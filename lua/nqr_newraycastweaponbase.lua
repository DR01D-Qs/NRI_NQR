local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local math_clamp = math.clamp
local math_lerp = math.lerp
local math_map_range_clamped = math.map_range_clamped
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local ids_single = Idstring("single")
local ids_auto = Idstring("auto")
local ids_burst = Idstring("burst")
local ids_volley = Idstring("volley")
local ids_dao = Idstring("dao")
local FIRE_MODE_IDS = {
	single = ids_single,
	dao = ids_dao,
	auto = ids_auto,
	burst = ids_burst,
	volley = ids_volley
}
NewRaycastWeaponBase = NewRaycastWeaponBase or class(RaycastWeaponBase)

require("lib/units/weapons/CosmeticsWeaponBase")
require("lib/units/weapons/ScopeBase")



function NewRaycastWeaponBase:clbk_assembly_complete(clbk, parts, blueprint)
	self._assembly_complete = true
	self._parts = parts
	self._blueprint = blueprint

	self:_update_fire_object()
	self:_update_stats_values()
	self:_refresh_gadget_list()
	self:_refresh_second_sight_list()

	if self._setup and self._setup.timer then
		self:set_timer(self._setup.timer)
	end

	local bullet_object_parts = {
		"magazine",
		"ammo",
		"underbarrel",
		"magazine_extra",
		"magazine_extra_2",
		"magazine_extra_3",
		"magazine_extra_4"
	}
	self._bullet_objects = {}

	for _, type in ipairs(bullet_object_parts) do
		local type_part = managers.weapon_factory:get_part_from_weapon_by_type(type, self._parts)

		if type_part then
			local bullet_objects = managers.weapon_factory:get_part_data_type_from_weapon_by_type(type, "bullet_objects", self._parts)

			if bullet_objects then
				local prefix = bullet_objects.prefix
				if prefix=="g_bullet" then
					local object = (type_part.unit:get_object(Idstring(prefix))
						or type_part.unit:get_object(Idstring("g_bullet_lod0"))
						or type_part.unit:get_object(Idstring("g_bullet_recoil"))
						or type_part.unit:get_object(Idstring("g_bullets"))
					)
					local object2 = type_part.unit:get_object(Idstring("g_shell")) or type_part.unit:get_object(Idstring("g_shell_lod0"))
					if object then
						self._bullet_objects[1] = self._bullet_objects[1] or {}
						table.insert(self._bullet_objects[1], {object2 and {object, object2} or object, type_part.unit})
					end
				else
					local offset = bullet_objects.offset or 0
					for i = 1 + offset, bullet_objects.amount + offset do
						local object = type_part.unit:get_object(Idstring(prefix .. i))
						if object then
							self._bullet_objects[i] = self._bullet_objects[i] or {}
							table.insert(self._bullet_objects[i], {object, type_part.unit})
						end
					end
				end
			end

			local bullet_belt = managers.weapon_factory:get_part_data_type_from_weapon_by_type(type, "bullet_belt", self._parts)

			if bullet_belt then
				local parent_id = managers.weapon_factory:get_part_id_from_weapon_by_type(type, self._blueprint)
				self._custom_units = self._custom_units or {}
				self._custom_units.bullet_belt = {
					parent = parent_id,
					parts = bullet_belt
				}
				local parts_tweak = tweak_data.weapon.factory.parts
				local bullet_index = bullet_objects and 1 + bullet_objects.amount + (bullet_objects.offset or 0) or 1

				for _, belt_part_id in ipairs(bullet_belt) do
					local unit = self._parts[belt_part_id].unit
					local belt_data = parts_tweak[belt_part_id]
					local belt_bullet_objects = belt_data.bullet_objects

					if belt_bullet_objects then
						local offset = belt_bullet_objects.offset or 0
						local prefix = belt_bullet_objects.prefix

						for i = 1 + offset, belt_bullet_objects.amount + offset do
							local object = unit:get_object(Idstring(prefix .. i))

							if object then
								print("bullet", bullet_index, i, unit, object)

								self._bullet_objects[bullet_index] = self._bullet_objects[bullet_index] or {}

								table.insert(self._bullet_objects[bullet_index], {
									object,
									unit
								})
							else
								Application:error("[NewRaycastWeaponBase:clbk_assembly_complete] Bullet object not found.", bullet_index, i, unit, object)
							end

							bullet_index = bullet_index + 1
						end
					end
				end
			end
		end
	end

	self._ammo_objects = nil

	if tweak_data.weapon[self._name_id].use_ammo_objects then
		self._ammo_objects = self._bullet_objects
		self._bullet_objects = nil
	end

	self:setup_underbarrel_data()
	self:_apply_cosmetics(clbk or function ()
	end)
	self:apply_texture_switches()
	self:apply_material_parameters()
	self:configure_scope()
	self:check_npc()
	self:call_on_digital_gui("set_firemode", self:fire_mode())
	self:_set_parts_enabled(self._enabled)

	if self._second_sight_data then
		self._second_sight_data.unit = self._parts[self._second_sight_data.part_id].unit
	end

	local category = tweak_data.weapon[self._name_id].use_data.selection_index == 2 and "primaries" or "secondaries"
	local slot = managers.blackmarket:equipped_weapon_slot(category)

	for _, part_id in ipairs(blueprint) do
		local colors = managers.blackmarket:get_part_custom_colors(category, slot, part_id, true)

		if colors then
			local mod_td = tweak_data.weapon.factory.parts[part_id]
			local part_data = parts[part_id]

			if colors[mod_td.sub_type] then
				local alpha = part_data.unit:base().GADGET_TYPE == "laser" and tweak_data.custom_colors.defaults.laser_alpha or 1

				part_data.unit:base():set_color(colors[mod_td.sub_type]:with_alpha(alpha))
			end

			if mod_td.adds then
				for _, add_part_id in ipairs(mod_td.adds) do
					if self._parts[add_part_id] and self._parts[add_part_id].unit:base() then
						local sub_type = tweak_data.weapon.factory.parts[add_part_id].sub_type

						self._parts[add_part_id].unit:base():set_color(colors[sub_type])
					end
				end
			end
		end
	end

	if self._setup and self._setup.user_unit then
		self:_chk_has_charms(self._parts, self._setup)
	end

	local to_load = {
		"units/pd2_dlc_peta/weapons/wpn_fps_shot_m37/wpn_fps_shot_m37",
		"units/pd2_dlc_lawp/weapons/wpn_fps_shot_ultima/wpn_fps_sho_ultima",
		"units/pd2_dlc_grv/weapons/wpn_fps_snp_siltstone/wpn_fps_snp_siltstone",

		["deagle"] = "units/pd2_dlc_rota/weapons/wpn_fps_sho_rota/wpn_fps_sho_rota",
		["x_deagle"] = "units/pd2_dlc_rota/weapons/wpn_fps_sho_rota/wpn_fps_sho_rota",
		["contraband"] = "units/pd2_dlc_spa/weapons/wpn_fps_snp_tti/wpn_fps_snp_tti",

		--regressions
		["amcar"] = "units/payday2/weapons/wpn_fps_ass_amcar/wpn_fps_ass_amcar",
		["amcar_crew"] = "units/payday2/weapons/wpn_fps_ass_amcar/wpn_fps_ass_amcar_npc",
		["m16"] = "units/payday2/weapons/wpn_fps_ass_m16/wpn_fps_ass_m16",
		["m16_crew"] = "units/payday2/weapons/wpn_fps_ass_m16/wpn_fps_ass_m16_npc",
		["olympic"] = "units/payday2/weapons/wpn_fps_smg_olympic/wpn_fps_smg_olympic",
		["olympic_crew"] = "units/payday2/weapons/wpn_fps_smg_olympic/wpn_fps_smg_olympic_npc",
		["victor"] = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor/wpn_fps_snp_victor",
		["victor_crew"] = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor/wpn_fps_snp_victor_npc",
		["rpk"] = "units/pd2_dlc_gage_lmg/weapons/wpn_fps_lmg_rpk/wpn_fps_lmg_rpk",
		["rpk_crew"] = "units/pd2_dlc_gage_lmg/weapons/wpn_fps_lmg_rpk/wpn_fps_lmg_rpk_npc",
		["akmsu"] = "units/payday2/weapons/wpn_fps_smg_akmsu/wpn_fps_smg_akmsu",
		["akmsu_crew"] = "units/payday2/weapons/wpn_fps_smg_akmsu/wpn_fps_smg_akmsu_npc",
		["tecci"] = "units/pd2_dlc_opera/weapons/wpn_fps_ass_tecci/wpn_fps_ass_tecci",
		["tecci_crew"] = "units/pd2_dlc_opera/weapons/wpn_fps_ass_tecci/wpn_fps_ass_tecci_npc",
		["glock_17"] = "units/payday2/weapons/wpn_fps_pis_g17/wpn_fps_pis_g17",
		["glock_17_crew"] = "units/payday2/weapons/wpn_fps_pis_g17/wpn_fps_pis_g17_npc",
		["g22c"] = "units/payday2/weapons/wpn_fps_pis_g22c/wpn_fps_pis_g22c",
		["g22c_crew"] = "units/payday2/weapons/wpn_fps_pis_g22c/wpn_fps_pis_g22c_npc",
		["x_g17"] = "units/pd2_dlc_butcher_mods/weapons/wpn_fps_pis_x_g17/wpn_fps_pis_x_g17",
		["x_g17_crew"] = "units/pd2_dlc_butcher_mods/weapons/wpn_fps_pis_x_g17/wpn_fps_pis_x_g17_npc",
		["x_g22c"] = "units/pd2_dlc_butcher_mods/weapons/wpn_fps_pis_x_g22c/wpn_fps_pis_x_g22c",
		["x_g22c_crew"] = "units/pd2_dlc_butcher_mods/weapons/wpn_fps_pis_x_g22c/wpn_fps_pis_x_g22c_npc",
	}
	for i, k in pairs(to_load) do
		if type(i)=="string" and i==self._name_id or type(i)~="string" then 
			if not managers.dyn_resource:is_resource_ready(Idstring("unit"), Idstring(k), "packages/dyn_resources") then
				managers.dyn_resource:load(Idstring("unit"), Idstring(k), "packages/dyn_resources", false)
			end
		end
	end


	clbk()
end



function NewRaycastWeaponBase:set_factory_data(factory_id)
	self._factory_id = factory_id

	local factory = tweak_data.weapon.factory[self._factory_id]
	self._name_id = (factory and factory.regression) or self._name_id
	self.name_id = self._name_id
end



