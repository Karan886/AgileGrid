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

function alignCenter(obj, parentHeight)
    obj.y = parentHeight * 0.5
    return true
end

function alignOnTop(obj, parent)
    if (parent == nil) then return false end
    obj.y = parent.y - (parent.height/2) - obj.height/2
    return true
end

function onRowRender(event)
    local row = event.row
    local rowWidth, rowHeight = row.contentWidth, row.contentHeight

    local rowItem = display.newText(row, row.params.item, 0, 0, "Fonts/BigBook-Heavy", 14)
    rowItem:setFillColor(0)
    alignLeft(rowItem, 5)
    alignCenter(rowItem, rowHeight)
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
        onRowRender = onRowRender 
    })

    for i = 1, #params do
        listBox:insertRow({
            rowHeight = rowHeight,
            params = params[i]
        })
    end

    local menuTitle = display.newRect(listBox.x, listBox.y, listBox.width, menuTitleBarHeight)
    menuTitle: setFillColor(unpack(menuTitleBarColor))
    alignOnTop(menuTitle, listBox)

    local menuTitleText = display.newText("Pause Menu", menuTitle.x, menuTitle.y, "Fonts/BigBook-Heavy", 16)
    
    sceneGroup:insert(blurLayer)
    sceneGroup: insert(listBox)
    sceneGroup:insert(menuTitle)
    sceneGroup: insert(menuTitleText)
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