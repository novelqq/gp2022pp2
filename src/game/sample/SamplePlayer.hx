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
	var speed = 0.;
	var move_right : Bool = false;
	var move_left : Bool = false;
	var move_up : Bool = false;
	var move_down: Bool = false;
	var is_moving = false;
	var move_frames = 4;
	var cooldown_frames: Int = 0;

	public function new() {
		super(5,5);

		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null )
			setPosCase(start.cx, start.cy);

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
			yr = 1;
		}

		// Ceiling collision
		if( yr<0.2 && level.hasCollision(cx,cy-1) )
			yr = 0.2;
	}

	private function resetInput() {
		move_left = move_right = move_up = move_down = false;
		cooldown_frames = 5;
		dx = dy = 0;
	}
	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		walkSpeed = 0;

		// Walk
		if (!is_moving) {
			move_left = ca.isDown(MoveLeft);
			move_right = ca.isDown(MoveRight);
			move_up = ca.isDown(MoveUp);
			move_down = ca.isDown(MoveDown);
		}
		
		if (!is_moving && (move_left || move_right || move_up || move_down)) {
			is_moving = true;
			dx -= move_left ? 1/move_frames : 0;
			dx += move_right ? 1/move_frames : 0;
			dy -= move_up ? 1/move_frames : 0;
			dy += move_down ? 1/move_frames : 0;
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