local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local material_defaults = {
	diffuse_layer1_texture = Idstring("units/payday2_cash/safes/default/base_gradient/base_default_df"),
	diffuse_layer2_texture = Idstring("units/payday2_cash/safes/default/pattern_gradient/gradient_default_df"),
	diffuse_layer0_texture = Idstring("units/payday2_cash/safes/default/pattern/pattern_default_df"),
	diffuse_layer3_texture = Idstring("units/payday2_cash/safes/default/sticker/sticker_default_df")
}
local material_textures = {
	pattern = "diffuse_layer0_texture",
	sticker = "diffuse_layer3_texture",
	pattern_gradient = "diffuse_layer2_texture",
	base_gradient = "diffuse_layer1_texture"
}
local material_variables = {
	cubemap_pattern_control = "cubemap_pattern_control",
	pattern_pos = "pattern_pos",
	uv_scale = "uv_scale",
	uv_offset_rot = "uv_offset_rot",
	pattern_tweak = "pattern_tweak",
	wear_and_tear = (managers.blackmarket and managers.blackmarket:skin_editor() and managers.blackmarket:skin_editor():active() or Application:production_build()) and "wear_tear_value" or nil
}

function NewRaycastWeaponBase:spawn_magazine_unit(pos, rot, hide_bullets)
	local mag_data = nil
	local mag_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("magazine", self._factory_id, self._blueprint)
	local mag_id = mag_list and mag_list[1]
	if not mag_id then return end
	local part_data = self._parts[mag_id]

	mag_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mag_id, self._factory_id, self._blueprint)
	if not mag_data or not part_data then return end
	local bullet_objects = mag_data.bullet_objects

	pos = pos or Vector3()
	rot = rot or Rotation()
	local is_thq = managers.weapon_factory:use_thq_weapon_parts()
	local use_cc_material_config = is_thq and self:get_cosmetics_data() and true or false
	local material_config_ids = Idstring("material_config")
	local mag_unit = World:spawn_unit(part_data.name, pos, rot)
	local new_material_config_ids = self:_material_config_name(mag_id, mag_data, use_cc_material_config, true)

	if mag_unit:material_config() ~= new_material_config_ids and DB:has(material_config_ids, new_material_config_ids) then
		mag_unit:set_material_config(new_material_config_ids, true)
	end

	if hide_bullets and bullet_objects then
		local prefix = bullet_objects.prefix

		for i = 1, bullet_objects.amount do
			local target_object = prefix~="g_bullet" and mag_unit:get_object(Idstring(prefix .. i)) or (
				mag_unit:get_object(Idstring(prefix))
				or mag_unit:get_object(Idstring("g_bullet_lod0"))
				or mag_unit:get_object(Idstring("g_bullet_recoil"))
				or mag_unit:get_object(Idstring("g_bullets"))
				or mag_unit:get_object(Idstring("g_bullet_01"))
			)
			local target_object2 = prefix=="g_bullet" and (mag_unit:get_object(Idstring("g_shell")) or mag_unit:get_object(Idstring("g_shell_lod0")))

			local ref_object = prefix~="g_bullet" and part_data.unit:get_object(Idstring(prefix .. i)) or (
				part_data.unit:get_object(Idstring(prefix))
				or part_data.unit:get_object(Idstring("g_bullet_lod0"))
				or part_data.unit:get_object(Idstring("g_bullet_recoil"))
				or part_data.unit:get_object(Idstring("g_bullets"))
				or part_data.unit:get_object(Idstring("g_bullet_01"))
			)
			local ref_object2 = prefix=="g_bullet" and (part_data.unit:get_object(Idstring("g_shell")) or part_data.unit:get_object(Idstring("g_shell_lod0")))

			if target_object then
				target_object:set_visibility(ref_object and ref_object:visibility() or false)
				if target_object2 then target_object2:set_visibility(ref_object2 and ref_object2:visibility() or false) end
			end
		end
	end

	local materials = {}
	local unit_materials = mag_unit:get_objects_by_type(Idstring("material")) or {}

	for _, m in ipairs(unit_materials) do
		if m:variable_exists(Idstring("wear_tear_value")) then
			table.insert(materials, m)
		end
	end

	local textures = {}
	local texture_key, p_type, value = nil
	local cosmetics_quality = self._cosmetics_quality
	local wear_tear_value = cosmetics_quality and tweak_data.economy.qualities[cosmetics_quality] and tweak_data.economy.qualities[cosmetics_quality].wear_tear_value or 1
	local uv_scale_value = self._cosmetics_pattern_scale and tweak_data.blackmarket.weapon_color_pattern_scales[self._cosmetics_pattern_scale] and tweak_data.blackmarket.weapon_color_pattern_scales[self._cosmetics_pattern_scale].uv_scale or Vector3(1, 1, 1)

	for _, material in pairs(materials) do
		material:set_variable(Idstring("wear_tear_value"), wear_tear_value)
		material:set_variable(Idstring("uv_scale"), uv_scale_value)

		p_type = managers.weapon_factory:get_type_from_part_id(mag_id)

		for key, variable in pairs(material_variables) do
			value = self:get_cosmetic_value("weapons", self._name_id, "parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key)

			if value then
				material:set_variable(Idstring(variable), value)
			end
		end

		for key, material_texture in pairs(material_textures) do
			value = self:get_cosmetic_value("weapons", self._name_id, "parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("weapons", self._name_id, "types", p_type, key) or self:get_cosmetic_value("weapons", self._name_id, key) or self:get_cosmetic_value("parts", mag_id, material:name():key(), key) or self:get_cosmetic_value("types", p_type, key) or self:get_cosmetic_value(key) or material_defaults[material_texture]

			if value then
				if type_name(value) ~= "Idstring" then
					value = Idstring(value)
				end

				Application:set_material_texture(material, Idstring(material_texture), value, Idstring("normal"))
			end
		end
	end

	return mag_unit
end

NewRaycastWeaponBase.magazine_collisions = {
	small = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	medium = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	},
	pistol = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_pistol"),
		Idstring("rp_box_collision_small")
	},
	smg = {
		Idstring("units/payday2/weapons/box_collision/box_collision_small_smg"),
		Idstring("rp_box_collision_small")
	},
	rifle = {
		Idstring("units/payday2/weapons/box_collision/box_collision_medium_ar"),
		Idstring("rp_box_collision_medium")
	},
	large_plastic = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_plastic"),
		Idstring("rp_box_collision_large")
	},
	large_metal = {
		Idstring("units/payday2/weapons/box_collision/box_collision_large_metal"),
		Idstring("rp_box_collision_large")
	}
}
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply

