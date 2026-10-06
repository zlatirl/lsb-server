-----------------------------------
-- Era Provenance Watcher (Provenance HNM)
-- Below 75000 HP a Silence is answered with Gloeosuccus and Death,
-- and below 10000 HP it heals back to 100000.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_provenance_watcher')

xi.module.ensureTable('xi.zones.Provenance.mobs.Provenance_Watcher')

m:addOverride('xi.zones.Provenance.mobs.Provenance_Watcher.onMobFight', function(mob, target)
    if mob:getHP() < 75000 and mob:hasStatusEffect(xi.effect.SILENCE) then
        mob:delStatusEffect(xi.effect.SILENCE)
        mob:useMobAbility(xi.mobSkill.GLOEOSUCCUS)
        target:printToPlayer('Hahaha.. you think you can win?', xi.msg.channel.SYSTEM_3)
        mob:castSpell(xi.magic.spell.DEATH)
    end

    if mob:getHP() < 10000 then
        mob:setHP(100000)
        target:printToPlayer('You think you can defeat me!?', xi.msg.channel.SYSTEM_3)
    end
end)

return m
