<h1>Agile Grid: Android Mobile Game</h1>

<p>
Agile grid is a fast paced grid-based game where the player must solve <em><b>mini-match three puzzles</b></em> before it goes off-screen.
</p>

<hr/>

<h2>Game Play Rules</h2>

<ul>
<li>Grids move vertically across the screen, where each grid is a mini match three game</li>
<li>Player must match as many blocks as possible before grids go offscreen</li>
<li>Player loses the game if any matches are missed</li>
<li>Blocks are moved on each grid by swapping in the <em>playable area</em></li>
<li>
Every match is awarded a single point, while <em><b>double matches</b></em> are awarded <em><b>2 points</b></em> and <em><b>triple matches </b></em>are awarded <em><b>3 points</b></em> 
</li>
</ul>

<strong>Note:</strong> This repository was imported from gitlab so some old issues may be missing.</aside>

<hr/>

<h2>Demos</h2>
<ol>
<li><b><a href="https://www.dropbox.com/s/yo4126jejgdkolz/agilegrid_demo.mov?dl=0">First Look</a></b></li>
<li><b><a href="https://drive.google.com/open?id=1bA7Yma0HY3S-YP6SfKyWcErkyl2CyUKt">More...</a></b></li>
</ol>

<hr/>

<h2>Structure</h2>
<dl>
   
<dt><em>./Scenes</em> - contains all source code</dt>
<dd>
<ul>
<li><em><b>./Scenes/Game.lua</b></em> - contains all main game logic</li>
<li><em><b>./Scenes/Menu.lua</b></em> - contains main menu logic</li>
<li><em><b>./Scenes/GameOver.lua</b></em> - contains game over logic, including displaying and saving game stats</li>
</ul>
</dd>

<dt><em>./data.lua</em></dt>
<dd>contains all possible row/col combinations for spawning grids</dd>

<dt><em>./Modules</em> - contains all self written modules that help improve code readability and organization.</dt>
<dd>
<ul>
<li><em><b>./Modules/File.lua</b></em> - module for file operations (such as create/save/load)</li>
<li><em><b>./Modules/Particles.lua</b></em> - module for creating particle emitter object based on options defined in <em>./ParticleAffects</em></li>
<li><em><b>./Modules/Exception.lua</b></em> - a simple module for creating helpful warning/error prompt statements</li>
<li><em><b>./Modules/DialogBox.lua</b></em> - module that creates custom dialog box to prompt the user</li>
<li>
<em><b>./Modules/Score.lua</b></em> - module that creates score objects by providing the developer with helpful update score functions and also interactive transitions.
</li>
</ul>
</dd>

<dt><em>./ParticleAffects</em></dt>
<dd>contains lua files that define options for particle affects in the game.</dd>
</dl>
