-----------------------------------
-- Module: Era Scheduled Events handler
-- Desc: Drives start/end/tick of era scheduled events from the time server tick.
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_scheduled_events')

m:addOverride('xi.server.onTimeServerTick', function()
    super()

    xi.eraEvents.checkScheduledEvents()
end)
