core:import("CoreMissionScriptElement")

ElementMandatoryBags = ElementMandatoryBags or class(CoreMissionScriptElement.MissionScriptElement)

function ElementMandatoryBags:init(...)
	ElementMandatoryBags.super.init(self, ...)



    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        family = { func_mandatory_bags_003 = 4, func_mandatory_bags_002 = 4, func_mandatory_bags_001 = 2 },
        jewelry_store = { func_mandatory_bags_003 = 6, func_mandatory_bags_002 = 6, func_mandatory_bags_001 = 3 },
    }

    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end