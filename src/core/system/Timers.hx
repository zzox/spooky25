package core.system;

function noop () {}

class Timers {
    var items:Array<Timer> = [];

    public function new () {}

    public function update (delta:Float) {
        for (timer in items) {
            timer.elapsed += delta;
            if (timer.elapsed >= timer.time) {
                timer.callback();
                timer.destroyed = true;
            }
        }

        items = items.filter((item) -> !item.destroyed);
    }

    public function addTimer (time:Float, callback:Void -> Void) {
        items.push(new Timer(time, callback));
    }

    public function destroy () {
        for (timer in items) {
            timer.destroy();
        }
    }
}

class Timer {
    public var destroyed:Bool = false;
    public var time:Float;
    public var elapsed:Float = 0.0;
    public var callback:Void -> Void;

    public function new (time:Float, callback:Void -> Void) {
        this.time = time;
        this.callback = callback;
    }

    public function destroy () {
        destroyed = true;
        callback = noop;
    }
}
