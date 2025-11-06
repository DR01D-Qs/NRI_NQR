function PlayerBipod:_enter(enter_data)
	local player = managers.player:player_unit()

	if player and self._unit:base().is_local_player then
		self._bipod = true
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		local speed_multiplier = self._equipped_unit:base():get_property("bipod_deploy_multiplier") or 1
		local reload_name_id = tweak_data.animations.reload_name_id or self._equipped_unit:base().name_id
		local equipped_unit_id = self._equipped_unit:base().name_id
		self._camera_pos = self._unit:camera():position()
		self._shoulder_pos = Vector3(0, 0, 0)

		if tweak_data.bipod_weapon_translation then
			mvector3.set(self._shoulder_pos, tweak_data.bipod_weapon_translation)
		end

		mvector3.rotate_with(self._shoulder_pos, self._unit:camera():rotation())
		mvector3.add(self._shoulder_pos, self._camera_pos)

		self._unit_deploy_position = player:position()

		self._unit:camera():camera_unit():base():set_limits(tweak_data.bipod_camera_spin_limit, tweak_data.bipod_camera_pitch_limit)
		PlayerBipod.super:start_deploying_bipod(tweak_data.timers.deploy_bipod)
		self._equipped_unit:base():tweak_data_anim_stop("undeploy")

		local result = self._ext_camera:play_redirect(Idstring(tweak_data.animations.bipod_enter .. "_" .. equipped_unit_id), speed_multiplier)
		local result_deploy = self._equipped_unit:base():tweak_data_anim_play("deploy", speed_multiplier)
		self._headbob = 0
		self._target_headbob = 0

		self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)

		PlayerStandard.ANIM_STATES.bipod = {
			recoil = Idstring(tweak_data.animations.bipod_recoil .. "_" .. equipped_unit_id),
			recoil_enter = Idstring(tweak_data.animations.bipod_recoil_enter .. "_" .. equipped_unit_id),
			recoil_loop = Idstring(tweak_data.animations.bipod_recoil_loop .. "_" .. equipped_unit_id),
			recoil_exit = Idstring(tweak_data.animations.bipod_recoil_exit .. "_" .. equipped_unit_id)
		}

		self:set_animation_state("bipod")
		self._unit:sound_source():post_event("wp_steady_in")
		self:_stance_entered()
		self:_husk_bipod_data()
	end
end