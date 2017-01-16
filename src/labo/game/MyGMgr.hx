package labo.game;
import labo.shell.MyHUD;
import vega.shell.SavedDatas;

import pixi.core.display.Container;
import vega.shell.GameMgrAssets;
import vega.shell.IGameShell;

/**
 * ...
 * @author nico
 */
class MyGMgr extends GameMgrAssets {
	var myHUD							: MyHUD									= null;
	
	public function new() { super(); }
	
	override public function getGameId() : String { return "Game"; }
	
	override public function init( pShell : IGameShell, pCont : Container, pSavedDatas : SavedDatas = null) : Void {
		super.init( pShell, pCont, pSavedDatas);
		
		myHUD = cast shell.enableGameHUD();
	}
	
	override public function destroy() : Void {
		myHUD = null;
		
		super.destroy();
	}
}