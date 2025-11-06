--INJECTING NEW INTERACTION TIME OVERRIDES
function ElementInteraction:init(...)
	ElementInteraction.super.init(self, ...)

	if Network:is_server() then
		local host_only = self:value("host_only")

		if host_only then
			self._unit = CoreUnit.safe_spawn_unit("units/dev_tools/mission_elements/point_interaction/interaction_dummy_nosync", self._values.position, self._values.rotation)
		else
			self._unit = CoreUnit.safe_spawn_unit("units/dev_tools/mission_elements/point_interaction/interaction_dummy", self._values.position, self._values.rotation)
		end

		if self._unit then
			self._unit:interaction():set_host_only(host_only)
			self._unit:interaction():set_active(false)
			self._unit:interaction():set_mission_element(self)
			self._unit:interaction():set_tweak_data(self._values.tweak_data_id)

			if self._values.override_timer ~= -1 then
                local nqr_overrides = {
                    exit_to_crimenet = 3
                }
				self._unit:interaction():set_override_timer_value(nqr_overrides[self._values.tweak_data_id] or self._values.override_timer)
			end
		end
	end
end