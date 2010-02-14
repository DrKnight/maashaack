﻿/*
  Version: MPL 1.1/GPL 2.0/LGPL 2.1
 
  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/
  
  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the
  License.
  
  The Original Code is [maashaack framework].
  
  The Initial Developers of the Original Code are
  Zwetan Kjukov <zwetan@gmail.com> and Marc Alcaraz <ekameleon@gmail.com>.
  Portions created by the Initial Developers are Copyright (C) 2006-2010
  the Initial Developers. All Rights Reserved.
  
  Contributor(s):
  
  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the LGPL or the GPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.
*/

package graphics.filters 
{
    import system.process.Lockable;

    import flash.display.DisplayObject;
    import flash.filters.BitmapFilter;

    /**
     * This collector defines all filters to update a specific DisplayObject view with multiple BitmapFilter (or multiple with the apply method).
     */
    public class Filters implements Lockable
    {
        /**
         * Creates a new Filters instance.
         * @param display An optional DisplayObject reference.
         */
        public function Filters( display:DisplayObject = null ):void
        {
            this.filters = [] ;
            this.display = display ;
        }
        
        /**
         * Indicates the display reference.
         */
        public function get display():DisplayObject
        {
            return _display ;
        }
        
        /**
         * @private
         */
        public function set display( display:DisplayObject ):void
        {
            _display = display ; 
            if ( _display &&  _display.filters && _display.filters != null )
            {
                var a:Array = _display.filters ;
                var l:int   = a.length ;
                lock() ;
                if ( l > 0 )
                {
                    for( var i:int ; i<l ; i++ )
                    {
                        addFilter( a[i] ) ;
                    }
                }
                unlock() ;
            }
        }
        
        /**
         * Indicates the number of filters.
         */
        public function get numFilters():uint
        {
            return filters.length ;
        }
        
        /**
         * Inserts a new BitmapFilter.
         * @param filter The BitmapFilter object to insert in the collection.
         * @return <code>true</code> If the BitmapFilter is register.
         */
        public function addFilter( filter:BitmapFilter ):Boolean
        {
            if ( filter )
            {
                if ( filters.indexOf( filter ) > -1 )
                {
                    return false ;
                }
                filters[ filters.length ] = filter ;
                update() ;
                return true ;
            }
            else
            {
                return false ;
            }
        }
        
        /**
         * Initialize the filters property of the specified DisplayObject reference.
         */
        public function apply( display:DisplayObject ):void
        {
            if ( display == null )
            {
                throw new ArgumentError( this + " apply failed, the display argument not must be null.") ;
            }
            if ( _locked )
            {
                return ;
            }
            if ( filters.length > 0 )
            {
                display.filters = filters ;
            }
            else
            {
                display.filters = null ;
            }
        }
        
        /**
         * Returns <code class="prettyprint">true</code> if the specified receiver is connected.
         * @return <code class="prettyprint">true</code> if the specified receiver is connected.
         */
        public function hasFilter( filter:BitmapFilter ):Boolean
        {
            return filters.indexOf( filter ) > -1 ;
        }
        
        /**
         * Returns <code>true</code> if one or more receivers are connected.
         * @return <code>true</code> if one or more receivers are connected.
         */
        public function isEmpty():Boolean
        {
            return !( filters.length > 0 ) ;
        }
        /**
         * Returns <code class="prettyprint">true</code> if the object is locked.
         * @return <code class="prettyprint">true</code> if the object is locked.
         */
        public function isLocked():Boolean
        {
            return _locked ;
        }
        
        /**
         * Locks the object.
         */
        public function lock():void
        {
            _locked = true ; 
        }
        
        /**
         * Removes a specific BitmapFilter reference.
         * @return <code>true</code> if the specified filter exist and can be unregister.
         */
        public function removeFilter( filter:BitmapFilter = null  ):Boolean
        {
            if ( filter == null )
            {
                if ( filters.length > 0 )
                { 
                    filters = [] ;
                    update() ;
                    return true ;
                }
                else
                {
                    return false ;
                }
            }
            var index:int = filters.indexOf( filter )  ;
            if ( index > -1 )
            {
                filters.splice( index , 1 ) ;
                update() ;
                return true ;
            }
            else
            {
                return false ; 
            }
        }
        
        /**
         * Unlocks the object.
         */
        public function unlock():void
        {
            _locked = false ;
        }
        
        /**
         * Updates the display filters.
         */
        public function update():void
        {
            if ( _locked )
            {
                return ;
            }
            if ( display )
            {
                if ( filters.length > 0 )
                {
                    display.filters = filters ;
                }
                else
                {
                    display.filters = null ;
                }
            }
        }
        
        /**
         * Returns the Array representation of all receivers connected with the signal.
         * @return the Array representation of all receivers connected with the signal.
         */
        public function toArray():Array
        {
            if ( filters.length > 0 )
            {
                return filters.slice() ;
            }
            else
            {
                return [] ;
            }
        }
        
        /**
         * @private
         */
        protected var filters:Array ;
        
        /**
         * @private
         */
        private var _display:DisplayObject ;
        
        /**
         * @private
         */
        private var _locked:Boolean ;
    }
}
