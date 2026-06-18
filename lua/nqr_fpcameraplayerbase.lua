function FPCameraPlayerBase:play_sound(unit, event)
	local lookup = {
		--m4_equip = "primary_steel_sight_exit",--"primary_steel_sight_enter",
		m4_equip = "",--"primary_steel_sight_enter",
		m4_unequip_a = "pistol_steel_sight_exit",--"primary_steel_sight_exit",
		foley_run_m4_02 = "",
	}
	local event = lookup[event] or event
	if alive(self._parent_unit) then
		self._parent_unit:sound():play(event)
	end
end

function FPCameraPlayerBase:play_melee_sound(unit, sound_id)
	local melee_entry = self.melee_instant_hit and "weapon" or self.custom_melee or managers.blackmarket:equipped_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local keep_charge = {
		--moneybundle = true,
		--chac = true,
		--wing = true,
		road = true,
		ostry = true,
		cs = true,
	}
	if not keep_charge[melee_entry] then return end

	if not melee_tweak.sounds or not melee_tweak.sounds[sound_id] then
		return
	end

	if alive(self._parent_unit) then
		self._parent_unit:sound():play(melee_tweak.sounds[sound_id], nil, false)
	end
end
function FPCameraPlayerBase:spawn_melee_item()
	--log("spawn_melee_item")
	if self._melee_item_units then return end

	local melee_entry = self.melee_instant_hit and "weapon" or self.custom_melee or managers.blackmarket:equipped_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local unit_name = melee_tweak.unit

	if unit_name then
		local hands = {
			{ "a_weapon_left" },
			{ "a_weapon_right" },
			{ "a_weapon_left", "a_weapon_right" },
		}
		local aligns = (
			self._parent_movement_ext.m_akimbo and hands[3]
			or melee_tweak.twohanded and melee_tweak.align_objects
			or self._parent_movement_ext.m_main_hand and hands[self._parent_movement_ext.m_main_hand]
			or melee_tweak.align_objects
			or hands[1]
		)
		local graphic_objects = melee_tweak.graphic_objects or {}
		self._melee_item_units = {}

		for _, align in ipairs(aligns) do
			local align_obj_name = Idstring(align)
			local align_obj = self._unit:get_object(align_obj_name)
			local unit = World:spawn_unit(Idstring(unit_name), align_obj:position(), align_obj:rotation())

			unit:anim_stop()
			self._unit:link(align_obj:name(), unit, unit:orientation_object():name())

			local m_rot = self.m_shifts and self.m_shifts[align] and self.m_shifts[align].rot
			if m_rot then
				unit:set_local_rotation(m_rot)
			end
			local m_pos = self.m_shifts and self.m_shifts[align] and self.m_shifts[align].pos
			if m_pos then
				unit:set_local_position(m_pos)
			end

			local w_rot = melee_tweak.shifts and melee_tweak.shifts.rot
			if w_rot then
				unit:set_local_rotation(unit:local_rotation() * w_rot)
			end

			local w_pos = melee_tweak.shifts and melee_tweak.shifts.pos
			if w_pos then
				local weapon_facing = unit:local_rotation()

				local right_dir   = weapon_facing:x()
				local forward_dir = weapon_facing:y()
				local up_dir      = weapon_facing:z()

				local final_offset = (right_dir * w_pos.x) + (forward_dir * w_pos.y) + (up_dir * w_pos.z)

				unit:set_local_position(unit:local_position() + final_offset)
			end

			for a_object, g_object in pairs(graphic_objects) do
				local graphic_obj_name = Idstring(g_object)
				local graphic_obj = unit:get_object(graphic_obj_name)
				graphic_obj:set_visibility(Idstring(a_object) == align_obj_name)
			end

			if melee_entry=="hauteur" then
				local graphic_obj_name = Idstring("g_sheet")
				local graphic_obj = unit:get_object(graphic_obj_name)
				graphic_obj:set_visibility(false)
			end

			if alive(unit) and unit:damage() and unit:damage():has_sequence("game") then
				unit:damage():run_sequence_simple("game")
			end

			table.insert(self._melee_item_units, unit)
		end

		if not melee_tweak.nochargeanim then
			self:play_anim_melee_item("charge", melee_tweak.chargeanimoffset)
		end
	end
