package vega.utils;

/**
 * ...
 * @author nico
 */
class Utils {
	/** The lowest integer value in Flash and JS. */
    public static inline var INT_MIN		: Int									= -2147483648;
	/** The highest integer value in Flash and JS. */
    public static inline var INT_MAX		: Int									= 2147483647;
	
	/** an arbitrary epsilon constant */
	public static inline var EPSILON		: Float									= 1e-8;
	
	/** pools de probabilité contrôlée, classés par id de pool */
	static var PROBA_POOLS					: Map<String,Array<Bool>>				= null;
	
	public static function minInt( pA : Int, pB : Int) : Int { return pA < pB ? pA : pB; }
	public static function maxInt( pA : Int, pB : Int) : Int { return pA > pB ? pA : pB; }
	
	public static function isMapEmpty( pMap : Map<Dynamic,Dynamic>) : Bool {
		var lVal : Dynamic;
		
		if ( pMap == null) return true;
		
		for ( lVal in pMap) return false;
		
		return true;
	}
	
	public static function cloneMap( pMap : Map<Dynamic,Dynamic>) : Map<Dynamic,Dynamic> {
		var lClone	: Map<Dynamic,Dynamic>	= Type.createInstance( Type.getClass( pMap), []);
		var lKey	: Dynamic;
		
		for ( lKey in pMap.keys()) lClone.set( lKey, pMap.get( lKey));
		
		return lClone;
	}
	
	public static function doesInherit( pSon : Class<Dynamic>, pMother : Class<Dynamic>) : Bool {
		if ( pSon == null) return false;
		
		//if ( Type.getClassName( pSon) == Type.getClassName( pMother)) return true;
		if ( pSon == pMother) return true;
		
		return doesInherit( Type.getSuperClass( pSon), pMother);
	}
	
	/**
	 * probabilité contrôlée : on garantie une probabilité sur un échantillon de tirages passés significatif par rapport à la probabilité
	 * @param	pId				identifiant de pool
	 * @param	pProba			probabilité : [ 0 .. 1]
	 * @param	pChaosRate		taux de "chaos" pour éviter des schémas répétitifs de probabilité : [ 0 .. 1]
	 * @param	pPoolLenMax		taille max d'un pool de probabilité contrôlée ; > 0 ; défini aussi la précision max : 1 / pPoolLenMax
	 * @return	true si la proba se vérifie, false sinon
	 */
	public static function isProbaId( pId : String, pProba : Float, pChaosRate : Float = .3, pPoolLenMax : Int = 20) : Bool {
		var lPool	: Array<Bool>;
		var lDI		: Int;
		var lI		: Int;
		var lNb		: Int;
		var lCtr	: Int;
		var lProba	: Float;
		var lRes	: Bool;
		
		if ( pProba <= 0) return false;
		else if ( pProba >= 1) return true;
		
		if ( PROBA_POOLS == null) PROBA_POOLS = new Map<String,Array<Bool>>();
		
		if ( ! PROBA_POOLS.exists( pId)){
			PROBA_POOLS.set( pId, new Array<Bool>());
			
			lRes = ( pProba >= .5);
			
			PROBA_POOLS.get( pId).push( lRes);
			
			return lRes;
		}
		
		lPool = PROBA_POOLS.get( pId);
		
		if ( pProba < .5){
			lNb = Utils.minInt( Math.round( 1 / pProba), pPoolLenMax);
		}else{
			lNb	= Utils.minInt( Math.round( 1 / ( 1 - pProba)), pPoolLenMax);
		}
		
		lCtr = 0;
		lDI = lPool.length - ( lPool.length < lNb ? lPool.length : lNb);
		lI = lDI;
		while ( lI < lPool.length){
			if ( lPool[ lI]) lCtr++;
			
			lI++;
		}
		
		lProba = lCtr / lI;
		
		if ( Math.abs( pProba - lProba) >= pChaosRate * pProba){
			if ( lProba == pProba) lRes = lPool[ lDI];
			else lRes = ( lProba < pProba);
			
			lPool.push( lRes);
			
			while ( lPool.length > pPoolLenMax) lPool.shift();
			
			return lRes;
		}else{
			lRes = ( Math.random() < .5);
			
			lPool.push( lRes);
			
			while ( lPool.length > pPoolLenMax) lPool.shift();
			
			return lRes;
		}
		
		return true;
	}
	
	/**
	 * probabilité contrôlée : on force un résultat de tirage de probabilité dans son pool
	 * @param	pId			identifiant de probabilité contrôlée
	 * @param	pIsProba	valeur de proba forcée
	 */
	public static function forceProbaId( pId : String, pIsProba : Bool) : Void {
		if ( PROBA_POOLS == null) PROBA_POOLS = new Map<String,Array<Bool>>();
		
		if ( ! PROBA_POOLS.exists( pId)) PROBA_POOLS.set( pId, new Array<Bool>());
		
		PROBA_POOLS.get( pId).push( pIsProba);
	}
	
