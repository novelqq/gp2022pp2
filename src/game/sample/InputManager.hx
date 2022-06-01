package sample;

import js.html.InputEvent;

class InputManager {
    var ca : ControllerAccess<GameAction>;

    var ents : Array<Entity>;
    public var app(get,never) : App; inline function get_app() return App.ME;
	public var game(get,never) : Game; inline function get_game() return Game.ME;
    public var level(get,never) : Level; inline function get_level() return Game.ME.level;
    

    public function new() {
        ca = App.ME.controller.createAccess();
        ca.lockCondition = Game.isGameControllerLocked;

    }
    
    public function addListener(entity:Entity) {
        ents.push(entity);
    }
    public function dispose() {
        ca.dispose();
    }

    public function preUpdate() {
        for(entity in ents) {
            entity.move_left = ca.isDown(MoveLeft);
			entity.move_right = ca.isDown(MoveRight);
			entity.move_up = ca.isDown(MoveUp);
			entity.move_down = ca.isDown(MoveDown);
        }
        //listen for input
        //delegate input to listening entities (ents array)
    }
}