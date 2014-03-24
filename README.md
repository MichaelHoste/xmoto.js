XMoto.js
========

This project is a HTML5 Port of [XMoto](http://xmoto.tuxfamily.org/) using 2D Canvas and [Box2DWeb](https://code.google.com/p/box2dweb/).

[![Image](http://js.xmoto.io/image.jpg)](http://js.xmoto.io)

This is the first part of a 2-parts project:
 1. [XMoto.js](https://github.com/MichaelHoste/xmoto.js) (this project!): JavaScript port of the game that need to be compatible with a lot of pre-existing levels (XML files) from the original game.
 2. [XMoto.io](https://github.com/MichaelHoste/xmoto.io): social XMoto game with a backend for scores, replays, etc.

XMoto.io will be built on XMoto.js using Ruby on Rails and both the projects will co-evolve and interact in some parts (XMoto.js will take some informations like replays from DOM and JS options, and it will call a route with replay when a player finished a level).

More about the project development on http://xmoto.io

## Demo

Master branch is regularly deployed here: http://js.xmoto.io

Click on the "debug mode" button and have fun with the simulation parameters. You can save the generated URL and copy-paste a link to specific physics.

Examples: [Tractor](http://js.xmoto.io/?level=1010&debug=false&left_wheel.radius=0.55),
[Rodeo](http://js.xmoto.io/?level=1010&debug=false&ground.restitution=1.5&left_suspension.lower_translation=-0.5&left_suspension.upper_translation=0.5&left_suspension.back_force=6&left_suspension.rigidity=2&right_suspension.lower_translation=-0.5&right_suspension.upper_translation=0.5&right_suspension.back_force=6&right_suspension.rigidity=1),
[Ugly Mode](http://js.xmoto.io/?level=1010&debug=true),
[Big Head](http://js.xmoto.io/?level=1010&debug=true&head.radius=0.7)
[Moon](http://js.xmoto.io/?level=1010&debug=false&gravity=5),
[Furious](http://js.xmoto.io/?level=1010&debug=false&moto_acceleration=40&biker_force=10&max_moto_speed=110&gravity=25&left_wheel.friction=10&ground.friction=3)

## Usage

 * Upload "data", "lib" and "bin" folders on a static web server (put 'data' folder on the root directory)
 * Include all the JavaScript files of /lib/ and /bin/xmoto.js on your web page.
 * Call ```$.xmoto('l1.lvl', options)``` where "l1.lvl" is the name of the level you want to load.

Available options:

```
{
  canvas:  '#xmoto'   # canvas selector
  loading: '#loading' # loading selector
  chrono:  '#chrono'  # chrono selector
}
```

## Developpment

### Installation

 * ```brew install nodejs```: install NodeJS (on MacOS)
 * ```sudo npm install -g coffee-script```: install CoffeeScript
 * ```npm install express```: install Express

### Working environnement

 * ```coffee -j bin/xmoto.js -wc src/*.coffee src/*/*.coffee``` to compile to JavaScript automatically on each change.
 * ```node server.js``` to launch HTTP Server (http://localhost:3000).

Don't forget to restart the coffee command if you create new JS files.

## TODO

 * Move camera left/right/up/down depending on moto direction and moto speed
 * Create camera and put @visibility, @scale, @object_to_follow etc. (for level and buffer)
 * surface drift / "rééquilibre bordures" / multiples photos liées ou photo+replay / voir replay
 * Optimization: hide the ghosts and entities that are off the screen
 * Understand impact of "scale" and "depth" on edges.
 * Optimization: group the blocks by texture and fill the texture just once by group.
 * Optimization: only collide with polygons on the screen ?
