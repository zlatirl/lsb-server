-----------------------------------
-- Era Event Point Shop
-----------------------------------
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.eraEvents = xi.eraEvents or {}

---@class TEraPointShop
---@field pointsVar string
---@field unitName string
---@field onceVarPrefix string
---@field logPath string
---@field menus table
xi.eraEvents.PointShop = xi.eraEvents.PointShop or {}

local pointShop = xi.eraEvents.PointShop
pointShop.__index = pointShop

---@return TEraPointShop
function pointShop:new(params)
    local obj = {}
    setmetatable(obj, self)
    obj.pointsVar     = params.pointsVar
    obj.unitName      = params.unitName
    obj.onceVarPrefix = params.onceVarPrefix
    obj.logPath       = params.logPath
    obj.menus         = {}

    return obj
end

function pointShop:getPoints(player)
    return player:getCharVar(self.pointsVar)
end

function pointShop:writeLog(player, itemId, quantity)
    local logFile = io.open(self.logPath, 'a')
    if logFile then
        logFile:write(string.format('[%s] %s (%is playtime) bought %ix item %i.\n', os.date(), player:getName(), player:getPlaytime(), quantity, itemId))
        logFile:close()
    end
end

function pointShop:showMenu(player, menu)
    player:queue(0, function(playerQueued)
        playerQueued:customMenu(menu)
    end)
end

function pointShop:open(player, menuName)
    self:showMenu(player, self.menus[menuName or 'Main Menu'])
end

function pointShop:menu(menuName)
    return function(player)
        self:open(player, menuName)
    end
end

function pointShop:purchase(player, itemId, quantity, cost, onceVar)
    local points = self:getPoints(player)

    if points < cost then
        player:printToPlayer(string.format('You do not have enough %s to claim that item. It costs %i points but you possess %i points.', self.unitName, cost, points))
        return
    end

    if npcUtil.giveItem(player, { { itemId, quantity } }) then
        player:setCharVar(self.pointsVar, points - cost)

        if onceVar then
            player:setCharVar(onceVar, 1)
        end

        self:writeLog(player, itemId, quantity)
    end
end

function pointShop:confirm(player, itemId, quantity, cost, name, onceVar)
    self:showMenu(player, {
        title   = string.format('Confirm Purchase (%i %s)', cost, self.unitName),
        options =
        {
            {
                'Purchase ' .. name .. '.',
                function(playerConfirm)
                    self:purchase(playerConfirm, itemId, quantity, cost, onceVar)
                end,
            },
            {
                'I changed my mind.',
                function(playerCancel)
                end,
            },
        },
    })
end

function pointShop:item(itemId, quantity, cost, name)
    return function(player)
        self:confirm(player, itemId, quantity, cost, name)
    end
end

function pointShop:itemOnce(itemId, quantity, cost, name)
    return function(player)
        local onceVar = self.onceVarPrefix .. itemId

        if player:getCharVar(onceVar) ~= 0 then
            self:showMenu(player, {
                title   = string.format('Could not purchase %s', name),
                options =
                {
                    {
                        'Can only purchase that item once.',
                        function(playerArg)
                        end,
                    },
                },
            })

            return
        end

        self:confirm(player, itemId, quantity, cost, name, onceVar)
    end
end
