package vega.sprites;

import vega.sprites.MySprite;
import vega.utils.PointXY;

/**
 * sprite de plateforme simple
 * 
 * @author nico
 */
class MySpPF extends MySprite implements ISpPF {
	public function new() { super(); }
	
	/** @inheritDoc */
	override public function doBounce( pSp : MySprite, pXY : PointXY = null, pIsFeet : Bool = true) : Bool { return pIsFeet && getHitRect().contains( pXY.x, pXY.y); }
}