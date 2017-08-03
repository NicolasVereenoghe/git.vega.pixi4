package js;

#if (!js_force_global_node_loader && !jslibs_node_loader)
@:native("fullScreenApi")
#else
@:jsRequire("haxelib/jslibs/js/FullScreenApi")
#end
extern class FullScreenApi
{
	#if (!js_force_global_node_loader && !jslibs_node_loader)
	private static function __init__() : Void
	{
		untyped __js__(";(function(){ var define, module;");
		haxe.macro.Compiler.includeFile("js/FullScreenApi.js", "inline");
		untyped __js__("})()");
	}
	#end
	
	public static var supportsFullScreen(default, null) : Bool;
	public static var fullScreenEventName(default, null) : String;
	
	public static function isFullScreen() : Bool;
	public static function requestFullScreen(el:js.html.Element) : Bool;
	public static function cancelFullScreen() : Void;
}