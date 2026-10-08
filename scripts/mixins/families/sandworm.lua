-----------------------------------
-- Sandworm (Shadowreign zones)
-- Can Doomvoid below 25% HP, and burrows off to another zone after an hour without a claim.
-- Doomvoid and the zone rotation live in scripts/globals/sandworm.lua.
-----------------------------------
require('scripts/globals/mixins')
-----------------------------------
g_mixins = g_mixins or {}
g_mixins.families = g_mixins.families or {}

local unclaimedLifetime = 3600

g_mixins.families.sandworm = function(sandwormMob)
    sandwormMob:addListener('SPAWN', 'SANDWORM_SPAWN', function(mob)
        mob:setMod(xi.mod.DEF, 400)
        mob:setMod(xi.mod.MEVA, 300)
        mob:setMod(xi.mod.MDEF, 50)
        mob:setMod(xi.mod.DOUBLE_ATTACK, 20)

        mob:setLocalVar('[DESPAWN]timer', GetSystemTime() + unclaimedLifetime)
    end)

    -- Doomvoid isn't on its skill list; each time it has TP below the threshold it gets one roll to use it.
    sandwormMob:addListener('COMBAT_TICK', 'SANDWORM_DOOMVOID', function(mob)
        if mob:getTP() < 1000 then
            mob:setLocalVar('doomvoidRolled', 0)
            return
        end

        if
            mob:getHPP() > xi.sandworm.doomvoidHpp or
            mob:getLocalVar('doomvoidRolled') == 1
        then
            return
        end

        mob:setLocalVar('doomvoidRolled', 1)

        if math.random(100) <= xi.sandworm.doomvoidChance then
            mob:useMobAbility(xi.mobSkill.DOOMVOID)
        end
    end)

    sandwormMob:addListener('ROAM_TICK', 'SANDWORM_ROAM_TICK', function(mob)
        if GetSystemTime() >= mob:getLocalVar('[DESPAWN]timer') then
            xi.sandworm.onMoveZone(mob)
            DespawnMob(mob:getID())
        end
    end)

    sandwormMob:addListener('DEATH', 'SANDWORM_DEATH', function(mob)
        xi.sandworm.onGone(mob)
    end)
end

return g_mixins.families.sandworm