--STAT TABLES TO NUMERIC
function NewRaycastWeaponBase:_update_stats_values(disallow_replenish, ammo_data)
	local wep_tweak = self:weapon_tweak_data() --tweak_data.weapon[self._name_id]
	self:_default_damage_falloff()
	self:_check_sound_switch()
	self._silencer = managers.weapon_factory:has_perk("silencer", self._factory_id, self._blueprint)
	local weapon_perks = managers.weapon_factory:get_perks(self._factory_id, self._blueprint) or {}
	if weapon_perks.fire_mode_auto then self._locked_fire_mode = ids_auto
	elseif weapon_perks.fire_mode_single then self._locked_fire_mode = ids_single
	elseif weapon_perks.fire_mode_burst then self._locked_fire_mode = ids_burst
	elseif weapon_perks.fire_mode_volley then self._locked_fire_mode = ids_volley
	else self._locked_fire_mode = nil end
	self._fire_mode = self._locked_fire_mode or self:get_recorded_fire_mode(self:_weapon_tweak_data_id()) or Idstring(wep_tweak.FIRE_MODE or "single")
	self._ammo_data = ammo_data or managers.weapon_factory:get_ammo_data_from_weapon(self._factory_id, self._blueprint) or {}
	self._can_shoot_through_shield = wep_tweak.can_shoot_through_shield
	self._can_shoot_through_enemy = wep_tweak.can_shoot_through_enemy
	self._can_shoot_through_wall = wep_tweak.can_shoot_through_wall
	self._armor_piercing_chance = wep_tweak.armor_piercing_chance or 0
	local primary_category = wep_tweak.categories and wep_tweak.categories[1]
	self._movement_penalty = tweak_data.upgrades.weapon_movement_penalty[primary_category] or 1
	self._burst_count = wep_tweak.BURST_COUNT or 3
	local fire_mode_data = wep_tweak.fire_mode_data or {}
	local volley_fire_mode = fire_mode_data.volley
	if volley_fire_mode then
		self._volley_spread_mul = volley_fire_mode.spread_mul or 1
		self._volley_damage_mul = volley_fire_mode.damage_mul or 1
		self._volley_ammo_usage = volley_fire_mode.ammo_usage or 1
		self._volley_rays = volley_fire_mode.rays or 1
	end
	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
	for part_id, stats in pairs(custom_stats) do
		if stats.movement_speed then self._movement_penalty = self._movement_penalty * stats.movement_speed end
		if tweak_data.weapon.factory.parts[part_id].type ~= "ammo" then
			if stats.ammo_pickup_min_mul then
				self._ammo_data.ammo_pickup_min_mul = self._ammo_data.ammo_pickup_min_mul and self._ammo_data.ammo_pickup_min_mul * stats.ammo_pickup_min_mul or stats.ammo_pickup_min_mul
			end

			if stats.ammo_pickup_max_mul then
				self._ammo_data.ammo_pickup_max_mul = self._ammo_data.ammo_pickup_max_mul and self._ammo_data.ammo_pickup_max_mul * stats.ammo_pickup_max_mul or stats.ammo_pickup_max_mul
			end
		end
		if stats.burst_count then self._burst_count = stats.burst_count end
		if stats.ammo_offset then self._ammo_data.ammo_offset = (self._ammo_data.ammo_offset or 0) + stats.ammo_offset end
		if stats.fire_rate_multiplier then self._ammo_data.fire_rate_multiplier = (self._ammo_data.fire_rate_multiplier or 0) + stats.fire_rate_multiplier - 1 end
		if stats.volley_spread_mul then self._volley_spread_mul = stats.volley_spread_mul end
		if stats.volley_damage_mul then self._volley_damage_mul = stats.volley_damage_mul end
		if stats.volley_ammo_usage then self._volley_ammo_usage = stats.volley_ammo_usage end
		if stats.volley_rays then self._volley_rays = stats.volley_rays end
	end
	local damage_falloff = {
		optimal_distance = self._optimal_distance,
		optimal_range = self._optimal_range,
		near_falloff = self._near_falloff,
		far_falloff = self._far_falloff,
		near_multiplier = self._near_multiplier,
		far_multiplier = self._far_multiplier
	}
	managers.blackmarket:modify_damage_falloff(damage_falloff, custom_stats)
	self._optimal_distance = damage_falloff.optimal_distance
	self._optimal_range = damage_falloff.optimal_range
	self._near_falloff = damage_falloff.near_falloff
	self._far_falloff = damage_falloff.far_falloff
	self._near_multiplier = damage_falloff.near_multiplier
	self._far_multiplier = damage_falloff.far_multiplier

	if self._ammo_data then
		if self._ammo_data.can_shoot_through_shield ~= nil then self._can_shoot_through_shield = self._ammo_data.can_shoot_through_shield end
		if self._ammo_data.can_shoot_through_enemy ~= nil then self._can_shoot_through_enemy = self._ammo_data.can_shoot_through_enemy end
		if self._ammo_data.can_shoot_through_wall ~= nil then self._can_shoot_through_wall = self._ammo_data.can_shoot_through_wall end
		if self._ammo_data.bullet_class ~= nil then
			self._bullet_class = CoreSerialize.string_to_classtable(self._ammo_data.bullet_class)
			self._bullet_slotmask = self._bullet_class:bullet_slotmask()
			self._blank_slotmask = self._bullet_class:blank_slotmask()
		end
		if self._ammo_data.armor_piercing_add ~= nil then self._armor_piercing_chance = math.clamp(self._armor_piercing_chance + self._ammo_data.armor_piercing_add, 0, 1) end
		if self._ammo_data.armor_piercing_mul ~= nil then self._armor_piercing_chance = math.clamp(self._armor_piercing_chance * self._ammo_data.armor_piercing_mul, 0, 1) end
	end

	local muzzleflashes = {
		"effects/payday2/particles/weapons/9mm_auto",
		"effects/payday2/particles/weapons/9mm_auto_fps",
		"effects/payday2/particles/weapons/9mm_auto_silence",
		"effects/payday2/particles/weapons/9mm_auto_silence_fps",
		"effects/payday2/particles/weapons/357_effect_fps",
		"effects/payday2/particles/weapons/556_auto",
		"effects/payday2/particles/weapons/556_auto_fps",
		"effects/payday2/particles/weapons/762_auto",
		"effects/payday2/particles/weapons/762_auto_fps",
		"effects/payday2/particles/weapons/308_muzzle",
		"effects/payday2/particles/weapons/big_762_auto",
		"effects/payday2/particles/weapons/big_762_auto_fps",
		"effects/payday2/particles/weapons/big_51b_auto_fps",
		"effects/payday2/particles/weapons/50cal_auto",
		"effects/payday2/particles/weapons/50cal_auto_fps",
		"effects/payday2/particles/weapons/50cal_browning_turret",
		"effects/payday2/particles/weapons/heat/flash",
		"effects/payday2/particles/weapons/air_pressure",
		"effects/payday2/particles/weapons/hailstorm_effect",
	}
	muzzleflashes = {}
	if self._silencer then
		self._muzzle_effect = Idstring(wep_tweak.muzzleflash_silenced or "effects/payday2/particles/weapons/9mm_auto_silence_fps")
	elseif self._ammo_data and self._ammo_data.muzzleflash ~= nil then
		self._muzzle_effect = Idstring(self._ammo_data.muzzleflash)
	else 
		self._muzzle_effect = Idstring(muzzleflashes[50] or wep_tweak.muzzleflash or "effects/particles/test/muzzleflash_maingun")
	end
	for _, part_id in ipairs(self._blueprint) do
		local part = tweak_data.weapon.factory.parts[part_id]
		if part.shell_eject then self._shell_ejection_effect_table.effect = Idstring(part.shell_eject) end
	end
	self._muzzle_effect_table = {
		effect = self._muzzle_effect,
		parent = self._obj_fire,
		force_synch = self._muzzle_effect_table.force_synch or false
	}
	if self._ammo_data and self._ammo_data.trail_effect ~= nil then
		self._trail_effect = Idstring(self._ammo_data.trail_effect)
	else
		self._trail_effect = wep_tweak.trail_effect and Idstring(wep_tweak.trail_effect) or Idstring("") --self.TRAIL_EFFECT
	end
	self._trail_effect_table = {
		effect = self._trail_effect,
		position = Vector3(),
		normal = Vector3()
	}

	--local base_stats = wep_tweak.stats
	local base_stats = WeaponDescription._get_base_stats(self:get_name_id())
	local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
	if not base_stats then return end
	local wep_tweak_default = tweak_data.weapon
	local stats = wep_tweak.stats and deep_clone(wep_tweak.stats) or {}
	local stats2 = deep_clone(wep_tweak)
	local modifier_stats = wep_tweak.stats_modifiers

	--ADD .STATS VALUES
	--[[for stat, value in pairs(stats) do
		if parts_stats[stat] then
			if stat=="barrel_length" then
				stats[stat] = parts_stats[stat]
			else
				stats[stat] = stats[stat] + parts_stats[stat]
			end
		end
	end]]

	--ADD CUSTOM STATS VALUES
	for stat, value in pairs(stats2) do
		if stat == "caliber" then
			if parts_stats[stat] then stats2[stat] = parts_stats[stat] end
		elseif stat == "ammotype" then
			if parts_stats[stat] then stats2[stat] = parts_stats[stat] end
		elseif stat == "barrel_length" then
			if parts_stats[stat] then stats2[stat] = parts_stats[stat] end
		elseif stat == "weight" then
			if parts_stats[stat] then stats2[stat] = stats2[stat] + parts_stats[stat] end
		elseif stat == "CLIP_AMMO_MAX" then
			if parts_stats[stat] then stats2[stat] = parts_stats[stat] end
		end
	end
	--self._current_stats_indices = stats
	self._current_stats = {}
	--for stat, value in pairs(stats) do
		--self._current_stats[stat] = wep_tweak_default.stats[stat] and value or 1 --stats_tweak_data[stat] and stats_tweak_data[stat][i] or 1
		--self._current_stats[stat] = value --stats_tweak_data[stat] and stats_tweak_data[stat][i] or 1
		--if modifier_stats and modifier_stats[stat] then
		--	self._current_stats[stat] = self._current_stats[stat] * modifier_stats[stat]
		--end
	--end
	self._current_stats.caliber = "9x19"
	for stat, value in pairs(stats2) do
		if stat == "caliber" then
			self._current_stats[stat] = value
		elseif stat == "ammotype" then
			self._current_stats[stat] = stats2[stat] and value or 1
		elseif stat == "barrel_length" then
			self._current_stats[stat] = stats2[stat] and value or 1
		elseif stat == "rise_factor" then
			self._current_stats[stat] = stats2[stat] and value or 1
		elseif stat == "weight" then
			self._current_stats[stat] = stats2[stat] and value or 1
		end
	end

	for stat, value in pairs(stats2) do
		if stat=="CLIP_AMMO_MAX" then
			if type(value)=="table" then
				local caliber = "9x19"
				for u, j in pairs(value) do if string.find(stats2.caliber or "", u) then caliber = u break end end
				self._current_stats[stat] = stats2[stat] and value[caliber] or wep_tweak.CLIP_AMMO_MAX or 1
			else
				self._current_stats[stat] = stats2[stat] and value or wep_tweak.CLIP_AMMO_MAX or 1
			end
			--self._current_stats[stat] = self._current_stats[stat] * (self:is_category("akimbo") and 2 or 1)
		end
	end
	self._current_stats.alert_size = stats.alert_size or 10000 --wep_tweak_default.stats.alert_size[math_clamp(stats.alert_size, 1, #stats_tweak_data.alert_size)]
	if modifier_stats and modifier_stats.alert_size then self._current_stats.alert_size = self._current_stats.alert_size * modifier_stats.alert_size end

	for i, k in pairs(base_stats) do
		if k.value then
			self._current_stats[i] = type(k.value)=="table" and 0 or (
				(type(k.value)=="string" or i=="barrel_length") and (parts_stats[i] or k.value)
			) or k.value+(parts_stats[i] or 0)
		end
	end
	self._current_stats.total_ammo_mod = parts_stats.totalammo or 0

	--[[if stats.concealment then --placeholder
		stats.suspicion = 1.6 --math.clamp(wep_tweak_default.stats.concealment - base_stats.concealment - (parts_stats.concealment or 0), 1, wep_tweak_default.stats.concealment)
		self._current_stats.suspicion = stats.suspicion --wep_tweak_default.stats.concealment--[stats.suspicion]
	end]]

	self._current_stats.zoom = 1

	if parts_stats and parts_stats.spread_multi then self._current_stats.spread_multi = parts_stats.spread_multi end

	local length = self._current_stats.barrel_length or 0
	local length_stock = nil
	local length_stock_addon = nil
	local barrel_md = {0,0,0,0,0}
	local barrel_md_bulk = {0,0}
	local device_md = {0,0,0,0,0}
	local result_md = {0,0,0,0,0}
	for _, part_id in ipairs(self._blueprint) do
		local part = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, self._factory_id, self._blueprint)

		if part.stats.CLIP_AMMO_MAX or part.type=="magazine" then
			if part.stats.weight then self._current_stats.empty_mag_weight = part.stats.weight end
			if part.stats.mag_amount then self._mag_amount = part.stats.mag_amount[2] end
			if part.stats.concealment and part.stats.concealment>0 then self._mag_size = part.stats.concealment end
		end

		if part.type~="second_sight" and part.stats.zoom then self._current_stats.zoom = part.stats.zoom end
		--if part.stats.zoom then self._current_stats.zoom = part.stats.zoom end

		if part.stats.shouldered then self._current_stats.shouldered = true end

		if part.stats.md_code then
			--[[if part.type=="barrel" then
				barrel_md = part.stats.md_code
				barrel_md_bulk = part.stats.md_bulk or barrel_md_bulk
			else
				device_md = part.stats.md_code
			end]]
			result_md = part.stats.md_code
		end

		if part.stats.length then
			length = length + part.stats.length

			if part.type=="stock" then
				length_stock = part.stats.length
			elseif part.type=="stock_addon" then
				length_stock_addon = part.stats.length
			end
		end
	end
	--managers.mission._fading_debug_output:script().log(tostring(length_stock), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring(length_stock_addon), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring(length), Color.white)

	if length_stock and length_stock_addon then length = length - length_stock end
	for i, k in pairs(tweak_data.weapon.factory[self._factory_id].default_blueprint) do
		self._current_stats.weight = self._current_stats.weight - (tweak_data.weapon.factory.parts[k].stats.weight or 0)
	end

	for i, k in pairs(managers.weapon_factory:get_assembled_blueprint(self._factory_id, self._blueprint)) do
		--managers.mission._fading_debug_output:script().log(tostring(k), Color.white)
	end
	--managers.mission._fading_debug_output:script().log(tostring("-"), Color.red)

	--result_md = ((barrel_md_bulk[1]>0) or (barrel_md_bulk[2]>0)) and device_md or barrel_md or result_md
	--for i, k in pairs(result_md) do managers.mission._fading_debug_output:script().log(tostring(i)..": "..tostring(k), Color.green) end
	local md_supp = result_md[1]~=0 and ((0.5)^(result_md[1])) or 1
	local md_flash = result_md[2]~=0 and (1-(result_md[2]*0.05)) or 1
	local md_comp = result_md[3]~=0 and ((0.92)^(result_md[3])) or 1
	local md_brake = result_md[4]~=0 and ((0.88)^(result_md[4])) or md_supp~=1 and ((0.92)^(result_md[1])) or 1
	local md_can = result_md[5]~=0 and (1+(result_md[5]*0.1)) or 1
	--managers.mission._fading_debug_output:script().log(tostring("barrel_md")..": "..tostring(barrel_md), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring("barrel_md_bulk")..": "..tostring(barrel_md_bulk), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring("device_md")..": "..tostring(device_md), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring("result_md")..": "..tostring(result_md), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring(result_md[1])..tostring(result_md[2])..tostring(result_md[3])..tostring(result_md[4])..tostring(result_md[5]), Color.yellow)

	self._length = length
	self._caliber = self._current_stats.caliber
	self._ammotype = self._current_stats.ammotype
	self._ammotype_data = tweak_data.weapon:nqr_ammotype_data(self._caliber, self._ammotype)
	--[[local wep_caliber = (tweak_data.weapon.calibers[self._current_stats.caliber] or tweak_data.weapon.calibers["9x19"])
	local wep_ammodata = nil
	for i, k in pairs(self._current_stats.ammotype~="Default" and wep_caliber or {}) do
		wep_ammodata = k.name==self._current_stats.ammotype and k
	end
	wep_ammodata = wep_ammodata or tweak_data.weapon.calibers[self._current_stats.caliber][1] ]]
	local default_barrel = self._ammotype_data.default_barrel
	local default_energy = self._ammotype_data.default_energy
	local proj_weight = self._ammotype_data.proj_weight
	local proj_type = self._ammotype_data.proj_type
	local proj_amount = self._ammotype_data.proj_amount or 1
	--[[local barrel = self._current_stats.barrel_length or 1
	local result_energy = (
		--LONGER
		barrel > default_barrel and
			default_energy + default_energy*(1-((default_barrel/barrel)^(1/2))) or (
		--SHORTER
		barrel < default_barrel and
			( default_energy * ( (barrel / default_barrel) ^ (1/3) ) ) or
		--SAME
			default_energy) )]]
	self._result_energy = tweak_data.weapon:nqr_energy(self._ammotype_data, self._barrel_length)
	self._result_speed = math.sqrt(2 * self._result_energy / (self._ammotype_data.proj_weight/15432))
	self._current_stats.mag_weight = ((self._current_stats.CLIP_AMMO_MAX or 1)*(self._ammotype_data.cartridge_weight or 1)*0.01) + (self._current_stats.empty_mag_weight or 0)
	if self._name_id=="m134" then self._current_stats.mag_weight = 10 end
	self._barrel_length = self._current_stats.barrel_length or self._barrel_length
	self._rise_factor = self._current_stats.rise_factor or self._rise_factor
	self._weight = (self._current_stats.weight or self._weight) + (self._current_stats.mag_weight or 0)
	self._alert_size = (default_energy * 10 * (md_supp*1.5)) + ((self._result_speed>343) and 10000 or 0)
	self._zoom = self._current_stats.zoom or self._zoom
	--self._spread = self:_get_spread()
	self._spread = tweak_data.weapon:nqr_spread(self._ammotype_data, self._barrel_length, self._name_id)
	--self._current_stats.spread = 1
	--self._spread = 1 --proj_weight / barrel / (proj_type~="pointy" and 1 or 2) / (wep_tweak.action~="moving_barrel" and 3 or 1)
	--[[self._kick = (0.1
		* ((self._result_energy/self._current_stats.weight)/4)
		* (self._current_stats.shouldered and 1 or 0.5)
		* ((wep_tweak.action and wep_tweak.action~="moving_barrel" and wep_tweak.action~="blowback" and wep_tweak.action~="roller_delayed") and 1 or 0.5)
		* (wep_tweak.rise_factor and 1+wep_tweak.rise_factor/5 or 1)
		* md_flash * md_brake * md_can
	)]]
	self._kick = tweak_data.weapon:nqr_kick(self._ammotype_data, self._barrel_length, self._weight, self._name_id)
	self._kick = (self._kick
		* (self._current_stats.shouldered and 1 or 0.5)
		* md_flash * md_brake * md_can
	)
	local stock_factor = (self._current_stats.shouldered and 1 or 2)
	local action_factor = wep_tweak.action and (
		(wep_tweak.action=="gatling" and 1)
		or (wep_tweak.action=="blowback" and 2)
		or (wep_tweak.action~="moving_barrel" and wep_tweak.action~="roller_delayed" and 3)
	) or 1
	--self._recoil = ( (self._result_energy/(math.sqrt(self._weight)))*(1+(self._rise_factor/5)) ) * action_factor * stock_factor * md_comp * (1+(self._kick*0.1)) * 0.005
	self._recoil = tweak_data.weapon:nqr_rise(self._ammotype_data, self._barrel_length, self._weight, self._name_id) * stock_factor * md_comp * (1+(self._kick*0.1))
	self._kick = self._kick * (2-((md_flash^2) * (md_supp~=1 and ((2-md_supp)^0.2) or md_brake) * (md_can^2)))
	if wep_tweak.recoilless then self._recoil = 0.5 self._kick = 0.5 end
	self._penetration = (
		(self._result_energy/proj_amount)
		* ((proj_type=="pointy" or proj_type=="arrow") and 1 or proj_type=="sphere" and 0.8 or 0.6)
		* (1.2 - tweak_data.weapon:nqr_bullet_size(self._caliber, self._ammotype_data) * 0.05)
	)
	self._CLIP_AMMO_MAX = self._current_stats.CLIP_AMMO_MAX or self._CLIP_AMMO_MAX
	self._spread_moving = self._current_stats.spread_moving or self._spread_moving
	self._extra_ammo = self._current_stats.extra_ammo or self._extra_ammo
	self._total_ammo_mod = self._current_stats.total_ammo_mod or self._total_ammo_mod
	self._movement_penalty = 1-self._weight/500 --placeholder
	if self._ammo_data.ammo_offset then self._extra_ammo = self._extra_ammo + self._ammo_data.ammo_offset end
	self._reload = self._current_stats.reload or self._reload
	self._spread_multiplier = self._current_stats.spread_multi or self._spread_multiplier
	self._scopes = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("scope", self._factory_id, self._blueprint)
	self._can_highlight_with_perk = managers.weapon_factory:has_perk("highlight", self._factory_id, self._blueprint)
	self._can_highlight_with_skill = managers.player:has_category_upgrade("weapon", "steelsight_highlight_specials")
	self._can_highlight = self._can_highlight_with_perk or self._can_highlight_with_skill
	self:_check_second_sight()
	self:_check_reticle_obj()
	if not disallow_replenish then self:replenish() end
	local user_unit = self._setup and self._setup.user_unit
	local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state
	self._fire_rate_multiplier = managers.blackmarket:fire_rate_multiplier(self._name_id, wep_tweak.categories, self._silencer, nil, current_state, self._blueprint)
	if self._ammo_data.fire_rate_multiplier then self._fire_rate_multiplier = self._fire_rate_multiplier + self._ammo_data.fire_rate_multiplier end
	self._rays = self._ammotype_data.proj_amount or 1
end



function NewRaycastWeaponBase:check_highlight_unit(unit)
	if not self._can_highlight then return end
	if not self._can_highlight_with_skill and self:is_second_sight_on() then return end
	if not unit or not unit:base() then return end
	if unit:character_damage() and unit:character_damage().dead and unit:character_damage():dead() then return end

	managers.game_play_central:auto_highlight_enemy(unit, true, true)
end



function NewRaycastWeaponBase:predict_bullet_objects()
	self:set_mag_visibility(true)
	self:_update_bullet_objects("get_ammo_total")
end
function NewRaycastWeaponBase:check_bullet_objects()
	if self._bullet_objects then
		self:_update_bullet_objects("get_ammo_remaining_in_clip")
	end
end



function RaycastWeaponBase:use_ammo(base, ammo_usage)
	local is_player = self._setup.user_unit == managers.player:player_unit()
	if not is_player then return end

	if ammo_usage > 0 then
		base:set_ammo_total(base:get_ammo_total() - ammo_usage)
	end
end



--RETICLE OBJ FOR EVERY SIGHT, BLANK_SIGHT
function NewRaycastWeaponBase:_check_reticle_obj()
	self._reticle_obj = nil
	local part = managers.weapon_factory:get_part_from_weapon_by_type("sight", self._parts)

	if part then
		local part_id = managers.weapon_factory:get_part_id_from_weapon_by_type("sight", self._blueprint)
		local part_tweak = tweak_data.weapon.factory.parts[part_id]

		if alive(part.unit) and not part_tweak.blank_sight then
			self._reticle_obj = part.unit:get_object(Idstring("g_reddot")) or part.unit:get_object(Idstring("g_gfx")) or part.unit:get_object(Idstring("g_reticle"))
		end
	end
end



--DETACH FIRE OBJ FROM SLIDE
function NewRaycastWeaponBase:_update_fire_object()
	local fire = managers.weapon_factory:get_part_from_weapon_by_type("barrel_ext", self._parts) or managers.weapon_factory:get_part_from_weapon_by_type("barrel", self._parts)

	if not fire then
		debug_pause("[NewRaycastWeaponBase:_update_fire_object] Weapon \"" .. tostring(self._factory_id) .. "\" is missing fire object !")
	elseif not fire.unit:get_object(Idstring("fire")) then
		debug_pause("[NewRaycastWeaponBase:_update_fire_object] Weapon \"" .. tostring(self._factory_id) .. "\" is missing fire object for part \"" .. tostring(fire.unit) .. "\"!")
	else
		self:change_fire_object(fire.unit:get_object(Idstring("fire")))
	end
end



function NewRaycastWeaponBase:can_magdrop()
	local wep_tweak = self:weapon_tweak_data()

	return not (
		self:use_shotgun_reload()
		or wep_tweak.feed_system=="break_action"
		or wep_tweak.feed_system=="clip_loader"
		or wep_tweak.feed_system=="backpack"
	)
end



function NewRaycastWeaponBase:update_visibility_state()
	self:_set_parts_visible(self._unit:visible(), true)
end
function NewRaycastWeaponBase:_set_parts_visible(visible, dont_touch_mag)
	if self._parts then
		local empty_s = Idstring("")
		local anim_groups, is_visible = nil
		local is_player = self._setup.user_unit == managers.player:player_unit()
		local steelsight_swap_state = false

		if is_player then
			steelsight_swap_state = self._setup.user_unit:camera() and alive(self._setup.user_unit:camera():camera_unit()) and self._setup.user_unit:camera():camera_unit():base():get_steelsight_swap_state() or false
		end

		for part_id, data in pairs(self._parts) do
			local unit = data.unit or data.link_to_unit

			local is_mag = (dont_touch_mag or self._magdrop) and tweak_data.weapon.factory.parts[part_id] and (
				tweak_data.weapon.factory.parts[part_id].type=="loader"
				or tweak_data.weapon.factory.parts[part_id].type=="magazine"
				or tweak_data.weapon.factory.parts[part_id].type=="magazine2"
				or tweak_data.weapon.factory.parts[part_id].type=="casing"
			)
			if not is_mag and alive(unit) then
				is_visible = visible and self:_is_part_visible(part_id)
				is_visible = is_visible and (self._parts[part_id].steelsight_visible == nil or self._parts[part_id].steelsight_visible == steelsight_swap_state)

				unit:set_visible(is_visible)

				if not visible and (not unit:base() or unit:base().GADGET_TYPE ~= "second_sight") then
					anim_groups = unit:anim_groups()

					for _, anim in ipairs(anim_groups) do
						if anim ~= empty_s then
							unit:anim_play_to(anim, 0)
							unit:anim_stop()
						end
					end
				end

				if unit:digital_gui() then
					unit:digital_gui():set_visible(visible)
				end

				if unit:digital_gui_upper() then
					unit:digital_gui_upper():set_visible(visible)
				end

				if unit:digital_gui_thd() then
					unit:digital_gui_thd():set_visible(visible)
				end
			end
		end
	end

	self:_chk_charm_upd_state()
end



function NewRaycastWeaponBase:fire(...)
	local ray_res = NewRaycastWeaponBase.super.fire(self, ...)

	--if self._fire_mode == ids_burst and self._bullets_fired > 1 and not self:weapon_tweak_data().sounds.fire_single then
		--self:_fire_sound()
	--end

	self:set_casing_visibility(true)

	return ray_res
end



--FIRE RAYCAST: SUPPORT FOR SHOOT_THROUGH_DATA
function NewRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data, ammo_usage)
	--[[if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end]]

	--[[if self._fire_mode == ids_volley then
		local ammo_usage_ratio = math.clamp(ammo_usage > 0 and ammo_usage / (self._volley_ammo_usage or ammo_usage) or 1, 0, 1)
		local rays = math.ceil(ammo_usage_ratio * (self._volley_rays or 1))
		spread_mul = spread_mul * (self._volley_spread_mul or 1)
		dmg_mul = dmg_mul * (self._volley_damage_mul or 1)
		local result = {
			rays = {}
		}

		for i = 1, rays do
			local raycast_res = NewRaycastWeaponBase.super._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)

			if raycast_res.enemies_in_cone then
				result.enemies_in_cone = result.enemies_in_cone or {}

				table.map_append(result.enemies_in_cone, raycast_res.enemies_in_cone)
			end

			result.hit_enemy = result.hit_enemy or raycast_res.hit_enemy

			table.list_append(result.rays, raycast_res.rays or {})
		end

		return result
	end]]

	return NewRaycastWeaponBase.super._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
