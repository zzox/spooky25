package game.world;

import core.Types.Dir;
import core.Types.IntVec2;

enum ActorState {
    Wait; // also move
    Prespell;
    Spell;
}

enum ActorBehavior {
    Aggro;
    // Heart;
}

class Actor {
    public var x:Int;
    public var y:Int;

    public var maxHealth:Int = 100;
    public var health:Int = 100;

    public var isPlayer:Bool = false;
    // public var isEnemy:Bool = false;

    // non-player stuff
    public var state:ActorState = Wait;
    public var stateTime:Int;
    public var behavior:ActorBehavior = Aggro;

    public var facing:Dir = Down;

    // just for show, should be limited to a length of 5
    public var path:Null<Array<IntVec2>>;

    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

    function get_isAlive () {
        return this.health > 0;
    }
}
