package vega.local;

import flump.library.Layer;
import haxe.xml.Fast;
import js.Browser;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.flump.Movie;
import vega.shell.ApplicationMatchSize;
import vega.utils.UtilsFlump;

/**
 * ...
 * @author nico
 */
class LocalMgr {
	public static var instance					: LocalMgr;
	
	public var TXT_SEP							: String				= "_";
	
	public var GLOBAL_TAG						: String				= "global";
	
	var TXT_PREFIX								: String				= "txt";
	
	var STYLES									: Dynamic				= null;
	
	var defaultLang								: String;
	var conf									: Dynamic				= null;
	
	/** collection de listener de mise à jour de localisation */
	var listeners								: Array<Void->Void>		= null;
	
	/**
	 * création du singleton de gestionnaire de localisation
	 * @param	pConf	données de loader du fichier de localisation ; supporte le json et le xml (reconverti en json)
	 * @param	pLang	id de langue par défaut, ou laisser null pour que ce soit déterminé par le navigateur
	 * @param	pStyles	map d'instance TextStyle, indexée par noms de styles ; "default" est un nom réservé ; null : ne pas utiliser de styles
	 */
	public function new( pConf : Dynamic, pLang : String = null, pStyles : Dynamic = null) {
		instance	= this;
		
		STYLES		= pStyles;
		
		doInit( pConf, pLang);
	}
	
	function doInit( pConf : Dynamic, pLang : String = null) : Void {
		if ( pConf.documentElement != null) conf = xml2Json( pConf);
		else conf = pConf.local;
		
		trace( conf);
		
		listeners	= new Array<Void->Void>();
		
		if ( pLang == null && Browser.supported) pLang = Browser.navigator.language;
		
		for ( iLocal in Reflect.fields( conf)){
			if ( iLocal == pLang){
				defaultLang = iLocal;
				break;
			}
		}
		
		if ( defaultLang == null){
			if ( Reflect.fields( conf).length > 1){
				if ( Reflect.fields( conf)[ 0] != GLOBAL_TAG) defaultLang = Reflect.fields( conf)[ 0];
				else defaultLang = Reflect.fields( conf)[ 1];
			} else defaultLang = Reflect.fields( conf)[ 0];
		}
		
		//defaultLang = "en";
		
		ApplicationMatchSize.instance.traceDebug( "INFO : LocalMgr::doInit : defaultLang = " + defaultLang, true);
	}
	
	/**
	 * on converti des données xml de fichier de localisation en json
	 * @param	pXmlData	données de document xml de fichier de localisation
	 * @return	structure json correspondante
	 */
	function xml2Json( pXmlData : Dynamic) : Dynamic {
		var lRes	: Dynamic	= { };
		var lInd1	: Int	= 0;
		var lInd2	: Int;
		
		while ( lInd1 < pXmlData.documentElement.childNodes.length){
			if ( pXmlData.documentElement.childNodes[ lInd1].nodeType == 1){
				Reflect.setField( lRes, pXmlData.documentElement.childNodes[ lInd1].nodeName, {});
				
				lInd2 = 0;
				while ( lInd2 < pXmlData.documentElement.childNodes[ lInd1].childNodes.length){
					if ( pXmlData.documentElement.childNodes[ lInd1].childNodes[ lInd2].nodeType == 1){
						Reflect.setField( lRes[ pXmlData.documentElement.childNodes[ lInd1].nodeName], pXmlData.documentElement.childNodes[ lInd1].childNodes[ lInd2].getAttribute( "id"), pXmlData.documentElement.childNodes[ lInd1].childNodes[ lInd2].firstChild.data);
					}
					
					lInd2++;
				}
				
			}
			
			lInd1++;
		}
		
		/*
		var lRes	: Dynamic	= { };
		var lI		: Int		= 0;
		var lJ		: Int;
		
		pXmlData = pXmlData.documentElement;
		
		while ( lI < pXmlData.children.length) {
			Reflect.setField( lRes, pXmlData.children[ lI].nodeName, {});
			
			lJ = 0;
			while ( lJ < pXmlData.children[ lI].children.length) {
				Reflect.setField( lRes[ pXmlData.children[ lI].nodeName], pXmlData.children[ lI].children[ lJ].id, pXmlData.children[ lI].children[ lJ].firstChild.data);
				
				lJ++;
			}
			
			lI++;
		}
		*/
		
		return lRes;
	}
	
	/**
	 * on récupère l'id de langue par défaut en cours
	 * @return	id delangue par défaut en cours
	 */
	public function getCurLangId() : String { return defaultLang; }
	
	/**
	 * on récupère l'indice de langue par défaut en cours
	 * @return	indice de la langue par défaut dans la collection (::conf) ; [ 0 .. n-1] ; -1 si non trouvé (erreur)
	 */
	public function getCurLangInd() : Int {
		var lCtr	: Int		= 0;
		
		for ( iLocal in Reflect.fields( conf)) {
			if( iLocal != GLOBAL_TAG){
				if ( iLocal == defaultLang) return lCtr;
				else lCtr++;
			}
		}
		
		ApplicationMatchSize.instance.traceDebug( "ERROR : LocalMgr::getCurLangInd : " + defaultLang + " not found !");
		
		return -1;
	}
	
