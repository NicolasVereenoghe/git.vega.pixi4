package vega.loader.file;
import vega.shell.ApplicationMatchSize;

/**
 * ...
 * @author nico
 */
class MyFile {
	public static inline var NO_VERSION			: String			= "NO-VERSION";
	public static inline var VERSION_NO_CACHE	: String			= "NO-CACHE";
	
	public static var EXT_PATH					: String			= null;
	
	var _name									: String;
	var _path									: String;
	var _version								: String;
	
	public function new( pName : String, pPath : String = null, pVersion : String = null) {
		_name		= pName;
		_version	= pVersion != null ? pVersion : ApplicationMatchSize.instance.version;
		
		if ( EXT_PATH != null &&  EXT_PATH != "") _path = ( pPath != null ? EXT_PATH + pPath : EXT_PATH);
		else _path = pPath;
	}
	
	public function getId() : String { return ( _path != null ? _path + ":" : "") + _name; }
	
	public function getName() : String { return _name; }
	
	public function getPath() : String { return _path; }
	
	public function getVersion() : String { return _version; }
}