-----------------------------------
-- func: !noxp
-- desc: Removes the Dedication (XP bonus) effect.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = ''
}

commandObj.onTrigger = function(player)
    if player:hasStatusEffect(xi.effect.DEDICATION) then
        player:delStatusEffect(xi.effect.DEDICATION)
        player:printToPlayer('XP Buff removed')
    end
end

xi.module.registerCommand('noxp', commandObj)
