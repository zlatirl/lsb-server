-----------------------------------
-- Module: GM Speed
-- Desc: GMs get double movement speed on zone in.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_gm_speed')

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    if player:getGMLevel() > 0 then
        player:setMod(xi.mod.MOVE_SPEED_OVERRIDE, 200)
    end
end)
