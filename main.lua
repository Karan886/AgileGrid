local composer = require "composer"
local file = require "Modules.File"
local json = require "json"
--initialize user data
local userData = {
	name = "player",
	highScore = 0,
	doubleMatches = 0,
	tripleMatches = 0
}

local settings = {
	name = "AGSettings",
	colorAssist = false,
	music = 0.5,
	sound = 0.5
}

local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

file.create('AGUser.json', json.encode(userData), system.DocumentsDirectory)
file.create('AGSettings.json', json.encode(settings), system.DocumentsDirectory)
composer.gotoScene("Scenes.Menu")