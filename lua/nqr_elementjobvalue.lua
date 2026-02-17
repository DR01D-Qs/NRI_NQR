core:import("CoreMissionScriptElement")

ElementJobValue = ElementJobValue or class(CoreMissionScriptElement.MissionScriptElement)

function ElementJobValue:init(...)
	ElementJobValue.super.init(self, ...)



    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        family = { func_job_value_003 = 4, func_job_value_002 = 4, func_job_value_001 = 2 },
        jewelry_store = { func_job_value_003 = 6, func_job_value_002 = 6, func_job_value_001 = 3 },
    }

    self._values.value = (lookup[job] and lookup[job][self._editor_name]) or self._values.value
end