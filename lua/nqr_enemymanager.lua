local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis_sq = mvector3.distance_sq
local t_rem = table.remove
local t_ins = table.insert
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
function EnemyManager:_update_gfx_lod()
	if self._gfx_lod_data.enabled and managers.navigation:is_data_ready() then
		local camera_rot = managers.viewport:get_current_camera_rotation()

		if camera_rot then
			local pl_tracker, cam_pos = nil
			local pl_fwd = camera_rot:y()
			local player = managers.player:player_unit()

			if player then
				pl_tracker = player:movement():nav_tracker()
				cam_pos = player:movement():m_head_pos()
			else
				pl_tracker = false
				cam_pos = managers.viewport:get_current_camera_position()
			end

			local entries = self._gfx_lod_data.entries
			local units = entries.units
			local states = entries.states
			local move_ext = entries.move_ext
			local trackers = entries.trackers
			local com = entries.com
			local chk_vis_func = pl_tracker and pl_tracker.check_visibility
			local unit_occluded = Unit.occluded
			local occ_skip_units = managers.occlusion._skip_occlusion
			local world_in_view_with_options = World.in_view_with_options

			for i, state in ipairs(states) do
				if not state and alive(units[i]) and (occ_skip_units[units[i]:key()] or (not pl_tracker or chk_vis_func(pl_tracker, trackers[i])) and not unit_occluded(units[i])) and world_in_view_with_options(World, com[i], 0, 110, 18000) then
					states[i] = 1

					units[i]:base():set_visibility_state(1)
				end
			end

			if #states > 0 then
				local anim_lod = managers.user:get_setting("video_animation_lod")
				local nr_lod_1 = self._nr_i_lod[anim_lod][1]
				local nr_lod_2 = self._nr_i_lod[anim_lod][2]
				local nr_lod_total = nr_lod_1 + nr_lod_2
				local imp_i_list = self._gfx_lod_data.prio_i
				local imp_wgt_list = self._gfx_lod_data.prio_weights
				local nr_entries = #states
				local i = self._gfx_lod_data.next_chk_prio_i

				if nr_entries < i then
					i = 1
				end

				local start_i = i

				repeat
					if states[i] and alive(units[i]) then
						if not occ_skip_units[units[i]:key()] and (pl_tracker and not chk_vis_func(pl_tracker, trackers[i]) or unit_occluded(units[i])) then
							states[i] = false

							units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						elseif not world_in_view_with_options(World, com[i], 0, 120, 18000) then
							states[i] = false

							--units[i]:base():set_visibility_state(false)
							self:_remove_i_from_lod_prio(i, anim_lod)

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						else
							local my_wgt = mvec3_dir(tmp_vec1, cam_pos, com[i])
							local dot = mvec3_dot(tmp_vec1, pl_fwd)
							local previous_prio = nil

							for prio, i_entry in ipairs(imp_i_list) do
								if i == i_entry then
									previous_prio = prio

									break
								end
							end

							my_wgt = my_wgt * my_wgt * (1 - dot)
							local i_wgt = #imp_wgt_list

							while i_wgt > 0 do
								if previous_prio ~= i_wgt and imp_wgt_list[i_wgt] <= my_wgt then
									break
								end

								i_wgt = i_wgt - 1
							end

							if not previous_prio or i_wgt <= previous_prio then
								i_wgt = i_wgt + 1
							end

							if i_wgt ~= previous_prio then
								if previous_prio then
									t_rem(imp_i_list, previous_prio)
									t_rem(imp_wgt_list, previous_prio)

									if previous_prio <= nr_lod_1 and nr_lod_1 < i_wgt and nr_lod_1 <= #imp_i_list then
										local promote_i = imp_i_list[nr_lod_1]
										states[promote_i] = 1

										units[promote_i]:base():set_visibility_state(1)
									elseif nr_lod_1 < previous_prio and i_wgt <= nr_lod_1 then
										local denote_i = imp_i_list[nr_lod_1]
										states[denote_i] = 2

										units[denote_i]:base():set_visibility_state(2)
									end
								elseif i_wgt <= nr_lod_total and #imp_i_list == nr_lod_total then
									local kick_i = imp_i_list[nr_lod_total]
									states[kick_i] = 3

									units[kick_i]:base():set_visibility_state(3)
									t_rem(imp_wgt_list)
									t_rem(imp_i_list)
								end

								local lod_stage = nil

								if i_wgt <= nr_lod_total then
									t_ins(imp_wgt_list, i_wgt, my_wgt)
									t_ins(imp_i_list, i_wgt, i)

									lod_stage = i_wgt <= nr_lod_1 and 1 or 2
								else
									lod_stage = 3

									self:_remove_i_from_lod_prio(i, anim_lod)
								end

								if states[i] ~= lod_stage then
									states[i] = lod_stage

									units[i]:base():set_visibility_state(lod_stage)
								end
							end

							self._gfx_lod_data.next_chk_prio_i = i + 1

							break
						end
					end

					if i == nr_entries then
						i = 1
					else
						i = i + 1
					end
				until i == start_i
			end
		end
	end
