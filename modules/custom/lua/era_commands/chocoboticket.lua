-----------------------------------
-- func: chocoboticket (player) (quantity)
-- desc: Gives Mog Kupon I-Mats signed "ChocoboColor"; trade one to Mapitoto to recolor a registered chocobo.
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 'si'
}

commandObj.onTrigger = function(player, targetName, quantity)
    local target = player
    if targetName then
        target = GetPlayerByName(targetName)
        if not target then
            player:printToPlayer(string.format('Player named \'%s\' not found.', targetName))
            player:printToPlayer('!chocoboticket (player) (quantity)')
            return
        end
    end

    quantity = quantity or 1

    local given = 0
    for _ = 1, quantity do
        if not target:addItem({ id = xi.item.MOG_KUPON_I_MAT, signature = 'ChocoboColor' }) then
            break
        end

        given = given + 1
    end

    player:printToPlayer(string.format('Gave %d ChocoboColor ticket(s) to %s.', given, target:getName()))
end

xi.module.registerCommand('chocoboticket', commandObj)
