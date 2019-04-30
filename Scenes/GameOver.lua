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

local rowHeight = 30
local gameStatsLength
local gameObjectivesLength = 10

local gameData
local objectivesList
local statsList

local leaderBoardsButton
local mainMenuButton

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
            rowHeight = rowHeight,
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
    local titleBar = display.newRect(0, 0, actualWidth, 40)
    titleBar: setFillColor(0.3)
    titleBar.anchorX, titleBar.anchorY = 0, 0
    backgroundLayer: insert(titleBar)
    -- screen title text that rests on the title bar
    local titleText = display.newText("Game Over", centerX, 0, "Fonts/BigBook-Heavy", 24)
    titleText.anchorY = 0
    titleText: setFillColor(1)
    backgroundLayer: insert(titleText)
    -- stats list object: when binded with the dialog box object can display player stats as a dialog box
    statsList = widget.newTableView({
        height = (gameStatsLength * rowHeight),
        width = actualWidth - 25,
        onRowRender = gameStatsRowRender,
        isLocked = true
    })
   statsList.x = centerX
   statsList.y = titleBar.y + titleBar.height + rowHeight + 10

   insertToList(statsList, gameData)
   -- objectives list object: when binded with the dialog box object can display player objectives and achievements 
   objectivesList = widget.newTableView({
       height = 6 * rowHeight,
       width = actualWidth - 25,
       onRowRender = onRowRender 
   })
   objectivesList.x = centerX
   objectivesList.y = statsList.y + statsList.height + 50

   local statsDialog = dialogBox.infoList(statsList, {
        title = "Game Stats"
   })
   foregroundLayer: insert(statsDialog)

   local objectivesDialog = dialogBox.infoList(objectivesList, {
        title = "Game Objectives"
   })
   foregroundLayer: insert(objectivesDialog)

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

    if (statsList ~= nil) then
        updateList(statsList, gameData)
    end

    if (objectivesList ~= nil) then
        --updateList(objectivesList, objectivesData)    
    end


    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen
 
    elseif ( phase == "did" ) then

    -- screen buttons
       leaderBoardsButton = widget.newButton({
            label = "LeaderBoards",
            shape = "roundedrect",
            fillColor = {default = {0.2, 0.6, 0}, over = {0.2, 0.6, 0, 0.5}},
            font = "Fonts/BigBook-Heavy",
            width = (actualWidth - 10)/2,
            height = 50,
            fontSize = 16,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
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
            width = (actualWidth - 15)/3,
            height = 50,
            fontSize = 16,
            emboss = true,
            cornerRadius = 10,
            strokeWidth = 3,
            strokeColor = {default = {1, 1, 1}, over = {1, 1, 1}},
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