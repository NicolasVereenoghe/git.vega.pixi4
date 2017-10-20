package labo.shell;

import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.math.shapes.Rectangle;
import pixi.flump.Movie;
import pixi.interaction.InteractionEvent;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.shell.ApplicationMatchSize;
import vega.shell.IGameShell;
import vega.shell.IMyHUD;
import vega.shell.ResizeBroadcaster;
import vega.sound.SndMgr;
import vega.ui.MyButtonFlump;
import vega.utils.UtilsFlump;
import haxe.extern.EitherType;

/**
 * ...
 * @author nico
 */
class MyHUD implements IMyHUD {
	var shell												: IGameShell					= null;
	
	var asset												: AssetInstance					= null;
	
	var container											: Container						= null;
	
	var btHelp												: MyButtonFlump					= null;

	public function new() { }
	
	public function init( pShell : IGameShell, pContainer : Container, pType : String = null) : Void {
		shell		= pShell;
		container	= pContainer;
		
		initAsset();
		
		ResizeBroadcaster.getInstance().addListener( onResize);
		
		onResize();
	}
	
	public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		// TODO !!
		freeAsset();
		
		container = null;
		shell = null;
	}
	
	public function doFrame( pDT : Float) : Void { }
	
	public function switchPause( pPause : Bool) : Void { }
	
	function initAsset() : Void {
		asset = cast container.addChild( AssetsMgr.instance.getAssetInstance( "myHUD"));
		
		btHelp = new MyButtonFlump( getBtHelp(), onHelp);
	}
	
	function freeAsset() : Void {
		btHelp.destroy();
		btHelp = null;
		
		container.removeChild( asset);
		asset.free();
		asset = null;
	}
	
	function onResize() : Void {
		var lRect	: Rectangle	= ApplicationMatchSize.instance.getScreenRect();
		
		UtilsFlump.setLayerXY(
			getBtHelp().parent,
			lRect.x + lRect.width,
			lRect.y
		);
	}
	
	function onHelp( pE : InteractionEvent) : Void {
		SndMgr.getInstance().play( "click");
		
		btHelp.reset();
		
		shell.onGameHelp();
		// TODO !!
		
		/*gMgr.switchPause( true);
		
		setCurScreen( new MyScreenPopHelp());
		
		btHelp.reset();
		
		asset.interactiveChildren = false;*/
	}
	
	function getBtHelp() : Movie { return cast cast( asset.getContent(), Movie).getLayer( "btHelp").getChildAt( 0); }
}