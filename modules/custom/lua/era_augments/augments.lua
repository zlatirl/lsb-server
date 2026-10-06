-----------------------------------
-- Era Augments
-----------------------------------
xi = xi or {}
xi.eraAugments = xi.eraAugments or {}

-- Rolls one augment per slot. Each slot is a weighted list of
-- { weight, id, minValue, maxValue, desc } entries, which may instead copy an
-- earlier slot's augment (mirrorSlotID) or value (mirrorSlotValue).
xi.eraAugments.roll = function(slotTables)
    local slots = {}

    for slotIndex, slot in ipairs(slotTables) do
        local totalWeight = 0
        for _, augment in ipairs(slot) do
            totalWeight = totalWeight + augment.weight
        end

        local roll = math.randomInt(1, totalWeight)

        for _, augment in ipairs(slot) do
            if roll <= augment.weight then
                local rolled = { id = augment.id, value = 0, desc = augment.desc }

                if augment.mirrorSlotID then
                    rolled.id = slots[augment.mirrorSlotID].id
                end

                if augment.mirrorSlotValue then
                    rolled.value = slots[augment.mirrorSlotValue].value
                elseif
                    augment.maxValue and
                    augment.minValue and
                    augment.maxValue > augment.minValue
                then
                    rolled.value = math.randomInt(augment.minValue, augment.maxValue)
                elseif augment.maxValue then
                    rolled.value = augment.maxValue
                end

                slots[slotIndex] = rolled
                break
            end

            roll = roll - augment.weight
        end
    end

    return slots
end

-- Augment values are stored one below the displayed bonus.
xi.eraAugments.describe = function(slots)
    local descriptions = {}

    for _, slot in ipairs(slots) do
        if slot.desc then
            table.insert(descriptions, slot.desc:find('%%d') and string.format(slot.desc, slot.value + 1) or slot.desc)
        end
    end

    return #descriptions > 0 and table.concat(descriptions, ' and ') or 'an augment'
end

xi.eraAugments.giveItem = function(player, itemId, slots)
    local augments = {}
    for _, slot in ipairs(slots) do
        table.insert(augments, { id = slot.id, value = slot.value })
    end

    return player:addItem({
        id     = itemId,
        exdata =
        {
            augmentKind    = xi.augment.kind.HAS_AUGMENTS,
            augmentSubKind = xi.augment.subKind.STANDARD,
            augments       = augments,
        },
    })
end
