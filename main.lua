local composer = require "composer"
local file = require "file"
--initialize user data
local userData = '{"name" : "clark"}'
file.create('user.json', userData, system.DocumentsDirectory)
composer.gotoScene("menu")