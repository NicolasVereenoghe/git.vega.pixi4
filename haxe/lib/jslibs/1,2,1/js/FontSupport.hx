package js;

/**
 * See https://github.com/drdk/dr-font-support.
 */
@:native("fontSupport")
extern class FontSupport
{
	private static function __init__() : Void
	{
		untyped __js__("(function(){ var define, module;");
		haxe.macro.Compiler.includeFile("js/FontSupport.js", "inline");
		untyped __js__("})()");
	}
	
	static inline function isFormatSupported(format:String, callb:Bool->Void) : Void run(callb, format);
	static inline function getSupportedFormat(formats:Array<String>, callb:String->Void) : Void run(callb, formats);
	static inline function getSupportedFormats(callb:{ woff2:Bool, woff:Bool, ttf:Bool, svg:Bool }->Void) : Void run(callb);
	
	@:selfCall private static function run(callb:Dynamic, ?formats:Dynamic):Void;
}
