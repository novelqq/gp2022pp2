package sample;

class SampleBox extends Entity {
	var move_frames: Int = 4;
	var manual_float_error = 1e-10;

	var temp_dx = 0.;
	var temp_dy = 0.;

    public function new(x, y) {
		super(5,5);

        setPosCase(x,y);
        makeSprite();
	}

    // Placeholder display
    function makeSprite() {
		var b = new h2d.Graphics(spr);
		b.beginFill(0xff00ff);
		b.drawRect(-hei*0.5,-wid*0.5,hei,wid);
	}

    override function dispose() {
		super.dispose();
	}

    override function tryMoveLeft() {
        if (level.hasCollision(cx-1, cy)) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx-1 && entity.cy == cy && !entity.tryMoveLeft()) {
                return false;
            }
        }
        temp_dx = -1/move_frames;
        return true;
    }

    override function tryMoveRight() {
        if (level.hasCollision(cx+1, cy)) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx+1 && entity.cy == cy && !entity.tryMoveRight()) {
                return false;
            }
        }
        temp_dx = 1/move_frames;
        return true;
    }

    override function tryMoveUp() {
        if (level.hasCollision(cx, cy-1)) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx && entity.cy == cy-1 && !entity.tryMoveUp()) {
                return false;
            }
        }
        temp_dy = -1/move_frames;
        return true;
    }

    override function tryMoveDown() {
        if (level.hasCollision(cx, cy+1)) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx && entity.cy == cy+1 && !entity.tryMoveDown()) {
                return false;
            }
        }
        temp_dy = 1/move_frames;
        return true;
    }

    function resetInput() {
        xr = yr = 0.5;
		temp_dx = temp_dy = 0.;
    }

    override function fixedUpdate() {
		
        xr += temp_dx;
		yr += temp_dy;
		while (xr > 1) {cx++; xr--;}
		while (xr < 0) {cx--; xr++;}
		while (yr > 1) {cy++; yr--;}
		while (yr < 0) {cy--; yr++;}
		if (Math.abs(xr - 0.5) < manual_float_error && Math.abs(yr - 0.5) < manual_float_error) {
			resetInput();
		}

        super.fixedUpdate();
	}
}