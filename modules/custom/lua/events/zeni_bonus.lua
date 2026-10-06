-----------------------------------
-- Increase custom Zeni trade reward by 33%
-- Reduce zeni cost of ZNM pops by 33%
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_zeni_bonus')

xi.eraEvents.zeniBonus = xi.eraEvents.zeniBonus or {}

local event = xi.eraEvents.ScheduledEvent:new('zeniBonus')

local tradeRewardMultiplier = 1.33
local popPriceMultiplier    = 0.66

xi.eraEvents.zeniBonus.getIsActive = function()
    return event:getIsActive()
end

m:addOverride('xi.sanrakuZeniTrades.getReward', function(player, itemId)
    local reward = super(player, itemId)

    if not reward or not xi.eraEvents.zeniBonus.getIsActive() then
        return reward
    end

    return math.floor(reward * tradeRewardMultiplier)
end)

m:addOverride('xi.znm.getPlayerPopPrice', function(player, mob, znmTier)
    local price = super(player, mob, znmTier)

    if not xi.eraEvents.zeniBonus.getIsActive() then
        return price
    end

    return math.floor(price * popPriceMultiplier)
end)
