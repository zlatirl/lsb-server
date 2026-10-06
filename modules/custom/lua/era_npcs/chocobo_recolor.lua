-----------------------------------
-- Era Chocobo recolor tickets (Mapitoto, Upper Jeuno)
-- Trading Mapitoto a Mog Kupon I-Mat signed "ChocoboColor" banks a ticket; a ticket buys one
-- change of the registered chocobo's color, beak, talons and tail.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_chocobo_recolor')

xi.chocoboRecolor = xi.chocoboRecolor or {}

local ticketVar       = 'ChocoboColorTicket'
local ticketSignature = 'ChocoboColor'

local colorNames =
{
    [xi.chocoboRaising.color.YELLOW] = 'Yellow',
    [xi.chocoboRaising.color.BLACK]  = 'Black',
    [xi.chocoboRaising.color.BLUE]   = 'Blue',
    [xi.chocoboRaising.color.RED]    = 'Red',
    [xi.chocoboRaising.color.GREEN]  = 'Green',
}

local features =
{
    { key = 'largeBeak',   var = '[ChocoboMenu]Beak',   label = 'Head' },
    { key = 'largeTalons', var = '[ChocoboMenu]Talons', label = 'Feet' },
    { key = 'fullTail',    var = '[ChocoboMenu]Tail',   label = 'Tail' },
}

local function featureName(isAlternate)
    return isAlternate and 'Alternate' or 'Standard'
end

local function loadDraft(player, chocobo)
    player:setLocalVar('[ChocoboMenu]Color', chocobo.color)
    for _, feature in ipairs(features) do
        player:setLocalVar(feature.var, chocobo[feature.key] and 1 or 0)
    end
end

local function clearDraft(player)
    player:setLocalVar('[ChocoboMenu]Color', 0)
    for _, feature in ipairs(features) do
        player:setLocalVar(feature.var, 0)
    end
end

local function reopen(player)
    player:queue(0, function(playerArg)
        xi.chocoboRecolor.showMenu(playerArg)
    end)
end

-- registerChocobo rewrites the raised chocobo's stats too, so they are carried over unchanged.
local function confirmChocobo(player)
    local current = player:getFieldChocobo()
    if not current then
        return
    end

    if player:getCharVar(ticketVar) <= 0 then
        player:printToPlayer('You do not have a valid ChocoboColor ticket.', xi.msg.channel.SYSTEM_2)
        return
    end

    local userData = player:getChocoboUserData()
    local chocobo  =
    {
        color           = player:getLocalVar('[ChocoboMenu]Color'),
        speed           = current.speed,
        minutes         = current.minutes,
        ability1        = userData.registeredAbility1,
        ability2        = userData.registeredAbility2,
        strength        = userData.registeredStrength,
        endurance       = userData.registeredEndurance,
        discernment     = userData.registeredDiscernment,
        receptivity     = userData.registeredReceptivity,
        weather         = userData.registeredWeather,
        silksSpeedBonus = userData.silksSpeedBonus,
    }

    for _, feature in ipairs(features) do
        chocobo[feature.key] = player:getLocalVar(feature.var) == 1
    end

    player:incrementCharVar(ticketVar, -1)
    player:registerChocobo(chocobo)
    clearDraft(player)

    player:delStatusEffectSilent(xi.effect.MOUNTED)
    player:addStatusEffect(xi.effect.MOUNTED,
    {
        power    = xi.mount.CHOCOBO,
        duration = 1800,
        origin   = player,
        subPower = xi.chocoboRaising.personalChocoboFlag,
        silent   = true,
    })
end

local function confirmMenu(player)
    local alternates = {}
    for _, feature in ipairs(features) do
        if player:getLocalVar(feature.var) == 1 then
            table.insert(alternates, string.lower(feature.label))
        end
    end

    local description = 'standard features'
    if #alternates > 0 then
        description = 'alternate ' .. table.concat(alternates, ', ')
    end

    player:customMenu({
        title   = string.format('%s with %s', colorNames[player:getLocalVar('[ChocoboMenu]Color')], description),
        options =
        {
            { 'Confirm chocobo', confirmChocobo },
            { 'Back', reopen },
        },
        onCancelled = clearDraft,
    })
end

local function cycleColor(player)
    player:setLocalVar('[ChocoboMenu]Color', (player:getLocalVar('[ChocoboMenu]Color') + 1) % 5)
    reopen(player)
end

local function toggleFeature(feature)
    return function(player)
        player:setLocalVar(feature.var, 1 - player:getLocalVar(feature.var))
        reopen(player)
    end
end

xi.chocoboRecolor.showMenu = function(player)
    local options =
    {
        { 'Color: ' .. colorNames[player:getLocalVar('[ChocoboMenu]Color')], cycleColor },
    }

    for _, feature in ipairs(features) do
        table.insert(options, { feature.label .. ': ' .. featureName(player:getLocalVar(feature.var) == 1), toggleFeature(feature) })
    end

    table.insert(options, { 'Confirm', function(playerArg)
        playerArg:queue(0, confirmMenu)
    end })

    player:customMenu({
        title       = 'Current chocobo state (select to change):',
        options     = options,
        onCancelled = clearDraft,
    })
end

local function openRecolor(player)
    local chocobo = player:getFieldChocobo()
    if not chocobo then
        player:printToPlayer('You need a registered chocobo before I can recolor it.', xi.msg.channel.SAY, 'Mapitoto')
        return
    end

    loadDraft(player, chocobo)
    xi.chocoboRecolor.showMenu(player)
end

m:addOverride('xi.zones.Upper_Jeuno.npcs.Mapitoto.onTrade', function(player, npc, trade)
    local item = trade:getItem(0)
    if
        trade:getSlotCount() == 1 and
        item and
        item:getID() == xi.item.MOG_KUPON_I_MAT and
        item:getSignature() == ticketSignature
    then
        player:confirmTrade()
        player:incrementCharVar(ticketVar, 1)
        openRecolor(player)
        return
    end

    super(player, npc, trade)
end)

m:addOverride('xi.zones.Upper_Jeuno.npcs.Mapitoto.onTrigger', function(player, npc)
    if player:getCharVar(ticketVar) > 0 then
        openRecolor(player)
        return
    end

    super(player, npc)
end)

return m
