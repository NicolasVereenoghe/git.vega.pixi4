package labo.screen;

import pixi.interaction.InteractionEvent;
import vega.screen.MyScreenMain;
import vega.sound.SndMgr;

/**
 * ...
 * @author nico
 */
class MyScreenMainInit extends MyScreenMain {
	public function new() { super(); }
	
	override function onBtStart( pE : InteractionEvent) : Void {
		SndMgr.getInstance().play( "click", null, true);
		
		super.onBtStart( pE);
	}
}