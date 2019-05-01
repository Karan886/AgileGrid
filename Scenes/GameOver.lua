local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local blur = require "Modules.Blur"
local dialogBox = require "Modules.DialogBox"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local backgroundLayer = display.newGroup()
local foregroundLayer = display.newGroup()

local listRowHeight = 30
local rowHeight = 30
local gameStatsLength
local gameObjectivesLength = 10

local gameData
local objectivesList
local statsList

local leaderBoardsButton
local mainMenuButton
local titleBar
local numTrophies = 0
local numRevivalGems = 0

local buttons = {leaderBoardsButton, mainMenuButton}

function gameStatsRowRender(event)
    local row = event.row
    local rowWidth, rowHeight = row.contentWidth, row.contentHeight

    --local rowItem = display.newText(row, row.params.item..":", 0, 0, "Fonts/BigBook-Heavy", 12)
    local rowItem = display.newText(row, row.params.item..":", 5, 0, "Fonts/BigBook-Heavy", 12)
    rowItem.alpha = 0.7
    rowItem:setFillColor(0)
    rowItem.anchorX = 0
    rowItem.y = rowHeight/2

    --local value = display.newText(row, row.params.value, 0, 0, "Fonts/BigBook-Heavy", 12)
    local value = display.newText(row, row.params.value, 0, 0, "Fonts/BigBook-Heavy", 12)
    value.alpha = 0.7
    value: setFillColor(0)
    value.anchorX = 1
    value.x = rowWidth - 5
    value.y = rowHeight/2
end

function addFinalScoreParameter()
    if (gameData ~= nil) then
        gameData[#gameData + 1] = {
            item = "final score",
            value = gameData[1].value + gameData[2].value + gameData[3].value
        }
    end
end

function insertToList(list, dataset) 
    if (list == nil or dataset == nil) then
        print("GameOver.lua: in function insertToList arguments are insufficient.")
        return false
    end
    for i=1, #dataset do
        list: insertRow({
            rowHeight = listRowHeight,
            params = dataset[i]
        })
    end
    return true
end

function updateList(list, dataset)
    if (list == nil or dataset == nil) then
        print("GameOver.lua: in function updateList arguments are insufficient.")
        return false
    end
    list: deleteAllRows()
    insertToList(list, dataset)
    return true
end

function disableButtons()
    for i=1, #buttons do
        if (buttons[i] == nil) then
            print("GameOver.lua: in function disableButtons element "..i.." is nil.")
            return false
        end
        buttons[i]: setEnabled(false)
    end
    return true
end

function enableButtons()
    for i=1, #buttons do
        if (buttons[i] == nil) then
            print("GameOver.lua: in function enableButtons element "..i.." is nil.")
            return false
        end
        buttons[i]: setEnabled(true)
        return true
    end
end

function createdDataRow(name, prompt, value, yoffset)
    local x,y = 0, yoffset
    if (prompt == nil or value == nil) then
        print("GameOver.lua: in function createdDataRow arguments #2 or #3 is nil. Setting defaults...")
        prompt = "Item"
        value = "Value"
    end

    local group = display.newGroup()
    group.name = name

    local row = display.newRect(x, y, actualWidth, rowHeight)
    row.anchorX, row.anchorY = 0, 0
    row: setFillColor(0.78, 0.47, 0.15, 0.5)
    row.strokeWidth = 2
    row: setStrokeColor(0, 0, 0, 0.7)

    local promptText = display.newText(prompt, 5, row.y, "Fonts/BigBook-Heavy", 10)
    promptText.anchorX, promptText.anchorY = 0, 0
    promptText.y = row.y + (row.height/2) - (promptText.height/2)
    promptText: setFillColor(0, 0, 0)

    local valueText = display.newText(value, actualWidth - 5, row.y, "Fonts/BigBook-Heavy", 10)
    valueText.anchorX, valueText.anchorY = 1, 0
    valueText.y = row.y + (row.height/2) - (valueText.height/2)
    valueText: setFillColor(0, 0, 0)

    group.height = row.height
    -- Trying to override (x,y) position on screen since we are packing into a group object
    group.xpos = row.x
    group.ypos = row.y

    group: insert(row)
    group: insert(promptText)
    group: insert(valueText)

    return group
end

function createImageDisplay(img, x, y, width, height, prompt, value)
    local group = display.newGroup()
    local bg = display.newImage(img, x, y)
    bg.width, bg.height = width, height
    bg.anchorX, bg.anchorY = 0, 0

    local promptText = display.newText(prompt, x + bg.width/2, y + bg.height/3, "Fonts/BigBook-Heavy", 10)
    promptText.anchorX, promptText.anchorY = 0, 0
    promptText.x = promptText.x - promptText.width/2
    promptText.y = promptText.y - promptText.height/2
    promptText: setFillColor(0, 0, 0)

    local valueText = display.newText(value, x + bg.width/2, bg.y + bg.height, "Fonts/BigBook-Heavy", 10)
    valueText.anchorX, valueText.anchorY = 0, 1
    valueText.x = valueText.x - valueText.width/2
    valueText.y = valueText.y - bg.height/3
    valueText: setFillColor(0, 0, 0)

    group.xpos = bg.x
    group.ypos = bg.y

    group: insert(bg)
    group: insert(promptText)
    group: insert(valueText)

    return group
