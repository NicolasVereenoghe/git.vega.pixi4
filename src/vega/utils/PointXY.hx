package vega.utils;

/**
 * ...
 * @author 
 */
class PointXY {
	public var x					: Float;
	public var y					: Float;
	
	public function new( pX : Float = 0, pY : Float = 0) {
		x	= pX;
		y	= pY;
	}
	
	public function clone() : PointXY { return new PointXY( x, y); }
	
	public function copy( pPoint : PointXY) : Void {
		x	= pPoint.x;
		y	= pPoint.y;
	}
	
	public function equals( pPoint : PointXY) : Bool { return x == pPoint.x && y == pPoint.y; }
}