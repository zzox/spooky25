package game.world;

import core.Types;
import core.util.Util;
import game.util.Pathfind;
import game.util.Utils;
import game.world.Grid;

final SQRT2 = Math.sqrt(2);

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

        for (i in 0...6) {
            final ghost = new Actor(3 + i, 1);
            ghost.stateTime = 10;
            actors.push(ghost);
        }
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

        if (actor.state != Wait) return;

        if (actor.isPlayer) {
            updatePlayer(actor);
            return;
        }

        // TODO: target can by enemies when we have teammates
        final targets = getPlayers();

        // everyone is aggro for now
        if (actor.behavior == Aggro) {
            tryAggro(actor, targets);
        } else {
            throw 'No behavior';
        }
    }

    inline function updatePlayer (player:Actor) {
        if (player.state == Wait) {
            // TODO: get or use buffers
            // player.stateTime--;
        }
    }

    function tryAggro (actor:Actor, targets:Array<Actor>) {
        // TODO: move contents of method in here as we measure distanceBetween in `findNearest`
        final nearest = findNearest(actor.x, actor.y, targets);
        if (nearest == null) {
            throw 'No Nearest';
        }

        if (distanceBetween(actor.x, actor.y, nearest.x, nearest.y) < 1.5) {
            trySpell(actor, nearest.x, nearest.y);
        } else {
            tryMoveActor(actor, nearest.x, nearest.y);
        }
    }

    function trySpell (actor:Actor, x:Int, y:Int) {
        actor.stateTime = 60;
        actor.state = Prespell;
        // actor.attackPos = new IntVec2(x, y);
    }

    function doSpell (actor:Actor) {
        actor.stateTime = 60;
        actor.state = Spell;
    }

    function tryMoveActor (actor:Actor, targetX:Int, targetY:Int) {
        final path = pathfind(makeMap(actor), new IntVec2(actor.x, actor.y), new IntVec2(targetX, targetY), Diagonal, true);
        if (path == null) {
            throw 'No Path';
            // TODO: stateTime of 1
            // actor.bd.stateTime = 60
            // return;
        }

        final items = clonePath(path);

        final isDiagonal = actor.x != items[0].x && actor.y != items[0].y;

        actor.x = items[0].x;
        actor.y = items[0].y;

        // final time = Math.floor((256 - actor.bd.stats.Speed) / 10)
        final speed = 25;
        final time = Math.floor(348 / speed);
        actor.stateTime = isDiagonal ? Math.floor(time * SQRT2) : time;
    }

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

        final actor = actorAt(xPos, yPos);

        if (gi != null && gi == None && actor == null) {
            player.x = xPos;
            player.y = yPos;
        }
    }

    function actorAt (x:Int, y:Int):Null<Actor> {
        for (a in actors) {
            if (a.x == x && a.y == y) return a;
        }

        return null;
    }

    // pass in the actor's exception
    function makeMap (actor:Actor) {
        return {
            width: 15,
            height: 15,
            items: mapGIItems(makeGrid(15, 15, 0), (x, y, _) -> {
                final tile = getGridItem(grid, x, y);
                return tile == None && (actorAt(x, y) == null || actorAt(x, y) == actor) ? 1 : 0;
            })
        }
    }

    function getEnemies ():Array<Actor> {
        return actors.filter(a -> !a.isPlayer);
    }

    function getPlayers ():Array<Actor> {
        return [player];
    }
}
