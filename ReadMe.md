# AgileGrid

Agile Grid is a mixture of a platformer style game and a grid based game. Agile refers to the fast paced
movement of gameplay - always keeping the player engaged as he/she must match as many blocks on the grid
before it goes offscreen.

- Grids move vertically across the screen, where each grid is a mini match three game.
- Player must match as many blocks as possible before grids go offscreen.
- Player loses the game if any matches are missed.
- Blocks are moved on each grid by swapping in the playable area.
- The game is lost when points go below zero.

Note: This repository was imported from gitlab so some old issues may be missing.

Demos:
- First Look: https://www.dropbox.com/s/yo4126jejgdkolz/agilegrid_demo.mov?dl=0
- More:       https://drive.google.com/open?id=1bA7Yma0HY3S-YP6SfKyWcErkyl2CyUKt

Structure:

- ./Scenes - contains all scene source code
   - ./Scenes/Game.lua - contains the main game logic.
   - ./Scenes/Menu.lua - contains main menu logic.
   - ./Scenes/GameOver.lua - contains game over logic, including displaying and saving game stats
- ./data.lua - contains all possible row/col combinations for spawning grids
- ./Modules - contains all self written modules that help improve code readability and organization.
   - ./Modules/File.lua - module for file operations (such as create/save/load)
   - ./Modules/Particles.lua - module for creating particle emitter object based on options defined in ./ParticleAffects
   - ./Modules/Exception.lua - a simple module for creating helpful warning/error pront statements
   - ./Modules/Score.lua - module that creates score objects by providing the developer with helpful update score functions 
     and also interactive transitions.
   - ./Modules/DialogBox.lua - module that creates custom dialog box to prompt the user.
- ./ParticleAffects - contains lua files that define options for particle affects in the game.
