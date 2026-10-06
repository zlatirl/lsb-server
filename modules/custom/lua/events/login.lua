-----------------------------------
-- Login Campaign Max 70 pts
-----------------------------------
require('modules/module_utils')
require('modules/custom/lua/events/scheduled_event')
-----------------------------------
local m = Module:new('era_login_campaign')

xi.eraEvents.login = xi.eraEvents.login or {}
local login = xi.eraEvents.login

local event = xi.eraEvents.ScheduledEvent:new('login')

local firstLoginPoints = 10
local dailyLoginPoints = 2

login.getIsActive = function()
    return event:getIsActive()
end

event:setStartFunction(function()
    if xi.settings.main.ENABLE_LOGIN_CAMPAIGN == 1 then
        print('[EraEvents] WARNING: era login campaign started while ENABLE_LOGIN_CAMPAIGN = 1; both write the same LoginCampaign* char vars.')
    end
end)

local function getNextMidnight()
    local now  = GetSystemTime()
    local date = os.date('*t', now)

    return now + 24 * 60 * 60 - date.sec - date.min * 60 - date.hour * 60 * 60
end

login.onGameIn = function(player)
    if not login.getIsActive() then
        return
    end

    local ID         = zones[player:getZoneID()]
    local now        = GetSystemTime()
    local campaign   = os.date('*t', event:getStartTime())
    local loginCount = player:getCharVar('LoginCampaignLoginNumber')

    if
        player:getCharVar('LoginCampaignYear') ~= campaign.year or
        player:getCharVar('LoginCampaignMonth') ~= campaign.month
    then
        player:setCharVar('LoginCampaignYear', campaign.year)
        player:setCharVar('LoginCampaignMonth', campaign.month)
        player:setCharVar('LoginCampaignLoginNumber', 0)
        player:setCharVar('LoginCampaignNextMidnight', 0)
        loginCount = 0
    end

    if now < player:getCharVar('LoginCampaignNextMidnight') then
        return
    end

    player:setCharVar('LoginCampaignNextMidnight', getNextMidnight())

    loginCount = loginCount + 1
    player:setCharVar('LoginCampaignLoginNumber', loginCount)

    local pointsGained = loginCount == 1 and firstLoginPoints or dailyLoginPoints
    player:incrementCharVar('LoginPoints', pointsGained)

    if ID.text.LOGIN_CAMPAIGN_UNDERWAY and ID.text.LOGIN_NUMBER then
        player:messageSpecial(ID.text.LOGIN_CAMPAIGN_UNDERWAY, campaign.year, campaign.month)
        player:messageSpecial(ID.text.LOGIN_NUMBER, 0, loginCount, pointsGained, player:getCharVar('LoginPoints'))
    end
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)

    player:timer(2500, function(playerArg)
        login.onGameIn(playerArg)
    end)
end)
