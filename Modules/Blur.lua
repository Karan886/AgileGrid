local blur = {}
local currentCapture = nil

local centerX = display.contentCenterX
local centerY = display.contentCenterY

function blur.start(options)
	if (currentCapture ~= nil) then return false end
	
	local bounds = {
        xMin = options.xmin,
        xMax = options.xmax,
        yMin = options.ymin,
        yMax = options.ymax
    }
    local screenCapture = display.captureBounds(bounds, false)
    screenCapture.x, screenCapture.y = centerX, centerY
    screenCapture.fill.effect = "filter.blurGaussian"
    screenCapture.fill.effect.horizontal.blurSize = 100
    screenCapture.fill.effect.vertical.blurSize = 100
    currentCapture = screenCapture
    
    print("successful screen capture and blur...")
    return true
end

function blur.stop()
    if (currentCapture ~= nil) then
    	display.remove(currentCapture)
    	return true
    end
    return false
end

return blur