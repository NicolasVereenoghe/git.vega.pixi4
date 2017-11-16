package vega.sprites;

import pixi.core.display.Container;
import pixi.core.math.Point;
import vega.sprites.MySprite;
import vega.utils.PointIJ;
import vega.utils.RectangleIJ;
import vega.utils.Utils;

/**
 * abstract : gestionnaire d'affichage d'un ground composé de plusieurs sections de level ; reste à coder le choix d'enchainement des sections
 * @author 
 */
class GroundMgrSections extends GroundMgr {
	/** @inheritDoc */
	public function new( pContainer : Container, pLvlGround : LvlGroundMgr, pSpMgr : MySpriteMgr) {
		super( pContainer, pLvlGround, pSpMgr);
		
		clipRectIn = clipRectInSection;
		clipRectOut = clipRectOutSection;
		
		getSpriteCell = getSpriteCellSection;
		
		addSpriteCell = addSpriteCellRegular;
		remSpriteCell = remSpriteCellRegular;
	}
	
	/** @inheritDoc */
	override public function getCellsAt( pModI : Int, pModJ : Int, pType : Class<MySprite> = null) : Array<Map<String,MyCell>> {
		var lRes 		: Array<Map<String,MyCell>>	= super.getCellsAt( pModI, pModJ, pType);
		var lSection	: SectionDesc				= getLvlGroundSectionAt( pModI, pModJ);
		var lRes2		: Map<String,MyCell>;
		
		if ( lSection != null){
			lRes2 = lSection.lvlGround.getCellsAt( pModI - lSection.offset.i, pModJ - lSection.offset.j);
			
			if ( ! Utils.isMapEmpty( lRes2)) lRes.push( lRes2);
		}
		
		return lRes;
	}
	
	/**
	 * abstract : on signale au gestionnaire qu'une section de level peut faire partie du pool de sections affichables ; à redéfinir pour coder une logique de pool
	 * @param	pLvlGround	instance de section de level qui peut faire partie des sections affichables
	 */
	public function addSection( pLvlGround : LvlGroundMgr) : Void { }
	
	/**
	 * abstract : on réupère un descripteur de section à une certaine case de level
	 * @param	pI		indice i de case de level
	 * @param	pJ		indice j de case de level
	 * @return	instance de descripteur de section à utiliser à cette case ; null si aucun (vide)
	 */
	function getLvlGroundSectionAt( pI : Int, pJ : Int) : SectionDesc { return null; }
	
