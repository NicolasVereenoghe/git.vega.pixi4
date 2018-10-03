package vega.shell;
import js.Browser;

/**
 * ...
 * @author nico
 */
class VegaFramer {
	static var instance					: VegaFramer						= null;
	
	var iterators						: Array<Float -> Void>;
	
	var lastTime						: Float;
	
	var hasRequest						: Bool								= false;
	
	var isPause							: Bool								= false;
	
	var isError							: Bool								= false;
	
	var fps								: Int								= -1;
	
	var requestId						: Int								= -1;
	
	public static function getInstance() : VegaFramer {
		if ( instance == null) instance = new VegaFramer();
		
		return instance;
	}
	
	public static function freeInstance() : Void {
		if ( instance != null){
			instance.destroy();
			instance = null;
		}
	}
	
	public function new( pFps : Int = -1) {
		fps = pFps;
		
		iterators = new Array<Float -> Void>();
		
		lastTime = Date.now().getTime();
		
		if ( Browser.supported) onFrame( 0);
		else ApplicationMatchSize.instance.traceDebug( "ERROR : VegaFramer::VegaFramer : no browser, no framing ...");
	}
	
	public function destroy() : Void {
		if ( Browser.supported && hasRequest) cancelFrame();
		
		iterators = null;
	}
	
	public function isRegistered( pIterator : Float -> Void) : Bool { return iterators.indexOf( pIterator) != -1; }
	
	public function addIterator( pIterator : Float -> Void) : Void { iterators.push( pIterator); }
	
	public function remIterator( pIterator : Float -> Void) : Void { iterators.remove( pIterator); }
	
	public function switchPause( pIsPause : Bool) : Void {
		if ( isPause != pIsPause){
			if ( ! pIsPause){
				if ( ! hasRequest) {
					lastTime = Date.now().getTime();
					requestFrame();
				}
			}else cancelFrame();
			
			isPause = pIsPause;
		}
		
		/*if ( isPause && ! pIsPause){
			if ( ! hasRequest){
				lastTime = Date.now().getTime();
				requestFrame();
			}
		}
		
		isPause = pIsPause;*/
	}
	
	function getFps() : Int {
		if ( fps < 0) return ApplicationMatchSize.instance.fps;
		else return fps;
	}
	
	function onFrame( pTime : Float) : Void {
		if ( iterators == null) return;
		
		if ( ApplicationMatchSize.instance.debug){
			if ( isError) return;
			
			try{
				doFrame( pTime);
			}catch ( pE : Dynamic) {
				ApplicationMatchSize.instance.traceDebug( "ERROR :" + Std.string( pE).split( "\n")[ 0]);
				trace( pE);
				
				isError = true;
			}
		}else doFrame( pTime);
	}
	
	function doFrame( pTime : Float) : Void {
		var lTime		: Float;
		var lIterator	: Float -> Void;
		var lClone		: Array<Float -> Void>;
		var lDT			: Float;
		var lInter		: Float;
		var lAjust		: Float;
		
		if ( isPause) hasRequest = false;
		else{
			requestFrame();
			
			lTime	= Date.now().getTime();
			lInter	= 1000 / getFps();
			lDT		= Math.min( lTime - lastTime, 3 * lInter);
			
			if ( lDT >= lInter){
				lAjust = Math.min( lDT - lInter, lInter / 2);
				lDT -= lAjust;
				
				lClone = iterators.copy();
				for ( lIterator in lClone) if ( ( ! isPause) && iterators.indexOf( lIterator) != -1) lIterator( lDT);
				
				lastTime = lTime - lAjust;
			}
		}
	}
	
	function requestFrame() : Void {
		hasRequest = true;
		requestId = Browser.window.requestAnimationFrame( onFrame);
	}
	
	function cancelFrame() : Void {
		if ( hasRequest){
			Browser.window.cancelAnimationFrame( requestId);
			
			hasRequest = false;
			requestId = -1;
		}
	}
}