-----------------------------------
-- Doomvoid
-- Family: Sandworm
-- Description: Players are drawn-in and swallowed whole, transporting them to an underground area.
-- Notes: Used below 40% HP. Destinations and the fight roll live in scripts/globals/sandworm.lua.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    if mob:getHPP() <= xi.sandworm.doomvoidHpp then
        return 0
    end

    return 1
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    xi.sandworm.doomvoid(mob, target)
    skill:setMsg(xi.msg.basic.NONE)

    return 0
end

return mobskillObject
