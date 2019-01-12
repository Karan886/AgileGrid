local composer = require "composer"
local file = require "Modules.File"
local json = require "json"

local test = require "Scenes.Menu"
--initialize user data
local userData = {
	name = "player",
	highScore = 0,
	doubleMatches = 0,
	tripleMatches = 0,
	highestPoint = 0
}
file.create('AGUser.json', json.encode(userData), system.DocumentsDirectory)
composer.gotoScene("Scenes.Menu")