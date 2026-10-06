-----------------------------------
-- 33% Bonus to Tokens
-- Increase nyzulUtil.vigilWeaponDrop base drop rate from 5% to 10%
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_nyzul_bonus')

xi.eraEvents.nyzulBonus = xi.eraEvents.nyzulBonus or {}

local event = xi.eraEvents.ScheduledEvent:new('nyzulBonus')

local tokenMultiplier      = 1.33
local vigilDropMultiplier  = 2

xi.eraEvents.nyzulBonus.getIsActive = function()
    return event:getIsActive()
end

m:addOverride('xi.nyzul.applyTokenBonus', function(player, tokens)
    tokens = super(player, tokens)

    if not xi.eraEvents.nyzulBonus.getIsActive() then
        return tokens
    end

    return math.floor(tokens * tokenMultiplier)
end)

m:addOverride('xi.nyzul.getVigilDropChance', function(player, mob, chance)
    chance = super(player, mob, chance)

    if not xi.eraEvents.nyzulBonus.getIsActive() then
        return chance
    end

    return math.min(100, chance * vigilDropMultiplier)
end)
