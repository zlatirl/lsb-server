-----------------------------------
-- Area: Jade Sepulcher
--  Mob: Lancelord Gaheel Ja
-- TOAU-29 Puppet in Peril
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobSpawn = function(mob)
    mob:addMod(xi.mod.SILENCERES, 100)
    mob:addMod(xi.mod.SLEEPRES, 100)
    mob:addMod(xi.mod.GRAVITYRES, 100)
    mob:addStatusEffect(xi.effect.PROTECT, { power = 175, duration = 1800, origin = mob })
    mob:addStatusEffect(xi.effect.SHELL, { power = 24, duration = 1800, origin = mob })
end

return entity