end
function FPCameraPlayerBase:unspawn_melee_item()
	--log("unspawn_melee_item")
	if not self._melee_item_units then
		return
	end

	for _, unit in ipairs(self._melee_item_units) do
		if alive(unit) then
			unit:unlink()
			World:delete_unit(unit)
		end
	end

	self._melee_item_units = nil
	self._melee_item_anim = nil
end
function FPCameraPlayerBase:shift_melee_item(shifts)
	if not self._melee_item_units then
		return
	end

	local melee_entry = self.melee_instant_hit and "weapon" or self.custom_melee or managers.blackmarket:equipped_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local hands = {
		{ "a_weapon_left" },
		{ "a_weapon_right" },
		{ "a_weapon_left", "a_weapon_right" },
	}
	local aligns = (
		self._parent_movement_ext.m_akimbo and hands[3]
		or melee_tweak.twohanded and melee_tweak.align_objects
		or self._parent_movement_ext.m_main_hand and hands[self._parent_movement_ext.m_main_hand]
		or melee_tweak.align_objects
		or hands[1]
	)
	for i, align in pairs(aligns) do
		local unit = self._melee_item_units[i]

		local m_rot = shifts and shifts[align] and shifts[align].rot
		if m_rot then
			unit:set_local_rotation(m_rot)
		end
		local m_pos = shifts and shifts[align] and shifts[align].pos
		if m_pos then
			unit:set_local_position(m_pos)
		end

		local w_rot = melee_tweak.shifts and melee_tweak.shifts.rot
		if w_rot then
			unit:set_local_rotation(unit:local_rotation() * w_rot)
		end

		local w_pos = melee_tweak.shifts and melee_tweak.shifts.pos
		if w_pos then
			local weapon_facing = unit:local_rotation()
	
			local right_dir   = weapon_facing:x()
			local forward_dir = weapon_facing:y() -- The direction the weapon looks
			local up_dir      = weapon_facing:z()
	
			local final_offset = (right_dir * w_pos.x) + (forward_dir * w_pos.y) + (up_dir * w_pos.z)
	
			unit:set_local_position(unit:local_position() + final_offset)
		end
	end
end

function FPCameraPlayerBase:play_anim_melee_item(tweak_name, offset)
	if not self._melee_item_units then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local anims = tweak_data.blackmarket.melee_weapons[melee_entry].anims
	local anim_data = anims and anims[tweak_name]

	if not anim_data then
		return
	end

	if self._melee_item_anim then
		for _, unit in ipairs(self._melee_item_units) do
			unit:anim_stop(self._melee_item_anim)
		end

		self._melee_item_anim = nil
	end

	local anim_ids = anim_data.anim and Idstring(anim_data.anim)

	if anim_ids then
		for _, unit in ipairs(self._melee_item_units) do
			local anim_length = unit:anim_length(anim_ids)

			if anim_data.loop then
				unit:anim_play_loop(anim_ids, 0, anim_length, 1)
			else
				if anim_data.from then
					unit:anim_set_time(anim_ids, anim_data.from)
				end

				unit:anim_play_to(anim_ids, anim_length, 1)
			end

			if type(anim_data.start_time) == "number" then
				local start_time = anim_data.start_time

				if start_time == -1 then
					start_time = anim_length
				end

				unit:anim_set_time(start_time)
			end

			if offset then
				unit:anim_set_time(anim_ids, offset)
			end
		end

		self._melee_item_anim = anim_ids
	end
end