function NewRaycastWeaponBase:drop_magazine_object()
	if not self._name_id then
		return
	end

	local name_id = self._name_id

	for original_name, name in pairs(tweak_data.animation.animation_redirects) do
		if name == name_id then
			name_id = original_name

			break
		end
	end

	local w_td_crew = tweak_data.weapon[name_id .. "_crew"]

	for part_id, part_data in pairs(self._parts) do
		local part = tweak_data.weapon.factory.parts[part_id]

		if part and part.type == "magazine" then
			local pos = part_data.unit:position()
			local rot = part_data.unit:rotation()
			local vel = part_data.unit:velocity()
			local dropped_mag = self:spawn_magazine_unit(pos, rot, true)
			local mag_size = w_td_crew and w_td_crew.pull_magazine_during_reload or "medium"

			mvec3_set(tmp_vec1, dropped_mag:oobb():center())
			mvec3_sub(tmp_vec1, dropped_mag:position())
			mvec3_set(tmp_vec2, dropped_mag:position())
			mvec3_add(tmp_vec2, tmp_vec1)

			local dropped_col = World:spawn_unit(NewRaycastWeaponBase.magazine_collisions[mag_size][1], tmp_vec2, part_data.unit:rotation())

			dropped_col:link(NewRaycastWeaponBase.magazine_collisions[mag_size][2], dropped_mag)
			mvec3_set(tmp_vec3, self._name_id=="ching" and rot:z() or -rot:z())
			mvec3_mul(tmp_vec3, 100)
			dropped_col:push(self._name_id=="ching" and 2 or 20, tmp_vec3)
			managers.enemy:add_magazine(dropped_mag, dropped_col)
		end
	end
end



--MAG VISIBILITY
function NewRaycastWeaponBase:set_mag_visibility(visibility)
	local mag_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("magazine", self._factory_id, self._blueprint)
	table.addto(mag_list, managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("magazine2", self._factory_id, self._blueprint))

	for i, k in pairs(mag_list) do
		local part_data = self._parts[k]
		if part_data and part_data.unit then part_data.unit:set_visible(visibility) end
	end

	local obj_list = { "g_clip", "g_bullet", "g_bullets_1" }
	for i, k in pairs(self._parts) do
		for o, l in pairs(obj_list) do
			if k.unit:get_object(Idstring(l)) then k.unit:get_object(Idstring(l)):set_visibility(visibility) end
		end
	end
end
function NewRaycastWeaponBase:set_loader_visibility(visibility)
	local mag_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("loader", self._factory_id, self._blueprint)
	local mag_id = mag_list and mag_list[1]
	local part_data = self._parts[mag_id]
	if part_data and part_data.unit then part_data.unit:set_visible(visibility) end
end
function NewRaycastWeaponBase:set_casing_visibility(visibility)
	local mag_list = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("casing", self._factory_id, self._blueprint)
	local mag_id = mag_list and mag_list[1]
	local part_data = self._parts[mag_id]
	if part_data and part_data.unit then part_data.unit:set_visible(visibility) end
end
