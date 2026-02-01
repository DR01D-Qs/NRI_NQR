--OVK_PLS: CHECK PHALANX BREAKUP BEFORE ITS ASSEMBLY, BREAKUP VOICELINE
function GroupAIStateBase:on_enemy_unregistered(unit)
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	if string.find(unit:base()._tweak_table, "phalanx")
	and self._phalanx_spawn_group and self._phalanx_spawn_group.has_spawned
	and table.size(self._phalanx_spawn_group.units or {})<=1
	then
		managers.game_play_central:announcer_say("cpw_a04")
		managers.groupai:state():force_end_assault_phase()
		self:phalanx_despawned()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table

	if self._special_unit_types[unit_type] then
		self:unregister_special_unit(u_key, unit_type)
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
	end

	if e_data.assigned_area and dead then
		local spawn_point = unit:unit_data().mission_element

		if spawn_point then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 700 and math.abs(spawn_pos.z - u_pos.z) < 300 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end



--DONT DO GAMEOVER UNTIL EVERYONE IS IN CUSTODY
function GroupAIStateBase:check_gameover_conditions()
	if not Network:is_server() or managers.platform:presence() ~= "Playing" or setup:has_queued_exec() then
		return false
	end

	if game_state_machine:current_state().game_ended and game_state_machine:current_state():game_ended() then
		return false
	end

	if Global.load_start_menu or Application:editor() then
		return false
	end

	if not self:whisper_mode() and self._super_syndrome_peers and self:hostage_count() > 0 then
		for _, active in pairs(self._super_syndrome_peers) do
			if active then
				return false
			end
		end
	end

	local plrs_alive = false
	local plrs_disabled = true --true

	for u_key, u_data in pairs(self._player_criminals) do
		plrs_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			plrs_disabled = false

			break
		end
	end

	local ai_alive = false
	local ai_disabled = true

	for u_key, u_data in pairs(self._ai_criminals) do
		ai_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			ai_disabled = false

			break
		end
	end

	local gameover = false

	if not plrs_alive and not self:is_ai_trade_possible() then
		gameover = true
	elseif plrs_disabled and not ai_alive then
		gameover = true
	elseif plrs_disabled and ai_disabled then
		gameover = true
	end

	gameover = gameover or managers.skirmish:check_gameover_conditions()

	if gameover then
		if not self._gameover_clbk then
			self._gameover_clbk = callback(self, self, "_gameover_clbk_func")

			managers.enemy:add_delayed_clbk("_gameover_clbk", self._gameover_clbk, Application:time() + 3)
		end
	elseif self._gameover_clbk then
		managers.enemy:remove_delayed_clbk("_gameover_clbk")

		self._gameover_clbk = nil
	end

	return gameover
end



function GroupAIStateBase:_coach_last_man_clbk()
	if table.size(self:all_char_criminals()) == 1 and self:bain_state() and #(managers.trade and managers.trade._criminals_to_respawn or {})>0 then
		managers.dialog:queue_narrator_dialog(self:hostage_count()<=0 and "h40" or "h42", {})
	end
end



function GroupAIStateBase:_get_balancing_multiplier(balance_multipliers)
	local nr_players = 0

	for u_key, u_data in pairs(self:all_player_criminals()) do
		if not u_data.status then
			nr_players = nr_players + 1
		end
	end

	local nr_ai = 0

	for u_key, u_data in pairs(self:all_AI_criminals()) do
		if not u_data.status then
			nr_ai = nr_ai + 1
		end
	end

	nr_players = nr_players + nr_ai
	nr_players = math.clamp(nr_players, 1, 4)

	return balance_multipliers[nr_players]
end



