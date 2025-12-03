function HuskPlayerMovement:_get_pose_redirect(pose_code)
	if pose_code==3 then self._bleedout = true else self._bleedout = false end
	return pose_code == 1 and "stand" or pose_code == 3 and "bleedout" or "crouch"
end



--[[function HuskPlayerMovement:anim_clbk_spawn_dropped_magazine()
	if not self:allow_dropped_magazines() then
		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if alive(equipped_weapon) and not equipped_weapon:base()._assembly_complete then
		return
	end

	local ref_unit = nil
	local allow_throw = true

	if not self._magazine_data then
		local w_td_crew = self:_equipped_weapon_crew_tweak_data()

		if not w_td_crew or not w_td_crew.pull_magazine_during_reload then
			return
		end

		self:anim_clbk_show_magazine_in_hand()

		if not self._magazine_data or not alive(self._magazine_data.unit) then
			return
		end

		local attach_bone = (not self._primary_hand or self._primary_hand == 0) and Idstring("LeftHandMiddle2") or Idstring("RightHandMiddle2")
		local bone_hand = self._unit:get_object(attach_bone)

		if bone_hand then
			mvec3_set(tmp_vec1, self._magazine_data.unit:position())
			mvec3_sub(tmp_vec1, self._magazine_data.unit:oobb():center())
			mvec3_add(tmp_vec1, bone_hand:position())
			self._magazine_data.unit:set_position(tmp_vec1)
		end

		ref_unit = self._magazine_data.part_unit
		allow_throw = false
	end

	if self._magazine_data and alive(self._magazine_data.unit) then
		ref_unit = ref_unit or self._magazine_data.unit

		self._magazine_data.unit:set_visible(false)

		local pos = ref_unit:position()
		local rot = ref_unit:rotation()
		local dropped_mag = self:_spawn_magazine_unit(self._magazine_data.id, self._magazine_data.name, pos, rot)

		self:_set_unit_bullet_objects_visible(dropped_mag, self._magazine_data.bullets, false)

		local mag_size = self._magazine_data.weapon_data.pull_magazine_during_reload

		if type(mag_size) ~= "string" then
			mag_size = "medium"
		end

		mvec3_set(tmp_vec1, ref_unit:oobb():center())
		mvec3_sub(tmp_vec1, pos)
		mvec3_set(tmp_vec2, pos)
		mvec3_add(tmp_vec2, tmp_vec1)

		local dropped_col = World:spawn_unit(HuskPlayerMovement.magazine_collisions[mag_size][1], tmp_vec2, rot)

		dropped_col:link(HuskPlayerMovement.magazine_collisions[mag_size][2], dropped_mag)

		if allow_throw then
			if self._left_hand_direction then
				local throw_force = 10

				mvec3_set(tmp_vec1, self._left_hand_direction)
				mvec3_mul(tmp_vec1, self._left_hand_velocity or 3)
				mvec3_mul(tmp_vec1, math.random(25, 45))
				mvec3_mul(tmp_vec1, -1)
				dropped_col:push(throw_force, tmp_vec1)
			end
		else
			local throw_force = 10
			local _t = (self._reload_speed_multiplier or 1) - 1

			mvec3_set(tmp_vec1, equipped_weapon:rotation():z())
			mvec3_mul(tmp_vec1, math.lerp(math.random(65, 80), math.random(140, 160), _t))
			mvec3_mul(tmp_vec1, math.random() < 0.0005 and 10 or -1)
			dropped_col:push(throw_force, tmp_vec1)
		end

		managers.enemy:add_magazine(dropped_mag, dropped_col)
	end
end]]