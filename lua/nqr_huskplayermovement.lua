function HuskPlayerMovement:_get_pose_redirect(pose_code)
	if pose_code==3 then self._bleedout = true else self._bleedout = false end
	return pose_code == 1 and "stand" or pose_code == 3 and "bleedout" or "crouch"
end



function HuskPlayerMovement:anim_cbk_set_melee_start_state_vars(unit, name, segment_name)
	local state = self._unit:anim_state_machine():segment_state(segment_name or Idstring("upper_body"))
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id() or "fists"
	if self._custom_melee then melee_entry = "fists" end
	local anim_global_param = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._unit:anim_state_machine():set_parameter(state, anim_global_param, 1)
end
function HuskPlayerMovement:anim_cbk_set_melee_item_state_vars(unit)
	local state = self._unit:anim_state_machine():segment_state(Idstring("upper_body"))
	local anim_attack_vars = {
		"var1",
		"var2"
	}

	self._unit:anim_state_machine():set_parameter(state, anim_attack_vars[math.random(#anim_attack_vars)], 1)

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id() or "fists"
	if self._custom_melee then melee_entry = "fists" end
	local anim_global_param = tweak_data.blackmarket.melee_weapons[melee_entry].anim_global_param

	self._unit:anim_state_machine():set_parameter(state, anim_global_param, 1)
end
function HuskPlayerMovement:anim_cbk_spawn_melee_item(unit, graphic_object)
	if alive(self._melee_item_unit) or not managers.network:session() or not managers.network:session():peer_by_unit(self._unit) then
		return
	end

	local align_obj_name = Idstring("a_weapon_left_front")

	if self:arm_animation_enabled() then
		self:refresh_primary_hand()

		if self._melee_hand == 1 then
			align_obj_name = Idstring("a_weapon_right_front")
		end
	end

	local align_obj = self._unit:get_object(align_obj_name)
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local peer = managers.network:session():peer(peer_id)
	local melee_entry = peer:melee_id() or "fists"
	if self._custom_melee then melee_entry = "fists" end
	local graphic_object_name = Idstring(graphic_object)
	local graphic_objects = tweak_data.blackmarket.melee_weapons[melee_entry].graphic_objects or {}
	local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].third_unit

	if unit_name then
		self._melee_item_unit = World:spawn_unit(Idstring(unit_name), align_obj:position(), align_obj:rotation())

		self._unit:link(align_obj:name(), self._melee_item_unit, self._melee_item_unit:orientation_object():name())

		if self:arm_animation_enabled() then
			local offset = tweak_data.vr.melee_offsets.weapons_npc[melee_entry]

			if offset then
				if offset.right and self._melee_hand == 1 then
					self._melee_item_unit:set_local_position(offset.right.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.right.rotation or Rotation())
				elseif offset.left and self._melee_hand == 0 then
					self._melee_item_unit:set_local_position(offset.left.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.left.rotation or Rotation())
				else
					self._melee_item_unit:set_local_position(offset.position or Vector3())
					self._melee_item_unit:set_local_rotation(offset.rotation or Rotation())
				end

				if offset.hidden_objects then
					for _, object in ipairs(offset.hidden_objects) do
						local obj = self._melee_item_unit:get_object(object)

						if obj then
							obj:set_visibility(false)
						end
					end
				end
			end
		end

		for a_object, g_object in pairs(graphic_objects) do
			local g_obj_name = Idstring(g_object)
			local g_obj = self._melee_item_unit:get_object(g_obj_name)

			g_obj:set_visibility(Idstring(a_object) == graphic_object_name)
		end

		if self._unit:inventory().on_melee_item_shown then
			self._unit:inventory():on_melee_item_shown()
		end
	end

	if alive(self._unit:inventory():equipped_unit()) then
		if self._unit:inventory():equipped_unit():base().AKIMBO then
			self._unit:inventory():equipped_unit():base():on_melee_item_shown(self._use_primary_melee_hand)
		elseif self._use_primary_melee_hand then
			self._unit:inventory():equipped_unit():base():on_disabled()
		end
	end
end
function HuskPlayerMovement:sync_melee_stop()
	self._melee_equipped = false

	if self._ext_anim.melee then
		self:anim_cbk_unspawn_melee_item()

		self._ext_anim.melee = false

		if alive(self._machine) then
			self:play_redirect("up_idle_ext")
			self:play_redirect("switch_weapon_enter")
		end
	end
end

function HuskPlayerMovement:sync_action_change_speed(speed)
	if speed==-1 then
		self._custom_melee = nil
		log("sync_action_change_speed RESET", self._custom_melee)
		return
	elseif speed==-2 then
		self._custom_melee = "fists"
		log("sync_action_change_speed HAXED", self._custom_melee)
		return
	end

	self._synced_max_speed = speed
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