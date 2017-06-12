package vega.screen;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.local.LocalMgr;
import vega.ui.MyButtonFlump;
import vega.utils.UtilsFlump;
import vega.utils.UtilsPixi;

/**
 * ...
 * @author nico
 */
class MyScreenMain extends MyScreen {
	var hit								: DisplayObject					= null;
	var startBt							: DisplayObject					= null;
	var startBtFlump					: MyButtonFlump					= null;
	
	public function new() {
		super();
		
		ASSET_ID	= "screenMain";
	}
	
	override public function destroy() : Void {
		if ( asset != null) LocalMgr.instance.recursiveFreeLocalTxt( cast asset.getContent());
		
		if ( startBt != null){
			UtilsPixi.unsetQuickBt( startBt);
			startBt = null;
		}
		
		if ( startBtFlump != null){
			startBtFlump.destroy();
			startBtFlump = null;
		}
		
		if ( hit != null){
			UtilsPixi.unsetQuickBt( hit);
			hit = null;
		}
		
		super.destroy();
	}
	
	override function buildContent() : Void {
		super.buildContent();
		
		if ( asset != null){
			hit = getLayerHit();
			
			if( hit != null){
				hit = cast( asset.getContent(), Movie).getLayer( "hit");
				hit.alpha = 0;
				
				UtilsPixi.setQuickBt( hit, onBtStart);
			}
			
			buildContentStart();
			
			LocalMgr.instance.recursiveSetLocalTxt( cast asset.getContent());
		}
	}
	
	function buildContentStart() : Void {
		var lStart	: DisplayObject = getLayerStart();
		
		if ( lStart != null){
			if ( Std.is( cast( lStart, Container).getChildAt( 0), Movie) && UtilsFlump.getLayer( MyButtonFlump.NAME_UP, cast cast( lStart, Container).getChildAt( 0)) != null){
				startBtFlump = new MyButtonFlump( cast cast( lStart, Container).getChildAt( 0));
				startBtFlump.addPressListener( onBtStart);
			}else{
				startBt = lStart;
				
				UtilsPixi.setQuickBt( startBt, onBtStart);
			}
			
			if ( hit != null) hit.buttonMode = false;
		}
	}
	
	override function launchAfterInit() : Void { shell.onScreenReady( this); }
	
	function onBtStart( pE : InteractionEvent) : Void {
		shell.onScreenClose( this);
		
		setModeFadeOut();
		
		//pE.stopPropagation();
	}
	
	function getLayerHit() : Container { return UtilsFlump.getLayer( "hit", cast asset.getContent()); }
	function getLayerStart() : Container { return UtilsFlump.getLayer( "start", cast asset.getContent()); }
}