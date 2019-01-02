local score = {}
local scoreObjects = {}

local file = require "Modules.File"
local exception = require "Modules.Exception"
local json = require "json"

local centerX = display.contentCenterX
local centerY = display.contentCenterY

function isObjectValid(name)
    if (scoreObjects[name] == nil) then
        exception.new(exception.error, "Could not find score object with name: "..name)
        return false
    end
    return true
end

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
        local startColor = {0, 1, 0}
        local endColor = {0.5, 0.5, 0.5}

        if (options ~= nil) then
        	scaleX = options.xScale or 2.0
        	scaleY = options.yScale or 2.0
        	duration = options.time or 300
            startColor, endColor = options.startColor or startColor, options.endColor or endColor
        end
        
        transition.to(obj, {
            time = duration,
            xScale =  scaleX,
            yScale = scaleY,
            onStart = function() obj:setFillColor(unpack(startColor)) end,
            onComplete = function() 
                 obj.xScale, obj.yScale = 1.0, 1.0 
                 obj:setFillColor(unpack(endColor))
            end
        })

    end

    obj.display = function(scaleFactor, duration, color)
        print("score.display called")
        local scale, elapsedTime = scaleFactor or 2, duration or 2000
        local fillColor = color or {1, 0, 0} 

        transition.to(obj, {
            time = elapsedTime,
            x = centerX,
            y = centerY,
            xScale = scale,
            yScale = scale,
            onComplete = function(target)
                target: setFillColor(unpack(fillColor))
            end
        })     
    end
    scoreObjects[name] = obj
    return obj
end

function score.save(name)
    if (isObjectValid(name)) then
        local userJson = file.loadJson("user.json")
        userJson[name] = scoreObjects[name].value
        file.save("user.json", json.encode(userJson))
    end
end

function score.load(name, property)
     if (isObjectValid(name)) then
         return file.loadJson("user.json", property)
     end
     return nil
end

function score.cleanUp()
   if (scoreObejcts ~= nil) then
       table.remove(scoreObjects)
       scoreObjects = nil
   end
end

return score