XMoto.io
========

HTML5 Version of XMOTO (2D Canvas + Box2D)

More about the development here : http://xmoto.io

## For developpment

### Installation

 * ```brew install nodejs``` (on MacOS) : install NodeJS
 * ```sudo npm install -g coffee-script``` : install CoffeeScript
 * ```npm install express``` : install Express

### Usage

 * ```coffee -j bin/xmoto.js -wc src/*.coffee src/*/*.coffee``` to compile to JavaScript automatically on each change.
 * ```node server.js``` to launch HTTP Server (http://localhost:3000) or use any web server.

Don't forget to restart the coffee command if you create new JS files.

## For production

Just upload the files on a static web server (you can remove the "src" folder if you want)

## Download the levels from the XMoto official website

### Solution 1

Execute this on the chrome console of one of the page of listing (ex. http://xmoto.tuxfamily.org/index.php?page=levels&sort=name&letter=A)

```
var jq = document.createElement('script');
jq.src = "//ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js";
document.getElementsByTagName('head')[0].appendChild(jq);
// ... give time for script to load, then type.
jQuery.noConflict();
```

Then this

```
$('.admin_data tr').each(function(){ $(this).find('td:last a').each(function() { console.log("wget -P data/Levels/ " + $(this).attr('href')) }) })
```

Then put result lines in a bash file at the root of the project, chmod +x the file and execute it.

### Solution 2

Use this file : http://xmoto.tuxfamily.org/levels.

## TODO

 * Dezoom with speed
 * Move camera left/right/up/down depending on moto direction and moto speed
 * Optimization : hide the ghosts and entities that are off the screen
 * Understand impact of "scale" and "depth" on edges.
 * Optimization : group the blocks by texture and fill the texture just once by group.
 * Optimization : only collide with polygons on the screen ?
