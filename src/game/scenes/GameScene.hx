package game.scenes;

import core.Game;
import core.Types;
import core.scene.Scene;
import game.world.World;
import kha.Assets;
import kha.graphics2.Graphics;
import kha.input.KeyCode;

class GameScene extends Scene {
    var world:World;

    override function create () {
        super.create();
        camera.bgColor = 0xff222034;

        world = new World();
    }

    override function update (delta:Float) {
        if (Game.keys.justPressed(KeyCode.Left)) {
            world.tryMovePlayer(Dir.Left);
        }
        if (Game.keys.justPressed(KeyCode.Right)) {
            world.tryMovePlayer(Dir.Right);
        }
        if (Game.keys.justPressed(KeyCode.Up)) {
            world.tryMovePlayer(Dir.Up);
        }
        if (Game.keys.justPressed(KeyCode.Down)) {
            world.tryMovePlayer(Dir.Down);
        }

        world.step();

        super.update(delta);

        // TODO: remove
        if (Game.keys.justPressed(KeyCode.R)) {
            game.changeScene(new GameScene());
        }
    }

    final leftEdge = 64;

    override function render (g2:Graphics, clears:Bool) {
        g2.begin(true, camera.bgColor);

        // g2.color = Math.floor(alpha * 256) * 0x1000000 + color;
        g2.color = 256 * 0x1000000 + 0xffffffff;

        final image = Assets.images.spook25sprites;

        for (actor in world.actors) {
            final tileIndex = actor.isPlayer ? 32 : 48;

            g2.drawSubImage(
                image,
                leftEdge + 1 + actor.x * 17, 1 + actor.y * 17,
                (tileIndex * 16) % image.width, Math.floor(tileIndex / 16) * 16,
                16, 16
            );
        }

        g2.end();
    }
}