	/**
	 * on récupère l'id de langue à partir d'un indice de langue
	 * @param	pInd	indice de langue dans la collection (::conf) ; [ 0 .. n-1]
	 * @return	id de langue correspondant, ou null si pas trouvé
	 */
	public function fromIndToId( pInd : Int) : String {
		var lCtr	: Int		= 0;
		
		for ( iLocal in Reflect.fields( conf)) {
			if( iLocal != GLOBAL_TAG){
				if ( lCtr == pInd) return iLocal;
				else lCtr++;
			}
		}
		
		ApplicationMatchSize.instance.traceDebug( "INFO : LocalMgr::fromIndToId : " + pInd + " out of bounds");
		
		return null;
	}
	
	/**
	 * on récupère le nombre de langues localisées
	 * @return	nombre de langues localisées dans la collection (::conf)
	 */
	public function getNbLangs() : Int {
		var lCtr	: Int		= 0;
		
		for ( iLocal in Reflect.fields( conf)) if( iLocal != GLOBAL_TAG) lCtr++;
		
		return lCtr;
	}
	
	/**
	 * on bascule la langue en cours vers une autre ; on dispatch l'event de changement à tous les listener ; rien ne se passe si l'id de langue correspond à celui en cours
	 * @param	pLangId		id de langue qui devient celle en cours ; doit correspondre à un id valide dans la collection du gestionnaire (::conf)
	 * @param	pNoDispatch	mettre true pour empêcher la propagation de l'info de mise à jour de langue ; laisser false par défaut pour dispatcher
	 */
	public function swapLang( pLangId : String, pNoDispatch : Bool = false) : Void {
		if ( pLangId != defaultLang) {
			defaultLang = pLangId;
			
			if ( ! pNoDispatch) {
				for ( iListener in listeners) iListener();
			}
		}
	}
	
	/**
	 * on ajoute un listener de mise à jour de localisation
	 * @param	pListener	écouteur de mise à jour
	 */
	public function addListener( pListener : Void -> Void) : Void { listeners.push( pListener); }
	
	/**
	 * on retire un listener de mise à jour de localisation
	 * @param	pListener	écouteur de mise à jour
	 */
	public function remListener( pListener : Void -> Void) : Void { listeners.remove( pListener); }
	
	public function getLocalTxt( pId : String, pForceLang : String = null) : String {
		var lLocals	: Dynamic;
		
		if ( pId == null || pId == "") return "";
		
		if ( pForceLang == null) pForceLang = defaultLang;
		
		lLocals = Reflect.getProperty( conf, pForceLang);
		
		if( ! Reflect.hasField( lLocals, pId)) return Reflect.getProperty( Reflect.getProperty( conf, GLOBAL_TAG), pId);
		
		return Reflect.getProperty( lLocals, pId);
	}
	
	public function instanciateTxtFromFlumpModel( pTxtId : String, pModelInstance : Movie, pVal : String = null) : Text {
		var lLayer		: Layer			= UtilsFlump.getLayerWithPrefixInMovie( pTxtId, pModelInstance);
		var lLayerCont	: Container		= cast pModelInstance.getLayer( lLayer.name).getChildAt( 0);
		var lDesc		: TxtDescFlump	= new TxtDescFlump( lLayer.name);
		var lParams		: TextStyle		= new TextStyle();
		var lStyles		: Dynamic;
		var lTxt		: Text;
		
		lParams.fontFamily	= lDesc.fontId;
		lParams.fontSize	= lDesc.size;
		lParams.fill		= lDesc.color;
		lParams.align		= lDesc.align;
		//lParams.padding		= lDesc.size; // ça fait rater le multi style
		lParams.lineHeight	= lDesc.lineHeight;
		
		addWordWrapParams( lDesc, lParams);
		
		if ( pVal == null){
			if( lDesc.forcedLangI >= 0) pVal = getLocalTxt( lDesc.localId, fromIndToId( lDesc.forcedLangI));
			else pVal = getLocalTxt( lDesc.localId);
		}
		
		lStyles = checkStyles( pVal, lParams);
		
		if( lStyles == null){
			lTxt = new Text(
				pVal,
				lParams
			);
		}else{
			lTxt = new MultiStyleText(
				pVal,
				lStyles
			);
		}
		
		ApplicationMatchSize.instance.traceDebug( "INFO : LocalMgr::instanciateTxtFromFlumpModel : " + lDesc.localId + " : " + lTxt.text);
		
		lLayerCont.addChild( lTxt);
		
		lLayerCont.interactiveChildren = false;
		
		alignTxt( lTxt, lDesc);
		
		return lTxt;
	}
	
	public function parseAndSetLocalTxtInMovie( pCont : Movie) : Void {
		var lLayers	: Array<Layer>	= UtilsFlump.getLayersWithPrefixInMovie( TXT_PREFIX, pCont);
		
		for ( iLayer in lLayers){
			try{ instanciateTxtFromFlumpModel( iLayer.name, pCont); } catch ( pE : Dynamic) { trace( pE); continue; }
		}
	}
	
