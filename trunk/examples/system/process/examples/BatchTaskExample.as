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
  Portions created by the Initial Developers are Copyright (C) 2006-2011
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

package examples
{
    import system.process.Action;
    import system.process.BatchTask;
    import system.process.Pause;
    
    import flash.display.Sprite;
    
    [SWF(width="740", height="480", frameRate="24", backgroundColor="#666666")]
    
    public class BatchTaskExample extends Sprite
    {
        public function BatchTaskExample()
        {
            batch = new BatchTask() ;
            
            // batch.mode = BatchTask.TRANSIENT ;
            
            batch.changeIt.connect( change ) ;
            batch.finishIt.connect( finish ) ;
            batch.progressIt.connect( progress ) ;
            batch.startIt.connect( start ) ;
            
            batch.addAction( new Pause(  2 , true ) , 0 , true ) ;
            batch.addAction( new Pause( 10 , true ) ) ;
            batch.addAction( new Pause(  1 , true ) , 0 , true ) ;
            batch.addAction( new Pause(  5 , true ) ) ;
            batch.addAction( new Pause(  7 , true ) , 0 , true ) ;
            batch.addAction( new Pause(  2 , true ) ) ;
            
            batch.run() ;
            
            // start
            // progress : [Pause duration:1s]
            // progress : [Pause duration:2s]
            // progress : [Pause duration:2s]
            // progress : [Pause duration:5s]
            // progress : [Pause duration:7s]
            // progress : [Pause duration:10s]
            // finish
        }
        
        public var batch:BatchTask ;
        
        public function change( action:Action ):void
        {
            trace( "change :  " + batch.current ) ;
        }
        
        public function finish( action:Action ):void
        {
            trace( "finish length:" + batch.length ) ;
        }
        
        public function progress( action:Action ):void
        {
            trace( "progress :  " + batch.current ) ;
        }
        
        public function start( action:Action ):void
        {
            trace( "start" ) ;
        }
    }
}