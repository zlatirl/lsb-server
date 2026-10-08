-----------------------------------
-- Area: One of many zones in Shadowreign zones
--   NM: Sandworm
-----------------------------------

xi = xi or {}
xi.sandworm = xi.sandworm or {}

xi.sandworm.onMobInitialize = function(mob)
    mob:addImmunity(xi.immunity.ELEGY)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.PETRIFY)
    mob:addImmunity(xi.immunity.TERROR)
end

-----------------------------------
-- Doomvoid
-- Below 40% HP the Sandworm can Doomvoid, pulling its target's party into one of two fights
-- and burrowing away. Which fight is rolled when it spawns.
-----------------------------------

xi.sandworm.doomvoidHpp    = 40
xi.sandworm.doomvoidChance = 25 -- percent per TP move once below doomvoidHpp

xi.sandworm.fight =
{
    KING_ARTHRO            = 1,
    LAMBTON_WORM_EVERBLOOM = 2,
    SERKET                 = 3,
    LAMBTON_WORM_GHOYU     = 4,
    GUIVRE                 = 5,
    LAMBTON_WORM_RUHOTZ    = 6,
}

local fights =
{
    [xi.sandworm.fight.KING_ARTHRO]            = { nm = 17129519, zone = xi.zone.EVERBLOOM_HOLLOW,   pos = {  306.000, -9.000, -288.000, 167 } },
    [xi.sandworm.fight.LAMBTON_WORM_EVERBLOOM] = { nm = 17129532, zone = xi.zone.EVERBLOOM_HOLLOW,   pos = {  -19.938, -8.750, -320.105,  65 } },
    [xi.sandworm.fight.SERKET]                 = { nm = 17305666, zone = xi.zone.GHOYUS_REVERIE,     pos = {  102.365, -0.206, -295.594,  60 } },
    [xi.sandworm.fight.LAMBTON_WORM_GHOYU]     = { nm = 17305667, zone = xi.zone.GHOYUS_REVERIE,     pos = { -459.000,  0.000,  -48.000,  50 } },
    [xi.sandworm.fight.GUIVRE]                 = { nm = 17158202, zone = xi.zone.RUHOTZ_SILVERMINES, pos = {  -20.541,  0.000,  249.768,  60 } },
    [xi.sandworm.fight.LAMBTON_WORM_RUHOTZ]    = { nm = 17158203, zone = xi.zone.RUHOTZ_SILVERMINES, pos = {  347.866,  0.000, -460.499, 100 } },
}

-- Each zone's own fight comes up 70% of the time, its Lambton Worm the rest.
local zoneFights =
{
    [xi.zone.EAST_RONFAURE_S]         = { xi.sandworm.fight.KING_ARTHRO, xi.sandworm.fight.LAMBTON_WORM_EVERBLOOM },
    [xi.zone.BATALLIA_DOWNS_S]        = { xi.sandworm.fight.KING_ARTHRO, xi.sandworm.fight.LAMBTON_WORM_EVERBLOOM },
    [xi.zone.WEST_SARUTABARUTA_S]     = { xi.sandworm.fight.SERKET,      xi.sandworm.fight.LAMBTON_WORM_GHOYU     },
    [xi.zone.MERIPHATAUD_MOUNTAINS_S] = { xi.sandworm.fight.SERKET,      xi.sandworm.fight.LAMBTON_WORM_GHOYU     },
    [xi.zone.SAUROMUGUE_CHAMPAIGN_S]  = { xi.sandworm.fight.SERKET,      xi.sandworm.fight.LAMBTON_WORM_GHOYU     },
    [xi.zone.NORTH_GUSTABERG_S]       = { xi.sandworm.fight.GUIVRE,      xi.sandworm.fight.LAMBTON_WORM_RUHOTZ    },
    [xi.zone.ROLANBERRY_FIELDS_S]     = { xi.sandworm.fight.GUIVRE,      xi.sandworm.fight.LAMBTON_WORM_RUHOTZ    },
}

xi.sandworm.pickDoomvoidFight = function(mob)
    local options = zoneFights[mob:getZoneID()]
    if not options then
        return
    end

    mob:setLocalVar('doomvoidFight', math.random(10) <= 7 and options[1] or options[2])
end

xi.sandworm.doomvoid = function(mob, target)
    local fight = fights[mob:getLocalVar('doomvoidFight')]
    if not fight then
        return
    end

    local nm = GetMobByID(fight.nm)
    if nm and not nm:isSpawned() then
        SpawnMob(fight.nm)
    end

    local leader = target
    if not leader:isPC() and leader:getMaster() then
        leader = leader:getMaster()
    end

    if leader:isPC() then
        for _, member in ipairs(leader:getAlliance()) do
            if member:getZoneID() == mob:getZoneID() then
                member:setPos(fight.pos[1], fight.pos[2], fight.pos[3], fight.pos[4], fight.zone)
            end
        end
    end

    DespawnMob(mob:getID())
end
