local composer = require "composer"
local file = require "Modules.File"
--initialize user data
local userData = '{"name" : "clark"}'
file.create('user.json', userData, system.DocumentsDirectory)
composer.gotoScene("Scenes.Menu")