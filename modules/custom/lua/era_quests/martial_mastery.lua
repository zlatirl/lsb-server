-----------------------------------
-- Era Martial Mastery
-- Spend 3 merits at Maat for Heart of the Bushin, kill 3 of the listed NMs,
-- then trade Maat a weapon to learn that skill's former donation weaponskill.
-- Players who donated on era trade any weapon to learn what they donated for.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_martial_mastery')

local ruLudeID = zones[xi.zone.RULUDE_GARDENS]

xi.martialMastery = xi.martialMastery or {}

local requiredKills = 3
local meritCost     = 3

local events =
{
    START  = 10196,
    FINISH = 10198,
}

-- donationVar is the charVar era's donation system set; several names are the
-- original donation weaponskill, which was later swapped for the one listed.
local weaponSkills =
{
    [xi.skill.HAND_TO_HAND] = { skillName = 'Hand-to-Hand', wsName = 'Shijin Spiral', unlock = xi.wsUnlock.SHIJIN_SPIRAL, donationVar = 'wsvictorysmite'     },
    [xi.skill.DAGGER]       = { skillName = 'Dagger',       wsName = 'Exenterator',   unlock = xi.wsUnlock.EXENTERATOR,   donationVar = 'wsexenterator'      },
    [xi.skill.SWORD]        = { skillName = 'Sword',        wsName = 'Requiescat',    unlock = xi.wsUnlock.REQUIESCAT,    donationVar = 'wsrequiescat'       },
    [xi.skill.GREAT_SWORD]  = { skillName = 'Great Sword',  wsName = 'Resolution',    unlock = xi.wsUnlock.RESOLUTION,    donationVar = 'wsresolution'       },
    [xi.skill.AXE]          = { skillName = 'Axe',          wsName = 'Ruinator',      unlock = xi.wsUnlock.RUINATOR,      donationVar = 'wscloudsplitter'    },
    [xi.skill.GREAT_AXE]    = { skillName = 'Great Axe',    wsName = 'Upheaval',      unlock = xi.wsUnlock.UPHEAVAL,      donationVar = 'wsupheaval'         },
    [xi.skill.SCYTHE]       = { skillName = 'Scythe',       wsName = 'Entropy',       unlock = xi.wsUnlock.ENTROPY,       donationVar = 'wsentropy'          },
    [xi.skill.POLEARM]      = { skillName = 'Polearm',      wsName = 'Stardiver',     unlock = xi.wsUnlock.STARDIVER,     donationVar = 'wsstardiver'        },
    [xi.skill.KATANA]       = { skillName = 'Katana',       wsName = 'Blade: Shun',   unlock = xi.wsUnlock.BLADE_SHUN,    donationVar = 'wsbladeshun'        },
    [xi.skill.GREAT_KATANA] = { skillName = 'Great Katana', wsName = 'Tachi: Shoha',  unlock = xi.wsUnlock.TACHI_SHOHA,   donationVar = 'wstachishoha'       },
    [xi.skill.CLUB]         = { skillName = 'Club',         wsName = 'Realmrazer',    unlock = xi.wsUnlock.REALMRAZER,    donationVar = 'wsrealmrazer'       },
    [xi.skill.STAFF]        = { skillName = 'Staff',        wsName = 'Shattersoul',   unlock = xi.wsUnlock.SHATTERSOUL,   donationVar = 'wsmyrkr'            },
    [xi.skill.ARCHERY]      = { skillName = 'Archery',      wsName = 'Apex Arrow',    unlock = xi.wsUnlock.APEX_ARROW,    donationVar = 'wsjishnusradiance'  },
    [xi.skill.MARKSMANSHIP] = { skillName = 'Marksmanship', wsName = 'Last Stand',    unlock = xi.wsUnlock.LAST_STAND,    donationVar = 'wslaststand'        },
}

