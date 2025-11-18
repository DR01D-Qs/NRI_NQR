core:import("CoreMissionScriptElement")

ElementPointOfNoReturn = ElementPointOfNoReturn or class(CoreMissionScriptElement.MissionScriptElement)

function ElementPointOfNoReturn:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local job = Global.level_data and Global.level_data.level_id
  local lookup = {
        escape_cafe = 3,
        escape_cafe_day = 3,
        escape_park = 3,
        escape_park_day = 3,
        escape_overpass = 3,
        escape_overpass_night = 3,
        escape_street = 3,
        escape_garage = 3,
        cage = 5,
        sand = 1.4,
        run = 0.5,
        bph = 1.5,
        roberts = 2,

        oil_rig_will_explode = 1.5,
     }
  local lookup_acc = {
		nmh = { func_point_no_return_001 = 1.2, point_no_return_065 = 0.5 },
		trai = { func_point_no_return = 4, func_point_no_return_escape = 4 },
	}

	for i, k in pairs(self._values) do
        if string.find(i, "time_") then
			self._values[i] = self._values[i] * (lookup[job] or (lookup_acc[job] and lookup_acc[job][self._values._editor_name]) or 1)
		end
    end

	self:operation_add()
	ElementPointOfNoReturn.super.on_executed(self, instigator)
end