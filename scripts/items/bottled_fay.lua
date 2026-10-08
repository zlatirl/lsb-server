-----------------------------------
-- ID: 5423
-- Bottled Fay
-- Leaves a Sandworm Doomvoid fight.
-----------------------------------
---@type TItem
local itemObject = {}

local doomvoidZones =
{
    [xi.zone.EVERBLOOM_HOLLOW]   = true,
    [xi.zone.GHOYUS_REVERIE]     = true,
    [xi.zone.RUHOTZ_SILVERMINES] = true,
}

itemObject.onItemCheck = function(target, item, caster)
    if not doomvoidZones[target:getZoneID()] or target:getCharVar('[Doomvoid]zone') == 0 then
        return 56
    end

    return 0
end

itemObject.onItemUse = function(target, user)
    xi.sandworm.startDoomvoidExit(target, xi.sandworm.exitParam.BOTTLED_FAY)
end

return itemObject
