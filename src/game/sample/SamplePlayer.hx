package sample;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends Entity {
	var ca : ControllerAccess<GameAction>;
	var speed = 0.045;
	var climbSpeed = 0.;
	var walkSpeed = 0.;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
		inline function get_onGround() return !destroyed && dy==0 && yr==1 && level.hasCollision(cx,cy+1);


	public function new() {
		super(5,5);

		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null )
			setPosCase(start.cx, start.cy);

		// Misc inits
		frictX = 0.84;
		frictY = 0.84;

		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;

		// Placeholder display
		var g = new h2d.Graphics(spr);
		g.beginFill(0x00ff00);
		g.drawCircle(0,-hei*0.5,9);
	}


	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();

		// Right collision
		if( xr>0.8 && level.hasCollision(cx+1,cy) )
			xr = 0.8;

		// Left collision
		if( xr<0.2 && level.hasCollision(cx-1,cy) )
			xr = 0.2;
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();

		// Land on ground
		if( yr>0.8 && level.hasCollision(cx,cy+1) ) {
			yr = 0.8;
		}

		// Ceiling collision
		if( yr<0.2 && level.hasCollision(cx,cy-1) )
			yr = 0.2;
	}


	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;
		climbSpeed = 0;

		// Walk
		if( ca.getAnalogDist2(MoveLeft,MoveRight)>0 ) {
			// As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			walkSpeed = ca.getAnalogValue2(MoveLeft,MoveRight); // -1 to 1
		}

		// Climb
		if(ca.getAnalogDist2(MoveUp,MoveDown)>0 ) {
			climbSpeed = ca.getAnalogValue2(MoveUp,MoveDown);
		}
	}


	override function fixedUpdate() {
		super.fixedUpdate();

		// Apply requested walk movement
		if( walkSpeed!=0 ) {
			dx += walkSpeed * speed;
		}
		if( climbSpeed!=0) {
			dy += climbSpeed * speed;
		}
	}
}