function GroupAIStateBase:spawn_one_teamAI(is_drop_in, char_name, pos, rotation, start)
	local job = Global.level_data and Global.level_data.level_id
	if not managers.groupai:state():team_ai_enabled() or not self._ai_enabled or not managers.criminals:character_taken_by_name(char_name) and (job=="short2_stage2b" and 2 or 1) <= managers.criminals:nr_AI_criminals() then
		return
	end

	local objective = self:_determine_spawn_objective_for_criminal_AI()

	if objective and objective.type == "follow" then
		local player = objective.follow_unit
		local player_pos = pos or player:position()
		local tracker = player:movement():nav_tracker()
		local spawn_pos = player_pos
		local spawn_rot = nil

		if is_drop_in and not self:whisper_mode() then
			local spawn_fwd = player:movement():m_head_rot():y()

			mvector3.set_z(spawn_fwd, 0)
			mvector3.normalize(spawn_fwd)

			spawn_rot = Rotation(spawn_fwd, math.UP)
			spawn_pos = player_pos

			if not tracker:lost() then
				local search_pos = player_pos - spawn_fwd * 200
				local ray_params = {
					allow_entry = false,
					trace = true,
					tracker_from = tracker,
					pos_to = search_pos
				}
				local ray_hit = managers.navigation:raycast(ray_params)

				if ray_hit then
					spawn_pos = ray_params.trace[1]
				else
					spawn_pos = search_pos
				end
			end
		else
			if start or self:whisper_mode() then
				local spawn_point = managers.network:session():get_next_spawn_point()
				spawn_pos = spawn_point.pos_rot[1]
				spawn_rot = spawn_point.pos_rot[2]
			else
				spawn_pos = player_pos
				spawn_rot = rotation
			end

			objective.in_place = true
		end

		local visual_seed = CriminalsManager.get_new_visual_seed()
		local team_id = tweak_data.levels:get_default_team_ID("player")
		local character_name = char_name or managers.criminals:get_free_character_name()
		local ai_character_id = managers.criminals:character_static_data_by_name(character_name).ai_character_id
		local unit_name = Idstring(tweak_data.blackmarket.characters[ai_character_id].npc_unit)
		local loadout = managers.criminals:_reserve_loadout_for(character_name)
		local unit = World:spawn_unit(unit_name, spawn_pos, spawn_rot)

		self:set_unit_teamAI(unit, character_name, team_id, visual_seed, loadout)
		managers.network:session():send_to_peers_synched("set_unit", unit, character_name, managers.blackmarket:henchman_loadout_string_from_loadout(loadout), 0, 0, tweak_data.levels:get_default_team_ID("player"), visual_seed)
		unit:brain():set_spawn_ai({
			init_state = "idle",
			params = {
				scan = true
			},
			objective = objective
		})

		if player:movement():current_state_name() == "driving" then
			local peer_id = managers.network:session():peer_by_unit(player):id()
			local vehicle_data = managers.player:get_vehicle_for_peer(peer_id)
			local vehicle_unit = vehicle_data and vehicle_data.vehicle_unit
			local vehicle_ext = alive(vehicle_unit) and vehicle_unit:vehicle_driving()

			vehicle_ext:place_team_ai_in_vehicle(unit)
		end

		return unit
	end
end



function GroupAIStateBase:hostage_killed(killer_unit)
	if not alive(killer_unit) then
		return
	end

	if killer_unit:base() and killer_unit:base().thrower_unit then
		killer_unit = killer_unit:base():thrower_unit()

		if not alive(killer_unit) then
			return
		end
	end

	local key = killer_unit:key()
	local criminal = self._criminals[key]

	if not criminal then
		return
	end

	self._hostages_killed = (self._hostages_killed or 0) + 1

	if not self._hunt_mode then
		if self._hostages_killed >= 1 and not self._hostage_killed_warning_lines then
			if self:sync_hostage_killed_warning(1) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 1)

				self._hostage_killed_warning_lines = 1
			end
		elseif self._hostages_killed >= 3 and self._hostage_killed_warning_lines == 1 then
			if self:sync_hostage_killed_warning(2) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 2)

				self._hostage_killed_warning_lines = 2
			end
		elseif self._hostages_killed >= 7 and self._hostage_killed_warning_lines == 2 and self:sync_hostage_killed_warning(3) then
			managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 3)

			self._hostage_killed_warning_lines = 3
		end
	end

	if not criminal.is_deployable then
		local tweak = tweak_data.player.damage

		--[[if killer_unit:base().is_local_player or killer_unit:base().is_husk_player then
			tweak = tweak_data.player.damage
		else
			tweak = tweak_data.character[killer_unit:base()._tweak_table].damage
		end]]

		local base_delay = tweak.base_respawn_time_penalty
		local respawn_penalty = criminal.respawn_penalty or (40 + self._tweak_data.assault.delay[3])
		criminal.respawn_penalty = respawn_penalty + tweak.respawn_time_penalty
		criminal.hostages_killed = (criminal.hostages_killed or 0) + 1
	end
end

function GroupAIStateBase:on_AI_criminal_death(criminal_name, unit)
	managers.hint:show_hint("teammate_dead", nil, false, {
		TEAMMATE = unit:base():nick_name()
	})

	if not Network:is_server() then
		return
	end

	local base_delay = tweak_data.player.damage.base_respawn_time_penalty
	local respawn_penalty = self._criminals[unit:key()].respawn_penalty or (40 + self._tweak_data.assault.delay[3])

	managers.trade:on_AI_criminal_death(criminal_name, respawn_penalty, self._criminals[unit:key()].hostages_killed or 0)
	managers.hud:set_ai_stopped(managers.criminals:character_data_by_unit(unit).panel_id, false)
end

function GroupAIStateBase:on_player_criminal_death(peer_id)
	managers.player:transfer_special_equipment(peer_id)

	local unit = managers.network:session():peer(peer_id):unit()

	if not unit then
		return
	end

	local my_peer_id = managers.network:session():local_peer():id()

	if my_peer_id ~= peer_id then
		managers.hint:show_hint("teammate_dead", nil, false, {
			TEAMMATE = unit:base():nick_name()
		})
	end

	if not Network:is_server() then
		return
	end

	local criminal_name = managers.criminals:character_name_by_peer_id(peer_id)
	local base_delay = tweak_data.player.damage.base_respawn_time_penalty
	local respawn_penalty = self._criminals[unit:key()].respawn_penalty or (40 + self._tweak_data.assault.delay[3])

	managers.trade:on_player_criminal_death(criminal_name, respawn_penalty, self._criminals[unit:key()].hostages_killed or 0)
	managers.criminals:on_last_valid_player_spawn_point_updated(unit)
	managers.mission:call_global_event("player_criminal_death")
end
