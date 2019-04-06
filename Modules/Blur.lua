local blur = {}

local centerX = display.contentCenterX
local centerY = display.contentCenterY

function blur.getBlurredImage(options)
	
	local bounds = {
        xMin = options.xmin,
        xMax = options.xmax,
        yMin = options.ymin,
        yMax = options.ymax
    }
    local screenCapture = display.captureBounds(bounds, false)
    screenCapture.anchorX, screenCapture.anchorY = 0, 0
    screenCapture.x, screenCapture.y = 0, 0
    screenCapture.fill.effect = "filter.blurGaussian"
    screenCapture.fill.effect.horizontal.blurSize = 100
    
    return screenCapture
end


return blur