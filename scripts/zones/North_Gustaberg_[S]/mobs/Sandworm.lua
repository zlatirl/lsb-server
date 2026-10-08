-----------------------------------
-- Area: North Gustaberg [S]
--  Mob: Sandworm
-- Note: Title Given if Sandworm does not Doomvoid
-----------------------------------
mixins = { require('scripts/mixins/families/sandworm') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    xi.sandworm.onMobInitialize(mob)
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.SANDWORM_WRANGLER)
    end
end

return entity
