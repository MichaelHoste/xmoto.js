XMoto
=====

HTML5 Version of XMOTO (2D Canvas + Box2D)

## For developpment

### Installation

 * ```brew install nodejs``` (on MacOS) : install NodeJS
 * ```sudo npm install -g coffee-script``` : install CoffeeScript
 * ```npm install express``` : install Express

### Usage

 * ```coffee -j bin/xmoto.js -wc src/*``` to compile to JavaScript on each change.
 * ```node server.js``` to launch HTTP Server (http://localhost:3000).

Don't forget to restart the coffee command if you create new JS files.

## For production

Just upload the files on a static web server (you can remove the "src" folder if you want)

## TODO

 * Optimization : create x bodies with y shapes for each polygon (set of triangles) instead of x*y bodies of 1 triangle
 * Optimization : group the blocks by texture and fill the texture just once by group
 * Optimization : only draw polygons that are on screen (and only collide with these polygons)
