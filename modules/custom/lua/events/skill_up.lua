-----------------------------------
-- Skill Up campaign:
-- +33% Combat, Magic, and Craft skill up rate
-- Currently only obtainable at Mendi in Lower Jeuno
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_skill_up')

xi.eraEvents.skillUp = xi.eraEvents.skillUp or {}
local skillUp = xi.eraEvents.skillUp

local event = xi.eraEvents.ScheduledEvent:new('skillUp')

local bonusPower = 33
local duration   = 3 * 60 * 60

local bonusMods =
{
    xi.mod.COMBAT_SKILLUP_RATE,
    xi.mod.MAGIC_SKILLUP_RATE,
    xi.mod.SYNTH_SKILL_GAIN,
}

skillUp.getIsActive = function()
    return event:getIsActive()
end

m:addOverride('xi.zones.Lower_Jeuno.npcs.Mendi.onTrigger', function(player, npc)
    if not skillUp.getIsActive() then
        super(player, npc)
        return
    end

    player:printToPlayer('Enjoy the enhanced learning! Go master your skills, adventurer!', xi.msg.channel.SAY, npc:getName())
    player:addStatusEffect(xi.effect.UNBRIDLED_LEARNING, { power = bonusPower, duration = duration, origin = player })
end)

m:addOverride('xi.effects.unbridled_learning.onEffectGain', function(target, effect)
    super(target, effect)

    local power = effect:getPower()

    if power > 0 then
        for _, mod in ipairs(bonusMods) do
            effect:addMod(mod, power)
        end
    end
end)
