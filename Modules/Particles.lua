local particles = {}
function particles.new(table)
	 local emitterObject = {}
     emitterObject.options = table
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