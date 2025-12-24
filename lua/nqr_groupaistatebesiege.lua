function GroupAIStateBase:set_enemy_assigned(area, unit_key)
	local u_data = self._police[unit_key]

	if u_data.assigned_area then
		u_data.assigned_area.police.units[unit_key] = nil
	end

	if area then
		area.police.units[unit_key] = u_data
		u_data.assigned_area = area
	else
		u_data.assigned_area = nil
	end
end



function GroupAIStateBesiege:_perform_group_spawning(spawn_task, force, use_last)
	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts

	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned and not force then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()

		for _, sp_data in ipairs(spawn_points) do
			local category = group_ai_tweak.unit_categories[u_type_name]

			if (sp_data.accessibility == "any" or category.access[sp_data.accessibility]) and (not sp_data.amount or sp_data.amount > 0) and sp_data.mission_element:enabled() then
				hopeless = false

				if sp_data.delay_t < self._t then
					local units = category.unit_types[current_unit_type]
					produce_data.name = units[math.random(#units)]
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

						if not objective then
							spawned_unit:set_slot(0)

							return true
						end

						objective.grp_objective = spawn_task.group.objective
					end

					local u_data = self._police[u_key]

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end

					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						if spawn_task.ai_task.phase=="build" or spawn_task.ai_task.phase=="sustain" then
							spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
						end
						spawned_unit:brain()._logic_data.spawned_in_phase = spawn_task.ai_task.phase
					end

					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true

		table.remove(self._spawning_groups, use_last and #self._spawning_groups or 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end



function GroupAIStateBesiege:set_wave_mode(flag)
	local old_wave_mode = self._wave_mode
	self._wave_mode = flag
	self._hunt_mode = nil
	local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		peta2 = {},
	}

	if flag == "hunt" then
		if lookup[job] then return end

		self._hunt_mode = true
		self._wave_mode = "besiege"

		managers.hud:start_assault(self._assault_number)
		self:_set_rescue_state(false)
		self:set_assault_mode(true)
		managers.trade:set_trade_countdown(false)
		self:_end_regroup_task()

		if self._task_data.assault.active then
			self._task_data.assault.phase = "sustain"
			self._task_data.use_smoke = true
			self._task_data.use_smoke_timer = 0
		else
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "besiege" then
		if self._task_data.regroup.active then
			self._task_data.assault.next_dispatch_t = self._task_data.regroup.end_t
		elseif not self._task_data.assault.active then
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "quiet" then
		self._hunt_mode = nil
	else
		self._wave_mode = old_wave_mode

		debug_pause("[GroupAIStateBesiege:set_wave_mode] flag", flag, " does not apply to the current Group AI state.")
	end
end



--WINTERS SPAWN CONDITION
function GroupAIStateBesiege:_check_spawn_phalanx()
	local nr_players = 0
	for u_key, u_data in pairs(self:all_player_criminals()) do
		if not u_data.status then nr_players = nr_players + 1 end
	end

	if nr_players>0 and not self._hunt_mode and self._phalanx_center_pos and self._task_data and self._task_data.assault.active and not self._phalanx_spawn_group and (self._task_data.assault.phase == "build" or self._task_data.assault.phase == "sustain") then
		local now = TimerManager:game():time()
		local respawn_delay = tweak_data.group_ai.phalanx.spawn_chance.respawn_delay

		if not self._phalanx_despawn_time or now >= self._phalanx_despawn_time + respawn_delay then
			local spawn_chance_start = tweak_data.group_ai.phalanx.spawn_chance.start
			self._phalanx_current_spawn_chance = self._phalanx_current_spawn_chance or spawn_chance_start
			self._phalanx_last_spawn_check = self._phalanx_last_spawn_check or now
			self._phalanx_last_chance_increase = self._phalanx_last_chance_increase or now
			local spawn_chance_increase = tweak_data.group_ai.phalanx.spawn_chance.increase
			local spawn_chance_max = tweak_data.group_ai.phalanx.spawn_chance.max

			if self._phalanx_current_spawn_chance < spawn_chance_max and spawn_chance_increase > 0 then
				local chance_increase_intervall = tweak_data.group_ai.phalanx.chance_increase_intervall

				if now >= self._phalanx_last_chance_increase + chance_increase_intervall then
					self._phalanx_last_chance_increase = now
					self._phalanx_current_spawn_chance = math.min(spawn_chance_max, self._phalanx_current_spawn_chance + spawn_chance_increase)
				end
			end

			if self._phalanx_current_spawn_chance > 0 then
				local check_spawn_intervall = tweak_data.group_ai.phalanx.check_spawn_intervall

				if now >= self._phalanx_last_spawn_check + check_spawn_intervall then
					self._phalanx_last_spawn_check = now

					if math.random() <= self._phalanx_current_spawn_chance then
						self:_spawn_phalanx()
					end
				end
			end
		end
	end
end

--JUST INFINITELY SPAM OCCASIONAL BUFF VOICELINES CUZ THEYRE NEAT
function GroupAIStateBesiege:_check_phalanx_damage_reduction_increase()
	local law1team = self:_get_law1_team()
	local damage_reduction_max = tweak_data.group_ai.phalanx.vip.damage_reduction.max

	if law1team.damage_reduction and math.random()<0.25 then
		local now = TimerManager:game():time()
		local increase_intervall = tweak_data.group_ai.phalanx.vip.damage_reduction.increase_intervall
		local last_increase = self._phalanx_damage_reduction_last_increase

		if now > last_increase + increase_intervall then
			last_increase = now

			self:set_phalanx_damage_reduction_buff(law1team.damage_reduction)

			self._phalanx_damage_reduction_last_increase = last_increase

			managers.game_play_central:announcer_say("cpw_a05")
		end
	end
end



function GroupAIStateBesiege:_upd_assault_task()
	local task_data = self._task_data.assault

	if not task_data.active then
		return
	end

	local t = self._t

	self:_assign_recon_groups_to_retire()

	local force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	local task_spawn_allowance = force_pool - (self._hunt_mode and 0 or task_data.force_spawned)

	if task_data.phase == "anticipation" then
		if task_data.phase_end_t < t or self._drama_data.zone == "high" then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)
			self:_set_rescue_state(false)

			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			task_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)

			if task_data.is_hesitating and task_data.voice_delay < self._t then
				if self._hostage_headcount > 0 then
					local best_group = nil

					for _, group in pairs(self._groups) do
						if not best_group or group.objective.type == "reenforce_area" then
							best_group = group
						elseif best_group.objective.type ~= "reenforce_area" and group.objective.type ~= "retire" then
							best_group = group
						end
					end

					if best_group and self:_voice_delay_assault(best_group) then
						task_data.is_hesitating = nil
					end
				else
					task_data.is_hesitating = nil
				end
			end
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t or self._drama_data.zone == "high" then
			local sustain_duration = math.lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math.random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul)

			managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)

			task_data.phase = "sustain"
			task_data.phase_end_t = t + sustain_duration
		end
	elseif task_data.phase == "sustain" then
		local end_t = self:assault_phase_end_time()
		task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

		if task_spawn_allowance <= 0 then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif end_t < t and not self._hunt_mode then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")

		if not self._hunt_mode then
			local enemies_defeated_time_limit = 120
			local drama_engagement_time_limit = 60

			if managers.skirmish:is_skirmish() then
				enemies_defeated_time_limit = 0
				drama_engagement_time_limit = 0
			end

			local min_enemies_left = 8
			local enemies_defeated = enemies_left < min_enemies_left
			local taking_too_long = t > task_data.phase_end_t + enemies_defeated_time_limit

			if enemies_defeated or taking_too_long then
				if not task_data.said_retreat then
					task_data.said_retreat = true

					self:_police_announce_retreat()
				elseif task_data.phase_end_t < t then
					local drama_pass = self._drama_data.amount < tweak_data.drama.assault_fade_end
					local engagement_pass = self:_count_criminals_engaged_force(11) <= 10
					local taking_too_long = t > task_data.phase_end_t + drama_engagement_time_limit

					if drama_pass and engagement_pass or taking_too_long then
						end_assault = true
					end
				end
			end

			if task_data.force_end or end_assault then
				print("assault task clear")

				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				local force_regroup = task_data.force_regroup
				task_data.force_regroup = nil

				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task(force_regroup)

				return
			end
		end
	end

	if self._drama_data.amount <= tweak_data.drama.low then
		for criminal_key, criminal_data in pairs(self._player_criminals) do
			self:criminal_spotted(criminal_data.unit)

			for group_id, group in pairs(self._groups) do
				if group.objective.charge then
					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
			end
		end
	end

	local primary_target_area = task_data.target_areas[1]

	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis = nil

		for criminal_key, criminal_data in pairs(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvector3.distance_sq(target_pos, criminal_data.m_pos)

				if not nearest_dis or dis < nearest_dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end

		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
	end

	local nr_wanted = task_data.force - self:_count_police_force("assault")

	if task_data.phase == "anticipation" then
		nr_wanted = nr_wanted - 5
	end

	if nr_wanted > 0 and task_data.phase ~= "fade" then
		local used_event = nil

		if task_data.use_spawn_event and task_data.phase ~= "anticipation" then
			task_data.use_spawn_event = false

			if self:_try_use_task_spawn_event(t, primary_target_area, "assault") then
				used_event = true
			end
		end

		if not used_event then
			if next(self._spawning_groups) then
				-- Nothing
			else
				self:_check_spawn_timed_groups(primary_target_area, task_data)

				local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, nil, nil, nil)

				if spawn_group then
					local grp_objective = {
						attitude = "avoid",
						stance = "hos",
						pose = "crouch",
						type = "assault_area",
						area = spawn_group.area,
						coarse_path = {
							{
								spawn_group.area.pos_nav_seg,
								spawn_group.area.pos
							}
						}
					}

					self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
				end
			end
		end
	end

	if task_data.phase ~= "anticipation" then
		if task_data.use_smoke_timer < t then
			task_data.use_smoke = true
		end

		self:detonate_queued_smoke_grenades()
	end

	self:_assign_enemy_groups_to_assault(task_data.phase)
