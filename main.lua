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
file.create('AGUser.json', json.encode(userData), system.DocumentsDirectory)

--Testing the image sheet for blocks

--[[local imgSheetOps = {
	width = 100,
	height = 100,
	numFrames = 15
}
frame = 1
for i = 1, 5 do
	for j = 1, 3 do
		local imgSheet = graphics.newImageSheet("Images/Blocks.png", imgSheetOps)
		local frameOne = display.newImage(imgSheet, frame, display.contentCenterX, display.contentCenterY)
		frame = frame + 1
		frameOne.width = 50
		frameOne.height = 50
		frameOne.x = frameOne.width*j
		frameOne.y = frameOne.height*i
	end
end--]]
composer.gotoScene("Scenes.Menu")