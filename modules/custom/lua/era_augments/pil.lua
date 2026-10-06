-----------------------------------
-- Era Augments: Pil
--   Area: Provenance
-- Desc: Trade an item and egg(s) for random augments, or the item and 50,000 gil to remove them.
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/era_augments/augments')
-----------------------------------
local m = Module:new('era_augments_pil')

xi.module.ensureTable('xi.zones.Provenance.npcs.Pil')

local removalCost = 50000

local augments =
{
    [xi.item.TOREADORS_RING] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                -- First slot
                { weight = 56, id = xi.augment.CRITICAL_HIT_RATE_P1, minValue = 0, maxValue = 1, desc = 'Crit Rate+%d' },
                { weight = 56, id = xi.augment.CRITICAL_HIT_DAMAGE_P1, minValue = 0, maxValue = 4, desc = 'Crit Dmg+%d%%' },
                { weight = 56, id = xi.augment.CRITICAL_HIT_RATE_P1, minValue = 0, maxValue = 2, desc = 'Crit Rate+%d%%' },
                { weight = 56, id = xi.augment.RNG_ATK_P1, minValue = 0, maxValue = 6, desc = 'R.Atk+%d' },
                { weight = 56, id = xi.augment.RNG_ACC_P1, minValue = 0, maxValue = 12, desc = 'R.Acc+%d' },
                { weight = 56, id = xi.augment.TRIPLE_ATTACK_P1, minValue = 0, maxValue = 1, desc = 'Triple Attack+%d%%' },
                { weight = 56, id = xi.augment.ENMITY_P1, minValue = 0, maxValue = 4, desc = 'Enmity+%d' },
                { weight = 56, id = xi.augment.ENMITY_M1, minValue = 0, maxValue = 4, desc = 'Enmity-%d' },
                { weight = 112, id = xi.augment.ACCURACY_P1, minValue = 0, maxValue = 4, desc = 'Acc+%d' },
                { weight = 112, id = xi.augment.ATTACK_P1, minValue = 0, maxValue = 4, desc = 'Attack+%d' },
                -- Stats
                { weight = 24, id = xi.augment.STR_P1, minValue = 0, maxValue = 2, desc = 'STR+%d' },
                { weight = 24, id = xi.augment.DEX_P1, minValue = 0, maxValue = 2, desc = 'DEX+%d' },
                { weight = 24, id = xi.augment.VIT_P1, minValue = 0, maxValue = 2, desc = 'VIT+%d' },
                { weight = 24, id = xi.augment.AGI_P1, minValue = 0, maxValue = 2, desc = 'AGI+%d' },
                { weight = 24, id = xi.augment.INT_P1, minValue = 0, maxValue = 2, desc = 'INT+%d' },
                { weight = 24, id = xi.augment.MND_P1, minValue = 0, maxValue = 2, desc = 'MND+%d' },
                { weight = 24, id = xi.augment.CHR_P1, minValue = 0, maxValue = 2, desc = 'CHR+%d' },
                -- Resistances
                { weight = 42, id = xi.augment.FIRE_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Fire Resist+%d' },
                { weight = 42, id = xi.augment.ICE_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Ice Resist+%d' },
                { weight = 42, id = xi.augment.WIND_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Wind Resist+%d' },
                { weight = 42, id = xi.augment.EARTH_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Earth Resist+%d' },
                { weight = 42, id = xi.augment.LIGHTNING_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Lightning Resist+%d' },
                { weight = 42, id = xi.augment.WATER_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Water Resist+%d' },
                { weight = 42, id = xi.augment.LIGHT_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Light Resist+%d' },
                { weight = 42, id = xi.augment.DARK_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Dark Resist+%d' },
            },
            {
                -- Second slot
                { weight = 56, id = xi.augment.CRITICAL_HIT_DAMAGE_P1, minValue = 0, maxValue = 4, desc = 'Crit Dmg+%d%%' },
                { weight = 56, id = xi.augment.CRITICAL_HIT_RATE_P1, minValue = 0, maxValue = 2, desc = 'Crit Rate+%d%%' },
                { weight = 56, id = xi.augment.RNG_ATK_P1, minValue = 0, maxValue = 6, desc = 'R.Atk+%d' },
                { weight = 56, id = xi.augment.RNG_ACC_P1, minValue = 0, maxValue = 12, desc = 'R.Acc+%d' },
                { weight = 56, id = xi.augment.TRIPLE_ATTACK_P1, minValue = 0, maxValue = 1, desc = 'Triple Attack+%d%%' },
                { weight = 56, id = xi.augment.ENMITY_P1, minValue = 0, maxValue = 4, desc = 'Enmity+%d' },
                { weight = 56, id = xi.augment.ENMITY_M1, minValue = 0, maxValue = 4, desc = 'Enmity-%d' },
                { weight = 112, id = xi.augment.ACCURACY_P1, minValue = 0, maxValue = 4, desc = 'Acc+%d' },
                { weight = 112, id = xi.augment.ATTACK_P1, minValue = 0, maxValue = 4, desc = 'Attack+%d' },
                -- Stats
                { weight = 24, id = xi.augment.STR_P1, minValue = 0, maxValue = 2, desc = 'STR+%d' },
                { weight = 24, id = xi.augment.DEX_P1, minValue = 0, maxValue = 2, desc = 'DEX+%d' },
                { weight = 24, id = xi.augment.VIT_P1, minValue = 0, maxValue = 2, desc = 'VIT+%d' },
                { weight = 24, id = xi.augment.AGI_P1, minValue = 0, maxValue = 2, desc = 'AGI+%d' },
                { weight = 24, id = xi.augment.INT_P1, minValue = 0, maxValue = 2, desc = 'INT+%d' },
                { weight = 24, id = xi.augment.MND_P1, minValue = 0, maxValue = 2, desc = 'MND+%d' },
                { weight = 24, id = xi.augment.CHR_P1, minValue = 0, maxValue = 2, desc = 'CHR+%d' },
                -- Resistances
                { weight = 49, id = xi.augment.FIRE_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Fire Resist+%d' },
                { weight = 49, id = xi.augment.ICE_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Ice Resist+%d' },
                { weight = 49, id = xi.augment.WIND_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Wind Resist+%d' },
                { weight = 49, id = xi.augment.EARTH_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Earth Resist+%d' },
                { weight = 49, id = xi.augment.LIGHTNING_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Lightning Resist+%d' },
                { weight = 49, id = xi.augment.WATER_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Water Resist+%d' },
                { weight = 49, id = xi.augment.LIGHT_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Light Resist+%d' },
                { weight = 49, id = xi.augment.DARK_RESIST_P1, minValue = 0, maxValue = 11, desc = 'Dark Resist+%d' },
            },
        }
    },
    [xi.item.ROSE_STRAP] =
    {
        egg = { xi.item.V_EGG, xi.item.J_EGG }, -- accepts either egg
        slots =
        {
            {
                { weight = 1, id = xi.augment.STORE_TP_P1_SUBTLE_BLOW_P1, minValue = 1, maxValue = 3, desc = 'Store TP/Subtle Blow+%d' },
                { weight = 1, id = xi.augment.ACCURACY_P1, minValue = 1, maxValue = 6, desc = 'Accuracy+%d' },
                { weight = 1, id = xi.augment.ZANSHIN_P1, minValue = 0, maxValue = 0, desc = 'Zanshin+1' },
                { weight = 1, id = xi.augment.GREAT_SWORD_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Sword+%d' },
                { weight = 1, id = xi.augment.GREAT_AXE_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Axe+%d' },
                { weight = 1, id = xi.augment.SCYTHE_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Scythe+%d' },
                { weight = 1, id = xi.augment.POLEARM_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Polearm+%d' },
                { weight = 1, id = xi.augment.GREAT_KATANA_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Katana+%d' },
                { weight = 1, id = xi.augment.STAFF_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Staff+%d' },
                { weight = 1, id = xi.augment.RESIST_BLIND_P1, minValue = 3, maxValue = 9, desc = 'Resist Blind+%d' },
                { weight = 1, id = xi.augment.RESIST_PARALYZE_P1, minValue = 3, maxValue = 9, desc = 'Resist Paralyze+%d' },
            },
            {
                { weight = 1, id = xi.augment.GREAT_SWORD_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Sword+%d' },
                { weight = 1, id = xi.augment.GREAT_AXE_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Axe+%d' },
                { weight = 1, id = xi.augment.SCYTHE_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Scythe+%d' },
                { weight = 1, id = xi.augment.POLEARM_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Polearm+%d' },
                { weight = 1, id = xi.augment.GREAT_KATANA_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Great Katana+%d' },
                { weight = 1, id = xi.augment.STAFF_SKILL_P1, minValue = 1, maxValue = 3, desc = 'Staff+%d' },
                { weight = 1, id = xi.augment.RESIST_BLIND_P1, minValue = 3, maxValue = 9, desc = 'Resist Blind+%d' },
                { weight = 1, id = xi.augment.RESIST_PARALYZE_P1, minValue = 3, maxValue = 9, desc = 'Resist Paralyze+%d' },
            },
        }
    },
    [xi.item.VELOCIOUS_BELT] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.STR_P1, minValue = 0, maxValue = 2, desc = 'STR+%d' },
                { weight = 1, id = xi.augment.DEX_P1, minValue = 0, maxValue = 2, desc = 'DEX+%d' },
                { weight = 1, id = xi.augment.VIT_P1, minValue = 0, maxValue = 2, desc = 'VIT+%d' },
                { weight = 1, id = xi.augment.AGI_P1, minValue = 0, maxValue = 2, desc = 'AGI+%d' },
                { weight = 1, id = xi.augment.INT_P1, minValue = 0, maxValue = 2, desc = 'INT+%d' },
                { weight = 1, id = xi.augment.MND_P1, minValue = 0, maxValue = 2, desc = 'MND+%d' },
                { weight = 1, id = xi.augment.CHR_P1, minValue = 0, maxValue = 2, desc = 'CHR+%d' },
            },
            {
                { weight = 1, id = xi.augment.FIRE_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Fire Resist+%d' },
                { weight = 1, id = xi.augment.ICE_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Ice Resist+%d' },
                { weight = 1, id = xi.augment.WIND_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Wind Resist+%d' },
                { weight = 1, id = xi.augment.EARTH_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Earth Resist+%d' },
                { weight = 1, id = xi.augment.LIGHTNING_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Lightning Resist+%d' },
                { weight = 1, id = xi.augment.WATER_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Water Resist+%d' },
                { weight = 1, id = xi.augment.LIGHT_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Light Resist+%d' },
                { weight = 1, id = xi.augment.DARK_RESIST_P1, minValue = 9, maxValue = 29, desc = 'Dark Resist+%d' },
            },
        }
    },
    [xi.item.LOQUACIOUS_EARRING] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.MP_P33, minValue = 0, maxValue = 20, desc = 'MP+%d' },
                { weight = 1, id = xi.augment.CONSERVE_MP_P1, minValue = 4, maxValue = 9, desc = 'Conserve MP+%d' },
                { weight = 1, id = xi.augment.MAG_ACC_P1, minValue = 0, maxValue = 4, desc = 'Magic accuracy+%d' },
                { weight = 1, id = xi.augment.DARK_MAGIC_SKILL_P1, minValue = 2, maxValue = 12, desc = 'Dark Magic skill+%d' },
            },
        }
    },
    [xi.item.BRUTAL_EARRING] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.DOUBLE_ATTACK_P1, minValue = 0, maxValue = 2, desc = 'Double Attack+%d%%' },
                { weight = 2, id = xi.augment.DUAL_WIELD_P1, minValue = 0, maxValue = 2, desc = 'Dual Wield+%d' },
                { weight = 1, id = xi.augment.HASTE_P1, minValue = 0, maxValue = 0, desc = 'Haste+1%' },
            },
            {
                { weight = 1, id = xi.augment.DOUBLE_ATTACK_P1, minValue = 0, maxValue = 2, desc = 'Double Attack+%d%%' },
                { weight = 1, id = xi.augment.DUAL_WIELD_P1, minValue = 0, maxValue = 2, desc = 'Dual Wield+%d' },
                { weight = 2, id = xi.augment.HASTE_P1, minValue = 0, maxValue = 0, desc = 'Haste+1%' },
            },
        }
    },
    [xi.item.PRISM_CAPE] =
    {
        egg = { xi.item.G_EGG, 3 }, -- requires 3 G eggs
        slots =
        {
            {
                { weight = 1, id = xi.augment.FAST_CAST_P1, minValue = 0, maxValue = 2, desc = 'Fast Cast+%d%%' },
                { weight = 1, id = xi.augment.MAG_ACC_P1, minValue = 0, maxValue = 3, desc = 'Magic accuracy+%d' },
                { weight = 1, id = xi.augment.CURE_POTENCY_P1, minValue = 0, maxValue = 3, desc = 'Cure potency+%d%%' },
                { weight = 1, id = xi.augment.SPELL_INTERRUPTION_RATE_DOWN_P1, minValue = 9, maxValue = 19, desc = 'Spell interruption rate-%d%%' },
            },
        }
    },
    [xi.item.WALAHRA_TURBAN] =
    {
        egg = xi.item.J_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.STORE_TP_P1, minValue = 2, maxValue = 9, desc = 'Store TP+%d' },
                { weight = 1, id = xi.augment.HASTE_P1, minValue = 0, maxValue = 0, desc = 'Haste+1%' },
                { weight = 1, id = xi.augment.EVASION_P1, minValue = 7, maxValue = 9, desc = 'Evasion+%d' },
                { weight = 1, id = xi.augment.ENHANCING_MAGIC_SKILL_P1, minValue = 2, maxValue = 9, desc = 'Enhancing Magic+%d' },
            },
        }
    },
    [xi.item.HAUBERGEON_P1] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.SWORD_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Sword Skill+%d' },
                { weight = 1, id = xi.augment.GREAT_SWORD_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Great Sword Skill+%d' },
                { weight = 1, id = xi.augment.AXE_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Axe Skill+%d' },
                { weight = 1, id = xi.augment.GREAT_AXE_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Great Axe Skill+%d' },
                { weight = 1, id = xi.augment.SCYTHE_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Scythe Skill+%d' },
                { weight = 1, id = xi.augment.POLEARM_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Polearm Skill+%d' },
                { weight = 1, id = xi.augment.KATANA_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Katana Skill+%d' },
                { weight = 1, id = xi.augment.GREAT_KATANA_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Great Katana Skill+%d' },
                { weight = 1, id = xi.augment.CLUB_SKILL_P1, minValue = 2, maxValue = 7, desc = 'Club Skill+%d' },
            },
            {
                { weight = 1, id = xi.augment.DEF_P1, minValue = 0, maxValue = 31, desc = 'DEF+%d' },
            }
        }
    },
    [xi.item.BIBIKI_SEASHELL] =
    {
        egg = xi.item.V_EGG,
        slots =
        {
            {
                { weight = 1, id = xi.augment.HP_RECOVERED_WHILE_HEALING_P1, minValue = 0, maxValue = 4, desc = 'HP+%d while healing' },
            },
            {
                { weight = 1, id = xi.augment.MP_RECOVERED_WHILE_HEALING_P1, mirrorSlotValue = 1, desc = 'MP+%d while healing' },
            },
            {
                { weight = 1, id = xi.augment.SPELL_INTERRUPTION_RATE_DOWN_P1, minValue = 0, maxValue = 2, desc = 'Spell interruption rate-%d%%' },
                { weight = 1, id = xi.augment.PHYS_DMG_TAKEN_M1, minValue = 0, maxValue = 2, desc = 'Phys dmg taken-%d%%' },
                { weight = 1, id = xi.augment.MAGIC_DMG_TAKEN_M1, minValue = 0, maxValue = 2, desc = 'Magic dmg taken-%d%%' },
                { weight = 1, id = xi.augment.BREATH_DMG_TAKEN_M1, minValue = 0, maxValue = 2, desc = 'Breath dmg taken-%d%%' },
            },
        }
    },
}

local itemNames =
{
    [xi.item.TOREADORS_RING]     = 'your Toreador\'s Ring',
    [xi.item.ROSE_STRAP]         = 'your Rose Strap',
    [xi.item.VELOCIOUS_BELT]     = 'your Velocious Belt',
    [xi.item.LOQUACIOUS_EARRING] = 'your Loquacious Earring',
    [xi.item.BRUTAL_EARRING]     = 'your Brutal Earring',
    [xi.item.PRISM_CAPE]         = 'your Prism Cape',
    [xi.item.WALAHRA_TURBAN]     = 'your Wal-Mart Turban',
    [xi.item.HAUBERGEON_P1]      = 'your Hauby',
    [xi.item.BIBIKI_SEASHELL]    = 'your Bibiki Seashell',
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

-- egg is one item, a list of alternatives, or { itemId, quantity }
local function tradeMatchesEgg(trade, itemID, egg)
    if type(egg) ~= 'table' then
        return npcUtil.tradeHasExactly(trade, { itemID, egg })
    end

    if type(egg[1]) == 'number' and type(egg[2]) == 'number' and egg[2] < 10 then
        return npcUtil.tradeHasExactly(trade, { itemID, { egg[1], egg[2] } })
    end

    for _, eggType in ipairs(egg) do
        if npcUtil.tradeHasExactly(trade, { itemID, eggType }) then
            return true
        end
    end

    return false
end

m:addOverride('xi.zones.Provenance.npcs.Pil.onTrade', function(player, npc, trade)
    for itemID, _ in pairs(itemNames) do
        if npcUtil.tradeHasExactly(trade, { itemID, { 'gil', removalCost } }) then
            player:confirmTrade()
            npcUtil.giveItem(player, itemID)
            return
        end
    end

    for itemID, entry in pairs(augments) do
        if tradeMatchesEgg(trade, itemID, entry.egg) then
            local slots = xi.eraAugments.roll(entry.slots)

            player:confirmTrade()
            xi.eraAugments.giveItem(player, itemID, slots)

            player:printToPlayer(string.format('You have successfully augmented %s with %s', itemNames[itemID] or 'your item', xi.eraAugments.describe(slots)), xi.msg.channel.SYSTEM_3)
            player:printToPlayer('To examine the augment, highlight item and press minus key on numpad', xi.msg.channel.SYSTEM_3)
            return
        end
    end
end)

m:addOverride('xi.zones.Provenance.npcs.Pil.onTrigger', function(player, npc)
    player:printToPlayer('Trade Prism Cape and 3 G eggs for augments (Random chance for values)', xi.msg.channel.SAY, 'Pil')
    player:printToPlayer('Trade Loquacious earring or Velocious Belt and V egg for augments (Random chance for values)', xi.msg.channel.SAY, 'Pil')
    player:printToPlayer('Trade Walahra Turban or Rose Strap and J egg for augments (Random chance for values)', xi.msg.channel.SAY, 'Pil')
    player:printToPlayer('To remove an augment, trade me the item and 50,000 gil.', xi.msg.channel.SAY, 'Pil')

    xi.shop.general(player, stock)
end)
