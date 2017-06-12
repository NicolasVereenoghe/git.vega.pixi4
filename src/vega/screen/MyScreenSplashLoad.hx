package vega.screen;

import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import vega.assets.AssetsMgr;
import vega.loader.VegaLoaderMgr;

/**
 * ...
 * @author 
 */
class MyScreenSplashLoad extends MyScreenPreload {
	var CONTENT_DELAY								: Float							= 200;
	var contentDelay								: Float;
	
	var isSplashLoaded								: Bool							= false;
	
	public function new() {
		super();
		
		ASSET_ID		= "screenSplash";
		
		fadeFrontColor	= 0xFFFFFF;
	}
	
	public function onSplashLoaded() : Void {
		isSplashLoaded = true;
		
		buildContentAsset();
	}
	
	override function buildContentAsset() : Void {
		if ( isSplashLoaded){
			if( ASSET_ID != null){
				asset = cast content.addChildAt( AssetsMgr.instance.getAssetInstance( ASSET_ID), 0);
				
				if ( VegaLoaderMgr.getInstance().getLoadingFile( asset.getDesc().getFile().getId()).isIMG()) {
					asset.x			= -asset.width / 2;
					asset.y			= -asset.height / 2;
					asset.alpha		= 0;
					contentDelay	= 0;
				}
			}
		}
	}
	
	override function doLoadFinal() : Void {
		if ( asset != null) asset.alpha = 1;
		
		super.doLoadFinal();
	}
	
	override function setModeFadeOut() : Void {
		if ( doMode == doModeFadeFront || asset == null) super.setModeFadeOut();
		else setModeFadeFront();
	}
	
	override function doModeProgress( pTime : Float) : Void {
		if ( asset != null){
			contentDelay	+= Math.min( pTime, CONTENT_DELAY / 2);
			asset.alpha		= Math.max( Math.min( 1, contentDelay / CONTENT_DELAY), asset.alpha);
		}
		
		super.doModeProgress( pTime);
	}
}