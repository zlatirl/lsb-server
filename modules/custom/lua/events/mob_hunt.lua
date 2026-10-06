-----------------------------------
-- Module: Era Mob Hunt event
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_mob_hunt')

xi.eraEvents.mobHunt = xi.eraEvents.mobHunt or {}
local mobHunt = xi.eraEvents.mobHunt

local event = xi.eraEvents.ScheduledEvent:new('mobHunt')

local logPath = 'log/mobHunt_audit.log'

local huntZones =
{
    xi.zone.EAST_RONFAURE,     xi.zone.WEST_RONFAURE,       xi.zone.LA_THEINE_PLATEAU,   xi.zone.JUGNER_FOREST,         xi.zone.BATALLIA_DOWNS,
    xi.zone.SOUTH_GUSTABERG,   xi.zone.NORTH_GUSTABERG,     xi.zone.KONSCHTAT_HIGHLANDS, xi.zone.PASHHOW_MARSHLANDS,    xi.zone.ROLANBERRY_FIELDS,
    xi.zone.WEST_SARUTABARUTA, xi.zone.EAST_SARUTABARUTA,   xi.zone.TAHRONGI_CANYON,     xi.zone.MERIPHATAUD_MOUNTAINS, xi.zone.SAUROMUGUE_CHAMPAIGN,
    xi.zone.VALKURM_DUNES,     xi.zone.BUBURIMU_PENINSULA,  xi.zone.QUFIM_ISLAND,
}

local hintChance         = 0.33
local confrontationPower = 2025 -- Identifies the Mob Hunt Confrontation effect
local targetLevel        = 40
local restrictionLevel   = 30
local maxRespawnInterval = 600
local spotRange          = 20
local rewardRange        = 50
local announceRange      = 100
local rageDelay          = 10 * 60

local targetMobMods =
{
    CHECK_AS_NM  = 1,
    ALWAYS_AGGRO = 1,
    DETECTION    = xi.detects.HEARING,
    SOUND_RANGE  = spotRange,
    NO_LINK      = 1,
    CLAIM_TYPE   = xi.claimType.UNCLAIMABLE,
    NO_DESPAWN   = 1,
}

local rageStages =
{
    { delay =   0, enrage = true, message = 'The hunt target is starting to get angry...' },
    { delay =  75, enrage = true, message = 'The hunt target is angry...' },
    { delay = 150, enrage = true, message = 'The hunt target is becoming furious...' },
    { delay = 225, enrage = true, message = 'The hunt target is enraging...' },
    { delay = 300, enrage = true, message = 'The hunt target is apoplectic with rage!' },
    { delay = 600, message = 'The hunt target is getting bored...' },
    { delay = 675, message = 'The hunt target is thinking about leaving...' },
    { delay = 750, message = 'The hunt target is going to leave soon...' },
    { delay = 825, message = 'The hunt target is about to slip away...' },
    { delay = 900, message = 'The hunt target got away!', escape = true },
}

local rewards =
{
    { weight = 40, gil = { 1000, 5000 } },
    { weight = 30, cruor = { 100, 500 } },
    { weight =  3, item = xi.item.GARRISON_TUNICA },
    { weight =  3, item = xi.item.GARRISON_BOOTS },
    { weight =  3, item = xi.item.GARRISON_HOSE },
    { weight =  3, item = xi.item.GARRISON_GLOVES },
    { weight =  3, item = xi.item.GARRISON_SALLET },
}

local function writeLog(fmt, ...)
    local logFile = io.open(logPath, 'a')
    if logFile then
        logFile:write(string.format('[%s] ' .. fmt .. '\n', os.date(), ...))
        logFile:close()
    end
end

local function getPlayersNear(mob, range)
    local players = {}
    local zone    = mob:getZone()

    if not zone then
        return players
    end

    for _, player in ipairs(zone:getPlayers()) do
        if player:checkDistance(mob) < range then
            table.insert(players, player)
        end
    end

    return players
end

local function announce(mob, message)
    for _, player in ipairs(getPlayersNear(mob, announceRange)) do
        player:printToPlayer(message, xi.msg.channel.NS_SHOUT)
    end
end

local function getHuntTarget()
    local huntTargetID = GetServerVariable('[MobHunt]Target')

    if huntTargetID == 0 then
        return nil
    end

    return GetMobByID(huntTargetID)
end

local function isMobHuntParticipant(player)
    return player:getConfrontationEffect() == confrontationPower
end

mobHunt.getIsActive = function()
    return event:getIsActive()
end

