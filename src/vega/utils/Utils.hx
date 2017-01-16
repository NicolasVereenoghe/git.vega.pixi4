package vega.utils;

/**
 * ...
 * @author nico
 */
class Utils {
	/** The lowest integer value in Flash and JS. */
    public static inline var INT_MIN :Int = -2147483648;
	/** The highest integer value in Flash and JS. */
    public static inline var INT_MAX :Int = 2147483647;
	
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
	 * @param	pA	coef a
	 * @param	pB	coef b
	 * @param	pC	coef c
	 * @param	pD	coef d
	 * @return	liste de racines possibles : [ x1, x2, x3]
	 */
	public static function poly3( pA : Float, pB : Float, pC : Float, pD : Float) : Array<Float> {
		var lP	: Float	= ( 3 * pA * pC - pB * pB) / ( 3 * pA * pA);
		var lQ	: Float	= ( 2 * pB * pB * pB - 9 * pA * pB * pC + 27 * pA * pA * pD) / ( 27 * pA * pA * pA);
		var lD1	: Float	= lQ * lQ + 4 * lP * lP * lP / 27;
		var lX1	: Float	= cubeRoot( ( -lQ - lD1) / 2) + cubeRoot( ( -lQ + lD1) / 2) - pB / ( 3 * pA);
		var lD2	: Float	= ( pB + pA * lX1) * ( pB + pA * lX1) - 4 * pA * ( pC + ( pB + pA * lX1) * lX1);
		
		if ( lD2 < 0) return [ lX1];
		else return[
			lX1,
			( -pB - pA * lX1 - Math.sqrt( lD2)) / ( 2 * pA),
			( -pB - pA * lX1 + Math.sqrt( lD2)) / ( 2 * pA)
		];
	}
	
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