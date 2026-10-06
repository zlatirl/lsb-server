-----------------------------------
-- ??? Boxes obtained from assault during event will have linen(40%) or cotton(60%) coinpurses
-- Trading Assault Logs to Rune of Release will roll 33% chance for a free tag
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_assault_rewards')

xi.eraEvents.assaultRewards = xi.eraEvents.assaultRewards or {}

local event = xi.eraEvents.ScheduledEvent:new('assaultRewards')

local eventBoxOrigin = 200
local freeTagChance  = 0.33

local eventBoxResults =
{
    { 40, xi.item.LINEN_COIN_PURSE },
    { 60, xi.item.COTTON_COIN_PURSE },
}

xi.eraEvents.assaultRewards.getIsActive = function()
    return event:getIsActive()
end

m:addOverride('xi.assault.runeReleaseTrade', function(player, npc, trade)
    local stamped = super(player, npc, trade)

    if
        stamped and
        xi.eraEvents.assaultRewards.getIsActive() and
        not player:hasKeyItem(xi.keyItem.IMPERIAL_ARMY_ID_TAG) and
        player:getLocalVar('rolledForFreeEventTag') == 0
    then
        player:setLocalVar('rolledForFreeEventTag', 1)

        if math.randomFloat(0, 1) <= freeTagChance then
            npcUtil.giveKeyItem(player, xi.keyItem.IMPERIAL_ARMY_ID_TAG)
            player:printToPlayer('You have received a free tag to continue your mythic progress!', xi.msg.channel.SYSTEM_1)
        end
    end

    return stamped
end)

m:addOverride('xi.assault.getUnappraisedOrigin', function(player, itemId, assaultID)
    if
        itemId == xi.item.UNAPPRAISED_BOX and
        xi.eraEvents.assaultRewards.getIsActive()
    then
        return eventBoxOrigin
    end

    return super(player, itemId, assaultID)
end)

m:addOverride('xi.appraisal.itemPick', function(player, info, appraisalID)
    if appraisalID == eventBoxOrigin then
        return super(player, { [eventBoxOrigin] = { items = eventBoxResults } }, appraisalID)
    end

    return super(player, info, appraisalID)
end)
