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
	var walkSpeed = 0.;
	var move_right : Bool = false;
	var move_left : Bool = false;
	var move_up : Bool = false;
	var move_down: Bool = false;
	var cooldown_frames: Int = 0;
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
		frictY = 0.94;

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
		if( yr>1 && level.hasCollision(cx,cy+1) ) {
			setSquashY(0.5);
			dy = 0;
			yr = 1;
			ca.rumble(0.2, 0.06);
			onPosManuallyChangedY();
		}

		// Ceiling collision
		if( yr<0.2 && level.hasCollision(cx,cy-1) )
			yr = 0.2;
	}

	private function resetInput() {
		move_left = false;
		move_right = false;
		move_up = false;
		move_down = false;
		cooldown_frames = 5;
	}
	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;
		if( onGround )
			cd.setS("recentlyOnGround",0.1); // allows "just-in-time" jumps

		// Walk
		move_left = ca.isDown(MoveLeft);
		move_right = ca.isDown(MoveRight);
		move_up = ca.isDown(MoveUp);
		move_down = ca.isDown(MoveDown);
	}


	override function fixedUpdate() {
		super.fixedUpdate();

		// Apply requested walk movement
		if(cooldown_frames == 0) {
			if(move_right){
				if (!level.hasCollision(cx+1, cy)){
					cx += 1;
				}
				resetInput();
			}
			if(move_left){
				if (!level.hasCollision(cx-1, cy)){
					cx -= 1;
				}
				resetInput();
			}
			if(move_down){
				if (!level.hasCollision(cx, cy+1)){
					cy += 1;
				}
				resetInput();
			}
			if(move_up){
				if (!level.hasCollision(cx, cy-1)){
					cy -= 1;
				}
				resetInput();
			}
		}
		else {
			cooldown_frames -= 1;
		}
		//dx += walkSpeed * speed;
	}
}