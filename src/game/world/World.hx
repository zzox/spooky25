package game.world;

import core.Types;
import game.world.Grid;

enum GridItem {
    None;
    Wall;
}

typedef Element = {
//   var type:SpellType;
  var x:Int;
  var y:Int;
  var time:Int;
  var from:Actor;
  var path:Array<IntVec2>;
  var damaged:Array<Actor>;
}

class World {
    public var grid:Grid<GridItem>;
    public var actors:Array<Actor> = [];

    public var player:Actor;

    public function new () {
        grid = makeGrid(15, 15, None);

        player = new Actor(7, 7);
        player.isPlayer = true;

        actors.push(player);
    }

    public function step () {
        for (a in actors) updateActor(a);
    }

    function updateActor (actor:Actor) {
        actor.stateTime--;
        if (actor.stateTime > 0) return;

        if (actor.state == Spell) {
            actor.state = Wait;
        }

        if (actor.state == Prespell) {
            doSpell(actor);
        }

        if (actor.isPlayer) {
            updatePlayer(actor);
            return;
        }

        // TODO: target can by enemies when we have teammates
        final targets = getPlayers();

        if (actor.state != Wait) return;

        if (actor.behavior == Aggro) {
            tryAggro(actor, targets);
        } else {
            throw 'No behavior';
        }
    }

    inline function updatePlayer (player:Actor) {
        if (player.state == Wait) {
            // player.stateTime--;
        }
    }

    function tryAggro (actor:Actor, targets:Array<Actor>) {}

    function trySpell (actor:Actor) {}
    function doSpell (actor:Actor) {}

    public function tryMovePlayer (dir:Dir) {
        var xPos = player.x;
        var yPos = player.y;

        switch (dir) {
            case Left: xPos--;
            case Right: xPos++;
            case Up: yPos--;
            case Down: yPos++;
        }

        final gi = getGridItem(grid, xPos, yPos);

        if (gi != null && gi == None) {
            player.x = xPos;
            player.y = yPos;
        }
    }

    function getEnemies ():Array<Actor> {
        return actors.filter(a -> !a.isPlayer);
    }

    function getPlayers ():Array<Actor> {
        return [player];
    }
}
