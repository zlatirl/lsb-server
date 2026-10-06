-----------------------------------
-- Era Ra'Kaznar Inner Court NMs
-- Five retail Ra'Kaznar mobs reworked into ???-popped NMs. Trade a ??? 250,000 gil for a Dawn Phantom Gem,
-- then talk to it to pop its NM: Poxhound (qm1, brings Draftdance Fluturini), Whitenoise Bats (qm2),
-- Wayward Bhoot (qm3, brings Dolorous Cyhiraeth).
-- Their stats live in modules/custom/data/zones/rakaznar_inner_court/mobs.yaml.
-----------------------------------
require('modules/module_utils')
-----------------------------------
local m = Module:new('era_rakaznar_nms')

-- Each NM is the first spawn of its retail template.
local nmIds =
{
    POXHOUND             = 17907715,
    DRAFTDANCE_FLUTURINI = 17907713,
    WHITENOISE_BATS      = 17907757,
    WAYWARD_BHOOT        = 17907733,
    DOLOROUS_CYHIRAETH   = 17907735,
}

local popPrice = 250000

local function isSpawned(mobId)
    local mob = GetMobByID(mobId)
    return mob ~= nil and mob:isSpawned()
end

-- Position just beside the target, for the NMs that warp onto whoever they hit.
local function nearTarget(target)
    local pos = target:getPos()
    pos.rot = target:getRotPos()

    return NearLocation(pos, 1.5, math.random() * math.pi)
end

-- Crowd control the Bhoot and Cyhiraeth shrug off with a matching TP move.
local effectResponses =
{
    { effect = xi.effect.STUN,     skill = xi.mobSkill.WINTER_BREEZE   },
    { effect = xi.effect.SILENCE,  skill = xi.mobSkill.VOICELESS_STORM },
    { effect = xi.effect.SLEEP_I,  skill = xi.mobSkill.SPRING_BREEZE   },
    { effect = xi.effect.SLEEP_II, skill = xi.mobSkill.SPRING_BREEZE   },
    { effect = xi.effect.LULLABY,  skill = xi.mobSkill.SPRING_BREEZE   },
}

local function respondToEffects(mob)
    for _, response in ipairs(effectResponses) do
        if mob:hasStatusEffect(response.effect) then
            mob:delStatusEffect(response.effect)
            mob:useMobAbility(response.skill)
            return
        end
    end
end

-- Steps through phases as HP drops; phases[0] is the first, keyed by the 'Breath' local var.
local function runPhases(mob, target, phases, onPhase)
    local hpp   = mob:getHPP()
    local phase = mob:getLocalVar('Breath')
    local next  = phases[phase]

    if hpp == 100 then
        mob:setLocalVar('Breath', 0)
    elseif next and hpp < next.hpp then
        mob:setLocalVar('Breath', phase + 1)
        onPhase(next)
    end
end

-----------------------------------
-- Poxhound
-----------------------------------
local poxhound = {}

do
    local breathPhases =
    {
        [0] = { hpp = 80 },
        [1] = { hpp = 55 },
        [2] = { hpp = 30 },
        [3] = { hpp = 10 },
    }

    poxhound.onMobInitialize = function(mob)
        mob:setMod(xi.mod.BINDRES, 20)
        mob:setMod(xi.mod.SLEEPRES, 100)
        mob:setMod(xi.mod.MDEF, 50)
        mob:setMod(xi.mod.TRIPLE_ATTACK, 30)
    end

    poxhound.onMobEngaged = function(mob, target)
        mob:setMod(xi.mod.REGAIN, 250)
    end

    poxhound.onMobFight = function(mob, target)
        if not isSpawned(nmIds.DRAFTDANCE_FLUTURINI) then
            GetMobByID(nmIds.DRAFTDANCE_FLUTURINI):setSpawn(mob:getXPos() + math.random(1, 5), mob:getYPos(), mob:getZPos() + math.random(1, 5))
            SpawnMob(nmIds.DRAFTDANCE_FLUTURINI, 300):updateEnmity(target)
        end

        runPhases(mob, target, breathPhases, function()
            mob:resetEnmity(target)
            mob:useMobAbility(xi.mobSkill.PETRIBREATH)
        end)
    end

    poxhound.onMobWeaponSkill = function(mob, target, skill, action)
        GetMobByID(nmIds.DRAFTDANCE_FLUTURINI):updateEnmity(target)
    end

    poxhound.onMobDisengage = function(mob)
        mob:setMod(xi.mod.REGAIN, 0)
    end
end

-----------------------------------
-- Draftdance Fluturini
-----------------------------------
local draftdanceFluturini = {}

