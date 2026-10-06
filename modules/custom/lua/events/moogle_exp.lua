-----------------------------------
-- B.R.O. Moogles will give EXP buff to all players during this event
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
xi.eraEvents.moogleExp = xi.eraEvents.moogleExp or {}

local event = xi.eraEvents.ScheduledEvent:new('moogleExp')

xi.eraEvents.moogleExp.getIsActive = function()
    return event:getIsActive()
end
