package vega.shell;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;
import haxe.extern.EitherType;

/**
 * interface de HUD de jeu
 * @author nico
 */
interface IMyHUD {
	/**
	 * initialisation du HUD
	 * @param	coque du jeu dont on gère le HUD
	 * @param	pContainer	le conteneur où attacher le rendu graphique du HUD
	 * @param	pType		nom identifiant d'un type de HUD
	 */
	function init( pShell : IGameShell, pContainer : Container, pType : String = null) : Void;
	
	/**
	 * destruction de l'interface HUD
	 */
	function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void;
	
	/**
	 * itération de frame du hud
	 * @param	pDT		variation de ms depuis dernière itération
	 */
	function doFrame( pDT : Float) : Void;
	
	/**
	 * on bascule la pause
	 * @param	pPause	true pour passer en pause, false pour reprendre la lecture
	 */
	function switchPause( pPause : Bool) : Void;
}