package core.util;

import core.Types;
import kha.Assets;
import kha.Image;

typedef TiledImage = {
    var source:String;
    var x:Int;
    var y:Int;
    var width:Int;
    var height:Int;
}

typedef TiledObject = {
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
    var properties:Map<String, String>;
}

typedef TileLayer = {
    var width:Int;
    var height:Int;
    var data:Array<Int>;
}
function replaceDashes (string:String):String {
    var s = '';
    for (c in string.split('')) {
        s += c == '-' ? '_' : c;
    }
    return s;
}
function getImagefromPath (imagePath:String):Image {
    final path = imagePath.split('/');
    final name = path[path.length - 1].split('.')[0];
    return Assets.images.get(replaceDashes(name));
}

/**
    Tiled Map parser. WIP.
**/
class TiledMap {
    // The size of this map in tiles.
    public var size:IntVec2;
    // Size of the tiles.
    public var tileSize:IntVec2;
    // Size of this map in pixels.
    public var pixelSize:IntVec2;
    // Map of tile layers.
    public var tileLayers:Map<String, TileLayer> = [];
    // Map of object groups.
    public var objectGroups:Map<String, Array<TiledObject>> = [];
    // Map of images.
    public var images:Map<String, TiledImage> = [];

    public function new (blobString:String) {
        final xml = Xml.parse(blobString).firstElement();

        tileSize = new IntVec2(
            Std.parseInt(xml.get('tilewidth')),
            Std.parseInt(xml.get('tileheight'))
        );

        size = new IntVec2(
            Std.parseInt(xml.get('width')),
            Std.parseInt(xml.get('height'))
        );

        pixelSize = new IntVec2(size.x * tileSize.x, size.y * tileSize.y);

        for (tileLayer in xml.elementsNamed('layer')) {
            tileLayers.set(tileLayer.get('name'), {
                data: tileLayer.firstElement().firstChild().toString().split(',').map((item) -> Std.parseInt(item)),
                width: Std.parseInt(tileLayer.get('width')),
                height: Std.parseInt(tileLayer.get('height'))
            });
        }

        for (objGroup in xml.elementsNamed('objectgroup')) {
            final objects = [];

            for (object in objGroup.elementsNamed('object')) {
                final properties = new Map();
                for (props in object.elementsNamed('properties')) {
                    for (p in props.elementsNamed('property')) {
                        properties.set(p.get('name'), p.get('value'));
                    }
                }

                objects.push({
                    x: Std.parseFloat(object.get('x')),
                    y: Std.parseFloat(object.get('y')),
                    width: Std.parseFloat(object.get('width')),
                    height: Std.parseFloat(object.get('height')),
                    properties: properties
                });
            }

            objectGroups.set(objGroup.get('name'), objects);
        }

        for (imageLayer in xml.elementsNamed('imagelayer')) {
            final item = imageLayer.firstElement();
            images.set(imageLayer.get('name'), {
                source: item.get('source'),
                x: Std.parseInt(imageLayer.get('offsetx')),
                y: Std.parseInt(imageLayer.get('offsety')),
                width: Std.parseInt(item.get('width')),
                height: Std.parseInt(item.get('height'))
            });
        }
    }
}
