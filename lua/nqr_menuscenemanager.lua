local ids_unit = Idstring("unit")
local sky_orientation_data_key = Idstring("sky_orientation/rotation"):key()
MenuSceneManager = MenuSceneManager or class()



function MenuSceneManager:_get_lobby_character_prio_item(rank, outfit) return "primary" end



function MenuSceneManager:get_henchmen_positioning(index)
	local offset = Vector3(0, -100, -130)
	local rotation = {
		-65,
		-79,
		-89
	}
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()

	mrotation.set_yaw_pitch_roll(rot, rotation[math.min(index, #rotation)], 0, 0)
	mvector3.set(pos, offset)
	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mvector3.set(mvec, mvec + Vector3(100, 150, 0))
	mrotation.set_look_at(rot, mvec, math_up)
	mvector3.set_x(pos, 50 + -80 * index)
	mvector3.set_z(pos, -135)

	return pos, rot
end

function MenuSceneManager:_setup_henchmen_characters()
	if self._henchmen_characters then
		for _, unit in ipairs(self._henchmen_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end

	self._henchmen_characters = {}
	local masks = {
		"dallas",
		"dallas",
		"dallas"
	}

	for i = 1, 3 do
		local pos, rot = self:get_henchmen_positioning(i)
		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[masks[i] ].unit, unit, nil, masks[i])
		table.insert(self._henchmen_characters, unit)

		self._character_visibilities[unit:key()] = false

		self:_chk_character_visibility(unit)
	end
end



--[[Hooks:PostHook( MenuSceneManager, "_set_up_templates", "nqr_CharacterTweakData:_set_up_templates", function(self)
	self._scene_templates.blackmarket_crafting = {
		camera_pos = Vector3(1500, -2000, 0)
	}
	self._scene_templates.blackmarket_crafting.target_pos = self._scene_templates.blackmarket_crafting.camera_pos + Vector3(0, 1, 0) * 100
	local camera_look = (self._scene_templates.blackmarket_crafting.target_pos - self._scene_templates.blackmarket_crafting.camera_pos):normalized()

	mvector3.rotate_with(camera_look, Rotation(4, 2.25, 0))

	self._scene_templates.blackmarket_crafting.item_pos = self._scene_templates.blackmarket_crafting.camera_pos + camera_look * 160
	self._scene_templates.blackmarket_crafting.fov = 110
	self._scene_templates.blackmarket_crafting.use_item_grab = true
	self._scene_templates.blackmarket_crafting.can_change_fov = true
	self._scene_templates.blackmarket_crafting.disable_rotate = true
	self._scene_templates.blackmarket_crafting.environment = "crafting"
	self._scene_templates.blackmarket_crafting.use_workbench_room = true
	self._scene_templates.blackmarket_crafting.lights = {}
	self._scene_templates.blackmarket_crafting.custom_fov = true
end)

function MenuSceneManager:spawn_workbench_room(workbench_name)
	self:delete_workbench_room()

	local ids_unit_workbench_room_name = workbench_name and Idstring(workbench_name) or self:workbench_room_name()

	if not managers.dyn_resource:is_resource_ready(Idstring("unit"), ids_unit_workbench_room_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE) then
		print("[MenuSceneManager:spawn_workbench_room]", "workbench room unit is not loaded, force loading it.")
		managers.dyn_resource:load(Idstring("unit"), ids_unit_workbench_room_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._workbench_force_loaded = true
	end

	local pos = self._scene_templates.blackmarket_crafting.camera_pos-Vector3(0,150,0)
	self._workbench_room = World:spawn_unit(ids_unit_workbench_room_name, pos)
end

function MenuSceneManager:spawn_item_weapon(factory_id, blueprint, cosmetics, texture_switches, custom_data)
	local factory_weapon = tweak_data.weapon.factory[factory_id]
	local ids_unit_name = Idstring(factory_weapon.unit)

	managers.dyn_resource:load(Idstring("unit"), ids_unit_name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._item_pos = custom_data and custom_data.item_pos or Vector3(0, 0, 200)

	mrotation.set_zero(self._item_rot_mod)

	self._item_yaw = custom_data and custom_data.item_yaw or 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_zero(self._item_rot)

	local function spawn_weapon(pos, rot, is_second_weapon)
		local w_unit = World:spawn_unit(ids_unit_name, pos, rot)

		w_unit:base():set_factory_data(factory_id)
		w_unit:base():set_cosmetics_data(cosmetics)
		w_unit:base():set_texture_switches(texture_switches)

		if blueprint then
			if is_second_weapon then
				local charm_parts = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("charm", factory_id, blueprint)

				if next(charm_parts) then
					local part_id = nil
					local filtered_bp = {}
					local t_cont = table.contains

					for i = 1, #blueprint do
						part_id = blueprint[i]

						if not t_cont(charm_parts, part_id) then
							filtered_bp[#filtered_bp + 1] = part_id
						end
					end

					blueprint = filtered_bp
				end
			end

			w_unit:base():assemble_from_blueprint(factory_id, blueprint, true)
		else
			w_unit:base():assemble(factory_id, true)
		end

		return w_unit
	end

	local new_unit = spawn_weapon(self._item_pos, self._item_rot, false)
	local second_unit = nil

	if new_unit:base().AKIMBO then
		second_unit = spawn_weapon(self._item_pos + self._item_rot:x() * -10 + self._item_rot:z() * -7 + self._item_rot:y() * -5, self._item_rot * Rotation(0, 8, -10), true)

		new_unit:link(new_unit:orientation_object():name(), second_unit)
		second_unit:base():tweak_data_anim_stop("unequip")
		second_unit:base():tweak_data_anim_play("equip")
	end

	new_unit:base():tweak_data_anim_stop("unequip")
	new_unit:base():tweak_data_anim_play("equip")

	custom_data = custom_data or {}
	custom_data.id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

	custom_data.fov_scale = true

	self:_set_item_unit(new_unit, nil, nil, nil, second_unit, custom_data)
	mrotation.set_yaw_pitch_roll(self._item_rot_mod, 90, 0, 0)

	return new_unit
end

function MenuSceneManager:_set_item_unit(unit, oobb_object, max_mod, type, second_unit, custom_data)
	self:remove_item()

	self._current_weapon_id = nil
	local scene_template = custom_data and custom_data.scene_template and self._scene_templates[custom_data.scene_template] or type == "mask" and self._scene_templates.blackmarket_mask or self._scene_templates.blackmarket_item
	self._item_pos = custom_data and custom_data.item_pos or Vector3(0, 0, 200)

	if custom_data and custom_data.item_offset then
		self._item_pos = self._item_pos + custom_data.item_offset
	end

	local item_yaw = self._item_yaw
	local item_pitch = self._item_pitch
	local item_roll = self._item_roll
	self._item_yaw = 0
	self._item_pitch = 0
	self._item_roll = 0

	mrotation.set_yaw_pitch_roll(self._item_rot, self._item_yaw, self._item_pitch, self._item_roll)
	mrotation.multiply(self._item_rot, self._item_rot_mod)

	self._item_unit = {
		unit = unit,
		name = unit:name(),
		second_unit = second_unit
	}

	unit:set_position(self._item_pos)
	unit:set_rotation(self._item_rot)
	unit:set_moving(2)

	local oobb = oobb_object and unit:get_object(Idstring(oobb_object)):oobb() or unit:oobb()
	self._current_item_oobb_object = oobb_object and unit:get_object(Idstring(oobb_object)) or unit
	local oobb_size = oobb:size()
	local max = math.max(oobb_size.x, oobb_size.y)
	max = math.max(max, oobb_size.z)
	local offset_dir = (scene_template.target_pos - scene_template.camera_pos):normalized()
	self._item_max_size = math.max(max * (max_mod or 1), 20)
	local pos = Vector3(self._item_pos.x, self._item_pos.y, self._item_pos.z)
	pos = pos - offset_dir * 90--(150 - self._item_max_size)
	self._item_rot_pos = pos

	self._current_item_fov_mod = nil
	if custom_data.fov_scale then
		--self._current_item_fov_mod = (80+self._item_max_size)*0.5
	end
	self._item_zoom = nil

	self:_set_item_offset(oobb, true)

	self._item_yaw = item_yaw or 0
	self._item_pitch = item_pitch or 0
	self._item_roll = item_roll or 0

	mrotation.set_yaw_pitch_roll(self._item_rot, self._item_yaw, self._item_pitch, self._item_roll)
	mrotation.multiply(self._item_rot, self._item_rot_mod)
end



function MenuSceneManager:setup_camera()
	if self._camera_values then
		return
	end

	local ref = self._bg_unit:get_object(Idstring("a_camera_reference"))
	local target_pos = Vector3(0, 0, ref:position().z)
	self._camera_values = {
		camera_pos_current = ref:position():rotate_with(Rotation(90))
	}
	self._camera_values.camera_pos_target = self._camera_values.camera_pos_current
	self._camera_values.target_pos_current = target_pos
	self._camera_values.target_pos_target = self._camera_values.target_pos_current
	self._camera_values.fov_current = self._standard_fov
	self._camera_values.fov_target = self._camera_values.fov_current
	self._camera_object = World:create_camera()

	self._camera_object:set_near_range(3)
	self._camera_object:set_far_range(250000)
	self._camera_object:set_fov(self._standard_fov)
	self._camera_object:set_rotation(self._camera_start_rot)
	self:_use_environment("standard")

	self._vp = managers.viewport:new_vp(0, 0, 1, 1, "menu_main")

	self._vp:set_width_mul_enabled()

	self._director = self._vp:director()
	self._shaker = self._director:shaker()
	self._camera_controller = self._director:make_camera(self._camera_object, Idstring("menu"))

	self._director:set_camera(self._camera_controller)
	self._director:position_as(self._camera_object)
	self._camera_controller:set_both(self._camera_object)
	self._camera_controller:set_target(self._camera_start_rot:y() * 100 + self._camera_start_rot:x() * 6)
	self:_set_camera_position(self._camera_values.camera_pos_current)
	self:_set_target_position(self._camera_values.camera_pos_target)
	self._vp:set_camera(self._camera_object)
	self._vp:set_active(true)
	self._vp:camera():set_width_multiplier(CoreMath.width_mul(1.7777777777777777))
	self:_set_dimensions()
	self._shaker:play("breathing", 0.2)

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "_resolution_changed"))
	self._sky_rotation_angle = 0
	self._environment_modifier_id = managers.viewport:create_global_environment_modifier(sky_orientation_data_key, true, function ()
		return self:_sky_rotation_modifier()
	end)
end

function MenuSceneManager:_set_target_position(pos)
	self._camera_controller:set_target(pos)
end
function MenuSceneManager:_set_camera_position(pos)
	self._camera_controller:set_camera(pos)
end

local target_pos_vector = Vector3()

tweak_data.gui.mod_preview_min_fov = -40
tweak_data.gui.mod_preview_max_fov = 20
function MenuSceneManager:change_fov(zoom, amount)
	if self._can_change_fov then
		self._item_zoom = self._item_zoom or 0
		if zoom == "in" then
			--self._fov_mod = math.clamp((self._fov_mod or 0) + ((amount or 0.45)*5) * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
			--self._item_zoom = math.clamp((self._item_zoom or 0) + 5 * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
			--self._item_unit.unit:set_position(self._item_pos-Vector3(0,10,0))
			if self._item_zoom > tweak_data.gui.mod_preview_min_fov then
				self._item_zoom = self._item_zoom -5
				self._item_rot_pos = self._item_rot_pos+Vector3(0,-5,0)
			end
		elseif zoom == "out" then
			--self._fov_mod = math.clamp((self._fov_mod or 0) - ((amount or 0.45)*5) * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
			--self._item_zoom = math.clamp((self._item_zoom or 0) - 5 * (self._change_fov_sensitivity or 1), tweak_data.gui.mod_preview_min_fov, tweak_data.gui.mod_preview_max_fov)
			--self._item_unit.unit:set_position(self._item_pos-Vector3(0,-10,0))
			if self._item_zoom < tweak_data.gui.mod_preview_max_fov then
				self._item_zoom = self._item_zoom +5
				self._item_rot_pos = self._item_rot_pos+Vector3(0,5,0)
			end
		end
		log(self._item_zoom)

		if self._current_scene_template and self._scene_templates[self._current_scene_template] and self._scene_templates[self._current_scene_template].item_pos then
			mvector3.lerp(target_pos_vector, self._camera_values.target_pos_target, self._scene_templates[self._current_scene_template].item_pos, math.max(-self._fov_mod / 20, 0))
			target_pos_vector = Vector3(1500, 2000, 0)
			log(tostring(self._item_offset))
			--self._item_offset = Vector3(0,0,0)
			--self._item_offset_target = Vector3(0,0,0)
			self:_set_target_position(target_pos_vector)
		end
	end
end

function MenuSceneManager:update(t, dt)
	if self._one_frame_delayed_clbks and #self._one_frame_delayed_clbks > 0 then
		for _, clbk in ipairs(self._one_frame_delayed_clbks) do
			clbk()
		end

		self._one_frame_delayed_clbks = {}
	end

	if self._delayed_callbacks then
		local callbacks = self._delayed_callbacks

		if callbacks[1] and callbacks[1][1] < t then
			local clbk_data = table.remove(callbacks, 1)
			local clbk = clbk_data[2]

			if #callbacks == 0 then
				self._delayed_callbacks = nil
			end

			clbk(clbk_data[3])
		end
	end

	if self._camera_values and self._transition_time then
		self._transition_time = math.min(self._transition_time + dt, 1)
		local bezier_value = math.bezier(self._transition_bezier, self._transition_time)

		if self._transition_time == 1 then
			self._transition_time = nil

			self:dispatch_transition_done()
			managers.skilltree:check_reset_message()
			managers.infamy:check_reset_message()
		end

		local camera_pos = math.lerp(self._camera_values.camera_pos_current, self._camera_values.camera_pos_target, bezier_value)
		local target_pos = math.lerp(self._camera_values.target_pos_current, self._camera_values.target_pos_target, bezier_value)
		local fov = math.lerp(self._camera_values.fov_current, self._camera_values.fov_target, bezier_value)
		self._current_fov = fov

		self:_set_camera_position(camera_pos)
		self:_set_target_position(target_pos)

		if self._character_values and not self._transition_time and #self._character_dynamic_bodies > 0 then
			self._enabled_character_dynamic_bodies = math.max(self._enabled_character_dynamic_bodies and self._enabled_character_dynamic_bodies or 0, 1)
		end
	elseif self._character_values and not mvector3.equal(self._character_values.pos_current, self._character_values.pos_target) then
		mvector3.lerp(self._character_values.pos_current, self._character_values.pos_current, self._character_values.pos_target, dt * 20)
		self._character_unit:set_position(self._character_values.pos_current)
	end

	if self._enabled_character_dynamic_bodies then
		self._enabled_character_dynamic_bodies = self._enabled_character_dynamic_bodies - 1

		if self._enabled_character_dynamic_bodies == 0 then
			self._enabled_character_dynamic_bodies = nil
		end
	end

	if self._camera_object and self._new_fov ~= self._current_fov + (self._fov_mod or 0) then
		self._new_fov = self._current_fov + (self._fov_mod or 0)

		self._camera_object:set_fov(self._new_fov)
	end

	if self._weapon_transition_time then
		self._weapon_transition_time = math.min(self._weapon_transition_time + dt, 1)
		local bezier_value = math.bezier(self._transition_bezier, self._weapon_transition_time)

		if self._item_offset_target then
			self._item_offset = math.lerp(self._item_offset_current, self._item_offset_target, bezier_value)
		end
	end

	if self._item_unit and self._item_unit.unit and not self._disable_item_updates and not self._item_grabbed then
		if not managers.blackmarket:currently_customizing_mask() and not self._disable_rotate then
			self._item_yaw = (self._item_yaw + 5 * dt) % 360
		end

		self._item_pitch = math.lerp(self._item_pitch, 0, 10 * dt)
		self._item_roll = math.lerp(self._item_roll, 0, 10 * dt)

		mrotation.set_yaw_pitch_roll(self._item_rot_temp, self._item_yaw, self._item_pitch, self._item_roll)
		mrotation.set_zero(self._item_rot)
		mrotation.multiply(self._item_rot, self._camera_object:rotation())
		mrotation.multiply(self._item_rot, self._item_rot_temp)
		mrotation.multiply(self._item_rot, self._item_rot_mod)
		self._item_unit.unit:set_rotation(self._item_rot)

		local new_pos = self._item_rot_pos + self._item_offset:rotate_with(self._item_rot)

		self._item_unit.unit:set_position(new_pos)
		self._item_unit.unit:set_moving(2)
	end

	if self._fade_down_lights then
		for _, light in ipairs(self._fade_down_lights) do
			light:set_multiplier(0)
		end
	end

	if self._active_lights then
		for _, light in ipairs(self._active_lights) do
			light:set_multiplier(0.8)
		end
	end

	self:_update_safe_scene(t, dt)
end

--SET INITIAL CUSTOM FOV
function MenuSceneManager:set_scene_template(template, data, custom_name, skip_transition)
	if not skip_transition and (self._current_scene_template == template or self._current_scene_template == custom_name) then
		return
	end

	local template_data = nil

	if not skip_transition then
		managers.menu_component:play_transition()

		self._fov_mod = 0

		if self._camera_object then
			self._camera_object:set_fov(self._current_fov + (self._fov_mod or 0))
		end

		template_data = data or self._scene_templates[template]
		self._current_scene_template = custom_name or template
		self._character_values = self._character_values or {}

		if template_data.character_pos then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()

			mvector3.set(self._character_values.pos_current, template_data.character_pos)
		elseif self._character_values.pos_target then
			self._character_values.pos_current = self._character_values.pos_current or Vector3()

			mvector3.set(self._character_values.pos_current, self._character_values.pos_target)
		end

		local set_character_position = false

		if template_data.character_pos then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()

			mvector3.set(self._character_values.pos_target, template_data.character_pos)

			set_character_position = true
		elseif self._character_values.pos_current then
			self._character_values.pos_target = self._character_values.pos_target or Vector3()

			mvector3.set(self._character_values.pos_target, self._character_values.pos_current)

			set_character_position = true
		end

		if set_character_position and self._character_values.pos_target then
			self._character_unit:set_position(self._character_values.pos_target)
		end

		if _G.IS_VR then
			if template_data.character_rot then
				self._character_unit:set_rotation(template_data.character_rot)
			else
				local a = self._bg_unit:get_object(Idstring("a_reference"))

				self._character_unit:set_rotation(a:rotation())
			end
		end

		if template_data and template_data.recreate_character and self._player_character_name then
			self:set_character(self._player_character_name, true)
		end

		self:_chk_character_visibility(self._character_unit)

		if self._lobby_characters then
			for _, unit in pairs(self._lobby_characters) do
				self:_chk_character_visibility(unit)
			end
		end

		if self._henchmen_characters then
			for _, unit in pairs(self._henchmen_characters) do
				self:_chk_character_visibility(unit)
			end
		end

		self:_use_environment(template_data.environment or "standard")
		self:post_ambience_event(template_data.ambience_event or "menu_main_ambience")

		self._camera_values.camera_pos_current = self._camera_values.camera_pos_target
		self._camera_values.target_pos_current = self._camera_values.target_pos_target
		self._camera_values.fov_current = self._camera_values.fov_target

		if self._transition_time then
			self:dispatch_transition_done()
		end

		self._transition_time = 1
		self._camera_values.camera_pos_target = template_data.camera_pos or self._camera_values.camera_pos_current
		self._camera_values.target_pos_target = template_data.target_pos or self._camera_values.target_pos_current
		self._camera_values.fov_target = template_data.custom_fov and self._current_item_fov_mod or template_data.fov or self._standard_fov

		self:_release_item_grab()
		self:_release_character_grab()

		self._use_item_grab = template_data.use_item_grab
		self._use_character_grab = template_data.use_character_grab
		self._use_character_grab2 = template_data.use_character_grab2
		self._use_character_pan = template_data.use_character_pan
		self._disable_rotate = template_data.disable_rotate or false
		self._disable_item_updates = template_data.disable_item_updates or false
		self._can_change_fov = template_data.can_change_fov or false
		self._can_move_item = template_data.can_move_item or false
		self._change_fov_sensitivity = template_data.change_fov_sensitivity or 1
		self._characters_deployable_visible = template_data.characters_deployable_visible or false

		self:set_character_deployable(managers.blackmarket:equipped_deployable(), false, 0)

		if template_data.remove_infamy_card and self._card_units and self._card_units[self._character_unit:key()] then
			local secondary = managers.blackmarket:equipped_secondary()

			if secondary then
				self:set_character_equipped_weapon(nil, secondary.factory_id, secondary.blueprint, "secondary", secondary.cosmetics)
			end
		end

		if template_data.hide_weapons then
			self:_delete_character_weapon(self._character_unit, "all")
		end

		if template_data.hide_mask then
			self:_delete_character_mask(self._character_unit)
		end

		if not _G.IS_VR then
			self:_select_character_pose()
		end

		if alive(self._menu_logo) then
			self._menu_logo:set_visible(not template_data.hide_menu_logo)
		end

		for _, event_unit in ipairs(self._event_units or {}) do
			event_unit:set_visible(template_data.show_event_units)
		end
	end

	if template_data and template_data.upgrade_object then
		self._temp_upgrade_object = template_data.upgrade_object

		self:_set_item_offset(template_data.upgrade_object:oobb())
	elseif self._use_item_grab and self._item_unit then
		if self._item_unit.unit then
			managers.menu_scene:_set_weapon_upgrades(self._current_weapon_id)
			self:_set_item_offset(self._current_item_oobb_object:oobb())
		else
			self._item_unit.scene_template = {
				template = template,
				data = data,
				custom_name = custom_name
			}
		end
	end

	if not skip_transition then
		local fade_lights = {}

		for _, light in ipairs(self._fade_down_lights) do
			if light:multiplier() ~= 0 and template_data.lights and not table.contains(template_data.lights, light) then
				table.insert(fade_lights, light)
			end
		end

		for _, light in ipairs(self._active_lights) do
			table.insert(fade_lights, light)
		end

		self._fade_down_lights = fade_lights
		self._active_lights = {}

		if template_data.lights then
			for _, light in ipairs(template_data.lights) do
				light:set_enable(true)
				table.insert(self._active_lights, light)
			end
		end
	end

	if template_data then
		if template_data.use_workbench_room then
			self:spawn_workbench_room(template_data.workbench_name)

			if template == "blackmarket_armor" then
				self:_change_workbench_room_lights()
			else
				self:_reset_workbench_room_lights()
			end
		else
			self:delete_workbench_room()
		end
	end
end

function MenuSceneManager:_set_item_offset(oobb, instant)
	local center = oobb:center()

	if self._item_unit.second_unit then
		center = math.lerp(self._item_unit.second_unit:oobb():center(), oobb:center(), 0.5)
	end

	local offset = (self._item_unit.unit:orientation_object():position() - center):rotate_with(self._item_rot:inverse())
	self._weapon_transition_time = self._weapon_transition_time and (self._weapon_transition_time == 1 and 0 or 1 - self._weapon_transition_time) or 0

	if instant then
		self._weapon_transition_time = 1
	end

	self._item_offset_current = self._item_offset_target or offset
	self._item_offset_target = offset
	self._item_offset = self._item_offset or offset
end]]