package vega.shell;
import js.Error;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import pixi.interaction.InteractionEvent;
import pixi.interaction.InteractionData;
import haxe.extern.EitherType;
import vega.utils.PointXY;

/**
 * tracking de coordonnées globales de pointeur
 * 
 * @author nico
 */
class GlobalPointer {
	public static var instance				: GlobalPointer;
	
	/** délai de timeout en ms d'une touche */
	var TIMEOUT								: Float						= 5000;
	/** délai de timeout en ms de souris */
	//var TIMEOUT_MOUSE						: Float						= 5000;
	/** id arbitraire de touche sans id ; semble correspondre à la souris */
	public static inline var DEFAULT_ID		: Int						= 421;
	
	/** disptance max de proximité pour détecter le bug doublon d'event d'interaction touch/mouse (mousemove déclenché par erreur par navigateur) */
	var MOUSE_DUP_PROXIMITY					: Float						= 10;
	
	/** flag indiquant que le pointeur actuel est de type "touchpad" (true) ou souris (false) */
	public var isTouchpad					: Bool						= false;
	/** flag indiquant si le pointeur actuel est en train de toucher l'appli (true) ou pas (false) */
	public var isDown						: Bool						= false;
	
	/** pile des points de touches actifs, indexés par ordre d'arrivé (0 : le + vieux, n-1 le + récent) */
	var datas								: Array<TouchDesc>;
	
	/**
	 * on vérifie que l'instance singleton existe et qu'elle est active
	 * @return	true si tout est ok, false si pas prêt
	 */
	public static function isOK() : Bool { return instance != null && instance.getEventAnchor().interactive; }
	
	public function new() {
		var lAnchor	: DisplayObject	= getEventAnchor();
		
		instance	= this;
		datas		= [];
		
		lAnchor.on( "mousedown", onMouseDown);
		lAnchor.on( "mouseup", onMouseUp);
		lAnchor.on( "mouseupoutside", onMouseUp);
		//lAnchor.on( "mouseout", onMouseUp);
		lAnchor.on( "mousemove", onMouseMove);
		
		lAnchor.on( "touchstart", onTouchDown);
		lAnchor.on( "touchend", onTouchUp);
		lAnchor.on( "touchendoutside", onTouchUp);
		lAnchor.on( "touchmove", onTouchMove);
		
		switchEnable( true);
		
		VegaFramer.getInstance().addIterator( doFrame);
	}
	
	/**
	 * libération mémoire de l'instance et du singleton
	 */
	public function destroy() : Void {
		getEventAnchor().removeAllListeners();
		
		VegaFramer.getInstance().remIterator( doFrame);
		
		instance	= null;
		datas		= null;
	}
	
	/**
	 * on vérifie si une coord de touche passe par dessus un rectangle
	 * @param	pRect	rectangle dans le repère des touches
	 * @return	listes de touches passant par dessus (liste vide si aucune)
	 */
	public function getTouchOverRect( pRect : Rectangle) : Array<TouchDesc> {
		var lRes	: Array<TouchDesc>	= [];
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if ( pRect.contains( lTouch.coord.x, lTouch.coord.y)) lRes.push( lTouch);
		}
		
