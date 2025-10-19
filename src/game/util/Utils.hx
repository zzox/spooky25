package game.util;

import core.util.Util;
import game.world.Actor;

function findNearest (x:Int, y:Int, actors:Array<Actor>):Null<Actor> {
  var nearest = null;
  // WARN:
  var nearestDist = 1000.0;
  for (a in actors) {
    final distance = distanceBetween(a.x, a.y, x, y);
    if (distance < nearestDist) {
      nearest = a;
      nearestDist = distance;
    }
  }

  return nearest;
}