	/**
	 * on réinitialise un pool de probabilité contrôlée
	 * @param	pId	identifiant de pool
	 */
	public static function freeProbaId( pId : String) : Void { if ( PROBA_POOLS != null && PROBA_POOLS.exists( pId)) PROBA_POOLS.remove( pId); }
	
	/**
	 * on calcule l'angle médian d'un secteur d'angle
	 * @param	pModALeft	angle sur [ 0 .. 2PI [ de borne gauche (début, sens trigo) de secteur
	 * @param	pModARight	angle sur [ 0 .. 2PI [ de borne droite (fin, sens trigo) de secteur
	 * @return	angle médian sur [ 0 .. 2PI [
	 */
	public static function midA( pModALeft : Float, pModARight : Float) : Float {
		if ( pModALeft > pModARight) return modA( ( pModALeft + pModARight) / 2 - Math.PI);
		else return ( pModALeft + pModARight) / 2;
	}
	
	/**
	 * on calcule le modulo de l'angle sur [ 0 .. 2PI [
	 * @param	pA	angle en radian
	 * @return	angle sur [ 0 .. 2PI [
	 */
	public static function modA( pA : Float) : Float {
		var l2PI	: Float	= 2 * Math.PI;
		
		pA %= l2PI;
		
		if ( pA < 0) pA = ( pA + l2PI) % l2PI;
		
		return pA;
	}
	
	/**
	 * on génère un nuages de points répartis de manière homogène dans un disque unitaire
	 * @param	pNbConcentric	nombre de cercle concentriques à générer dans le disque (min=1)
	 * @return	liste de points ( x:[0], y:[1]) sur le disque unitaire
	 * @see		http://www.holoborodko.com/pavel/2015/07/23/generating-equidistant-points-on-unit-disk/
	 */
	public static function generateCloudInDisk( pNbConcentric : Int) : Array<Array<Float>> {
		var lRes	: Array<Array<Float>>	= [ [ 0, 0]];
		var lIDisk	: Int					= 1;
		var lNb		: Int;
		var lR		: Float;
		var lIA		: Int;
		var lA		: Float;
		
		if ( pNbConcentric < 1) pNbConcentric = 1;
		
		while ( lIDisk <= pNbConcentric){
			lNb	= Math.round( Math.PI / Math.asin( 1 / ( 2 * lIDisk)));
			lR	= lIDisk / pNbConcentric;
			
			lIA = 0;
			while ( lIA < lNb){
				lA	= 2 * Math.PI * lIA++ / lNb;
				lRes.push( [
					lR * Math.cos( lA),
					lR * Math.sin( lA)
				]);
			}
			
			lIDisk++;
		}
		
		return lRes;
	}
	
	/**
	 * calcule de racine cubique
	 * @param	pVal	valeur au cube
	 * @return	racine cubique
	 */
	public static function cubeRoot( pVal : Float) : Float {
		if ( pVal < 0) return -Math.pow( -pVal, 1 / 3);
		else return Math.pow( pVal, 1 / 3);
	}
	
	/**
	 * calcul des racines d'un polynome de 3ème deg : ax^3 + bx^2 + cx + d = 0
	 * @param	pA	coef a ; (!=0)
	 * @param	pB	coef b
	 * @param	pC	coef c
	 * @param	pD	coef d
	 * @return	liste de racines possibles : [ x1, x2, x3]
	 */
	public static function poly3( pA : Float, pB : Float, pC : Float, pD : Float) : Array<Float> {
		/*var lP	: Float	= ( 3 * pA * pC - pB * pB) / ( 3 * pA * pA);
		var lQ	: Float	= ( 2 * pB * pB * pB - 9 * pA * pB * pC + 27 * pA * pA * pD) / ( 27 * pA * pA * pA);
		var lD1	: Float	= lQ * lQ + 4 * lP * lP * lP / 27;
		var lX1	: Float	= cubeRoot( ( -lQ - lD1) / 2) + cubeRoot( ( -lQ + lD1) / 2) - pB / ( 3 * pA);
		var lD2	: Float	= ( pB + pA * lX1) * ( pB + pA * lX1) - 4 * pA * ( pC + ( pB + pA * lX1) * lX1);
		
		if ( lD2 < 0) return [ lX1];
		else return[
			lX1,
			( -pB - pA * lX1 - Math.sqrt( lD2)) / ( 2 * pA),
			( -pB - pA * lX1 + Math.sqrt( lD2)) / ( 2 * pA)
		];*/
		
		var lP		: Float			= ( 3 * pA * pC - pB * pB) / ( 3 * pA * pA);
		var lQ		: Float			= ( 2 * pB * pB * pB - 9 * pA * pB * pC + 27 * pA * pA * pD) / ( 27 * pA * pA * pA);
		var lDeprec	: Float			= pB / ( 3 * pA);
		var lD		: Float;
		var lU		: Float;
		var lT		: Float;
		var lK		: Float;
		
		if ( Math.abs( lP) < EPSILON){
			return [ cubeRoot( -lQ) - lDeprec];
		}else if ( Math.abs( lQ) < EPSILON){
			if ( lP < 0) return [ -lDeprec, Math.sqrt( -lP) - lDeprec, -Math.sqrt( -lP) - lDeprec];
			else return [ -lDeprec];
		}else{
			lD = lQ * lQ / 4 + lP * lP * lP / 27;
			
			if ( Math.abs( lD) < EPSILON){
				return [ -1.5 * lQ / lP - lDeprec, 3 * lQ / lP - lDeprec];
			}else if ( lD > 0){
				lU = cubeRoot( -lQ / 2 - Math.sqrt( lD));
				
				return [ lU - lP / ( 3 * lU) - lDeprec];
			}else{
				lU = 2 * Math.sqrt( -lP / 3);
				lT = Math.acos( 3 * lQ / lP / lU) / 3;
				lK = 2 * Math.PI / 3;
				
				return [ lU * Math.cos( lT) - lDeprec, lU * Math.cos( lT - lK) - lDeprec, lU * Math.cos( lT - 2 * lK) - lDeprec];
			}
		}
	}
	
