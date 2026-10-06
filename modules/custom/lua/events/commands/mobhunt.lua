-----------------------------------
-- func: mobhunt <command> [<mobID>]
-- desc: Lets players join or quit the Mob Hunt event, and lets GMs control the hunt target.
--       Players: join, quit
--       GMs:     new, set [<mobID>], get, cleanup
-----------------------------------
require('modules/module_utils')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 'ss',
}

local function printUsage(player)
    player:printToPlayer('!mobhunt join | quit', xi.msg.channel.SYSTEM_3)

    if player:getGMLevel() >= 1 then
        player:printToPlayer('GM: !mobhunt new | set [<mobID>] | get | cleanup', xi.msg.channel.SYSTEM_3)
    end
end

local function printTarget(player, label)
    player:printToPlayer(string.format('%s Mob Hunt target: %d.', label, GetServerVariable('[MobHunt]Target')), xi.msg.channel.SYSTEM_3)
end

local inactiveCommands =
{
    quit    = true,
    cleanup = true,
    get     = true,
}

commandObj.onTrigger = function(player, command, arg1)
    local mobHunt = xi.eraEvents.mobHunt

    command = command and string.lower(command)

    if not command then
        printUsage(player)
        return
    end

    if not mobHunt.getIsActive() and not inactiveCommands[command] then
        player:printToPlayer('The Mob Hunt event is not currently live.', xi.msg.channel.SYSTEM_3)
        return
    end

    local isGM = player:getGMLevel() >= 1

    if command == 'join' then
        mobHunt.join(player)
        player:printToPlayer('You have joined the hunt!', xi.msg.channel.SYSTEM_3)
    elseif command == 'quit' then
        mobHunt.quit(player)
        player:printToPlayer('You are no longer participating in the hunt.', xi.msg.channel.SYSTEM_3)
    elseif command == 'new' and isGM then
        mobHunt.activateNewHuntTarget()
        printTarget(player, 'New')
    elseif command == 'set' and isGM then
        local target = arg1 and GetMobByID(tonumber(arg1) or 0) or player:getCursorTarget()

        if not target or not target:isMob() then
            player:printToPlayer('Provide a valid mob ID or target a mob.', xi.msg.channel.SYSTEM_3)
            return
        end

        mobHunt.setHuntTarget(target)
        printTarget(player, 'New')
    elseif command == 'get' and isGM then
        printTarget(player, 'Current')
    elseif command == 'cleanup' and isGM then
        local huntTargetID = GetServerVariable('[MobHunt]Target')
        local huntTarget   = huntTargetID > 0 and GetMobByID(huntTargetID) or nil

        if huntTarget then
            mobHunt.cleanupHuntTarget(huntTarget)
            player:printToPlayer(string.format('Cleaned up Mob Hunt target: %d.', huntTargetID), xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer('There is no Mob Hunt target to clean up.', xi.msg.channel.SYSTEM_3)
        end
    else
        printUsage(player)
    end
end

xi.module.registerCommand('mobhunt', commandObj)
