local score = {}
local scoreObjects = {}

local json = require "json"

function readFile(filePath)
    local path = system.pathForFile(filePath)
    local decoded, position, message = json.decodeFile(path)

    if not decoded then
        print("Error: failed to decode json file at "..filePath.." at "..position.." msg: "..message)
        return nil
    end
    
    return decoded
end

function writeFile(filePath, content)
    local path = system.pathForFile(filePath)
    local file, errorMessage = io.open(path, "w")
    if not file then
        print("Error: "..errorMessage)
        return false
    end
    file:write(json.encode(content))
    io.close()
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

function score.load(name)
    if (scoreObjects[name] == nil) then
        print("Score.save unable to save score because specified score object does not exist")
        return false
    end
    local userContent = readFile("./user.json")
    return userContent[name]
end


return score