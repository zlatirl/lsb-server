-----------------------------------
-- Era Augments: Runga-Kopunga
--   Area: Lower Jeuno
-- Desc: Accessory exchanges (F.A.I.L. Badge) and egg augments for select weapons and armor.
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/era_augments/augments')
-----------------------------------
local m = Module:new('era_augments_runga_kopunga')

xi.module.ensureTable('xi.zones.Lower_Jeuno.npcs.Runga-Kopunga')

local npcName = 'Runga-Kopunga'

local accessoryExchange =
{
    -- DM Earring Cycle
    [xi.item.SUPPANOMIMI]     = xi.item.BUSHINOMIMI,
    [xi.item.BUSHINOMIMI]     = xi.item.BEASTLY_EARRING,
    [xi.item.BEASTLY_EARRING] = xi.item.KNIGHTS_EARRING,
    [xi.item.KNIGHTS_EARRING] = xi.item.ABYSSAL_EARRING,
    [xi.item.ABYSSAL_EARRING] = xi.item.SUPPANOMIMI,

    -- CoP Ring Cycle
    [xi.item.RAJAS_RING]  = xi.item.TAMAS_RING,
    [xi.item.TAMAS_RING]  = xi.item.SATTVA_RING,
    [xi.item.SATTVA_RING] = xi.item.RAJAS_RING,

    -- Apoc Nigh Earring Cycle
    [xi.item.STATIC_EARRING]   = xi.item.MAGNETIC_EARRING,
    [xi.item.MAGNETIC_EARRING] = xi.item.HOLLOW_EARRING,
    [xi.item.HOLLOW_EARRING]   = xi.item.ETHEREAL_EARRING,
    [xi.item.ETHEREAL_EARRING] = xi.item.STATIC_EARRING,

    -- ToAU Ring Cycle
    [xi.item.BALRAHNS_RING] = xi.item.ULTHALAMS_RING,
    [xi.item.ULTHALAMS_RING] = xi.item.JALZAHNS_RING,
    [xi.item.JALZAHNS_RING] = xi.item.BALRAHNS_RING,
}

local accessoryGilExchange =
{
    -- DM Earrings
    {
        [xi.item.SUPPANOMIMI] = 1,
        [xi.item.BUSHINOMIMI] = 2,
        [xi.item.BEASTLY_EARRING] = 3,
        [xi.item.KNIGHTS_EARRING] = 4,
        [xi.item.ABYSSAL_EARRING] = 5,
    },
    -- CoP Rings
    {
        [xi.item.RAJAS_RING] = 1,
        [xi.item.TAMAS_RING] = 2,
        [xi.item.SATTVA_RING] = 3,
    },
    -- Apoc Nigh Earrings
    {
        [xi.item.STATIC_EARRING] = 1,
        [xi.item.MAGNETIC_EARRING] = 2,
        [xi.item.HOLLOW_EARRING] = 3,
        [xi.item.ETHEREAL_EARRING] = 4,
    },
    -- ToAU Rings
    {
        [xi.item.BALRAHNS_RING] = 1,
        [xi.item.ULTHALAMS_RING] = 2,
        [xi.item.JALZAHNS_RING] = 3,
    },
}

