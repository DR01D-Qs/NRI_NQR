function ContourExt:add(type, sync, multiplier, override_color, is_element)
	self._contour_list = self._contour_list or {}
	local data = self._types[type]
	local fadeout = data.fadeout
	local multiplier = data.color==tweak_data.contour.character.dangerous_color and (multiplier or 0.15) or multiplier

	if data.fadeout_silent and managers.groupai:state():whisper_mode() then
		fadeout = data.fadeout_silent
	end

	if fadeout and multiplier then
		fadeout = fadeout * multiplier
	end

	sync = sync and not self._is_child_contour or false

	if sync then
		local sync_unit = self._unit
		local u_id = self._unit:id()

		if u_id == -1 then
			sync_unit, u_id = nil
			local corpse_data = managers.enemy:get_corpse_unit_data_from_key(self._unit:key())

			if corpse_data then
				u_id = corpse_data.u_id
			end
		end

		if u_id then
			managers.network:session():send_to_peers_synched("sync_contour_add", sync_unit, u_id, table.index_of(ContourExt.indexed_types, type), multiplier or 1)
		else
			sync = nil

			Application:error("[ContourExt:add] Unit isn't network-synced and isn't a registered corpse, can't sync. ", self._unit)
		end
	end

	for _, setup in ipairs(self._contour_list) do
		if setup.type == type then
			if fadeout then
				setup.fadeout_t = TimerManager:game():time() + fadeout
			elseif not setup.data.unique then
				setup.ref_c = setup.ref_c + 1
			end

			if is_element then
				setup.ref_c_element = (setup.ref_c_element or 0) + 1
			end

			local old_color = setup.color or data.color
			setup.color = override_color or nil

			if old_color ~= override_color then
				self:_upd_color()
			end

			return setup
		end
	end

	if not self._removed_occlusion then
		self._removed_occlusion = true

		managers.occlusion:remove_occlusion(self._unit)
	end

	local setup = {
		ref_c = 1,
		type = type,
		ref_c_element = is_element and 1 or nil,
		sync = sync,
		fadeout_t = fadeout and TimerManager:game():time() + fadeout or nil,
		color = override_color or nil,
		data = data
	}

	if data.ray_check then
		setup.upd_skip_count = ContourExt.raycast_update_skip_count
		local mov_ext = self._unit:movement()

		if mov_ext and mov_ext.m_com then
			setup.ray_pos = mov_ext:m_com()
		end
	end

	local i = 1
	local contour_list = self._contour_list
	local old_preset_type = contour_list[1] and contour_list[1].type

	while contour_list[i] and contour_list[i].data.priority <= data.priority do
		i = i + 1
	end

	table.insert(contour_list, i, setup)

	if not old_preset_type or i == 1 and old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	if data.damage_bonus or data.damage_bonus_distance then
		self:_chk_damage_bonuses()
	end

	if data.trigger_marked_event then
		self:_chk_mission_marked_events(setup)
	end

	self:apply_to_linked("add", type, false, multiplier, override_color)

	return setup
end
