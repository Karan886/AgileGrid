local composer = require("composer")
local scene = composer.newScene()

--some dimensions
local height = display.actualContentHeight
local width = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

function TransitionToGameScene()
    composer.gotoScene("Scenes.Game", { effect = "fade", time = 1000})
end

function hideStatusBar()
    display.setStatusBar(display.HiddenStatusBar);
end
 
function scene:create( event )
    local SceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local MainBackground = display.newImage("Images/Background/sky_main.png", 0, 0)
    MainBackground.anchorX, MainBackground.anchorY = 0, 0

    local GameTitle = display.newText("Agile Grid", centerX, centerY-150, "Fonts/BigBook-Heavy", 30)
    GameTitle: setFillColor(0.14, 0.19, 0.17)

    hideStatusBar()

    --adding display elements to scene group
    SceneGroup: insert(MainBackground)
    SceneGroup: insert(GameTitle) 
end
 
 

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        Runtime:addEventListener("touch",TransitionToGameScene)
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime:removeEventListener("touch", TransitionToGameScene)
 
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