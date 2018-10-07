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
local bin = { 
  grids = {}
}

--global variables
local ScrollParallaxObjects
local debugText

--physics setup
local physics = require "physics"
--physics.start()
--physics.setGravity(0, 0.3)

-- glabal timer variables
local gridSpawnTimer

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

function createGridGroup(grid)
   local gridGroup = display.newGroup()
   gridGroup.size = grid.size

   local gridXPos = (width - (grid.size * grid.blockSize + grid.size * grid.offsetX) / 2) - centerX
   local gridYPos = (height - (grid.size * grid.blockSize + grid.size * grid.offsetY) / 2) - centerY

   local numOfBlocks = 0

  for i=1,grid.size do
    for j=1,grid.size do
        local block = display.newRect(100, 100, grid.blockSize, grid.blockSize)
        block.x = gridXPos + i * (grid.blockSize + grid.offsetX) - grid.blockSize/2 - grid.offsetX
        block.y = gridYPos + j * (grid.blockSize + grid.offsetY) - grid.blockSize/2 - grid.offsetY

        numOfBlocks = numOfBlocks + 1
        block.id = numOfBlocks
        block.isFocus = false
        
        block:addEventListener("touch", blockSwipe)
        gridGroup:insert(block)            
    end
  end

  return gridGroup
end

function getDominant_Swipe_Direction(horizontalMagnitude, verticalMagnitude)
  if (math.abs(horizontalMagnitude) > math.abs(verticalMagnitude)) then
    return "HORIZONTAL"
  end
  return "VERTICAL"
end



function blockSwipe(event)
   local parentGroup = event.target.parent
   --print("groupID: "..parentGroup.id.." blockID: "..parentGroup[event.target.id].id)

   if (event.phase == "began") then

     event.target.isFocus = true
   elseif (event.target.isFocus) then
     if (event.phase == "moved") then

         print("blockID: "..event.target.id.." is being moved")

         local horizontalSwipeMagnitude = event.x - event.xStart
         local verticalSwipeMagnitude = event.y - event.yStart

         local swipeDirection = getDominant_Swipe_Direction(horizontalSwipeMagnitude, verticalSwipeMagnitude)
         
         if (swipeDirection == "HORIZONTAL") then
             if (horizontalSwipeMagnitude < 0) then
                 print "SWIPED LEFT"
                 debugText.text = "SWIPED LEFT"
             elseif (horizontalSwipeMagnitude > 0) then
                 print "SWIPE RIGHT"
                 debugText.text = "SWIPED RIGHT"
             end
         elseif (swipeDirection == "VERTICAL") then
             if (verticalSwipeMagnitude < 0) then
                 print "SWIPED UP"
                 debugText.text = "SWIPED UP"
             elseif (verticalSwipeMagnitude > 0) then
                 print "SWIPE DOWN"
                 debugText.text = "SWIPED DOWN"
             end
         end


     elseif (event.phase == "ended" or event.phase == "cancelled") then

         event.target.isFocus = false      
     end
   end
   return true
end

function spawnGrid()
   local gridsTable = bin.grids
   local grid_group = createGridGroup({
      size = 3,
      blockSize = 30,
      offsetX = 5,
      offsetY = 5
    })
 
   grid_group.isABlockSelected = false
   grid_group.id = #gridsTable

   physics.addBody(grid_group)
   gridsTable[#gridsTable + 1] = grid_group
   
end


function scene:create( event )
 
    local SceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local MainBackground = display.newImage("Images/Backgrounds/sky_game.png", centerX, centerY)
    debugText = display.newText("SWIPE DIRECTION", centerX, centerY - 100, system.nativeFont, 16)
    debugText: setFillColor(0,0,0)
     --adding display elements to scene group
    SceneGroup: insert(MainBackground)
    SceneGroup: insert(debugText)
 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        gridSpawnTimer = timer.performWithDelay(2000, spawnGrid, 1)

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
        timer.cancel(gridSpawnTimer)

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