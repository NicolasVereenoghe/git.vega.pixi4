package vega.loader.file;

import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.core.textures.VideoBaseTexture;
import vega.shell.ApplicationMatchSize;
import haxe.Timer;

/**
 * ...
 * @author nico
 */
class LoadingFileVideo extends LoadingFile {
	var vdoTexture										: Texture												= null;
	
	public function new( pFile : MyFile) { super( pFile); }
	
	override public function getLoadedContent( pId : String = null) : Dynamic { return vdoTexture; }
	
	override function buildLoader() : Void { }
	
	override function freeLoader() : Void {
		if ( vdoTexture != null){
			cast( vdoTexture.baseTexture, VideoBaseTexture).dispose();
			
			vdoTexture.destroy( true);
			
			vdoTexture = null;
		}
	}
	
	override function doLoad() : Void {
		vdoTexture	= Texture.fromVideoUrl( getUrlRequest());
		
		cast( vdoTexture.baseTexture, VideoBaseTexture).autoPlay = false;
		//cast( vdoTexture.baseTexture, VideoBaseTexture).autoUpdate = false;
		
		vdoTexture.baseTexture.addListener( "loaded", onLoadComplete);
		vdoTexture.baseTexture.addListener( "error", onError);
	}
	
	override function removeLoaderListener() : Void {
		vdoTexture.baseTexture.removeListener( "loaded", onLoadComplete);
		vdoTexture.baseTexture.removeListener( "error", onError);
	}
	
	override function onLoadComplete() : Void {
		removeLoaderListener();
		
		vegaLoader.onCurFileLoaded();
		
		vegaLoader = null;
	}
	
	override function onError() : Void {
		ApplicationMatchSize.instance.traceDebug( "ERROR : LoadingFileVideo::onError : " + _file.getId() + " ( " + ctrReload + ")"/*") : " + Reflect.getProperty( loader.resources, _file.getId()).error*/);
		
		if ( ctrReload++ < RELOAD_MAX){
			freeLoader();
			
			Timer.delay( doLoad, RELOAD_DELAY_MAX * Math.round( Math.pow( ctrReload / RELOAD_MAX, 2)));
		}else ApplicationMatchSize.instance.reload();
	}
	
	override function getUrlRequest( pForceNoCache : Bool = false, pFile : MyFile = null) : String {
		var lFile		: MyFile	= pFile == null ? _file : pFile;
		var lName		: String	= lFile.getName();
		var lPath		: String	= lFile.getPath() != null ? lFile.getPath() : "";
		
		if( lName.indexOf( "://") != -1) return lName;
		else return lPath + lName;
	}
}