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
		new SamplePlayer();
		new SampleBox(l.l_Entities.all_Box[0].cx, l.l_Entities.all_Box[0].cy);
		new SampleBox(l.l_Entities.all_Box[1].cx, l.l_Entities.all_Box[1].cy);
		// for (i in 0...1) {
		// 	var start = l.l_Entities.all_Box[i];
		// 	new SampleBox(start.cx, start.cy);
		// }
	}
}

