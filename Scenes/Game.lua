local composer = require( "composer" )
local scene = composer.newScene()

-- Include files
local data = require "data"
local widget = require "widget"
local score = require "Modules.Score"
local particles = require "Modules.Particles"
local exception = require "Modules.Exception"
local dialog = require "Modules.DialogBox"
local file = require "Modules.File"
 
--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth

local centerX = display.contentCenterX
local centerY = display.contentCenterY

local width = display.contentWidth
local height = display.contentHeight

-- global variables
local upperBoundary
local headerFrame
local scoreText
local pausePlayButton
local quitGameButton
local pauseGameText
local gameOverLay
local dialogBox

local parallax_clouds_one
local parallax_clouds_two
local parallax_clouds_three

local parallaxWrapPosition
local gameStatsText

--initialized globals
local pauseTexture = {
    type = "image",
    filename = "./Images/UI/pause_button.png"
}

local playTexture = {
    type = "image",
    filename = "./Images/UI/play_button.png"
}

local smokeAffect = particles.new("./ParticleAffects/SmokeExplosion.json")
local gameState = "PLAY"

local gameData = {
  score = 0,
  doubleMatches = 0,
  tripleMatches = 0,
  highestPoint = 0
}

local spawnTime = 8000

--container for grids and other game objects
local bin = { 
  grids = {},
  UI = {}
}

local spawnLayer = display.newGroup()

--physics setup
local physics = require "physics"
physics.start()
physics.setGravity(0, -0.1)
--physics.setDrawMode("hybrid")

-- global timer variables
local gridSpawnTimer

--clean up helper functions
function removeGridFromGlobalTable(id)
   local globalTable = bin.grids
   local gridToRemove = bin.grids[id]

   if (gridToRemove ~= nil) then
       table.remove(globalTable, id)
       spawnLayer: remove(gridToRemove)
       display.remove(gridToRemove)
       print "Grid is successfully removed"
       for i=1,#globalTable do
         globalTable[i].id = i
       end
   else
       print("no grid to remove")
   end
end

