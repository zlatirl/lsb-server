-----------------------------------
-- Module: Sanraku Zeni Trades
--   Area: Aht Urhgan Whitegate
--    NPC: Sanraku
-- Desc: Trade certain Nyzul Isle / ToAU boss drops to Sanraku for bonus Zeni.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_sanraku_zeni_trades')

xi.sanrakuZeniTrades = xi.sanrakuZeniTrades or {}

local tradeRewards =
{
    [xi.item.WYRM_HORN]                  = 1000,
    [xi.item.OROBON_LURE]                = 1000,
    [xi.item.KHIMAIRA_TAIL]              = 1000,
    [xi.item.SLICE_OF_CERBERUS_MEAT]     = 1000,
    [xi.item.HANDFUL_OF_NIDHOGGS_SCALES] = 1000,
    [xi.item.CHUNK_OF_HYDRA_MEAT]        = 1000,
}

xi.sanrakuZeniTrades.getReward = function(player, itemId)
    return tradeRewards[itemId]
end

m:addOverride('xi.znm.sanraku.onTrade', function(player, npc, trade)
    local itemId = trade:getItemCount() == 1 and trade:getItemId(0) or 0
    local reward = tradeRewards[itemId] and xi.sanrakuZeniTrades.getReward(player, itemId)

    if not reward then
        super(player, npc, trade)
        return
    end

    trade:confirmItem(itemId)
    player:confirmTrade()
    player:addCurrency('zeni_point', reward)
    player:printToPlayer(string.format('Excellent! I shall add this to my collection. Take this bonus of %i Zeni!', reward), xi.msg.channel.SAY, 'Sanraku')
    player:printToPlayer(string.format('You have received %i bonus Zeni for a total of %i', reward, player:getCurrency('zeni_point')), xi.msg.channel.SYSTEM_1)
end)
