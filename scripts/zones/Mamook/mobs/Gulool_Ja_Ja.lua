-----------------------------------
-- Area: Mamook
--  Mob: Gulool Ja Ja
-----------------------------------
local ID = zones[xi.zone.MAMOOK]
mixins =
{
    require('scripts/mixins/job_special'),
    require('scripts/mixins/draw_in'),
}
-----------------------------------
---@type TMobEntity
local entity = {}

local function despawnBodyguards()
    for i = ID.mob.GULOOL_JA_JA + 1, ID.mob.GULOOL_JA_JA + 4 do
        DespawnMob(i)
    end
end

entity.onMobInitialize = function(mob)
    mob:addListener('MAGIC_TAKE', 'GULOOL_JA_JA_MAGIC_TAKE', function(target, caster, spell)
        if
            spell and
            target:isAlive() and
            (caster:isPC() or caster:isPet()) and
            spell:getSpellGroup() ~= xi.magic.spellGroup.WHITE
        then
            target:useMobAbility(xi.mobSkill.VORPAL_WHEEL, caster)
        end
    end)
end

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.DOUBLE_ATTACK, 20)
    mob:setMod(xi.mod.DEF, 400)
    mob:setMod(xi.mod.MEVA, 300)
    mob:setMod(xi.mod.MDEF, 50)
end

entity.onMobEngage = function(mob, target)
    for i = ID.mob.GULOOL_JA_JA + 1, ID.mob.GULOOL_JA_JA + 4 do
        SpawnMob(i):updateEnmity(target)
    end
end

entity.onMobFight = function(mob, target)
    for i = ID.mob.GULOOL_JA_JA + 1, ID.mob.GULOOL_JA_JA + 4 do
        local pet = GetMobByID(i)
        if pet and pet:getCurrentAction() == xi.action.category.ROAMING then
            pet:updateEnmity(target)
        end
    end

    if mob:getBattleTime() % 60 < 2 and mob:getBattleTime() > 10 then
        for i = ID.mob.GULOOL_JA_JA + 1, ID.mob.GULOOL_JA_JA + 4 do
            local bodyguard = GetMobByID(i)
            if bodyguard and not bodyguard:isSpawned() then
                bodyguard:setSpawn(mob:getXPos() + math.randomInt(1, 5), mob:getYPos(), mob:getZPos() + math.randomInt(1, 5))
                SpawnMob(i):updateEnmity(target)
                break
            end
        end
    end
end

entity.onMobMobskillChoose = function(mob, target)
    local tpMoves =
    {
        xi.mobSkill.RUSHING_SLASH,
        xi.mobSkill.TYRANNIC_BLARE,
        xi.mobSkill.MIASMA,
        xi.mobSkill.VORPAL_WHEEL,
    }

    if mob:getHPP() <= 20 then
        table.insert(tpMoves, xi.mobSkill.DECUSSATE)
    end

    return tpMoves[math.randomInt(1, #tpMoves)]
end

entity.onMobDisengage = function(mob)
    despawnBodyguards()
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.SHINING_SCALE_RIFLER)
    end

    if optParams.isKiller or optParams.noKiller then
        despawnBodyguards()
    end
end

entity.onMobDespawn = function(mob)
    despawnBodyguards()
end

return entity
