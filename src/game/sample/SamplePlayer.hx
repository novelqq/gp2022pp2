package sample;

/**
	SamplePlayer is an Entity with some extra functionalities:
	- falls with gravity
	- has basic level collisions
	- controllable (using gamepad or keyboard)
	- some squash animations, because it's cheap and they do the job
**/

class SamplePlayer extends SampleBox {
	var ca : ControllerAccess<GameAction>;
	var move_right : Bool = false;
	var move_left : Bool = false;
	var move_up : Bool = false;
	var move_down: Bool = false;
	public static var cooldown_frames: Int = 0;
	var is_moving: Bool = false;

	public function new() {
		// Start point using level entity "PlayerStart"
		var start = level.data.l_Entities.all_PlayerStart[0];
		if( start!=null ) {
			super(start.cx,start.cy);
		} else {
			super(0,0);
		}
		
		// Camera tracks this
		camera.trackEntity(this, true);
		camera.clampToLevelBounds = true;

		// Init controller
		ca = App.ME.controller.createAccess();
		ca.lockCondition = Game.isGameControllerLocked;		
	}

	// Placeholder display
	override function makeSprite() {
		var g = new h2d.Graphics(spr);
		g.beginFill(0x00ff00);
		g.drawCircle(0,0,8);
	}

	override function dispose() {
		super.dispose();
		ca.dispose(); // don't forget to dispose controller accesses
	}

	override function resetInput() {
		super.resetInput();
		cooldown_frames = 2;
		is_moving = false;
		move_left = move_right = move_up = move_down = false;
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
		if (cooldown_frames == 0 && !is_moving) {
			if (move_left && tryMoveLeft() || move_right && tryMoveRight() || move_up && tryMoveUp() || move_down && tryMoveDown()) {
				is_moving = true;
			}
		}
		if (is_moving || isFalling) {
			super.fixedUpdate();
		} else if (cooldown_frames > 0) {
			cooldown_frames -= 1;
		}
	}
}