do
    local blowupPhases =
    {
        [0] = { hpp = 75, wakeUp = true  },
        [1] = { hpp = 50, wakeUp = true  },
        [2] = { hpp = 25, wakeUp = false },
        [3] = { hpp =  5, wakeUp = false },
    }

    local sleepEffects =
    {
        xi.effect.SLEEP_I,
        xi.effect.SLEEP_II,
        xi.effect.LULLABY,
    }

    -- Thief-bolt style add effects; one is picked per hit.
    local addEffects =
    {
        { ae = xi.mob.ae.PLAGUE,  effect = xi.effect.PLAGUE  },
        { ae = xi.mob.ae.SLEEP,   effect = xi.effect.SLEEP_I },
        { ae = xi.mob.ae.SILENCE, effect = xi.effect.SILENCE },
        { ae = xi.mob.ae.POISON,  effect = xi.effect.POISON, power = 4 },
        { ae = xi.mob.ae.STUN,    effect = xi.effect.STUN    },
    }

    draftdanceFluturini.onMobEngaged = function(mob, target)
        mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
        mob:setMod(xi.mod.GRAVITYRES, 100)
    end

    draftdanceFluturini.onMobFight = function(mob, target)
        local hpp             = mob:getHPP()
        local poxhoundIsAlive = isSpawned(nmIds.POXHOUND)

        -- Drains while Poxhound lives (regenerating again below 47%), regenerates once it is dead.
        if not poxhoundIsAlive then
            mob:setMod(xi.mod.REGEN, math.floor(mob:getMaxHP() / 200))
            mob:setUnkillable(false)
        elseif hpp < 47 then
            mob:setMod(xi.mod.REGEN, math.floor(mob:getMaxHP() / 50))
        else
            mob:setMod(xi.mod.REGEN, math.floor(mob:getMaxHP() / -100))
        end

        if hpp < 26 and poxhoundIsAlive then
            mob:addHP(math.floor(mob:getMaxHP() * 0.75))
            mob:setLocalVar('Breath', 0)
        end

        if hpp < 50 then
            mob:setMod(xi.mod.SLEEPRES, 100)
            mob:setMod(xi.mod.LULLABYRES, 100)
            mob:setMod(xi.mod.DOUBLE_ATTACK, 25)
            mob:setMod(xi.mod.MDEF, 100)

            if mob:hasStatusEffect(xi.effect.BIND) then
                mob:delStatusEffect(xi.effect.BIND)
                mob:resetEnmity(target)
            end
        end

        if hpp < 25 then
            if not mob:hasStatusEffect(xi.effect.ARROW_SHIELD) then
                mob:addStatusEffect(xi.effect.ARROW_SHIELD, { power = 1, duration = 99999, origin = mob })
            end
        else
            mob:delStatusEffect(xi.effect.ARROW_SHIELD)
        end

        runPhases(mob, target, blowupPhases, function(phase)
            mob:resetEnmity(target)

            if phase.wakeUp then
                for _, effect in ipairs(sleepEffects) do
                    mob:delStatusEffect(effect)
                end
            end

            GetMobByID(nmIds.POXHOUND):updateEnmity(target)
            mob:teleport(nearTarget(target), target)
            mob:useMobAbility(xi.mobSkill.MIJIN_GAKURE_1)
        end)
    end

    draftdanceFluturini.onMobWeaponSkill = function(mob, target, skill, action)
        GetMobByID(nmIds.POXHOUND):updateEnmity(target)
    end

    -- A target that already has the rolled effect is dropped from hate so the next player gets it.
    draftdanceFluturini.onAdditionalEffect = function(mob, target, damage)
        local pick = addEffects[math.random(#addEffects)]

        if target:hasStatusEffect(pick.effect) then
            mob:resetEnmity(target)
            return 0, 0, 0
        end

        return xi.mob.onAddEffect(mob, target, damage, pick.ae, { chance = 20, duration = 5, power = pick.power })
    end

    draftdanceFluturini.onMobDisengage = function(mob)
        mob:setUnkillable(true)
    end
end

-----------------------------------
-- Whitenoise Bats
-----------------------------------
local whitenoiseBats = {}

do
    local breathPhases =
    {
        [0] = { hpp = 80, skill = xi.mobSkill.COLD_BREATH,       resetAfter = false },
        [1] = { hpp = 55, skill = xi.mobSkill.HEAT_BREATH_1,     resetAfter = true  },
        [2] = { hpp = 30, skill = xi.mobSkill.LEVEL_5_PETRIFY_1, resetAfter = true  },
        [3] = { hpp = 10, skill = xi.mobSkill.FULMINATION,       resetAfter = true  },
    }

    -- Every 30 seconds one damage type becomes fully absorbed.
    local shieldMods =
    {
        xi.mod.UDMGPHYS,
        xi.mod.UDMGRANGE,
        xi.mod.UDMGMAGIC,
    }

    local shieldInterval = 30

    whitenoiseBats.onMobEngaged = function(mob, target)
        mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
        mob:setMobMod(xi.mobMod.HP_STANDBACK, -1)
    end

    whitenoiseBats.onMobFight = function(mob, target)
        runPhases(mob, target, breathPhases, function(phase)
            mob:resetEnmity(target)
            mob:teleport(nearTarget(target), target)
            mob:useMobAbility(phase.skill)

            if phase.resetAfter then
                mob:resetEnmity(target)
            end
        end)

        if mob:getBattleTime() - mob:getLocalVar('changeTime') > shieldInterval then
            mob:setLocalVar('changeTime', mob:getBattleTime())

            for _, damageMod in ipairs(shieldMods) do
                mob:setMod(damageMod, 0)
            end

            mob:setMod(shieldMods[math.random(#shieldMods)], -1000)
        end
    end

    whitenoiseBats.onAdditionalEffect = function(mob, target, damage)
        return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.POISON, { chance = 65, duration = math.random(4, 8) })
    end
end

-----------------------------------
-- Wayward Bhoot / Dolorous Cyhiraeth
-----------------------------------
local function applyCasterMods(mob)
    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
    mob:setMod(xi.mod.AQUAVEIL_COUNT, 20)
    mob:setMod(xi.mod.BINDRES, 20)
    mob:setMod(xi.mod.SLEEPRES, -100)
    mob:setMod(xi.mod.GRAVITYRES, 30)
    mob:setMod(xi.mod.REFRESH, 300)
    mob:setMod(xi.mod.REGEN, 5)
    mob:setMod(xi.mod.SILENCERES, -100)
    mob:setMod(xi.mod.STUNRES, -100)
end

local function clearCasterMods(mob)
    mob:setMod(xi.mod.BINDRES, 0)
    mob:setMod(xi.mod.SLEEPRES, 0)
    mob:setMod(xi.mod.GRAVITYRES, 0)
    mob:setMod(xi.mod.REFRESH, 0)
    mob:setMod(xi.mod.REGEN, 0)
    mob:setMod(xi.mod.AQUAVEIL_COUNT, 0)
end

-- While its spikes are up the mob takes no physical or ranged damage and regenerates 1%/tick.
local function applySpikeShield(mob, spikes)
    if mob:hasStatusEffect(spikes) then
        mob:setMod(xi.mod.UDMGRANGE, -1000)
        mob:setMod(xi.mod.UDMGPHYS, -1000)
        mob:setMod(xi.mod.REGEN, math.floor(mob:getMaxHP() / 100))
    else
        mob:setMod(xi.mod.UDMGRANGE, 0)
        mob:setMod(xi.mod.UDMGPHYS, 0)
        mob:setMod(xi.mod.REGEN, 0)
    end
end

local wayward = {}

do
    local breathPhases =
    {
        [0] = { hpp = 80, skill = xi.mobSkill.ABRASIVE_TANTRA, resetEnmity = false },
        [1] = { hpp = 50, skill = xi.mobSkill.NERVE_GAS,       resetEnmity = true  },
        [2] = { hpp = 30, skill = xi.mobSkill.VOICELESS_STORM, resetEnmity = true  },
        [3] = { hpp = 10, skill = xi.mobSkill.INFERNO_BLAST,   resetEnmity = true  },
    }

    wayward.onMobSpawn = function(mob)
        if not isSpawned(nmIds.DOLOROUS_CYHIRAETH) then
            SpawnMob(nmIds.DOLOROUS_CYHIRAETH, 300)
        end
    end

    wayward.onMobEngaged = function(mob, target)
        GetMobByID(nmIds.DOLOROUS_CYHIRAETH):updateEnmity(target)
        applyCasterMods(mob)
    end

    wayward.onMobFight = function(mob, target)
        runPhases(mob, target, breathPhases, function(phase)
            mob:useMobAbility(phase.skill)

            if phase.resetEnmity then
                mob:resetEnmity(target)
            end
        end)

        applySpikeShield(mob, xi.effect.ICE_SPIKES)
        respondToEffects(mob)
    end

    wayward.onMobWeaponSkill = function(mob, target, skill, action)
        mob:resetEnmity(target)
        mob:teleport(nearTarget(target), target)
        skill:setMsg(0)
        GetMobByID(nmIds.DOLOROUS_CYHIRAETH):updateEnmity(target)
    end

    wayward.onSpellPrecast = function(mob, spell)
        mob:setMod(xi.mod.AQUAVEIL_COUNT, 20)
    end

    wayward.onMobDisengage = function(mob)
        clearCasterMods(mob)
    end
end

local dolorousCyhiraeth = {}

do
    local breathPhases =
    {
        [0] = { hpp = 75, skill = xi.mobSkill.ELECTROCHARGE, resetEnmity = false },
        [1] = { hpp = 50, skill = xi.mobSkill.ICE_BREAK_1,   resetEnmity = true  },
        [2] = { hpp = 30, skill = xi.mobSkill.SILENCE_GAS_1, resetEnmity = true  },
        [3] = { hpp = 10, skill = xi.mobSkill.PILE_PITCH_2,  resetEnmity = true  },
    }

    dolorousCyhiraeth.onMobEngaged = function(mob, target)
        mob:updateEnmity(target)
        applyCasterMods(mob)
        mob:setMod(xi.mod.LULLABYRES, -100)
        mob:setMod(xi.mod.FASTCAST, 50)
    end

    dolorousCyhiraeth.onMobFight = function(mob, target)
        local bhootIsAlive = isSpawned(nmIds.WAYWARD_BHOOT)

        if mob:getHPP() < 26 and bhootIsAlive then
            mob:addHP(math.floor(mob:getMaxHP() * 0.75))
        end

        runPhases(mob, target, breathPhases, function(phase)
            mob:useMobAbility(phase.skill)

            if phase.resetEnmity then
                mob:resetEnmity(target)
            end
        end)

        respondToEffects(mob)
        applySpikeShield(mob, xi.effect.BLAZE_SPIKES)

        if not bhootIsAlive then
            mob:setUnkillable(false)
        end
    end

    -- Warps onto whoever it just hit: Apocalypse Nigh's warp without the animation, which would block other skills.
    dolorousCyhiraeth.onMobWeaponSkill = function(mob, target, skill, action)
        mob:resetEnmity(target)
        mob:teleport(nearTarget(target), target)
        skill:setMsg(0)
        mob:updateEnmity(target)
    end

    dolorousCyhiraeth.onSpellPrecast = function(mob, spell)
        mob:setMod(xi.mod.AQUAVEIL_COUNT, 20)
    end

    dolorousCyhiraeth.onMobDisengage = function(mob)
        mob:setUnkillable(true)
        clearCasterMods(mob)
        mob:setMod(xi.mod.LULLABYRES, 0)
    end
end

-----------------------------------
-- ??? NPCs
-----------------------------------
local function popNpc(nmId)
    return
    {
        onTrade = function(player, npc, trade)
            if not npcUtil.tradeHasExactly(trade, { { xi.item.GIL, popPrice } }) then
                return
            end

            if player:hasKeyItem(xi.keyItem.DAWN_PHANTOM_GEM) then
                player:printToPlayer('You already have a pop item in your possession.', xi.msg.channel.SAY, '???')
                return
            end

            player:confirmTrade()
            npcUtil.giveKeyItem(player, xi.keyItem.DAWN_PHANTOM_GEM)
        end,

        onTrigger = function(player, npc)
            if not player:hasKeyItem(xi.keyItem.DAWN_PHANTOM_GEM) then
                player:printToPlayer(string.format('Please trade %d gil to get a Dawn Phantom Gem Key Item.', popPrice), xi.msg.channel.SAY, '???')
            elseif isSpawned(nmId) then
                player:printToPlayer('Mobs are up already')
            else
                player:printToPlayer('Prepare yourself!')
                SpawnMob(nmId):updateClaim(player)
                player:delKeyItem(xi.keyItem.DAWN_PHANTOM_GEM)
            end
        end,
    }
end

-----------------------------------
-- Wiring
-----------------------------------
local scripts =
{
    ['xi.zones.RaKaznar_Inner_Court.mobs.Poxhound']             = poxhound,
    ['xi.zones.RaKaznar_Inner_Court.mobs.Draftdance_Fluturini'] = draftdanceFluturini,
    ['xi.zones.RaKaznar_Inner_Court.mobs.Whitenoise_Bats']      = whitenoiseBats,
    ['xi.zones.RaKaznar_Inner_Court.mobs.Wayward_Bhoot']        = wayward,
    ['xi.zones.RaKaznar_Inner_Court.mobs.Dolorous_Cyhiraeth']   = dolorousCyhiraeth,
    ['xi.zones.RaKaznar_Inner_Court.npcs.qm1']                  = popNpc(nmIds.POXHOUND),
    ['xi.zones.RaKaznar_Inner_Court.npcs.qm2']                  = popNpc(nmIds.WHITENOISE_BATS),
    ['xi.zones.RaKaznar_Inner_Court.npcs.qm3']                  = popNpc(nmIds.WAYWARD_BHOOT),
}

for path, handlers in pairs(scripts) do
    xi.module.ensureTable(path)

    for event, handler in pairs(handlers) do
        m:addOverride(path .. '.' .. event, function(...)
            return handler(...)
        end)
    end
end

return m