end

function scene:create( event )
    print("Switched to Game Over scene....")
    local sceneGroup = self.view
    local params = event.params
    gameData = params.GameData
    --Add final score to the stats list
    addFinalScoreParameter()
    gameStatsLength = #gameData

    -- screen background
    local whiteBg = display.newRect(0, 0, actualWidth, actualHeight)
    whiteBg.anchorX, whiteBg.anchorY = 0, 0
    whiteBg: setFillColor(0.9)
    backgroundLayer: insert(whiteBg)
    -- ta/bar on top of screen for dislpaying title
    titleBar = display.newRect(0, 0, actualWidth, 40)
    titleBar: setFillColor(0.3)
    titleBar.anchorX, titleBar.anchorY = 0, 0
    backgroundLayer: insert(titleBar)
    -- screen title text that rests on the title bar
    local titleText = display.newText("Game Over", centerX, 0, "Fonts/BigBook-Heavy", 24)
    titleText.anchorY = 0
    titleText: setFillColor(1)
    backgroundLayer: insert(titleText)

    local trophiesRow = createdDataRow("TrophiesEarned", "Trophies Earned:", numTrophies, titleBar.height)
    foregroundLayer: insert(trophiesRow)

    local revivalGemRow = createdDataRow("GemsEarned", "Revival Gems:", numRevivalGems, titleBar.height + trophiesRow.height)
    foregroundLayer: insert(revivalGemRow)

    local matchesDisplay = createImageDisplay(
        "Images/SquareContainer.png", 
        revivalGemRow.xpos, 
        revivalGemRow.ypos + revivalGemRow.height, 
        actualWidth/4, 
        actualWidth/4,
        "Matches",
        0
    )
    foregroundLayer: insert(matchesDisplay)

    local doubleMatchesDisplay = createImageDisplay(
        "Images/SquareContainer.png",
        centerX - actualWidth/4 + 10,
        revivalGemRow.ypos + revivalGemRow.height,
        actualWidth/3,
        actualWidth/4,
        "x2 matches",
        0
    )
    foregroundLayer: insert(doubleMatchesDisplay)

    local tripleMatchesDisplay = createImageDisplay(
        "Images/SquareContainer.png",
         actualWidth - actualWidth/3,
         revivalGemRow.ypos + revivalGemRow.height,
         actualWidth/3,
         actualWidth/4,
         "x3 matches",
         0
    )
    foregroundLayer: insert(tripleMatchesDisplay)

    local finalScoreDisplay = createImageDisplay(
        "Images/CircleContainer.png",
        centerX - actualWidth/6,
        doubleMatchesDisplay.y + doubleMatchesDisplay.height + actualWidth/3 + 10,
        actualWidth/4,
        actualWidth/4,
        "Score",
        0
    )
    foregroundLayer: insert(finalScoreDisplay)
   
    sceneGroup: insert(backgroundLayer)
    sceneGroup: insert(foregroundLayer) 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    local params = event.params
    gameData = params.GameData

    addFinalScoreParameter()
    gameStatsLength = #gameData

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen
 
    elseif ( phase == "did" ) then

    -- screen buttons
       leaderBoardsButton = widget.newButton({
            label = "LeaderBoards",
            shape = "roundedrect",
            fillColor = {default = {0.2, 0.6, 0}, over = {0.2, 0.6, 0, 0.5}},
            font = "Fonts/BigBook-Heavy",
            width = (actualWidth - 10)/3,
            height = 50,
            fontSize = 10,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {0, 0, 0, 0.5}, over = {0, 0, 0, 0.5}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            onEvent = function(event) 
                if (event.phase == "ended")then
                    disableButtons()
                end
            end
        })
       leaderBoardsButton.anchorX = 1
       leaderBoardsButton.anchorY = 1
       leaderBoardsButton.x = actualWidth - 5
       leaderBoardsButton.y = actualHeight - 10

       mainMenuButton = widget.newButton({
            label = "Menu",
            shape = "roundedrect",
            fillColor = {default = {0.78, 0.47, 0.15}, over = {0.78, 0.47, 0.15, 0.5}},
            font = "Fonts/BigBook-Heavy",
            width = (actualWidth - 15)/4,
            height = 50,
            fontSize = 10,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {0, 0, 0, 0.5}, over = {0, 0, 0, 0.5}},
            labelColor = {default = {1, 1, 1}, over = {1, 1, 1}},
            onEvent = function(event) 
                if (event.phase == "ended")then
                    disableButtons()
                    composer.gotoScene("Scenes.Menu", {
                        effect = "fade",
                        time = 500
                    })
                end
            end
       })
       mainMenuButton.anchorX = 0
       mainMenuButton.anchorY = 1
       mainMenuButton.x = 5
       mainMenuButton.y = actualHeight - 10

       enableButtons()

       sceneGroup: insert(leaderBoardsButton)
       sceneGroup: insert(mainMenuButton)
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        
 
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