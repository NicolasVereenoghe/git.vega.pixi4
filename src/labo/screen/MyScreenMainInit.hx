package labo.screen;

import pixi.interaction.EventTarget;
import vega.screen.MyScreenMain;
import vega.sound.SndMgr;

/**
 * ...
 * @author nico
 */
class MyScreenMainInit extends MyScreenMain {
	public function new() { super(); }
	
	override function onBtStart( pE : EventTarget) : Void {
		SndMgr.getInstance().play( "click", null, true);
		
		super.onBtStart( pE);
	}
}