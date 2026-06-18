-----------------------------------
-- Assault: Wamoura Farm Raid
-----------------------------------
local ID = zones[xi.zone.LEBROS_CAVERN]
-----------------------------------
local instanceObject = {}

instanceObject.registryRequirements = function(player)
    return player:hasKeyItem(xi.ki.LEBROS_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.WAMOURA_FARM_RAID and
        player:getCharVar('assaultEntered') == 0 and
        player:hasKeyItem(xi.ki.ASSAULT_ARMBAND) and
        player:getMainLvl() > 50
end

instanceObject.entryRequirements = function(player)
    return player:hasKeyItem(xi.ki.LEBROS_ASSAULT_ORDERS) and
        player:getCurrentAssault() == xi.assault.mission.WAMOURA_FARM_RAID and
        player:getCharVar('assaultEntered') == 0 and
        player:getMainLvl() > 50
end

instanceObject.afterInstanceRegister = function(player)
    local instance = player:getInstance()
    player:messageSpecial(ID.text.ASSAULT_START_OFFSET + 27, 27)
    player:messageSpecial(ID.text.TIME_TO_COMPLETE, instance:getTimeLimit() / 60)
end

instanceObject.onInstanceCreated = function(instance)
--    for i, v in pairs(ID.mob[27]) do
--        SpawnMob(v, instance)
--    end
end

instanceObject.onInstanceCreatedCallback = function(player, instance)
    xi.assault.onInstanceCreatedCallback(player, instance)
    xi.instance.onInstanceCreatedCallback(player, instance)
end

instanceObject.onInstanceTimeUpdate = function(instance, elapsed)
    xi.instance.updateInstanceTime(instance, elapsed, ID.text)
end

instanceObject.onInstanceFailure = function(instance)
    xi.assault.onInstanceFailure(instance)
end

instanceObject.onInstanceProgressUpdate = function(instance, progress)
    if progress >= 15 then
        instance:complete()
    end
end

instanceObject.onInstanceComplete = function(instance)
    local chars = instance:getChars()

    for i, v in pairs(chars) do
        v:messageSpecial(ID.text.RUNE_UNLOCKED_POS, 7, 8)
    end

    local rune = GetNPCByID(ID.npc.RUNE_OF_RELEASE, instance)
    local box = GetNPCByID(ID.npc.ANCIENT_LOCKBOX, instance)

    if rune then
        rune:setPos(414.29, -40.64, 301.523, 247)
        rune:setStatus(xi.status.NORMAL)
    end

    if box then
        box:setPos(410.41, -41.12, 300.743, 243)
        box:setStatus(xi.status.NORMAL)
    end
end

instanceObject.onEventUpdate = function(player, csid, option, npc)
end

instanceObject.onEventFinish = function(player, csid, option, npc)
end

return instanceObject
