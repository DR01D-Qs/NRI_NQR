function TimerGui:start(timer)
	timer = self._override_timer or timer

	local job = Global.level_data and Global.level_data.level_id

	--Utils.PrintTable(self, 2)

    if self._jammed_tweak_data=="huge_lance_jammed" then timer = timer * 0.5 end

	local lookup = {
		nmh = {
			["Vector3(-1184, 1438.33, 119.743)"] = 90,

			["Vector3(-1016, 2028, 129.044)"] = 120,
			["Vector3(-1349, 2086, 128.571)"] = 120,
			["Vector3(-1016, 2556, 120.12)"] = 120,
		},
	}
	timer = (lookup[job] and lookup[job][tostring(self._unit:position())]) or timer

	if not self._started then
		self:_start(timer)

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_timer_gui", self._unit, timer)
		end
	end

	if not self._powered then
		self:set_powered(true)
	end

	if self._jammed then
		self:set_jammed(false)
	end
end