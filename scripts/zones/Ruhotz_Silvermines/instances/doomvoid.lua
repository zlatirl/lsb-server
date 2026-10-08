-----------------------------------
-- doomvoid
-- Sandworm's Doomvoid: Guivre or a Lambton Worm
-----------------------------------
local ID = zones[xi.zone.RUHOTZ_SILVERMINES]
-----------------------------------
local instanceObject = {}

instanceObject.onInstanceCreated = function(instance)
    xi.sandworm.onDoomvoidInstanceCreated(instance, ID.mob.GUIVRE, ID.mob.LAMBTON_WORM)
end

instanceObject.onInstanceCreatedCallback = function(player, instance)
    xi.sandworm.onDoomvoidInstanceCreatedCallback(player, instance)
end

instanceObject.afterInstanceRegister = function(player)
    xi.sandworm.afterDoomvoidRegister(player, ID.text)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

instanceObject.onInstanceFailure = function(instance)
    for _, player in pairs(instance:getChars()) do
        if not xi.sandworm.startDoomvoidExit(player, xi.sandworm.exitParam.TIMEOUT) then
            player:setPos(-34.2, -16, 58, 32, xi.zone.MHAURA)
        end
    end
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
end

instanceObject.onInstanceComplete = function(instance)
end

return instanceObject