	public function recursiveSetLocalTxt( pCont : Container) : Void { recursiveApply( pCont, parseAndSetLocalTxtInMovie); }
	
	public function updateTxtFromFlumpModel( pTxtId : String, pModelInstance : Movie, pVal : String = null) : Text {
		var lLayer		: Layer			= UtilsFlump.getLayerWithPrefixInMovie( pTxtId, pModelInstance);
		var lLayerCont	: Container		= cast pModelInstance.getLayer( lLayer.name).getChildAt( 0);
		var lDesc		: TxtDescFlump	= new TxtDescFlump( lLayer.name);
		var lTxt		: Text			= cast lLayerCont.getChildAt( lLayerCont.children.length - 1);
		
		lTxt.text = ( pVal == null ? getLocalTxt( lDesc.localId) : pVal);
		
		alignTxt( lTxt, lDesc);
		
		return lTxt;
	}
	
	/**
	 * on met à jour les champs texte précédemment créés par ::parseAndSetLocalTxtInMovie
	 * @param	pCont	movie modèle conteneur de champs textes localisable
	 */
	public function updateLocalTxtInMovie( pCont : Movie) : Void {
		var lLayers	: Array<Layer>	= UtilsFlump.getLayersWithPrefixInMovie( TXT_PREFIX, pCont);
		
		for ( iLayer in lLayers) {
			try { updateTxtFromFlumpModel( iLayer.name, pCont); } catch ( pE : Dynamic) { trace( pE); continue; }
		}
	}
	
	public function recursiveUpdateLocalTxt( pCont : Container) : Void { recursiveApply( pCont, updateLocalTxtInMovie); }
	
	public function freeLocalTxtInMovie( pCont : Movie) : Void {
		var lLayers	: Array<Layer>	= UtilsFlump.getLayersWithPrefixInMovie( TXT_PREFIX, pCont);
		var lDesc	: TxtDescFlump;
		var lTxt	: DisplayObject;
		var lCont	: Container;
		
		for ( iLayer in lLayers){
			try { lDesc = new TxtDescFlump( iLayer.name); } catch ( pE : Dynamic) { trace( pE); continue; }
			lCont	= cast pCont.getLayer( iLayer.name).getChildAt( 0);
			
			if( lCont.children.length > 0){
				lTxt = lCont.getChildAt( lCont.children.length - 1);
				
				if ( Std.is( lTxt, Text)){
					pCont.removeChild( lTxt);
					lTxt.destroy();
				}
			}
		}
	}
	
	public function recursiveFreeLocalTxt( pCont : Container) : Void { recursiveApply( pCont, freeLocalTxtInMovie); }
	
	function checkStyles( pTxt : String, pDefault : TextStyle) : Dynamic {
		var lRes	: Dynamic;
		
		if ( STYLES == null) return null;
		else{
			for ( iStyle in Reflect.fields( STYLES)){
				if ( pTxt.indexOf( "<" + iStyle + ">") != -1){
					lRes = Reflect.copy( STYLES);
					
					Reflect.setField(
						lRes,
						"default",
						{
							"fontFamily": pDefault.fontFamily,
							"fontSize": pDefault.fontSize,
							"fill": pDefault.fill,
							"align": pDefault.align,
							//"padding": pDefault.padding, // ça fait rater le multi style
							"wordWrap": pDefault.wordWrap,
							"wordWrapWidth": pDefault.wordWrapWidth,
							"lineHeight": pDefault.lineHeight
						}
					);
					
					return lRes;
				}
			}
			
			return null;
		}
	}
	
	function alignTxt( pTxt : Text, pDesc : TxtDescFlump) : Void {
		if ( pDesc.align == TxtDescFlump.ALIGN_CENTER) pTxt.x = -pTxt.width / 2;
		else if ( pDesc.align == TxtDescFlump.ALIGN_RIGHT) pTxt.x = -pTxt.width;
		
		if ( pDesc.vAlign == TxtDescFlump.V_ALIGN_CENTER) pTxt.y = ( Reflect.field( pTxt.style, "fontSize") - pTxt.height) / 2;
		else if ( pDesc.vAlign == TxtDescFlump.V_ALIGN_BOT) pTxt.y = Reflect.field( pTxt.style, "fontSize") - pTxt.height;
	}
	
	function recursiveApply( pCont : Container, pFunc : Movie -> Void) : Void {
		for ( iChild in pCont.children){
			if ( Std.is( iChild, Container)) recursiveApply( cast iChild, pFunc);
		}
		
		if ( Std.is( pCont, Movie)) pFunc( cast pCont);
	}
	
	function addWordWrapParams( pDesc : TxtDescFlump, pParams : TextStyle) : TextStyle {
		if ( pDesc.wordWrap > 0) {
			pParams.wordWrap = true;
			pParams.wordWrapWidth = pDesc.wordWrap;
		}
		
		return pParams;
	}
}