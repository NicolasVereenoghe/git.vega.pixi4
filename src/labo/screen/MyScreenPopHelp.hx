package labo.screen;

import pixi.core.display.DisplayObject;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.local.LocalMgr;
import vega.screen.MyScreen;
import vega.sound.SndMgr;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author nico
 */
class MyScreenPopHelp extends MyScreen {
	public function new() {
		super();
		
		ASSET_ID = "popHelp";
	}
	
	override public function destroy() : Void {
		UtilsPixi.unsetQuickBt( getHit());
		
		LocalMgr.instance.recursiveFreeLocalTxt( asset);
		
		super.destroy();
	}
	
	override function launchAfterInit() : Void { setModeFadeIn(); }
	
	override function buildContent() : Void {
		super.buildContent();
		
		UtilsPixi.setQuickBt( getHit(), onClose);
		
		LocalMgr.instance.recursiveSetLocalTxt( asset);
	}
	
	function onClose( pE : InteractionEvent) : Void {
		SndMgr.getInstance().play( "click");
		
		shell.onScreenClose( this);
		
		setModeFadeOut();
	}
	
	function getHit() : DisplayObject { return cast( asset.getContent(), Movie).getLayer( "hit"); }
}