end
function NewRaycastWeaponBase:get_damage_falloff(damage, col_ray, user_unit)
	if self._optimal_distance + self._optimal_range == 0 then
		return damage
	end

	local distance = col_ray.distance or mvector3.distance(col_ray.unit:position(), user_unit:position())
	local near_dist = self._optimal_distance - self._near_falloff
	local optimal_start = self._optimal_distance
	local optimal_end = self._optimal_distance + self._optimal_range
	local far_dist = optimal_end + self._far_falloff
	local near_mul = self._near_mul
	local optimal_mul = 1
	local far_mul = self._far_mul
	local primary_category = self:weapon_tweak_data().categories and self:weapon_tweak_data().categories[1]
	local current_state = user_unit and user_unit:movement() and user_unit:movement()._current_state

	if current_state and current_state:in_steelsight() then
		local mul = managers.player:upgrade_value(primary_category, "steelsight_range_inc", 1)
		optimal_end = optimal_end * mul
		far_dist = far_dist * mul
	end

	local damage_mul = 1

	--managers.mission._fading_debug_output:script().log(tostring(distance), Color.white)
	--[[if distance < self._optimal_distance then
		if self._near_falloff > 0 then
			damage_mul = math_map_range_clamped(distance, near_dist, optimal_start, near_mul, optimal_mul)
		else
			damage_mul = near_mul
		end
	elseif distance < optimal_end then
		damage_mul = optimal_mul
	elseif self._far_falloff > 0 then
		damage_mul = math_map_range_clamped(distance, optimal_end, far_dist, optimal_mul, far_mul)
	else
		damage_mul = far_mul
	end]]

	return damage * damage_mul
