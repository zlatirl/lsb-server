-----------------------------------
-- Era NPC
-- Utilities for custom Era NPC interactions
-----------------------------------
require('modules/module_utils')
require('scripts/globals/npc_util')
-----------------------------------
xi = xi or {}
xi.eraNpc = xi.eraNpc or {}

function xi.eraNpc.giveInstantWarpScroll(player, npc, params)
    params = params or {}
    params.name = params.name or npc:getName()

    if player:hasItem(xi.item.SCROLL_OF_INSTANT_WARP) then
        return false
    end

    player:printToPlayer('Bro, you forgot your Warp scroll, don\'t worry, I gotchu :D', xi.msg.channel.SAY, params.name)
    npcUtil.giveItem(player, xi.item.SCROLL_OF_INSTANT_WARP)

    return true
end

function xi.eraNpc.tryWarp(player, npc, params)
    local time = GetSystemTime()
    params.name = params.name or npc:getName()

    if
        player:getLocalVar('[Era]WarpNpc') ~= npc:getID() or
        time > player:getLocalVar('[Era]WarpTime')
    then
        player:setLocalVar('[Era]WarpNpc', npc:getID())
        player:setLocalVar('[Era]WarpTime', time + 30)
        player:printToPlayer('Warning! The next time you click this NPC, you will be transported.', xi.msg.channel.SAY, params.name)
        player:printToPlayer(string.format('Destination: %s', params.destinationName), xi.msg.channel.SAY, params.name)
        return false
    end

    if params.check and not params.check() then
        player:printToPlayer(params.checkFailureText, xi.msg.channel.SAY, params.name)
        return false
    end

    if params.destination == 'nation' then
        xi.teleport.toHomeNation(player)
    elseif params.destination == 'warp' then
        player:warp()
    else
        player:setPos(unpack(params.destination))
    end

    return true
end

function xi.eraNpc.giveInstantWarpScrollThenTryWarp(player, npc, params)
    if xi.eraNpc.giveInstantWarpScroll(player, npc, params) then
        return
    end

    xi.eraNpc.tryWarp(player, npc, params)
end

local function getTotalExp(player)
    local totalExpToAchieveLevel =
    {
        [0] = 0,
        0, 500, 1250, 2250, 3500, 5000, 6750, 8750, 10950, 13350,
        15950, 18750, 21750, 24950, 28350, 31950, 35750, 39750, 43950, 48350,
        52950, 57750, 62750, 67850, 73050, 78350, 83750, 89250, 94850, 100550,
        106350, 112250, 118250, 124350, 130550, 136850, 143250, 149750, 156350, 163050,
        169850, 176750, 183750, 190850, 198050, 205350, 212750, 220250, 227850, 235550,
        243350, 251350, 260550, 270950, 282550, 295350, 309350, 324550, 340950, 358550,
        377350, 397350, 418850, 441850, 466350, 492350, 519850, 548850, 579350, 611350,
        645350, 681350, 719350, 759350, 801350, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0,
    }

    local totalExp = 0
    for job = xi.job.WAR, xi.job.RUN do
        totalExp = totalExp + totalExpToAchieveLevel[player:getJobLevel(job)]
    end

    return totalExp
end

function xi.eraNpc.broMoogleTrade(player, npc, trade)
    player:printToPlayer('Hey bro, I don\'t know what you\'re expecting me to do with this. I\'m good.', xi.msg.channel.SAY, 'B.R.O. Moogle')
end

