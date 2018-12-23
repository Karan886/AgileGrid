local frame = {
	frameObjects = {}
}

local widget = require "widget"
local init = false

-- Dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local previousObj = nil

local header = {
	size = { width = actualWidth, height = 45},
	color = {red = 0.9, green = 0.4, blue = 0.7},
	image = nil,
	position = {x = centerX, y = -30},
  alpha = 1.0
}

local displayGroup = nil

function positionObject(obj)
    local xpos = obj.offsetLeft or 5
    local width = obj.width

    if (previousObj ~= nil) then
       xpos = previousObj.x + previousObj.width + (obj.offsetRight or 5)
   end 
   
   obj.x = xpos
   obj.y = header.position.y
end

function frame.init(options, group)
	if (options ~= nil) then
		for key, value in pairs(options) do
    	    header[key] = value
        end
	end
    local headerFrame = nil
    if (header.image == nil) then
    	headerFrame = simpleHeader()
    else
        headerFrame = texturedHeader()
    end
    if (group ~= nil) then
    	displayGroup = group
    	group: insert(headerFrame)
    end
    init = true
end

function frame.addText(name, text, options)
   if (init == false) then
       print("Cannot add text to UIFrame because it was not initialized")
       return nil
   end
   local frameObjects = frame.frameObjects

   local size = 10 
   local font = "Fonts/BigBook-Heavy" 

   if (options ~= nil) then
    size = 10
    font = "Fonts/BigBook-Heavy"
   end

   local text = display.newText(text, 0, header.position.y, font, size)
   text.anchorX, text.anchorY = 0, 0.5
   text.name = name
   
   positionObject(text)

   frameObjects[name] = text
   if (displayGroup ~= nil) then
       displayGroup: insert(text)
   end
   previousObj = text
   return text
end

function frame.addButton(name, options)
    local frameObjects = frame.frameObjects
    if (init == false) then
       print("Cannot add text to UIFrame because it was not initialized")
       return nil
    end
    local button = widget.newButton(options)
    button.anchorX, button.anchorY = 0, 0.5
    positionObject(button)
    
    frameObjects[name] = button

    if (displayGroup ~= nil) then
        displayGroup: insert(button)
    end
    previousObj = button
    button.name = name
    return button
end

function frame.add(name, obj)
  local frameObjects = frame.frameObjects
  if (init == false) then
       print("Cannot add text to UIFrame because it was not initialized")
       return false
  end

  obj.anchorX, obj.anchorY = 0, 0.5
  positionObject(obj)
  return true
end

function simpleHeader()
	local headerFrame = display.newRoundedRect(header.position.x, header.position.y, header.size.width, header.size.height, 10)
    headerFrame: setFillColor(header.color.red, header.color.blue, header.color.green, header.alpha)
    return headerFrame
end

function texturedHeader()
	local headerFrame = display.newImage(header.image, centerX, header.position.y)
	return headerFrame
end

return frame