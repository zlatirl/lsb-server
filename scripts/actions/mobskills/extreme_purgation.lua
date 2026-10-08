-----------------------------------
-- Extreme Purgation
-- Family: Sandworm
-- Description: Absorbs all dispelable effects from targets in an area of effect.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

local maxEffectsToSteal = 20

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local stolenCount = 0

    if not target:isUndead() then
        for i = 1, maxEffectsToSteal do
            if mob:stealStatusEffect(target, xi.effectFlag.DISPELABLE) == 0 then
                break
            end

            stolenCount = i
        end
    end

    if stolenCount > 0 then
        skill:setMsg(xi.msg.basic.EFFECT_DRAINED)
    else
        skill:setMsg(xi.msg.basic.SKILL_NO_EFFECT)
    end

    return stolenCount
end

return mobskillObject
