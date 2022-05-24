class Level extends GameProcess {
	/** Level grid-based width**/
	public var cWid(get,never) : Int; inline function get_cWid() return data.l_Ground.cWid;

	/** Level grid-based height **/
	public var cHei(get,never) : Int; inline function get_cHei() return data.l_Ground.cHei;

	/** Level pixel width**/
	public var pxWid(get,never) : Int; inline function get_pxWid() return cWid*Const.GRID;

	/** Level pixel height**/
	public var pxHei(get,never) : Int; inline function get_pxHei() return cHei*Const.GRID;

	public var data : World_Level;
	var tilesetSource : h2d.Tile;

	public var marks : tools.MarkerMap<Types.LevelMark>;
	var invalidated = true;

	public function new(ldtkLevel:World.World_Level) {
		super();

		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		data = ldtkLevel;
		tilesetSource = hxd.Res.levels.MasterSimple.toTile();
		marks = new MarkerMap(cWid, cHei);
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
		return !isValid(cx,cy) ? true : !(data.l_Ground.getInt(cx,cy)==1);
	}

	/** Render current level**/
	function render() {

		root.removeChildren();
		var tg = new h2d.TileGroup(tilesetSource, root);

		//TODO: De-jankify this
		var layer1 = data.l_Ground;
		var layer2 = data.l_Trees;
		var layer3 = data.l_Walls;
		//var layer4 = data.l_Grass;
		for( autoTile in layer1.autoTiles ) {
			var tile = layer1.tileset.getAutoLayerTile(autoTile);
			tg.add(autoTile.renderX, autoTile.renderY, tile);
		}
		for( autoTile in layer2.autoTiles ) {
			var tile = layer2.tileset.getAutoLayerTile(autoTile);
			tg.add(autoTile.renderX, autoTile.renderY, tile);
		}
		for( autoTile in layer3.autoTiles ) {
			var tile = layer3.tileset.getAutoLayerTile(autoTile);
			tg.add(autoTile.renderX, autoTile.renderY, tile);
		}
		
		// for (gridTile in layer4.gridTiles) {
		// 	var tile = layer4.tileset.get;
		// 	tg.add(gridTile.renderX, gridTile.renderY, tile);
		// }
		// layer1.render(tg);
		// layer3.render(tg);
		//layer4.render(tg);

	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}