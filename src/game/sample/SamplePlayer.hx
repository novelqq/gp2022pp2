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
	var move_right : Bool = false;
	var move_left : Bool = false;
	var move_up : Bool = false;
	var move_down: Bool = false;
	var cooldown_frames: Int = 0;
	var is_moving: Bool = false;
	var move_frames: Int = 4;
	var manual_float_error = 1e-10;

	var temp_dx = 0.;
	var temp_dy = 0.;

	public function new() {
		super(5,5);

		// Start point using level entity "Player"
		var start = level.data.l_Entities.all_Player[0];
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
		g.drawCircle(0,0,8);
	}


	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}


	/** X collisions **/
	override function onPreStepX() {
		super.onPreStepX();
	}


	/** Y collisions **/
	override function onPreStepY() {
		super.onPreStepY();
	}

	private inline function resetInput() {
		move_left = move_right = move_up = move_down = false;
		cooldown_frames = 2;
		temp_dx = temp_dy = 0;
		is_moving = false;
	}
	/**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	override function preUpdate() {
		super.preUpdate();

		// Walk
		if (!is_moving) {
			move_left = ca.isDown(MoveLeft);
			move_right = ca.isDown(MoveRight);
			move_up = ca.isDown(MoveUp);
			move_down = ca.isDown(MoveDown);
			if (move_left && move_right) {
				move_left = move_right = false;
			}
			if (move_up && move_down) {
				move_up = move_down = false;
			}
			if ((move_left || move_right) && (move_up || move_down)) {
				move_left = move_right = move_up = move_down = false;
			}
		}
		
		
	}


	override function fixedUpdate() {
		super.fixedUpdate();

		//collisions and pushing logic here, probably need to refactor later
		//TODO: write "try_move_left" method that recursively tries to push each block to the left.
		if (cooldown_frames == 0 && !is_moving) {
			if (move_left && !level.hasCollision(cx-1, cy)) {
				temp_dx = -1/move_frames;
				is_moving = true;
			} else if (move_right && !level.hasCollision(cx+1,cy)) {
				temp_dx = 1/move_frames;
				is_moving = true;
			} else if (move_up && !level.hasCollision(cx, cy-1)) {
				temp_dy = -1/move_frames;
				is_moving = true;
			} else if (move_down && !level.hasCollision(cx, cy+1)) {
				temp_dy = 1/move_frames;
				is_moving = true;
			}
		}

		if (is_moving) {
			xr += temp_dx;
			yr += temp_dy;
			while (xr > 1) {cx++; xr--;}
			while (xr < 0) {cx--; xr++;}
			while (yr > 1) {cy++; yr--;}
			while (yr < 0) {cy--; yr++;}
			if (Math.abs(xr - 0.5) < manual_float_error && Math.abs(yr - 0.5) < manual_float_error) {
				xr = yr = 0.5;
				resetInput();
			}
		} else if (cooldown_frames > 0) {
			cooldown_frames -= 1;
		}
	}
}