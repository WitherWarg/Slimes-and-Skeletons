# LÖVE 2D Game with Lua: SnS

## Video Demo:  TODO

## About Me

## Description

### My Game

My game is called slimes and skeletons, or SnS for short. It is composed a prototype game where you kill slimes and skeletons and your goal is to reach the house at the end of the path.

### Controls

The controls are relatively simple:
WASD to move;
Mouse button to attack;
The direction of the attack depends on your mouse, not the current direction of the player;
Finally, in order to run the game, visit the website linked below, then download, unzip and run the executable.
<https://zulox.itch.io/sns>

### Assets

All assets' licenses are included with links to their repositories. You may have to search in multiple files for certain assets.

#### Libraries

All folders inside of the library are used in order to improve the ease of development and do not add any features that are present in SnS, but simply make the code cleaner.

For example, windfield is a physics module that takes the LÖVE2D's joints, fixtures and shapes into a single collider and world with easy to use functions. However, I am the one who needs to implement collision behavior, speed, shape and size. Then, I need to connect that behavior with what the player can see.

#### Art

CS50 is a course about learning how to program. Because of this, and mostly because of my lackluster skill, most of the art in this game was from [itch.io](https://itch.io/).

The hearts pack I used was made by [VampireGirl](https://itch.io/profile/fliflifly). However, the pack is free and she did not leave a license.

The main pack that I used, Mystic Woods, was made by [Game Endeavor]((https://game-endeavor.itch.io/)). He's a Youtube Creator who is currently posting developer logs for a game. His license has been included in the mystic woods folder which cost me $2.99.

### Code

#### main.lua

This simply loads the game's graphics, loads in all of the files using require.lua and switches to the level gamestate. A gamestate is a table with all the regular love callbacks. This helps me switch between level, pause and end screens for the game.

#### conf.lua

In the configuration file, I define the title, version, dimensions and other miscellaneous settings which you can find out more about on the LÖVE2D website <https://love2d.org/wiki/Config_Files>.

#### Maps

This contains the map data necessary for the sti (simple tiled implementation) library to read and load the map so that I can draw it as well as all colliders that need to be used for the walls.

#### Source

The source folder is made up of four directories. THe first one, entities, stores all the behavior and functions related to entities. The second one, instances, stores all gamestates. Thirdly, the load directory stores the files necessary to properly load the physics world as well as all of the files in the project. Finally, the utilities directory stores multiple useful functions such as a converter from hsl to rgb.

##### Entities
