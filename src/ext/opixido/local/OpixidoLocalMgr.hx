package ext.opixido.local;

import js.Browser;
import vega.local.LocalMgr;
import vega.shell.ApplicationMatchSize;

/**
 * spécialisation opixido de gestion de fichier de localisation ; xml structuré / arborescent :
 *	<data>
 * 		<language id="fr>
 * 			<items>
 * 				<item><![CDATA[texte0]]></item>
 * 				<item><![CDATA[texte1]]></item>
 * 				<item><![CDATA[texte2]]></item>
 * 			</items>
 * 			[...]
 * 		</language>
 * 		[...]
 * 	</data>
 * 
 * le xml peut être partagé par plusieurs appli
 * on peut préciser une balise racine qui marque le point de départ de l'accès aux données de notre appli dans chaque langue
 * on peut aussi spécifier une liste ordonnée de langues utilisées par notre appli pour garantir des index de langue indépendant des autres éventuelles applis
 * 
 * pour l'accès aux feuilles d'arbre de données, on utilise un identifiant composite décrivant le "path" d'accès, ie accéder à "texte1" : "items.item[1]"
 */
class OpixidoLocalMgr extends LocalMgr {
	var MOTIF_LANGUAGE										: String											= "language";
	var MOTIF_LANGUAGE_ATTRIBUTE							: String											= "id";
	
	var radixMotif											: String											= "";
	
	var langIndexes											: Array<String>										= null;
	
	public function new( pConf : Dynamic, pLang : String = null, pStyles : Dynamic = null, pRadixMotif : String = "", pLangIndexes : Array<String> = null) {
		super( pConf, pLang, pStyles);
		
		langIndexes	= pLangIndexes;
		radixMotif	= pRadixMotif;
		
		doInitOpixido( pConf, pLang);
	}
	
	function doInitOpixido( pConf : Dynamic, pLang : String = null) : Void {
		var lLangs	: Array<String>;
		
		conf		= pConf;
		listeners	= new Array<Void->Void>();
		
		if ( pLang == null && Browser.supported) pLang = Browser.navigator.language;
		
		lLangs = getAvailableLangs();
		for ( iLang in lLangs){
			if ( iLang == pLang){
				defaultLang = iLang;
				break;
			}
		}
		
		if ( defaultLang == null) defaultLang = lLangs[ 0];
		
		ApplicationMatchSize.instance.traceDebug( "INFO : OpixidoLocalMgr::doInitOpixido : defaultLang = " + defaultLang, true);
	}
	
	function getAvailableLangs() : Array<String> {
		var lRes	: Array<String>;
		var lI		: Int;
		var lNodes	: Dynamic;
		
		if ( langIndexes != null) return langIndexes;
		else{
			lRes	= new Array<String>();
			lNodes	= conf.documentElement.childNodes;
			lI		= 0;
			
			while ( lI < lNodes.length){
				if ( lNodes[ lI].nodeType == 1 && lNodes[ lI].nodeName == MOTIF_LANGUAGE){
					if ( radixMotif == "" || lNodes[ lI].getElementsByTagName( radixMotif).length > 0){
						lRes.push( lNodes[ lI].getAttribute( MOTIF_LANGUAGE_ATTRIBUTE));
					}
				}
				
				lI++;
			}
			
			return lRes;
		}
	}
	
	override public function getCurLangInd() : Int {
		var lLangs	: Array<String>	= getAvailableLangs();
		var lI		: Int			= 0;
		
		while ( lI < lLangs.length){
			if ( lLangs[ lI] == defaultLang) return lI;
			
			lI++;
		}
		
		ApplicationMatchSize.instance.traceDebug( "ERROR : OpixidoLocalMgr::getCurLangInd : " + defaultLang + " not found !");
		
		return -1;
	}
	
	override public function fromIndToId( pInd : Int) : String {
		var lLangs	: Array<String>	= getAvailableLangs();
		
		if ( pInd >= 0 && pInd < lLangs.length) return lLangs[ pInd];
		
		ApplicationMatchSize.instance.traceDebug( "INFO : OpixidoLocalMgr::fromIndToId : " + pInd + " out of bounds");
		
		return null;
	}
	
	override public function getNbLangs() : Int { return getAvailableLangs().length; }
	
	override public function getLocalTxt( pId : String, pForceLang : String = null) : String {
		var lIds	: Array<String>;
		var lParams	: Array<String>;
		var lI		: Int;
		var lXml	: Dynamic;
		
		if ( pId == null || pId == "") return "";
		
		if ( pForceLang == null) pForceLang = defaultLang;
		
		lIds	= pId.split( ".");
		lI		= 0;
		lXml	= getRootLang( pForceLang);
		while ( lI < lIds.length){
			lParams = lIds[ lI].split( "[");
			
			if ( lParams.length > 1) lXml = lXml.getElementsByTagName( lIds[ lI])[ Std.parseInt( lParams[ 1].split( "]")[ 0])];
			else lXml = lXml.getElementsByTagName( lIds[ lI])[ 0];
			
			lI++;
		}
		
		return lXml.firstChild.data;
	}
	
	function getRootLang( pId : String) : Dynamic {
		var lI		: Int		= 0;
		var lNodes	: Dynamic	= conf.documentElement.childNodes;
		
		while ( lI < lNodes.length){
			if ( lNodes[ lI].nodeType == 1 && lNodes[ lI].nodeName == MOTIF_LANGUAGE && lNodes[ lI].getAttribute( MOTIF_LANGUAGE_ATTRIBUTE) == pId){
				if ( radixMotif == "") return lNodes[ lI];
				else return lNodes[ lI].getElementsByTagName( radixMotif)[ 0];
			}
			
			lI++;
		}
		
		trace( "ERROR : OpixidoLocalMgr::getRootLang : no data for lang " + pId);
		
		return null;
	}
}