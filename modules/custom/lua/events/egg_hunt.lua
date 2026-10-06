-----------------------------------
-- Egg Hunt event: Non-NM and Non-battlefield mobs that are higher lv. then you and your in a party of 4 have a chance to drop a E egg.
-- trade the E Egg to the guidestone in jeuno to eggHuntPoints and a random egg.
-- They can talk to the fountain in Ru'Lude Gardens to spend those points.
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
require('modules/custom/lua/events/point_shop')
-----------------------------------
local m = Module:new('era_egg_hunt')

xi.eraEvents.eggHunt = xi.eraEvents.eggHunt or {}
local eggHunt = xi.eraEvents.eggHunt

local event = xi.eraEvents.ScheduledEvent:new('eggHunt')

local logPath        = 'log/eggHunt_audit.log'
local eggChance      = 0.10
local pointsPerEEgg  = 3

local drops =
{
    { weight = 2,   item = xi.item.D_EGG },
    { weight = 5,   item = xi.item.S_EGG },
    { weight = 15,  item = xi.item.R_EGG },
    { weight = 15,  item = xi.item.M_EGG },
    { weight = 15,  item = xi.item.H_EGG },
    { weight = 15,  item = xi.item.G_EGG },
    { weight = 15,  item = xi.item.J_EGG },
    { weight = 300, item = xi.item.E_EGG },
}

local shop = xi.eraEvents.PointShop:new({
    pointsVar     = 'eggHuntPoints',
    unitName      = 'egg points',
    onceVarPrefix = 'eggHunt',
    logPath       = logPath,
})

eggHunt.shop = shop

eggHunt.getIsActive = function()
    return event:getIsActive()
end

local function pickDrop()
    local totalWeight = 0
    for _, drop in ipairs(drops) do
        totalWeight = totalWeight + drop.weight
    end

    local roll = math.randomInt(1, totalWeight)
    for _, drop in ipairs(drops) do
        if roll <= drop.weight then
            return drop.item
        end

        roll = roll - drop.weight
    end
end

eggHunt.onMobDeath = function(mob, player, isKiller)
    if
        not isKiller or
        not eggHunt.getIsActive() or
        player:getPartySize() < 4 or
        mob:getMainLvl() <= player:getMainLvl() or
        mob:getMobMod(xi.mobMod.CHECK_AS_NM) > 0 or
        mob:isMobType(xi.mobType.NOTORIOUS) or
        mob:isMobType(xi.mobType.BATTLEFIELD)
    then
        return
    end

    if math.randomFloat(0, 1) > eggChance then
        return
    end

    local item = pickDrop()

    player:addTreasure(item, mob)
    player:printToPlayer('This thing can drop an egg?', xi.msg.channel.NS_SAY)

    local logFile = io.open(logPath, 'a')
    if logFile then
        logFile:write(string.format('[%s] %s (%is playtime) added item %i to their treasure pool.\n', os.date(), player:getName(), player:getPlaytime(), item))
        logFile:close()
    end
end

eggHunt.onGuideStoneTrade = function(player, npc, trade)
    local eEggs = trade:getItemQty(xi.item.E_EGG)

    if eEggs == 0 then
        return
    end

    trade:confirmItem(xi.item.E_EGG, eEggs)
    player:confirmTrade()
    player:printToPlayer('Thank you for the eggs! Here have this gift.', xi.msg.channel.SYSTEM_3)
    player:incrementCharVar('eggHuntPoints', pointsPerEEgg * eEggs)

    return NoAction:new()
end

eggHunt.onGuideStoneTrigger = function(player, npc)
    player:printToPlayer('Trade me E egg\'s right now!!!', xi.msg.channel.SYSTEM_3)

    return NoAction:new()
end

eggHunt.openShopMenu = function(player, npc)
    player:printToPlayer(string.format('Your efforts have garnered you %i egg points!', shop:getPoints(player)))
    shop:open(player)

    return NoAction:new()
end