end



function NewRaycastWeaponBase:assemble_from_blueprint(factory_id, blueprint, clbk)
	local third_person = self:_third_person()
	local skip_queue = self:skip_queue()
	self._parts, self._blueprint = managers.weapon_factory:assemble_from_blueprint(factory_id, self._unit, blueprint, third_person, self:is_npc(), callback(self, self, "clbk_assembly_complete", clbk or function () end), skip_queue)

	self:_check_thq_align_anim()
	self:_update_stats_values()
end

function NewRaycastWeaponBase:_refresh_second_sight_list()
	local second_sights = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("second_sight", self._factory_id, self._blueprint)
	local forbidden = managers.weapon_factory:_get_forbidden_parts(self._factory_id, self._blueprint)

	table.sort(second_sights, function (a, b)
		return b < a
	end)

	self._second_sights = {}

	for _, part_id in ipairs(second_sights) do
		if tweak_data.weapon.factory.parts[part_id].sub_type~="ironsight" and not forbidden[part_id] then
			table.insert(self._second_sights, {
				part_id = part_id,
				unit = self._parts and self._parts[part_id] and self._parts[part_id].unit,
				piggyback = tweak_data.weapon.factory.parts[part_id] and tweak_data.weapon.factory.parts[part_id].sub_type=="piggyback",
			})
		end
	end

	local has_sight = nil
	local has_second_sight = nil
	for _, part_id in ipairs(self._blueprint) do
		if tweak_data.weapon.factory.parts[part_id].type=="sight" then has_sight = true end
		if tweak_data.weapon.factory.parts[part_id].type=="second_sight" then has_second_sight = true end
	end
	local user_unit = self._setup and self._setup.user_unit
	local current_state = alive(user_unit) and user_unit:movement() and user_unit:movement()._current_state
	--if (not has_sight) and has_second_sight then
		--self:toggle_second_sight(current_state)
		--self._second_sight_on = 1
	--end
	--managers.mission._fading_debug_output:script().log(tostring(self._second_sight_on), Color.red)
	--for i, k in pairs(tweak_data.weapon.factory.parts[part_id] or {}) do managers.mission._fading_debug_output:script().log(tostring(i)..": "..tostring(k), Color.white) end
