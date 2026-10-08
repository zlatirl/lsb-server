-----------------------------------
-- Era Survival Guide mounts (Ru'Lude Gardens)
-- Talking to the Survival Guide hands out mount key items earned through titles and key items.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/npc_util')
-----------------------------------
local m = Module:new('era_survival_guide_mounts')

local function hasTitles(player, titles)
    for _, title in ipairs(titles) do
        if not player:hasTitle(title) then
            return false
        end
    end

    return true
end

local mounts =
{
    {
        keyItem = xi.keyItem.XZOMIT_COMPANION,
        earned  = function(player)
            return player:hasKeyItem(xi.keyItem.TEAR_OF_ALTANA)
        end,
    },
    {
        keyItem = xi.keyItem.SPHEROID_COMPANION,
        earned  = function(player)
            return player:hasTitle(xi.title.BURIER_OF_THE_ILLUSION)
        end,
    },
    {
        keyItem = xi.keyItem.MOOGLE_COMPANION,
        earned  = function(player)
            return hasTitles(player, { xi.title.TIAMAT_TROUNCER, xi.title.VRTRA_VANQUISHER, xi.title.WORLD_SERPENT_SLAYER })
        end,
    },
    {
        keyItem = xi.keyItem.WARMACHINE_COMPANION,
        earned  = function(player)
            return hasTitles(player, { xi.title.SHINING_SCALE_RIFLER, xi.title.TROLL_SUBJUGATOR, xi.title.GORGONSTONE_SUNDERER })
        end,
    },
    {
        keyItem = xi.keyItem.IRON_GIANT_COMPANION,
        earned  = function(player)
            return hasTitles(player, { xi.title.STAR_CHARIOTEER, xi.title.SUN_CHARIOTEER, xi.title.COMET_CHARIOTEER, xi.title.MOON_CHARIOTEER })
        end,
    },
}

m:addOverride('xi.zones.RuLude_Gardens.npcs.Survival_Guide.onTrigger', function(player, npc)
    for _, mount in ipairs(mounts) do
        if not player:hasKeyItem(mount.keyItem) and mount.earned(player) then
            npcUtil.giveKeyItem(player, mount.keyItem)
            return
        end
    end

    player:printToPlayer('Trade me a Caver\'s Shovel and see what happens')
    super(player, npc)
end)

return m
