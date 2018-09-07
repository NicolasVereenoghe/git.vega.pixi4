package vega.local;

/**
 * ...
 * @author nico
 */
class VideoSrtChunk {
	public var start( default, null)								: Int;
	public var end( default, null)									: Int;
	public var txt( default, null)									: String;
	public var index( default, null)								: Int;
	
	public function new() { }
	
	public function init( pStartTime : Int, pEndTime : Int, pTxt : String, pChunkI : Int) : Void {
		start	= pStartTime;
		end		= pEndTime;
		txt		= pTxt;
		index	= pChunkI;
	}
}