end

function NewRaycastWeaponBase:_ads_mod()
	if self.AKIMBO then return 0.5 end

	local parts = {}
	local has_sight = nil
	local has_magnifier = nil
	local sightpairs = nil

	for _, id in ipairs(managers.weapon_factory:get_assembled_blueprint(self._factory_id, self._blueprint)) do
		local part = managers.weapon_factory:_part_data(id, self._factory_id)
		table.insert(parts, id)

		if part.sightpairs then sightpairs = deep_clone(part.sightpairs) end

		if (part.type=="sight" and not part.blank_sight)
		or part.type=="ironsight"
		or part.sub_type=="ironsight"
		then has_sight = true end

		if part.type=="second_sight" and part.stats.zoom then has_magnifier = true end
	end

	if not has_sight then
		return self:is_second_sight_on() and (has_magnifier and 2 or 0) or 0
	elseif not sightpairs then
		return 0
	end

	local no_pair = 1.5
	for _, id in pairs(sightpairs) do
		if table.contains(parts, id) then no_pair = 0 break end
	end

	return no_pair
end

--GET DAMAGE: USE NEW STATS
--[[function NewRaycastWeaponBase:update_damage()
	local wep = tweak_data.weapon[self._name_id]
	local wep_cartridge = tweak_data.weapon.cartridges[wep.cartridge] or tweak_data.weapon.cartridges["9x19"]
	if self._blueprint then
		local parts_stats = managers.weapon_factory:get_stats(self._factory_id, self._blueprint)
		wep_cartridge = parts_stats.cartridge and tweak_data.weapon.cartridges[parts_stats.cartridge] or (tweak_data.weapon.cartridges[wep.cartridge] or "9x19")
	end
	local default_barrel = wep_cartridge.default_barrel or 1
	local default_energy = wep_cartridge.default_energy or 1
	local barrel = self._barrel_length or 1
	local result_damage = (
		--LONGER
		barrel > default_barrel and
			default_energy + default_energy*(1-((default_barrel/barrel)^(1/2))) or (
		--SHORTER
		barrel < default_barrel and
			--(default_energy * (1 - ((default_barrel - barrel) / default_barrel) ^ 1.5)) or
			( default_energy * ( (barrel / default_barrel) ^ (1/3) ) ) or
		--SAME
			default_energy) ) / 40 --250
	self.result_damage = result_damage
	self._damage = result_damage --(self._current_stats and self._current_stats.damage or 0) + self:damage_addend()) * self:damage_multiplier()
end]]
function NewRaycastWeaponBase:update_damage()
	self._damage = (self._result_energy or 0) / 40
end
--function NewRaycastWeaponBase:get_result_damage() return self.result_damage end

--GET SPREAD: USE NEW STATS
function NewRaycastWeaponBase:_get_spread(user_unit)
	local wep_tweak = self:weapon_tweak_data()

	--[[local current_state = user_unit:movement()._current_state
	if not current_state then return 0, 0 end

	local spread_values = self:weapon_tweak_data().spread
	--if not spread_values then return 0, 0 end

	local current_spread_value = spread_values[current_state:get_movement_state()]
	local spread_x, spread_y = nil

	if type(current_spread_value) == "number" then
		spread_x = self:_get_spread_from_number(user_unit, current_state, current_spread_value)
		spread_y = spread_x
	else
		spread_x, spread_y = self:_get_spread_from_table(user_unit, current_state, current_spread_value)
	end

	if current_state:in_steelsight() then
		local steelsight_tweak = spread_values.steelsight
		local multi_x, multi_y = nil

		if type(steelsight_tweak) == "number" then
			multi_x = 1 + 1 - steelsight_tweak
			multi_y = multi_x
		else
			multi_x = 1 + 1 - steelsight_tweak[1]
			multi_y = 1 + 1 - steelsight_tweak[2]
		end

		spread_x = spread_x * multi_x
		spread_y = spread_y * multi_y
	end

	if self._spread_multiplier then
		spread_x = spread_x * self._spread_multiplier[1]
		spread_y = spread_y * self._spread_multiplier[2]
	end]]

	--[[local wep_cartridge = tweak_data.weapon.cartridges[self._current_stats.cartridge] or tweak_data.weapon.cartridges["9x19"]
	local proj_weight = wep_cartridge.proj_weight
	local proj_type = wep_cartridge.proj_type
	local proj_amount = wep_cartridge.proj_amount or 1
	local barrel = self._barrel_length or 1
	--local spread = proj_amount * proj_weight^(1/(4+barrel)) * (proj_type=="pointy" and 0.6 or proj_type=="rounded" and 0.7 or 0.8) - 0.7 --self._current_stats.spread or self._spread
	local spread = (100+proj_weight)^(1/(4+(barrel)))
	spread = spread * (1+(proj_amount*0.2)) * (proj_type=="pointy" and 1.0 or proj_type=="rounded" and 1.2 or 1.4) -1.2
	local action_factor = wep_tweak.action and (
		(wep_tweak.action=="moving_barrel" and 1.2)
		or ((wep_tweak.action=="blowback" or wep_tweak.action=="roller_delayed") and 1.1)
		or 1
	) or 1.1]]

	spread = self._spread * 0.1

	return spread, spread --spread_x, spread_y
end
function NewRaycastWeaponBase:_get_spread_from_number(user_unit, current_state, current_spread_value)
	local spread = self:_get_spread_indices(current_state)
	return math.max(spread * current_spread_value * 10 / (self:weapon_tweak_data().barrel_length or 1), 0)
end
function NewRaycastWeaponBase:_get_spread_indices(current_state)
	local spread_index = self._current_stats_indices and self._current_stats_indices.spread or 1
	local spread_idx_x, spread_idx_y = nil
	if type(spread_index) == "number" then
		spread_idx_x = self:_get_spread_index(current_state, spread_index)
		spread_idx_y = spread_idx_x
	else
		spread_idx_x = self:_get_spread_index(current_state, spread_index[1])
		spread_idx_y = self:_get_spread_index(current_state, spread_index[2])
	end
	return spread_idx_x, spread_idx_y
