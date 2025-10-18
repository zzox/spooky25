package game.world;

typedef Grid<T> = {
    var width:Int;
    var height:Int;
    var items:Array<T>;
}

function makeGrid<T> (width:Int, height:Int, initialValue:T):Grid<T> {
    return {
        width: width,
        height: height,
        items: [for (i in 0...(width * height)) initialValue],
    }
}

function forEachGI<T> (grid:Grid<T>, callback:(x:Int, y:Int, item:T) -> Void) {
    for (x in 0...grid.width) {
        for (y in 0...grid.height) {
            callback(x, y, grid.items[x + y * grid.width]);
        }
    }
}

function mapGIItems<T, TT> (grid:Grid<T>, callback:(x:Int, y:Int, item:T) -> TT):Array<TT> {
    // don't know about this as it requires a cast
    // if (callback == null) {
    //     callback = (x:Int, y:Int, item:T) -> { return cast(item); };
    // }

    final items = [];
    for (x in 0...grid.width) {
        for (y in 0...grid.height) {
            items.push(callback(x, y, grid.items[x + y * grid.width]));
        }
    }
    return items;
}

function getGridItem<T> (grid:Grid<T>, x:Int, y:Int):Null<T> {
    if (x < 0 || y < 0 || x >= grid.width || y >= grid.height) {
        return null;
    }

    return grid.items[x + y * grid.width];
}