	/*function cuberoot(x) {
		var y = Math.pow(Math.abs(x), 1/3);
		return x < 0 ? -y : y;
	}

	function solveCubic(a, b, c, d) {
		if (Math.abs(a) < 1e-8) { // Quadratic case, ax^2+bx+c=0
			a = b; b = c; c = d;
			if (Math.abs(a) < 1e-8) { // Linear case, ax+b=0
				a = b; b = c;
				if (Math.abs(a) < 1e-8) // Degenerate case
					return [];
				return [-b/a];
			}

			var D = b*b - 4*a*c;
			if (Math.abs(D) < 1e-8)
				return [-b/(2*a)];
			else if (D > 0)
				return [(-b+Math.sqrt(D))/(2*a), (-b-Math.sqrt(D))/(2*a)];
			return [];
		}

		// Convert to depressed cubic t^3+pt+q = 0 (subst x = t - b/3a)
		var p = (3*a*c - b*b)/(3*a*a);
		var q = (2*b*b*b - 9*a*b*c + 27*a*a*d)/(27*a*a*a);
		var roots;

		if (Math.abs(p) < 1e-8) { // p = 0 -> t^3 = -q -> t = -q^1/3
			roots = [cuberoot(-q)];
		} else if (Math.abs(q) < 1e-8) { // q = 0 -> t^3 + pt = 0 -> t(t^2+p)=0
			roots = [0].concat(p < 0 ? [Math.sqrt(-p), -Math.sqrt(-p)] : []);
		} else {
			var D = q*q/4 + p*p*p/27;
			if (Math.abs(D) < 1e-8) {       // D = 0 -> two roots
				roots = [-1.5*q/p, 3*q/p];
			} else if (D > 0) {             // Only one real root
				var u = cuberoot(-q/2 - Math.sqrt(D));
				roots = [u - p/(3*u)];
			} else {                        // D < 0, three roots, but needs to use complex numbers/trigonometric solution
				var u = 2*Math.sqrt(-p/3);
				var t = Math.acos(3*q/p/u)/3;  // D < 0 implies p < 0 and acos argument in [-1..1]
				var k = 2*Math.PI/3;
				roots = [u*Math.cos(t), u*Math.cos(t-k), u*Math.cos(t-2*k)];
			}
		}

		// Convert back from depressed cubic
		for (var i = 0; i < roots.length; i++)
			roots[i] -= b/(3*a);

		return roots;
	}*/
	
	
	/**
	 * on détermine si un angle fait partie d'un secteur angulaire
	 * @param	pModA		angle sur [ 0 .. 2PI [ à tester
	 * @param	pModALeft	angle sur [ 0 .. 2PI [ de borne gauche (début, sens trigo) de secteur
	 * @param	pModARight	angle sur [ 0 .. 2PI [ de borne droite (fin, sens trigo) de secteur
	 * @return	true si l'angle est dans le secteur, false sinon
	 */
	public static function isAInSector( pModA : Float, pModALeft : Float, pModARight : Float) : Bool {
		if ( pModALeft > pModARight){
			if ( pModA < pModALeft) return pModA >= pModALeft - 2 * Math.PI && pModA <= pModARight;
			else return pModA >= pModALeft && pModA <= pModARight + 2 * Math.PI;
		}else{
			return pModA >= pModALeft && pModA <= pModARight;
		}
	}
}