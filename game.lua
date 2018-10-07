local composer = require( "composer" )
 
local scene = composer.newScene()
 
--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local width = display.contentWidth
local height = display.contentHeight

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
    local ObjectEnd = { x = centerX, y = actualHeight} or options.exit
    -- the speed at which the parallax object's location updates in the scene (this is usually measured in pixels per frame in this case)
    local Speed = 1 or options.speed

    --print( "Parallax object options: { ObjectStartX = " .. ObjectStart.x .. " ObjectStartY = " .. ObjectStart.y ..
        --" Speed = " .. Speed .. " WrapDelay = " .. WrapDelay)
    
    if ( object.y <= ObjectEnd.y ) then
        object.y = object.y + Speed
    else
        if ( object ~= nil ) then
            object.x = math.random(0, actualWidth)
            object.y = ObjectStart.y
        end
    end  
end

function createGrid(grid)

   local gridXPos = (width - (grid.size * grid.blockSize + grid.size * grid.offsetX) / 2) - centerX
   local gridYPos = (height - (grid.size * grid.blockSize + grid.size * grid.offsetY) / 2) - centerY

  for i=1,grid.size do
    for j=1,grid.size do
        local block = display.newRect(100, 100, grid.blockSize, grid.blockSize)
        block.x = gridXPos + i * (grid.blockSize + grid.offsetX) - grid.blockSize/2 - grid.offsetX
        block.y = gridYPos + j * (grid.blockSize + grid.offsetY) - grid.blockSize/2 - grid.offsetY

        print("spawned block: "..block.x.." , "..block.y)              
    end
  end
end

function spawnGrid()
   createGrid({
      size = 3,
      blockSize = 30,
      offsetX = 5,
      offsetY = 5
    })
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
        spawnGrid()
    end 
end

function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
 
    elseif ( phase == "did" ) then

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