end
function NewRaycastWeaponBase:_get_spread_index(current_state, spread_index)
	local cond_spread_addend = self:conditional_accuracy_addend(current_state)
	local spread_multiplier = 1
	spread_multiplier = spread_multiplier - (1 - self:spread_multiplier(current_state))
	spread_multiplier = spread_multiplier - (1 - self:conditional_accuracy_multiplier(current_state))
	spread_multiplier = self:_convert_add_to_mul(spread_multiplier)
	local spread_addend = self:spread_index_addend(current_state) + cond_spread_addend
	spread_index = math.ceil((spread_index + spread_addend) * spread_multiplier)
	--spread_index = math.clamp(spread_index, 1, #tweak_data.weapon.stats.spread)

	return spread_index --tweak_data.weapon.stats.spread[spread_index]
end

--GET CLIP: USE NEW STATS
function NewRaycastWeaponBase:calculate_ammo_max_per_clip()
	return (self._CLIP_AMMO_MAX or tweak_data.weapon[self._name_id].CLIP_AMMO_MAX) * (self.AKIMBO and 2 or 1)
end

--GET ZOOM
function NewRaycastWeaponBase:zoom()
	local second_sight = self:get_active_second_sight()

	if second_sight then
		return tweak_data.weapon.factory.parts[second_sight.part_id].stats.zoom or 1
	end

	if self:is_second_sight_on() and self._second_sight_data then
		return tweak_data.weapon.factory.parts[self._second_sight_data.part_id].stats.zoom or 1
	end

	return NewRaycastWeaponBase.super.zoom(self)
end

--TOGGLE_SECOND_SIGHT: STOP MESSING WITH REEQUIP
function NewRaycastWeaponBase:toggle_second_sight(current_state)
	if not self._enabled then return false end

	--[[local second_sight_on = self._second_sight_on or 0
	local second_sights = self._second_sights

	if second_sights then
		if second_sights[1] and second_sights[1].piggyback then return end

		second_sight_on = (second_sight_on + 1) % (#second_sights + 1)

		--self:set_second_sight_on(second_sight_on, false, second_sights, current_state)

		return true
	end

	return false]]

	local second_sight_on = self._second_sight_on or 0
	local second_sights = self._second_sights
	local sight_order = NQR.settings.nqr_sight_order==1 and 1 or -1

	local assembled_blueprint = managers.weapon_factory:get_assembled_blueprint(self._factory_id, self._blueprint)
	local forbidden = managers.weapon_factory:_get_forbidden_parts(self._factory_id, assembled_blueprint)
	local override = managers.weapon_factory:_get_override_parts(self._factory_id, assembled_blueprint)
	local part = nil
	local has_main_sight = nil
	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			local part = managers.weapon_factory:_part_data(part_id, self._factory_id, override)
			has_main_sight = has_main_sight or (part.type=="sight" and not part.blank_sight and part.sub_type~="ironsight")
		end
	end

	if second_sights then
		--self._second_sight_on = (self._second_sight_on + sight_order) % (#self._second_sights + 1)
		--if second_sights[1] and second_sights[1].piggyback then second_sight_on = 1 end
		--self:set_second_sight_on(second_sight_on, false, second_sights, current_state)
		if not has_main_sight and second_sights[1] and second_sights[1].piggyback then
			--self:set_second_sight_on(1, false, second_sights, current_state)
			return false
		else
			return true
		end
	end

	return false
end

function NewRaycastWeaponBase:_set_parts_enabled(enabled)
	if self._parts then
		local anim_groups = nil
		local empty_s = Idstring("")

		for part_id, data in pairs(self._parts) do
			if alive(data.unit) then
				if not enabled and (not data.unit:base() or data.unit:base().GADGET_TYPE ~= "second_sight") then
					anim_groups = data.unit:anim_groups()

					for _, anim in ipairs(anim_groups) do
						if anim ~= empty_s then
							data.unit:anim_play_to(anim, 0)
							data.unit:anim_stop()
						end
					end
				end

				data.unit:set_enabled(enabled)

				if data.unit:digital_gui() then
					data.unit:digital_gui():set_visible(enabled)
				end

				if data.unit:digital_gui_upper() then
					data.unit:digital_gui_upper():set_visible(enabled)
				end

				if data.unit:digital_gui_thd() then
					data.unit:digital_gui_thd():set_visible(enabled)
				end
			end
		end
	end
end



function NewRaycastWeaponBase:start_shooting()
	if self._fire_mode == ids_volley then
		self:_start_charging()

		self._shooting = true

		return
	end

	NewRaycastWeaponBase.super.start_shooting(self)

	if self._fire_mode == ids_burst then
		self._shooting_count = (self._burst_count or 3) * (self.AKIMBO and 2 or 1)
	end
end



--[[START SHOOTING: DAO SHIT
function NewRaycastWeaponBase:start_shooting()
	if self._fire_mode == ids_volley then
		self:_start_charging()

		self._shooting = true

		return
	end

	NewRaycastWeaponBase.super.start_shooting(self)

	if self._fire_mode == ids_burst then
		self._shooting_count = self._burst_count or 3
	end
end
function NewRaycastWeaponBase:trigger_held(...)
	if self._fire_mode == ids_burst then
		if not self._shooting_count or self._shooting_count == 0 then
			return false
		end
	elseif self._fire_mode == ids_volley then
		local volley_charge_time = self:charge_max_t()
		local fired = false

		if volley_charge_time == 0 or self._volley_charge_start_t + volley_charge_time <= managers.player:player_timer():time() then
			fired = self:fire(...)

			if fired then
				self._next_fire_allowed = self._unit:timer():time() + self:charge_cooldown_t()

				self:_fire_sound()
			end
		end

		return fired
	end

	local fired = NewRaycastWeaponBase.super.trigger_held(self, ...)

	if self._fire_mode == ids_burst then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then
			self._shooting_count = 0
		elseif fired then
			self._shooting_count = self._shooting_count - 1
		end
	end

	return fired
end]]
function NewRaycastWeaponBase:trigger_held(...)
	if self._fire_mode == ids_burst then
		if not self._shooting_count or self._shooting_count == 0 then
			return false
		end
	elseif self._fire_mode == ids_volley then
		local volley_charge_time = self:charge_max_t()
		local fired = false

		if self._volley_charge_start_t + volley_charge_time <= managers.player:player_timer():time() then
			fired = self:fire(...)

			if fired then
				self._next_fire_allowed = self._unit:timer():time() + self:charge_cooldown_t()

				--self:_fire_sound()
			end
		end

		return fired
	end

	local fired = NewRaycastWeaponBase.super.trigger_held(self, ...)

	if self._fire_mode == ids_burst then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then
			self._shooting_count = 0
		elseif fired then
			self._shooting_count = self._shooting_count - 1
		end
	end

	return fired
end



--SPAWN WEAPON: BOLT DROPPED CHECK
function NewRaycastWeaponBase:on_enabled(...)
	NewRaycastWeaponBase.super.on_enabled(self, ...)
	self:_set_parts_enabled(true)
	self:set_gadget_on(self._last_gadget_idx, false)

	if self:clip_empty() then
		--self:tweak_data_anim_play_at_end("magazine_empty")

		local wep_tweak = self:weapon_tweak_data()
		if self.delayed_t1==0 then
			self:tweak_data_anim_play("fire", 1, 0.1, true)
		elseif self.delayed_t1==-1 then
			self:tweak_data_anim_stop("fire")
			self:tweak_data_anim_stop("reload")
			self:tweak_data_anim_play("reload", 1, wep_tweak.r_ass and 0.033 or nil, true)
		end
	end

	self:_chk_charm_upd_state()
end

--ANIM PLAY: OFFSET ARGUMENT, DONT_PLAY ARGUMENT
function NewRaycastWeaponBase:tweak_data_anim_play(anim, speed_multiplier, offsetq, dont_play, skip_sao_check)
	--managers.mission._fading_debug_output:script().log(tostring(anim).." "..tostring(speed_multiplier),  Color.white)

	if not skip_sao_check and self:weapon_tweak_data().sao and anim=="fire" and dont_play then
		self:tweak_data_anim_stop("fire", true)
		return
	end

	local orig_anim = anim
	local unit_anim = self:_get_tweak_data_weapon_animation(orig_anim)
	local effect_manager = World:effect_manager()
	speed_multiplier = speed_multiplier or 1
	local data = tweak_data.weapon.factory[self._factory_id]
	local offset = (offsetq and offsetq~=0) and offsetq or self:_get_anim_start_offset(anim_name)

	if self._active_animation_effects[anim] then for _, effect in ipairs(self._active_animation_effects[anim]) do World:effect_manager():kill(effect) end end
	self._active_animation_effects[anim] = {}

	if data.animations and data.animations[unit_anim] then
		local anim_name = data.animations[unit_anim]
		local ids_anim_name = Idstring(anim_name)
		local length = self._unit:anim_length(ids_anim_name)

		self._unit:anim_stop(ids_anim_name)
		if not dont_play then self._unit:anim_play_to(ids_anim_name, length, speed_multiplier) end

		if offset then self._unit:anim_set_time(ids_anim_name, offset) end
	end
	if data.animation_effects and data.animation_effects[unit_anim] then
		local effect_table = data.animation_effects[unit_anim]

		if effect_table then
			effect_table = clone(effect_table)
			effect_table.parent = effect_table.parent and self._unit:get_object(effect_table.parent)
			local effect = effect_manager:spawn(effect_table)

			table.insert(self._active_animation_effects[anim], effect)
		end
	end

	for part_id, data in pairs(self._parts) do
		if data.unit and data.animations and data.animations[unit_anim] then
			local anim_name = data.animations[unit_anim]
			local ids_anim_name = Idstring(anim_name)
			local length = data.unit:anim_length(ids_anim_name)

			data.unit:anim_stop(ids_anim_name)
			if not dont_play then data.unit:anim_play_to(ids_anim_name, length, speed_multiplier) end

			if offset then data.unit:anim_set_time(ids_anim_name, offset) end
		end
		if data.unit and data.animation_effects and data.animation_effects[unit_anim] then
			local effect_table = data.animation_effects[unit_anim]

			if effect_table then
				effect_table = clone(effect_table)
				effect_table.parent = effect_table.parent and data.unit:get_object(effect_table.parent)
				local effect = effect_manager:spawn(effect_table)

				table.insert(self._active_animation_effects[anim], effect)
			end
		end
	end


	self:set_reload_objects_visible(true, anim)
	if not dont_play then NewRaycastWeaponBase.super.tweak_data_anim_play(self, orig_anim, speed_multiplier, offsetq, dont_play) end

	return true
end
function NewRaycastWeaponBase:tweak_data_anim_stop(anim, skip_sao_check)
	--managers.mission._fading_debug_output:script().log(tostring(anim),  Color.white)

	if not skip_sao_check and self:weapon_tweak_data().sao and anim=="fire" then
		self:tweak_data_anim_play("fire", 1, 0.05, true, true)
		return
	end

	--managers.mission._fading_debug_output:script().log(tostring(anim),  Color.white)
	local orig_anim = anim
	local unit_anim = self:_get_tweak_data_weapon_animation(orig_anim)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[unit_anim] then
		local anim_name = data.animations[unit_anim]

		self._unit:anim_stop(Idstring(anim_name))
	end

	for part_id, data in pairs(self._parts) do
		if data.unit and data.animations and data.animations[unit_anim] then
			local anim_name = data.animations[unit_anim]

			data.unit:anim_stop(Idstring(anim_name))
		end
	end

	self:set_reload_objects_visible(false, anim)

	if self._active_animation_effects[anim] then
		for _, effect in ipairs(self._active_animation_effects[anim]) do
			World:effect_manager():kill(effect)
		end

		self._active_animation_effects[anim] = nil
	end

	NewRaycastWeaponBase.super.tweak_data_anim_stop(self, orig_anim)
end
function NewRaycastWeaponBase:tweak_data_anim_pause(anim, offset, second)
	local unit_anim = anim
	local data = tweak_data.weapon.factory[self._factory_id]
	local selfcsc = (second and alive(self._second_gun)) and self._second_gun:base() or self

	if data.animations and data.animations[unit_anim] then
		selfcsc._unit:anim_set_time(Idstring(data.animations[unit_anim]), offset)
	end
	for part_id, data in pairs(selfcsc._parts) do
		if data.animations and data.animations[unit_anim] then
			data.unit:anim_set_time(Idstring(data.animations[unit_anim]), offset)
		end
	end

	return true
end

function NewRaycastWeaponBase:set_reload_objects_visible(visible, anim)
	local data = tweak_data.weapon.factory[self._factory_id]
	local reload_objects = anim and data.reload_objects and data.reload_objects[anim]

	if reload_objects then
		self._reload_objects[self._name_id] = reload_objects
	elseif self._reload_objects then
		reload_objects = self._reload_objects[self.name_id]
	end

	if reload_objects then
		self:set_objects_visible(self._unit, reload_objects, visible)
	end

	for part_id, part in pairs(self._parts) do
		local reload_objects = anim and part.reload_objects and part.reload_objects[anim]

		if reload_objects then
			self._reload_objects[part_id] = reload_objects
		elseif self._reload_objects then
			reload_objects = self._reload_objects[part_id]
		end

		if reload_objects then
			self:set_objects_visible(part.unit, reload_objects, visible)
		end
	end
end



--NEW FUNCTION: MAGDROP
function NewRaycastWeaponBase:do_magdrop(fresh_mag)
	self._magdrop = true

	if self:use_shotgun_reload() then
		self:set_ammo_total(math.max(self:get_ammo_total() - 1, 0))
		managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())

		if not self:is_category("revolver") then self:drop_magazine_object() end

		return
	end

	if not self:is_category("revolver") then self:drop_magazine_object() end
	if self._second_gun then self._second_gun:base():drop_magazine_object() end

	local amount_to_deduct = fresh_mag and self:get_ammo_max_per_clip() or (math.max(self:get_ammo_remaining_in_clip()-self:get_chamber(), 0))
	self:set_ammo_total(math.max(self:get_ammo_total()-amount_to_deduct, 0))
	self:set_ammo_remaining_in_clip(math.min(self:get_chamber(), self:get_ammo_remaining_in_clip()))
	managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())

	--managers.mission._fading_debug_output:script().log(tostring("csc"), Color.white)
	self:set_mag_visibility(false)
end

--RELOAD_SPEED_MULTIPLIER: -
function NewRaycastWeaponBase:reload_speed_multiplier()
	if self._current_reload_speed_multiplier then
		return self._current_reload_speed_multiplier
	end

	local multiplier = 1

	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)

	if self._setup and alive(self._setup.user_unit) and self._setup.user_unit:movement() then
		local morale_boost_bonus = self._setup.user_unit:movement():morale_boost()

		if morale_boost_bonus then
			multiplier = multiplier + 1 - morale_boost_bonus.reload_speed_bonus
		end

		if self._setup.user_unit:movement():next_reload_speed_multiplier() then
			multiplier = multiplier + 1 - self._setup.user_unit:movement():next_reload_speed_multiplier()
		end
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "reload_weapon_faster") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "reload_weapon_faster", 1)
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "single_shot_fast_reload") then
		multiplier = multiplier + 1 - managers.player:temporary_upgrade_value("temporary", "single_shot_fast_reload", 1)
	end

	multiplier = multiplier + 1 - managers.player:get_property("shock_and_awe_reload_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:get_temporary_property("bloodthirst_reload_speed", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("team", "crew_faster_reload", 1)
	multiplier = self:_convert_add_to_mul(multiplier)
	multiplier = multiplier * self:reload_speed_stat()
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end

--RELOAD_EXPIRE_T: CHAMBER
function NewRaycastWeaponBase:reload_expire_t(is_not_empty)
	if self._use_shotgun_reload then
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(is_not_empty)
		local reload_shell_expire_t = self:reload_shell_expire_t(is_not_empty)
		local chamber = self:get_chamber()
		local ammo_total = self:get_ammo_total()
		local ammo_max_per_clip = self:get_ammo_max_per_clip() + (is_not_empty and chamber or 0)
		local ammo_remaining_in_clip = self:get_ammo_remaining_in_clip()
		local ammo_to_full = math.min(ammo_total - ammo_remaining_in_clip, ammo_max_per_clip - ammo_remaining_in_clip)
		local reload_num = shotgun_reload_tweak and math.min(ammo_to_full, shotgun_reload_tweak.reload_num or 1) or 1
		local ammo_to_reload = self._magdrop_shotgun and ammo_to_full or reload_num

		if shotgun_reload_tweak and shotgun_reload_tweak.reload_queue then
			local reload_expire_t = 0
			local queue_data = nil
			local queue_index = 0
			local queue_num = #shotgun_reload_tweak.reload_queue

			while ammo_to_reload > 0 do
				if queue_index == queue_num then
					reload_expire_t = reload_expire_t + (shotgun_reload_tweak.reload_queue_wrap or 0)
				end

				queue_index = queue_index % queue_num + 1
				queue_data = shotgun_reload_tweak.reload_queue[queue_index]
				reload_expire_t = reload_expire_t + queue_data.expire_t or 0.5666666666666667
				ammo_to_reload = ammo_to_reload - (queue_data.reload_num or 1)
			end

			return reload_expire_t, queue_data.reload_num
		end

		return math.ceil(ammo_to_reload / reload_num) * reload_shell_expire_t, reload_num
	end

	return nil
end

--UPDATE BULLETS: SUPPORT CHAMBER
function NewRaycastWeaponBase:_update_bullet_objects(ammo_func)
	if self._bullet_objects then
		local wep_tweak = self:weapon_tweak_data()
		local mechanical = wep_tweak.action=="bolt_action" or wep_tweak.action=="pump_action"
		--if self.r_cycle and self.r_stage==#self.r_cycle then ammo_func = "get_ammo_remaining_in_clip" end --todo

		for i, objects in pairs(self._bullet_objects) do
			for _, object in ipairs(objects) do
				if object[1] then
					local ammo_base = self:ammo_base()
					local ammo = ammo_base[ammo_func](ammo_base) - self:get_chamber()
					--managers.mission._fading_debug_output:script().log(tostring(ammo_base[ammo_func](ammo_base)).." - "..tostring(self:get_chamber()), Color.white)
					if type(object[1])=="table" then
						object[1][1]:set_visibility(i <= ammo)
						object[1][2]:set_visibility(i <= ammo)
					else
						object[1]:set_visibility(i <= ammo)
					end
				end
			end
		end
	end
end
--UPDATE RELOADING: CHAMBER
function NewRaycastWeaponBase:update_reloading(t, dt, time_left)
	if self._use_shotgun_reload and self._next_shell_reloded_t and self._next_shell_reloded_t < t then
		local chamber = self:get_chamber()
		local speed_multiplier = self:reload_speed_multiplier()
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(not self._started_reload_empty)
		local ammo_to_reload = 1
		local next_queue_data = nil

		if shotgun_reload_tweak and shotgun_reload_tweak.reload_queue then
			self._shotgun_queue_index = self._shotgun_queue_index % #shotgun_reload_tweak.reload_queue + 1

			if self._shotgun_queue_index == #shotgun_reload_tweak.reload_queue then
				self._next_shell_reloded_t = self._next_shell_reloded_t + (shotgun_reload_tweak.reload_queue_wrap or 0)
			end

			local queue_data = shotgun_reload_tweak.reload_queue[self._shotgun_queue_index]
			ammo_to_reload = queue_data and queue_data.reload_num or 1
			next_queue_data = shotgun_reload_tweak.reload_queue[self._shotgun_queue_index + 1]
			self._next_shell_reloded_t = self._next_shell_reloded_t + (next_queue_data and next_queue_data.expire_t or 0.5666666666666667) / speed_multiplier
		else
			self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t(not self._started_reload_empty) / speed_multiplier
			ammo_to_reload = shotgun_reload_tweak and shotgun_reload_tweak.reload_num or 1
		end

		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip()+chamber, self:get_ammo_remaining_in_clip() + ammo_to_reload))

		managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

		if not next_queue_data or not next_queue_data.skip_update_ammo then
			self:update_ammo_objects()
		end

		return true
	end