mobHunt.isHuntTargetActive = function()
    local huntTarget = getHuntTarget()

    return huntTarget ~= nil and
        huntTarget:isAlive() and
        huntTarget:getLocalVar('[MobHunt]isTarget') > 0
end

local function isValidHuntTarget(mob)
    if not mob or not mob:isAlive() then
        return false
    end

    local enmityList = mob:getEnmityList() or {}

    return mob:getSpawnType() == xi.spawnType.NORMAL and
        not mob:isNM() and
        mob:getRespawnInterval() < maxRespawnInterval and
        #enmityList == 0
end

-- The first 1024 (0x400) IDs in a zone are reserved for mobs.
local function getZoneMobID(zoneID, index)
    return bit.lshift(0x1000 + zoneID, 12) + index
end

local function findHuntTargetInZone(zoneID)
    for _ = 1, 32 do
        local mob = GetMobByID(getZoneMobID(zoneID, math.randomInt(0, 0x3FF)))

        if isValidHuntTarget(mob) then
            return mob
        end
    end

    for index = 0, 0x3FF do
        local mob = GetMobByID(getZoneMobID(zoneID, index))

        if isValidHuntTarget(mob) then
            return mob
        end
    end

    return nil
end

mobHunt.activateNewHuntTarget = function()
    local previousHuntTarget = getHuntTarget()
    local previousZoneID     = previousHuntTarget and previousHuntTarget:getZoneID() or 0

    for _ = 1, 10 do
        local huntZoneID = huntZones[math.randomInt(1, #huntZones)]

        if huntZoneID ~= previousZoneID then
            local huntTarget = findHuntTargetInZone(huntZoneID)

            if huntTarget then
                mobHunt.setHuntTarget(huntTarget)
                return
            end

            printf('[MobHunt] Could not find a valid hunt target in zone %d.', huntZoneID)
        end
    end

    print('[MobHunt] Failed to activate a new hunt target.')
end

local function onTargetDrawIn(mob)
    local target = mob:getTarget()

    if target then
        utils.drawIn(target, {
            conditions = { mob:checkDistance(target) >= mob:getMeleeRange(target) * 2 },
            position   = mob:getPos(),
        })
    end
end

local function updateParticipants(mob)
    for _, entry in ipairs(mob:getEnmityList() or {}) do
        local participant = entry.entity:getMaster() or entry.entity

        if participant:isPC() and participant:getLocalVar('[MobHunt]Participated') == 0 then
            participant:setLocalVar('[MobHunt]Participated', 1)

            -- The target gets 10% more HP for every participant past the sixth.
            local participantCount = mob:getLocalVar('[MobHunt]ParticipantCount') + 1
            mob:setLocalVar('[MobHunt]ParticipantCount', participantCount)

            if participantCount > 6 and mob:isAlive() then
                mob:addMod(xi.mod.HPP, 10)
                mob:updateHealth()
                mob:addHP(mob:getBaseHP() * 0.1)
            end

            mobHunt.join(participant)
        end
    end
end

local function checkNearbyPlayers(mob, time)
    for _, player in ipairs(getPlayersNear(mob, spotRange)) do
        if
            isMobHuntParticipant(player) and
            player:isDead() and
            time >= player:getLocalVar('[MobHunt]NextRaise')
        then
            player:setLocalVar('[MobHunt]NextRaise', time + 5)
            player:timer(3000, function(playerArg)
                playerArg:sendRaise(3)
            end)
        end

        if not isMobHuntParticipant(player) and player:isAlive() and mob:isAlive() then
            mobHunt.join(player)
            player:addStatusEffect(xi.effect.STUN, { power = 1, duration = 3, origin = mob })
            player:printToPlayer('The hunt target spotted you!', xi.msg.channel.SYSTEM_3)
        end

        if mob:getLocalVar('[MobHunt]Discovered') == 0 then
            mob:setLocalVar('[MobHunt]Discovered', 1)
            mob:setLocalVar('[MobHunt]RageTime', time + rageDelay)
            announce(mob, string.format('%s has discovered the hunt target! Let the battle commence...', player:getName()))
        end
    end
end

local function updateRage(mob, time)
    local rageTime = mob:getLocalVar('[MobHunt]RageTime')
    local rage     = mob:getLocalVar('[MobHunt]Rage')
    local stage    = rageStages[rage + 1]

    if rageTime == 0 or not stage or time < rageTime + stage.delay then
        return
    end

    -- Rage only progresses while someone is in the zone to see it.
    local zone = mob:getZone()
    if not zone or #zone:getPlayers() == 0 then
        return
    end

    mob:setLocalVar('[MobHunt]Rage', rage + 1)

    if stage.enrage then
        mob:addMod(xi.mod.DELAYP, -10)
        mob:addMod(xi.mod.ATTP, 10)
    end

    announce(mob, stage.message)

    if stage.escape then
        mobHunt.huntTargetEscapes(mob)
    end
end

local function onTargetTick(mob)
    local time = GetSystemTime()

    updateParticipants(mob)
    checkNearbyPlayers(mob, time)
    updateRage(mob, time)
end

mobHunt.setHuntTarget = function(huntTarget)
    local previousHuntTarget = getHuntTarget()

    if previousHuntTarget and previousHuntTarget:getLocalVar('[MobHunt]isTarget') > 0 then
        mobHunt.cleanupHuntTarget(previousHuntTarget)
    end

    printf('[MobHunt] New hunt target %s (%d) in %s.', huntTarget:getName(), huntTarget:getID(), huntTarget:getZoneName())

    SetServerVariable('[MobHunt]Target', huntTarget:getID())
    huntTarget:setLocalVar('[MobHunt]isTarget', 1)
    huntTarget:setLocalVar('[MobHunt]ParticipantCount', 0)
    huntTarget:setLocalVar('[MobHunt]Discovered', 0)
    huntTarget:setLocalVar('[MobHunt]RageTime', 0)
    huntTarget:setLocalVar('[MobHunt]Rage', 0)

    huntTarget:setMobLevel(targetLevel)

    for mobModName, value in pairs(targetMobMods) do
        huntTarget:setLocalVar('[MobHunt]' .. mobModName, huntTarget:getMobMod(xi.mobMod[mobModName]))
        huntTarget:setMobMod(xi.mobMod[mobModName], value)
    end

    huntTarget:setTrueDetection(true)
    huntTarget:addStatusEffect(xi.effect.CONFRONTATION, { power = confrontationPower, origin = huntTarget })

    huntTarget:addListener('TICK', 'MOB_HUNT_TICK', onTargetTick)
    huntTarget:addListener('COMBAT_TICK', 'MOB_HUNT_DRAW_IN', onTargetDrawIn)

    -- The target is unclaimable, so the core never passes a killer to onMobDeath for it.
    huntTarget:addListener('DEATH', 'MOB_HUNT_DEATH', function(mob, killer)
        mobHunt.onHuntTargetDeath(mob, killer)
    end)
end

local function restoreHuntTarget(huntTarget)
    huntTarget:removeListener('MOB_HUNT_TICK')
    huntTarget:removeListener('MOB_HUNT_DRAW_IN')
    huntTarget:removeListener('MOB_HUNT_DEATH')
    huntTarget:delStatusEffect(xi.effect.CONFRONTATION)

    if huntTarget:getLocalVar('[MobHunt]isTarget') > 0 then
        for mobModName, _ in pairs(targetMobMods) do
            huntTarget:setMobMod(xi.mobMod[mobModName], huntTarget:getLocalVar('[MobHunt]' .. mobModName))
        end

        huntTarget:setMod(xi.mod.DELAYP, 0)
        huntTarget:setMod(xi.mod.ATTP, 0)
        huntTarget:setMod(xi.mod.HPP, 0)
        huntTarget:setLocalVar('[MobHunt]isTarget', 0)
    end

    huntTarget:setTrueDetection(false)
end

mobHunt.cleanupHuntTarget = function(huntTarget)
    if huntTarget:isAlive() then
        huntTarget:setHP(0)
    end

    restoreHuntTarget(huntTarget)
end

mobHunt.join = function(player)
    if not player:isPC() or isMobHuntParticipant(player) then
        return
    end

    player:addStatusEffect(xi.effect.CONFRONTATION, { power = confrontationPower, origin = player })
    player:levelRestriction(restrictionLevel)
end

mobHunt.quit = function(player)
    if not player:isPC() or player:getLocalVar('[MobHunt]QuitQueued') ~= 0 then
        return
    end

    -- Queued so it can't run while the player is dead; dropping the level
    -- restriction and then being raised would otherwise award XP.
    player:setLocalVar('[MobHunt]QuitQueued', 1)
    player:queue(0, function(playerArg)
        playerArg:setLocalVar('[MobHunt]QuitQueued', 0)

        if isMobHuntParticipant(playerArg) then
            playerArg:delStatusEffect(xi.effect.CONFRONTATION)
            playerArg:levelRestriction(0)
            playerArg:setLocalVar('[MobHunt]Participated', 0)
        end
    end)
end

local function pickReward()
    local totalWeight = 0
    for _, reward in ipairs(rewards) do
        totalWeight = totalWeight + reward.weight
    end

    local roll = math.randomInt(1, totalWeight)
    for _, reward in ipairs(rewards) do
        if roll <= reward.weight then
            return reward
        end

        roll = roll - reward.weight
    end
end

mobHunt.distributeRewards = function(player)
    player:incrementCharVar('LoginPoints', 1)
    player:printToPlayer('You gained 1 login point!', xi.msg.channel.NS_SAY)

    local reward = pickReward()
    local ID     = zones[player:getZoneID()]

    if reward.gil then
        local gil = math.randomInt(reward.gil[1], reward.gil[2])
        player:addGil(gil)
        player:messageSpecial(ID.text.GIL_OBTAINED, gil)
        writeLog('%s earned %d gil.', player:getName(), gil)
    elseif reward.cruor then
        local cruor = math.randomInt(reward.cruor[1], reward.cruor[2])
        player:addCurrency('cruor', cruor)
        player:printToPlayer(string.format('Obtained %d cruor.', cruor), xi.msg.channel.NS_SAY)
        writeLog('%s earned %d cruor.', player:getName(), cruor)
    elseif npcUtil.giveItem(player, reward.item) then
        writeLog('%s earned item %d.', player:getName(), reward.item)
    end
end

local function releasePlayers(mob, defeated)
    for _, player in ipairs(getPlayersNear(mob, rewardRange)) do
        if isMobHuntParticipant(player) and player:getLocalVar('[MobHunt]Participated') > 0 then
            player:setLocalVar('[MobHunt]Participated', 0)

            if defeated then
                player:printToPlayer('You defeated the Mob Hunt target!', xi.msg.channel.SYSTEM_3)
                mobHunt.distributeRewards(player)
            end
        end

        mobHunt.quit(player)
    end
end

mobHunt.onHuntTargetDeath = function(mob, killer)
    writeLog('%s was defeated by %s in %s.', mob:getName(), killer and killer:getName() or 'nobody', mob:getZoneName())

    updateParticipants(mob)
    releasePlayers(mob, true)
    restoreHuntTarget(mob)
    mobHunt.activateNewHuntTarget()
end

mobHunt.huntTargetEscapes = function(mob)
    writeLog('%s wasn\'t defeated in time and escaped from %s.', mob:getName(), mob:getZoneName())

    releasePlayers(mob, false)
    restoreHuntTarget(mob)
    DespawnMob(mob:getID())
    mobHunt.activateNewHuntTarget()
end

mobHunt.onMobDeath = function(mob, player, isKiller)
    -- Only run once per mob death.
    if not mobHunt.getIsActive() or not isKiller then
        return
    end

    if mob:getID() == GetServerVariable('[MobHunt]Target') then
        return
    end

    local zoneID = player:getZoneID()
    if
        math.randomFloat(0, 1) > hintChance or
        not utils.contains(zoneID, huntZones)
    then
        return
    end

    if not mobHunt.isHuntTargetActive() then
        mobHunt.activateNewHuntTarget()
    end

    local huntTarget = getHuntTarget()
    if not huntTarget then
        return
    end

    local huntZoneID = huntTarget:getZoneID()

    player:timer(0, function(playerArg)
        if playerArg:getLocalVar('[MobHunt]ReceivedClue') == 0 then
            playerArg:setLocalVar('[MobHunt]ReceivedClue', 1)
            writeLog('%s received a clue in %s.', playerArg:getName(), playerArg:getZoneName())
        end

        if zoneID == huntZoneID then
            playerArg:printToPlayer('You suspect the hunt target is somewhere nearby!', xi.msg.channel.SYSTEM_3)
        else
            playerArg:printToPlayer('You have a feeling the hunt target is somewhere else...', xi.msg.channel.SYSTEM_3)
        end
    end)
end

event:setEndFunction(function()
    local huntTarget = getHuntTarget()

    if huntTarget and huntTarget:getLocalVar('[MobHunt]isTarget') > 0 then
        releasePlayers(huntTarget, false)
        mobHunt.cleanupHuntTarget(huntTarget)
    end
end)

m:addOverride('xi.mob.onMobDeathEx', function(mob, player, isKiller, isWeaponSkillKill)
    super(mob, player, isKiller, isWeaponSkillKill)

    mobHunt.onMobDeath(mob, player, isKiller)
end)
