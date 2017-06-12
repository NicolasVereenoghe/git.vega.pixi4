package vega.paddle;
import js.Browser;
import js.html.KeyboardEvent;
import vega.shell.ApplicationMatchSize;
import vega.shell.GlobalPointer;

/**
 * controller à un bouton ; souris + touchpad + keys
 * @author	nico
 */
class OneButtonPaddle {
	/** nombre d'itérations consécutives avec le controller actif */
	public var downCtr( default, null)		: Int								= 0;
	
	/** indique si le verrou d'action est activé (true) ou pas (false) */
	var isLocked							: Bool								= false;
	/** indique si à la dernière itération il y avait un control actif (true) ou pas (false) */
	var wasDown								: Bool								= false;
	
	/** map d'activation indexées par id de key */
	var actives								: Map<Int,Bool>;
	
	/**
	 * construction
	 */
	public function new() {
		// TODO !!
		actives = new Map<Int,Bool>();
		
		Browser.document.addEventListener( "keydown", onKeyDown);
		Browser.document.addEventListener( "keyup", onKeyUp);
		
		if ( GlobalPointer.instance == null) {
			ApplicationMatchSize.instance.traceDebug( "WARNING : OneButtonPaddle::OneButtonPaddle : no GlobalPointer instance, creating one ...");
			
			new GlobalPointer();
		}
	}
	
	/**
	 * destruction
	 */
	public function destroy() : Void {
		Browser.document.removeEventListener( "keydown", onKeyDown);
		Browser.document.removeEventListener( "keyup", onKeyUp);
		
		actives = null;
	}
	
	/**
	 * itération de frame
	 * @param	pDt		dt en ms
	 */
	public function doFrame( pDt : Float) : Void {
		wasDown = ( GlobalPointer.instance.isDown || isKeyActive());
		
		if ( isLocked && ! wasDown) isLocked = false;
		
		if ( isDown()) downCtr++;
		else downCtr = 0;
	}
	
	/**
	 * on verrouille le control qui devient inactif tant qu'on n'a pas relâché le control
	 */
	public function lock() : Void { isLocked = wasDown; }
	
	/**
	 * on vérifie si le control est actif
	 * @return	true si control actif, false si pas d'action
	 */
	public function isDown() : Bool { return ( ! isLocked) && wasDown; }
	
	/**
	 * capture de keys down
	 * @param	pE	event de keys down
	 */
	function onKeyDown( pE : KeyboardEvent) : Void {
		actives[ pE.keyCode] = true;
		
		if ( pE.keyCode == 37 || pE.keyCode == 38 || pE.keyCode == 39 || pE.keyCode == 40 || pE.keyCode == 32) pE.preventDefault();
	}
	
	/**
	 * capture de keys up
	 * @param	pE	event de keys up
	 */
	function onKeyUp( pE : KeyboardEvent) : Void { actives.remove( pE.keyCode); }
	
	/**
	 * détermine si au moins une touche de keys est active
	 * @return	true si keys actif, sinon false
	 */
	function isKeyActive() : Bool {
		for ( iKey in actives) return true;
		
		return false;
	}
}