local composer = require("composer")
local scene = composer.newScene()

local colors = require "Data.Colors"
 

function scene:create( event )
    print("Switched to Game Over scene....")
    
    -- local result = colors.populateDimensions(4, 3)
    -- for i = 1, #result do
    --     print(result[i].r..","..result[i].g..","..result[i].b)
    -- end
    
end
 
function scene:show( event )
 
   
end
 
 
-- hide()
function scene:hide( event )
 
end
 

function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
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