end
function NewRaycastWeaponBase:update_r_stage(t)
	if not (self.r_time and self.r_steps and self.r_cycle) then return end

	local temp_r_stage = self.r_starting_stage
	local time_passed = self.r_time - (self.r_expire_t - t)

	--local count = self.r_penalty or 0
	--for i=(self.r_starting_stage or 1), #self.r_cycle do
		--count = count + self.r_steps[ self.r_cycle[i] ]
		--if count>time_passed then temp_r_stage = i>1 and i break end
	--end

	for i=(self.r_starting_stage or 1), #self.r_cycle do
		if self.r_stages[i]>time_passed then temp_r_stage = i>1 and i break end
	end

	if self.r_stage~=temp_r_stage then
		self.r_stage = temp_r_stage

		--if self.r_cycle[self.r_stage]=="r_get_new_mag_in" then self:predict_bullet_objects() end
	end
end
function NewRaycastWeaponBase:update_bolting(t, reloading)
	local wep_tweak = self:weapon_tweak_data()
	if wep_tweak.chamber==0 then return end
	local open_reload = self.r_cycle and self.r_cycle[#self.r_cycle]=="r_bolt_release_2"
	local bolt_opened = open_reload and self.r_stage and self.r_stage>=table.get_key(self.r_cycle, "r_bolt_release_1") and self.r_stage~=#self.r_cycle
	local wep_mechanical = wep_tweak.action=="bolt_action" or wep_tweak.action=="pump_action" or wep_tweak.action=="lever_action"
	--managers.mission._fading_debug_output:script().log(tostring(self._is_bolting~=2 and ((self.r_stage and self.r_cycle and self.r_cycle[1]=="r_bolt_release_1"))), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring((open_reload and not self.r_stage) or ((not self.r_expire_t) and (t < bolting_stage_t1))), Color.white)

	if not self._bolting_interupted or self.r_expire_t then
		local gonna_bolt_release = open_reload or (
			self.r_stages and #self.r_stages>1
			and self.r_stages[#self.r_stages]~=self.r_stages[#self.r_stages-1]
			and (self.r_cycle[#self.r_cycle]=="r_bolt_release") 
			--and ((self.r_cycle[#self.r_cycle]=="r_bolt_release" and self.r_steps[#self.r_stages]>0) or self.r_cycle[#self.r_cycle]=="r_bolt_release_2")
		)
		local end_t = (
			((wep_mechanical or open_reload) and self.r_expire_t and gonna_bolt_release and (self.r_expire_t+self:weapon_fire_rate()*0.2))
			--or (wep_mechanical and ((self.r_exit_expire_init and self.r_exit_expire_t) or (not self.r_expire_t and self._next_fire_allowed)))
			or (wep_mechanical and (not self.r_expire_t and self._next_fire_allowed))
		)
		if end_t and t<end_t then
			local bolting_stage_t1 = end_t - self:weapon_fire_rate()*0.5
			local bolting_stage_t2 = end_t - self:weapon_fire_rate()*0.2

				--[[--if not self._is_bolting and (t < bolting_stage_t1) and not (self.r_stage and self.r_cycle and self.r_cycle[1]=="r_bolt_release_1") then
				if (open_reload and not self.r_stage) or (t < bolting_stage_t1) then
					self._is_bolting = 1
				--elseif self._is_bolting~=2 and ((self.r_stage and self.r_cycle and self.r_cycle[1]=="r_bolt_release_1") or ((bolting_stage_t1 < t) and (t < bolting_stage_t2))) then
				end
				if self.r_expire_t and bolt_opened or ((bolting_stage_t1 < t) and (t < bolting_stage_t2)) then
					if self._is_bolting~=2 and self.chamber_state~=0 and not (not self.chamber_state and not wep_mechanical and self:clip_empty()) then
						if not self.chamber_state and self:get_ammo_remaining_in_clip()>0 and self._next_fire_allowed and self._next_fire_allowed<t then
							self:set_ammo_remaining_in_clip(self:get_ammo_remaining_in_clip()-1)
							self:use_ammo(self, 1)
							managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
						end

						self.chamber_state = 0
						self:_spawn_shell_eject_effect()
					end

					self._is_bolting = 2
				--elseif self._is_bolting==2 and (bolting_stage_t2 < t) then
				elseif (bolting_stage_t2 < t) then
					self._is_bolting = nil
					self._bolting_interupted = nil
					--self:_update_bullet_objects("get_ammo_max_per_clip")
					if self:get_ammo_remaining_in_clip()>0 then
						self.chamber_state = nil
					end
				end]]

			if self.r_expire_t and open_reload then
				if not self.r_stage and not (bolting_stage_t2 < t) then
					self._is_bolting = 1
				elseif bolt_opened then
					if self._is_bolting~=2 and self.chamber_state~=0 and not (not self.chamber_state and not wep_mechanical and self:clip_empty()) then
						if not self.chamber_state and self:get_ammo_remaining_in_clip()>0 and self._next_fire_allowed and self._next_fire_allowed<t then
							self.chamber_state = 0
							self:set_ammo_remaining_in_clip(self:get_ammo_remaining_in_clip()-1)
							self:use_ammo(self, 1)
							managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
						end

						self.chamber_state = 0
						self:_spawn_shell_eject_effect()
					end

					self._is_bolting = 2
				elseif (bolting_stage_t2 < t) then
					self._is_bolting = nil
					self._bolting_interupted = nil
					--self:_update_bullet_objects("get_ammo_max_per_clip")
					if self:get_ammo_remaining_in_clip()>0 then
						self.chamber_state = nil
					end
				end
			else
				if (t < bolting_stage_t1) then
					self._is_bolting = 1
				elseif (bolting_stage_t1 < t) and (t < bolting_stage_t2) then
					if self._is_bolting~=2 and self.chamber_state~=0 and not (not self.chamber_state and not wep_mechanical and self:clip_empty()) then
						if not self.chamber_state and self:get_ammo_remaining_in_clip()>0 and self._next_fire_allowed and self._next_fire_allowed<t then
							self:set_ammo_remaining_in_clip(self:get_ammo_remaining_in_clip()-1)
							self:use_ammo(self, 1)
							managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
						end

						self.chamber_state = 0
						self:_spawn_shell_eject_effect()
					end

					self._is_bolting = 2
				elseif (bolting_stage_t2 < t) then
					self._is_bolting = nil
					self._bolting_interupted = nil
					--self:_update_bullet_objects("get_ammo_max_per_clip")
					if self:get_ammo_remaining_in_clip()>0 then
						self.chamber_state = nil
						--if self.r_stage then self:on_reload() end
					end
				end
			end
		else
			self._is_bolting = nil
		end
	end

	if self.chamber_state~=0 and not (not self.chamber_state and not wep_mechanical and self:clip_empty()) then
		--if self.r_stage and self.r_stage==(#self.r_cycle-1) and self.r_cycle[#self.r_cycle]=="r_bolt_release" then
			--self._bolting_interupted = nil
		--end

		--[[if (self.r_stage and self.r_cycle and self.r_cycle[1]=="r_bolt_release_1")
		or (self._is_bolting==2) then
			if not self.chamber_state and self:get_ammo_remaining_in_clip()>0 and self._next_fire_allowed and self._next_fire_allowed<t then
				self:set_ammo_remaining_in_clip(self:get_ammo_remaining_in_clip()-1)
				self:use_ammo(self, 1)
				managers.hud:set_ammo_amount(self:selection_index(), self:ammo_info())
			end

			self.chamber_state = 0
			self:_spawn_shell_eject_effect()
		end]]
	end
end
function NewRaycastWeaponBase:interupt_bolting(forced)
	local wep_tweak = self:weapon_tweak_data()
	--if (wep_tweak.action~="bolt_action" and self._is_bolting~=1) or (wep_tweak.action=="bolt_action" and not self._is_bolting) then return end
	--managers.mission._fading_debug_output:script().log(tostring("interupt attempt, bolting: ")..tostring(self._is_bolting), Color.red)
	--managers.mission._fading_debug_output:script().log(tostring(self._bolting_interupted), Color.red)
	if (self._bolting_interupted or not self._is_bolting and forced)
	or (wep_tweak.action~="bolt_action" and self._is_bolting==2)
	or (self._is_bolting==1 and not self.chamber_state)
	then
		return
	end
	managers.mission._fading_debug_output:script().log(tostring("bolting interupted"), Color.red)
	--if state_data then state_data.reload_exit_expire_t = nil end
	self._bolting_interupted = true
	self:tweak_data_anim_stop("fire")
	self:tweak_data_anim_stop("fire_steelsight")
	if self.chamber_state~=0 then self.chamber_state = -1 end
end

--WORK FOR BOTH RELOAD TYPES
function NewRaycastWeaponBase:started_reload_empty()
	--if self._use_shotgun_reload then
		return self._started_reload_empty
	--end

	--return nil
end

--START RELOAD: MOVED STARTED_RELOAD_EMPTY OUT OF HERE
function NewRaycastWeaponBase:start_reload(...)
	NewRaycastWeaponBase.super.start_reload(self, ...)

	if self._use_shotgun_reload then
		local speed_multiplier = 1 --self:reload_speed_multiplier()
		local t = managers.player:player_timer():time()
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(not self._started_reload_empty)

		if shotgun_reload_tweak and shotgun_reload_tweak.reload_queue then
			self._shotgun_queue_index = 0
			local next_queue_data = shotgun_reload_tweak.reload_queue[1]
			self._next_shell_reloded_t = t + next_queue_data.expire_t / speed_multiplier

			if not next_queue_data.skip_update_ammo then
				self:update_ammo_objects()
			end
		else
			--self._next_shell_reloded_t = t + self:_first_shell_reload_expire_t(not self._started_reload_empty) / speed_multiplier

			self:update_ammo_objects()
		end

		--self._current_reload_speed_multiplier = speed_multiplier
	end
end
--ON RELOAD: CHAMBER
function NewRaycastWeaponBase:on_reload(...)
	--local ammo_base = self._reload_ammo_base or self:ammo_base()
	local chamber = self:get_chamber()
	if self:get_ammo_remaining_in_clip()>=chamber then
		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip()+chamber))
	elseif self._setup.expend_ammo then
		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_total(), self:get_ammo_max_per_clip()))
	else
		self:set_ammo_remaining_in_clip(self:get_ammo_max_per_clip())
		self:set_ammo_total(self:get_ammo_max_per_clip())
	end

	managers.job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

	self._reload_ammo_base = nil



	local user_unit = managers.player:player_unit()

	if user_unit then
		user_unit:movement():current_state():send_reload_interupt()
	end

	self:set_reload_objects_visible(false)

	self._reload_objects = {}
end



function NewRaycastWeaponBase:_first_shell_reload_expire_t(is_not_empty, wep_swap)
	if self._use_shotgun_reload then
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(is_not_empty, wep_swap)
		local wep_tweak = wep_swap and tweak_data.weapon[wep_swap] or self:weapon_tweak_data()
		local first_shell_offset = shotgun_reload_tweak and shotgun_reload_tweak.reload_first_shell_offset or wep_tweak.timers.shotgun_reload_first_shell_offset or 0.33

		return self:reload_shell_expire_t(is_not_empty, wep_swap) - first_shell_offset
	end

	return nil
end
function NewRaycastWeaponBase:reload_shell_expire_t(is_not_empty, wep_swap)
	if self._use_shotgun_reload then
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(is_not_empty, wep_swap)
		local wep_tweak = wep_swap and tweak_data.weapon[wep_swap] or self:weapon_tweak_data()

		return shotgun_reload_tweak and shotgun_reload_tweak.reload_shell or wep_tweak.timers.shotgun_reload_shell or 0.5666666666666667
	end

	return nil
end
function NewRaycastWeaponBase:reload_enter_expire_t(is_not_empty, wep_swap)
	if self._use_shotgun_reload then
		local shotgun_reload_tweak = self:_get_shotgun_reload_tweak_data(is_not_empty)
		local wep_tweak = wep_swap and tweak_data.weapon[wep_swap] or self:weapon_tweak_data()

		return shotgun_reload_tweak and shotgun_reload_tweak.reload_enter or wep_tweak.timers.shotgun_reload_enter or 0.3
	end

	return nil
end
function NewRaycastWeaponBase:_get_shotgun_reload_tweak_data(is_not_empty, wep_swap)
	local wep_tweak = wep_swap and tweak_data.weapon[wep_swap] or self:weapon_tweak_data()

	if wep_tweak and wep_tweak.timers and wep_tweak.timers.shotgun_reload then
		return is_not_empty and wep_tweak.timers.shotgun_reload.not_empty or wep_tweak.timers.shotgun_reload.empty
	end

	return nil
end



--FAKE BIPODS
function NewRaycastWeaponBase:is_bipod_usable()
	local retval = false
	local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", self._parts)
	local bipod_unit = nil

	if bipod_part and bipod_part[1] then
		bipod_unit = bipod_part[1].unit:base()
	end

	if bipod_unit then
		retval = bipod_unit:is_usable()
	end

	return true--retval
end



--REPLENISH: REMOVE TOTAL AMMO SKILL MULTIPLIERS
function NewRaycastWeaponBase:replenish()
	local ammo_max_per_clip = self:calculate_ammo_max_per_clip()
	local ammo_max = (
		self._mag_amount
		and (self._mag_amount * (self:use_shotgun_reload() and 1 or (self._CLIP_AMMO_MAX or tweak_data.weapon[self._name_id].CLIP_AMMO_MAX)))
		or tweak_data.weapon[self._name_id].AMMO_MAX
	) + (self._total_ammo_mod or 0) + ammo_max_per_clip
	ammo_max = tweak_data.weapon[self._name_id].feed_system=="backpack" and tweak_data.weapon[self._name_id].AMMO_MAX or ammo_max

	self:set_ammo_max_per_clip(ammo_max_per_clip)
	self:set_ammo_max(ammo_max)
	self:set_ammo_total(ammo_max)
	self:set_ammo_remaining_in_clip(ammo_max_per_clip)

	self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP

	if self._assembly_complete then
		for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
			if gadget and gadget.replenish then
				gadget:replenish()
			end
		end
	end

	self:update_damage()
end
function NewRaycastWeaponBase:get_ammo_max_total()
	--return (self._mag_amount and (self._mag_amount * self:calculate_ammo_max_per_clip()) or tweak_data.weapon[self._name_id].AMMO_MAX) + self:calculate_ammo_max_per_clip()
	return (
		(self._mag_amount and (self._mag_amount * (self._CLIP_AMMO_MAX or tweak_data.weapon[self._name_id].CLIP_AMMO_MAX)) or tweak_data.weapon[self._name_id].AMMO_MAX)
		+ self:calculate_ammo_max_per_clip()
		+ (self._total_ammo_mod or 0)
	)
end



--CLIP_FULL: CHAMBER
function NewRaycastWeaponBase:clip_full()
	local wep_tweak = self:weapon_tweak_data()
	--return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip() + (self._use_shotgun_reload and wep_tweak.always_empty and 1 or self:get_chamber())
	return self:get_ammo_remaining_in_clip() == self:get_ammo_max_per_clip() + self:get_chamber()
end
