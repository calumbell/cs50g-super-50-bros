# Super 50 Bros.

Assignment 4 of EDX/HarvardX's *CS50 Introduction to Games Development* course: https://www.edx.org/course/cs50s-introduction-to-game-development .

**Topics**: *Tile Maps, 2D Animation, Procedural Level Generation, and Platformer Physics*

## Requirements
- LÖVE 2D 10.2

### Assignment Objectives
Read and understand the distribution code for the game *Super 50 Bros* (a Mario clone) and implement the following features:

- Modify the level generation algorithm so that the player will never spawn above a chasm.
- Generate a random-coloured locked block and a key to unlock it. When the key has been picked up, the lock can be opened.
- Opened the locked block will generate a goalpost & flag at the end of the level.
- When the player touches the flag, generate a new (and slightly longer) level. When the player respawns, their score should persist.

You can view the distribution code at https://cdn.cs50.net/games/2019/x/assignments/4/assignment4.zip , or you can check out the initial commit for this repo.

### Additional Features
- Modified the GameObject class so that it can animated like an Entity (using the Animation class). This was used to animate the flag.
- Modified Animation class to trigger sound effects when switching between frames. This was used to add footstep sfx to the player.
- 
---

