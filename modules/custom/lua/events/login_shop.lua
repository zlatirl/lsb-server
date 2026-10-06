-----------------------------------
-- Login Campaign & Mob_hunt Point Shop
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
require('modules/custom/lua/events/point_shop')
-----------------------------------
xi.eraEvents.loginShop = xi.eraEvents.loginShop or {}
local loginShop = xi.eraEvents.loginShop

local event = xi.eraEvents.ScheduledEvent:new('loginShop')

local shop = xi.eraEvents.PointShop:new({
    pointsVar = 'LoginPoints',
    unitName  = 'login points',
    logPath   = 'log/loginShop_audit.log',
})

loginShop.shop = shop

loginShop.getIsActive = function()
    return event:getIsActive()
end

shop.menus =
{
    ['Main Menu'] =
    {
        title   = 'Choose a point category.',
        options =
        {
            { '1 point item',  shop:menu('1 point items') },
            { '3 point item',  shop:menu('3 point items') },
            { '5 point item',  shop:menu('5 point items') },
            { '10 point item', shop:menu('10 point items') },
            { '15 point item', shop:menu('15 point items') },
            { '20 point item', shop:menu('20 point items') },
            { '40 point item', shop:menu('40 point items') },
        },
    },
    ['1 point items'] =
    {
        title   = 'Each entry costs 1 point.',
        options =
        {
            { '3 Beastmen\'s Seal', shop:item(xi.item.BEASTMENS_SEAL,    3, 1, '3 Beastmen\'s Seal') },
            { 'Kindred\'s Seal',    shop:item(xi.item.KINDREDS_SEAL,     1, 1, '1 Kindred\'s Seal') },
            { 'Ancient Beastcoin',  shop:item(xi.item.ANCIENT_BEASTCOIN, 1, 1, '1 Ancient Beastcoin') },
            { 'Back',               shop:menu('Main Menu') },
        },
    },
    ['3 point items'] =
    {
        title   = 'Each entry costs 3 points.',
        options =
        {
            { 'Celestial Globe', shop:item(xi.item.CELESTIAL_GLOBE, 1, 3, 'Celestial Globe') },
            { 'Hikogami Yukata', shop:item(xi.item.HIKOGAMI_YUKATA, 1, 3, 'Hikogami Yukata') },
            { 'Himegami Yukata', shop:item(xi.item.HIMEGAMI_YUKATA, 1, 3, 'Himegami Yukata') },
            { 'Back',            shop:menu('Main Menu') },
        },
    },
    ['5 point items'] =
    {
        title   = 'Each entry costs 5 points.',
        options =
        {
            { 'Aeolsglocke',      shop:item(xi.item.AEOLSGLOCKE,      1, 5, 'Aeolsglocke') },
            { 'Leafbell',         shop:item(xi.item.LEAFBELL,         1, 5, 'Leafbell') },
            { 'Carillon Vermeil', shop:item(xi.item.CARILLON_VERMEIL, 1, 5, 'Carillon Vermeil') },
            { 'Back',             shop:menu('Main Menu') },
        },
    },
    ['10 point items'] =
    {
        title   = 'Each entry costs 10 points.',
        options =
        {
            { '1x Lungo-Nango Jadeshell', shop:item(xi.item.LUNGO_NANGO_JADESHELL, 1, 10, '1x Lungo-Nango Jadeshell') },
            { '1x 100 Byne Bill',         shop:item(xi.item.ONE_HUNDRED_BYNE_BILL, 1, 10, '1x 100 Byne Bill') },
            { '1x Montiont Silverpiece',  shop:item(xi.item.MONTIONT_SILVERPIECE,  1, 10, '1x Montiont Silverpiece') },
            { '1x Refractive Crystal',    shop:item(xi.item.REFRACTIVE_CRYSTAL,    1, 10, '1x Refractive Crystal') },
            { 'Back',                     shop:menu('Main Menu') },
        },
    },
    ['15 point items'] =
    {
        title   = 'Each entry costs 15 points.',
        options =
        {
            { 'Imperial Army I.D Tag Kupon', shop:item(xi.item.MOG_KUPON_A_SYW,  1, 15, 'Assault Tag Kupon') },
            { 'Remnants Permit Kupon',       shop:item(xi.item.MOG_KUPON_W_RMEA, 1, 15, 'Remnants Permit Kupon') },
            { '1x Linen Coin Purse',         shop:item(xi.item.LINEN_COIN_PURSE, 1, 15, '1x Linen Coin Purse') },
            { '1x Goblin Offering',          shop:item(xi.item.GOBLIN_OFFERING,  1, 15, '1x Goblin Offering') },
            { 'Back',                        shop:menu('Main Menu') },
        },
    },
    ['20 point items'] =
    {
        title   = 'Each entry costs 20 points.',
        options =
        {
            { 'Leaf bench',    shop:item(xi.item.LEAF_BENCH,    1, 20, 'Leaf bench') },
            { 'Astral cube',   shop:item(xi.item.ASTRAL_CUBE,   1, 20, 'Astral cube') },
            { 'Chocobo Chair', shop:item(xi.item.CHOCOBO_CHAIR, 1, 20, 'Chocobo Chair') },
            { 'Back',          shop:menu('Main Menu') },
        },
    },
    ['40 point items'] =
    {
        title   = 'Each entry costs 40 points.',
        options =
        {
            { 'Honey Wine',    shop:item(xi.item.JUG_OF_HONEY_WINE,      1, 40, 'Honey Wine') },
            { 'Beastly Shank', shop:item(xi.item.BEASTLY_SHANK,          1, 40, 'Beastly Shank') },
            { 'Blue Pondweed', shop:item(xi.item.CLUMP_OF_BLUE_PONDWEED, 1, 40, 'Blue Pondweed') },
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
                    player:printToPlayer(string.format('You have %i login points to spend!', shop:getPoints(player)))
                    shop:open(player)
                    return NoAction:new()
                end,
            },
        },
    },
})
