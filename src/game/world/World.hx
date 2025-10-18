package game.world;

import game.world.Grid;

enum GridItem{
    None;
    Wall;
}

class Actor {
    public var x:Int;
    public var y:Int;

    public function new (x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }
}

class World {
    public var grid:Grid<GridItem>;
    public var actors:Array<Actor> = [];

    public var player:Actor;

    public function new () {
        grid = makeGrid(15, 15, None);

        player = new Actor(7, 7);

        actors.push(player);
    }
}
