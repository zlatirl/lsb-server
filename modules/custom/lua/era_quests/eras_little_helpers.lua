-----------------------------------
-- Era's Little Helpers
-- Winning a mission fight you aren't progressing (helping someone else) gives EXP, Cruor
-- and a help point. Tewo Rutuminpa in Upper Jeuno hands out gear as help points add up.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_little_helpers')

xi.littleHelpers = xi.littleHelpers or {}

local helpVar = 'ErasLittleHelpers'

local small = { exp = 500, cruor = 1000 }
local large = { exp = 1500, cruor = 2000 }

local function onCurrentStep(content, player)
    return content:entryRequirement(player, nil, true)
end

local function onMission(content, player)
    return player:getCurrentMission(content.missionArea or player:getNation()) == content.mission
end

-- Each fight's check returns true for players progressing their own mission there; everyone else is helping.
local battlefields =
{
    [xi.battlefield.id.RANK_2_MISSION]                      = { reward = small, isProgressing = onCurrentStep },
    [xi.battlefield.id.RANK_2_MISSION_1]                    = { reward = small, isProgressing = onCurrentStep },
    [xi.battlefield.id.RANK_2_MISSION_2]                    = { reward = small, isProgressing = onCurrentStep },
    [xi.battlefield.id.SHADOW_LORD_BATTLE]                  = { reward = small, isProgressing = onMission },
    [xi.battlefield.id.ANCIENT_VOWS]                        = { reward = large, isProgressing = onMission },
    [xi.battlefield.id.SAVAGE]                              = { reward = large, isProgressing = onMission },
    [xi.battlefield.id.ANCIENT_FLAMES_BECKON_SPIRE_OF_DEM]   = { reward = large, isProgressing = onCurrentStep },
    [xi.battlefield.id.ANCIENT_FLAMES_BECKON_SPIRE_OF_HOLLA] = { reward = large, isProgressing = onCurrentStep },
    [xi.battlefield.id.ANCIENT_FLAMES_BECKON_SPIRE_OF_MEA]   = { reward = large, isProgressing = onCurrentStep },
    [xi.battlefield.id.DESIRES_OF_EMPTINESS]                = { reward = large, isProgressing = onMission },
    [xi.battlefield.id.DARKNESS_NAMED]                      = { reward = large, isProgressing = onMission },
    [xi.battlefield.id.RANK_5_MISSION]                      =
    {
        reward = small,
        isProgressing = function(content, player)
            return player:hasKeyItem(xi.keyItem.NEW_FEIYIN_SEAL)
        end,
    },
}

local tewoRewards =
{
    { helps = 5,  item = xi.item.KUPOFRIEDS_RING },
    { helps = 10, item = xi.item.SPELUNKERS_HELM },
    { helps = 14, item = xi.item.ALLIED_RING },
    { helps = 16, item = xi.item.EYEPATCH },
    { helps = 18, item = xi.item.CLUB_HAMMER },
    { helps = 20, item = xi.item.NOBLE_POULAINES },
}

xi.littleHelpers.reward = function(player, reward)
    if reward.exp then
        player:addExp(reward.exp)
    end

    player:addCurrency('cruor', reward.cruor)
    player:incrementCharVar(helpVar, 1)
    player:printToPlayer('For helping your fellow players, here\'s some extra cruor!', xi.msg.channel.SAY, 'Era Staff')
end

-- Progress is checked before super so the fight's own win handler hasn't advanced the mission yet.
m:addOverride('Battlefield.onBattlefieldLeave', function(self, player, battlefield, leavecode)
    local helper = battlefields[self.battlefieldId]
    local isHelping = leavecode == xi.battlefield.leaveCode.WON and
        helper ~= nil and
        not helper.isProgressing(self, player)

    super(self, player, battlefield, leavecode)

    if isHelping then
        xi.littleHelpers.reward(player, helper.reward)
    end
end)

m:addOverride('xi.zones.The_Ashu_Talif.instances.the_black_coffin.onInstanceComplete', function(instance)
    local helpers = {}
    for _, player in pairs(instance:getChars()) do
        if
            player:getCurrentMission(xi.mission.log_id.TOAU) ~= xi.mission.id.toau.THE_BLACK_COFFIN or
            player:getMissionStatus(xi.mission.log_id.TOAU) ~= 1
        then
            table.insert(helpers, player)
        end
    end

    super(instance)

    for _, player in ipairs(helpers) do
        xi.littleHelpers.reward(player, { exp = 1000, cruor = 2000 })
    end
end)

m:addOverride('xi.zones.Nyzul_Isle.instances.nashmeiras_plea.onInstanceComplete', function(instance)
    for _, player in pairs(instance:getChars()) do
        if
            player:getCurrentMission(xi.mission.log_id.TOAU) ~= xi.mission.id.toau.NASHMEIRAS_PLEA or
            player:getMissionStatus(xi.mission.log_id.TOAU) ~= 1
        then
            xi.littleHelpers.reward(player, { exp = 1000, cruor = 2000 })
        end
    end

    super(instance)
end)

-- Minotaur (CoP Distant Beliefs) is an open-world kill, so it counts once per login.
m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    if
        mob:getZoneID() == xi.zone.PHOMIUNA_AQUEDUCTS and
        mob:getName() == 'Minotaur' and
        player:getCurrentMission(xi.mission.log_id.COP) ~= xi.mission.id.cop.DISTANT_BELIEFS and
        player:getLocalVar('[LittleHelpers]Minotaur') == 0
    then
        player:setLocalVar('[LittleHelpers]Minotaur', 1)
        xi.littleHelpers.reward(player, { cruor = 1000 })
    end
end)

xi.module.ensureTable('xi.zones.Upper_Jeuno.npcs.Tewo_Rutuminpa')

m:addOverride('xi.zones.Upper_Jeuno.npcs.Tewo_Rutuminpa.onTrigger', function(player, npc)
    local helps = player:getCharVar(helpVar)

    for _, reward in ipairs(tewoRewards) do
        if helps >= reward.helps and not player:hasItem(reward.item) then
            player:printToPlayer('Some fellow adventurers of yours left this here for you and said thanks for helping.', xi.msg.channel.SAY, 'Tewo')
            npcUtil.giveItem(player, reward.item)
            return
        end
    end

    if helps > tewoRewards[#tewoRewards].helps then
        player:printToPlayer('Dang, you\'re a superstar helper. I\'ve got nothing left for you now.', xi.msg.channel.SAY, 'Tewo')
    elseif helps >= 1 then
        player:printToPlayer('I see you\'re a pretty helpful kind of person. Come back to me after you help out a bit more.', xi.msg.channel.SAY, 'Tewo')
    else
        player:startEvent(111)
    end
end)

return m
