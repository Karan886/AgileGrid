local composer = require( "composer" )
 
local scene = composer.newScene()
 
--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local width = display.contentWidth
local height = display.contentHeight

local upperBoundary
local lowerBoundary

--scene garbage for objects that are not latched on to the scene
local bin = { 
  grids = {}
}

--global variables
local ScrollParallaxObjects

--physics setup
local physics = require "physics"
physics.start()
physics.setGravity(0, -0.1)
--physics.setDrawMode("hybrid")

-- glabal timer variables
local gridSpawnTimer

--clean up helper functions
function removeGridFromGlobalTable(id)
   local globalTable = bin.grids
   local gridToRemove = bin.grids[id]

   if (gridToRemove ~= nil) then
       print "Grid exists, removing now..."
       table.remove(globalTable, id)
       display.remove(gridToRemove)
       print "Grid is successfully removed"
       for i=1,#globalTable do
         globalTable[i].id = i
       end
   end
end

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

function checkForMatch(grid)
  local slotContainer = grid.slotContainer

  -- Vertical match check.
  for i = 1, (#slotContainer - 2) do
      local block = slotContainer[i]
      local secondBlock = slotContainer[i + 1]
      local thirdBlock = slotContainer[i + 2]

      if (isBlockOnBottomEdge(block) == false and isBlockOnBottomEdge(secondBlock) == false) then
          if (block.colorId == secondBlock.colorId and block.colorId == thirdBlock.colorId) then
              print("Vertical Match Detected")
              block:setFillColor(1,1,1,0.5)
              secondBlock:setFillColor(1,1,1,0.5)
              thirdBlock:setFillColor(1,1,1,0.5)
          end
      end
  end

-- Horizontal Match check.
local index = 1
  local block = slotContainer[index]
  while (block.id + (grid.size * 2) <= #slotContainer) do
    local secondBlock = slotContainer[index + grid.size]
    local thirdBlock = slotContainer[index + (grid.size * 2)]
    if (block.colorId == secondBlock.colorId and block.colorId == thirdBlock.colorId) then
      print("Horizontal Match Detected")
      block: setFillColor(1,1,1,0.5)
      secondBlock: setFillColor(1,1,1,0.5)
      thirdBlock: setFillColor(1,1,1,0.5)
    end
    index = index + 1
    block = slotContainer[index]
  end
end

function assignRandomColorsToBlocks(slotContainer)   
   local numOfColors = #slotContainer
   local colors = getColorMatrix(numOfColors)
   print("number of colors: "..#colors)

  for i = 1, #slotContainer do
    local block = slotContainer[i]
    local randomColorIndex = math.random(1, #colors)
    local colorToAssign = colors[randomColorIndex]

    table.remove(colors, randomColorIndex)
    block:setFillColor(colorToAssign.red, colorToAssign.green, colorToAssign.blue)
    block.colorId = colorToAssign.id
  end
end

-- This function gets a random set of colors such that every color has triplets 
function getColorMatrix(numOfBlocks)
  local colorMatrix = {}
  --math.random() gives me a random number between 0 and 1
  for i = 1, (numOfBlocks / 3) do
    local uniqueId = #colorMatrix
    local color = {math.random(), math.random(), math.random()}
    colorMatrix[#colorMatrix + 1] = {red = color[1], blue = color[2], green = color[3], id = uniqueId}
    colorMatrix[#colorMatrix + 1] = {red = color[1], blue = color[2], green = color[3], id = uniqueId}
    colorMatrix[#colorMatrix + 1] = {red = color[1], blue = color[2], green = color[3], id = uniqueId}
  end
  return colorMatrix
end

function createGridGroup(grid)
   local gridGroup = display.newGroup()
   local slotContainer = {}

   gridGroup.size = grid.size

   local gridXPos = grid.xPos
   local gridYPos = grid.yPos


  for i=1,grid.size do
    for j=1,grid.size do
        local block = display.newRect(100, 100, grid.blockSize, grid.blockSize)
        block.x = gridXPos + i * (grid.blockSize + grid.offsetX) - grid.blockSize/2 - grid.offsetX
        block.y = gridYPos + j * (grid.blockSize + grid.offsetY) - grid.blockSize/2 - grid.offsetY
        
        block.isEnabled = true
        block.id = #slotContainer + 1
        block.isFocus = false
        
        block:addEventListener("touch", blockSwipe)
        slotContainer[#slotContainer + 1] = block
        gridGroup:insert(block)            
    end
  end

  assignRandomColorsToBlocks(slotContainer)

  local slotContainers = bin.slotContainers
  gridGroup.slotContainer = slotContainer
  gridGroup.offsetX = grid.offsetX
  gridGroup.offsetY = grid.offsetY
  gridGroup.blockSize = grid.blockSize
  
  return gridGroup
end

function onUpperSensorCollide(event)
  print("Collision occured with upper sensor")
  if (event.other.name == "GridContainer") then
      print("Grid Container Detected By Upper Sensor with id: "..event.other.id)
      removeGridFromGlobalTable(event.other.id)
  end
end
function isBlockOnRightEdge (block)
    local parentGroup = block.parent
    local gridSize = parentGroup.size
    local totalGridSize = gridSize * gridSize

    return (block.id > (totalGridSize - gridSize))
end

function isBlockOnLeftEdge (block)
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

  transition.to(blockA, { time = 500, x = blockB.x, y = blockB.y })
  transition.to(blockB, { time = 500, x = blockA.x, y = blockA.y })

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

function canSwapBlocks(idA, idB, container)
    return (container[idA].isEnabled and container[idB].isEnabled)
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
                 print("Swiped Left")
                 local idA = event.target.id
                 local idB = idA - parentGroup.size
                 if (isBlockOnLeftEdge(event.target) == false and canSwapBlocks(idA, idB, parentGroup)) then
                    local leftBlock = slotContainer[idB]
                    swapBlocks(event.target, leftBlock)
                 end               
             elseif (horizontalSwipeMagnitude > 0) then
                 print("Swiped Right")
                 local idA = event.target.id
                 local idB = idA + parentGroup.size
                 if (isBlockOnRightEdge(event.target) == false and canSwapBlocks(idA, idB, parentGroup)) then
                    local rightBlock = slotContainer[idB]
                    swapBlocks(event.target, rightBlock)
                 end     
             end
         elseif (swipeDirection == "VERTICAL") then
             if (verticalSwipeMagnitude < 0) then
                 print("swiped up")
                 local idA = event.target.id
                 local idB = idA - 1
                 if (isBlockOnUpperEdge(event.target) == false and canSwapBlocks(idA, idB, parentGroup)) then
                    local upperBlock = slotContainer[idB]
                    swapBlocks(event.target, upperBlock)
                 end  
             elseif (verticalSwipeMagnitude > 0) then
                 print("swiped down")
                 local idA = event.target.id
                 local idB = idA + 1
                 if (isBlockOnBottomEdge(event.target) == false and canSwapBlocks(idA, idB, parentGroup)) then
                    local lowerBlock = slotContainer[idB]
                    swapBlocks(event.target, lowerBlock)
                 end               
             end
         end

         event.target.isFocus = false 
         display.getCurrentStage():setFocus(nil)   
     end
   end
   checkForMatch(parentGroup)
   return true
end

function spawnGrid()
   math.randomseed(os.time())
   local randomSize = (math.random(1,2)) * 3

   local sizeofBlock = 30
   local blockOffset = 5

   local totalShapeSide = (sizeofBlock + blockOffset) * (randomSize - 1) + sizeofBlock
   local trueGridCenter = centerX - (totalShapeSide/2) 
   local randomX = math.random(trueGridCenter - (totalShapeSide/2), trueGridCenter + (totalShapeSide/2))

   local gridsTable = bin.grids
   local grid_group = createGridGroup({
      size = randomSize,
      blockSize = sizeofBlock,
      offsetX = blockOffset,
      offsetY = blockOffset,
      xPos = randomX,
      yPos = height
    })

   
   grid_group.name = "GridContainer"
   grid_group.id = #gridsTable + 1

   local slotContainer = grid_group.slotContainer

   --use the position of the top left block to position physics boundary
   local firstBlockPosition = { x = slotContainer[1].x, y = slotContainer[1].y }

   --creating a custom physics shape since display groups behave differently when adding physics
   local leftCorner = { x = firstBlockPosition.x - (sizeofBlock/2), y = firstBlockPosition.y - (sizeofBlock/2) }
   local rightCorner = { x = leftCorner.x + totalShapeSide, y = leftCorner.y }
   local bottomLeftCorner = { x = leftCorner.x, y = leftCorner.y + totalShapeSide }
   local bottomRightCorner = { x = rightCorner.x, y = rightCorner.y + totalShapeSide }

   local gridPhysicsShape = {

         leftCorner.x, leftCorner.y, 
         rightCorner.x, rightCorner.y,
         bottomRightCorner.x, bottomRightCorner.y,
         bottomLeftCorner.x, bottomLeftCorner.y, 
         leftCorner.x, leftCorner.y
  }

   physics.addBody(grid_group, "dynamic", { shape = gridPhysicsShape})
   gridsTable[#gridsTable + 1] = grid_group
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
 
    local SceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local MainBackground = display.newImage("Images/Backgrounds/sky_game.png", centerX, centerY)
     
    upperBoundary = display.newRect(centerX, -35, width, 5)
    upperBoundary: setFillColor(1,0,0,0.5)

    lowerBoundary = display.newRect(centerX, height, width, 5)
    lowerBoundary: setFillColor(1,0,0,0.5)

     --adding display elements to scene group
    SceneGroup: insert(MainBackground)
    SceneGroup: insert(upperBoundary) 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        --spawn the first grid then apply the delay
        spawnGrid()
        gridSpawnTimer = timer.performWithDelay(15000, spawnGrid, 2)

        physics.addBody(upperBoundary, "static")
        upperBoundary: addEventListener("collision", onUpperSensorCollide)
            
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