--ROTANIM'S MODIFIERS
local mrot1 = Rotation()
local mrot2 = Rotation()
local mrot3 = Rotation()
local mrot4 = Rotation()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()
function FPCameraPlayerBase:_update_movement(t, dt)
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)

	if _G.IS_VR then
		local hmd_position = mvec1
		local mover_position = mvec3

		mvector3.set(mover_position, new_head_pos)
		mvector3.set(hmd_position, self._parent_movement_ext:hmd_position())
		mvector3.set(new_head_pos, self._parent_movement_ext:ghost_position())
		mvector3.set_x(hmd_position, 0)
		mvector3.set_y(hmd_position, 0)
		mvector3.add(new_head_pos, hmd_position)

		local mover_top = math.max(self._parent_unit:get_active_mover_offset() * 2, 45)

		mvector3.set_z(mover_position, mover_position.z + mover_top)

		self._output_data.mover_position = mvector3.copy(mover_position)

		self:_horizonatal_recoil_kick(t, dt)
		self:_vertical_recoil_kick(t, dt)
	else
		mvector3.add(new_head_pos, self._head_stance.translation)

		local stick_input_x = 0
		local stick_input_y = 0
		local aim_assist_x, aim_assist_y = self:_get_aim_assist(t, dt, self._tweak_data.aim_assist_snap_speed, self._aim_assist)
		stick_input_x = stick_input_x + self:_horizonatal_recoil_kick(t, dt) + aim_assist_x
		stick_input_y = stick_input_y + self:_vertical_recoil_kick(t, dt) + aim_assist_y
		local look_polar_spin = data.spin - stick_input_x
		local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)

		if not self._limits or not self._limits.spin then
			look_polar_spin = look_polar_spin % 360
		end

		local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
		local look_vec = look_polar:to_vector()
		local cam_offset_rot = mrot3

		mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
		self._output_data.rotation = new_head_rot or self._output_data.rotation

		if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
			self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
		end

		if self._camera_properties.current_tilt ~= 0 then
			self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
		end
	end

	self._output_data.position = new_head_pos

	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)
	self:set_position(new_shoulder_pos)
	self:set_rotation(new_shoulder_rot)
