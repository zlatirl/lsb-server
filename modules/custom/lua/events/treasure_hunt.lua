-----------------------------------
-- If your in a group of 4 of more and the mob is high lv. then you you have a chance at a drop
-- 15% change of a drop and drop is from 3 bucket
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_treasure_hunt')

xi.eraEvents.treasureHunt = xi.eraEvents.treasureHunt or {}
local treasureHunt = xi.eraEvents.treasureHunt

local event = xi.eraEvents.ScheduledEvent:new('treasurehunt')

local logPath = 'log/treasurehunt_audit.log'

-- 15% chance to drop SOMETHING.
-- If something will drop, it chooses from one of four tiers.
-- These odds are all defined by relative rarity rather than absolute chance.
-- For example, Tier 1 is 3 times more likely than Tier 2.
-- Once Tier 1 is chosen, a Beastmen's Seal is 9 times more likely than a Kindred's Crest.
-- A Beastmen's Seal comes out to an absolute chance to drop of 3.85%.
local dropRate  = 150 -- 15% out of 1000. Comes out to 5.4% of Tier 2 or higher.
local dropTiers =
{
    {
        rate    = 120,
        message = 'You found some treasure!',
        drops   =
        {
            { rate = 8, item = xi.item.BEASTMENS_SEAL },
            { rate = 4, item = xi.item.KINDREDS_SEAL },
            { rate = 2, item = xi.item.KINDREDS_CREST },
            { rate = 1, item = xi.item.HIGH_KINDREDS_CREST },
        },
    },
    {
        rate    = 40,
        message = 'You found some rare treasure!',
        drops   =
        {
            { rate = 2, item = xi.item.LUNGO_NANGO_JADESHELL },
            { rate = 2, item = xi.item.ONE_HUNDRED_BYNE_BILL },
            { rate = 2, item = xi.item.MONTIONT_SILVERPIECE },
            { rate = 1, item = xi.item.REFRACTIVE_CRYSTAL },
        },
    },
    {
        rate    = 24,
        message = 'You found some very rare treasure!',
        drops   =
        {
            { rate = 2, item = xi.item.COTTON_COIN_PURSE },
            { rate = 1, item = xi.item.GOBLIN_OFFERING },
        },
    },
}

treasureHunt.getIsActive = function()
    return event:getIsActive()
end

local function pickByRate(entries)
    local total = 0
    for _, entry in ipairs(entries) do
        total = total + entry.rate
    end

    local roll = math.randomInt(1, total)
    for _, entry in ipairs(entries) do
        if roll <= entry.rate then
            return entry
        end

        roll = roll - entry.rate
    end
end

treasureHunt.onMobDeath = function(mob, player, isKiller)
    if
        not isKiller or
        not treasureHunt.getIsActive() or
        player:getPartySize() < 4 or
        mob:getMainLvl() < player:getMainLvl() or
        mob:getMobMod(xi.mobMod.CHECK_AS_NM) > 0 or
        mob:isMobType(xi.mobType.NOTORIOUS) or
        mob:isMobType(xi.mobType.BATTLEFIELD)
    then
        return
    end

    if math.randomInt(1, 1000) > dropRate then
        return
    end

    local tier = pickByRate(dropTiers)
    local item = pickByRate(tier.drops).item

    player:addTreasure(item, mob)
    player:printToPlayer(tier.message, xi.msg.channel.NS_SAY)

    local logFile = io.open(logPath, 'a')
    if logFile then
        logFile:write(string.format('[%s] %s (lv.%i) dropped item %i (tierRate %i) for %s.\n', os.date(), mob:getName(), mob:getMainLvl(), item, tier.rate, player:getName()))
        logFile:close()
    end
end

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    treasureHunt.onMobDeath(mob, player, isKiller)
end)