local qualifyingKills =
{
    [xi.zone.ALTAIEU]                = { 'Absolute_Virtue' },
    [xi.zone.ARRAPAGO_REEF]          = { 'Medusa' },
    [xi.zone.ATTOHWA_CHASM]          = { 'Tiamat' },
    [xi.zone.AYDEEWA_SUBTERRANE]     = { 'Pandemonium_Warden' },
    [xi.zone.BATALLIA_DOWNS_S]       = { 'Dark_Ixion' },
    [xi.zone.BEHEMOTHS_DOMINION]     = { 'Behemoth', 'King_Behemoth' },
    [xi.zone.CAEDARVA_MIRE]          = { 'Khimaira', 'Tyger' },
    [xi.zone.DRAGONS_AERY]           = { 'Fafnir', 'Nidhogg' },
    [xi.zone.EAST_RONFAURE_S]        = { 'Dark_Ixion' },
    [xi.zone.EVERBLOOM_HOLLOW]       = { 'King_Arthro', 'Lambton_Worm' },
    [xi.zone.FORT_KARUGO_NARUGO_S]   = { 'Dark_Ixion' },
    [xi.zone.GHOYUS_REVERIE]         = { 'Lambton_Worm', 'Serket' },
    [xi.zone.GRAUBERG_S]             = { 'Dark_Ixion' },
    [xi.zone.HALVUNG]                = { 'Gurfurlur_the_Menacing' },
    [xi.zone.HAZHALM_TESTING_GROUNDS] = { 'Odin' },
    [xi.zone.JUGNER_FOREST_S]        = { 'Dark_Ixion' },
    [xi.zone.KING_RANPERRES_TOMB]    = { 'Vrtra' },
    [xi.zone.MAMOOK]                 = { 'Gulool_Ja_Ja' },
    [xi.zone.MOUNT_ZHAYOLM]          = { 'Cerberus', 'Sarameya' },
    [xi.zone.ROLANBERRY_FIELDS_S]    = { 'Dark_Ixion' },
    [xi.zone.RUHOTZ_SILVERMINES]     = { 'Guivre', 'Lambton_Worm' },
    [xi.zone.THE_SHRINE_OF_RUAVITAU] = { 'Kirin' },
    [xi.zone.ULEGUERAND_RANGE]       = { 'Jormungand' },
    [xi.zone.VALLEY_OF_SORROWS]      = { 'Adamantoise', 'Aspidochelone' },
    [xi.zone.WAJAOM_WOODLANDS]       = { 'Hydra', 'Tinnin' },
    [xi.zone.WESTERN_ALTEPA_DESERT]  = { 'King_Vinegarroon' },
}

local qualifyingLookup = {}
for zoneId, names in pairs(qualifyingKills) do
    qualifyingLookup[zoneId] = {}
    for _, name in ipairs(names) do
        qualifyingLookup[zoneId][name] = true
    end
end

local function maatSay(player, text, delay)
    if delay then
        player:timer(delay, function(playerArg)
            playerArg:printToPlayer(text, xi.msg.channel.SAY, 'Maat')
        end)
    else
        player:printToPlayer(text, xi.msg.channel.SAY, 'Maat')
    end
end

local function notify(player, text)
    player:printToPlayer(text, xi.msg.channel.NS_SHOUT)
end

local function notifyKills(player)
    notify(player, string.format('You have %i of %i kills required to learn your next weaponskill.', player:getCharVar('HeartOfTheBushin'), requiredKills))
end

local function hasDonated(player)
    if player:getCharVar('wspack') ~= 0 then
        return true
    end

    for _, ws in pairs(weaponSkills) do
        if player:getCharVar(ws.donationVar) > 0 then
            return true
        end
    end

    return false
end

local function hasLearnedAll(player)
    for _, ws in pairs(weaponSkills) do
        if not player:hasLearnedWeaponskill(ws.unlock) then
            return false
        end
    end

    return true
end