end

local function make_dis_id(from, to)
	local f = from < to and from or to
	local t = to < from and from or to

	return tostring(f) .. "-" .. tostring(t)
end
local function spawn_group_id(spawn_group)
	return spawn_group.mission_element:id()
end
function GroupAIStateBesiege:_find_spawn_group_near_area(target_area, allowed_groups, target_pos, max_dis, verify_clbk)
	local all_areas = self._area_data
	local mvec3_dis = mvector3.distance_sq
	max_dis = max_dis and max_dis * max_dis
	local t = self._t
	local valid_spawn_groups = {}
	local valid_spawn_group_distances = {}
	local total_dis = 0
	target_pos = target_pos or target_area.pos
	local to_search_areas = {
		target_area
	}
	local found_areas = {
		[target_area.id] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)
		local spawn_groups = search_area.spawn_groups

		if spawn_groups then
			for _, spawn_group in ipairs(spawn_groups) do
				if spawn_group.delay_t <= t and (not verify_clbk or verify_clbk(spawn_group)) then
					local dis_id = make_dis_id(spawn_group.nav_seg, target_area.pos_nav_seg)

					if not self._graph_distance_cache[dis_id] then
						local coarse_params = {
							access_pos = "swat",
							from_seg = spawn_group.nav_seg,
							to_seg = target_area.pos_nav_seg,
							id = dis_id
						}
						local path = managers.navigation:search_coarse(coarse_params)

						if path and #path >= 2 then
							local dis = 0
							local current = spawn_group.pos

							for i = 2, #path do
								local nxt = path[i][2]

								if current and nxt then
									dis = dis + mvector3.distance(current, nxt)
								end

								current = nxt
							end

							self._graph_distance_cache[dis_id] = dis
						end
					end

					if self._graph_distance_cache[dis_id] then
						local my_dis = self._graph_distance_cache[dis_id]

						if not max_dis or my_dis < max_dis then
							total_dis = total_dis + my_dis
							valid_spawn_groups[spawn_group_id(spawn_group)] = spawn_group
							valid_spawn_group_distances[spawn_group_id(spawn_group)] = my_dis
						end
					end
				end
			end
		end

		for other_area_id, other_area in pairs(all_areas) do
			if not found_areas[other_area_id] and other_area.neighbours[search_area.id] then
				table.insert(to_search_areas, other_area)

				found_areas[other_area_id] = true
			end
		end
	until #to_search_areas == 0

	if not next(valid_spawn_group_distances) then
		return
	end

	local time = TimerManager:game():time()
	local timer_can_spawn = false

	for id in pairs(valid_spawn_groups) do
		if not self._spawn_group_timers[id] or self._spawn_group_timers[id] <= time then
			timer_can_spawn = true

			break
		end
	end

	if not timer_can_spawn then
		self._spawn_group_timers = {}
	end

	for id in pairs(valid_spawn_groups) do
		if self._spawn_group_timers[id] and time < self._spawn_group_timers[id] then
			valid_spawn_groups[id] = nil
			valid_spawn_group_distances[id] = nil
		end
	end

	if total_dis == 0 then
		total_dis = 1
	end

	local total_weight = 0
	local candidate_groups = {}
	self._debug_weights = {}
	local dis_limit = 5000

	for i, dis in pairs(valid_spawn_group_distances) do
		local my_wgt = math.lerp(1, 0.2, math.min(1, dis / dis_limit)) * 5
		local my_spawn_group = valid_spawn_groups[i]
		local my_group_types = my_spawn_group.mission_element:spawn_groups()
		if my_group_types and table.contains(my_group_types, "tac_swat_rifle_flank") then
			table.insert(my_group_types, 1, "tac_swat_shotgun_rush")
			table.insert(my_group_types, 1, "tac_swat_shotgun_flank")
			table.insert(my_group_types, 1, "tac_swat_rifle")
		end
		my_spawn_group.distance = dis
		total_weight = total_weight + self:_choose_best_groups(candidate_groups, my_spawn_group, my_group_types, allowed_groups, my_wgt)
	end

	if total_weight == 0 then
		return
	end

	for _, group in ipairs(candidate_groups) do
		table.insert(self._debug_weights, clone(group))
	end

	return self:_choose_best_group(candidate_groups, total_weight)
