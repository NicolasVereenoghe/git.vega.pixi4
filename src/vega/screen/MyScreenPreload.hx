package vega.screen;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class MyScreenPreload extends MyScreenLoad {
	var BAR_RECT						: Rectangle							= null;
	var BAR_RGB							: Int								= 0x000000;
	
	var bar								: Graphics;
	
	public function new() {
		super();
		
		bgColor			= 0xFFFFFF;
	}
	
	override public function destroy() : Void {
		content.removeChild( bar);
		bar.destroy();
		bar = null;
		
		super.destroy();
	}
	
	override public function start() : Void { setModeProgress(); }
	
	override public function onLoadProgress( pLoadRate : Float) : Void { toRate = .5 + .5 * pLoadRate; }
	
	override function doLoadFinal() : Void {
		super.doLoadFinal();
		
		shell.onScreenClose( this);
		
		setModeFadeOut();
	}
	
	override function buildContent() : Void {
		super.buildContent();
		
		bar = cast content.addChild( new Graphics());
		
		bar.beginFill( BAR_RGB);
		
		if ( BAR_RECT != null){
			bar.drawRect( 0, 0, BAR_RECT.width, BAR_RECT.height);
			bar.x	= BAR_RECT.x;
			bar.y	= BAR_RECT.y;
		}else{
			bar.drawRect( 0, 0, ApplicationMatchSize.instance.getScreenRectExt().width, 30);
		}
		
		bar.endFill();
		
		onResize();
	}
	
	override function onResize() : Void {
		if( BAR_RECT == null){
			bar.x	= ApplicationMatchSize.instance.getScreenRect().x;
			bar.y	= ApplicationMatchSize.instance.getScreenRect().y;
		}
		
		refreshBar();
	}
	
	override function launchAfterInit() : Void { shell.onScreenReady( this); }
	
	override function doModeProgress( pTime : Float) : Void {
		super.doModeProgress( pTime);
		
		refreshBar();
	}
	
	function refreshBar() : Void {
		bar.scale.x = Math.max( .005, curRate) * ApplicationMatchSize.instance.getScreenRect().width / ApplicationMatchSize.instance.getScreenRectExt().width;
	}
}