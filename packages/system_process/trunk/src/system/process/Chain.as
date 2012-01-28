﻿/*  Version: MPL 1.1/GPL 2.0/LGPL 2.1   The contents of this file are subject to the Mozilla Public License Version  1.1 (the "License"); you may not use this file except in compliance with  the License. You may obtain a copy of the License at  http://www.mozilla.org/MPL/    Software distributed under the License is distributed on an "AS IS" basis,  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License  for the specific language governing rights and limitations under the  License.    The Original Code is [maashaack framework].    The Initial Developers of the Original Code are  Zwetan Kjukov <zwetan@gmail.com> and Marc Alcaraz <ekameleon@gmail.com>.  Portions created by the Initial Developers are Copyright (C) 2006-2012  the Initial Developers. All Rights Reserved.    Contributor(s):    Alternatively, the contents of this file may be used under the terms of  either the GNU General Public License Version 2 or later (the "GPL"), or  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),  in which case the provisions of the GPL or the LGPL are applicable instead  of those above. If you wish to allow use of your version of this file only  under the terms of either the GPL or the LGPL, and not to allow others to  use your version of this file under the terms of the MPL, indicate your  decision by deleting the provisions above and replace them with the notice  and other provisions required by the LGPL or the GPL. If you do not delete  the provisions above, a recipient may use your version of this file under  the terms of any one of the MPL, the GPL or the LGPL.*/package system.process {    /**     * A chain is a sequence with a finite or infinite number of actions. All actions registered in the chain can be executed one by one with different strategies (loop, auto remove, etc).     * <p><b>Example :</b></p>     * <pre class="prettyprint">     * package examples     * {     *     import system.events.ActionEvent;     *     import system.process.Action;     *     import system.process.Chain;     *     import system.process.Pause;     *          *     import flash.display.Sprite;     *          *     [SWF(width="740", height="480", frameRate="24", backgroundColor="#666666")]     *          *     public class ChainBasicExample extends Sprite     *     {     *         public function ChainBasicExample()     *         {     *             var chain:Chain = new Chain() ;     *                  *             chain.addEventListener( ActionEvent.FINISH   , debug ) ;     *             chain.addEventListener( ActionEvent.PROGRESS , debug ) ;     *             chain.addEventListener( ActionEvent.START    , debug ) ;     *                  *             chain.finishIt.connect( finish ) ;     *             chain.progressIt.connect( progress ) ;     *             chain.startIt.connect( start  ) ;     *                  *             chain.addAction( new Pause(1) ) ;     *             chain.addAction( new Pause(1) ) ;     *             chain.addAction( new Pause(1) ) ;     *                  *             chain.run() ;     *         }     *              *         public function debug( e:ActionEvent ):void     *         {     *             trace( "debug " + e.type ) ;     *         }     *              *         public function finish( action:Action ):void     *         {     *             trace( "finish" ) ;     *         }     *              *         public function progress( action:Action ):void     *         {     *             trace( "progress : " + (action as Chain).current ) ;     *         }     *              *         public function start( action:Action ):void     *         {     *             trace( "start" ) ;     *         }     *     }     * }     * </pre>     */    public class Chain extends TaskGroup    {        /**         * Creates a new Chain instance.         * @param length The initial length (number of elements) of the Vector. If this parameter is greater than zero, the specified number of Vector elements are created and populated with the default value appropriate to the base type (null for reference types).         * @param fixed Whether the chain length is fixed (true) or can be changed (false). This value can also be set using the fixed property.         * @param looping Specifies whether playback of the clip should continue, or loop (default false).          * @param numLoop Specifies the number of the times the presentation should loop during playback.         * @param mode Specifies the mode of the chain. The mode can be "normal" (default), "transient" or "everlasting".         * @param actions A dynamic object who contains Action references to initialize the chain.         */        public function Chain( length:uint = 0 , fixed:Boolean = false , looping:Boolean = false , numLoop:uint = 0 , mode:String = "normal" , actions:* = null )        {            this.looping = looping ;            this.numLoop = numLoop ;            super( length , fixed , mode , actions ) ;        }                /**         * Determinates the "everlasting" mode of the chain. In this mode the action register in the chain can't be auto-remove.         */        public static const EVERLASTING:String = "everlasting" ;                /**         * Determinates the "normal" mode of the chain. In this mode the chain has a normal life cycle.         */        public static const NORMAL:String = "normal" ;                /**         * Determinates the "transient" mode of the chain. In this mode all actions are strictly auto-remove in the chain when are invoked.         */        public static const TRANSIENT:String = "transient" ;                /**         * Indicates the current Action reference when the chain process is running.         */        public function get current():Action        {            return _current ? _current.action : null ;        }                /**         * Indicates the current countdown loop value.         */        public function get currentLoop():uint        {            return _currentLoop ;        }                /**         * @private         */        public override function set length( value:uint ):void        {            _current = null ;            super.length = value ;        }                /**         * Specifies the number of the times the chain should loop during playback.         */        public var numLoop:uint ;                /**         * Indicates the current numeric position of the chain.         */        public function get position():uint        {            return _position ;        }                /**         * Returns a shallow copy of this object.         * @return a shallow copy of this object.         */        public override function clone():*        {            var clone:Chain = new Chain( 0 , false , looping , numLoop , _mode, _actions.length > 0 ? toVector() : null ) ;            clone.fixed = _actions.fixed ;            return clone ;        }                /**         * Retrieves the next action reference in the chain with the current position.         */        public function element():*         {            return hasNext() ? (_actions[_position] as ActionEntry).action : null ;        }                /**         * Indicates if the chain contains a next action (based with the current position value).         */        public function hasNext():Boolean        {            return _position < _actions.length ;        }                /**         * Resume the chain.         */        public override function resume():void         {            if ( _stopped )            {                setRunning(true) ;                _stopped = false ;                notifyResumed() ;                if ( _current && _current.action && _current.action is Resumable )                {                    (_current.action as Resumable).resume() ;                }                else                {                    next() ;                }             }            else            {                run() ;             }        }                /**         * Launchs the chain process.         */        public override function run( ...arguments:Array ):void         {            if ( !running )            {                notifyStarted() ;                _current     = null  ;                _stopped     = false ;                _position    = 0 ;                _currentLoop = 0 ;                next() ;            }        }                /**         * Stops the chain. Stop only the current action if is running.         */        public override function stop():void        {            if ( running )             {                if ( _current && _current.action )                {                    if ( _current.action is Stoppable )                    {                        (_current.action as Stoppable).stop() ;                    }                }                setRunning( false ) ;                _stopped = true ;                notifyStopped() ;            }        }                /**         * @private         */        protected var _current:ActionEntry ;                /**         * @private         */        protected var _currentLoop:uint ;                /**         * @private         */        protected var _position:int ;                /**         * Run the next action in the chain.         */        protected override function next( action:Action = null ):void         {            if ( _current )            {                if ( _mode != EVERLASTING )                {                    if ( _mode == TRANSIENT || (_current.auto && _mode == NORMAL) )                    {                        _current.action.finishIt.disconnect( next ) ;                        _position -- ;                        _actions.splice( _position , 1 ) ;                    }                }                notifyChanged() ;                _current = null ;            }            if ( _actions.length > 0 )             {                if ( hasNext() )                {                    _current = _actions[_position++] as ActionEntry ;                    notifyProgress() ;                    if ( _current && _current.action )                    {                        _current.action.run() ;                    }                    else                    {                        next() ;                    }                }                else if ( looping )                {                    _position = 0 ;                    if( numLoop == 0 )                    {                        notifyLooped() ;                        _currentLoop = 0  ;                        next() ;                    }                    else if ( _currentLoop < numLoop )                    {                        _currentLoop ++ ;                        notifyLooped() ;                        next() ;                    }                    else                    {                        _currentLoop = 0 ;                        notifyFinished() ;                     }                }                else                {                    _currentLoop = 0 ;                    _position    = 0 ;                    notifyFinished() ;                }            }            else             {                notifyFinished() ;            }        }    }}