end
local mvec1 = Vector3()
function FPCameraPlayerBase:_update_rot(axis, unscaled_axis)
	self.nqr_rot_pitch = self.nqr_rot_pitch or Rotation()
	local rot = Rotation(0, self.nqr_rot_pitch, 0)

	if self._animate_pitch then self:animate_pitch_upd() end

	if self.nqr_rotanim then self:nqr_rotanim_upd() end

	local t = managers.player:player_timer():time()
	local dt = t - (self._last_rot_t or t)
	self._last_rot_t = t
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)
	mvector3.add(new_head_pos, self._head_stance.translation)

	self._input.look = axis
	self._input.look_multiplier = self._parent_unit:base():controller():get_setup():get_connection("look"):get_multiplier()
	local stick_input_x, stick_input_y = self._look_function(axis, self._input.look_multiplier, dt, unscaled_axis)
	local look_polar_spin = data.spin - stick_input_x
	local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -85, 85)
	local player_state = managers.player:current_state()

	if self._limits then
		if self._limits.spin then
			local d = (look_polar_spin - self._limits.spin.mid) / self._limits.spin.offset
			d = math.clamp(d, -1, 1)
			look_polar_spin = data.spin - math.lerp(stick_input_x, 0, math.abs(d))
		end

		if self._limits.pitch then
			local d = math.abs((look_polar_pitch - self._limits.pitch.mid) / self._limits.pitch.offset)
			d = math.clamp(d, -1, 1)
			look_polar_pitch = data.pitch + math.lerp(stick_input_y, 0, math.abs(d))
			look_polar_pitch = math.clamp(look_polar_pitch, -85, 85)
		end
	end

	if not self._limits or not self._limits.spin then
		look_polar_spin = look_polar_spin % 360
	end

	local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
	local look_vec = look_polar:to_vector()
	local cam_offset_rot = mrot3

	mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)

	if self._animate_pitch == nil then
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
	end

	self._output_data.position = new_head_pos

	if self._p_exit then
		self._p_exit = false
		self._output_data.rotation = self._parent_unit:movement().fall_rotation

		mrotation.multiply(self._output_data.rotation, self._parent_unit:camera():rotation())

		data.spin = self._output_data.rotation:y():to_polar().spin
	else
		self._output_data.rotation = new_head_rot or self._output_data.rotation
	end

	if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
		self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
	end

	if self._camera_properties.current_tilt ~= 0 then
		self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
	end

	local new_rot1 = Rotation()
	local new_rot2 = Rotation()
	mrotation.set_zero(new_rot1)
	mrotation.set_zero(new_rot2)
	mrotation.multiply(new_rot1, new_shoulder_rot)
	mrotation.multiply(new_rot2, self._output_data.rotation)
	mrotation.multiply(new_rot1, rot)
	mrotation.multiply(new_rot2, rot)

	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, new_rot2)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, new_rot2)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)

	if player_state == "driving" then
		self:_set_camera_position_in_vehicle()
	elseif player_state == "jerry1" or player_state == "jerry2" then
		mrotation.set_zero(cam_offset_rot)
		mrotation.multiply(cam_offset_rot, self._parent_unit:movement().fall_rotation)
		mrotation.multiply(cam_offset_rot, new_rot2)

		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, cam_offset_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, cam_offset_rot)
		mvector3.add(shoulder_pos, self._parent_unit:position())
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(self._parent_unit:position())
		self._parent_unit:camera():set_rotation(cam_offset_rot)
	elseif player_state == "bipod" then
		local movement_state = self._parent_unit:movement():current_state()

		self:set_position(movement_state._shoulder_pos or new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(movement_state._camera_pos or self._output_data.position)
		self._parent_unit:camera():set_rotation(new_rot2)
	elseif player_state == "player_turret" then
		self:set_position(new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(new_rot2)
	else
		self:set_position(new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(new_rot2)
	end
end

function FPCameraPlayerBase:nqr_rotanim_init(start_t, start_pitch, end_pitch, duration)
	self.nqr_rotanim = {
		start_t = start_t,
		start_pitch = start_pitch or 0,
		end_pitch = end_pitch,
		duration = duration
	}
end
function FPCameraPlayerBase:nqr_rotanim_upd()
	local t = Application:time()
	local elapsed_t = t - self.nqr_rotanim.start_t
	local step = elapsed_t / self.nqr_rotanim.duration

	if step > 1 then
		self.nqr_rotanim = nil
		self.nqr_rot_pitch = 0
	else
		step = self:catmullrom(step, -8, 0, 1, 0.2)
		self.nqr_rot_pitch = math.lerp(self.nqr_rotanim.start_pitch, self.nqr_rotanim.end_pitch, step)
	end
end



--[[function FPCameraPlayerBase:play_anim_melee_item(tweak_name)
	if not self._melee_item_units then
		return
	end

	local melee_entry = "nin" --managers.blackmarket:equipped_melee_weapon()
	local anims = tweak_data.blackmarket.melee_weapons[melee_entry].anims
	local anim_data = anims and anims[tweak_name]

	if not anim_data then
		return
	end

	if self._melee_item_anim then
		for _, unit in ipairs(self._melee_item_units) do
			unit:anim_stop(self._melee_item_anim)
		end

		self._melee_item_anim = nil
	end

	local ids = anim_data.anim and Idstring(anim_data.anim)

	if ids then
		for _, unit in ipairs(self._melee_item_units) do
			local length = unit:anim_length(ids)

			if anim_data.loop then
				unit:anim_play_loop(ids, 0, length, 1)
			else
				unit:anim_play_to(ids, length, 1)
			end
		end

		self._melee_item_anim = ids
	end
end]]



function FPCameraPlayerBase:set_visible(visible)
	self._unit:set_visible(visible)

	if self._unit:spawn_manager() then
		self._unit:spawn_manager():set_visibility_state(visible)
	end
end



function FPCameraPlayerBase:show_weapon()
	--log("FPCameraPlayerBase:show_weapon")
	if alive(self._parent_unit) then
		self._parent_unit:inventory():show_equipped_unit()
		managers.player:player_unit():movement():current_state():_stance_entered()
	end
end
function FPCameraPlayerBase:hide_weapon()
	--log("FPCameraPlayerBase:hide_weapon")
	if alive(self._parent_unit) then
		self._parent_unit:inventory():hide_equipped_unit()
	end
end



--GUN LENGTH SYSTEM
Hooks:PostHook(FPCameraPlayerBase, "clbk_stance_entered", "nqr_FPCameraPlayerBase:clbk_stance_entered", function(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration, head_duration_multiplier, head_duration)
	self._current_stance = new_shoulder_stance
end)
Hooks:PostHook(FPCameraPlayerBase, "update", "nqr_FPCameraPlayerBase:update", function(self, unit, t, dt)
	local player = self._parent_unit
	local camera = player:camera()
	local wep_base = player:inventory() and player:inventory():equipped_unit() and player:inventory():equipped_unit():base()
	if not wep_base then return end
	local wep_name = wep_base:get_name_id()

	local wep_swapped = 1
	self._last_wep = self._last_wep or wep_name
	if self._last_wep and wep_name and self._last_wep~=wep_name then
		wep_swapped = 12
		self._last_wep = wep_name
	end

	push_vec = push_vec or Vector3()

	if wep_base and wep_base._length then
		local plr = managers.player:player_unit():movement():current_state()
		local wep_length = wep_base._length*2.5
		local overall_length = math.max(40, wep_length + (wep_base._current_stats.shouldered and -10 or (wep_base:selection_index()==1 and 30 or 10)))
		if plr:_is_meleeing() then overall_length = 45 end
		local from = camera:position() + camera:forward()
		local to = camera:position() + camera:forward() * overall_length
		local z = 0

		local wallpush_ignores = {}
		local testray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"))
		local invalid_push = testray and (
			testray.unit:base() and testray.unit:base()._thrower_unit
			or testray.unit:damage() and testray.unit:damage()._collision_event and string.find(testray.unit:damage()._collision_event, "wp_clip_")
			or testray.unit:name()==Idstring("units/payday2/equipment/gen_equipment_zipline_motor/gen_equipment_zipline_motor")
		)
		local push_dist = overall_length - (testray and testray.unit and not invalid_push and testray.distance or overall_length)
		plr._wall_push = nil

		if plr._state_data.on_ladder and wep_base:selection_index()==2 then push_dist = math.min(push_dist, 9) end

		if push_dist>0 then
			if push_dist>4 then plr._wall_push = true plr:_interupt_action_steelsight() end
			if push_dist>8 then z = -10 plr._wall_melee_block = 3 end
			if (push_dist>24) and (wep_base:selection_index()==2) then plr._wall_unequip = true end
		end

		if not (plr._running_enter_end_t and plr._running_exit_start_t) then
			mvector3.lerp(push_vec, push_vec, Vector3(0, -push_dist, z), dt * 12)
		end
	end

	if not self._current_stance then return end
	local ads_mul = wep_base._current_stats.shouldered and 0.6 or 1
	stance_pos = stance_pos or Vector3()
	mvector3.lerp(stance_pos, stance_pos, self._current_stance.translation, dt * 16 * ads_mul * wep_swapped)
	mvector3.set(self._shoulder_stance.translation, stance_pos + push_vec)

	stance_ang = stance_ang or Rotation()
	mrotation.slerp(stance_ang, stance_ang, self._current_stance.rotation, dt * 14 * ads_mul * wep_swapped)
	mrotation.set_zero(self._shoulder_stance.rotation)
	mrotation.multiply(self._shoulder_stance.rotation, stance_ang)
end)



function FPCameraPlayerBase:play_redirect(redirect_name, speed, offset_time)
	local lookup = {
		[Idstring("recoil"):key()] = true,
		[Idstring("recoil_steelsight"):key()] = true,
		[Idstring("recoil_enter"):key()] = true,
		[Idstring("recoil_loop"):key()] = true,
		[Idstring("recoil_exit"):key()] = true,
	}
	if (self.interact_redirect_t and self.interact_redirect_t>managers.player:player_timer():time()) and lookup[redirect_name:key()] then return end

	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	if speed then
		self._unit:anim_state_machine():set_speed(result, math.max(0, speed))
	end

	if redirect_name==Idstring("stop_running") then
		self._parent_unit:sound():play("foley_run_m4_02")
	end

	return result
end
function PlayerCamera:nqr_play_anim(anim)
	if not anim then return end

	self._unit:anim_play(anim)
end



--RECOIL: LIMIT DISABLED
function FPCameraPlayerBase:recoil_kick(up, down, left, right)
	local v = math.lerp(up, down, math.random())
	self._recoil_kick.accumulated = ((self._recoil_kick.accumulated or 0) + v)

	local h = math.lerp(left, right, math.random())
	self._recoil_kick.h.accumulated = ((self._recoil_kick.h.accumulated or 0) + h)
end
--AUTO RECOIL COMPENSATION DISABLED
function FPCameraPlayerBase:stop_shooting(wait)
	self._recoil_kick.to_reduce = 0
	self._recoil_kick.h.to_reduce = 0
    self._recoil_wait = wait or 0
end



--RECOIL: SHARPER RISE
function FPCameraPlayerBase:_vertical_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		self:break_recoil()

		return 0
	end

	local r_value = 0

	if self._recoil_kick.current and self._episilon < math.abs(self._recoil_kick.accumulated - self._recoil_kick.current) then
		local action = self._parent_unit:inventory():equipped_unit():base():weapon_tweak_data().action
		local sharpness = ((not action) or action=="moving_barrel" or action=="roller_delayed") and 2 or (action=="blowback" and 1.5) or 1
		local n = math.step(self._recoil_kick.current, self._recoil_kick.accumulated, (360 / sharpness) * dt)

		r_value = n - self._recoil_kick.current
		self._recoil_kick.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait < 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.to_reduce then
		self._recoil_kick.current = nil
		local n = math.lerp(self._recoil_kick.to_reduce, 0, 9 * dt)
		r_value = -(self._recoil_kick.to_reduce - n)
		self._recoil_kick.to_reduce = n

		if self._recoil_kick.to_reduce == 0 then
			self._recoil_kick.to_reduce = nil
		end
	end

	return r_value
end
function FPCameraPlayerBase:_horizonatal_recoil_kick(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		return 0
	end

	local r_value = 0

	if self._recoil_kick.h.current and self._episilon < math.abs(self._recoil_kick.h.accumulated - self._recoil_kick.h.current) then
		local action = self._parent_unit:inventory():equipped_unit():base():weapon_tweak_data().action
		local sharpness = (((not action) or action=="moving_barrel" or action=="roller_delayed") and 3) or (action=="blowback" and 2) or 1
		local n = math.step(self._recoil_kick.h.current, self._recoil_kick.h.accumulated, (360 / sharpness) * dt)
		r_value = n - self._recoil_kick.h.current
		self._recoil_kick.h.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait < 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.h.to_reduce then
		self._recoil_kick.h.current = nil
		local n = math.lerp(self._recoil_kick.h.to_reduce, 0, 5 * dt)
		r_value = -(self._recoil_kick.h.to_reduce - n)
		self._recoil_kick.h.to_reduce = n

		if self._recoil_kick.h.to_reduce == 0 then
			self._recoil_kick.h.to_reduce = nil
		end
	end

	return r_value
end



--
function FPCameraPlayerBase:enter_shotgun_reload_loop(unit, state, ...)
	if alive(self._parent_unit) then
		local wep_base = self._parent_unit:inventory():equipped_unit():base()
		local wep_tweak = wep_base:weapon_tweak_data()
		local speed_multiplier = wep_base._current_reload_speed_multiplier_loop--:reload_speed_multiplier()

		if wep_tweak.r_ffs then
			wep_base:tweak_data_anim_play("reload_enter", speed_multiplier, wep_tweak.r_enter/30)
		elseif not (wep_tweak.r_anim_swap and wep_tweak.r_anim_swap==wep_base.r_anim_swap) then
			wep_base:tweak_data_anim_play("reload", speed_multiplier)
		end
		self._unit:anim_state_machine():set_speed(Idstring(state), speed_multiplier)
	end
end



--FUNNY EXCEPTIONS THX OVK
function FPCameraPlayerBase:anim_clbk_check_bullet_object()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()
		local wep_base = weapon:base()
		local funny_exception = (
			(
				wep_base._name_id=="r700" 
				or wep_base._name_id=="shrew"
				or wep_base._name_id=="g26"
				or wep_base._name_id=="mac10"
				or wep_base._name_id=="baka"
	 		) and (wep_base:get_ammo_remaining_in_clip()-wep_base:get_chamber())<=0
			or wep_base._name_id=="ching"
			--or csc and shs
		)

		if alive(weapon) and not funny_exception then
			wep_base:predict_bullet_objects()
		end
	end
end



local bezier_values = { 0, 0, 1, 1 }
local mrot1 = Rotation()
local mrot2 = Rotation()
local mrot3 = Rotation()
local mrot4 = Rotation()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()
function FPCameraPlayerBase:_calculate_soft_velocity_overshot(dt)
	if self.shs then return end
	local stick_input = self._input.look
	local vel_overshot = self._vel_overshot

	if not stick_input then
		return
	end

	local input_yaw, input_pitch, input_x, input_z = nil
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if stick_input.x >= 0 then
		local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, 0, 1)), 1.5) * math.sign(stick_input.x)
		input_yaw = stick_input_x * vel_overshot.yaw_pos
	else
		local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, -1, 0)), 1.5)
		input_yaw = stick_input_x * vel_overshot.yaw_neg
	end

	self.nqr_yaw = self.nqr_yaw or 0
	input_yaw = input_yaw + self.nqr_yaw

	local last_yaw = vel_overshot.last_yaw
	local sign_in_yaw = math.sign(input_yaw)
	local abs_in_yaw = math.abs(input_yaw)
	local sign_last_yaw = math.sign(last_yaw)
	local abs_last_yaw = math.abs(last_yaw)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_yaw = math.step(vel_overshot.target_yaw, input_yaw, step_v)
	local final_yaw = nil
	local diff = math.abs(vel_overshot.target_yaw - last_yaw)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_yaw = math.step(last_yaw, vel_overshot.target_yaw, step_amount)
	vel_overshot.last_yaw = final_yaw
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if stick_input.y >= 0 then
		local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, 0, 1)), 1.5) * math.sign(stick_input.y)
		input_pitch = stick_input_y * vel_overshot.pitch_pos
	else
		local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, -1, 0)), 1.5)
		input_pitch = stick_input_y * vel_overshot.pitch_neg
	end

	local last_pitch = vel_overshot.last_pitch
	local sign_in_pitch = math.sign(input_pitch)
	local abs_in_pitch = math.abs(input_pitch)
	local sign_last_pitch = math.sign(last_pitch)
	local abs_last_pitch = math.abs(last_pitch)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_pitch = math.step(vel_overshot.target_pitch, input_pitch, step_v)
	local final_pitch = nil
	local diff = math.abs(vel_overshot.target_pitch - last_pitch)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_pitch = math.step(last_pitch, vel_overshot.target_pitch, step_amount)
	vel_overshot.last_pitch = final_pitch

	local rot = -math.rot_to_vec(self._shoulder_stance.rotation).z
	local y_mul = (90-math.abs(self._output_data.rotation:pitch()))/15
	local p_mul = 4
	local r_mul = y_mul/4
	local y = (final_yaw*y_mul*(math.cos(rot))) - (final_pitch*p_mul*(math.sin(rot)))
	local p = (final_pitch*p_mul*(math.cos(rot))) + (final_yaw*y_mul*(math.sin(rot)))
	local r = final_yaw*r_mul
	mrotation.set_yaw_pitch_roll(vel_overshot.rotation, y, p, r)

	local pivot = vel_overshot.pivot
	local new_root = mvec3

	mvector3.set(new_root, pivot)
	mvector3.negate(new_root)
	mvector3.rotate_with(new_root, vel_overshot.rotation)
	mvector3.add(new_root, pivot)
	mvector3.set(vel_overshot.translation, new_root)
end
