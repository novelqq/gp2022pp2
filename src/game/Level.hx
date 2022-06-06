class Level extends GameProcess {
	/** Level grid-based width**/
	public var cWid(get,never) : Int; inline function get_cWid() return data.l_Level.cWid;

	/** Level grid-based height **/
	public var cHei(get,never) : Int; inline function get_cHei() return data.l_Level.cHei;

	/** Level pixel width**/
	public var pxWid(get,never) : Int; inline function get_pxWid() return cWid*Const.GRID;

	/** Level pixel height**/
	public var pxHei(get,never) : Int; inline function get_pxHei() return cHei*Const.GRID;

	public var data : World_Level;
	var tilesetSource : h2d.Tile;
	var tiles : Array<h2d.Tile>;

	public var marks : tools.MarkerMap<Types.LevelMark>;
	var invalidated = true;

	var intGrid : Array<Array<Int>>;

	public function new(ldtkLevel:World.World_Level) {
		super();
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		data = ldtkLevel;
		tilesetSource = hxd.Res.levels.TestTiles.toTile();
		marks = new MarkerMap(cWid, cHei);

		//initializes intgrid
		// for (x in 0 ... cWid) {
		// 	for (y in 0 ... cHei) {
		// 		intGrid[x][y] = !isValid(x,y) ? 0 : data.l_Level.getInt(x,y)-1;
		// 	}
		// }

		tiles = [
			for (x in 0 ... Std.int(tilesetSource.width/Const.GRID)) 
			for (y in 0 ... Std.int(tilesetSource.height/Const.GRID))
			tilesetSource.sub(x*Const.GRID, y*Const.GRID, Const.GRID, Const.GRID)
			];
	}

	override function onDispose() {
		super.onDispose();
		data = null;
		tilesetSource = null;
		marks.dispose();
		marks = null;
	}

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx,cy) return cx + cy*cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}

	/** Return TRUE if "Ground" layer does not contain ground **/
	public inline function hasCollision(cx,cy) : Bool {
		return getZValue(cx,cy) == 0;
	}

	public inline function getZValue(cx,cy): Int {
		return !isValid(cx,cy) ? 0 : data.l_Level.getInt(cx,cy)-1;
		// return !isValid(cx,cy) ? 0 : intGrid[cx][cy];
	}

	/** Render current level**/
	function render() {

		root.removeChildren();

		for (y in 0 ... cHei) {
			var yGroup = new h2d.TileGroup(tilesetSource);
			for (x in 0 ... cWid) {
				var z = getZValue(x,y);
				var up = getZValue(x,y-1);
				var down = getZValue(x,y+1);
				var left = getZValue(x-1,y);
				var right = getZValue(x+1,y);
				if (z == 0) {
					//Add void tile to ygroup
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[24]);
				} else 	if (z == left && z == right && z == up && z == down) {
					//Add center tile to ygroup
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[6]);
				} else if (z != left && z == right && z == up && z == down) {
					//Add left tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[1]);
				} else if (z == left && z != right && z == up && z == down) {
					//Add right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[11]);
				} else if (z == left && z == right && z != up && z == down) {
					//Add top tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[5]);
				} else if (z == left && z == right && z == up && z != down) {
					//Add bottom tile
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[9]);
					}
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[7]);
				} else if (z != left && z == right && z != up && z == down) {
					//Add top-left tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[0]);
				} else if (z != left && z == right && z == up && z != down) {
					//Add bottom-left tile
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[4]);
					}
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[2]);
				} else if (z == left && z != right && z != up && z == down) {
					//Add top-right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[10]);
				} else if (z == left && z != right && z == up && z != down) {
					//Add bottom-right tile
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[14]);
					}
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[12]);
				} else if (z != left && z != right && z == up && z == down) {
					//Add left-right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[16]);
				} else if (z == left && z == right && z != up && z != down) {
					//Add top-bottom tile
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[9]);
					}
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[8]);
				} else if (z != left && z != right && z != up && z == down) {
					//Add top-left-right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[15]);
				} else if (z != left && z != right && z == up && z != down) {
					//Add bottom-left-right tile
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[19]);
					}
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[17]);
				} else if (z != left && z == right && z != up && z != down) {
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[4]);
					}
					//Add top-bottom-left tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[3]);
				} else if (z == left && z != right && z != up && z != down) {
					for (wallHeight in 0...z) {
						yGroup.add(x*Const.GRID, (y-wallHeight/2)*Const.GRID, tiles[14]);
					}
					//Add top-bottom-right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[13]);
				} else if (z != left && z != right && z != up && z != down) {
					//Add top-bottom-left-right tile
					yGroup.add(x*Const.GRID, (y-z/2)*Const.GRID, tiles[18]);
				}
			}
			root.add(yGroup, y, -1);
		}
		sortLayers();



		
		// var tg = new h2d.TileGroup(tilesetSource, root);

		// data.l_Level.render(tg);
		// data.l_Height1.render(tg);
		// data.l_Height2.render(tg);
		// data.l_Height3.render(tg);
	}

	public function sortLayers() {
		for (layer in 0 ... cHei) {
			root.ysort(layer);
		}
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}