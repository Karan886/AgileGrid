local frame = {}

-- Dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

local header = {
	size = { width = actualWidth, height = 45},
	color = {red = 0.9, green = 0.4, blue = 0.7}
}

function frame.init(options, group)
	if (options ~= nil) then
		for key, value in pairs(options) do
    	    header[key] = value
        end
	end
    local headerFrame = nil
    if (header.image == nil) then
    	headerFrame = simpleHeader()
    end
    if (group ~= nil) then
    	group: insert(headerFrame)
    end
end

function simpleHeader()
	local headerFrame = display.newRect(centerX, -30, header.size.width, header.size.height)
    headerFrame: setFillColor(header.color.red, header.color.blue, header.color.green)
    headerFrame: setStrokeColor(0, 0, 0)
    headerFrame.strokeWidth = 1
    return headerFrame
end

return frame