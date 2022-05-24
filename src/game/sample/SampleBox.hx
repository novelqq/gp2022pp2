package sample;

class SampleBox extends Entity {
	var move_frames: Int = 4;
	var manual_float_error = 1e-10;

    //temporary measures
    public static var nextBox : SampleBox = null;

	var temp_dx = 0.;
	var temp_dy = 0.;

    public function new(x, y) {
		super(5,5);

        setPosCase(x,y);

		// Placeholder display
		var b = new h2d.Graphics(spr);
		b.beginFill(0xff00ff);
		b.drawRect(-hei*0.5,-wid*0.5,hei,wid);
	}

    override function dispose() {
		super.dispose();
	}

	override function onPreStepX() {
		super.onPreStepX();
	}

	override function onPreStepY() {
		super.onPreStepY();
	}

    function tryMoveLeft() {
        if (level.hasCollision(cx-1, cy)) {
            return false;
        }
        // TODO: check for more boxes recursively
        if (false ) {
            if(nextBox.tryMoveLeft()) {
                dx = -1/move_frames;
                return true;
            }
            return false;
        }
        dx = -1/move_frames;
        return true;
    }

    function tryMoveRight() {
        if (level.hasCollision(cx+1, cy)) {
            return false;
        }
        // TODO: check for more boxes recursively
        if (false ) {
            if(nextBox.tryMoveRight()) {
                dx = 1/move_frames;
                return true;
            }
            return false;
        }
        dx = 1/move_frames;
        return true;
    }

    function tryMoveUp() {
        if (level.hasCollision(cx, cy-1)) {
            return false;
        }
        // TODO: check for more boxes recursively
        if (false ) {
            if(nextBox.tryMoveUp()) {
                dy = -1/move_frames;
                return true;
            }
            return false;
        }
        dy = -1/move_frames;
        return true;
    }

    function tryMoveDown() {
        if (level.hasCollision(cx, cy+1)) {
            return false;
        }
        // TODO: check for more boxes recursively
        if (false ) {
            if(nextBox.tryMoveLeft()) {
                dy = 1/move_frames;
                return true;
            }
            return false;
        }
        dy = 1/move_frames;
        return true;
    }

    override function fixedUpdate() {
		super.fixedUpdate();

        xr += temp_dx;
		yr += temp_dy;
		while (xr > 1) {cx++; xr--;}
		while (xr < 0) {cx--; xr++;}
		while (yr > 1) {cy++; yr--;}
		while (yr < 0) {cy--; yr++;}
		if (Math.abs(xr - 0.5) < manual_float_error && Math.abs(yr - 0.5) < manual_float_error) {
			xr = yr = 0.5;
			dx = dy = 0.;
		}

	}
}