function MissionManager:_activate_mission(name)
	CoreDebug.cat_debug("gaspode", "MissionManager:_activate_mission", name)

	if name then
		if self:script(name) then
			self:activate_script(name)
		else
			Application:throw_exception("There was no mission named " .. name .. " availible to activate!")
		end
	else
		for _, script in pairs(self._scripts) do
			if script:activate_on_parsed() then
				self:activate_script(script:name())
			end
		end
	end



    local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		trai = {
			["9b2fcf39f23e2344"] = {
				["Vector3(-2900, 3725, 547.404)"] = true,
				["Vector3(-2900, 3725, 842.404)"] = true,
				["Vector3(-2900, 3725, 1141.4)"] = true,
				["Vector3(-3175, 3725, 547.404)"] = true,
				["Vector3(-3175, 3725, 842.404)"] = true,
				["Vector3(-3175, 3725, 1141.4)"] = true,

				["Vector3(-2900, 3525, 547.404)"] = true,
				["Vector3(-2900, 3525, 842.404)"] = true,
				["Vector3(-2900, 3525, 1141.4)"] = true,
				["Vector3(-3175, 3525, 547.404)"] = true,
				["Vector3(-3175, 3525, 842.404)"] = true,
				["Vector3(-3175, 3525, 1141.4)"] = true,
			},

			["4027cbad1f8d5b37"] = {
				["Vector3(-2900, 4100, 547.404)"] = true,
				["Vector3(-3000, 4100, 547.404)"] = true,
				["Vector3(-3075, 4100, 547.404)"] = true,
				["Vector3(-2900, 4100, 842.404)"] = true,
				["Vector3(-3000, 4100, 842.404)"] = true,
				["Vector3(-3075, 4100, 842.404)"] = true,
				["Vector3(-2900, 4100, 1141.4)"] = true,
				["Vector3(-3000, 4100, 1141.4)"] = true,
				["Vector3(-3075, 4100, 1141.4)"] = true,

				["Vector3(-2900, 3525, 547.404)"] = true,
				["Vector3(-3000, 3525, 547.404)"] = true,
				["Vector3(-3075, 3525, 547.404)"] = true,
				["Vector3(-2900, 3525, 842.404)"] = true,
				["Vector3(-3000, 3525, 842.404)"] = true,
				["Vector3(-3075, 3525, 842.404)"] = true,
				["Vector3(-2900, 3525, 1141.4)"] = true,
				["Vector3(-3000, 3525, 1141.4)"] = true,
				["Vector3(-3075, 3525, 1141.4)"] = true,
			},
		},
		dinner = {
			["e8fe662bb4d262d3"] = true,
		},
	}
	for i, k in pairs(World:find_units_quick("all", 1)) do
		if lookup[job] and lookup[job][k:name():key()] and (type(lookup[job][k:name():key()])~="table" or lookup[job][k:name():key()][tostring(k:position())]) then
			k:set_slot(0)
		end
	end

	local lookup_add = {
		big = {
			{
				unit = "units/dev_tools/level_tools/dev_collision_10m",
				pos = Vector3(-2822,250,-595),
			},
			{
				unit = "units/dev_tools/level_tools/dev_collision_10m",
				pos = Vector3(-2822,-250,-595),
			},
		},
	}
	for i, k in pairs(lookup_add[job] or {}) do
		local result_unit = World:spawn_unit(Idstring(k.unit), k.pos or Vector3(0,0,0), k.rot or Rotation(0,0,0))
		result_unit:set_visible(false)
	end
end



function MissionScriptElement:init(mission_script, data)
	self._mission_script = mission_script
	self._id = data.id
	self._editor_name = data.editor_name
	self._values = data.values



	local job = Global.level_data and Global.level_data.level_id
	lookup = {
		jolly = { ["Link - delay"] = { delay = 45 } },
	}
	if lookup[job] and lookup[job][self._editor_name] then
		for i, k in pairs(lookup[job][self._editor_name]) do
			self._values.on_executed[1][i] = k
		end
		--Utils.PrintTable(self._values, 3)
	end
end