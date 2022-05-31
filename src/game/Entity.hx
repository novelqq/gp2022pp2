class Entity {
    public static var ALL : Array<Entity> = [];
    public static var GC : Array<Entity> = [];

	// Various getters to access all important stuff easily
	public var app(get,never) : App; inline function get_app() return App.ME;
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var destroyed(default,null) = false;
	public var ftime(get,never) : Float; inline function get_ftime() return game.ftime;
	public var camera(get,never) : Camera; inline function get_camera() return game.camera;

	var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;
	var utmod(get,never) : Float; inline function get_utmod() return Game.ME.utmod;
	public var hud(get,never) : ui.Hud; inline function get_hud() return Game.ME.hud;

	/** State machine. Value should only be changed using `startState(v)` **/
	public var state(default,null) : State;

	/** Unique identifier **/
	public var uid(default,null) : Int;

	public var z = 0;
	/** Grid X coordinate **/
    public var cx = 0;
	/** Grid Y coordinate **/
    public var cy = 0;
	/** Sub-grid X coordinate (from 0.0 to 1.0) **/
    public var xr = 0.5;
	/** Sub-grid Y coordinate (from 0.0 to 1.0) **/
    public var yr = 0.5;

	/** X velocity, in grid fractions **/
    public var dx = 0.;
	/** Y velocity, in grid fractions **/
	public var dy = 0.;

	/** Last known X position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
	var lastFixedUpdateX = 0.;
	/** Last known Y position of the attach point (in pixels), at the beginning of the latest fixedUpdate **/
	var lastFixedUpdateY = 0.;

	/** If TRUE, the sprite display coordinates will be an interpolation between the last known position and the current one. This is useful if the gameplay happens in the `fixedUpdate()` (so at 30 FPS), but you still want the sprite position to move smoothly at 60 FPS or more. **/
	var interpolateSprPos = true;

	/** Pixel width of entity **/
	public var wid(default,set) : Float = Const.GRID;
		inline function set_wid(v) { invalidateDebugBounds=true;  return wid=v; }

	/** Pixel height of entity **/
	public var hei(default,set) : Float = Const.GRID;
		inline function set_hei(v) { invalidateDebugBounds=true;  return hei=v; }

	/** Inner radius in pixels (ie. smallest value between width/height, then divided by 2) **/
	public var innerRadius(get,never) : Float;
		inline function get_innerRadius() return M.fmin(wid,hei)*0.5;

	/** "Large" radius in pixels (ie. biggest value between width/height, then divided by 2) **/
	public var largeRadius(get,never) : Float;
		inline function get_largeRadius() return M.fmax(wid,hei)*0.5;

	/** Horizontal direction, can only be -1 or 1 **/
	public var dir(default,set) = 1;

	/** Current sprite X **/
	public var sprX(get,never) : Float;
		inline function get_sprX() {
			return interpolateSprPos
				? M.lerp( lastFixedUpdateX, (cx+xr)*Const.GRID, game.getFixedUpdateAccuRatio() )
				: (cx+xr)*Const.GRID;
		}

	/** Current sprite Y **/
	public var sprY(get,never) : Float;
		inline function get_sprY() {
			return interpolateSprPos
				? M.lerp( lastFixedUpdateY, (cy+yr)*Const.GRID, game.getFixedUpdateAccuRatio() )
				: (cy+yr)*Const.GRID;
		}

	/** Sprite X scaling **/
	public var sprScaleX = 1.0;
	/** Sprite Y scaling **/
	public var sprScaleY = 1.0;

	/** Sprite X squash & stretch scaling, which automatically comes back to 1 after a few frames **/
	var sprSquashX = 1.0;
	/** Sprite Y squash & stretch scaling, which automatically comes back to 1 after a few frames **/
	var sprSquashY = 1.0;

	/** Entity visibility **/
	public var entityVisible = true;

	/** Main entity HSprite instance **/
    public var spr : HSprite;

	/** Color vector transformation applied to sprite **/
	public var baseColor : h3d.Vector;

	/** Color matrix transformation applied to sprite **/
	public var colorMatrix : h3d.Matrix;

	// Debug stuff
	var debugLabel : Null<h2d.Text>;
	var debugBounds : Null<h2d.Graphics>;
	var invalidateDebugBounds = false;

	/** Defines X alignment of entity at its attach point (0 to 1.0) **/
	public var pivotX(default,set) : Float = 0.5;
	/** Defines Y alignment of entity at its attach point (0 to 1.0) **/
	public var pivotY(default,set) : Float = 0.5;

	/** Entity attach X pixel coordinate **/
	public var attachX(get,never) : Float; inline function get_attachX() return (cx+xr)*Const.GRID;
	/** Entity attach Y pixel coordinate **/
	public var attachY(get,never) : Float; inline function get_attachY() return (cy+yr)*Const.GRID;

	// Various coordinates getters, for easier gameplay coding

	/** Left pixel coordinate of the bounding box **/
	public var left(get,never) : Float; inline function get_left() return attachX + (0-pivotX) * wid;
	/** Right pixel coordinate of the bounding box **/
	public var right(get,never) : Float; inline function get_right() return attachX + (1-pivotX) * wid;
	/** Top pixel coordinate of the bounding box **/
	public var top(get,never) : Float; inline function get_top() return attachY + (0-pivotY) * hei;
	/** Bottom pixel coordinate of the bounding box **/
	public var bottom(get,never) : Float; inline function get_bottom() return attachY + (1-pivotY) * hei;

	/** Center X pixel coordinate of the bounding box **/
	public var centerX(get,never) : Float; inline function get_centerX() return attachX + (0.5-pivotX) * wid;
	/** Center Y pixel coordinate of the bounding box **/
	public var centerY(get,never) : Float; inline function get_centerY() return attachY + (0.5-pivotY) * hei;

	/** Current X position on screen (ie. absolute)**/
	public var screenAttachX(get,never) : Float;
		inline function get_screenAttachX() return game!=null && !game.destroyed ? sprX*Const.SCALE + game.scroller.x : sprX*Const.SCALE;

	/** Current Y position on screen (ie. absolute)**/
	public var screenAttachY(get,never) : Float;
		inline function get_screenAttachY() return game!=null && !game.destroyed ? sprY*Const.SCALE + game.scroller.y : sprY*Const.SCALE;

	/** attachX value during last frame **/
	public var prevFrameAttachX(default,null) : Float = -Const.INFINITE;
	/** attachY value during last frame **/
	public var prevFrameAttachY(default,null) : Float = -Const.INFINITE;

	var actions : Array<{ id:String, cb:Void->Void, t:Float }> = [];


	/**
		Constructor
	**/
    public function new(x:Int, y:Int) {
        uid = Const.makeUniqueId();
		ALL.push(this);

        setPosCase(x,y);
		state = Normal;

        spr = new HSprite(Assets.tiles);
		Game.ME.scroller.add(spr, Const.DP_MAIN);
		spr.colorAdd = new h3d.Vector();
		baseColor = new h3d.Vector();
		spr.colorMatrix = colorMatrix = h3d.Matrix.I();
		spr.setCenterRatio(pivotX, pivotY);

		if( ui.Console.ME.hasFlag("bounds") )
			enableDebugBounds();
    }


	function set_pivotX(v) {
		pivotX = M.fclamp(v,0,1);
		if( spr!=null )
			spr.setCenterRatio(pivotX, pivotY);
		return pivotX;
	}

	function set_pivotY(v) {
		pivotY = M.fclamp(v,0,1);
		if( spr!=null )
			spr.setCenterRatio(pivotX, pivotY);
		return pivotY;
	}

	inline function set_dir(v) {
		return dir = v>0 ? 1 : v<0 ? -1 : dir;
	}

	/** Move entity to grid coordinates **/
	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
		z = level.getZValue(x,y);
		onPosManuallyChangedBoth();
	}

	/** Move entity to pixel coordinates **/
	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
		onPosManuallyChangedBoth();
	}

	/** Should be called when you manually (ie. ignoring physics) modify both X & Y entity coordinates **/
	function onPosManuallyChangedBoth() {
		if( M.dist(attachX,attachY,prevFrameAttachX,prevFrameAttachY) > Const.GRID*2 ) {
			prevFrameAttachX = attachX;
			prevFrameAttachY = attachY;
		}
		updateLastFixedUpdatePos();
	}

	/** Should be called when you manually (ie. ignoring physics) modify entity X coordinate **/
	function onPosManuallyChangedX() {
		if( M.fabs(attachX-prevFrameAttachX) > Const.GRID*2 )
			prevFrameAttachX = attachX;
		lastFixedUpdateX = attachX;
	}

	/** Should be called when you manually (ie. ignoring physics) modify entity Y coordinate **/
	function onPosManuallyChangedY() {
		if( M.fabs(attachY-prevFrameAttachY) > Const.GRID*2 )
			prevFrameAttachY = attachY;
		lastFixedUpdateY = attachY;
	}


	/** Quickly set X/Y pivots. If Y is omitted, it will be equal to X. **/
	public function setPivots(x:Float, ?y:Float) {
		pivotX = x;
		pivotY = y!=null ? y : x;
	}

	/** Return TRUE if the Entity *center point* is in screen bounds (default padding is +32px) **/
	public inline function isOnScreenCenter(padding=32) {
		return camera.isOnScreen( centerX, centerY, padding + M.fmax(wid*0.5, hei*0.5) );
	}

	/** Return TRUE if the Entity rectangle is in screen bounds (default padding is +32px) **/
	public inline function isOnScreenBounds(padding=32) {
		return camera.isOnScreenRect( left,top, wid, hei, padding );
	}


	/**
		Changed the current entity state.
		Return TRUE if the state is `s` after the call.
	**/
	public function startState(s:State) : Bool {
		if( s==state )
			return true;

		if( !canChangeStateTo(state, s) )
			return false;

		var old = state;
		state = s;
		onStateChange(old,state);
		return true;
	}


	/** Return TRUE to allow a change of the state value **/
	function canChangeStateTo(from:State, to:State) {
		return true;
	}

	/** Called when state is changed to a new value **/
	function onStateChange(old:State, newState:State) {}

	public function is<T:Entity>(c:Class<T>) return Std.isOfType(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.downcast(this, c);

	/** Return a random Float value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	/** Return a random Integer value in range [min,max]. If `sign` is TRUE, returned value might be multiplied by -1 randomly. **/
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);

	/** Truncate a float value using given `precision` **/
	public inline function pretty(value:Float,?precision=1) return M.pretty(value,precision);

	/** Return a distance (in grid cells) from this to something **/
	public inline function distCase(?e:Entity, ?tcx:Int, ?tcy:Int, ?txr=0.5, ?tyr=0.5) {
		if( e!=null )
			return M.dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
		else
			return M.dist(cx+xr, cy+yr, tcx+txr, tcy+tyr);
	}

	/** Return a distance (in pixels) from this to something **/
	public inline function distPx(?e:Entity, ?x:Float, ?y:Float) {
		if( e!=null )
			return M.dist(attachX, attachY, e.attachX, e.attachY);
		else
			return return M.dist(attachX, attachY, x, y);
	}

	function canSeeThrough(cx:Int, cy:Int) {
		return !level.hasCollision(cx,cy) || this.cx==cx && this.cy==cy;
	}

	/** Check if the grid-based line between this and given target isn't blocked by some obstacle **/
	public inline function sightCheck(?e:Entity, ?tcx:Int, ?tcy:Int) {
		if( e!=null)
			return e==this ? true : dn.Bresenham.checkThinLine(cx, cy, e.cx, e.cy, canSeeThrough);
		else
			return dn.Bresenham.checkThinLine(cx, cy, tcx, tcy, canSeeThrough);
	}

	/** Create a LPoint instance from current coordinates **/
	public inline function createPoint() return LPoint.fromCase(cx+xr,cy+yr);

	/** Create a LRect instance from current entity bounds **/
	public inline function createRect() return tools.LRect.fromPixels( Std.int(left), Std.int(top), Std.int(wid), Std.int(hei) );

    public final function destroy() {
        if( !destroyed ) {
            destroyed = true;
            GC.push(this);
        }
    }

    public function dispose() {
        ALL.remove(this);

		baseColor = null;
		colorMatrix = null;

		spr.remove();
		spr = null;

		if( debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}

		if( debugBounds!=null ) {
			debugBounds.remove();
			debugBounds = null;
		}
    }


	/** Print some numeric value below entity **/
	public inline function debugFloat(v:Float, ?c=0xffffff) {
		debug( pretty(v), c );
	}


	/** Print some value below entity **/
	public inline function debug(?v:Dynamic, ?c=0xffffff) {
		#if debug
		if( v==null && debugLabel!=null ) {
			debugLabel.remove();
			debugLabel = null;
		}
		if( v!=null ) {
			if( debugLabel==null ) {
				debugLabel = new h2d.Text(Assets.fontPixel, Game.ME.scroller);
				debugLabel.filter = new dn.heaps.filter.PixelOutline();
			}
			debugLabel.text = Std.string(v);
			debugLabel.textColor = c;
		}
		#end
	}

	/** Hide entity debug bounds **/
	public function disableDebugBounds() {
		if( debugBounds!=null ) {
			debugBounds.remove();
			debugBounds = null;
		}
	}


	/** Show entity debug bounds (position and width/height). Use the `/bounds` command in Console to enable them. **/
	public function enableDebugBounds() {
		if( debugBounds==null ) {
			debugBounds = new h2d.Graphics();
			game.scroller.add(debugBounds, Const.DP_TOP);
		}
		invalidateDebugBounds = true;
	}

	function renderDebugBounds() {
		var c = Color.makeColorHsl((uid%20)/20, 1, 1);
		debugBounds.clear();

		// Bounds rect
		debugBounds.lineStyle(1, c, 0.5);
		debugBounds.drawRect(left-attachX, top-attachY, wid, hei);

		// Attach point
		debugBounds.lineStyle(0);
		debugBounds.beginFill(c,0.8);
		debugBounds.drawRect(-1, -1, 3, 3);
		debugBounds.endFill();

		// Center
		debugBounds.lineStyle(1, c, 0.3);
		debugBounds.drawCircle(centerX-attachX, centerY-attachY, 3);
	}

	/** Briefly squash sprite on X (Y changes accordingly). "1.0" means no distorsion. **/
	public function setSquashX(scaleX:Float) {
		sprSquashX = scaleX;
		sprSquashY = 2-scaleX;
	}

	/** Briefly squash sprite on Y (X changes accordingly). "1.0" means no distorsion. **/
	public function setSquashY(scaleY:Float) {
		sprSquashX = 2-scaleY;
		sprSquashY = scaleY;
	}


	/**
		"Beginning of the frame" loop, called before any other Entity update loop
	**/
    public function preUpdate() {

		#if debug
		// Show bounds (with `/bounds` in console)
		if( ui.Console.ME.hasFlag("bounds") && debugBounds==null )
			enableDebugBounds();

		// Hide bounds
		if( !ui.Console.ME.hasFlag("bounds") && debugBounds!=null )
			disableDebugBounds();
		#end

    }

	/**
		Post-update loop, which is guaranteed to happen AFTER any preUpdate/update. This is usually where render and display is updated
	**/
    public function postUpdate() {
		spr.x = sprX;
		spr.y = sprY -hei*z*0.5;
        spr.scaleX = dir*sprScaleX * sprSquashX;
        spr.scaleY = sprScaleY * sprSquashY;
		spr.visible = entityVisible;

		sprSquashX += (1-sprSquashX) * M.fmin(1, 0.2*tmod);
		sprSquashY += (1-sprSquashY) * M.fmin(1, 0.2*tmod);

		// Color adds
		spr.colorAdd.load(baseColor);

		// Debug label
		if( debugLabel!=null ) {
			debugLabel.x = Std.int(attachX - debugLabel.textWidth*0.5);
			debugLabel.y = Std.int(attachY+1);
		}

		// Debug bounds
		if( debugBounds!=null ) {
			if( invalidateDebugBounds ) {
				invalidateDebugBounds = false;
				renderDebugBounds();
			}
			debugBounds.x = Std.int(attachX);
			debugBounds.y = Std.int(attachY);
		}
	}

	/**
		Loop that runs at the absolute end of the frame
	**/
	public function finalUpdate() {
		prevFrameAttachX = attachX;
		prevFrameAttachY = attachY;
	}


	final function updateLastFixedUpdatePos() {
		lastFixedUpdateX = attachX;
		lastFixedUpdateY = attachY;
	}

	/** Called at the beginning of each X movement step **/
	function onPreStepX() {
	}

	/** Called at the beginning of each Y movement step **/
	function onPreStepY() {
	}

	/**
		Main loop, but it only runs at a "guaranteed" 30 fps (so it might not be called during some frames, if the app runs at 60fps). This is usually where most gameplay elements affecting physics should occur, to ensure these will not depend on FPS at all.
	**/
	public function fixedUpdate() {
		updateLastFixedUpdatePos();
		z = level.getZValue(cx,cy);
	}

	/**
		Main loop running at full FPS (ie. always happen once on every frames, after preUpdate and before  postUpdate)
	**/
    public function frameUpdate() {
    }

	//these exist to be inherited
	function tryMoveLeft():Bool {return false;}
	function tryMoveRight():Bool {return false;}
	function tryMoveUp():Bool {return false;}
	function tryMoveDown():Bool {return false;}
}