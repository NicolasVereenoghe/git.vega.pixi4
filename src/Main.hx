package;

import labo.shell.MyShell;
import vega.loader.file.MyFile;
import vega.shell.ApplicationMatchSize;
import vega.shell.BaseShell;
import vega.shell.GlobalPointer;
import vega.shell.VegaDeactivator;
import vega.shell.VegaFramer;
import vega.shell.VegaOrient;
import vega.sound.SndMgr;

/**
 * ...
 * @author nico
 */
class Main extends ApplicationMatchSize {
	var shell		: BaseShell;
	
	static function main() { new Main(); }
	
	public function new() {
		super();
		
		//debugLvl = "INFO";
		debug = true;
		debugVisibleInit = true;
		//debugMotifs = [ "VegaOrient"];
		
		setFPS( 60);
		
		version = "32";
		
		traceDebug( version, true);
		
		SndMgr.getInstance( .5);
		
		new GlobalPointer();
		//GlobalPointer.instance.switchEnable( false);
		
		//VegaOrient.getInstance().init();
		
		VegaFramer.getInstance().addIterator( startShell);
		
		VegaDeactivator.getInstance();
	}
	
	function startShell( pDT : Float) : Void {
		VegaFramer.getInstance().remIterator( startShell);
		
		shell = new MyShell();
		shell.init(
			getContent(),
			new MyFile( "assets.json", null, MyFile.VERSION_NO_CACHE),
			new MyFile( "local.xml", null, MyFile.VERSION_NO_CACHE),
			{ "Comfortaa-Light": new MyFile( "comfortaa_light.css", null, MyFile.NO_VERSION)}
		);
		
		//new Perf();
	}
}