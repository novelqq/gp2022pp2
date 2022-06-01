package sample;

/**
	This small class just creates a SamplePlayer instance in current level
**/
class SampleGame extends Game {
	public function new() {
		super();
	}

	override function startLevel(l:World_Level) {
		super.startLevel(l);
		for (startloc in level.data.l_Entities.all_Box) {
			new SampleBox(startloc.cx, startloc.cy);
		}
		new SamplePlayer();
	}
}

