package;
import haxe.extern.EitherType;
import js.html.CanvasElement;
import js.html.Event;

@:native("window.CanvasInput")
extern class CanvasInput {
	public var outerW( default, null)				: Float;
	public var outerH( default, null)				: Float;
	
	public var _hiddenInput( default, null)			: CanvasElement;
	
	public var _mouseDown							: Bool;
	
	function new( pOptions : Dynamic);
	
	public function focus( ?pPos : Int) : Void;
	
	public function blur( ?pTarget : CanvasInput) : Void;
	
	public function renderCanvas() : CanvasElement;
	
	public function destroy() : Void;
	
	public function value( ?pForceValue : String) : EitherType<String,CanvasInput>;
}