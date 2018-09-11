package vega.local;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class TxtDescFlump {
	public static inline var ALIGN_CENTER	: String					= "center";
	public static inline var ALIGN_RIGHT	: String					= "right";
	
	public static inline var V_ALIGN_CENTER	: String					= "center";
	public static inline var V_ALIGN_BOT	: String					= "bot";
	
	public var localId						: String;
	public var fontId						: String;
	public var size							: Int;
	public var align						: String;
	public var color						: String;
	public var wordWrap						: Float						= -1;
	public var vAlign						: String;
	public var lineHeight					: Float						= 0;
	public var forcedLangI					: Int						= -1;
	public var antialiasForReadability		: Bool						= null;
	public var padding						: Float						= 0;
	
	public function new( pLayerData : String) {
		var lDatas	: Array<String>	= pLayerData.split( LocalMgr.instance.TXT_SEP);
		
		if ( lDatas.length < 6) throw "WARNING : TxtDescFlump::TxtDescFlump : invalid params : " + pLayerData;
		
		localId		= lDatas[ 1];
		fontId		= lDatas[ 2];
		size		= Std.parseInt( lDatas[ 3]);
		align		= lDatas[ 4];
		color		= "#" + lDatas[ 5];
		
		if ( lDatas.length > 6) wordWrap = Std.parseFloat( lDatas[ 6]);
		if ( lDatas.length > 7) vAlign = lDatas[ 7];
		if ( lDatas.length > 8) lineHeight = Std.parseFloat( lDatas[ 8]);
		if ( lDatas.length > 9 && lDatas[ 9] != "") forcedLangI = Std.parseInt( lDatas[ 9]);
		
		if ( lDatas.length > 10 && lDatas[ 10] != "") antialiasForReadability = ( lDatas[ 10] == "1");
		else antialiasForReadability = LocalMgr.USE_ANTIALIAS_FOR_READABILITY;
		
		if ( lDatas.length > 11 && lDatas[ 11] != "") padding = Std.parseFloat( lDatas[ 11]);
	}
}