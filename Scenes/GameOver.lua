local composer = require "composer"
local scene = composer.newScene()

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local width = display.contentWidth
local height = display.contentHeight

--global variables
local gameOverClipboard
local gameOverText

local dataObjects = display.newGroup()

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
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
    local sceneGroup = self.view
    local bg = display.newImage("./Images/Backgrounds/sky_main_two.png", centerX, centerY)

    gameOverClipboard = display.newImage("./Images/Misc/clipboard.png", centerX, centerY)
    gameOverClipboard.y = centerY - gameOverClipboard.height - 45
    gameOverClipboard.width, gameOverClipboard.height =  300, 380

    gameOverText = display.newText("Game Over", centerX, 0, "./Fonts/BigBook-Heavy", 30)
    gameOverText: setFillColor(0, 0, 0.2)

    sceneGroup: insert(bg)
    sceneGroup: insert(gameOverClipboard)
    sceneGroup: insert(gameOverText)
end

function scene:show( event )
	local sceneGroup = self.view
	if (event.phase == "will") then
	    transition.to(gameOverClipboard, {time = 500, x = centerX, y = centerY})
	    timer.performWithDelay(1000, function()
	        showGameStats({
                {key = "Matches", value = 0},
                {key = "Mismatches", value = 0},
                {key = "Highest Score", value = 0},
                {key = "x2 Matches", value = 0},
                {key = "x3 Matches", value = 0},
                {key = "Below Zero", value = -1},
                {key = "Final Score", value = -1}
	        })
	        for i = 1, dataObjects.numChildren do
	            transition.to(dataObjects[i], {time = 300, alpha = 1.0})
	        end
	    end, 1)

	elseif (event.phase == "did") then

	end

	sceneGroup: insert(dataObjects)
end

function scene:hide( event )
    local sceneGroup = self.view
	if (event.phase == "will") then

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