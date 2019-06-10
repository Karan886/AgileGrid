local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local blur = require "Modules.Blur"
local slidingList = require "Modules.SlidingList"

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

local objectivesList
local statsList

local leaderBoardsButton
local mainMenuButton
local titleBar
local numTrophies = 0
local numRevivalGems = 0

local matchesDisplay
local doubleMatchesDisplay
local tripleMatchesDisplay
local finalScoreDisplay

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

function createDataRow(ops)
    -- Parse options
    local name = ops.name or "Data-row"
    local prompt = ops.prompt or "Prompt Text"
    local value = ops.value or 0
    local yoffset = ops.yoffset or 0
    local imgsrc = ops.imgsrc or nil

    local x,y = 0, yoffset
    if (prompt == nil or value == nil) then
        print("GameOver.lua: in function createDataRow arguments #2 or #3 is nil. Setting defaults...")
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

    local valueText = display.newText(value, actualWidth - 20, row.y, "Fonts/BigBook-Heavy", 10)
    valueText.anchorX, valueText.anchorY = 1, 0
    valueText.y = row.y + (row.height/2) - (valueText.height/2)
    valueText: setFillColor(0, 0, 0)

    group: insert(row)
    group: insert(promptText)
    group: insert(valueText)

    if (imgsrc ~= nil) then
        local icon = display.newImage(imgsrc)
        icon.anchorX, icon.anchorY = 1, 0
        icon.width, icon.height = 15, 18
        icon.x, icon.y = valueText.x + 15, valueText.y
        group: insert(icon)
    end

    group.height = row.height

    -- Trying to override (x,y) position on screen since we are packing into a group object
    group.xpos = row.x
    group.ypos = row.y
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

function createFinalScoreDisplay(x, y, gameData)
    if (gameData == nil) then
        print("GameOver.lua: in function createFinalScoreDisplay gameData object is nil.")
        return nil
    end
    local group = display.newGroup()

    local imgbg = display.newRect(x, y, actualWidth, actualWidth/4)
    imgbg.anchorX, imgbg.anchorY = 0, 0

    local prefix = display.newText(
        "Final Score = "..gameData["matches"].." + "..gameData["doubleMatches"].." + "..gameData["tripleMatches"].." = ",
        15,
        imgbg.y + imgbg.height/2, 
        "Fonts/BigBook-Heavy",
        12
    )
    prefix.anchorX, prefix.anchorY = 0, 0
    prefix.y = prefix.y - prefix.height/2
    prefix: setFillColor(0)

    local score = display.newText(
        gameData["matches"] + gameData["doubleMatches"] + gameData["tripleMatches"],
        prefix.x + prefix.width + 3,
        prefix.y,
        "Fonts/BigBook-Heavy",
        12
    )
    score.anchorX, score.anchorY = 0, 0
    score: setFillColor(1, 0, 0)

    group.ypos = imgbg.y
    group: insert(imgbg)
    group: insert(prefix)
    group: insert(score)

    return group
end

function updateFinalScoreDisplay(prefix, value)
    if (finalScoreDisplay == nil) then
        print("GameOver.lua: in function updateFinalScoreDisplay finalScoreDisplay object is nil.")
        return false
    end
    finalScoreDisplay[2].text = prefix
    finalScoreDisplay[3].text = value
    return true
end

function updateImageDisplay(obj, value)
    if (obj == nil) then
        print("GameOver.lua: in function updateImageDisplay argument #1 is nil.")
        return false
    end
    if (value == nil) then
        print("GameOver.lua: in function updateImageDisplay argument #2 is nil")
        return false
    end
    -- 3rd element in object array is (which is actually a display group object) is the associated value text object
    obj[3].text = value
    return true
end
 