function xi.eraNpc.broMoogleTrigger(player, npc)
    local zoneid = player:getZoneID()
    local totalExp = getTotalExp(player)
    local expCap = 1087850 -- Enough exp for reaching level 75 and leveling two subjobs to 37

    -- B.R.O. Moogle explanation for first timers
    if player:getCharVar('BroMoogleIntro') == 0 then
        player:printToPlayer('Hey bro, I\'m one of Era\'s infamous buffing moogles!', xi.msg.channel.SAY, 'B.R.O. Moogle')
        player:printToPlayer('We\'ll help you out on your adventures. Just hit us up every time you see us!', xi.msg.channel.SAY, 'B.R.O. Moogle')
        player:printToPlayer('Talk to me again when you\'re ready for my Mighty Moogle Magic!', xi.msg.channel.SAY, 'B.R.O. Moogle')
        player:printToPlayer('What? Why didn\'t I say it? Bro, we\'re not all the same... *Sigh* ... Kupo...', xi.msg.channel.SAY, 'B.R.O. Moogle')
        player:setCharVar('BroMoogleIntro', 1)
        return
    end

    local time = GetSystemTime()

    if time > player:getLocalVar('[Era]BroBuffTime') then
        player:setLocalVar('[Era]BroBuffTime', time + 30)
        player:printToPlayer('Here are the buffs I\'m authorized to give you, bro.', xi.msg.channel.SAY, 'B.R.O. Moogle')
        player:addStatusEffect(xi.effect.RERAISE, { power = 1, duration = 7200, origin = player })

        if
            xi.eraEvents.moogleExp.getIsActive() or
            (player:getMainLvl() < 75 and totalExp < expCap)
        then
            player:addStatusEffect(xi.effect.DEDICATION, { power = 100, tick = 60, duration = 10800, subPower = 80000, origin = player }) -- Current EXP Buff
        elseif totalExp >= expCap and player:getCharVar('BroLockV1') == 0 then
            player:printToPlayer('Oh, bro, you\'ve grown so strong you don\'t need my magic anymore!', xi.msg.channel.SAY, 'B.R.O. Moogle')
            player:setCharVar('BroLockV1', 1)
        end
    end

    if xi.eraNpc.giveInstantWarpScroll(player, npc, { name = 'B.R.O. Moogle' }) then
        return
    end

    if
        player:getZone():getRegionID() == xi.region.JEUNO or
        zoneid == xi.zone.AHT_URHGAN_WHITEGATE
    then
        xi.eraNpc.tryWarp(player, npc, {
            destinationName = 'Your Home Nation',
            destination     = 'nation',
            name            = 'B.R.O. Moogle',
        })
    end
end

-----------------------------------
-- NPC wiring
-----------------------------------

local m = Module:new('era_npcs')

local function noop()
end

local function warpNpc(params)
    return
    {
        onTrigger = function(player, npc)
            xi.eraNpc.giveInstantWarpScrollThenTryWarp(player, npc, params)
        end,
    }
end

-- Conquest overseer that hands out an Instant Warp scroll first, when one is due.
local function warpScrollOverseer(name)
    local guardNation = xi.nation.OTHER
    local guardType   = xi.conquest.guard.CITY
    local guardEvent  = 32763

    return
    {
        onTrade = function(player, npc, trade)
            xi.conquest.overseerOnTrade(player, npc, trade, guardNation, guardType)
        end,

        onTrigger = function(player, npc)
            if xi.eraNpc.giveInstantWarpScroll(player, npc, { name = name }) then
                return
            end

            xi.conquest.overseerOnTrigger(player, npc, guardNation, guardType, guardEvent)
        end,

        onEventUpdate = function(player, csid, option)
            xi.conquest.overseerOnEventUpdate(player, csid, option, guardNation)
        end,

        onEventFinish = function(player, csid, option)
            xi.conquest.overseerOnEventFinish(player, csid, option, guardNation, guardType)
        end,
    }
end

local broMoogle =
{
    onTrade   = xi.eraNpc.broMoogleTrade,
    onTrigger = xi.eraNpc.broMoogleTrigger,
}

local nantoto =
{
    onTrigger = function(player, npc)
        if xi.eraNpc.giveInstantWarpScroll(player, npc) then
            return
        end

        if player:hasCompletedMission(xi.mission.log_id.WOTG, xi.mission.id.wotg.CAVERNOUS_MAWS) then
            player:printToPlayer('Trade me 1k gil to teleport to the Vunkerl Inlet (S) camp.', xi.msg.channel.SAY, 'Nantoto')
        else
            player:printToPlayer('You have not time traveled yet, so I don\'t think you know how to get back...', xi.msg.channel.SAY, 'Nantoto')
        end
    end,

    onTrade = function(player, npc, trade)
        if trade:getGil() == 1000 then
            if player:hasCompletedMission(xi.mission.log_id.WOTG, xi.mission.id.wotg.CAVERNOUS_MAWS) then
                player:confirmTrade()
                player:setPos(-18, -40, 306, 122, xi.zone.VUNKERL_INLET_S)
            else
                player:printToPlayer('You have not time traveled yet, so I don\'t think you know how to get back...', xi.msg.channel.SAY, 'Nantoto')
            end
        end
    end,
}

