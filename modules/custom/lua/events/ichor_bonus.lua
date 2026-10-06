-----------------------------------
-- 33% Bonus to Ichor
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_ichor_bonus')

xi.eraEvents.ichorBonus = xi.eraEvents.ichorBonus or {}

local event = xi.eraEvents.ScheduledEvent:new('ichorBonus')

local ichorMultiplier = 1.33

xi.eraEvents.ichorBonus.getIsActive = function()
    return event:getIsActive()
end

m:addOverride('xi.einherjar.getAmpoulesReward', function(chamberId, defeatedCount, totalCount)
    local reward = super(chamberId, defeatedCount, totalCount)

    if not xi.eraEvents.ichorBonus.getIsActive() then
        return reward
    end

    return math.floor(reward * ichorMultiplier)
end)