local function learn(player, ws)
    player:addLearnedWeaponskill(ws.unlock)
    notify(player, string.format('You learn %s!', ws.wsName))
end

local function removeHeart(player)
    player:delKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN)
    player:messageSpecial(ruLudeID.text.KEYITEM_LOST, xi.keyItem.HEART_OF_THE_BUSHIN)
end

local function giveInstructions(player)
    player:timer(500, function(playerArg)
        notify(playerArg, string.format('You spend %i Merits. Era Custom Martial Mastery Quest Activated!', meritCost))
    end)
    maatSay(player, 'Prove that you are ready for true martial mastery and seek out combat with the most vicious Notorious Monsters throughout Vana\'diel.', 1000)
    maatSay(player, 'Once you have slain three or more, return to me and trade the weapon for which you wish to learn a new skill.', 2000)
    maatSay(player, 'Don\'t worry youngin\', I won\'t keep your weapon... I don\'t need it.', 4000)
    player:timer(4500, function(playerArg)
        playerArg:printToPlayer('cracks his knuckles and grins roguishly.', xi.msg.channel.EMOTION, 'Maat')
    end)
end

-- The first trade of a weapon type only names the weaponskill; trading the same type again confirms it.
local function confirmChoice(player, skillType)
    if player:getLocalVar('MartialMasteryChoice') == skillType then
        return true
    end

    local ws = weaponSkills[skillType]
    maatSay(player, string.format('So you want to learn a new %s skill, huh kid? Yeah, I suppose you might be ready...', ws.skillName))
    maatSay(player, string.format('Here, hand me that weapon again and I\'ll show you a little trick. I call it %s, but don\'t blink \'cause I\'ll only do it once!', ws.wsName), 2000)
    maatSay(player, 'Now, I know you youngin\'s are indecisive, so hand me a different weapon if you\'ve already changed your mind.', 4000)
    player:setLocalVar('MartialMasteryChoice', skillType)

    return false
end

local function startQuest(player)
    if player:getCharVar('MartialMasteryCS') == 0 then
        if hasDonated(player) or player:getMeritCount() >= meritCost then
            player:startEvent(events.START)
        else
            notify(player, string.format('You must spend %i Merit Points to activate Era\'s Custom Martial Mastery Quest.', meritCost))
        end

        return
    end

    if player:getMeritCount() < meritCost then
        notify(player, string.format('You must spend %i Merit Points to activate Era\'s Custom Martial Mastery Quest.', meritCost))
        return
    end

    player:setMerits(player:getMeritCount() - meritCost)
    player:addKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN)
    player:messageSpecial(ruLudeID.text.KEYITEM_OBTAINED, xi.keyItem.HEART_OF_THE_BUSHIN)
    giveInstructions(player)
end

local function finishQuest(player, skillType)
    local ws = weaponSkills[skillType]

    if player:getCharVar('MartialMasteryCS') == 1 then
        if hasDonated(player) then
            player:startEvent(events.FINISH)
        elseif player:getCharVar('HeartOfTheBushin') < requiredKills then
            notifyKills(player)
        elseif confirmChoice(player, skillType) then
            player:startEvent(events.FINISH)
        end

        return
    end

    if player:getCharVar('HeartOfTheBushin') < requiredKills then
        notifyKills(player)
        return
    end

    if player:hasLearnedWeaponskill(ws.unlock) then
        maatSay(player, string.format('I\'ve already shown you %s once and I ain\'t gonna do it again, kid. Try a different weapon.', ws.wsName))
        player:setLocalVar('MartialMasteryChoice', 0)
        return
    end

    if not confirmChoice(player, skillType) then
        return
    end

    learn(player, ws)
    removeHeart(player)
    player:setCharVar('HeartOfTheBushin', 0)
end

