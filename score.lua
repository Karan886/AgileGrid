local score = {}
local scoreObjects = {}

local json = require "json"

function score.new(name, obj, value)
    obj.name = name or #scoreObjects
    obj.value = value
    obj.name = name
    obj.add = function(text, value)
        obj.value = obj.value + value
        obj.text = text..obj.value
    end

    obj.poke = function(options)
        local duration = 300
        local scaleX, scaleY = 2.0, 2.0
        if (options ~= nil) then
        	scaleX = options.xScale or 2.0
        	scaleY = options.yScale or 2.0
        	duration = options.time or 300
        end

        transition.to(obj, {
            time = duration,
            xScale =  scaleX,
            yScale = scaleY,
            onComplete = function() obj.xScale, obj.yScale = 1.0, 1.0 end
        })

    end
    scoreObjects[name] = obj
    return obj
end

return score