function createGameStatsText()
    local pos = {x = 0, y = centerY - actualHeight/2 + headerFrame.height + 5}
    local ui = bin.UI
    local group = display.newGroup()
    local count = 1
    for key, value in pairs(gameData) do
        local gameStat = display.newText(key..": "..value, pos.x, pos.y * count, "./Fonts/Carbon-Phyber", 10)
        gameStat.x = gameStat.width/2 + 5
        gameStat.alpha = 0.8
        gameStat.isVisible = false
        group: insert(gameStat)
        ui[#ui + 1] = gameStat
        count = count + 1
    end
    return group
end

function hideGameStatsText(group)
   for i = 1, group.numChildren do
       group[i].isVisible = false
   end 
end

function showGameStatsText(group)
   local count = 1
   for key, value in pairs(gameData) do
       group[count].text = key..": "..value
       group[count].isVisible = true
       count = count + 1
   end
end

function resetGameData()
  for key in pairs(gameData) do
    gameData[key] = 0
  end
end

function updateGameData(value)
  if (scoreText.value > gameData["highestPoint"]) then gameData["highestPoint"] = scoreText.value end
  if (value == 2) then
      gameData["doubleMatches"] = gameData["doubleMatches"] + 1
  elseif (value == 3) then
    gameData["tripleMatches"] = gameData["tripleMatches"] + 1
  end
  gameData["score"] = scoreText.value
end

function updateScore(val, pokeOptions)
    if (scoreText ~= nil) then
       scoreText.add({
           value = val
       })
       scoreText.poke(pokeOptions)
       
       updateGameData(value)

      if (scoreText.value < 0) then
          haltGameActivity()
          scoreText.display(nil, 1000)
           changeScene({
              sceneName = "Scenes.GameOver",
              duration = 500,
              delay = 3000,
              params = { highScores = getUserGameData(), currentGameData = gameData}
          })
      end
    end
end

function removeMatchedBlocks(blocks, score)
  -- Assuming that all blocks belong to the same parent grid
  if (blocks == nil or #blocks == 0) then
    return false
  end
  local parentGrid = blocks[1].parent
  for i = 1, #blocks do
    blocks[i].isEnabled = false
    blocks[i].alpha = 0.5
    transition.to(blocks[i], {xScale = 0.5, yScale = 0.5, time = 350, onComplete = function() blocks[i].isVisible = false end})
    parentGrid.numOfBlocks = parentGrid.numOfBlocks - 1
  end
  if (score == true) then
      updateScore(#blocks / 3, {
          startColor = {0.28, 0.52, 0.34}
      })
  end
  return true
end

function disableBlocks(blocks)
  for i = 1, #blocks do
    blocks[i].isEnabled = false
  end
end

function getMatchedBlocks(grid)
  local slotContainer = grid.slotContainer
  local matchedBlocks = {}
  -- Vertical match check.
  for i = 1, (#slotContainer - 2) do
      local block = slotContainer[i]
      local secondBlock = slotContainer[i + 1]
      local thirdBlock = slotContainer[i + 2]

      if (isBlockOnBottomEdge(block) == false and isBlockOnBottomEdge(secondBlock) == false and block.isEnabled == true) then
          if (block.colorId == secondBlock.colorId and block.colorId == thirdBlock.colorId) then
              disableBlocks({block, secondBlock, thirdBlock})
              matchedBlocks[#matchedBlocks + 1] = block
              matchedBlocks[#matchedBlocks + 1] = secondBlock
              matchedBlocks[#matchedBlocks + 1] = thirdBlock
          end
      end
  end

 -- Horizontal Match check.
 local index = 1
 local block = slotContainer[index]
 while (block.id + (grid.size.rows * 2) <= #slotContainer) do
   local secondBlock = slotContainer[index + grid.size.rows]
   local thirdBlock = slotContainer[index + (grid.size.rows * 2)]
   if (block.colorId == secondBlock.colorId and block.colorId == thirdBlock.colorId and block.isEnabled == true) then
      disableBlocks({block, secondBlock, thirdBlock})
      matchedBlocks[#matchedBlocks + 1] = block
      matchedBlocks[#matchedBlocks + 1] = secondBlock
      matchedBlocks[#matchedBlocks + 1] = thirdBlock
   end
   index = index + 1
   block = slotContainer[index]
end
  return matchedBlocks
end

function assignRandomColorsToBlocks(slotContainer)   
   local numOfColors = #slotContainer
   local colors = getColorMatrix(numOfColors)

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

   local sizeCombinations = data.sizeCombinations
   local randomSize = sizeCombinations[math.random(1, #sizeCombinations)]

   local rows = grid.rows or randomSize.rows
   local cols = grid.cols or randomSize.cols

   local size = {rows = rows, cols = cols}

   gridGroup.totalShapeWidth = (grid.blockSize + grid.offsetX) * (cols - 1) + grid.blockSize
   gridGroup.totalShapeHeight = (grid.blockSize + grid.offsetY) * (rows - 1) + grid.blockSize

   gridGroup.size = size
   local randomX = math.random(0, width - gridGroup.totalShapeWidth)

   local gridXPos = grid.xpos or randomX
   local gridYPos = grid.ypos or (height + 35)

   for i=1, cols do
     for j=1, rows do
        local block = display.newRoundedRect(100, 100, grid.blockSize, grid.blockSize, grid.blockCornerRadius)
        block.strokeWidth = 2
        block: setStrokeColor(0, 0, 0, 0.5)
        block.x = gridXPos + i * (grid.blockSize + grid.offsetX) - grid.blockSize/2 - grid.offsetX
        block.y = gridYPos + j * (grid.blockSize + grid.offsetY) - grid.blockSize/2 - grid.offsetY

        block.placeholder = display.newRect(block.x, block.y, block.width, block.height)
        block.placeholder.isVisible = false
        gridGroup: insert(block.placeholder)
        
        block.isEnabled = true
        block.id = #slotContainer + 1
        block.isFocus = false
        
        block:addEventListener("touch", blockSwipe)
        slotContainer[#slotContainer + 1] = block           
     end
   end
   
   gridGroup.topLeft = {x = slotContainer[1].x, y = slotContainer[1].y}
   gridGroup.numOfBlocks = cols * rows
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
  if (event.other.name == "GridContainer" and event.phase == 'ended') then
      print("Grid Container Detected By Upper Sensor with id: "..event.other.id)
      local matchesLeft = event.other.numOfBlocks / 3
      updateScore(matchesLeft * -2, {
          startColor = {1, 0, 0}
      })
      removeGridFromGlobalTable(event.other.id)
  end
end

function isBlockOnRightEdge (block)
    local parentGroup = block.parent
    local gridSize = parentGroup.size
    local totalGridSize = gridSize.rows * gridSize.cols

    return (block.id > (totalGridSize - gridSize.rows))
end

function isBlockOnLeftEdge (block)
  local parentGroup = block.parent
  return (block.id <= parentGroup.size.rows)
end

function isBlockOnUpperEdge(block)
  local parentGroup = block.parent
  local gridSize = parentGroup.size

  return (((block.id - 1) % gridSize.rows) == 0)
end

function isBlockOnBottomEdge(block)
  local parentGroup = block.parent
  local gridSize = parentGroup.size

  return ((block.id % gridSize.rows) == 0)
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
  local blockAPlaceholder = blockA.placeholder
  local blockBPlaceholder = blockB.placeholder

  blockA.id = blockBID
  blockB.id = blockAID
  blockA.placeholder = blockBPlaceholder
  blockB.placeholder = blockAPlaceholder

  slotContainer[blockAID] = blockB
  slotContainer[blockBID] = blockA

  transition.to(blockA, {time = 500, x = blockA.placeholder.x, y = blockA.placeholder.y})
  transition.to(blockB, {time = 500, x = blockB.placeholder.x, y = blockB.placeholder.y})

end

function getAbsolutePosition(object)
 if (object == nil) then
     print("Object is nil")
     return nil
 end

 local xpos, ypos = object:localToContent(0,0)
 return {x = xpos, y = ypos}
end

function getGridlocation(gridGroup)
    local blockSize = gridGroup.blockSize
    local shapeWidth = gridGroup.shapeWidth
    local shapeHeight = gridGroup.shapeHeight
end

function blockSwipe(event)
   if (gameState == "PAUSED" or gameState == "HALT") then
       return true
   end
   local parentGroup = event.target.parent
   local slotContainer = parentGroup.slotContainer

   if (event.phase == "began") then
     event.target.isFocus = true
     display.getCurrentStage():setFocus(event.target)
   elseif (event.target.isFocus) then
     if (event.phase == "ended" or event.phase == "cancelled") then

        local horizontalSwipeMagnitude = event.x - event.xStart
        local verticalSwipeMagnitude = event.y - event.yStart
        local swipeDirection = getDominant_Swipe_Direction(horizontalSwipeMagnitude, verticalSwipeMagnitude)
         
         if (swipeDirection == "HORIZONTAL") then
             if (horizontalSwipeMagnitude < 0) then
                 local idA = event.target.id
                 local idB = idA - parentGroup.size.rows
                 if (isBlockOnLeftEdge(event.target) == false) then
                    local leftBlock = slotContainer[idB]
                    swapBlocks(event.target, leftBlock)
                 end               
             elseif (horizontalSwipeMagnitude > 0) then
                 local idA = event.target.id
                 local idB = idA + parentGroup.size.rows
                 if (isBlockOnRightEdge(event.target) == false) then
                    local rightBlock = slotContainer[idB]
                    swapBlocks(event.target, rightBlock)
                 end     
             end
         elseif (swipeDirection == "VERTICAL") then
             if (verticalSwipeMagnitude < 0) then
                 local idA = event.target.id
                 local idB = idA - 1
                 if (isBlockOnUpperEdge(event.target) == false) then
                    local upperBlock = slotContainer[idB]
                    swapBlocks(event.target, upperBlock)               
                 end  
             elseif (verticalSwipeMagnitude > 0) then
                 local idA = event.target.id
                 local idB = idA + 1
                 if (isBlockOnBottomEdge(event.target) == false) then
                    local lowerBlock = slotContainer[idB]
                    swapBlocks(event.target, lowerBlock)
                 end               
             end
         end
      
         event.target.isFocus = false 
         display.getCurrentStage():setFocus(nil)

         local blocksToRemove = getMatchedBlocks(parentGroup)
         removeMatchedBlocks(blocksToRemove, true)

         if (parentGroup.numOfBlocks == 0) then
             local position = getAbsolutePosition(parentGroup.backdrop)
             smokeAffect.start(position.x, position.y, spawnLayer)
             removeGridFromGlobalTable(parentGroup.id)
         end  
     end
   end

   return true
end

function spawnGrid(x, y, rows, cols)
   local sizeofBlock = centerX/6
   local blockOffset = 5

   local defaultOptions = {
      blockSize = sizeofBlock,
      offsetX = blockOffset,
      offsetY = blockOffset,
      blockCornerRadius = 5,
   }
   
   if (type(x) == 'number') then
       defaultOptions['xpos'] = x
   end

   if (type(y) == 'number') then
       defaultOptions['ypos'] = y
   end

   if (type(rows) == 'number') then
       defaultOptions['rows'] = rows
   end

   if (type(cols) == 'number') then
       defaultOptions['cols'] = cols
   end

   local gridsTable = bin.grids
   local grid_group = createGridGroup(defaultOptions)

   grid_group.name = "GridContainer"
   grid_group.id = #gridsTable + 1

   local slotContainer = grid_group.slotContainer
   local gridTopLeft = grid_group.topLeft

   -- Creating a custom physics shape since display groups behave differently when adding physics
   local leftCorner = { x = gridTopLeft.x - (sizeofBlock/2), y = gridTopLeft.y - (sizeofBlock/2) }
   local rightCorner = { x = leftCorner.x + grid_group.totalShapeWidth, y = leftCorner.y }
   local bottomLeftCorner = { x = leftCorner.x, y = leftCorner.y + grid_group.totalShapeHeight }
   local bottomRightCorner = { x = rightCorner.x, y = rightCorner.y + grid_group.totalShapeHeight }

   local gridPhysicsShape = {

         leftCorner.x, leftCorner.y, 
         rightCorner.x, rightCorner.y,
         bottomRightCorner.x, bottomRightCorner.y,
         bottomLeftCorner.x, bottomLeftCorner.y, 
         leftCorner.x, leftCorner.y
   }

   local backdrop = display.newRoundedRect(
       grid_group.topLeft.x + grid_group.totalShapeWidth/2 - sizeofBlock/2, 
       grid_group.topLeft.y + grid_group.totalShapeHeight/2 - sizeofBlock/2, 
       grid_group.totalShapeWidth + 10, 
       grid_group.totalShapeHeight + 10,
       5
   )
   backdrop: setFillColor(1, 1, 1, 0.5)
   backdrop.strokeWidth = 2
   backdrop: setStrokeColor(0, 0, 0, 0.5)
   grid_group: insert(backdrop)
   grid_group.backdrop = backdrop

   for i = 1, #slotContainer do
       grid_group: insert(slotContainer[i])
   end

   local blocks = getMatchedBlocks(grid_group)
   removeMatchedBlocks(blocks, false)

   physics.addBody(grid_group, "dynamic", { shape = gridPhysicsShape, isSensor = true})
   gridsTable[#gridsTable + 1] = grid_group 

   spawnLayer: insert(grid_group)

   if (grid_group.numOfBlocks == 0) then
       removeGridFromGlobalTable(grid_group.id)
       spawnGrid()
   end 
end

function scroll(options, group)
  for i = 1, #options do
    local asset = display.newImage(options[i].path, options[i].xstart, options[i].ystart)
    asset.duration = options[i].duration
    transition.to(asset, {
       delay = options[i].delay, 
       time = options[i].duration, 
       x = options[i].xend, 
       y = options[i].yend, 
       iterations = 0,
       rotation = options[i].rotation,
       onRepeat = function() asset.x = math.random(0, width) end
    })
    group: insert(asset)
  end
end

function parallaxScroll()
    if (parallax_clouds_one.y > parallax_clouds_one.height + 50) then
        parallax_clouds_one.y = parallaxWrapPosition.y - 70
    else
        parallax_clouds_one.y = parallax_clouds_one.y + 0.5
    end

    if (parallax_clouds_two.y > parallax_clouds_two.height + 50) then
        parallax_clouds_two.y = parallaxWrapPosition.y - 70
    else
        parallax_clouds_two.y = parallax_clouds_two.y + 0.5
    end

    if (parallax_clouds_three.y > parallax_clouds_three.height + 50) then
        parallax_clouds_three.y = parallaxWrapPosition.y - 70
    else
        parallax_clouds_three.y = parallax_clouds_three.y + 0.5
    end
end

function changePausePlay(event)
    if (event.target.id == "play") then
        event.target.fill = pauseTexture
        event.target.id = "pause"
        resumeGame()
    elseif (event.target.id == "pause") then
        event.target.fill = playTexture
        event.target.id = "play"
        pauseGame()
    end
end

function createPausePlayButton(x, y, sceneGroup)
   -- adding delay because this button is enabled before all related objects are initialized.
    local ui = bin.UI
    timer.performWithDelay(1000, function()
        pausePlayButton = display.newRect(centerX, centerY, 31, 40)
        pausePlayButton.fill = pauseTexture
        pausePlayButton.width, pausePlayButton.height = 12, 12
        pausePlayButton.alpha = 0.8
        pausePlayButton.id = "pause" 
        pausePlayButton: addEventListener("tap", changePausePlay) 
        pausePlayButton.x, pausePlayButton.y = x, y 
        ui[#ui + 1] = pausePlayButton
        sceneGroup: insert(pausePlayButton)
    end, 1)    
end

function createQuitGameButton(x, y, sceneGroup)
    local ui = bin.UI
    timer.performWithDelay(1000, function()
        quitGameButton = widget.newButton({
            defaultFile = "./Images/UI/close.png",
            width = 15,
            height = 15,
            onPress = function()
                haltGameActivity()
                dialogBox.show()
            end
        })
        quitGameButton.x, quitGameButton.y = x, y
        ui[#ui + 1] = quitGameButton
        sceneGroup: insert(quitGameButton)
    end, 1)
end

function imageTransition(firstImage, secondImage, duration)
    if (firstImage == nil or secondImage == nil) then
        print("Warning: Game.imageTransition has invalid arguments")
        return false
    end
    local secondFadeOutTransition
    local firstFadeOutTransition = function () transition.fadeOut(secondImage, {time = duration, onComplete = secondFadeOutTransition}) end
    secondFadeOutTransition = function() transition.fadeIn(secondImage, {time = duration, onComplete = firstFadeOutTransition}) end

    firstFadeOutTransition()
end
-- delay refers to when to start changing scene, while duration defines the amount of time it takes for the scene to fade
function changeScene(options)
    local ops = options or {}
    local duration = ops.duration or 1000
    local delay = ops.delay or 500
    local sceneName = ops.sceneName or "Scenes.Menu"
    local parameters = ops.params
    local effect = ops.effect or "fade"

    timer.performWithDelay(delay, function()
        composer.gotoScene(sceneName, {
        effect = effect,
        time = duration,
        params = parameters
       })
    end, 1)
end

function haltGameActivity()
    gameState = "HALT"
    pausePlayButton: removeEventListener("tap", changePausePlay)

    displayOverLay({
        color = {0, 0, 0, 0.5}
    })
    physics.pause()
end

function unhaltGameActivity()
    hideOverLay()
    physics.start()
    pausePlayButton: addEventListener("tap", changePausePlay)
    gameState = "PLAY"
end

function displayOverLay(options)
    gameOverLay: setFillColor(unpack(options.color))
    gameOverLay.isVisible = true
end

function hideOverLay()
    gameOverLay.isVisible = false
end

function pauseGame()
    if (gridSpawnTimer ~= nil) then
        timer.pause(gridSpawnTimer)
    end
    Runtime: removeEventListener("enterFrame", parallaxScroll)
    physics.pause()
    gameState = "PAUSED"
    pauseGameText.isVisible = true
    displayOverLay({
        color = {0, 0, 0, 0.5}
    })
    quitGameButton: setEnabled(false)
    showGameStatsText(gameStatsText)
end

function resumeGame()
    if (gridSpawnTimer ~= nil) then
        timer.resume(gridSpawnTimer)
    end
    Runtime: addEventListener("enterFrame", parallaxScroll)
    physics.start()

    gameState = "PLAY"
    pauseGameText.isVisible = false
    hideOverLay()
    quitGameButton: setEnabled(true)
    hideGameStatsText(gameStatsText)
end
 -- Get current user high scores etc.
function getUserGameData()
    return file.loadJson("user.json", system.DocumentsDirectory)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local firstGradientSky = display.newImage("./Images/Backgrounds/sky_gradient_one.png", centerX, centerY)
    local secondGradientSky = display.newImage("./Images/Backgrounds/sky_gradient_two.png", centerX, centerY)
    imageTransition(firstGradientSky, secondGradientSky, 15000)

    parallax_clouds_one = display.newImage("./Images/Parallax/parallax_clouds_one.png", centerX, centerY)
    parallax_clouds_two = display.newImage("./Images/Parallax/parallax_clouds_two.png", centerX, centerY - parallax_clouds_one.height)
    parallax_clouds_three = display.newImage("./Images/Parallax/parallax_clouds_two.png", centerX, centerY - parallax_clouds_two.height)

    parallaxWrapPosition = {x = parallax_clouds_two.x, y = parallax_clouds_two.y}
     
    upperBoundary = display.newRect(centerX, -35, width, 5)
    upperBoundary.isVisible = false

     --adding display elements to scene group
    sceneGroup: insert(firstGradientSky)
    sceneGroup: insert(secondGradientSky)
    sceneGroup: insert(parallax_clouds_one)
    sceneGroup: insert(parallax_clouds_two)
    sceneGroup: insert(parallax_clouds_three)
    sceneGroup: insert(upperBoundary)
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        --spawn the first grid then apply the delay
        physics.start()
        spawnGrid(centerX - 100, centerY, 4, 3)
        gridSpawnTimer = timer.performWithDelay(spawnTime, spawnGrid, 0)
        
        physics.addBody(upperBoundary, "static")
        upperBoundary: addEventListener("collision", onUpperSensorCollide)
        Runtime: addEventListener("enterFrame", parallaxScroll)

        local ui = bin.UI

        pauseGameText = display.newText("PAUSED", centerX, centerY, "Fonts/BigBook-Heavy", 20)
        pauseGameText: setFillColor(0.93, 0.57, 0.13)
        pauseGameText.isVisible = false
        ui[#ui + 1] = pauseGameText

        gameOverLay = display.newRect(centerX, centerY, actualWidth, actualHeight)
        gameOverLay: setFillColor(0, 0, 0, 0.5)
        gameOverLay.isVisible = false
        ui[#ui + 1] = gameOverLay

        sceneGroup: insert(spawnLayer)

        headerFrame = display.newRoundedRect(centerX, centerY - actualHeight/2 + 10, actualWidth + 7, 35, 10)
        headerFrame: setFillColor(0.85, 0.65, 0.13, 0.6)
        ui[#ui + 1] = headerFrame

        scoreText = display.newText("0", centerX, headerFrame.y, "Fonts/BigBook-Heavy", 22)
        scoreText: setFillColor(0.5, 0.5, 0.5)
        scoreText = score.new("", scoreText, 0)
        ui[#ui + 1] = scoreText

        dialogBox = dialog.create({
            bodyText = "Are You Sure You Want To Quit ?",
            height = height/8,
            dialogType = dialog.confirmation,
            headerColor = {0.78, 0.47, 0.15},
            alpha = 0.7,
            onConfirm = function()
               dialogBox.hide()
               changeScene({
                   duration = 300,
                   delay = 10
               })
            end,
            onDeny = function()
               dialogBox.hide()
               unhaltGameActivity()
            end
        })
        ui[#ui + 1] = dialogBox

        gameStatsText = createGameStatsText()

        sceneGroup: insert(headerFrame)
        sceneGroup: insert(gameOverLay)
        sceneGroup: insert(pauseGameText)
        sceneGroup: insert(scoreText)
        sceneGroup: insert(dialogBox.dialogGroup)
        sceneGroup: insert(gameStatsText)

        createPausePlayButton(width - 28, headerFrame.y + 3, sceneGroup)
        createQuitGameButton(centerX - width/2 + (15/2) + 5, headerFrame.y + 3, sceneGroup)

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

        -- removing event listeners
        upperBoundary: removeEventListener("collision", onUpperSensorCollide)
        pausePlayButton: removeEventListener("touch", changePausePlay)
        Runtime: removeEventListener("enterFrame", parallaxScroll)
       
        -- cleaning up other scene objects
        score.cleanUp()

        local ui, grids = bin.UI, bin.grids
        for i = 1, #ui do  display.remove(ui[i]) end 
        for i = 1, #grids do display.remove(grids[i]) end
            
        if (gameState == "HALT") then unhaltGameActivity() end

        resetGameData()
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