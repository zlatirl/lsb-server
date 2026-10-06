-----------------------------------
-- Module: Era Assault Tags
-- Desc: Imperial Army I.D. tags stock up to 7, restocking one every 20 hours.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_assault_tags')

local maxTagStock     = 7
local tagRestockHours = 20

m:addOverride('xi.assault.getMaxTagStock', function(player)
    return maxTagStock
end)

m:addOverride('xi.assault.getTagRestockPeriod', function(player, idTagPeriod)
    idTagPeriod = super(player, idTagPeriod)

    if player:hasKeyItem(xi.keyItem.RHAPSODY_IN_AZURE) then
        return idTagPeriod
    end

    return math.floor(idTagPeriod * tagRestockHours / 24)
end)
