-----------------------------------
-- func: !kill <target>
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 2,
    parameters = 's'
}

commandObj.onTrigger = function(player, targetName)
    if targetName == nil then
        player:printToPlayer('The proper syntax for this command is: !kill <target>')
        return
    end

    local target = GetPlayerByName(targetName)

    if target == nil then
        player:printToPlayer(string.format('Player name \'%s\' not found.', targetName))
        return
    end

    target:injectActionPacket(target:getID(), 5, 207, 0, 0, 0, 10, 1)
    target:injectActionPacket(target:getID(), 5, 216, 0, 0, 0, 10, 1)
    target:injectActionPacket(target:getID(), 5, 270, 0, 0, 0, 10, 1)
    target:injectActionPacket(target:getID(), 5, 236, 0, 0, 0, 10, 1)
    player:printToPlayer(string.format('Looks like %s is eating dirt for lunch now.', target:getName()))
end

xi.module.registerCommand('kill', commandObj)