function scene:create( event )
    print("Switched to Game Over scene....")
    local sceneGroup = self.view
    local params = event.params
    local gameData = params.GameData
    --Add final score to the stats list
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

    local trophiesRow = createDataRow({
        name = "TrophiesEarned",
        prompt = "Trophies Earned:",
        value = numTrophies,
        yoffset = titleBar.height,
    })
    foregroundLayer: insert(trophiesRow)
    
    local revivalGemRow = createDataRow({
        name = "GemsEarned",
        prompt = "Revival Gems:",
        value = "x"..numRevivalGems,
        yoffset = titleBar.height + trophiesRow.height,
        imgsrc = "Images/ruby.png"
    })
    foregroundLayer: insert(revivalGemRow)

    -- create interacive blocks that display user stats for previously finished game

    matchesDisplay = createImageDisplay(
        "Images/SquareContainer.png", 
        revivalGemRow.xpos, 
        revivalGemRow.ypos + revivalGemRow.height, 
        actualWidth/3, 
        actualWidth/4,
        "Matches",
        gameData["matches"]
    )
    foregroundLayer: insert(matchesDisplay)

    doubleMatchesDisplay = createImageDisplay(
        "Images/SquareContainer.png",
        centerX - actualWidth/6,
        revivalGemRow.ypos + revivalGemRow.height,
        actualWidth/3,
        actualWidth/4,
        "x2 Matches",
        gameData["doubleMatches"]
    )
    foregroundLayer: insert(doubleMatchesDisplay)

    tripleMatchesDisplay = createImageDisplay(
        "Images/SquareContainer.png",
         actualWidth - actualWidth/3,
         revivalGemRow.ypos + revivalGemRow.height,
         actualWidth/3,
         actualWidth/4,
         "x3 Matches",
         gameData["tripleMatches"]
    )
    foregroundLayer: insert(tripleMatchesDisplay)

    -- create a final score data block (diff from the data blocks above so cannot use same function)
    finalScoreDisplay = createFinalScoreDisplay(0, tripleMatchesDisplay.ypos + tripleMatchesDisplay.height, gameData)
    foregroundLayer: insert(finalScoreDisplay)

    local objectivesTitleBar = display.newRect(
        centerX, 
        finalScoreDisplay.ypos + finalScoreDisplay.height + 2,
        actualWidth,
        rowHeight 
       )
       objectivesTitleBar.anchorY = 0
       objectivesTitleBar: setFillColor(0, 0, 0, 0.7)
       objectivesTitleBar: setStrokeColor(0)
       objectivesTitleBar.strokeWidth = 1

    local objectivesTitle = display.newText("Objectives/Achievements", 5, objectivesTitleBar.y, "Fonts/BigBook-Heavy", 14)
    objectivesTitle.anchorX, objectivesTitle.anchorY = 0, 0
    foregroundLayer: insert(objectivesTitleBar)
    foregroundLayer: insert(objectivesTitle)

    
    local objectivesList = slidingList.createSlidingList({
        x = 0,
        y = objectivesTitleBar.y + objectivesTitleBar.height + 15
    })
    foregroundLayer:insert(objectivesList)
   
    sceneGroup: insert(backgroundLayer)
    sceneGroup: insert(foregroundLayer) 
end
 
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen
 
    elseif ( phase == "did" ) then

        local params = event.params
        local gameData = params.GameData

        -- update score display
        updateImageDisplay(matchesDisplay, gameData["matches"])
        updateImageDisplay(doubleMatchesDisplay, gameData["doubleMatches"])
        updateImageDisplay(tripleMatchesDisplay, gameData["tripleMatches"])
        
        updateFinalScoreDisplay(
            "Final Score = "..gameData["matches"].." + "..gameData["doubleMatches"].." + "..gameData["tripleMatches"].." = ",
            gameData["matches"] + gameData["doubleMatches"] + gameData["tripleMatches"]
        )

    -- screen buttons
       leaderBoardsButton = widget.newButton({
            label = "LeaderBoards",
            shape = "roundedrect",
            fillColor = {default = {0.2, 0.6, 0}, over = {0.2, 0.6, 0, 0.5}},
            font = "Fonts/BigBook-Heavy",
            width = (actualWidth - 10)/3,
            height = 30,
            fontSize = 10,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {0, 0, 0}, over = {0, 0, 0}},
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
            height = 30,
            fontSize = 10,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {0, 0, 0}, over = {0, 0, 0}},
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