local function onWeaponTrade(player, weapon)
    if hasLearnedAll(player) then
        maatSay(player, 'Nice try, youngin\'!')
        return
    end

    local skillType = weapon:getSkillType()
    if not weaponSkills[skillType] then
        maatSay(player, 'I ain\'t got any tricks for that one, kid.')
        return
    end

    if player:hasKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN) then
        finishQuest(player, skillType)
    else
        startQuest(player)
    end
end

local function onStartFinish(player)
    player:addKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN)
    player:messageSpecial(ruLudeID.text.KEYITEM_OBTAINED, xi.keyItem.HEART_OF_THE_BUSHIN)
    player:setCharVar('MartialMasteryCS', 1)

    if hasDonated(player) then
        notify(player, 'Previous donation unlocks detected. Trade any weapon to learn your weaponskills!')
    else
        player:setMerits(player:getMeritCount() - meritCost)
        giveInstructions(player)
    end
end

local function onFinishFinish(player)
    if player:getCharVar('wspack') ~= 0 then
        for _, ws in pairs(weaponSkills) do
            learn(player, ws)
            player:setCharVar(ws.donationVar, 0)
        end

        player:setCharVar('wspack', 0)
    elseif hasDonated(player) then
        for _, ws in pairs(weaponSkills) do
            if player:getCharVar(ws.donationVar) ~= 0 then
                learn(player, ws)
                player:setCharVar(ws.donationVar, 0)
            end
        end
    else
        local ws = weaponSkills[player:getLocalVar('MartialMasteryChoice')]
        if not ws then
            return
        end

        learn(player, ws)
        player:setCharVar('HeartOfTheBushin', 0)
    end

    removeHeart(player)
    player:setCharVar('MartialMasteryCS', 2)

    if hasLearnedAll(player) then
        player:setCharVar('MartialMasteryCS', 0)
        notify(player, 'Congratulations! You have learned all of the Martial Mastery Weaponskills!')
        notify(player, 'You have been awarded 5000 Cruor!')
        player:addExp(12500)
        player:addCurrency('cruor', 5000)
    end
end

xi.martialMastery.onMobDeath = function(mob, player)
    local zoneKills = qualifyingLookup[mob:getZoneID()]
    if
        not zoneKills or
        not zoneKills[mob:getName()] or
        not player:hasKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN)
    then
        return
    end

    player:incrementCharVar('HeartOfTheBushin', 1)
    notify(player, 'Martial Mastery progress recorded!')
    notifyKills(player)
end

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    xi.martialMastery.onMobDeath(mob, player)
end)

m:addOverride('xi.zones.RuLude_Gardens.npcs.Maat.onTrade', function(player, npc, trade)
    super(player, npc, trade)

    if player:isInEvent() then
        return
    end

    local weapon = trade:getItem(0)
    if
        trade:getItemCount() == 1 and
        weapon and
        weapon:isType(xi.itemType.WEAPON)
    then
        onWeaponTrade(player, weapon)
    end
end)

m:addOverride('xi.zones.RuLude_Gardens.npcs.Maat.onTrigger', function(player, npc)
    super(player, npc)

    if player:isInEvent() then
        return
    end

    if hasDonated(player) then
        notify(player, 'Previous Martial Mastery unlocks from donations detected! Trade any weapon to learn your weaponskills!')
    elseif player:hasKeyItem(xi.keyItem.HEART_OF_THE_BUSHIN) then
        notifyKills(player)
    elseif not hasLearnedAll(player) then
        notify(player, 'Trade any weapon to Maat to begin Era\'s Custom Martial Mastery Quest!')
        player:timer(1000, function(playerArg)
            notify(playerArg, string.format('Activating Custom Martial Mastery Quest will cost %i Merits.', meritCost))
        end)
    end
end)

m:addOverride('xi.zones.RuLude_Gardens.npcs.Maat.onEventFinish', function(player, csid, option, npc)
    super(player, csid, option, npc)

    if csid == events.START then
        onStartFinish(player)
    elseif csid == events.FINISH then
        onFinishFinish(player)
    end
end)

return m
