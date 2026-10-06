-----------------------------------
-- Cruor rewarded from merit exchange is doubled during this event
-----------------------------------
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
xi.eraEvents.cruorBonus = xi.eraEvents.cruorBonus or {}

local event = xi.eraEvents.ScheduledEvent:new('cruorBonus')

xi.eraEvents.cruorBonus.getIsActive = function()
    return event:getIsActive()
end
