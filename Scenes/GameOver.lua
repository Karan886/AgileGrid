local composer = require("composer")
local scene = composer.newScene()

local blur = require "Modules.Blur"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- ui layers
local blurLayer = display.newGroup()

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

    if (event.phase == "will") then

    elseif (event.phase == "did") then

    end
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