		return lRes;
	}
	
	/**
	 * on récupère une liste de touches marquées "down"
	 * @return	liste de touches "down", de la plus ancienne (en 0) à la plus récente ( n-1)
	 */
	public function getDownTouches() : Array<TouchDesc> {
		var lRes	: Array<TouchDesc>	= [];
		var lI		: Int				= 0;
		
		while ( lI < datas.length){
			if ( datas[ lI].isDown) lRes.push( datas[ lI]);
			
			lI++;
		}
		
		return lRes;
	}
	
	/**
	 * on récupère le descripteur de touche ayant l'identifiant précisé
	 * @param	pId		identifiant de touche recherchée
	 * @return	descripteur de touche correspondant, ou null si inexistant
	 */
	public function getTouchId( pId : EitherType<String,Int>) : TouchDesc {
		var lTouch	: TouchDesc;
		
		if ( pId == null) pId = DEFAULT_ID;
		
		for ( lTouch in datas) if ( lTouch.id == pId) return lTouch;
		
		return null;
	}
	
	/**
	 * on essaye de retrouver une touche à partir d'un event de touche
	 * @param	pE	event de touche
	 * @param	pIsMouse	true si event venant de souris, sinon recherche d'identifiant sur toutes les touches
	 * @return	descripteur de touche ou null si pas trouvé
	 */
	public function getTouchEvent( pE : InteractionEvent, pIsMouse : Bool = false) : TouchDesc {
		if ( pIsMouse) return getMouseTouch();
		else return getTouchId( pE.data.identifier);
	}
	
	/**
	 * on récupère les coordonnées globales du pointeur
	 * @return	coordonnées globales, ou null si pointeur invalide
	 */
	public function getPointerCoord() : PointXY {
		if ( datas.length > 0) return datas[ 0].coord;
		
		return null;
	}
	
	/**
	 * on bascule l'activation (perf)
	 * @param	pIsEnable	true pour activé, false pour désactivé
	 */
	public function switchEnable( pIsEnable : Bool) : Void {
		ApplicationMatchSize.instance.traceDebug( "INFO : GlobalPointer::switchEnable : " + pIsEnable);
		
		getEventAnchor().interactive = pIsEnable;
		
		flush();
	}
	
	/**
	 * on force la capture d'un event de down qu'on enregistre
	 * (par exemple, un bouton le capture en premier mais peut le transmettre explicitement pour court circuiter la chaine de transmission)
	 * @param	pE			event de down
	 * @param	pIsMouse	true pour désigner un event de souris, false pour le touchpad
	 */
	public function forceCaptureDown( pE : InteractionEvent, pIsMouse : Bool) : Void {
		ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::forceCaptureDown : id=" + pE.data.identifier + " ; isMouse=" + pIsMouse);
		
		if ( pIsMouse) onMouseDown( pE);
		else onTouchDown( pE);
		
		pE.stopPropagation();
	}
	
	/**
	 * on reset les données de pointeur
	 */
	public function flush() : Void {
		isDown	= false;
		datas	= [];
	}
	
	/**
	 * itération de frame
	 * @param	pDT	dt en ms
	 */
	function doFrame( pDT : Float) : Void {
		var lI	: Int	= datas.length - 1;
		
		while ( lI >= 0) {
			datas[ lI].delay += pDT;
			
			if ( datas[ lI].isMouse){
				//if ( datas[ lI].delay >= TIMEOUT_MOUSE) datas.remove( datas[ lI]);
			}else{
				if ( datas[ lI].delay >= TIMEOUT) datas.remove( datas[ lI]);
			}
			
			lI--;
		}
		
		checkTouchState();
	}
	
	/**
	 * on retourne une chaine de trace
	 * @return	chaine de trace
	 */
	public function toString() : String {
		var lStr	: String		= "";
		
		for ( iTouch in datas) lStr += iTouch.id + ":" + Math.round( iTouch.coord.x) + ":" + Math.round( iTouch.coord.y) + ":" + ( iTouch.isDown ? "D" : "U") + ":" + ( iTouch.isMouse ? "M" : "T") + " - ";
		
		return lStr;
	}
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant de repère de coordonnées
	 * @return	objet d'affichage
	 */
	public function getRepere() : DisplayObject { return ApplicationMatchSize.instance.getContent(); }
	
	function onTouchDown( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		var lPt		: PointXY	= new PointXY();
		
		pE.data.getLocalPosition( getRepere(), cast lPt);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= true;
		}else datas.push( new TouchDesc( lPt, false, true, pE.data.identifier));
		
		checkTouchState();
	}
	
	function onTouchUp( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		if ( lTouch != null){
			datas.remove( lTouch);
			checkTouchState();
		}
	}
	
	function onTouchMove( pE : InteractionEvent) : Void {
		var lPt		: PointXY	= new PointXY();
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		pE.data.getLocalPosition( getRepere(), cast lPt);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= true;
		}else datas.push( new TouchDesc( lPt, false, true, pE.data.identifier));
		
		checkTouchState();
	}
	
	function onMouseDown( pE : InteractionEvent) : Void {
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		var lPt		: PointXY	= new PointXY();
		
		pE.data.getLocalPosition( getRepere(), cast lPt);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= true;
			
			if( ! lTouch.isMouse) ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::onMouseDown : not a mouse event : " + pE.data.identifier);
		}else{
			lTouch = findNearestPos( lPt);
			
			if ( lTouch != null && ( lTouch.coord.x - lPt.x) * ( lTouch.coord.x - lPt.x) + ( lTouch.coord.y - lPt.y) * ( lTouch.coord.y - lPt.y) <= MOUSE_DUP_PROXIMITY * MOUSE_DUP_PROXIMITY){
				ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::onMouseDown : force mouse to touch : " + pE.data.identifier + " -> " + lTouch.id);
				
				lTouch.coord	= lPt;
				lTouch.delay	= 0;
				lTouch.isDown	= true;
			}else{
				datas.push( new TouchDesc( lPt, true, true, pE.data.identifier));
			}
		}
		
		checkTouchState();
	}
	
	function onMouseUp( pE : InteractionEvent) : Void {
		var lPt		: PointXY	= new PointXY();
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		pE.data.getLocalPosition( getRepere(), cast lPt);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			lTouch.isDown	= false;
		}else{
			lTouch = findNearestPos( lPt);
			
			if ( lTouch != null && ( lTouch.coord.x - lPt.x) * ( lTouch.coord.x - lPt.x) + ( lTouch.coord.y - lPt.y) * ( lTouch.coord.y - lPt.y) <= MOUSE_DUP_PROXIMITY * MOUSE_DUP_PROXIMITY){
				ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::onMouseUp : force mouse to touch : " + pE.data.identifier + " -> " + lTouch.id + " ; remove");
				
				datas.remove( lTouch);
			}else{
				datas.push( new TouchDesc( lPt, true, false, pE.data.identifier));
			}
		}
		
		checkTouchState();
	}
	
	function onMouseMove( pE : InteractionEvent) : Void {
		var lPt		: PointXY	= new PointXY();
		var lTouch	: TouchDesc	= getTouchId( pE.data.identifier);
		
		pE.data.getLocalPosition( getRepere(), cast lPt);
		
		if ( lTouch != null){
			lTouch.coord	= lPt;
			lTouch.delay	= 0;
			
			if( ! lTouch.isMouse) ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::onMouseMove : not a mouse event : " + pE.data.identifier);
		}else{
			lTouch = findNearestPos( lPt);
			
			if ( lTouch != null && ( lTouch.coord.x - lPt.x) * ( lTouch.coord.x - lPt.x) + ( lTouch.coord.y - lPt.y) * ( lTouch.coord.y - lPt.y) <= MOUSE_DUP_PROXIMITY * MOUSE_DUP_PROXIMITY){
				ApplicationMatchSize.instance.traceDebug( "WARNING : GlobalPointer::onMouseMove : force mouse to touch : " + pE.data.identifier + " -> " + lTouch.id);
				
				lTouch.coord	= lPt;
				lTouch.delay	= 0;
			}else{
				datas.push( new TouchDesc( lPt, true, false, pE.data.identifier));
				
				checkTouchState();
			}
		}
	}
	
	/**
	 * on récupère une réf sur l'objet d'affichage servant d'ancrage aux évent de touch / mouse
	 * @return	objet d'affichage
	 */
	function getEventAnchor() : DisplayObject { return ApplicationMatchSize.instance.stage; }
	
	// sans InteractionData::identifier
	/**
	 * on recherche la touche la plus proche du point précisé ; par défaut, méthode dédiée au touchpad
	 * @param	pPos		position de recherche
	 * @param	pDoMouse	true pour inclure la souris à la recherche, false si que le touch pad
	 * @return	touche enregistrée la plus proche, ou null si rien de trouvé
	 */
	function findNearestPos( pPos : PointXY, pDoMouse : Bool = false) : TouchDesc {
		var lDist	: Float		= -1;
		var lRes	: TouchDesc	= null;
		var lTmp	: Float;
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if( pDoMouse || ( ! lTouch.isMouse)){
				lTmp = ( lTouch.coord.x - pPos.x) * ( lTouch.coord.x - pPos.x) + ( lTouch.coord.y - pPos.y) * ( lTouch.coord.y - pPos.y);
				
				if ( lDist < 0 || lTmp < lDist){
					lDist	= lTmp;
					lRes	= lTouch;
				}
			}
		}
		
		return lRes;
	}
	
	/**
	 * on récupère la ref sur la touche de la souris
	 * @return	ref sur touche de souris ou null si aucune
	 */
	function getMouseTouch() : TouchDesc {
		var lTouch	: TouchDesc;
		
		for ( lTouch in datas){
			if ( lTouch.isMouse) return lTouch;
		}
		
		return null;
	}
	
	/**
	 * on rafraichit l'état de la touche
	 */
	function checkTouchState() : Void {
		if ( datas.length > 0){
			if ( datas[ 0].isMouse){
				isTouchpad	= false;
				isDown		= datas[ 0].isDown;
			}else{
				isTouchpad	= true;
				isDown		= true;
			}
			
			//if( isDown) ApplicationMatchSize.instance.traceDebug( toString(), true);
		}else isDown = false;
	}
}

/**
 * descripteur de touche
 */
class TouchDesc {
	public var coord			: PointXY;
	public var delay			: Float;
	public var isMouse			: Bool;
	public var isDown			: Bool;
	public var id				: EitherType<String,Int>;
	
	public var isBound			: Bool						= false;
	
	public function new( pCoord : PointXY, pIsMouse : Bool, pIsDown : Bool, pId : EitherType<String,Int>) {
		/*if( pIsMouse){
			ApplicationMatchSize.instance.traceDebug( "INFO : TouchDesc::TouchDesc : isMouse=" + pIsMouse + " ; isDown=" + pIsDown + " ; id=" + pId, true);
			
			try{ throw new Error(); }catch ( pE : Error){
				ApplicationMatchSize.instance.traceDebug( pE.stack.split( "at ")[ 2], true);
				ApplicationMatchSize.instance.traceDebug( pE.stack.split( "at ")[ 3], true);
				ApplicationMatchSize.instance.traceDebug( pE.stack.split( "at ")[ 4], true);
			}
		}*/
		
		coord	= pCoord;
		isMouse	= pIsMouse;
		delay	= 0;
		isDown	= pIsDown;
		id		= pId != null ? pId : GlobalPointer.DEFAULT_ID;
	}
}