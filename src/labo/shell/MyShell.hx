package labo.shell;

import labo.game.MyGMgr;
import labo.screen.MyScreenPopHelp;
import labo.shell.MyHUD;
import labo.screen.MyScreenMainInit;
import pixi.core.display.Container;
import pixi.core.math.shapes.Rectangle;
import pixi.interaction.InteractionEvent;
import vega.assets.AssetInstance;
import vega.assets.AssetsMgr;
import vega.loader.VegaLoader;
import vega.loader.file.MyFile;
import vega.screen.MyScreen;
import vega.screen.MyScreenInitLoad;
import vega.screen.MyScreenMain;
import vega.shell.ApplicationMatchSize;
import vega.shell.GameShell;
import vega.shell.IGameMgr;
import vega.shell.IMyHUD;
import vega.shell.ResizeBroadcaster;
import vega.sound.SndDesc;
import vega.sound.SndMgr;
import vega.ui.MyButtonFlump;
import vega.utils.UtilsFlump;

/**
 * ...
 * @author nico
 */
class MyShell extends GameShell {
	var btFullscreen							: MyButtonFlump								= null;
	var btFullscreenAsset						: AssetInstance								= null;
	
	var myHUDContainer							: Container;
	var curHUD									: IMyHUD									= null;
	
	public function new() {
		super();
		
		ResizeBroadcaster.getInstance().addListener( onResize);
	}
	
	override public function init( pCont : Container, pFileAssets : MyFile, pFileLocal : MyFile, pFonts : Dynamic) : Void {
		super.init( pCont, pFileAssets, pFileLocal, pFonts);
		
		myHUDContainer = cast pCont.addChildAt( new Container(), pCont.getChildIndex( gameContainer) + 1);
		
		gameContainer.interactiveChildren = false;
		myHUDContainer.interactiveChildren = false;
	}
	
	override public function getCurGameHUD() : IMyHUD { return curHUD; }
	
	override public function enableGameHUD( pType : String = null) : IMyHUD {
		if ( curHUD == null){
			curHUD = new MyHUD();
			
			curHUD.init( this, myHUDContainer);
		}else ApplicationMatchSize.instance.traceDebug( "ERROR : MyShell::enableGameHUD : un HUD est déjà actif, ignore");
		
		return curHUD;
	}
	
	override public function onGameHelp( pHelpTag : String = null) : Void {
		curGame.switchPause( true);
		
		gameContainer.interactiveChildren = false;
		myHUDContainer.interactiveChildren = false;
		
		setCurScreen( new MyScreenPopHelp());
	}
	
	override public function onScreenEnd( pScreen : MyScreen) : Void {
		super.onScreenEnd( pScreen);
		
		if ( ( Std.is( pScreen, MyScreenMain) || Std.is( pScreen, MyScreenPopHelp)) && curScreen == null && curGame != null){
			gameContainer.interactiveChildren = true;
			myHUDContainer.interactiveChildren = true;
			
			curGame.switchPause( false);
		}
	}
	
	function onResize() : Void {
		var lRect	: Rectangle;
		
		if ( btFullscreenAsset != null){
			lRect = ApplicationMatchSize.instance.getScreenRect();
			
			btFullscreenAsset.x	= lRect.x;
			btFullscreenAsset.y	= lRect.y;
		}
	}
	
	function onBtFullscreen( pE : InteractionEvent) : Void { SndMgr.getInstance().play( "click", null, true); }
	
	override function setCurScreen( pScreen : MyScreen) : Void {
		super.setCurScreen( pScreen);
		
		if ( Std.is( pScreen, MyScreenMain) && btFullscreenAsset == null){
			btFullscreenAsset	= cast _containerScr.addChildAt( AssetsMgr.instance.getAssetInstance( "btFullscreen"), _containerScr.getChildIndex( pScreen.getContainer()) + 1);
			btFullscreen		= UtilsFlump.createFullscreenBt( cast btFullscreenAsset.getContent());
			btFullscreen.addDownListener( onBtFullscreen);
			
			onResize();
		}
	}
	
	override function loadAssetsMain( pLoader : VegaLoader = null) : Void {
		if ( pLoader == null) pLoader = new VegaLoader();
		
		pLoader.addHowlFile( new SndDesc( "click"));
		
		super.loadAssetsMain( pLoader);
	}
	
	override function onAssetsMainProgress( pLoader : VegaLoader) : Void { if ( Std.is( curScreen, MyScreenInitLoad) && ! isLocked) cast( curScreen, MyScreenInitLoad).onLoadProgress( pLoader.getProgressRate() * .25); }
	
	override function onMallocMainProgress( pCur : Int, pTotal : Int) : Void { if( Std.is( curScreen, MyScreenInitLoad) && ! isLocked) cast( curScreen, MyScreenInitLoad).onLoadProgress( .25 + ( pCur / pTotal) * .25); }
	
	override function onMallocMainEnd() : Void { launchGame(); }
	
	override public function onGameProgress( pRate : Float) : Void { if ( Std.is( curScreen, MyScreenInitLoad) && ! isLocked) cast( curScreen, MyScreenInitLoad).onLoadProgress( .5 + pRate * .5); }
	
	override public function onGameReady() : Void {
		super.onGameReady();
		
		curGame.switchPause( true);
		
		super.onMallocMainEnd();
	}
	
	override function getScreenMain() : MyScreenMain { return new MyScreenMainInit(); }
	
	override function getGameInstance() : IGameMgr { return new MyGMgr(); }
}