package game.world;

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

    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

    function get_isAlive () {
        return this.health > 0;
    }
}
