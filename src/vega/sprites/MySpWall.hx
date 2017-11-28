package vega.sprites;

import vega.sprites.MySprite;
import vega.utils.PointXY;

/**
 * sprite de mur simple
 * 
 * @author nico
 */
class MySpWall extends MySprite {
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function doBounce( pSp : MySprite, pXY : PointXY = null, pIsFeet : Bool = true) : Bool { return getHitRect().contains( pXY.x, pXY.y); }
}