XMoto.js
========

[DEMO](http://js.xmoto.io)

This project is a HTML5 Port of [XMoto](http://xmoto.tuxfamily.org/) using
[CoffeeScript](http://coffeescript.org), [PixiJS](http://www.pixijs.com)
and [Box2DWeb](https://code.google.com/p/box2dweb/).

[![Image](http://js.xmoto.io/image.jpg)](http://js.xmoto.io)

This is the **first** part of a 2-parts project:
 1. [XMoto.js](https://github.com/MichaelHoste/xmoto.js) (this project!):
    JavaScript port of the game that need to be compatible with a lot of
    pre-existing levels (XML files) from the original game.
 2. [XMoto.io](https://github.com/MichaelHoste/xmoto.io): social XMoto
    game with a backend for scores, replays, etc.

XMoto.io will be built on top of XMoto.js, using Ruby on Rails, and both the
projects will co-evolve and interact in some parts.

More about the project development on http://xmoto.io
(not up-to-date but good intro).

## Demo

Master branch is frequently deployed here: http://js.xmoto.io

Click on the "debug mode" button and have fun with the simulation parameters.
You can copy-paste the generated URL to keep the custom physics.

**Examples:**

 * [Tractor](http://js.xmoto.io/?level=1010&debug=true&debug_physics=false&left_wheel.radius=0.55)
 * [Rodeo](http://js.xmoto.io/?level=1010&debug=true&debug_physics=false&ground.restitution=1.5&left_suspension.lower_translation=-0.5&left_suspension.upper_translation=0.5&left_suspension.back_force=6&left_suspension.rigidity=2&right_suspension.lower_translation=-0.5&right_suspension.upper_translation=0.5&right_suspension.back_force=6&right_suspension.rigidity=1)
 * [Ugly Mode](http://js.xmoto.io/?level=1010&debug=true&debug_physics=true)
 * [Big Head](http://js.xmoto.io/?level=1010&debug=true&debug_physics=true&head.radius=0.7)
 * [Moon](http://js.xmoto.io/?level=1010&debug=true&debug_physics=false&gravity=5)
 * [Furious](http://js.xmoto.io/?level=1010&debug=true&debug_physics=false&moto_acceleration=40&biker_force=10&max_moto_speed=110&gravity=25&left_wheel.friction=10&ground.friction=3)

## Usage

 * Upload "data", "lib" and "bin" folders on a static web server
   (put 'data' folder on the root directory)
 * Include all the JavaScript files of /lib/ and /bin/xmoto.js
   on your web page.
 * Call ```$.xmoto('l1.lvl')``` or ```$.xmoto('l1.lvl', options)```
   where "l1.lvl" is the name of the level and the options are:

```
{
  container: '#xmoto'   # game selector (empty div)
  loading:   '#loading' # loading selector
  chrono:    '#chrono'  # chrono selector
  width:     800
  height:    600
}
```

## Developpment

### Installation

 * ```brew install nodejs yarn``` to install NodeJS and YARN (on MacOS)
 * ```yarn install``` to install development dependencies

### Working environnement

 * ```./node_modules/coffeescript/bin/coffee -j bin/xmoto.js -wc src/*.coffee src/*/*.coffee``` to compile
   to JavaScript in real-time.
 * ```node server.js``` to launch HTTP Server (http://localhost:3001).

Don't forget to restart the coffee command if you create new COFFEE files.

### Technical informations

 * Implementation of replays is described [here](https://github.com/MichaelHoste/xmoto.js/issues/8)
 * Use [this link](http://js.xmoto.io?level=943&debug=true&automatic_scale=false&manual_scale=false&default_scale.x=90&default_scale.y=-90&width=1024&height=768) to compare screen 1/1 with original X-Moto (same zoom/resolution): 

## COVID-XMoto

Many years after this project was shelved, and out of nowhere, 
[James Fator](https://jamesfator.com/) decided to fork this project to make 
a heavily modified version of XMoto.js, dedicated to the somewhat strange 
years of the COVID virus.

<a href="http://covid.xmoto.io">
  <img src="http://xmoto.io/img/xmoto-covid.png" width="700" title="COVID-XMoto" />
</a>

<br/>

The COVID-19 confirmed cases timeseries has become a mountain of flags 
which you must climb with your motorcycle! Can you win the race for the cure?

* [Play COVID-XMoto](http://covid.xmoto.io)
* [The COVID-XMoto fork](https://github.com/JamesFator/COVID-XMoto)

Thanks again to James Fator for this nice project! I'm always happy to see that 
open-sourcing side projects can lead to unexpected things. 

Please visit his personal website for other cool projects: https://jamesfator.com/

## TODO

* Rename: init_sprites => init_graphics?
* Manage the limits in mesh as well?
  => See level 1136 (Green Hill Zone Act 2) to align checkerboard and scale.
* Animated textures for blocks/edges? (l8682/l7388) 
  => performance.now(), Date.now() or Ticker?
* Manage sky better: 
  * `<sky color_r="150" color_g="100" color_b="50" zoom="3.0">sky1</sky>`
  * `<sky color_g="255" zoom="3.7" color_a="255" color_b="255" offset="0.16" drifted="false" use_params="true" color_r="255">Water1</sky>`
  * http://wiki.xmoto.tuxfamily.org/index.php?title=Others_tips_to_make_levels
* Adjust a bit the camera (player more on the borders of the camera, less zoom)
* Sounds with PixiJS Sound and play on the left/right depending on position
* Adjust the height of the driver (less bumpy!? Height of sprite? Compare values?)
* Manage checkpoints
  * http://wiki.xmoto.tuxfamily.org/index.php?title=Notes_on_Checkpoints
* Parse maps from https://github.com/bjorn/tiled ?
* Create alternative box2D physics using DIV elements on screen.
* use color on image to create mesh of collisions: https://github.com/Tamersoul/magic-wand-js

[and other stuffs](https://github.com/MichaelHoste/xmoto.js/issues)
