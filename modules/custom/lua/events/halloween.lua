-----------------------------------
-- Halloween event: spawn special spooky enemies in low level zones that drop candy and give points for the event shop
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
require('modules/custom/lua/events/point_shop')
-----------------------------------
xi.eraEvents.halloween = xi.eraEvents.halloween or {}
local halloween = xi.eraEvents.halloween

halloween.activeMobs   = halloween.activeMobs or {}
halloween.respawnTimes = halloween.respawnTimes or {}

local event = xi.eraEvents.ScheduledEvent:new('halloween')

local logPath     = 'log/halloween_audit.log'
local respawnTime = 10 * 60
local mobLevel    = 40
local pointsGain  = 3
local rewardRange = 100
local mobVariants = 10

-- Trick or Treat mobs are defined in modules/custom/data/zones/<zone>/mobs.yaml,
-- using the top mobVariants IDs of each zone's mob range.
local zoneSpawnPoints =
{
    [xi.zone.EAST_RONFAURE] =
    {
        { 448.468, -1.452, -472.382 },
        { 167.811, -20.637, -112.122 },
        { 440.973, -50.000, 320.165 },
    },
    [xi.zone.WEST_RONFAURE] =
    {
        { -205.360, -59.837, 441.303 },
        { -665.227, -27.941, 22.534 },
        { 1.065, 0.277, -526.266 },
    },
    [xi.zone.LA_THEINE_PLATEAU] =
    {
        { -749.116, 7.657, 119.759 },
        { 104.428, 24.753, -558.114 },
        { 512.064, 40.196, 478.931 },
    },
    [xi.zone.SOUTH_GUSTABERG] =
    {
        { -558.878, 40.000, -399.793 },
        { 219.268, -59.900, -436.053 },
        { 348.453, -0.778, -671.586 },
    },
    [xi.zone.NORTH_GUSTABERG] =
    {
        { -620.824, 40.070, 272.685 },
        { -165.653, -0.504, 409.238 },
        { 268.464, -60.006, 520.005 },
    },
    [xi.zone.KONSCHTAT_HIGHLANDS] =
    {
        { 626.474, 40.548, 437.948 },
        { -115.856, 23.975, 318.642 },
        { 522.723, 8.000, 193.000 },
    },
    [xi.zone.WEST_SARUTABARUTA] =
    {
        { -397.634, -28.000, 438.607 },
        { 10.133, -25.524, 544.115 },
        { -386.043, 3.249, -359.660 },
    },
    [xi.zone.EAST_SARUTABARUTA] =
    {
        { -234.932, -22.500, 661.420 },
        { -355.240, -0.444, -190.542 },
        { 467.637, 9.500, -140.818 },
    },
    [xi.zone.TAHRONGI_CANYON] =
    {
        { -458.539, -39.926, -133.012 },
        { -306.617, 7.820, 248.577 },
        { -77.175, 32.166, 552.656 },
    },
}

-- 100% of one of these items
local drops =
{
    { weight = 50,  item = xi.item.ANCIENT_BEASTCOIN },
    { weight = 50,  item = xi.item.ONE_HUNDRED_BYNE_BILL },
    { weight = 50,  item = xi.item.MONTIONT_SILVERPIECE },
    { weight = 50,  item = xi.item.LUNGO_NANGO_JADESHELL },
    { weight = 100, item = xi.item.REFRACTIVE_CRYSTAL },
    { weight = 100, item = xi.item.JACK_O_LANTERN },
    { weight = 100, item = xi.item.HANDFUL_OF_BLOODY_CHOCOLATE },
    { weight = 150, item = xi.item.PERSIKOS },
    { weight = 150, item = xi.item.KITRON },
    { weight = 200, item = xi.item.LITTLE_WORM },
}

local shop = xi.eraEvents.PointShop:new({
    pointsVar     = 'halloweenPoints',
    unitName      = 'treat points',
    onceVarPrefix = 'halloween',
    logPath       = logPath,
})

