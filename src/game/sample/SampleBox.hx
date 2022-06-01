package sample;

class SampleBox extends Entity {
	var move_frames: Int = 4;
	var manual_float_error = 1e-10;

    var isFalling: Bool = false;

	var temp_dx = 0.;
	var temp_dy = 0.;

    public function new(x, y) {
		super(5,5);

        setPosCase(x,y);
        makeSprite();
	}

    // Placeholder display
    function makeSprite() {
        var boxTile = hxd.Res.levels.box.toTile();
		var b = new h2d.Graphics(spr);
		b.beginTileFill(boxTile.width, boxTile.height, 1, 1, boxTile);
		b.drawTile(-wid*0.5,-hei, boxTile);
	}

    override function dispose() {
		super.dispose();
	}

    //recursively try to push boxes, returning false if unable to be pushed (hits a wall)
    //returns true and initializes velocity if able to be pushed
    override function tryMoveLeft() {
        if (level.hasCollision(cx-1, cy) || level.getZValue(cx-1, cy) > z) {
            return false;
        }
        for (entity in Entity.ALL) {
            //checks if a box is to the left, and if so, if it can move or not
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx-1 && entity.cy == cy && entity.z == z && !entity.tryMoveLeft()) {
                return false;
            }
        }
        temp_dx = -1/move_frames;
        return true;
    }

    override function tryMoveRight() {
        if (level.hasCollision(cx+1, cy) || level.getZValue(cx+1, cy) > z) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx+1 && entity.cy == cy && entity.z == z && !entity.tryMoveRight()) {
                return false;
            }
        }
        temp_dx = 1/move_frames;
        return true;
    }

    override function tryMoveUp() {
        if (level.hasCollision(cx, cy-1) || level.getZValue(cx, cy-1) > z) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx && entity.cy == cy-1 && entity.z == z && !entity.tryMoveUp()) {
                return false;
            }
        }
        temp_dy = -1/move_frames;
        return true;
    }

    override function tryMoveDown() {
        if (level.hasCollision(cx, cy+1) || level.getZValue(cx, cy+1) > z) {
            return false;
        }
        for (entity in Entity.ALL) {
            if (Std.isOfType(entity, SampleBox) && entity.cx == cx && entity.cy == cy+1 && entity.z == z && !entity.tryMoveDown()) {
                return false;
            }
        }
        temp_dy = 1/move_frames;
        return true;
    }

    function resetInput() {
        xr = yr = 0.5;
		temp_dx = temp_dy = 0.;
        isFalling = true;
    }

    override function fixedUpdate() {
		
        //update position with velocities
        xr += temp_dx;
		yr += temp_dy;
		while (xr > 1) {cx++; xr--;}
		while (xr < 0) {cx--; xr++;}
		while (yr > 1) {cy++; yr--;}
		while (yr < 0) {cy--; yr++;}

        //if grid aligned (which happens when not moving and at the end of movement), reset input
		if (Math.abs(xr - 0.5) < manual_float_error && Math.abs(yr - 0.5) < manual_float_error) {
			resetInput();
		}

        //while not in motion, checks if there is a level or box under the entity, otherwise decrements z until there is
        while(isFalling) {
            if (level.getZValue(cx,cy) == z) {
                isFalling = false;
            }
            for (entity in Entity.ALL) {
                if (Std.isOfType(entity, SampleBox) && entity.cx == cx && entity.cy == cy && entity.z == z-1) {
                    isFalling = false;
                }
            }
            if (isFalling) {
                z--;
            }
        }

        super.fixedUpdate();
	}
}