local npcs =
{
    ['Aht_Urhgan_Whitegate.npcs.Bro_Moogle'] = broMoogle,
    ['Bastok_Markets.npcs.Bro_Moogle']       = broMoogle,
    ['Lower_Jeuno.npcs.Bro_Moogle']          = broMoogle,
    ['Port_Jeuno.npcs.Bro_Moogle']           = broMoogle,
    ['RuLude_Gardens.npcs.Bro_Moogle']       = broMoogle,
    ['Southern_San_dOria.npcs.Bro_Moogle']   = broMoogle,
    ['Upper_Jeuno.npcs.Bro_Moogle']          = broMoogle,
    ['Windurst_Woods.npcs.Bro_Moogle']       = broMoogle,

    ['Aht_Urhgan_Whitegate.npcs.Amajal'] = warpNpc({
        destinationName = 'Caedarva Mire - Undead ZNM Camp',
        destination     = { -691, -24, 357, 132, xi.zone.CAEDARVA_MIRE },
    }),
    ['Lower_Jeuno.npcs.Falak'] = warpNpc({
        destinationName = 'Beaucedine Glacier [S] - Corse Light Camp',
        destination     = { -179.443, -83.660, -83.084, 255, xi.zone.BEAUCEDINE_GLACIER_S },
    }),
    ['Lower_Jeuno.npcs.Raji'] = warpNpc({
        destinationName = 'Crawler\'s Nest - Lizard Camp',
        destination     = { 132, -40, -70, 90, xi.zone.CRAWLERS_NEST },
    }),
    ['Lower_Jeuno.npcs.Shomera'] =
    {
        onTrigger = function(player, npc)
            xi.eraNpc.giveInstantWarpScrollThenTryWarp(player, npc, {
                destinationName  = 'Aht Urgan Whitegate',
                destination      = { 111, 0, 21, 190, xi.zone.AHT_URHGAN_WHITEGATE },
                checkFailureText = 'You do not own the \'Boarding Permit\' Key Item.',
                check            = function()
                    return player:hasKeyItem(xi.keyItem.BOARDING_PERMIT)
                end,
            })
        end,
    },
    ['Port_Jeuno.npcs.Naurmaire'] = warpNpc({
        destinationName = 'Western Altepa Desert - Beetle Camp',
        destination     = { -141, -14, 19, 255, xi.zone.WESTERN_ALTEPA_DESERT },
    }),
    ['RuLude_Gardens.npcs.Ajahkeem'] = warpNpc({
        destinationName = 'The Boyahda Tree - Crab Camp',
        destination     = { 215, 8, -38, 77, xi.zone.THE_BOYAHDA_TREE },
    }),
    ['RuLude_Gardens.npcs.Anoop'] = warpNpc({
        destinationName = 'Yhoator Jungle - Mandragora Camp',
        destination     = { -285, 8, 140, 253, xi.zone.YHOATOR_JUNGLE },
    }),
    ['RuLude_Gardens.npcs.Kayle'] = warpNpc({
        destinationName = 'Kuftal Tunnel - Tiger Camp',
        destination     = { 148, 19, -112, 147, xi.zone.KUFTAL_TUNNEL },
    }),

    ['Lower_Jeuno.npcs.Nantoto']          = nantoto,
    ['Lower_Jeuno.npcs.Rakuru-Rakoru']    = warpScrollOverseer('Rakuru-Rakoru'),
    ['RuLude_Gardens.npcs.Diradour']      = warpScrollOverseer('Diradour'),
    -- Stands still as a warp NPC instead of her retail patrol.
    ['RuLude_Gardens.npcs.Leis'] =
    {
        onSpawn   = noop,
        onTrigger = warpNpc({
            destinationName = 'Middle Delkfutt\'s Tower - Gigas Camp',
            destination     = { 20, -80, -73, 65, xi.zone.MIDDLE_DELKFUTTS_TOWER },
        }).onTrigger,
    },
    ['Provenance.npcs.Glimmering_Trove'] =
    {
        onTrigger = function(player, npc)
            xi.eraNpc.tryWarp(player, npc, {
                destinationName = 'Your Home Point',
                destination     = 'warp',
                name            = 'GlimmeringTrove',
            })
        end,
    },
}

-- NPCs with a base script must not be pre-created, or that script would never load over the table.
local hasBaseScript =
{
    ['RuLude_Gardens.npcs.Leis'] = true,
}

for npcPath, handlers in pairs(npcs) do
    local path = 'xi.zones.' .. npcPath
    if not hasBaseScript[npcPath] then
        xi.module.ensureTable(path)
    end

    for event, handler in pairs(handlers) do
        m:addOverride(path .. '.' .. event, function(...)
            return handler(...)
        end)
    end
end

return xi.eraNpc
