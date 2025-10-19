package game.util;

import core.Types;
import game.world.Grid;

// from: http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html
typedef Heuristic = (p1: IntVec2, p2: IntVec2) -> Float;

// WARN: a static class like this needs to be safe, multiple pathfinds at once
// could cause issues. also requires us recycling these items
class Points {
    public static var index:Int = 0;
    public static var items:Array<IntVec2> = [];
    public static function getItem(x:Int, y:Int):IntVec2 {
        final item = items[index];
        if (item != null) {
            item.set(x, y);
            index++;
            return item;
        }

        index++;
        items.push(new IntVec2(x, y));
        return items[index - 1];
    }

    public static function makeItems () {}
}

function Manhattan (p1: IntVec2, p2: IntVec2): Float {
    final d1 = Math.abs(p2.x - p1.x);
    final d2 = Math.abs(p2.y - p1.y);
    return d1 + d2;
}

function Diagonal (p1: IntVec2, p2: IntVec2): Float {
    final d1 = Math.abs(p2.x - p1.x);
    final d2 = Math.abs(p2.y - p1.y);
    return d1 + d2 + ((Math.sqrt(2) - 2) * Math.min(d1, d2));
}

class PathNode {
    public var point:IntVec2;
    public var tail:Null<PathNode>;
    public var cost:Float = 0.0;
    public var h:Float = 0.0;

    public function new (point: IntVec2, ?tail: PathNode) {
        this.point = point;
        this.tail = tail;
    }
}

class Heap {
    public var nodes: Array<PathNode> = [];

    public function new () {}

    public function addNode (node: PathNode) {
        this.nodes.push(node);
        this.nodes.sort((n1, n2) -> Math.round(n1.cost + n1.h) - Math.round(n2.cost + n2.h));
        // this.nodes = this.nodes.sort((n1, n2) -> (n1.cost + n1.h) - (n2.cost + n2.h));
    }

    public function popNode (): Null<PathNode> {
        return this.nodes.shift();
    }
}

// TODO: better name, isn't exactly a hash set.
class HashSet {
    // combined x,y position -> cost
    var items:Map<Int, Float> = new Map();
    var width:Int;

    public function new (width: Int) {
        this.width = width;
    }

    public function getItem (point: IntVec2): Null<Float>  {
        return this.items.get(Std.int(point.y * this.width + point.x));
    }

    public function setItem (point: IntVec2, cost: Float) {
        this.items.set(point.y * this.width + point.x, cost);
    }
}

function checkPointsEqual (point1: IntVec2, point2: IntVec2): Bool {
    return point1.x == point2.x && point1.y == point2.y;
}

function createPathFrom (node: PathNode): Array<IntVec2> {
    final items: Array<IntVec2> = [];

    while (node.tail != null) {
        items.push(node.point);
        node = node.tail;
    }

    items.reverse();

    return items;
}

function checkCanMoveTo (grid:Grid<Int>, pointX:Int, pointY:Int, targetX:Int, targetY:Int): Bool {
    // if out of bounds or has an actor or obstacle that's not the target, return false
    final gridItem = getGridItem(grid, pointX, pointY);
    return !(
        gridItem == null ||
        // pointX < 0 || pointY < 0 || pointX >= grid.width || pointY >= grid.height ||
        !(gridItem != 0 || (pointX == targetX && pointY == targetY))
    );
}

function getNeighbors (grid:Grid<Int>, point:IntVec2, target:IntVec2, canGoDiagonal:Bool = false): Array<IntVec2> {
  final neighbors:Array<IntVec2> = [];

    // N, S, E, W
    if (checkCanMoveTo(grid, point.x, point.y - 1, target.x, target.y)) {
        neighbors.push(Points.getItem(point.x, point.y - 1));
    }
    if (checkCanMoveTo(grid, point.x, point.y + 1, target.x, target.y)) {
        neighbors.push(Points.getItem(point.x, point.y + 1));
    }
    if (checkCanMoveTo(grid, point.x + 1, point.y, target.x, target.y)) {
        neighbors.push(Points.getItem(point.x + 1, point.y));
    }
    if (checkCanMoveTo(grid, point.x - 1, point.y, target.x, target.y)) {
        neighbors.push(Points.getItem(point.x - 1, point.y));
    }

    // NE, SE, NW, SW
    if (canGoDiagonal) {
        if (checkCanMoveTo(grid, point.x + 1, point.y - 1, target.x, target.y)) {
            neighbors.push(Points.getItem(point.x + 1, point.y - 1));
        }
        if (checkCanMoveTo(grid, point.x + 1, point.y + 1, target.x, target.y)) {
            neighbors.push(Points.getItem(point.x + 1, point.y + 1));
        }
        if (checkCanMoveTo(grid, point.x - 1, point.y - 1, target.x, target.y)) {
            neighbors.push(Points.getItem(point.x - 1, point.y - 1));
        }
        if (checkCanMoveTo(grid, point.x - 1, point.y + 1, target.x, target.y)) {
            neighbors.push(Points.getItem(point.x - 1, point.y + 1));
        }
    }

  return neighbors;
}

function getMovementCost (grid:Grid<Int>, fromPoint: IntVec2, toPoint: IntVec2): Float {
  final pointCost = getGridItem(grid, fromPoint.x, fromPoint.y);

    var multi:Float = 1;
    if (fromPoint.x - toPoint.x != 0 && fromPoint.y - toPoint.y != 0) {
        multi *= Math.sqrt(2);
    }

  return pointCost * multi;
}

function pathfind (
    grid:Grid<Int>,
    startPoint:IntVec2,
    endPoint:IntVec2,
    heuristic:Heuristic,
    canGoDiagonal:Bool = false
): Null<Array<IntVec2>> {
    final startNode = new PathNode(startPoint);

    final visited = new HashSet(grid.width);

    Points.index = 0;

    // our heap of possible selections
    final heap = new Heap();
    // push node to a sorted queue of open items
    heap.addNode(startNode);

    // TEMP:
    var iterations = 0;
    while (heap.nodes.length > 0) {
        final currentNode = heap.popNode();

        if (currentNode == null) {
            throw 'Undefined node!';
        }

        // check if this start equals the end
        if (checkPointsEqual(endPoint, currentNode.point)) {
            return createPathFrom(currentNode);
        }

        final neighbors = getNeighbors(grid, currentNode.point, endPoint, canGoDiagonal);
        for (neighbor in neighbors) {
            // find cost for neighbor, include cost to this point
            final newCost = currentNode.cost + getMovementCost(grid, currentNode.point, neighbor);

            // TODO:
            // use heuristic to find estimated cost (alloted + estimate distance)

            // if the visited item exists and has a lower cost, don't do anything with this neighbor
            final visitedItem = visited.getItem(neighbor);
            if (visitedItem == null || newCost < visitedItem) {
                final newNode = new PathNode(neighbor, currentNode);
                newNode.cost = newCost;
                newNode.h = heuristic(neighbor, endPoint);
                heap.addNode(newNode);
                visited.setItem(neighbor, newCost);
            }
        };

        // safeguarding against infinite loops. may be unnecessary.
        if (++iterations > 5000) {
            trace('too many iterations');
            break;
        }
    }

    return null;
}

function clonePath (path:Array<IntVec2>):Array<IntVec2> {
    return [for (p in path) new IntVec2(p.x, p.y)];
}
