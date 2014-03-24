XMoto.js
========

This project is a HTML5 Port of [XMoto](http://xmoto.tuxfamily.org/) using 2D Canvas and ([Box2DWeb](https://code.google.com/p/box2dweb/)).

[![Image](https://raw.githubusercontent.com/MichaelHoste/xmoto.js/master/image.jpg)](http://js.xmoto.io)

This is the first part of a 2-parts project :
 1. XMoto.js (this project!) : JavaScript port of the game that need to be compatible with a lot of pre-existing levels (XML files) from the original game.
 2. [XMoto.io](https://github.com/MichaelHoste/xmoto.io) : social XMoto game with a backend for scores, replays, etc.

XMoto.io will be built on XMoto.js using Ruby on Rails and both the projects will co-evolve and interact in some parts.

 * Image
 * DEMO
 * More about the development here : http://xmoto.io

## Usage

 * Upload "data", "lib" and "bin" folders on a static web server.
 * Include all the JavaScript files of /lib/ and /bin/xmoto.js on your web page.
 * Unsure that /data/ folder is on your root directory.
 * Call ```$.xmoto('l1.lvl')``` where "l1.lvl" is the name of the level you want to load

## Developpment

### Installation

 * ```brew install nodejs``` : install NodeJS (on MacOS)
 * ```sudo npm install -g coffee-script``` : install CoffeeScript
 * ```npm install express``` : install Express

### Working environnement

 * ```coffee -j bin/xmoto.js -wc src/*.coffee src/*/*.coffee``` to compile to JavaScript automatically on each change.
 * ```node server.js``` to launch HTTP Server (http://localhost:3000).

Don't forget to restart the coffee command if you create new JS files.

## TODO

 * Move camera left/right/up/down depending on moto direction and moto speed
 * Create camera and put @visibility, @scale, @object_to_follow etc. (for level and buffer)
 * surface drift / "rééquilibre bordures" / multiples photos liées ou photo+replay / voir replay
 * Optimization : hide the ghosts and entities that are off the screen
 * Understand impact of "scale" and "depth" on edges.
 * Optimization : group the blocks by texture and fill the texture just once by group.
 * Optimization : only collide with polygons on the screen ?
