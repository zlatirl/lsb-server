-----------------------------------
-- Assault campaign: 1 full tag refresh at Qulsun, bonus points, and double refresh rate
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_assault_event')

xi.eraEvents.assault = xi.eraEvents.assault or {}

local event = xi.eraEvents.ScheduledEvent:new('assault')

local pointsMultiplier         = 3
local firstCompletionPromotion = 8
local repeatPromotion          = 3
local tagRestockDivisor        = 2

xi.eraEvents.assault.getIsActive = function()
    return event:getIsActive()
end

xi.eraEvents.assault.getStartTime = function()
    return event:getStartTime()
end

xi.eraEvents.assault.getEndTime = function()
    return event:getEndTime()
end

local function onQulsunTrigger(player, npc)
    local eventStart = event:getStartTime()

    if player:getCharVar('FREE_TAGS') == eventStart then
        return
    end

    if player:getLocalVar('freeTagCheck') == 0 then
        player:setLocalVar('freeTagCheck', 1)
        player:printToPlayer('It appears that you are eligible for a full tag recharge, courtesy of the Era Staff!', xi.msg.channel.SAY, 'Qulsun')
        player:printToPlayer('Talk to me again if you are certain you are ready for your tag recharge. This is only available once per event!', xi.msg.channel.SAY, 'Qulsun')
        return NoAction:new()
    end

    player:setLocalVar('freeTagCheck', 0)
    player:setCharVar('FREE_TAGS', eventStart)
    player:setCurrency('id_tags', xi.assault.getMaxTagStock(player))

    player:printToPlayer('Then these are for you! We hope you enjoy completing assaults. You can use these immediately by speaking to folks on my right.', xi.msg.channel.SAY, 'Qulsun')
    player:printToPlayer('Also, the Era Staff has told me to let you know how much they appreciate you playing here. Thank you!', xi.msg.channel.SAY, 'Qulsun')
    player:printToPlayer('Your Imperial Army I.D. Tags have been fully recharged!', xi.msg.channel.SYSTEM_1)

    return NoAction:new()
end

event:addInteractions({
    {
        check = function(player)
            return event:getIsActive()
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Qulsun'] =
            {
                onTrigger = onQulsunTrigger,
            },
        },
    },
})

m:addOverride('xi.assault.getTagRestockPeriod', function(player, idTagPeriod)
    idTagPeriod = super(player, idTagPeriod)

    if not xi.eraEvents.assault.getIsActive() then
        return idTagPeriod
    end

    return math.floor(idTagPeriod / tagRestockDivisor)
end)

m:addOverride('xi.assault.applyEventBonus', function(member, points, promotionBonus, isFirstCompletion)
    points, promotionBonus = super(member, points, promotionBonus, isFirstCompletion)

    if not xi.eraEvents.assault.getIsActive() then
        return points, promotionBonus
    end

    return points * pointsMultiplier, isFirstCompletion and firstCompletionPromotion or repeatPromotion
end)