end

function GroupAIStateBesiege:_choose_best_groups(best_groups, group, group_types, allowed_groups, weight)
	local total_weight = 0

	for _, group_type in ipairs(group_types) do
		if tweak_data.group_ai.enemy_spawn_groups[group_type] then
			local cat_weights = allowed_groups[group_type]

			if cat_weights then
				local cat_weight = self:_get_difficulty_dependent_value(cat_weights)
				local mod_weight = weight * cat_weight

				table.insert(best_groups, {
					group = group,
					group_type = group_type,
					wght = mod_weight,
					cat_weight = cat_weight,
					dis_weight = weight
				})

				total_weight = total_weight + mod_weight
			end
		else
			debug_pause("[GroupAIStateBesiege:_choose_best_groups] inexistent spawn_group:", group_type, ". element id:", group.mission_element._id)
		end
	end

	return total_weight
end

function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)
	local spawn_group_desc = tweak_data.group_ai.enemy_spawn_groups[spawn_group_type]
	local wanted_nr_units = nil

	if type(spawn_group_desc.amount) == "number" then
		wanted_nr_units = spawn_group_desc.amount
	else
		wanted_nr_units = math.random(spawn_group_desc.amount[1], spawn_group_desc.amount[2])
	end

	local valid_unit_types = {}

	self._extract_group_desc_structure(spawn_group_desc.spawn, valid_unit_types)

	local unit_categories = tweak_data.group_ai.unit_categories
	local total_wgt = 0
	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		local cat_data = unit_categories[spawn_entry.unit]

		if not cat_data then
			debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

			return
		end

		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit < self:_get_special_unit_type_count(cat_data.special_type) + (spawn_entry.amount_min or 0) then
			spawn_group.delay_t = self._t + 10

			return
		else
			total_wgt = total_wgt + spawn_entry.freq
			i = i + 1
		end
	end

	for _, sp_data in ipairs(spawn_group.spawn_pts) do
		sp_data.delay_t = self._t + math.rand(0.5)
	end

	local spawn_task = {
		objective = not grp_objective.element and self._create_objective_from_group_objective(grp_objective),
		units_remaining = {},
		spawn_group = spawn_group,
		spawn_group_type = spawn_group_type,
		ai_task = ai_task
	}

	table.insert(self._spawning_groups, spawn_task)

	local function _add_unit_type_to_spawn_task(i, spawn_entry)
		local spawn_amount_mine = 1 + (spawn_task.units_remaining[spawn_entry.unit] and spawn_task.units_remaining[spawn_entry.unit].amount or 0)
		spawn_task.units_remaining[spawn_entry.unit] = {
			amount = spawn_amount_mine,
			spawn_entry = spawn_entry
		}
		wanted_nr_units = wanted_nr_units - 1

		if spawn_entry.amount_min then
			spawn_entry.amount_min = spawn_entry.amount_min - 1
		end

		if spawn_entry.amount_max then
			spawn_entry.amount_max = spawn_entry.amount_max - 1

			if spawn_entry.amount_max == 0 then
				table.remove(valid_unit_types, i)

				total_wgt = total_wgt - spawn_entry.freq

				return true
			end
		end
	end

	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]

		if i <= #valid_unit_types and wanted_nr_units > 0 and spawn_entry.amount_min and spawn_entry.amount_min > 0 and (not spawn_entry.amount_max or spawn_entry.amount_max > 0) then
			if not _add_unit_type_to_spawn_task(i, spawn_entry) then
				i = i + 1
			end
		else
			i = i + 1
		end
	end

	while wanted_nr_units > 0 and #valid_unit_types ~= 0 do
		local rand_wght = math.random() * total_wgt
		local rand_i = 1
		local rand_entry = nil

		repeat
			rand_entry = valid_unit_types[rand_i]
			rand_wght = rand_wght - rand_entry.freq

			if rand_wght <= 0 then
				break
			else
				rand_i = rand_i + 1
			end
		until false

		local cat_data = unit_categories[rand_entry.unit]
		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit <= self:_get_special_unit_type_count(cat_data.special_type) then
			table.remove(valid_unit_types, rand_i)

			total_wgt = total_wgt - rand_entry.freq
		else
			_add_unit_type_to_spawn_task(rand_i, rand_entry)
		end
	end

	local group_desc = {
		size = 0,
		type = spawn_group_type
	}

	for u_name, spawn_info in pairs(spawn_task.units_remaining) do
		group_desc.size = group_desc.size + spawn_info.amount
	end

	local group = self:_create_group(group_desc)
	group.objective = grp_objective
	group.objective.moving_out = true
	group.team = self._teams[spawn_group.team_id or tweak_data.levels:get_default_team_ID("combatant")]
	spawn_task.group = group

	return group
end