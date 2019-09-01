local composer = require "composer"
local scene = composer.newScene()

local blur = require "Modules.Blur"
local widget = require "widget"
local file = require "Modules.File"
local ui = require "Modules.UI"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Global objects
local pauseContainer

local blurLayer = display.newGroup()
local gameStatsLayer = display.newGroup()
local buttonsLayer = display.newGroup()
local settingsLayer = display.newGroup()

function triggerHideMenuOverlay(gameState)
    if (gameState == nil) then
        print("cannot hide pause menu overlay because state is not defined")
        return false
    end
    state = gameState
    composer.hideOverlay() 
    return true
end

function scene:create(event)
    print("switched to pause menu")
    local sceneGroup = self.view
    local blurOverlay = blur.getBlurredImage({
        xmin = 0,
        xmax = actualWidth,
        ymin = -15,
        ymax = actualHeight,
    })
    blurLayer: insert(blurOverlay)

    pauseContainer = display.newImage("Images/UI/pauseContainer.png", centerX, centerY)
    local menuTitleParams = {
        "Pause Menu", 
        centerX, 
        pauseContainer.y - pauseContainer.height / 2,
        "Fonts/BigBook-Heavy",
        25
    }
    local menuTitle = display.newText(unpack(menuTitleParams))
    menuTitle.y = menuTitle.y + menuTitle.height / 2 + 2
    menuTitle: setFillColor(0)
    
    -- Create buttons on a separate layer
    local resumeButton = widget.newButton({
        label = "Resume",
        font = "Fonts/BigBook-Heavy",
        labelColor = {default = {0, 0.6, 0}, over = {0, 0.6, 0, 0.8}},
        onEvent = function(event) 
            if (event.phase == "ended")then
                triggerHideMenuOverlay("RESUME") 
            end
        end
    })
    resumeButton.anchorX, resumeButton.anchorY = 0, 1
    resumeButton.x = pauseContainer.x - pauseContainer.width + resumeButton.width / 2 + 10
    resumeButton.y = pauseContainer.y + pauseContainer.height / 2
    buttonsLayer: insert(resumeButton)

    local quitButton = widget.newButton({
        label = "Quit",
        font = "Fonts/BigBook-Heavy",
        labelColor = {default = {0.6, 0, 0}, over = {0.6, 0, 0, 0.8}}
    })
    quitButton.anchorX, quitButton.anchorY = 1, 1
    quitButton.x = pauseContainer.x + pauseContainer.width - quitButton.width / 2
    quitButton.y = pauseContainer.y + pauseContainer.height / 2
    buttonsLayer: insert(quitButton)

    sceneGroup: insert(blurLayer)
    sceneGroup: insert(pauseContainer)
    sceneGroup: insert(menuTitle)
    sceneGroup: insert(buttonsLayer)
end

function scene:show(event)
    local sceneGroup = self.view
    local params = event.params
    local gameStats = params.gameData

    local statsObjectY = centerY - pauseContainer.height / 4 + 25
    local statsObjectWidth = pauseContainer.width - 17
    local statsObjectHeight = pauseContainer.height / 2

    if (event.phase == "will") then
        ui.displayGameStats({
            data = gameStats,
            layer = gameStatsLayer,
            x = centerX,
            y = statsObjectY,
            width = statsObjectWidth,
            height = statsObjectHeight,
            yOffsetFactor = 1.5,
            fontSize = 20,
            font = "Fonts/Futura-Bold",
            alias = {
                tripleMatches = "Triple Matches:",
                doubleMatches = "Double Matches:",
                matches = "Matches:"
            }
        })

        ui.displaySettings({
            xStart = pauseContainer.x - pauseContainer.width / 2 + 15,
            yStart = statsObjectY + statsObjectHeight / 4,
            layer = settingsLayer 
        })
    
    elseif (event.phase == "did") then

    end
    sceneGroup:insert(gameStatsLayer)
    sceneGroup:insert(settingsLayer)
end

function scene:hide(event)
    local parent = event.parent
    if (event.phase == "will") then
        parent:resumeGameActivity("PLAY")
    elseif (event.phase == "did") then
        -- parent:gameOver(0)
    end
end

function scene:destroy()
    local sceneGroup = self.view
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