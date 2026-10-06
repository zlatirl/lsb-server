-----------------------------------
-- Sunbreeze Music for City Zones
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
xi.eraEvents.sunbreezeFestival = xi.eraEvents.sunbreezeFestival or {}
local sunbreezeFestival = xi.eraEvents.sunbreezeFestival

sunbreezeFestival.originalMusic = sunbreezeFestival.originalMusic or {}

local event = xi.eraEvents.ScheduledEvent:new('sunbreezeFestival')

local sunbreezeShuffle = 227

local cityZones =
{
    xi.zone.RULUDE_GARDENS,
    xi.zone.LOWER_JEUNO,        xi.zone.PORT_JEUNO,         xi.zone.UPPER_JEUNO,
    xi.zone.SOUTHERN_SAN_DORIA, xi.zone.NORTHERN_SAN_DORIA, xi.zone.PORT_SAN_DORIA,
    xi.zone.BASTOK_MARKETS,     xi.zone.BASTOK_MINES,       xi.zone.PORT_BASTOK,
    xi.zone.WINDURST_WALLS,     xi.zone.WINDURST_WATERS,    xi.zone.WINDURST_WOODS,    xi.zone.PORT_WINDURST,
}

sunbreezeFestival.getIsActive = function()
    return event:getIsActive()
end

event:setStartFunction(function()
    for _, zoneID in ipairs(cityZones) do
        local zone = GetZone(zoneID)

        if zone then
            sunbreezeFestival.originalMusic[zoneID] = sunbreezeFestival.originalMusic[zoneID] or zone:getBackgroundMusicNight()
            zone:setBackgroundMusicNight(sunbreezeShuffle)
        end
    end
end)

event:setEndFunction(function()
    for _, zoneID in ipairs(cityZones) do
        local zone          = GetZone(zoneID)
        local originalMusic = sunbreezeFestival.originalMusic[zoneID]

        if zone and originalMusic then
            zone:setBackgroundMusicNight(originalMusic)
        end

        sunbreezeFestival.originalMusic[zoneID] = nil
    end
end)
