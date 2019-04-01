local composer = require("composer")
local scene = composer.newScene()

local widget = require("widget")
local blur = require "Modules.Blur"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

--global variables
local menuWidth = 200
local rowHeight = 30
local menuTitleBarHeight = 30

local menuTitleBarColor = {0.25, 0.25, 0.25}


local blurLayer = display.newGroup()

function alignLeft(obj, offset)
    if (obj == nil) then return false end
    obj.anchorX = 0
    obj.x = offset or 0
    return true
end

function alignRight(obj, parentWidth, offset)
    if (obj == nil) then return false end
    local mOffset = offset or 0
    obj.anchorX = 1
    obj.x = parentWidth - mOffset
    return true
end

function alignCenter(obj, parentHeight)
    obj.y = parentHeight * 0.5
    return true
end

function alignOnTop(obj, parent)
    if (parent == nil) then return false end
    obj.y = parent.y - (parent.height/2) - obj.height/2
    return true
end

function alignBelow(obj, parent)
    if (parent == nil) then return false end
    obj.anchorY = 0
    obj.y = parent.y + (parent.height/2)
    return true
end

function onRowRender(event)
    local row = event.row
    local rowWidth, rowHeight = row.contentWidth, row.contentHeight

    local rowItem = display.newText(row, row.params.item..":", 0, 0, "Fonts/BigBook-Heavy", 12)
    rowItem.alpha = 0.7
    rowItem:setFillColor(0)
    alignLeft(rowItem, 10)
    alignCenter(rowItem, rowHeight)

    local value = display.newText(row, row.params.value, 0, 0, "Fonts/BigBook-Heavy", 12)
    value.alpha = 0.7
    value: setFillColor(0)
    alignRight(value, rowWidth, 5)
    alignCenter(value, rowHeight)


end

 
function scene:create( event )
    print("Started pause menu overlay scene...")
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    local params = event.params
    local menuHeight = #params * rowHeight
    local blurOverlay = blur.getBlurredImage({
        xmin = 0,
        xmax = actualWidth,
        ymin = -15,
        ymax = actualHeight,
    })
    blurLayer: insert(blurOverlay)

    local listBox = widget.newTableView({
        left = centerX - (menuWidth/2),
        top = centerY - (menuHeight/2),
        height = menuHeight,
        width = menuWidth,
        onRowRender = onRowRender,
        isLocked = true
    })

    local rowOps = {
        rowHeight = rowHeight,
        lineColor = {0.5, 0.5, 0.5, 0.5},
    }

    for i = 1, #params do
        if (i == #params) then rowOps.lineColor = {0, 0, 0, 0} end
        rowOps.params = params[i]
        listBox:insertRow(rowOps)
    end

    local menuTitle = display.newRect(listBox.x, listBox.y, listBox.width, menuTitleBarHeight)
    menuTitle: setFillColor(unpack(menuTitleBarColor))
    alignOnTop(menuTitle, listBox)

    local menuTitleText = display.newText("Pause Menu", menuTitle.x, menuTitle.y, "Fonts/BigBook-Heavy", 16)
    local resumeButton = widget.newButton({
        label = "Resume",
        shape = "rect",
        fillColor = {default = {0.2, 0.6, 0}, over = {0.2, 0.6, 0, 0.5}},
        font = "Fonts/BigBook-Heavy",
        fontSize = 24,
        labelColor = {default = {1, 1, 1}, over = {1, 1, 1}}
    })

    resumeButton.height, resumeButton.width = rowHeight, menuWidth/2
    resumeButton.anchorX = 0
    resumeButton.x = listBox.x - (listBox.width/2)
    alignBelow(resumeButton, listBox)

    local quitButton = widget.newButton({
        label = "Quit",
        shape = "rect",
        fillColor = {default = {0.78, 0.47, 0.15}, over = {0.78, 0.47, 0.15, 0.5}},
        font = "Fonts/BigBook-Heavy",
        fontSize = 24,
        labelColor = {default = {1, 1, 1}, over = {1, 1, 1}}
    })

    quitButton.height, quitButton.width = rowHeight, menuWidth/2
    quitButton.anchorX = 0
    quitButton.x = listBox.x
    alignBelow(quitButton, listBox)

    
    sceneGroup:insert(blurLayer)
    sceneGroup: insert(listBox)
    sceneGroup:insert(menuTitle)
    sceneGroup: insert(menuTitleText)
    sceneGroup:insert(resumeButton)
end
 
 

function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
    end
end
 
 
-- hide()
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