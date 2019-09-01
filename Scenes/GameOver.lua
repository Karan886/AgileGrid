local composer = require("composer")
local scene = composer.newScene()

local blur = require "Modules.Blur"
local ui = require "Modules.UI"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- ui layers
local blurLayer = display.newGroup()
local backgroundLayer = display.newGroup()
local gameStatsLayer = display.newGroup()

function scene:create( event )
    print("switched to Game Over scene....")
    local sceneGroup = self.view
    
    local blurOverlay = blur.getBlurredImage({
        xmin = 0,
        xmax = actualWidth,
        ymin = -15,
        ymax = actualHeight,
    })
    blurLayer: insert(blurOverlay)
    sceneGroup:insert(blurLayer) 
end
 
function scene:show( event )
    local sceneGroup = self.view
    local params = event.params
    local gameStats = params.gameData

    if (event.phase == "will") then

    elseif (event.phase == "did") then
        local modal = display.newImage("Images/UI/ModalSmall.png", centerX, centerY)
        modal.alpha = 0
        backgroundLayer:insert(modal)

        local gameoverTitle = display.newText("GameOver", modal.x, 0, "Fonts/BigBook-Heavy", 20)
        gameoverTitle.y = modal.y - modal.height / 2 + gameoverTitle.height / 2
        gameoverTitle.alpha = 0
        gameoverTitle:setFillColor(0.8, 0, 0)
        backgroundLayer:insert(gameoverTitle)

         -- Ease in the modal using transition
        transition.to(modal, {
            alpha = 1.0,
            time = 1500,
            onComplete = function()
                gameoverTitle.alpha = 1.0
                ui.displayGameStats({
                    data = gameStats,
                    layer = gameStatsLayer,
                    x = centerX,
                    y = centerY,
                    width = modal.width - 10,
                    height = modal.height - 20,
                    yOffsetFactor = 1.5,
                    fontSize = 20,
                    font = "Fonts/Futura-Bold",
                    alias = {
                        tripleMatches = "Triple Matches:",
                        doubleMatches = "Double Matches:",
                        matches = "Matches:"
                    }
                })
            end
        })

    end
    sceneGroup:insert(backgroundLayer)
    sceneGroup:insert(gameStatsLayer)
end
 
function scene:hide( event )
    local sceneGroup = self.view
    
    if (event.phase == "will") then

    elseif (event.phase == "did") then

    end
end
 

function scene:destroy( event )
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene