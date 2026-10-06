#include "common/timer.h"
#include "map/entities/mob_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/lua/luautils.h"
#include "map/utils/moduleutils.h"

class EraEventsModule : public CPPModule
{
    void OnInit() override
    {
        TracyZoneScoped;

        // Use the global ::lua, not the CPPModule::lua member: modules are constructed during
        // static init, before the global state reference is bound, so the member can be dangling.

        // mob:getSpawnType()
        ::lua["CBaseEntity"]["getSpawnType"] = [](CLuaBaseEntity* PLuaBaseEntity) -> uint16
        {
            if (auto* PMob = dynamic_cast<CMobEntity*>(PLuaBaseEntity->GetBaseEntity()))
            {
                return static_cast<uint16>(PMob->m_SpawnType);
            }

            return 0;
        };

        // mob:getRespawnInterval()
        ::lua["CBaseEntity"]["getRespawnInterval"] = [](CLuaBaseEntity* PLuaBaseEntity) -> uint32
        {
            if (auto* PMob = dynamic_cast<CMobEntity*>(PLuaBaseEntity->GetBaseEntity()); PMob && PMob->m_AllowRespawn)
            {
                return static_cast<uint32>(timer::count_seconds(PMob->m_RespawnTime));
            }

            return 0;
        };
    }
};

REGISTER_CPP_MODULE(EraEventsModule);
