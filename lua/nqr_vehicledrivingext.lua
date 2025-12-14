function VehicleDrivingExt:_detect_npc_collisions()
	local vel = self._vehicle:velocity()
	--managers.mission._fading_debug_output:script().log(tostring(math.floor((vel:length()*0.003)^3)), Color.white)

	if vel:length() < 150 then
		return
	end

	local oobb = self._unit:oobb()
	local slotmask = managers.slot:get_mask("flesh")
	local units = World:find_units("intersect", "obb", oobb:center(), oobb:x(), oobb:y(), oobb:z(), slotmask)

	for _, unit in pairs(units) do
		local unit_is_criminal = unit:in_slot(managers.slot:get_mask("all_criminals"))

		if unit_is_criminal then
			-- Nothing
		elseif unit:character_damage() and not unit:character_damage():dead() then
			if unit:character_damage()._vehicle_bump_t and (unit:character_damage()._vehicle_bump_t > TimerManager:game():time()) then return end
			unit:character_damage()._vehicle_bump_t = TimerManager:game():time() + 0.5

			self._hit_soundsource:set_position(unit:position())
			self._hit_soundsource:set_rtpc("car_hit_vel", math.clamp(vel:length() / 100 * 2, 0, 100))
			self._hit_soundsource:post_event("car_hit_body_01")

			local damage_ext = unit:character_damage()
			local attack_data = {
				variant = "explosion",
				damage = (vel:length()*0.003)^3,
				pls_dont_just_kill_the_guy = true,
			}

			if self._seats.driver.occupant == managers.player:local_player() then
				attack_data.attacker_unit = managers.player:local_player()
			end

			local unit_is_enemy = unit:in_slot(managers.slot:get_mask("enemies"))
			local td = tweak_data.achievement.ranc_9
			local vehicle_pass = not td.vehicle_id or self.tweak_data == td.vehicle_id
			local level_pass = td.job == (managers.job:has_active_job() and managers.job:current_level_id() or "")
			local diff_pass = not td.difficulty or table.contains(td.difficulty, Global.game_settings.difficulty)
			local local_player_is_inside = false
			local players_inside = {}

			for seat_id, seat in pairs(self._seats) do
				if alive(seat.occupant) and not seat.occupant:brain() then
					table.insert(players_inside, seat.occupant)
				end

				if seat.occupant == managers.player:local_player() then
					local_player_is_inside = true
				end
			end

			if unit_is_enemy and vehicle_pass and level_pass and diff_pass then
				attack_data.players_in_vehicle = players_inside
			end

			damage_ext:damage_mission(attack_data)

			--[[if unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
				unit:movement()._active_actions[1]:force_ragdoll(true)
			end]]

			local nr_u_bodies = unit:num_bodies()
			local i_u_body = 0

			while nr_u_bodies > i_u_body do
				local u_body = unit:body(i_u_body)

				if u_body:enabled() and u_body:dynamic() then
					local body_mass = u_body:mass()

					u_body:push_at(body_mass / math.random(2), vel * 2.5, u_body:position())
				end

				i_u_body = i_u_body + 1
			end
		end
	end
end