end



function EnemyManager:corpse_limit()
	local limit = self._MAX_NR_CORPSES
	limit = managers.mutators:modify_value("EnemyManager:corpse_limit", limit)

	return limit
end

function EnemyManager:_upd_corpse_disposal()
	self._corpse_disposal_id = nil
	local enemy_data = self._enemy_data
	local player = managers.player:player_unit()
	local cam_pos, cam_fwd = nil

	if player then
		cam_pos = player:movement():m_head_pos()
		cam_fwd = player:camera():forward()
	elseif managers.viewport:get_current_camera() then
		cam_pos = managers.viewport:get_current_camera_position()
		cam_fwd = managers.viewport:get_current_camera_rotation():y()
	end

	local corpses = enemy_data.corpses
	local nr_corpses = enemy_data.nr_corpses
	local disposals_needed = nr_corpses - self:corpse_limit()
	local to_dispose = {}
	local nr_found = 0

	if cam_pos then
		local min_dis = 4000000
		local dot_chk = 0
		local dir_vec = tmp_vec1

		for u_key, u_data in pairs(corpses) do
			if not u_data.no_dispose then
				local u_pos = u_data.m_pos

				if min_dis < mvec3_dis_sq(cam_pos, u_pos) then
					mvec3_dir(dir_vec, cam_pos, u_pos)

					if mvec3_dot(cam_fwd, dir_vec) < dot_chk then
						to_dispose[u_key] = true
						nr_found = nr_found + 1

						if nr_found == disposals_needed then
							break
						end
					end
				end
			end
		end
	end

	disposals_needed = disposals_needed - nr_found

	if disposals_needed > 0 then
		local oldest_corpses = {}

		for u_key, u_data in pairs(corpses) do
			if not u_data.no_dispose and not to_dispose[u_key] then
				local death_t = u_data.death_t

				for i = disposals_needed, 1, -1 do
					local old_corpse = oldest_corpses[i]

					if not old_corpse then
						old_corpse = {
							t = death_t,
							key = u_key
						}
						oldest_corpses[#oldest_corpses + 1] = old_corpse

						break
					elseif death_t < old_corpse.t then
						old_corpse.t = death_t
						old_corpse.key = u_key

						break
					end
				end
			end
		end

		for i = 1, disposals_needed do
			to_dispose[oldest_corpses[i].key] = true
		end

		nr_found = nr_found + disposals_needed
	end

	local is_server = Network:is_server()

	for u_key, _ in pairs(to_dispose) do
		local unit = corpses[u_key].unit
		corpses[u_key] = nil

		if is_server or unit:id() == -1 then
			unit:base():set_slot(unit, 0)
		else
			unit:set_enabled(false)
		end
	end

	enemy_data.nr_corpses = nr_corpses - nr_found
end