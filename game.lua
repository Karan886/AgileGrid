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
--debug variables
local swipeStatusText
local debugEdgeBlocksText

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
   local slotContainer = {}

   gridGroup.size = grid.size

   local gridXPos = (width - (grid.size * grid.blockSize + grid.size * grid.offsetX) / 2) - centerX
   local gridYPos = (height - (grid.size * grid.blockSize + grid.size * grid.offsetY) / 2) - centerY


  for i=1,grid.size do
    for j=1,grid.size do
        local block = display.newRect(100, 100, grid.blockSize, grid.blockSize)
        block.x = gridXPos + i * (grid.blockSize + grid.offsetX) - grid.blockSize/2 - grid.offsetX
        block.y = gridYPos + j * (grid.blockSize + grid.offsetY) - grid.blockSize/2 - grid.offsetY

        block.id = #slotContainer + 1
        block.isFocus = false
        
        block:addEventListener("touch", blockSwipe)
        slotContainer[#slotContainer + 1] = block
        gridGroup:insert(block)            
    end
  end

  local slotContainers = bin.slotContainers
  gridGroup.slotContainer = slotContainer
  gridGroup.offsetX = grid.offsetX
  gridGroup.offsetY = grid.offsetY
  gridGroup.blockSize = grid.blockSize
  
  return gridGroup
end

function isBlockOnRightEdge(block)
    local parentGroup = block.parent
    local gridSize = parentGroup.size
    local totalGridSize = gridSize * gridSize

    return (block.id > (totalGridSize - gridSize))
end

function isBlockOnLeftEdge(block)
  local parentGroup = block.parent
  local gridSize = parentGroup.size

  return (block.id <= parentGroup.size)
end

function isBlockOnUpperEdge(block)
  local parentGroup = block.parent
  local gridSize = parentGroup.size

  return (((block.id - 1) % gridSize) == 0)
end

function isBlockOnBottomEdge(block)
  local parentGroup = block.parent
  local gridSize = parentGroup.size

  return ((block.id % gridSize) == 0)
end

function getDominant_Swipe_Direction(horizontalMagnitude, verticalMagnitude)
  if (math.abs(horizontalMagnitude) > math.abs(verticalMagnitude)) then
    return "HORIZONTAL"
  end
  return "VERTICAL"
end

function swapBlocks(blockA, blockB)
  local grids = bin.grids
  local parentGroupID = blockA.parent.id
  local slotContainer = grids[parentGroupID].slotContainer

  local blockAID = blockA.id
  local blockBID = blockB.id

  blockA.id = blockBID
  blockB.id = blockAID

  slotContainer[blockAID] = blockB
  slotContainer[blockBID] = blockA

  transition.to(blockA, { time = 300, x = blockB.x, y = blockB.y })
  transition.to(blockB, { time = 300, x = blockA.x, y = blockA.y })

end

function moveBlockToEmptySpace(block, direction)
  local newID
  local newX
  local newY
  
  local parentGroup = block.parent
  local slotContainer = parentGroup.slotContainer
  if (direction == "LEFT") then
      print "MOVING BLOCK LEFT TO EMPTY SPACE"
      newID = block.id - parentGroup.size
      newX = block.x - (parentGroup.blockSize + parentGroup.offsetX)
      newY = block.y

  elseif (direction == "RIGHT") then
      print "MOVING BLOCK RIGHT TO EMPTY SPACE"
      newID = block.id + parentGroup.size
      newX = block.x + (parentGroup.blockSize + parentGroup.offsetX)
      newY = block.y

  elseif (direction == "UP") then
      print "MOVING BLOCK UP TO EMPTY SPACE"
      newID = block.id - 1
      newX = block.x
      newY = block.y - (parentGroup.blockSize + parentGroup.offsetY)

  elseif (direction == "DOWN") then
      print "MOVING BLOCK DOWN TO EMPTY SPACE"
      newID = block.id + 1
      newX = block.x
      newY = block.y + (parentGroup.blockSize + parentGroup.offsetY)
  end

  if (newID ~= nil) then
      print "NEWID is not null"
      slotContainer[newID] = block
      slotContainer[block.id] = nil
      block.id = newID
      
      transition.to( block, { time = 300, x = newX, y = newY })
  end
end

function blockSwipe(event)
   local parentGroup = event.target.parent
    local slotContainer = parentGroup.slotContainer

   if (event.phase == "began") then

     event.target.isFocus = true
     display.getCurrentStage():setFocus(event.target)
   elseif (event.target.isFocus) then
     if (event.phase == "moved") then

     elseif (event.phase == "ended" or event.phase == "cancelled") then

        local horizontalSwipeMagnitude = event.x - event.xStart
        local verticalSwipeMagnitude = event.y - event.yStart

       

         local swipeDirection = getDominant_Swipe_Direction(horizontalSwipeMagnitude, verticalSwipeMagnitude)
         
         if (swipeDirection == "HORIZONTAL") then
             if (horizontalSwipeMagnitude < 0) then
                 --print "SWIPED LEFT"
                 swipeStatusText.text = "SWIPED LEFT"
                 if (isBlockOnLeftEdge(event.target)) then
                     debugEdgeBlocksText.text = "LEFT EDGE DETECTED"
                     print "SELECTED BLOCK IS ON THE LEFT EDGE"

                 elseif (slotContainer[event.target.id - parentGroup.size] == nil) then
                     print "SWIPING LEFT TO NIL BLOCK"
                     debugEdgeBlocksText.text = "SWIPING TO NIL BLOCK"
                     moveBlockToEmptySpace(event.target, "LEFT")
                 else 
                     local leftBlock = slotContainer[event.target.id - parentGroup.size]
                     print("LEFTBLOCK: "..leftBlock.id)
                     swapBlocks(leftBlock, event.target)
                 end
                 

             elseif (horizontalSwipeMagnitude > 0) then
                 --print "SWIPE RIGHT"
                 swipeStatusText.text = "SWIPED RIGHT"
                 if (isBlockOnRightEdge(event.target)) then
                     print "RIGHT EDGE DETECTED"
                     debugEdgeBlocksText.text = "RIGHT EDGE DETECTED"
                 elseif (slotContainer[event.target.id + parentGroup.size] == nil) then
                     print "SWIPING RIGHT TO NIL BLOCK"
                     debugEdgeBlocksText.text = "SWIPING TO NIL BLOCK"
                     moveBlockToEmptySpace(event.target, "RIGHT")
                 end
             end
         elseif (swipeDirection == "VERTICAL") then
             if (verticalSwipeMagnitude < 0) then
                 --print "SWIPED UP"
                 swipeStatusText.text = "SWIPED UP"
                 if (isBlockOnUpperEdge(event.target)) then
                     print "UPPER EDGE DETECTED"
                     debugEdgeBlocksText.text = "UPPER EDGE DETECTED"
                 elseif (slotContainer[event.target.id - 1] == nil) then
                     print "SWIPING UP TO NIL BLOCK"
                     debugEdgeBlocksText.text = "SWIPING TO NIL BLOCK"
                     moveBlockToEmptySpace(event.target, "UP")
                 end

             elseif (verticalSwipeMagnitude > 0) then
                 print "SWIPE DOWN"
                 swipeStatusText.text = "SWIPED DOWN"
                 if (isBlockOnBottomEdge(event.target)) then
                     print "BOTTOM EDGE DETECTED"
                     debugEdgeBlocksText.text = "BOTTOM EDGE DETECTED"
                 elseif (slotContainer[event.target.id + 1] == nil) then
                     print "SWIPING DOWN TO NIL BLOCK"
                     debugEdgeBlocksText.text = "SWIPING TO NIL BLOCK"
                     moveBlockToEmptySpace(event.target, "DOWN")
                 end                 
             end
         end

         event.target.isFocus = false 
         display.getCurrentStage():setFocus(nil) 

         debugEdgeBlocksText.text = "NO EDGE DETECTED"    
     end
   end
   return true
end

function spawnGrid()
   local gridsTable = bin.grids
   local grid_group = createGridGroup({
      size = 4,
      blockSize = 40,
      offsetX = 5,
      offsetY = 5
    })
 
   grid_group.id = #gridsTable + 1

   physics.addBody(grid_group)
   gridsTable[#gridsTable + 1] = grid_group

   local grids = bin.grids
   local grid = grids[1]
   local slotContainer = grid.slotContainer
   local child = slotContainer[2]

   grid: remove(child)
   display.remove(child)
   slotContainer[child.id] = nil

end


function scene:create( event )
 
    local SceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local MainBackground = display.newImage("Images/Backgrounds/sky_game.png", centerX, centerY)
    swipeStatusText = display.newText("SWIPE DIRECTION", centerX-100, centerY - (centerY+10), system.nativeFont, 16)
    swipeStatusText: setFillColor(0,0,0)

    debugEdgeBlocksText = display.newText("NO EDGE DETECTED", centerX+100, centerY - (centerY+10), system.nativeFont, 16)
    debugEdgeBlocksText: setFillColor(0,0,0)
     --adding display elements to scene group
    SceneGroup: insert(MainBackground)
    SceneGroup: insert(swipeStatusText)
    SceneGroup: insert(debugEdgeBlocksText)
 
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