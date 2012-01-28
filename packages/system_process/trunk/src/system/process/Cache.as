﻿/*  Version: MPL 1.1/GPL 2.0/LGPL 2.1   The contents of this file are subject to the Mozilla Public License Version  1.1 (the "License"); you may not use this file except in compliance with  the License. You may obtain a copy of the License at  http://www.mozilla.org/MPL/    Software distributed under the License is distributed on an "AS IS" basis,  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License  for the specific language governing rights and limitations under the  License.    The Original Code is [maashaack framework].    The Initial Developers of the Original Code are  Zwetan Kjukov <zwetan@gmail.com> and Marc Alcaraz <ekameleon@gmail.com>.  Portions created by the Initial Developers are Copyright (C) 2006-2012  the Initial Developers. All Rights Reserved.    Contributor(s):    Alternatively, the contents of this file may be used under the terms of  either the GNU General Public License Version 2 or later (the "GPL"), or  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),  in which case the provisions of the GPL or the LGPL are applicable instead  of those above. If you wish to allow use of your version of this file only  under the terms of either the GPL or the LGPL, and not to allow others to  use your version of this file under the terms of the MPL, indicate your  decision by deleting the provisions above and replace them with the notice  and other provisions required by the LGPL or the GPL. If you do not delete  the provisions above, a recipient may use your version of this file under  the terms of any one of the MPL, the GPL or the LGPL.*/package system.process {    import system.process.caches.Attribute;    import system.process.caches.Method;    import system.process.caches.Property;    
    /**     * Enqueue a collection of members definitions (commands) to apply or invoke with the specified target object.     * <p><b>Example :</b></p>     * <pre class="prettyprint">     * import core.dump ;     * import system.process.Cache ;     *      * var object:Object = {} ;     *      * object.a = 1 ;     * object.b = 2 ;     * object.c = 3 ;     * object.d = 3 ;     *      * object.method1 = function( value:uint ):void     * {     *     this.c = value ;     * };     *      * object.method2 = function( value1:uint , value2:uint ):void     * {     *     this.d = value1 + value2 ;     * };     *      * object.setPropertyIsEnumerable("method1", false) ;     * object.setPropertyIsEnumerable("method2", false) ;     *      * trace( core.dump( object ) ) ; // {b:2,d:3,a:1,c:3}     *      * var cache:Cache = new Cache() ;     *      * cache.enqueueAttribute("a", 10) ;     * cache.enqueueAttribute("b", 20) ;     *      * cache.enqueueMethod("method1", 30) ;     * cache.enqueueMethod("method2", 40 , 50) ;     *      * cache.target = object ;     *      * cache.run() ; // flush the cache and initialize the target or invoked this methods.     *      * trace( core.dump( object ) ) ; // {b:20,c:30,d:90,a:10}     * </pre>     */    public class Cache extends Task     {        /**         * Creates a new Cache instance.         * @param target The scope of the cache object.         */        public function Cache( target:* = null , init:Vector.<Property> = null )        {            this.target = target ;            _queue = new Vector.<Property>() ;            if ( init && init.length > 0 )            {                for each( var prop:Property in init )                {                    _queue.push( prop ) ;                }            }        }                /**         * Returns the number of commands in memory.         * @return the number of commands in memory.         */        public function get length():uint        {            return _queue.length;         }                /**         * The scope of the object.         */        public var target:* ;                /**         * Removes all commands in memory.         */        public function clear():void        {           _queue.length = 0 ;        }                /**         * Creates and returns a shallow copy of the object.         * @return A new object that is a shallow copy of this instance.         */        public override function clone():*        {            return new Cache( target , _queue ) ;        }                /**         * Enqueues an attribute name/value entry.         */        public function enqueueAttribute( name:String , value:* ):Cache        {            if ( name != null && name != "" )            {                _queue.push( new Attribute( name , value ) ) ;            }            return this ;        }                /**         * Enqueues a method definition.         * @param name The name of the method.         * @param ...args The optional arguments passed-in the method.          */        public function enqueueMethod( name:String , ...args:Array ):Cache        {            if ( name != null && name != "" )            {                _queue.push( new Method( name , args ) ) ;            }            return this ;        }                /**         * Enqueues a method definition with an Array of arguments and an optional rest list of parameters..         * @param name The name of the method.         * @param args The Array of all arguments passed-in the method.         * @param rest The optional Array reference of rest arguments passed-in the method (if the method use a ..rest definition).         */        public function enqueueMethodWithArguments( name:String , args:Array , rest:Array = null ):Cache        {            if ( name != null && name != "" )            {                if ( rest != null )                {                    args = (args || []).concat( rest ) ;                }                _queue.push( new Method( name , args ) ) ;            }            return this ;        }                /**         * Indicates if the tracker cache is empty.         */        public function isEmpty():Boolean        {           return _queue.length == 0 ;        }                /**         * Flush and invoke all the commands in memory.         */        public override function run(...arguments:Array):void        {            notifyStarted() ;            if ( target )            {                var l:int = _queue.length ;                if ( l > 0 )                {                    var item:* ;                    var name:String;                    for ( var i:int ; i<l ; i++ )                    {                        item = _queue.shift() ;                        if ( item is Method )                        {                            name = (item as Method).name ;                            if ( name != null && name in target )                            {                                if ( target[name] is Function )                                {                                    (target[name] as Function).apply(target, (item as Method).arguments) ;                                }                            }                        }                        else if ( item is Attribute )                        {                            name  = (item as Attribute).name ;                            if ( name != null && name in target )                            {                                target[name] = (item as Attribute).value ;                            }                        }                    }                }            }            notifyFinished() ;        }                /**         * @private         */        internal var _queue:Vector.<Property> ;    }}