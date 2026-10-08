-----------------------------------
-- Desiccation
-- Family: Sandworm
-- Description: Puts all Job Abilities of targets in front of the mob on their full recast.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    if target:isPC() then
        target:maxAbilityRecasts()
    end

    skill:setMsg(xi.msg.basic.USES)

    return 0
end

return mobskillObject
