-----------------------------------
-- Era Scheduled Events
-----------------------------------
require('scripts/globals/interaction/interaction_global')
-----------------------------------
xi = xi or {}
xi.eraEvents = xi.eraEvents or {}
xi.eraEvents.scheduled = xi.eraEvents.scheduled or {}

---@class TEraScheduledEvent
---@field id string
---@field isEnabled boolean
---@field sections table?
xi.eraEvents.ScheduledEvent = xi.eraEvents.ScheduledEvent or {}

local scheduledEvent = xi.eraEvents.ScheduledEvent
scheduledEvent.__index = scheduledEvent
scheduledEvent.__eq = function(c1, c2)
    return c1.id == c2.id
end

local noop = function()
end

---@param id string
---@return TEraScheduledEvent
function scheduledEvent:new(id)
    local obj = {}
    setmetatable(obj, self)
    obj.id             = id
    obj.isEnabled      = false
    obj.startFunc      = noop
    obj.endFunc        = noop
    obj.serverTickFunc = noop
    obj.sections       = nil

    -- Hot reload: drop the old object's interactions and keep its running state,
    -- so a live event doesn't run its start function a second time.
    local previous = xi.eraEvents.scheduled[id]
    if previous then
        if previous.sections then
            InteractionGlobal.lookup:removeContainer(previous)
        end

        obj.isEnabled = previous.isEnabled
    end

    xi.eraEvents.scheduled[id] = obj

    return obj
end

function scheduledEvent:getStartTime()
    return GetServerVariable('[Event]' .. self.id .. 'Start')
end

function scheduledEvent:getEndTime()
    return GetServerVariable('[Event]' .. self.id .. 'End')
end

function scheduledEvent:getIsActive()
    local currentTime = GetSystemTime()
    local startTime   = self:getStartTime()
    local endTime     = self:getEndTime()

    if startTime == 0 or startTime > currentTime then
        return false
    end

    -- No end time (or an end time before the start) means the event runs until ended.
    if endTime == 0 or startTime > endTime then
        return true
    end

    return currentTime < endTime
end

function scheduledEvent:setStartFunction(startFunc)
    self.startFunc = startFunc
    return self
end

function scheduledEvent:setEndFunction(endFunc)
    self.endFunc = endFunc
    return self
end

function scheduledEvent:setServerTickFunction(serverTickFunc)
    self.serverTickFunc = serverTickFunc
    return self
end

function scheduledEvent:checkActive()
    local wasEnabled = self.isEnabled

    self.isEnabled = self:getIsActive()

    if self.isEnabled == wasEnabled then
        return
    end

    if self.isEnabled then
        print('Starting Scheduled Event: ' .. self.id)
        self:startFunc()
    else
        print('Ending Scheduled Event: ' .. self.id)
        self:endFunc()
    end
end

function scheduledEvent:addInteractions(sections)
    if self.sections then
        InteractionGlobal.lookup:removeContainer(self)
    end

    self.sections = sections

    InteractionGlobal.lookup:addContainer(self)
end

xi.eraEvents.checkScheduledEvents = function()
    for id, event in pairs(xi.eraEvents.scheduled) do
        local ok, err = pcall(function()
            event:checkActive()

            if event.isEnabled then
                event:serverTickFunc()
            end
        end)

        if not ok then
            printf('[EraEvents] Error in scheduled event %s: %s', id, err)
        end
    end
end
