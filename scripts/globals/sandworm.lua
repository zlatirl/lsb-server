-----------------------------------
-- Area: One of many zones in Shadowreign zones
--   NM: Sandworm
-----------------------------------
xi = xi or {}
xi.sandworm = xi.sandworm or {}

xi.sandworm.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.ELEGY)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.PETRIFY)
    mob:addImmunity(xi.immunity.TERROR)
end

-----------------------------------
-- Doomvoid
-- Below 25% HP the Sandworm can Doomvoid, pulling its target's party into an instance where they
-- face either the zone's NM or a Lambton Worm.
-----------------------------------

xi.sandworm.doomvoidHpp       = 25
xi.sandworm.doomvoidChance    = 25
xi.sandworm.lambtonWormChance = 20 -- percent; reported as 10-25%

-----------------------------------
-- Spawning
-- Left unclaimed for an hour it moves straight to another zone;
-- after it dies or Doomvoids, the next one pops in another zone 20-25 hours later.
-----------------------------------

local sandworms =
{
    [xi.zone.EAST_RONFAURE_S]         = 17109357,
    [xi.zone.BATALLIA_DOWNS_S]        = 17121693,
    [xi.zone.WEST_SARUTABARUTA_S]     = 17166720,
    [xi.zone.MERIPHATAUD_MOUNTAINS_S] = 17174888,
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S]  = 17178901,
    [xi.zone.NORTH_GUSTABERG_S]       = 17138041,
    [xi.zone.ROLANBERRY_FIELDS_S]     = 17150317,
}

local function pickZone(excludeZoneId)
    local options = {}
    for zoneId, _ in pairs(sandworms) do
        if zoneId ~= excludeZoneId then
            table.insert(options, zoneId)
        end
    end

    return options[math.random(#options)]
end

local function scheduleNextSandworm(mob, delay)
    SetServerVariable('[Sandworm]Zone', pickZone(mob:getZoneID()))
    SetServerVariable('[Sandworm]Pop', GetSystemTime() + delay)
end

xi.sandworm.onMoveZone = function(mob)
    scheduleNextSandworm(mob, 0)
end

xi.sandworm.onGone = function(mob)
    scheduleNextSandworm(mob, math.random(72000, 90000))
end

xi.sandworm.onGameHour = function()
    local zoneId = GetServerVariable('[Sandworm]Zone')
    if not sandworms[zoneId] then
        zoneId = pickZone()
        SetServerVariable('[Sandworm]Zone', zoneId)
        SetServerVariable('[Sandworm]Pop', 0)
    end

    if GetSystemTime() < GetServerVariable('[Sandworm]Pop') then
        return
    end

    local mob = GetMobByID(sandworms[zoneId])
    if mob and not mob:isSpawned() then
        SpawnMob(mob:getID())
    end
end

-----------------------------------
-- Doomvoid instances
-----------------------------------

local doomvoidInstances =
{
    [xi.zone.EAST_RONFAURE_S]         = 8602,  -- Everbloom Hollow: King Arthro or Lambton Worm
    [xi.zone.BATALLIA_DOWNS_S]        = 8602,
    [xi.zone.WEST_SARUTABARUTA_S]     = 12900, -- Ghoyu's Reverie: Serket or Lambton Worm
    [xi.zone.MERIPHATAUD_MOUNTAINS_S] = 12900,
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S]  = 12900,
    [xi.zone.NORTH_GUSTABERG_S]       = 9302,  -- Ruhotz Silvermines: Guivre or Lambton Worm
    [xi.zone.ROLANBERRY_FIELDS_S]     = 9302,
}

local doomvoidMaps =
{
    [xi.zone.EVERBLOOM_HOLLOW]   = xi.keyItem.MAP_OF_EVERBLOOM_HOLLOW,
    [xi.zone.GHOYUS_REVERIE]     = xi.keyItem.MAP_OF_GHOYUS_REVERIE,
    [xi.zone.RUHOTZ_SILVERMINES] = xi.keyItem.MAP_OF_RUHOTZ_SILVERMINES,
}

local doomvoidExits =
{
    [xi.zone.EVERBLOOM_HOLLOW]   = { 180.664, -19.804, -240.211,   4, xi.zone.EAST_RONFAURE_S     },
    [xi.zone.GHOYUS_REVERIE]     = { 143.031,  -1.062, -319.190, 135, xi.zone.WEST_SARUTABARUTA_S },
    [xi.zone.RUHOTZ_SILVERMINES] = { -81.264,  -0.191,  -13.855, 188, xi.zone.NORTH_GUSTABERG_S   },
}

local lambtonArrivals =
{
    [xi.zone.EVERBLOOM_HOLLOW]   = {  -19.938, -8.750, -320.105,  65 },
    [xi.zone.GHOYUS_REVERIE]     = {  470.880,  0.318,  344.617, 164 },
    [xi.zone.RUHOTZ_SILVERMINES] = {  347.866,  0.000, -460.499, 253 },
}

local swallowEvents =
{
    [xi.zone.EAST_RONFAURE_S]         = 264,
    [xi.zone.BATALLIA_DOWNS_S]        = 203,
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S]  = 264,
    [xi.zone.WEST_SARUTABARUTA_S]     = 264,
    [xi.zone.MERIPHATAUD_MOUNTAINS_S] = 264,
    [xi.zone.NORTH_GUSTABERG_S]       = 202,
    [xi.zone.ROLANBERRY_FIELDS_S]     = 264,
}