	function clipRectInSection( pI : Int, pJ : Int, pW : Int, pH : Int) : Void {
		var lIMax			: Int					= pI + pW;
		var lJMax			: Int					= pJ + pH;
		var lI				: Int					= pI;
		var lJ				: Int;
		var lSection		: SectionDesc;
		var lDescs			: Map<String,MyCell>;
		var lName			: String;
		
		while ( lI < lIMax) {
			lJ = pJ;
			while ( lJ < lJMax) {
				lSection = getLvlGroundSectionAt( lI, lJ);
				if ( lSection != null){
					lDescs = lSection.lvlGround.getCellsAt( lI - lSection.offset.i, lJ - lSection.offset.j);
					
					if ( lDescs != null){
						for ( iDesc in lDescs){
							lName = getInstanceQualifiedSectionName( iDesc, lSection);
							
							if ( ! sprites.exists( lName)) {
								spMgr.addSpriteDisplay(
									iDesc.instanciate(),
									( iDesc.getI() + lSection.offset.i) * _lvlGround.getCELL_W() + iDesc.getDx(),
									( iDesc.getJ() + lSection.offset.j) * _lvlGround.getCELL_H() + iDesc.getDy(),
									lName,
									iDesc
								);
							}
						}
					}
				}
				
				lDescs = _lvlGround.getCellsAt( lI, lJ);
				if ( lDescs != null){
					for ( iDesc in lDescs){
						if ( ! sprites.exists( iDesc.getInstanceId())) {
							spMgr.addSpriteDisplay(
								iDesc.instanciate(),
								iDesc.getI() * _lvlGround.getCELL_W() + iDesc.getDx(),
								iDesc.getJ() * _lvlGround.getCELL_H() + iDesc.getDy(),
								iDesc.getInstanceId(),
								iDesc
							);
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function clipRectOutSection( pI : Int, pJ : Int, pW : Int, pH : Int, pClipRIJ : RectangleIJ) : Void {
		var lDone			: Map<String,Bool>		= new Map<String,Bool>();
		var lIMax			: Int					= pI + pW;
		var lJMax			: Int					= pJ + pH;
		var lI				: Int					= pI;
		var lJ				: Int;
		var lDescs			: Map<String,MyCell>;
		var lSection		: SectionDesc;
		var lName			: String;
		var lSp				: MySprite;
		var lCellClipRIJ	: RectangleIJ;
		
		while ( lI < lIMax) {
			lJ = pJ;
			while ( lJ < lJMax) {
				lSection = getLvlGroundSectionAt( lI, lJ);
				if ( lSection != null){
					lDescs = lSection.lvlGround.getCellsAt( lI - lSection.offset.i, lJ - lSection.offset.j);
					if ( lDescs != null){
						for ( iDesc in lDescs){
							lName = getInstanceQualifiedSectionName( iDesc, lSection);
							
							if ( ! lDone.exists( lName)) {
								lDone[ lName] = true;
								lSp = sprites[ lName];
								
								if ( lSp != null && lSp.isClipable()) {
									lCellClipRIJ	= iDesc.getCellOffset().clone();
									lCellClipRIJ.offset( iDesc.getI() + lSection.offset.i, iDesc.getJ() + lSection.offset.j);
									
									if ( pClipRIJ.getLeft() > lCellClipRIJ.getRight() || pClipRIJ.getRight() < lCellClipRIJ.getLeft() || pClipRIJ.getTop() > lCellClipRIJ.getBottom() || pClipRIJ.getBottom() < lCellClipRIJ.getTop()) {
										spMgr.remSpriteDisplay( lSp);
									}
								}
							}
						}
					}
				}
				
				lDescs = _lvlGround.getCellsAt( lI, lJ);
				if ( lDescs != null){
					for ( iDesc in lDescs){
						if ( ! lDone.exists( iDesc.getInstanceId())) {
							lDone[ iDesc.getInstanceId()] = true;
							lSp = sprites[ iDesc.getInstanceId()];
							
							if ( lSp != null && lSp.isClipable()) {
								lCellClipRIJ	= iDesc.getCellOffset().clone();
								lCellClipRIJ.offset( iDesc.getI(), iDesc.getJ());
								
								if( pClipRIJ.getLeft() > lCellClipRIJ.getRight() || pClipRIJ.getRight() < lCellClipRIJ.getLeft() || pClipRIJ.getTop() > lCellClipRIJ.getBottom() || pClipRIJ.getBottom() < lCellClipRIJ.getTop()){
									spMgr.remSpriteDisplay( lSp);
								}
							}
						}
					}
				}
				
				lJ++;
			}
			
			lI++;
		}
	}
	
	function getSpriteCellSection( pDesc : MyCell, pIJ : PointIJ = null) : Array<MySprite> {
		var lSection	: SectionDesc;
		var lName		: String;
		
		if ( pDesc.getLvlGroundMgr() == _lvlGround) return getSpriteCellRegular( pDesc, pIJ);
		else {
			lName = getInstanceQualifiedSectionName( pDesc, getLvlGroundSectionAt( pIJ.i, pIJ.j));
			
			if ( sprites.exists( lName)) return [ sprites[ lName]];
			else return [];
		}
	}
	
	function getInstanceQualifiedSectionName( pDesc : MyCell, pSection : SectionDesc) : String { return pSection.id + "_" + pDesc.getInstanceId(); }
}

class SectionDesc {
	public var id			: Int;
	public var lvlGround	: LvlGroundMgr;
	public var offset		: RectangleIJ;
	
	public function new( pId : Int, pLvlGround : LvlGroundMgr, pOffset : RectangleIJ){
		id			= pId;
		lvlGround	= pLvlGround;
		offset		= pOffset;
	}
}