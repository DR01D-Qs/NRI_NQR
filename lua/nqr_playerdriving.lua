function PlayerDriving:_enter(enter_data)
	self:_get_vehicle()

	if self._vehicle == nil then
		print("[DRIVING] No vehicle found")

		return
	end

	if self._vehicle_ext:get_view() == nil then
		print("[DRIVING] No vehicle view point found")

		return
	end

	self._seat = self._vehicle_ext:find_seat_for_player(self._unit)
	self._wheel_idle = false

	self:_postion_player_on_seat(self._seat)
	self._unit:inventory():add_listener("PlayerDriving", {
		"equip"
	}, callback(self, self, "on_inventory_event"))

	self._current_weapon = self._unit:inventory():equipped_unit()

	if self._current_weapon then
		--table.insert(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
	end

	if self._seat.driving then
		self:_set_camera_limits("driving")

		local use_fps_material = true
		use_fps_material = not _G.IS_VR

		if use_fps_material and self._vehicle_unit:damage():has_sequence("local_driving_enter") then
			self._vehicle_unit:damage():run_sequence("local_driving_enter")
		end

		self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 1)
	else
		self:_set_camera_limits("passenger")

		--self._seat.allow_shooting = true
		--self._seat.has_shooting_mode = true

		if not self._seat.allow_shooting then
			self._unit:camera():play_redirect(self.IDS_PASSENGER_REDIRECT)
		else
			self._unit:camera():play_redirect(self:get_animation("equip"))
		end
	end

	self._unit:camera():set_shaker_parameter("breathing", "amplitude", 0)
	--self._unit:camera()._camera_unit:base():animate_fov(self:get_zoom_fov({}), 0.33)

	self._controller = self._unit:base():controller()

	managers.controller:set_ingame_mode("driving")
	self:_upd_attention()
end

function PlayerDriving:exit(state_data, new_state_name)
	print("[DRIVING] PlayerDriving: Exiting vehicle")
	self:_interupt_action_exit_vehicle()
	PlayerDriving.super.exit(self, state_data, new_state_name)

	if self._vehicle_unit:camera() then
		self._vehicle_unit:camera():deactivate(self._unit)
	end

	self:_interupt_action_steelsight()

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_charging_weapon()
	self:_interupt_action_melee()

	local exit_position = self._vehicle_ext:find_exit_position(self._unit)
	local exit_pos = self._exit_data and self._exit_data.position or exit_position and exit_position:position()
	local exit_rot = self._exit_data and self._exit_data.rotation or exit_position and exit_position:rotation() or Rotation()
	self._exit_data = nil

	if exit_pos then
		self._unit:set_rotation(exit_rot)
		self._unit:camera():set_rotation(exit_rot)

		local pos = exit_pos + Vector3(0, 0, 30)

		self._unit:set_position(pos)
		self._unit:camera():set_position(pos)

		if _G.IS_VR then
			self._unit:movement():set_ghost_position(exit_pos)
		end

		self._unit:camera():camera_unit():base():set_spin(exit_rot:y():to_polar().spin)
		self._unit:camera():camera_unit():base():set_pitch(0)
		self._unit:camera():camera_unit():base():set_target_tilt(0)

		self._unit:camera():camera_unit():base().bipod_location = nil
	else
		Application:error("[PlayerDriving:exit] No vehicle exit position")
	end

	if self._vehicle_unit:damage():has_sequence("local_driving_exit") then
		self._vehicle_unit:damage():run_sequence("local_driving_exit")
	end

	if self._seat.driving then
		self._unit:inventory():show_equipped_unit()
	end

	if not self._was_unarmed or not managers.groupai:state():whisper_mode() then
		self._unit:camera():play_redirect(self:get_animation("equip"))
	end

	managers.player:exit_vehicle()

	self._dye_risk = nil
	self._state_data.in_air = false
	self._stance = PlayerDriving.STANCE_NORMAL
	local exit_data = {
		skip_equip = true
	}
	local velocity = self._unit:mover() and self._unit:mover():velocity()

	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("set_pose", 1)
	self._unit:inventory():remove_listener("PlayerDriving")

	if self._current_weapon then
		--table.delete(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
	end

	self:_upd_attention()
	self:_remove_camera_limits()
	--self._camera_unit:base():animate_fov(75, 0.33)
	self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 0)
	managers.controller:set_ingame_mode("main")

	return exit_data
end
function PlayerDriving:on_inventory_event(unit, event)
	local weapon = self._unit:inventory():equipped_unit()

	if weapon then
		table.insert(weapon:base()._setup.ignore_units, self._vehicle_unit)

		if alive(self._current_weapon) then
			--table.delete(self._current_weapon:base()._setup.ignore_units, self._vehicle_unit)
		end

		self._current_weapon = weapon

		weapon:base():set_visibility_state(true)
	else
		self._current_weapon = false
	end
end
function PlayerDriving:get_zoom_fov(stance_data)
	return PlayerStandard.get_zoom_fov(self, stance_data)
end



function PlayerDriving:_set_camera_limits(mode)
	if mode == "driving" or mode == "passenger" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.driver then
			self._camera_unit:base():set_limits(170, 60)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.driver.yaw, self._vehicle_ext._tweak_data.camera_limits.driver.pitch)
		end
	elseif mode == "shooting" then
		if not self._vehicle_ext._tweak_data.camera_limits or not self._vehicle_ext._tweak_data.camera_limits.shooting then
			self._camera_unit:base():set_limits(nil, 85)
		else
			self._camera_unit:base():set_limits(self._vehicle_ext._tweak_data.camera_limits.shooting.yaw, self._vehicle_ext._tweak_data.camera_limits.shooting.pitch)
		end
	end
end