halloween.shop = shop

halloween.getIsActive = function()
    return event:getIsActive()
end

local function getFirstMobID(zoneID)
    return bit.lshift(0x1000 + zoneID, 12) + 0x400 - mobVariants
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

halloween.onMobDeath = function(mob, killer)
    if not killer or not killer:isPC() then
        return
    end

    local zoneID = mob:getZoneID()

    for _, member in pairs(killer:getAlliance()) do
        if member:getZoneID() == zoneID and member:checkDistance(mob) < rewardRange then
            member:incrementCharVar('halloweenPoints', pointsGain)
            member:printToPlayer(string.format('You\'ve earned %i treat points!', pointsGain))
        end
    end

    killer:addTreasure(pickDrop(), mob)
end

halloween.onMobDespawn = function(mob)
    local zoneID = mob:getZoneID()

    halloween.activeMobs[zoneID]   = nil
    halloween.respawnTimes[zoneID] = GetSystemTime() + respawnTime
end

local function spawnMob(zoneID)
    local points = zoneSpawnPoints[zoneID]
    local pos    = points[math.randomInt(1, #points)]
    local mobID  = getFirstMobID(zoneID) + math.randomInt(0, mobVariants - 1)
    local mob    = GetMobByID(mobID)

    if not mob or mob:isSpawned() then
        return
    end

    mob:setSpawn(pos[1], pos[2], pos[3], 0)
    mob:addListener('DEATH', 'HALLOWEEN_DEATH', halloween.onMobDeath)
    mob:addListener('DESPAWN', 'HALLOWEEN_DESPAWN', halloween.onMobDespawn)

    SpawnMob(mobID)

    mob:renameEntity('Trick or Treat', true)
    mob:setMobLevel(mobLevel)
    mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
    mob:setMobMod(xi.mobMod.NO_DESPAWN, 1)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)

    halloween.activeMobs[zoneID] = mobID
end

event:setServerTickFunction(function()
    local time = GetSystemTime()

    for zoneID, _ in pairs(zoneSpawnPoints) do
        if
            GetZone(zoneID) and
            not halloween.activeMobs[zoneID] and
            time >= (halloween.respawnTimes[zoneID] or 0)
        then
            spawnMob(zoneID)
        end
    end
end)

event:setEndFunction(function()
    for zoneID, mobID in pairs(halloween.activeMobs) do
        halloween.activeMobs[zoneID] = nil
        DespawnMob(mobID)
    end

    halloween.respawnTimes = {}
end)

shop.menus =
{
    ['Main Menu'] =
    {
        title   = 'Choose a point category.',
        options =
        {
            { '1 treat items',  shop:menu('1 point items') },
            { '3 treat items',  shop:menu('3 point items') },
            { '5 treat items',  shop:menu('5 point items') },
            { '7 treat items',  shop:menu('7 point items') },
            { '15 treat items', shop:menu('15 point items') },
            { '20 treat items', shop:menu('20 point items') },
        },
    },
    ['1 point items'] =
    {
        title   = 'Each entry costs 1 treat point.',
        options =
        {
            { 'Pumpkin Head',    shop:item(xi.item.PUMPKIN_HEAD,    1, 1, 'Pumpkin Head') },
            { 'Pumpkin Head II', shop:item(xi.item.PUMPKIN_HEAD_II, 1, 1, 'Pumpkin Head II') },
            { 'Trick Staff',     shop:item(xi.item.TRICK_STAFF,     1, 1, 'Trick Staff') },
            { 'Trick Staff II',  shop:item(xi.item.TRICK_STAFF_II,  1, 1, 'Trick Staff II') },
            { 'Pitchfork',       shop:item(xi.item.PITCHFORK,       1, 1, 'Pitchfork') },
            { 'Back',            shop:menu('Main Menu') },
        },
    },
    ['3 point items'] =
    {
        title   = 'Each entry costs 3 treat points.',
        options =
        {
            { 'Flan Masque',  shop:item(xi.item.FLAN_MASQUE,  1, 3, 'Flan Masque') },
            { 'Botulus Suit', shop:item(xi.item.BOTULUS_SUIT, 1, 3, 'Botulus Suit') },
            { 'Ahriman Cap',  shop:item(xi.item.AHRIMAN_CAP,  1, 3, 'Ahriman Cap') },
            { 'Eerie Cloak',  shop:item(xi.item.EERIE_CLOAK,  1, 3, 'Eerie Cloak') },
            { 'Witch Hat',    shop:item(xi.item.WITCH_HAT,    1, 3, 'Witch Hat') },
            { 'Back',         shop:menu('Main Menu') },
        },
    },
    ['5 point items'] =
    {
        title   = 'Each entry costs 5 treat points.',
        options =
        {
            { 'Horror Head',    shop:item(xi.item.HORROR_HEAD,    1, 5, 'Horror Head') },
            { 'Horror Head II', shop:item(xi.item.HORROR_HEAD_II, 1, 5, 'Horror Head II') },
            { 'Treat Staff',    shop:item(xi.item.TREAT_STAFF,    1, 5, 'Treat Staff') },
            { 'Treat Staff II', shop:item(xi.item.TREAT_STAFF_II, 1, 5, 'Treat Staff II') },
            { 'Pitchfork +1',   shop:item(xi.item.PITCHFORK_P1,   1, 5, 'Pitchfork +1') },
            { 'Back',           shop:menu('Main Menu') },
        },
    },
    ['7 point items'] =
    {
        title   = 'Each entry costs 7 treat points.',
        options =
        {
            { 'Flan Masque +1',  shop:item(xi.item.FLAN_MASQUE_P1,  1, 7, 'Flan Masque +1') },
            { 'Botulus Suit +1', shop:item(xi.item.BOTULUS_SUIT_P1, 1, 7, 'Botulus Suit +1') },
            { 'Pyracmon Cap',    shop:item(xi.item.PYRACMON_CAP,    1, 7, 'Pyracmon Cap') },
            { 'Eerie Cloak +1',  shop:item(xi.item.EERIE_CLOAK_P1,  1, 7, 'Eerie Cloak +1') },
            { 'Coven Hat',       shop:item(xi.item.COVEN_HAT,       1, 7, 'Coven Hat') },
            { 'Back',            shop:menu('Main Menu') },
        },
    },
    ['15 point items'] =
    {
        title   = 'Each entry costs 15 treat points. (once)',
        options =
        {
            { 'Goblin Offering',       shop:itemOnce(xi.item.GOBLIN_OFFERING,    1,  15, 'Goblin Offering') },
            { '12 Refractive Crystal', shop:itemOnce(xi.item.REFRACTIVE_CRYSTAL, 12, 15, 'Refractive Crystal') },
            { 'Back',                  shop:menu('Main Menu') },
        },
    },
    ['20 point items'] =
    {
        title   = 'Each entry costs 20 treat points.',
        options =
        {
            { 'Leaf bench',    shop:item(xi.item.LEAF_BENCH,    1, 20, 'Leaf bench') },
            { 'Astral cube',   shop:item(xi.item.ASTRAL_CUBE,   1, 20, 'Astral cube') },
            { 'Chocobo Chair', shop:item(xi.item.CHOCOBO_CHAIR, 1, 20, 'Chocobo Chair') },
            { 'Giant Donko',   shop:item(xi.item.GIANT_DONKO_1, 1, 20, 'Giant Donko') },
            { 'Back',          shop:menu('Main Menu') },
        },
    },
}

event:addInteractions({
    {
        check = function(player)
            return event:getIsActive()
        end,

        [xi.zone.RULUDE_GARDENS] =
        {
            ['relic'] =
            {
                onTrigger = function(player, npc)
                    player:printToPlayer(string.format('You have %i treat points to spend!', shop:getPoints(player)))
                    shop:open(player)
                    return NoAction:new()
                end,
            },
        },
    },
})
