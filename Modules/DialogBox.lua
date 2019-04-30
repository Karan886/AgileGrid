local dialog = {}
local widget = require "widget"

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

-- Dialog box with a provided list: ie. user must create a tableview object to render a list 
-- and then pass it onto this function
function dialog.infoList(list, options)
  if (list == nil) then
    print("DialogBox.lua: cannot create infoList because list is nil.")
    return nil
  end
  local group = display.newGroup()

  local titleBarColor = options.headerFrameColor or {0, 0, 0, 0.7}
  local dialogBodyColor = options.dialogBodyColor or {0.8, 0.8, 0.8}
  local titleBarHeight = options.titleBarHeight or 30
  local width = options.width or list.width
  local rowHeight = options.rowHeight or 30
  local xPos = options.xPos or centerX
  local ypos = options.yPos or centerY
  local title = options.title or "Dialog Title"
  
  local titleBar = display.newRect(0, 0, width, rowHeight)
  titleBar: setFillColor(unpack(titleBarColor))
  titleBar.anchorY = 1
  list.anchorY = 0
  titleBar.x = list.x
  titleBar.y = list.y 

  local titleText = display.newText(title, 0, 0, "Fonts/BigBook-Heavy", 16)
  titleText.anchorX = 0
  titleText.x = titleBar.x - titleBar.width/2 + 5
  titleText.y = titleBar.y - titleBar.height/2

  group: insert(titleBar)
  group: insert(list)
  group:insert(titleText)

  return group
end

return dialog