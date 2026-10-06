-----------------------------------
-- Homepoint Crystal Exchange
-----------------------------------
require('modules/module_utils')
-----------------------------------

xi = xi or {}
xi.homepointExchange = xi.homepointExchange or {}

-- Crystal to Cluster Exchange
xi.homepointExchange.onTrade = function(player, npc, trade)
    local clusterShift   = xi.item.FIRE_CLUSTER - xi.item.FIRE_CRYSTAL
    local clustersToGive = {}

    -- Check for crystal to cluster exchanges (12 crystals = 1 cluster)
    for itemID = xi.item.FIRE_CRYSTAL, xi.item.DARK_CRYSTAL do
        local crystalQty = trade:getItemQty(itemID)
        local clusters   = math.floor(crystalQty / 12)

        if clusters > 0 and npcUtil.tradeHas(trade, { { itemID, clusters * 12 } }) then
            clustersToGive[#clustersToGive + 1] = { itemID + clusterShift, clusters }
        end
    end

    if #clustersToGive > 0 then
        player:confirmTrade()
        npcUtil.giveItem(player, clustersToGive)
        return true
    end

    -- Check for Chocobo Whistle recharge
    if npcUtil.tradeHasExactly(trade, xi.item.CHOCOBO_WHISTLE) then
        player:confirmTrade()
        npcUtil.giveItem(player, xi.item.CHOCOBO_WHISTLE)
        player:printToPlayer('Your Chocobo Whistle has been re-charged!', xi.msg.channel.SAY, 'Home Point')
        return true
    end

    return false
end

local m = Module:new('era_homepoint_crystal_exchange')

local homepoints =
{
    'xi.zones.Aht_Urhgan_Whitegate.npcs.HomePoint#2',
    'xi.zones.Lower_Jeuno.npcs.HomePoint#1',
    'xi.zones.Lower_Jeuno.npcs.HomePoint#2',
    'xi.zones.RuLude_Gardens.npcs.HomePoint#3',
}

for _, path in ipairs(homepoints) do
    m:addOverride(path .. '.onTrade', function(player, npc, trade)
        xi.homepointExchange.onTrade(player, npc, trade)
    end)
end

return xi.homepointExchange
