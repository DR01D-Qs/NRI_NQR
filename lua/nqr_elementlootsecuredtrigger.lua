core:import("CoreMissionScriptElement")

ElementLootSecuredTrigger = ElementLootSecuredTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementLootSecuredTrigger:init(...)
	ElementLootSecuredTrigger.super.init(self, ...)

    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        four_stores = { trigger_loot_secured_007 = 150000 },
    }
    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end
