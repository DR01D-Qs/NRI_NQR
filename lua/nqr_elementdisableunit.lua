core:import("CoreMissionScriptElement")

ElementDisableUnit = ElementDisableUnit or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDisableUnit:init(...)
	ElementDisableUnit.super.init(self, ...)

	self._units = {}



    local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		hox_1 = {
			func_disable_unit_011 = true,
			func_disable_unit_012 = true,
			func_disable_unit_013 = true,
			func_disable_unit_014 = true,
		},
	}
	self._values.execute_on_startup = lookup[job] and lookup[job][self._editor_name] or self._values.execute_on_startup
end