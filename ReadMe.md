# AgileGrid

Agile Grid is a mixture of a platformer style game and a grid based game. Agile refers to the fast paced
movement of gameplay - always keeping the player engaged as he/she must match as many blocks on the grid
before it goes offscreen.

- Grids move vertically across the screen, where each grid is a mini match three game.
- Player must match as many blocks as possible before grids go offscreen.
- Future enhancements include adding perks that the player can unlock - ie. slow down time.
- Player can move blocks on each grid by swapping in the playable area

Structure:

- ./Scenes contains all scene source code - ./Scenes/Game.lua contains the main game logic.
- ./data.lua - contains all possible row/col combinations for spawning grids
- ./Modules contains all self written modules that help improve code readability and organization.
   - ./Modules/File.lua - module for file operations (such as create/save/load)
   - ./Modules/Particles.lua - module for creating particle emitter object based on options defined in ./ParticleAffects
   - ./Modules/Exception.lua - a simple module for creating helpful warning/error pront statements
   - ./Modules/Score.lua - module that creates score objects by providing the object with helpful update score functions 
     and also interactive transitions.