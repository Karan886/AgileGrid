local composer = require("composer")
local scene = composer.newScene()
 

function scene:create( event )
    print("Switched to Game Over scene....")
    
    
    

   
    
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