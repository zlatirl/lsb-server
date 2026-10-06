-----------------------------------
-- func: event <command> ...
--       event help [<command>]
--       event list
--       event start <eventName> [<startTime>]
--       event end <eventName> [<endTime>]
--       event check <eventName>
-- desc: Schedule era custom events/campaigns.
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 2,
    parameters = 'sssssssssssssss',
}

local dateDisplayFormat = '%b %d, %Y %I:%M:%S%p'

local function usageError(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('For usage instructions, run: !event help')
end

local function formatTime(timestamp)
    return os.date(dateDisplayFormat, timestamp)
end

local dateFormats =
{
    { pattern = '^((%d%d%d%d)[-/](%d%d)[-/](%d%d))(.*)$',   keys = { 'date', 'year', 'month', 'day', 'timeString' } },
    { pattern = '^((%d%d?) (%a%a%a%a*),? (%d%d%d%d))(.*)$', keys = { 'dateName', 'day', 'monthName', 'year', 'timeString' } },
    { pattern = '^((%a%a%a%a*) (%d%d?),? (%d%d%d%d))(.*)$', keys = { 'dateName', 'monthName', 'day', 'year', 'timeString' } },
}

local timeFormats =
{
    { pattern = '^,?[T ]((%d%d?):(%d%d):(%d%d)([ap]m))(.*)$', keys = { 'time', 'hour', 'min', 'sec', 'ampm', 'offsetString' } },
    { pattern = '^,?[T ]((%d%d):(%d%d):(%d%d))(.*)$',         keys = { 'time', 'hour', 'min', 'sec', 'offsetString' } },
    { pattern = '^,?[T ]((%d%d?):(%d%d)([ap]m))(.*)$',        keys = { 'time', 'hour', 'min', 'ampm', 'offsetString' } },
    { pattern = '^,?[T ]((%d%d):(%d%d))(.*)$',                keys = { 'time', 'hour', 'min', 'offsetString' } },
}

local offsetFormats =
{
    { pattern = '^(Z)$',                 keys = { 'utc' } },
    { pattern = '^([+-])(%d%d):(%d%d)$', keys = { 'sign', 'offsetHour', 'offsetMin' } },
    { pattern = '^([+-])(%d%d)$',        keys = { 'sign', 'offsetHour' } },
}

local monthNames =
{
    Jan = 1,  January   = 1,
    Feb = 2,  February  = 2,
    Mar = 3,  March     = 3,
    Apr = 4,  April     = 4,
    May = 5,
    Jun = 6,  June      = 6,
    Jul = 7,  July      = 7,
    Aug = 8,  August    = 8,
    Sep = 9,  September = 9,
    Oct = 10, October   = 10,
    Nov = 11, November  = 11,
    Dec = 12, December  = 12,
}

local function matchFormat(obj, str, formats)
    for _, format in ipairs(formats) do
        local matches = { string.match(str, format.pattern) }

        if matches[1] then
            for index, key in ipairs(format.keys) do
                obj[key] = matches[index]
            end

            return true
        end
    end

    return false
end

-- Parses e.g. '2023-09-02 11:00-07' or 'Sep 2, 2023 11:00am' into a unix timestamp.
-- Without a timezone the server's local time is used. Returns nil on failure.
local function parseDateString(player, dateString)
    local obj = {}

    if not matchFormat(obj, dateString, dateFormats) then
        player:printToPlayer('Invalid date component.')
        return nil
    end

    if
        obj.timeString ~= '' and
        not matchFormat(obj, obj.timeString, timeFormats)
    then
        player:printToPlayer('Invalid time component.')
        return nil
    end

    if obj.monthName then
        obj.month = monthNames[obj.monthName]

        if not obj.month then
            player:printToPlayer('Invalid month name.')
            return nil
        end
    end

    -- A bare date means midnight (os.time would otherwise default to noon).
    local dateTable =
    {
        year  = tonumber(obj.year),
        month = tonumber(obj.month),
        day   = tonumber(obj.day),
        hour  = tonumber(obj.hour) or 0,
        min   = tonumber(obj.min) or 0,
        sec   = tonumber(obj.sec) or 0,
    }

    if obj.ampm == 'pm' and dateTable.hour ~= 12 then
        dateTable.hour = dateTable.hour + 12
    elseif obj.ampm == 'am' and dateTable.hour == 12 then
        dateTable.hour = 0
    end

    local offset = 0

    if obj.offsetString and obj.offsetString ~= '' then
        if not matchFormat(obj, obj.offsetString, offsetFormats) then
            player:printToPlayer('Invalid timezone component.')
            return nil
        end

        dateTable.isdst = false

        -- os.time reads dateTable as server local time; shift it into the requested timezone.
        ---@diagnostic disable-next-line: param-type-mismatch
        local utcOffset    = os['time'](os.date('!*t')) - os['time'](os.date('*t'))
        local offsetSecs   = (tonumber(obj.offsetHour) or 0) * 60 * 60 + (tonumber(obj.offsetMin) or 0) * 60

        if obj.utc then
            offset = utcOffset
        elseif obj.sign == '+' then
            offset = utcOffset + offsetSecs
        else
            offset = utcOffset - offsetSecs
        end
    end

    local timestamp = os['time'](dateTable)
    if not timestamp then
        return nil
    end

    return timestamp - offset
end

local function liveText(event)
    return event:getIsActive() and 'live' or 'not live'
end

local function handleHelp(player, command)
    command = command and string.lower(command)

    if not command then
        player:printToPlayer('!event <command> <eventName> ...', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('List of available !event commands:', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('(< > means user entry, [ ] means optional)', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('list', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('start <eventName> [<startTime>]', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('end <eventName> [<endTime>]', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('check <eventName>', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('You can get additional info on a specific command with: !event help <command>', xi.msg.channel.SYSTEM_3)
    elseif command == 'list' then
        player:printToPlayer('list', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Lists all available Scheduled Events and their current schedules.', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Example: !event list', xi.msg.channel.SYSTEM_3)
    elseif command == 'start' then
        player:printToPlayer('start <eventName> [<startTime>]', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Schedules the start time of an event (or starts it now if no time is provided).', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('The event will continue indefinitely unless the `end` command is also used.', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Example: !event start assault Sep 2, 2023 11:00-07', xi.msg.channel.SYSTEM_3)
    elseif command == 'end' then
        player:printToPlayer('end <eventName> [<endTime>]', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Schedules the end time of an event (or ends it now if no time is provided).', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Example: !event end assault Sep 9, 2023 11:00-07', xi.msg.channel.SYSTEM_3)
    elseif command == 'check' then
        player:printToPlayer('check <eventName>', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Checks whether an event is currently live and shows its schedule.', xi.msg.channel.SYSTEM_3)
        player:printToPlayer('Example: !event check assault', xi.msg.channel.SYSTEM_3)
    else
        player:printToPlayer('Unknown event command.')
        handleHelp(player)
    end
end

local function handleList(player)
    if next(xi.eraEvents.scheduled) == nil then
        player:printToPlayer('There are no scheduled events registered.', xi.msg.channel.SYSTEM_3)
        return
    end

    local eventNames = {}
    for eventName, _ in pairs(xi.eraEvents.scheduled) do
        table.insert(eventNames, eventName)
    end

    table.sort(eventNames)

    for _, eventName in ipairs(eventNames) do
        local event     = xi.eraEvents.scheduled[eventName]
        local startTime = event:getStartTime()
        local endTime   = event:getEndTime()
        local msg       = eventName

        if startTime == 0 then
            msg = msg .. ' is not scheduled to start.'
        else
            msg = msg .. ' is ' .. liveText(event) .. '. Starts: ' .. formatTime(startTime) .. '.'

            if endTime == 0 then
                msg = msg .. ' Does not have an end date.'
            else
                msg = msg .. ' Ends: ' .. formatTime(endTime) .. '.'
            end
        end

        player:printToPlayer(msg, xi.msg.channel.SYSTEM_3)
    end
end

local function handleSetTime(player, event, suffix, label, ...)
    local dateString = table.concat({ ... }, ' ')
    local targetTime = GetSystemTime()

    if dateString ~= '' then
        targetTime = parseDateString(player, dateString)

        if not targetTime then
            player:printToPlayer('Could not parse that date string.')
            return
        end
    end

    SetServerVariable('[Event]' .. event.id .. suffix, targetTime)

    player:printToPlayer(string.format('%s event %s date: %s', event.id, label, formatTime(targetTime)), xi.msg.channel.SYSTEM_3)
    player:printToPlayer(string.format('%s event is %s.', event.id, liveText(event)), xi.msg.channel.SYSTEM_3)
end

local function handleCheck(player, event)
    local startTime = event:getStartTime()
    local endTime   = event:getEndTime()

    if startTime == 0 then
        player:printToPlayer(event.id .. ' event is not scheduled to start.', xi.msg.channel.SYSTEM_3)
    else
        player:printToPlayer(event.id .. ' event start date: ' .. formatTime(startTime), xi.msg.channel.SYSTEM_3)

        if endTime == 0 then
            player:printToPlayer(event.id .. ' event does not have an end date.', xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer(event.id .. ' event end date: ' .. formatTime(endTime), xi.msg.channel.SYSTEM_3)
        end
    end

    player:printToPlayer(string.format('%s event is %s.', event.id, liveText(event)), xi.msg.channel.SYSTEM_3)
end

local function findEvent(eventName)
    for id, event in pairs(xi.eraEvents.scheduled) do
        if string.lower(id) == string.lower(eventName) then
            return event
        end
    end

    return nil
end

commandObj.onTrigger = function(player, command, eventName, ...)
    command = command and string.lower(command)

    if not command or command == 'help' then
        handleHelp(player, eventName)
        return
    end

    if command == 'list' then
        handleList(player)
        return
    end

    if not eventName then
        usageError(player, 'Invalid eventName provided.')
        return
    end

    local event = findEvent(eventName)
    if not event then
        usageError(player, 'No event with that eventName found.')
        return
    end

    if command == 'start' then
        handleSetTime(player, event, 'Start', 'start', ...)
    elseif command == 'end' then
        handleSetTime(player, event, 'End', 'end', ...)
    elseif command == 'check' then
        handleCheck(player, event)
    else
        usageError(player, 'Unknown event command.')
    end
end

xi.module.registerCommand('event', commandObj)
