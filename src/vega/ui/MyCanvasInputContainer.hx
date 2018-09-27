package vega.ui;

import js.Browser;
import js.html.Event;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject.DestroyOptions;
import pixi.core.graphics.Graphics;
import pixi.core.math.shapes.Rectangle;
import pixi.core.textures.Texture;
import pixi.interaction.InteractionEvent;
import vega.shell.ApplicationMatchSize;
import vega.shell.GlobalPointer;
import vega.utils.PointXY;

import haxe.extern.EitherType;
import pixi.core.sprites.Sprite;

/**
 * champ texte de saisie ; wrapping de CanvasInput dans un Sprite ; ne fonctionne qu'en mode de rendu "canvas"
 * @author nico
 */
class MyCanvasInputContainer extends Container {
	var spInput									: Sprite											= null;
	
	var input									: CanvasInput										= null;
	
	var isFocus									: Bool												= false;
	
	var wasDown									: Bool												= false;
	
	var tmpAllowScale							: Bool												= false;
	
	/**
	 * contruction la texture de sprite qui recopie une instance de CanvasInput wrappée
	 * @param	pCanvasInputOptions		paramètres de construction de l'instance de CanvasInput
	 * 									ne pas préciser de propriété "canvas" où l'afficher, car le rendu se fait par recopie dans une texture
	 * 									les champs "onblur" et "onsubmit" sont réservés
	 */
	public function new( pCanvasInputOptions : Dynamic) {
		var lInput	: CanvasInput;
		
		pCanvasInputOptions.onblur = onBlur;
		pCanvasInputOptions.onsubmit = onSubmit;
		
		lInput = new CanvasInput( pCanvasInputOptions);
		
		super();
		
		tmpAllowScale = ApplicationMatchSize.instance.allowScale;
		
		spInput = cast addChild( new Sprite( Texture.fromCanvas( lInput.renderCanvas())));
		
		input = lInput;
		
		interactive = true;
		buttonMode = true;
		
		addListener( "touchstart", onContainerFocus);
		addListener( "mousedown", onContainerFocus);
	}
	
	public function getValue() : String { return input.value(); }
	
	override public function destroy( ?options : EitherType<Bool,DestroyOptions>) : Void {
		removeAllListeners();
		
		input.destroy();
		input = null;
		
		removeChild( spInput);
		spInput.destroy( true);
		spInput = null;
		
		super.destroy( options);
	}
	
	function onBlur( pTarget : CanvasInput) : Void {
		isFocus = false;
		
		input._mouseDown = false;
		
		ApplicationMatchSize.instance.allowScale = tmpAllowScale;
		
		ApplicationMatchSize.instance.refreshRender();
		
		ApplicationMatchSize.instance.traceDebug( "INFO : MyCanvasInputContainer::onBlur : " + input.value(), true);
	}
	
	function onSubmit( pE : Event, pTarget : CanvasInput) : Void { input.blur(); }
	
	function onContainerFocus( pE : InteractionEvent) : Void {
		ApplicationMatchSize.instance.allowScale = false;
		
		isFocus = true;
		
		input.focus();
		
		input._mouseDown = true;
		
		wasDown = true;
	}
	
	override public function updateTransform() : Void {
		super.updateTransform();
		
		if ( isFocus && input != null){
			if ( wasDown){
				if ( ! GlobalPointer.instance.isDown){
					wasDown = false;
				}
			}else if ( GlobalPointer.instance.isDown){
				onSubmit( null, input);
				
				return;
			}
			
			input._hiddenInput.focus();
		}
	}
}