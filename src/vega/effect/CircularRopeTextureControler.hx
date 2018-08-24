package vega.effect;
import pixi.core.Pixi.ScaleModes;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.flump.Movie;
import pixi.flump.Sprite;
import pixi.mesh.Rope;
import vega.shell.ApplicationMatchSize;
import vega.utils.PointXY;

class CircularRopeTextureControler {
	var DEFAULT_NB_PTS									: Int												= 50;
	
	var container										: Movie												= null;
	
	var rope											: Rope												= null;
	
	public function new() { }
	
	public function init( pContainer : Movie, pNbPt : Int = 0) : Void {
		var lPts		: Array<PointXY>	= new Array<PointXY>();
		var lNb			: Int				= ( pNbPt > 0 ? pNbPt : DEFAULT_NB_PTS);
		var lBounds		: Rectangle;
		var lTexture	: Texture;
		var lCont		: Movie;
		var lRadius		: Float;
		var lA			: Float;
		var lI			: Int;
		var lW			: Float;
		var lP			: Float;
		var lDA			: Float;
		var lTmpA		: Float;
		
		container	= pContainer;
		
		lRadius 	= getMcRadius().width;
		lA			= getMcRadius().parent.skew.y;
		lP			= 2 * Math.PI * lRadius;
		
		lCont		= getMcTexture( container);
		
		lCont.parent.visible = true;
		
		lBounds		= lCont.getLocalBounds();
		lCont.x		= -lBounds.x;
		lCont.y		= -lBounds.y;
		
		lTexture	= ApplicationMatchSize.instance.renderer.generateTexture( lCont.parent, ScaleModes.DEFAULT, 1);
		lW			= lTexture.width;
		lDA			= 2 * Math.PI * lW / lP;
		
		lCont.parent.visible = false;
		
		lI = 0;
		while ( lI < lNb){
			lTmpA = lI * ( lDA / ( lNb - 1)) + lA - lDA / 2;
			
			lPts.push( new PointXY( Math.cos( lTmpA) * lRadius, Math.sin( lTmpA) * lRadius));
			
			lI++;
		}
		
		rope		= cast container.addChild( new Rope( lTexture, cast lPts));
	}
	
	public function destroy() : Void {
		container.removeChild( rope);
		rope.destroy( true);
		rope = null;
		
		container = null;
	}
	
	public static function getMcTexture( pContainer : Movie) : Movie { return cast pContainer.getLayer( "mcTexture").getChildAt( 0); }
	
	function getMcRadius() : Sprite { return cast container.getLayer( "mcRadius").getChildAt( 0); }
}