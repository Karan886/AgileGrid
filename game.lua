local composer = require( "composer" )
 
local scene = composer.newScene()
 
--some dimensions
local height = display.actualContentHeight
local width = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

--scene garbage for objects that are not latched on to the scene
local bin = {}

--global variables
local ScrollParallaxObjects
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
function ParallaxScroll(object, options)
    --initialize options
    --the point where a parallax object starts and ends on the screen (ie. it ends when it wraps around)
    local ObjectStart = { x = centerX, y = centerY - 200 } or options.start
    local ObjectEnd = { x = centerX, y = height} or options.exit
    -- the speed at which the parallax object's location updates in the scene (this is usually measured in pixels per frame in this case)
    local Speed = 1 or options.speed

    --print( "Parallax object options: { ObjectStartX = " .. ObjectStart.x .. " ObjectStartY = " .. ObjectStart.y ..
        --" Speed = " .. Speed .. " WrapDelay = " .. WrapDelay)
    
    if ( object.y <= ObjectEnd.y ) then
        object.y = object.y + Speed
    else
        if ( object ~= nil ) then
            object.x = math.random(0, width)
            object.y = ObjectStart.y
        end
    end  
end


function scene:create( event )
 
    local SceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local MainBackground = display.newImage("Images/Backgrounds/sky_game.png", centerX, centerY)

     --adding display elements to scene group
    SceneGroup: insert(MainBackground)
 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
    --parallax scroll objects
    local Parallax_PinkCloud_Small = display.newImage("Images/Parallax/cloud_pink_small.png", centerX, 0)
    local Parallax_GreyCloud_Small = display.newImage("Images/Parallax/cloud_grey_small.png", centerX - 100, 0)

    ScrollParallaxObjects =  function ()
        ParallaxScroll(Parallax_PinkCloud_Small, { start = {y = -10}})
        ParallaxScroll(Parallax_GreyCloud_Small, { start = {y = 0}})
    end

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        Runtime: addEventListener("enterFrame", ScrollParallaxObjects)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end 
    sceneGroup: insert(Parallax_PinkCloud_Small)
end

 
 

function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        Runtime: removeEventListener("enterFrame", ScrollParallaxObjects)
    end
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