shop.menus =
{
    ['Main Menu'] =
    {
        title   = 'Choose a point category.',
        options =
        {
            { '1 point items',  shop:menu('1 point items') },
            { '3 point items',  shop:menu('3 point items') },
            { '5 point items',  shop:menu('5 point items') },
            { '7 point items',  shop:menu('7 point items') },
            { '10 point items', shop:menu('10 point items') },
            { '20 point items', shop:menu('20 point items') },
        },
    },
    ['1 point items'] =
    {
        title   = 'Each entry costs 1 egg point.',
        options =
        {
            { 'Egg Stool',   shop:item(xi.item.EGG_STOOL,   1, 1, 'Egg Stool') },
            { 'Egg table',   shop:item(xi.item.EGG_TABLE,   1, 1, 'Egg table') },
            { 'Egg locker',  shop:item(xi.item.EGG_LOCKER,  1, 1, 'Egg Locker') },
            { 'Egg lantern', shop:item(xi.item.EGG_LANTERN, 1, 1, 'Egg lantern') },
            { 'Egg Buffet',  shop:item(xi.item.EGG_BUFFET,  1, 1, 'Egg Buffet') },
            { 'Back',        shop:menu('Main Menu') },
        },
    },
    ['3 point items'] =
    {
        title   = 'Each entry costs 3 egg points.',
        options =
        {
            { 'Wing Egg',    shop:item(xi.item.WING_EGG,    1, 3, 'Wing Egg') },
            { 'Lamp Egg',    shop:item(xi.item.LAMP_EGG,    1, 3, 'Lamp Egg') },
            { 'Flower Egg',  shop:item(xi.item.FLOWER_EGG,  1, 3, 'Flower Egg') },
            { 'Jeweled Egg', shop:item(xi.item.JEWELED_EGG, 1, 3, 'Jeweled Egg') },
            { 'Back',        shop:menu('Main Menu') },
        },
    },
    ['5 point items'] =
    {
        title   = 'Each entry costs 5 egg points.',
        options =
        {
            { 'Melodious Egg',  shop:item(xi.item.MELODIUS_EGG,   1, 5, 'Melodious egg') },
            { 'Clockwork Egg',  shop:item(xi.item.CLOCKWORK_EGG,  1, 5, 'Clockwork Egg') },
            { 'Hatchling Egg',  shop:item(xi.item.HATCHLING_EGG,  1, 5, 'Hatchling Egg') },
            { 'Prinseggstarta', shop:item(xi.item.PRINSEGGSTARTA, 1, 5, 'Prinseggstarta') },
            { 'Back',           shop:menu('Main Menu') },
        },
    },
    ['7 point items'] =
    {
        title   = 'Each entry costs 7 egg points.',
        options =
        {
            { 'Happy Egg',   shop:item(xi.item.HAPPY_EGG,   1, 7, 'Happy Egg') },
            { 'Fortune Egg', shop:item(xi.item.FORTUNE_EGG, 1, 7, 'Fortune Egg') },
            { 'Orphic Egg',  shop:item(xi.item.ORPHIC_EGG,  1, 7, 'Orphic Egg') },
            { 'Back',        shop:menu('Main Menu') },
        },
    },
    ['10 point items'] =
    {
        title   = 'Each entry costs 10 egg points.',
        options =
        {
            { 'Goblin Offering (once)',         shop:itemOnce(xi.item.GOBLIN_OFFERING,    1,  10, 'Goblin Offering') },
            { '12x Refractive Crystals (once)', shop:itemOnce(xi.item.REFRACTIVE_CRYSTAL, 12, 10, 'Refractive Crystal') },
            { 'Assault Tag Kupon (once)',       shop:itemOnce(xi.item.MOG_KUPON_A_SYW,    1,  10, 'Assault Tag Kupon') },
            { 'Remnants Permit Kupon (once)',   shop:itemOnce(xi.item.MOG_KUPON_W_RMEA,   1,  10, 'Remnants Permit Kupon') },
            { 'Back',                           shop:menu('Main Menu') },
        },
    },
    ['20 point items'] =
    {
        title   = 'Each entry costs 20 egg points.',
        options =
        {
            { 'Leaf bench',    shop:item(xi.item.LEAF_BENCH,    1, 20, 'Leaf bench') },
            { 'Astral cube',   shop:item(xi.item.ASTRAL_CUBE,   1, 20, 'Astral cube') },
            { 'Chocobo Chair', shop:item(xi.item.CHOCOBO_CHAIR, 1, 20, 'Chocobo Chair') },
            { 'Back',          shop:menu('Main Menu') },
        },
    },
}

local interactions =
{
    check = function(player)
        return event:getIsActive()
    end,

    [xi.zone.RULUDE_GARDENS] =
    {
        ['relic'] =
        {
            onTrigger = eggHunt.openShopMenu,
        },
    },
}

for _, zoneID in ipairs({ xi.zone.LOWER_JEUNO, xi.zone.PORT_JEUNO, xi.zone.UPPER_JEUNO }) do
    interactions[zoneID] =
    {
        ['Guide_Stone'] =
        {
            onTrigger = eggHunt.onGuideStoneTrigger,
            onTrade   = eggHunt.onGuideStoneTrade,
        },
    }
end

event:addInteractions({ interactions })

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    eggHunt.onMobDeath(mob, player, isKiller)
end)
