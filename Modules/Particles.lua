local particles = {}
local file = require "Modules.File"
function particles.new(filepath)
	 local emitterObject = {}
     emitterObject.options = file.loadJson(filepath)
     emitterObject.start = function(x, y, sceneGroup)
         local emitter = display.newEmitter(emitterObject.options)
         emitter.x, emitter.y = x, y
         if (sceneGroup ~= nil) then
         	 sceneGroup: insert(emitter)
         end
         return emitter
     end
     return emitterObject
end

return particles