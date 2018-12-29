local frame = {
	frameObjects = {}
}

local widget = require "widget"

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

function addToGroup(obj)
  if (displayGroup ~= nil) then
    displayGroup: insert(obj)
  end
end

function positionObject(obj, options, isPrevious)
    local xpos = obj.offsetLeft or 5

    if (options ~= nil) then
       xpos = options.xpos or centerX
    elseif (previousObj ~= nil) then
       xpos = previousObj.x + previousObj.width + (obj.offsetRight or 5)  
    end

   local width = obj.width
   obj.x = xpos
   obj.y = header.position.y

   if (isPrevious) then
      previousObj = obj
   end
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

  headerFrame.add = function(name, obj, options)
      local frameObjects = frame.frameObjects
      obj.anchorX, obj.anchorY = 0, 0.5
      positionObject(obj, options, true)
      frameObjects[name] = obj
      addToGroup(obj)  
  end

  headerFrame.fixPosition = function(name)
      local frameObjects = frame.frameObjects
      if (frameObjects[name]) then
          positionObject(frameObjects[name],{xpos = centerX - frameObjects[name].width}, false)
      else
         print("Warning: the object name specified is invalid in function UIFrame.init.fixPosition")
      end
  end
    
  addToGroup(headerFrame)
  return headerFrame
end

function frame.addText(name, text, options)
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
   
    positionObject(text, nil, true)

    frameObjects[name] = text
    addToGroup(text)
end

function frame.addButton(name, options)
    local frameObjects = frame.frameObjects
    local button = widget.newButton(options)
    button.anchorX, button.anchorY = 0, 0.5
    positionObject(button, nil, true)
    
    frameObjects[name] = button

    if (displayGroup ~= nil) then
        displayGroup: insert(button)
    end
    button.name = name
end

function frame.toString()
    local frameObjects = frame.frameObjects
    local counter = 1
    print("Header Frame Contents: ")
    for k,v in pairs(frameObjects) do
      print("Object "..counter.." name : "..k)
    end
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