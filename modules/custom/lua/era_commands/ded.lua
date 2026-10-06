-----------------------------------
-- func: !ded <target>
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 4,
    parameters = 's'
}

commandObj.onTrigger = function(player, target)
    if target == nil then
        player:printToPlayer('The proper syntax for this command is: !ded <target>')
        return
    end

    local targ = GetPlayerByName(target)

    if targ == nil then
        player:printToPlayer(string.format('Player named \'%s\' not found.', target))
        return
    end

    targ:injectActionPacket(targ:getID(), 5, 271, 0, 0, 0, 10, 1)
    targ:injectActionPacket(targ:getID(), 5, 202, 0, 0, 0, 10, 1)
    targ:injectActionPacket(targ:getID(), 5, 207, 0, 0, 0, 10, 1)
    targ:injectActionPacket(targ:getID(), 5, 216, 0, 0, 0, 10, 1)
    targ:injectActionPacket(targ:getID(), 5, 270, 0, 0, 0, 10, 1)
    targ:setHP(0)
    player:printToPlayer(string.format('%s is resting in pepperoni\'s.', targ:getName()))
end

xi.module.registerCommand('ded', commandObj)
