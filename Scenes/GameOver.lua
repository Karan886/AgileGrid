local composer = require "composer"
local scene = composer.newScene()

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local width = display.contentWidth
local height = display.contentHeight

local widget = require "widget"

--global variables
local gameOverClipboard
local gameOverText
local backButton

local dataObjects = display.newGroup()
local bin = {}

function goToMainMenu()
    composer.gotoScene("Scenes.Menu", {time = 300, effect = "fade"})
end

function showGameStats(data)
	local pos = {x = gameOverClipboard.x, y = gameOverClipboard.y - (gameOverClipboard.y/2) - 33}
    for i = 1, #data do
        local dataBackground = display.newRect(pos.x, pos.y, gameOverClipboard.width - 25, 50)
        if (dataObjects.numChildren > 0) then
        	local previous = dataObjects[dataObjects.numChildren]
            dataBackground.y = previous.y + previous.height + 25
        end
        dataBackground: setFillColor(0, 0, 0, 0.5)
        dataBackground.strokeWidth = 1
        dataBackground: setStrokeColor(1, 1, 1, 0.5)
        dataBackground.alpha = 0

        local keyText = display.newText(data[i].key..":", 0, dataBackground.y, "./Fonts/BigBook-Heavy", 16)
        keyText.x = dataBackground.x - dataBackground.width/2 + keyText.width/2 + 5
        keyText: setFillColor(1, 1, 1, 0.7)
        keyText.alpha = 0

        local valueText = display.newText(data[i].value, 0, dataBackground.y, "./Fonts/BigBook-Heavy", 16)
        valueText.x = dataBackground.x + dataBackground.x/2 + valueText.width

        dataObjects: insert(dataBackground)
        dataObjects: insert(keyText)
        dataObjects: insert(valueText)
        bin[#bin + 1] = dataBackground
        bin[#bin + 1] = keyText
        bin[#bin + 1] = valueText
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
    local bg = display.newImage("./Images/Backgrounds/sky_main_two.png", centerX, centerY)

    gameOverClipboard = display.newImage("./Images/Misc/clipboard.png", centerX, centerY)
    gameOverClipboard.y = centerY - gameOverClipboard.height - 60
    gameOverClipboard.width, gameOverClipboard.height =  300, 380

    gameOverText = display.newText("Game Over", centerX, centerY - actualHeight/2, "./Fonts/BigBook-Heavy", 30)
    gameOverText.y = gameOverText.y + gameOverText.height / 2 + 3
    gameOverText: setFillColor(0, 0, 0.2)

    backButton = widget.newButton({
        label = "Main Menu",
        font = "./Fonts/BigBook-Heavy",
        shape = "roundedRect",
        cornerRadius = 5,
        fillColor = {default = {0.55, 0.35, 0.17}, over = {0.55, 0.35, 0.17, 0.5}},
        labelColor = {default = {1, 1, 1}, over = {1, 1, 1, 0.5}},
        strokeWidth = 2,
        strokeColor = {default = {0.8, 0.5, 0.2, 0.8}, over = {0.8, 0.5, 0.2, 0.5}},
        x = centerX,
        y = centerY + actualHeight/2,
        onPress = goToMainMenu
    })
    backButton.y = backButton.y - backButton.height / 2 - 7

    sceneGroup: insert(bg)
    sceneGroup: insert(gameOverClipboard)
    sceneGroup: insert(gameOverText)
    sceneGroup: insert(backButton)
end

function cleanUpScene()
   for i = 1, #bin do
	     display.remove(bin[i])
	end 
end

function scene:show( event )
	local sceneGroup = self.view
	if (event.phase == "will") then
        local params = event.params
	    transition.to(gameOverClipboard, {time = 500, x = centerX, y = centerY})
	    timer.performWithDelay(1000, function()
	        showGameStats({
                {key = "High Score", value = 0},
                {key = "Total Matches", value = 0},
                {key = "Highest Point", value = 0},
                {key = "x2 Matches", value = 0},
                {key = "x3 Matches", value = 0},
                {key = "Below Zero", value = -1},
                {key = "Final Score", value = -1}
	        })
	        for i = 1, dataObjects.numChildren do
	            transition.to(dataObjects[i], {time = 100, alpha = 1.0})
	        end
	    end, 1)

	elseif (event.phase == "did") then

	end

	sceneGroup: insert(dataObjects)
end

function scene:hide( event )
    local sceneGroup = self.view
	if (event.phase == "will") then
	    cleanUpScene()
	elseif (event.phase == "did") then

	end
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
-- -----------------------------------------------------------------------------------
return scene