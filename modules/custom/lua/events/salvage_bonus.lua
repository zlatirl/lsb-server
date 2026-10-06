-----------------------------------
-- Add a second linen purse to bosses
-- Add a third 25 armor drop to bosses
-- Add a second drop chance for 35's
-- Add a second drop chance for some cotton purses
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
xi.eraEvents.salvageBonus = xi.eraEvents.salvageBonus or {}

local event = xi.eraEvents.ScheduledEvent:new('salvageBonus')

xi.eraEvents.salvageBonus.getIsActive = function()
    return event:getIsActive()
end

local function addBonusDrops(mob, addDrops)
    mob:addListener('ITEM_DROPS', 'SALVAGE_BONUS_DROPS', function(mobArg, loot)
        addDrops(mobArg, loot)
        mobArg:removeListener('SALVAGE_BONUS_DROPS')
    end)
end

local function bonusDrops(drops)
    return function(mob, player, optParams)
        if not optParams.isKiller then
            return
        end

        addBonusDrops(mob, function(mobArg, loot)
            for _, group in ipairs(drops.groups or {}) do
                loot:addGroupFixed(group.rate, group.items)
            end

            for _, entry in ipairs(drops.items or {}) do
                loot:addItemFixed(entry.item, entry.rate)
            end
        end)
    end
end

local interactions =
{
    check = function(player)
        return event:getIsActive()
    end,

    [xi.zone.ARRAPAGO_REMNANTS] =
    {
        ['Archaic_Chariot'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.ENLILS_KOLLUKS,   rate = 100 },
                    { item = xi.item.HIKAZU_HAKAMA,    rate = 100 },
                    { item = xi.item.FREYAS_LEDELSENS, rate = 100 },
                },
            }),
        },
        ['Armored_Chariot'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.LINEN_COIN_PURSE, rate = 200 },
                },
                groups =
                {
                    {
                        rate  = 1000,
                        items =
                        {
                            { item = xi.item.BODBS_PIGACHES },
                            { item = xi.item.EAS_DOUBLET },
                            { item = xi.item.EAS_TIARA },
                            { item = xi.item.FREYRS_TROUSERS },
                            { item = xi.item.PHOBOSS_SABATONS },
                            { item = xi.item.TSUKIKAZU_GOTE },
                        },
                    },
                },
            }),
        },
        ['Deviate_Bhoot_NM'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.DEIMOSS_MASK,      rate = 50 },
                },
            }),
        },
        ['Psycheflayer_NM'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.MACHAS_CROWN,      rate = 50 },
                },
            }),
        },
        ['Qiqirn_Astrologer'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.DEIMOSS_CUIRASS,   rate = 70 },
                },
            }),
        },
        ['Qiqirn_Treasure_Hunter'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.MACHAS_COAT,       rate = 40 },
                },
            }),
        },
    },

    [xi.zone.BHAFLAU_REMNANTS] =
    {
        ['Gate_Widow'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.MACHAS_CUFFS,     rate = 80 },
                    { item = xi.item.ENLILS_BRAYETTES, rate = 70 },
                },
            }),
        },
        ['Long-Bowed_Chariot'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.LINEN_COIN_PURSE, rate = 200 },
                },
                groups =
                {
                    {
                        rate  = 1000,
                        items =
                        {
                            { item = xi.item.BODBS_ROBE },
                            { item = xi.item.PHOBOSS_CUIRASS },
                            { item = xi.item.PHOBOSS_MASK },
                            { item = xi.item.EAS_DASTANAS },
                            { item = xi.item.BODBS_CROWN },
                            { item = xi.item.FREYRS_LEDELSENS },
                            { item = xi.item.TSUKIKAZU_HAIDATE },
                        },
                    },
                },
            }),
        },
        ['Peryton'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.ENLILS_BRAYETTES, rate = 60 },
                },
            }),
        },
        ['Skirmish_Pephredo'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.HIKAZU_SUNE_ATE, rate = 90 },
                    { item = xi.item.FREYAS_MASK,     rate = 70 },
                },
            }),
        },
        ['Zebra_Zachary'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.FREYAS_MASK,       rate = 65 },
                    { item = xi.item.DEIMOSS_GAUNTLETS, rate = 80 },
                },
            }),
        },
    },

    [xi.zone.SILVER_SEA_REMNANTS] =
    {
        ['Citadel_Chelonian'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.HIKAZU_HARA_ATE, rate = 70 },
                },
            }),
        },
        ['Dekka'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.ENLILS_CRACKOWS,   rate = 70 },
                },
            }),
        },
        ['Gyroscopic_Gear'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.COTTON_COIN_PURSE, rate = 50 },
                    { item = xi.item.FREYAS_GLOVES,     rate = 70 },
                },
            }),
        },
        ['Gyroscopic_Gears'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.DEIMOSS_CUISSES, rate = 70 },
                },
            }),
        },
        ['Hammerblow_Majanun'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.HIKAZU_KABUTO, rate = 70 },
                },
            }),
        },
        ['Long-Armed_Chariot'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.LINEN_COIN_PURSE, rate = 200 },
                },
                groups =
                {
                    {
                        rate  = 1000,
                        items =
                        {
                            { item = xi.item.BODBS_CUFFS },
                            { item = xi.item.EAS_BRAIS },
                            { item = xi.item.FREYRS_JERKIN },
                            { item = xi.item.FREYRS_MASK },
                            { item = xi.item.PHOBOSS_GAUNTLETS },
                            { item = xi.item.TSUKIKAZU_SUNE_ATE },
                        },
                    },
                },
            }),
        },
        ['Powderkeg_Yanadahn'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.MACHAS_SLOPS, rate = 70 },
                },
            }),
        },
    },

    [xi.zone.ZHAYOLM_REMNANTS] =
    {
        ['Battleclad_Chariot'] =
        {
            onMobDeath = bonusDrops({
                items =
                {
                    { item = xi.item.LINEN_COIN_PURSE, rate = 200 },
                },
                groups =
                {
                    {
                        rate  = 1000,
                        items =
                        {
                            { item = xi.item.BODBS_SLOPS },
                            { item = xi.item.EAS_CRACKOWS },
                            { item = xi.item.FREYRS_GLOVES },
                            { item = xi.item.PHOBOSS_CUISSES },
                            { item = xi.item.TSUKIKAZU_JINPACHI },
                            { item = xi.item.TSUKIKAZU_TOGI },
                        },
                    },
                },
            }),
        },
        ['Poroggo_Madame'] =
        {
            onMobDeath = function(mob, player, optParams)
                if not optParams.isKiller then
                    return
                end

                addBonusDrops(mob, function(mobArg, loot)
                    local instance = mobArg:getInstance()
                    local stage    = instance and instance:getStage() or 0

                    if stage == 5 then
                        loot:addItemFixed(xi.item.ENLILS_GAMBISON, 100)
                        loot:addItemFixed(xi.item.HIKAZU_GOTE, 100)
                        loot:addItemFixed(xi.item.FREYAS_TROUSERS, 100)
                    elseif stage == 6 then
                        loot:addItemFixed(xi.item.MACHAS_PIGACHES, 100)
                        loot:addItemFixed(xi.item.DEIMOSS_LEGGINGS, 100)
                        loot:addItemFixed(xi.item.ENLILS_TIARA, 100)
                    end
                end)
            end,
        },
    },
}

event:addInteractions({ interactions })
