local composer = require( "composer" )
 
local scene = composer.newScene()
 
--some dimensions
local height = display.actualContentHeight
local width = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

--scene garbage for objects that are not latched on to the scene
local bin = {}

--global scene objects
local Parallax_CloudPink_Small

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
function ParallaxScroll(object, options)
    --initialize options
    --the point where a parallax object starts and ends on the screen (ie. it ends when it wraps around)
    local ObjectStart = { x = object.x, y = object.y } or options.start
    local ObjectEnd = { x = centerX, y = 0} or options.exit
    -- the speed at which the parallax object's location updates in the scene (this is usually measured in pixels per frame in this case)
    local Speed = 5 or options.speed
    -- after the object hits its exit location we might not want to wrap right away, this is measured in milliseconds
    local WrapDelay = 500 or options.wrapDelay

    print( "Parallax object options: { ObjectStartX = " .. ObjectStart.x .. " ObjectStartY = " .. ObjectStart.y ..
        " Speed = " .. Speed .. " WrapDelay = " .. WrapDelay)
    
    if (object.y >= ObjectEnd.y) then
        object.y = object.y + Speed
    else
        if ( object ~= nil ) then
            timer.performWithDelay( WrapDelay, function ()
                print("parallax object wrap around delay listener was called")
                object.x = ObjectStart.x
                object.y = ObjectStart.y
            end)
        end
    end  
end

function ParallaxScrollTrigger()
    ParallaxScroll(Parallax_CloudPink_Small)
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

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end 
end

 
 

function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
 
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