local augments =
{
    [xi.item.RIDILL] =
    {
        eggs =
        {
            {
                egg = xi.item.S_EGG,
                slots =
                {
                    {
                        { weight = 1, id = xi.augment.ATTACK_P1, minValue = 0, maxValue = 9, desc = 'Attack+%d' },
                    }
                }
            },
            {
                egg = xi.item.D_EGG,
                slots =
                {
                    {
                        { weight = 89, id = xi.augment.DMG_P1, minValue = 4, maxValue = 14, desc = 'DMG+%d' },
                        { weight = 10, id = xi.augment.DMG_P1, minValue = 15, maxValue = 18, desc = 'DMG+%d (Near Max!)' },
                        { weight = 1, id = xi.augment.DMG_P1, minValue = 19, maxValue = 19, desc = 'DMG+%d (MAX!)' },
                    }
                }
            }
        }
    },
    [xi.item.KRAKEN_CLUB] =
    {
        eggs =
        {
            {
                egg = xi.item.S_EGG,
                slots =
                {
                    {
                        { weight = 1, id = xi.augment.ATTACK_P1, minValue = 0, maxValue = 9, desc = 'Attack+%d' },
                    }
                }
            },
            {
                egg = xi.item.D_EGG,
                slots =
                {
                    {
                        { weight = 89, id = xi.augment.DMG_P1, minValue = 4, maxValue = 14, desc = 'DMG+%d' },
                        { weight = 10, id = xi.augment.DMG_P1, minValue = 15, maxValue = 18, desc = 'DMG+%d (Near Max!)' },
                        { weight = 1, id = xi.augment.DMG_P1, minValue = 19, maxValue = 19, desc = 'DMG+%d (MAX!)' },
                    }
                }
            }
        }
    },
    [xi.item.JOYEUSE] =
    {
        eggs =
        {
            {
                egg = xi.item.D_EGG,
                slots =
                {
                    {
                        { weight = 89, id = xi.augment.DMG_P1, minValue = 4, maxValue = 14, desc = 'DMG+%d' },
                        { weight = 10, id = xi.augment.DMG_P1, minValue = 15, maxValue = 18, desc = 'DMG+%d (Near Max!)' },
                        { weight = 1, id = xi.augment.DMG_P1, minValue = 19, maxValue = 19, desc = 'DMG+%d (MAX!)' },
                    }
                }
            }
        }
    },
    [xi.item.MERCURIAL_KRIS] =
    {
        eggs =
        {
            {
                egg = xi.item.D_EGG,
                slots =
                {
                    {
                        { weight = 89, id = xi.augment.DMG_P1, minValue = 4, maxValue = 14, desc = 'DMG+%d' },
                        { weight = 10, id = xi.augment.DMG_P1, minValue = 15, maxValue = 18, desc = 'DMG+%d (Near Max!)' },
                        { weight = 1, id = xi.augment.DMG_P1, minValue = 19, maxValue = 19, desc = 'DMG+%d (MAX!)' },
                    }
                }
            }
        }
    },
    [xi.item.CHATOYANT_STAFF] =
    {
        eggs =
        {
            {
                egg = xi.item.M_EGG,
                slots =
                {
                    {
                        { weight = 1, id = xi.augment.DIVINE_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Divine Magic Skill+%d' },
                        { weight = 1, id = xi.augment.HEALING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Healing Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ENHANCING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Enhancing Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ENFEEBLING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Enfeebling Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ELEMENTAL_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Elemental Magic Skill+%d' },
                        { weight = 1, id = xi.augment.DARK_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Dark Magic Skill+%d' },
                        { weight = 1, id = xi.augment.SUMMONING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Summoning Magic Skill+%d' },
                        { weight = 1, id = xi.augment.NINJUTSU_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Ninjutsu Skill+%d' },
                        { weight = 1, id = xi.augment.SINGING_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Singing Skill+%d' },
                        { weight = 1, id = xi.augment.STRING_INSTRUMENT_SKILL_P1, minValue = 0, maxValue = 4, desc = 'String Instrument Skill+%d' },
                        { weight = 1, id = xi.augment.WIND_INSTRUMENT_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Wind Instrument Skill+%d' },
                        { weight = 1, id = xi.augment.BLUE_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Blue Magic Skill+%d' },
                    },
                    {
                        { weight = 1, id = xi.augment.DIVINE_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Divine Magic Skill+%d' },
                        { weight = 1, id = xi.augment.HEALING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Healing Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ENHANCING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Enhancing Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ENFEEBLING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Enfeebling Magic Skill+%d' },
                        { weight = 1, id = xi.augment.ELEMENTAL_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Elemental Magic Skill+%d' },
                        { weight = 1, id = xi.augment.DARK_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Dark Magic Skill+%d' },
                        { weight = 1, id = xi.augment.SUMMONING_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Summoning Magic Skill+%d' },
                        { weight = 1, id = xi.augment.NINJUTSU_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Ninjutsu Skill+%d' },
                        { weight = 1, id = xi.augment.SINGING_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Singing Skill+%d' },
                        { weight = 1, id = xi.augment.STRING_INSTRUMENT_SKILL_P1, minValue = 0, maxValue = 4, desc = 'String Instrument Skill+%d' },
                        { weight = 1, id = xi.augment.WIND_INSTRUMENT_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Wind Instrument Skill+%d' },
                        { weight = 1, id = xi.augment.BLUE_MAGIC_SKILL_P1, minValue = 0, maxValue = 4, desc = 'Blue Magic Skill+%d' },
                    }
                }
            }
        }
    },
    [xi.item.SCORPION_HARNESS_P1] =
    {
        eggs =
        {
            {
                egg = xi.item.H_EGG,
                slots =
                {
                    {
                        { weight = 1, id = xi.augment.HP_P1, minValue = 0, maxValue = 9, desc = 'HP+%d' },
                        { weight = 1, id = xi.augment.ATTACK_P1, minValue = 0, maxValue = 9, desc = 'Attack+%d' },
                        { weight = 1, id = xi.augment.RAPID_SHOT_P1, minValue = 0, maxValue = 9, desc = 'Rapid Shot+%d' },
                        { weight = 1, id = xi.augment.HASTE_P1, minValue = 0, maxValue = 0, desc = 'Haste+1%%' },
                        { weight = 1, id = xi.augment.ACCURACY_P1, minValue = 0, maxValue = 9, desc = 'Accuracy+%d' },
                    }
                }
            }
        }
    },
}

local itemNames =
{
    [xi.item.RIDILL]              = 'your Ridill',
    [xi.item.KRAKEN_CLUB]         = 'your Kraken Club',
    [xi.item.JOYEUSE]             = 'your Joyeuse',
    [xi.item.MERCURIAL_KRIS]      = 'your Mercurial Kris',
    [xi.item.CHATOYANT_STAFF]     = 'your Chatoyant Staff',
    [xi.item.SCORPION_HARNESS_P1] = 'your Scorpion Harness',
}

local stock =
{
    { xi.item.G_EGG, 166666 },
    { xi.item.V_EGG, 500000 },
    { xi.item.J_EGG, 500000 },
    { xi.item.H_EGG, 250000 },
    { xi.item.M_EGG, 350000 },
    { xi.item.S_EGG, 1000000 },
    { xi.item.D_EGG, 10000000 },
}

local function findAccessoryGroup(itemId)
    for _, group in ipairs(accessoryGilExchange) do
        if group[itemId] then
            return group
        end
    end

    return nil
end

local function getItemByPosition(group, position)
    for itemId, pos in pairs(group) do
        if pos == position then
            return itemId
        end
    end

    return nil
end

local function giveAccessory(player, itemId)
    local ID = zones[xi.zone.LOWER_JEUNO]

    if not player:hasKeyItem(xi.keyItem.FAIL_BADGE) then
        player:printToPlayer('Please complete the F.A.I.L. Badge Quest.', xi.msg.channel.SAY, npcName)
        return
    end

    if player:getFreeSlotsCount() == 0 then
        player:messageSpecial(ID.text.ITEM_CANNOT_BE_OBTAINED, itemId)
        return
    end

    player:confirmTrade()
    player:addItem(itemId, 1)
    player:messageSpecial(ID.text.ITEM_OBTAINED, itemId)
end

-- Accessory + N gil picks the Nth item of that accessory's set.
local function tryGilExchange(player, trade)
    local gil = trade:getGil()
    if gil == 0 then
        return false
    end

    for slot = 0, 7 do
        local itemId = trade:getItemId(slot)
        local group  = itemId > 0 and findAccessoryGroup(itemId)
        local target = group and getItemByPosition(group, gil)

        if
            target and
            npcUtil.tradeHasExactly(trade, { itemId, { 'gil', gil } })
        then
            if target == itemId then
                player:printToPlayer('You already have this item. Trade cancelled.', xi.msg.channel.SAY, npcName)
            else
                giveAccessory(player, target)
            end

            return true
        end
    end

    return false
end

local function tryAugment(player, trade)
    for itemID, itemConfig in pairs(augments) do
        for _, eggConfig in ipairs(itemConfig.eggs) do
            if npcUtil.tradeHasExactly(trade, { itemID, eggConfig.egg }) then
                local slots = xi.eraAugments.roll(eggConfig.slots)

                player:confirmTrade()
                xi.eraAugments.giveItem(player, itemID, slots)

                player:printToPlayer(string.format('You have successfully augmented %s with %s', itemNames[itemID] or 'your item', xi.eraAugments.describe(slots)), xi.msg.channel.SYSTEM_3)
                player:printToPlayer('To examine the augment, highlight item and press minus key on numpad', xi.msg.channel.SYSTEM_3)
                return true
            end
        end
    end

    return false
end

m:addOverride('xi.zones.Lower_Jeuno.npcs.Runga-Kopunga.onTrade', function(player, npc, trade)
    if tryGilExchange(player, trade) then
        return
    end

    for inputItem, outputItem in pairs(accessoryExchange) do
        if npcUtil.tradeHasExactly(trade, inputItem) then
            giveAccessory(player, outputItem)
            return
        end
    end

    tryAugment(player, trade)
end)

m:addOverride('xi.zones.Lower_Jeuno.npcs.Runga-Kopunga.onTrigger', function(player, npc)
    player:printToPlayer('Trade Ridill & S egg for an augmented attack+ Ridill (Random chance for value)', xi.msg.channel.SAY, npcName)
    player:printToPlayer('Trade Scorpion Harness +1 & H egg for an augmented Scorpion Harness+1 (Random chance for augtype & value)', xi.msg.channel.SAY, npcName)
    player:printToPlayer('Trade Select Weapons & D egg for an augmented DMG (Random chance for value)', xi.msg.channel.SAY, npcName)
    player:printToPlayer('Trade Chatoyant Staff & M egg for augmented Magic Skills (Random chance for value)', xi.msg.channel.SAY, npcName)

    xi.shop.general(player, stock)
end)
