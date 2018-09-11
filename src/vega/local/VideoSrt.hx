package vega.local;
import pixi.flump.Movie;
import vega.loader.VegaLoaderMgr;
import vega.loader.file.MyFile;

class VideoSrt {
	var TIMING_SEP										: String													= "-->";
	
	var BIG_TIME_SEP									: String													= ":";
	var TINY_TIME_SEP									: String													= ".";
	
	var chunks											: Array<VideoSrtChunk>										= null;
	
	var movie											: Movie														= null;
	var txtLayerId										: String													= null;
	
	var currentChunkI									: Int														= -1;
	
	public function new() { }
	
	public function init( pTxtLayerId : String, pMovie : Movie, pFile : MyFile) : Void {
		var lData	: String			= VegaLoaderMgr.getInstance().getLoadingFile( pFile.getId()).getLoadedContent();
		var lSep	: String;
		var lLines	: Array<String>;
		var lLine	: String;
		var lI		: Int;
		var lEndI	: Int;
		var lT1		: Int;
		var lT2		: Int;
		var lTs		: Array<String>;
		var lTxt	: String;
		var lChunk	: VideoSrtChunk;
		
		movie		= pMovie;
		txtLayerId	= pTxtLayerId;
		
		if ( lData.indexOf( "\r\n") != -1) lSep = "\r\n";
		else if ( lData.indexOf( "\r") != -1) lSep = "\r";
		else lSep = "\n";
		
		lLines = lData.split( lSep);
		
		chunks = new Array<VideoSrtChunk>();
		
		lI = findNextChunkLineI( lLines);
		while ( lI >= 0){
			lTs		= lLines[ lI].split( TIMING_SEP);
			lT1		= parseTiming( lTs[ 0]);
			lT2		= parseTiming( lTs[ 1]);
			lEndI	= findNextChunkEndLineI( lLines, lI + 1);
			lTxt	= concatLines( lLines, lI + 1, lEndI, lSep);
			
			lChunk	= new VideoSrtChunk();
			lChunk.init( lT1, lT2, lTxt, chunks.length);
			
			chunks.push( lChunk);
			
			lI = findNextChunkLineI( lLines, lEndI + 1);
		}
		
		//trace( chunks);
	}
	
	public function destroy() : Void {
		freeCurrentChunkTxt();
		
		chunks = null;
		movie = null;
		txtLayerId = null;
	}
	
	public function update( pTime : Int) : Void {
		var lChunk	: VideoSrtChunk	= findChunkAt( pTime);
		
		if ( lChunk == null) freeCurrentChunkTxt();
		else if( lChunk.index != currentChunkI){
			if ( currentChunkI < 0) LocalMgr.instance.instanciateTxtFromFlumpModel( txtLayerId, movie, lChunk.txt);
			else{
				LocalMgr.instance.freeLocalTxtInMovie( movie);
				LocalMgr.instance.instanciateTxtFromFlumpModel( txtLayerId, movie, lChunk.txt);
			}
			
			currentChunkI = lChunk.index;
		}
	}
	
	function freeCurrentChunkTxt() : Void {
		if ( currentChunkI >= 0){
			LocalMgr.instance.freeLocalTxtInMovie( movie);
			
			currentChunkI = -1;
		}
	}
	
	function findChunkAt( pTime : Int) : VideoSrtChunk {
		var lI		: Int			= 0;
		var lChunk	: VideoSrtChunk;
		
		while ( lI < chunks.length){
			lChunk = chunks[ lI];
			
			if ( lChunk.start <= pTime && lChunk.end >= pTime) return lChunk;
			
			lI++;
		}
		
		return null;
	}
	
	function concatLines( pLines : Array<String>, pFromI : Int, pToI : Int, pSep : String) : String {
		var lRes	: String	= "";
		
		while ( pFromI <= pToI){
			if ( lRes == "") lRes = pLines[ pFromI];
			else lRes += pSep + pLines[ pFromI];
			
			pFromI++;
		}
		
		return lRes;
	}
	
	function findNextChunkLineI( pLines : Array<String>, pFromLineI : Int = 0) : Int {
		while ( pFromLineI < pLines.length){
			if ( pLines[ pFromLineI].indexOf( TIMING_SEP) != -1) return pFromLineI;
			
			pFromLineI++;
		}
		
		return -1;
	}
	
	function findNextChunkEndLineI( pLines : Array<String>, pFromLineI : Int) : Int {
		while ( pFromLineI < pLines.length && StringTools.trim( pLines[ pFromLineI]).length != 0) pFromLineI++;
		
		return pFromLineI - 1;
	}
	
	function parseTiming( pStrTime : String) : Int {
		var lBigParts	: Array<String>;
		var lTinyParts	: Array<String>;
		
		pStrTime	= StringTools.trim( pStrTime).split( " ")[ 0];
		
		lBigParts	= pStrTime.split( BIG_TIME_SEP);
		
		if ( lBigParts.length == 2){
			lTinyParts	= lBigParts[ 1].split( TINY_TIME_SEP);
			
			return Std.parseInt( lBigParts[ 0]) * 60 * 1000 + Std.parseInt( lTinyParts[ 0]) * 1000 + Std.parseInt( lTinyParts[ 1]);
		}else{
			lTinyParts	= lBigParts[ 2].split( TINY_TIME_SEP);
			
			return Std.parseInt( lBigParts[ 0]) * 60 * 60 * 1000 + Std.parseInt( lBigParts[ 1]) * 60 * 1000 + Std.parseInt( lTinyParts[ 0]) * 1000 + Std.parseInt( lTinyParts[ 1]);
		}
	}
}