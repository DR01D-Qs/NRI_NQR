core:module("CoreElementToggle")
core:import("CoreMissionScriptElement")

ElementToggle = ElementToggle or class(CoreMissionScriptElement.MissionScriptElement)

function ElementToggle:init(...)
	ElementToggle.super.init(self, ...)



    if not self._values then return end

    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        nail = { reset_ingredient_vo = 1, },
    }

    self._values.set_trigger_times = (lookup[job] and lookup[job][self._editor_name]) or self._values.set_trigger_times
end