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

## timestep issue

If the computer is not able to run the game at 60FPS, we can change the display interval like this :

60FPS :
```setInterval(update, 1000 / 60)```
```level.world.Step(1.0 / 60.0, 10, 10)```

30FPS :
```setInterval(update, 1000 / 30)```
```level.world.Step(1.0 / 30.0, 20, 20)```

15FPS :
```setInterval(update, 1000 / 60)```
```level.world.Step(1.0 / 15.0, 40, 40)```

(the behavior will be the same in those 4 examples !)

A good idea would be to make an educated guess of the power of the computer and adapt the framerate.
(check http://gafferongames.com/game-physics/fix-your-timestep/)

## Download the levels from the XMoto official website

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

## TODO

 * Understand impect of "scale" and "depth" on edges
 * Optimization : create x bodies with y shapes for each polygon (set of triangles) instead of x*y bodies of 1 triangle
 * Optimization : group the blocks by texture and fill the texture just once by group
 * Optimization : only draw polygons that are on screen (and only collide with these polygons)
 * Optimization : group triangles polygons (collision blocks) by pairs to get convex polygons with max 8 sides (less complexity, less clipping)