xi.sandworm.doomvoid = function(mob, target)
    local zoneId     = mob:getZoneID()
    local instanceId = doomvoidInstances[zoneId]
    if not instanceId then
        return
    end

    local leader = target
    if not leader:isPC() and leader:getMaster() then
        leader = leader:getMaster()
    end

    if not leader:isPC() then
        return
    end

    mob:setLocalVar('doomvoidUsed', 1)
    leader:setLocalVar('[Doomvoid]worm', mob:getID())
    leader:setLocalVar('[Doomvoid]instance', instanceId)

    local swallowEvent = swallowEvents[zoneId]

    for _, member in ipairs(leader:getAlliance()) do
        if member:getZoneID() == zoneId then
            member:setCharVar('[Doomvoid]zone', zoneId, GetSystemTime() + 7200)

            if swallowEvent then
                member:startEvent(swallowEvent)
            else
                local swallowText = zones[zoneId].text.SANDWORM_SWALLOWS
                if swallowText then
                    member:messageSpecial(swallowText)
                end
            end
        end
    end

    if not swallowEvent then
        leader:createInstance(instanceId)
    end
end

xi.sandworm.onEventFinish = function(player, csid)
    if csid ~= swallowEvents[player:getZoneID()] then
        return
    end

    local instanceId = player:getLocalVar('[Doomvoid]instance')
    if instanceId ~= 0 then
        player:setLocalVar('[Doomvoid]instance', 0)
        player:createInstance(instanceId)
    end
end

xi.sandworm.onDoomvoidInstanceCreated = function(instance, nmId, lambtonWormId)
    if math.random(100) <= xi.sandworm.lambtonWormChance then
        local arrival = lambtonArrivals[instance:getZone():getID()]

        instance:setEntryPos(arrival[1], arrival[2], arrival[3], arrival[4])
        SpawnMob(lambtonWormId, instance)
    else
        SpawnMob(nmId, instance)
    end
end

xi.sandworm.onDoomvoidInstanceCreatedCallback = function(player, instance)
    local zoneId = player:getZoneID()
    local worm   = GetMobByID(player:getLocalVar('[Doomvoid]worm'))

    player:setLocalVar('[Doomvoid]worm', 0)

    for _, member in ipairs(player:getAlliance()) do
        if
            member:getZoneID() == zoneId and
            member:getCharVar('[Doomvoid]zone') == zoneId
        then
            if instance then
                member:addTempItem(xi.item.BOTTLED_FAY)
                member:setInstance(instance)
                member:setPos(0, 0, 0, 0, instance:getZone():getID())
            else
                member:setCharVar('[Doomvoid]zone', 0)
            end
        end
    end

    if worm and worm:isSpawned() then
        if instance then
            xi.sandworm.onGone(worm)
            DespawnMob(worm:getID())
        else
            worm:setLocalVar('doomvoidUsed', 0)
        end
    end
end

xi.sandworm.afterDoomvoidRegister = function(player, text)
    local map = doomvoidMaps[player:getZoneID()]
    if map and not player:hasKeyItem(map) then
        player:addKeyItem(map)
    end

    player:messageSpecial(text.TIME_TO_COMPLETE, player:getInstance():getTimeLimit() / 60)
end

xi.sandworm.exitParam =
{
    BOTTLED_FAY = 400,
    TIMEOUT     = 500,
}

xi.sandworm.isLeavingDoomvoid = function(player)
    return player:getCharVar('[Doomvoid]zone') ~= 0
end

xi.sandworm.startDoomvoidExit = function(player, param)
    if player:getCharVar('[Doomvoid]zone') == 0 then
        return false
    end

    player:startEvent(10000, { [0] = param, flags = 8 })

    return true
end

xi.sandworm.leaveDoomvoid = function(player)
    local zone = player:getCharVar('[Doomvoid]zone')
    if zone == 0 then
        return false
    end

    local map = doomvoidMaps[player:getZoneID()]
    if map then
        player:delKeyItem(map)
    end

    local exit = doomvoidExits[player:getZoneID()]
    if exit then
        player:setPos(exit[1], exit[2], exit[3], exit[4], exit[5])
    else
        local instance = player:getInstance()
        player:setPos(0, 0, 0, 0, instance and instance:getEntranceZoneID() or zone)
    end

    player:setCharVar('[Doomvoid]zone', 0)

    return true
end
