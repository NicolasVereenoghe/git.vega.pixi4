package vega.assets;
import vega.loader.file.MyFile;

/**
 * ...
 * @author nico
 */
class AssetRender {
	public static inline var RENDER_FLUMP		: String				= "flump";
	public static inline var RENDER_DEFAULT		: String				= "default";
	public static inline var RENDER_VIDEO		: String				= "video";
	
	public static inline var TYPE_FLUMP_MC		: String				= "mc";
	public static inline var TYPE_FLUMP_SP		: String				= "sp";
	
	public var render							: String;
	public var type								: String;
	
	/** map de fichiers .vtt ; indexé par code langue (choix libre) ; null si aucun sous-titre */
	public var srts								: Map<String,MyFile>	= null;
	
	public function new( pNode : Dynamic) {
		var lSrt	: Dynamic;
		
		if ( pNode != null){
			render = pNode.name;
			
			if ( pNode.type != null) type = pNode.type;
			
			if ( render == RENDER_VIDEO && pNode.srts != null){
				for ( iLang in Reflect.fields( pNode.srts)){
					if ( srts == null) srts = new Map<String,MyFile>();
					
					lSrt = Reflect.field( pNode.srts, iLang);
					
					srts.set(
						iLang,
						new MyFile(
							lSrt.name,
							lSrt.path,
							lSrt.version
						)
					);
				}
			}
		}else render = RENDER_DEFAULT;
	}
}