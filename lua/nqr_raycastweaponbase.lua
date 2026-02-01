local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_neg = mvector3.negate
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()
RaycastWeaponBase = RaycastWeaponBase or class(UnitBase)
RaycastWeaponBase.TRAIL_EFFECT = Idstring("effects/particles/weapons/weapon_trail")
RaycastWeaponBase.SHIELD_MIN_KNOCK_BACK = tweak_data.upgrades.values.player.shield_knock_bullet.max_damage
RaycastWeaponBase.SHIELD_KNOCK_BACK_CHANCE = tweak_data.upgrades.values.player.shield_knock_bullet.chance



function RaycastWeaponBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	--self._name_id = self.name or self.name_id or "amcar"
	--self.name_id = self.name or nil
	self._name_id = self.name_id or "amcar"
	self.name_id = nil
	self._visible = false

	self:_create_use_setups()

	self._setup = {}
	self._digest_values = SystemInfo:platform() == Idstring("WIN32")
	self._ammo_data = false
	self._do_shotgun_push = tweak_data.weapon[self._name_id].do_shotgun_push or false

	self:replenish()

	self._aim_assist_data = tweak_data.weapon[self._name_id].aim_assist
	self._autohit_data = tweak_data.weapon[self._name_id].autohit
	self._autohit_current = self._autohit_data and self._autohit_data.INIT_RATIO or 0
	self._shoot_through_data = {
		--kills = 0,
		from = Vector3()
	}
	self._can_shoot_through_shield = tweak_data.weapon[self._name_id].can_shoot_through_shield
	self._can_shoot_through_enemy = tweak_data.weapon[self._name_id].can_shoot_through_enemy
	self._can_shoot_through_wall = tweak_data.weapon[self._name_id].can_shoot_through_wall
	local bullet_class = tweak_data.weapon[self._name_id].bullet_class

	if bullet_class ~= nil then
		bullet_class = CoreSerialize.string_to_classtable(bullet_class)

		if bullet_class then
			self._bullet_class = bullet_class
		else
			Application:error("[RaycastWeaponBase:init] Unexisting class for bullet_class string ", weap_tweak.bullet_class, "defined for tweak data ID ", name_id)

			self._bullet_class = InstantBulletBase
		end
	else
		self._bullet_class = InstantBulletBase
	end

	self._bullet_slotmask = self._bullet_class:bullet_slotmask()
	self._blank_slotmask = self._bullet_class:blank_slotmask()
	self._next_fire_allowed = -1000
	self._obj_fire = self._unit:get_object(Idstring("fire"))
	self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	self._muzzle_effect_table = {
		force_synch = true,
		effect = self._muzzle_effect,
		parent = self._obj_fire
	}
	self._use_shell_ejection_effect = true
	self._obj_shell_ejection = self._unit:get_object(Idstring("a_shell"))
	--self._obj_shell_ejection = self:is_category("revolver") and self._unit:get_object(Idstring("a_body")) or self._unit:get_object(Idstring("a_shell"))
	self._shell_ejection_effect = Idstring(self:weapon_tweak_data().shell_ejection or "effects/payday2/particles/weapons/shells/shell_556")
	self._shell_ejection_effect_table = {
		effect = self._shell_ejection_effect,
		parent = self._obj_shell_ejection
	}
	self._sound_fire = SoundDevice:create_source("fire")

	self._sound_fire:link(self._unit:orientation_object())

	self._trail_effect = self:weapon_tweak_data().trail_effect and Idstring(self:weapon_tweak_data().trail_effect) or self.TRAIL_EFFECT
	self._trail_effect_table = {
		effect = self._trail_effect,
		position = Vector3(),
		normal = Vector3()
	}
	self._shot_fired_stats_table = {
		hit = false,
		weapon_unit = self._unit
	}
	self._magazine_empty_objects = {}
	self._concussion_tweak = self:weapon_tweak_data().concussion_data
	RaycastWeaponBase.shield_mask = RaycastWeaponBase.shield_mask or managers.slot:get_mask("enemy_shield_check")
	RaycastWeaponBase.enemy_mask = RaycastWeaponBase.enemy_mask or managers.slot:get_mask("enemies")
	RaycastWeaponBase.wall_mask = RaycastWeaponBase.wall_mask or managers.slot:get_mask("world_geometry")
	RaycastWeaponBase.wall_vehicle_mask = RaycastWeaponBase.wall_vehicle_mask or managers.slot:get_mask("world_geometry", "vehicles")
end



--STATS TABLES TO NUMERIC
function RaycastWeaponBase:setup(setup_data, damage_multiplier)
	self._autoaim = setup_data.autoaim
	local stats = tweak_data.weapon[self._name_id].stats
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_fires = {}
	local weapon_stats = tweak_data.weapon.stats

	if stats then
		self._zoom = self._zoom or stats.zoom --weapon_stats.zoom[stats.zoom]
		self._alert_size = self._alert_size or stats.alert_size --]weapon_stats.alert_size[
		self._suppression = 50 --stats.suppression--]weapon_stats.suppression--[ self._suppression or
		self._spread = self._spread or 0.5 --stats.spread--]weapon_stats.spread[ self._spread or
		self._recoil = self._recoil or stats.recoil--]weapon_stats.recoil[ self._recoil or
		self._spread_moving = stats.spread_moving--]weapon_stats.spread_moving--[ self._spread_moving or
		self._concealment = 0.6 --stats.concealment--]weapon_stats.concealment--[ self._concealment or
		self._value = stats.value--]weapon_stats.value--[ self._value or
		self._total_ammo_mod = self._total_ammo_mod or stats.total_ammo_mod--]weapon_stats.total_ammo_mod--[ self._total_ammo_mod or
		self._extra_ammo = stats.extra_ammo -- self._extra_ammo or
		self._reload = stats.reload--]weapon_stats.reload--[ self._reload or
		self._barrel_length = self._barrel_length or stats.barrel_length or 0

		for i, _ in pairs(weapon_stats) do
			local stat = self["_" .. tostring(i)]

			if not stat then
				self["_" .. tostring(i)] = weapon_stats[i][5]

				debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stat \"" .. tostring(i) .. "\"!")
			end
		end
	else
		debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stats block!")

		self._zoom = 60
		self._alert_size = 5000
		self._suppression = 1
		self._spread = 1
		self._recoil = 1
		self._spread_moving = 1
		self._reload = 1
	end

	self._bullet_slotmask = (setup_data.hit_slotmask or self._bullet_slotmask) - World:make_slot_mask(16)
	self._panic_suppression_chance = setup_data.panic_suppression_skill and self:weapon_tweak_data().panic_suppression_chance

	if self._panic_suppression_chance == 0 then
		self._panic_suppression_chance = false
	end

	self._setup = setup_data
	self._fire_mode = self._fire_mode or tweak_data.weapon[self._name_id].FIRE_MODE or "single"

	if self._setup.timer then
		self:set_timer(self._setup.timer)
	end
end



function RaycastWeaponBase:is_special()
	local categories = self:categories()

	for i, k in pairs(categories or {}) do
		return tweak_data.gui.buy_weapon_category_aliases[k]=="wpn_special"
	end

	return false
end



function RaycastWeaponBase:add_ammo_from_bag(available, special)
	local function process_ammo(ammo_base, amount_available)
		local caliber_class = (
			self._caliber
			and tweak_data.weapon.calibers[self._caliber]
			and tweak_data.weapon.calibers[self._caliber].class
		)
		local conv_ammo = caliber_class=="rifle" or caliber_class=="shotgun" or caliber_class=="pistol"
		local is_special = self:is_special()
		local special_check = (special and conv_ammo) or (not special and (not conv_ammo or is_special))

		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() or special_check then
			return 0
		end

		local ammo_max = ammo_base:get_ammo_max()
		local ammo_total = ammo_base:get_ammo_total()
		local wanted = 1 - ammo_total / ammo_max
		local can_have = math.min(wanted, amount_available)

		ammo_base:set_ammo_total(math.min(ammo_max, ammo_total + math.ceil(can_have * ammo_max)))
		print(wanted, can_have, math.ceil(can_have * ammo_max), ammo_base:get_ammo_total())

		return can_have
	end

	local can_have = process_ammo(self, available)
	available = available - can_have

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local ammo = process_ammo(gadget:ammo_base(), available)
			can_have = can_have + ammo
			available = available - ammo

			gadget:on_add_ammo_from_bag()
		end
	end

	return can_have
end



function RaycastWeaponBase:calculate_ammo_max_per_clip()
	return (self._CLIP_AMMO_MAX or tweak_data.weapon[self._name_id].CLIP_AMMO_MAX) * (self.AKIMBO and 2 or 1)
end



function RaycastWeaponBase:reload_speed_multiplier()
	local multiplier = 1

	for _, category in ipairs(self:weapon_tweak_data().categories) do
		multiplier = multiplier * managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
	end

	multiplier = multiplier * managers.player:upgrade_value("weapon", "passive_reload_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._name_id, "reload_speed_multiplier", 1)
	multiplier = managers.modifiers:modify_value("WeaponBase:GetReloadSpeedMultiplier", multiplier)

	return multiplier
end



--REMOVE AMMO PICKUP MULTIPLIER
function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier_min = 1
		local multiplier_max = 1

		local add_amount = add_amount_override
		local picked_up = true

		if not add_amount then
			local rng_ammo = math.lerp(ammo_base._ammo_pickup[1] * multiplier_min, ammo_base._ammo_pickup[2] * multiplier_max, math.random())
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end

	local picked_up, add_amount = nil
	picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

	if self.AKIMBO then
		local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

		if akimbo_rounding > 0 then
			_add_ammo(self, nil, akimbo_rounding)
		end
	end

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
			picked_up = p or picked_up
			add_amount = add_amount + a

			if self.AKIMBO then
				local akimbo_rounding = gadget:ammo_base():get_ammo_total() % 2 + #self._fire_callbacks

				if akimbo_rounding > 0 then
					_add_ammo(gadget:ammo_base(), nil, akimbo_rounding)
				end
			end
		end
	end

	return picked_up, add_amount
end



--ANIM PLAY: OFFSET ARGUMENT, DONT_PLAY ARGUMENT
function RaycastWeaponBase:anim_play(anim, speed_multiplier, offsetq, dont_play)
	--managers.mission._fading_debug_output:script().log(tostring(anim).." "..tostring(speed_multiplier),  Color.white)

	if anim then
		local length = self._unit:anim_length(Idstring(anim))
		speed_multiplier = speed_multiplier or 1

		if not dont_play then
			self._unit:anim_stop(Idstring(anim))
			self._unit:anim_play_to(Idstring(anim), length, speed_multiplier)
		end

		local offset = offsetq or self:_get_anim_start_offset(anim)

		if offset then
			self._unit:anim_set_time(Idstring(anim), offset)
		end
	end
end

function RaycastWeaponBase:tweak_data_anim_play(anim, ...)
	local animation = self:_get_tweak_data_weapon_animation(anim)

	if animation and not dont_play then
		self:anim_play(animation, ...)

		return true
	end

	return false
end

function RaycastWeaponBase:set_objects_visible(unit, objects, visible)
	if type(objects) == "string" then
		objects = {
			objects
		}
	end

	for _, object_name in ipairs(objects) do
		local graphic_object = unit:get_object(Idstring(object_name))

		if graphic_object then
			graphic_object:set_visibility(visible)
		end
	end
end



--GLOBAL SHIELDBASH
function RaycastWeaponBase:chk_shield_knock(hit_unit, col_ray, weapon_unit, user_unit, damage)
	if hit_unit:base() and hit_unit:base()._tweak_table~="shield" then return false end

	local hit_shield = hit_unit:in_slot(self.shield_mask)
	local enemy_unit = hit_shield and hit_unit:parent() or hit_unit
	local char_dmg_ext = alive(enemy_unit) and enemy_unit:character_damage()
	if not char_dmg_ext or not char_dmg_ext.force_hurt then return false end
	if char_dmg_ext.is_immune_to_shield_knockback and char_dmg_ext:is_immune_to_shield_knockback() then return false end
	local is_swat = hit_unit:name()==Idstring("units/payday2/characters/ene_acc_shield_small/shield_small")
	local is_phalanx = hit_unit:name()==Idstring("units/pd2_dlc_vip/characters/ene_acc_shield_phalanx/ene_acc_shield_phalanx")

	local damage_min = 30
	local damage_max = 60
	if is_swat then
		damage_min = 20
		damage_max = 40
	elseif is_phalanx then
		damage_min = 60
		damage_max = 130
	end

	local mov_ext = alive(enemy_unit) and enemy_unit:movement()
	local dmg_accum = mov_ext._dmg_accum or 0

	if (damage > math.random(damage_min, damage_max)) or (dmg_accum > math.random(damage_min, damage_max)) or not hit_shield then
		local damage_info = {
			damage = hit_shield and 0 or damage,
			type = "shield_knock",
			variant = "melee",
			col_ray = col_ray,
			result = {
				variant = "melee",
				type = "shield_knock"
			}
		}

		mov_ext._dmg_accum = nil
		char_dmg_ext:force_hurt(damage_info)

		return true
	elseif (damage > (is_phalanx and 30 or 9)) or (dmg_accum > (is_phalanx and 30 or 9)) then
		local damage_info = {
			damage = 0,
			type = "light_hurt",
			variant = "bullet",
			col_ray = col_ray,
			result = {
				variant = "bullet",
				type = "light_hurt"
			}
		}

		char_dmg_ext:force_hurt(damage_info)

		return true
	end

	return false
end



function RaycastWeaponBase:weapon_fire_rate()
	local wep_tweak = self:weapon_tweak_data()

	return wep_tweak.fire_mode_data and wep_tweak.fire_mode_data.fire_rate or 0
end
--ROF: GLOBAL CAP, BOLTING FACTOR
function RaycastWeaponBase:update_next_shooting_time(bolting_factor)
	if self:gadget_overrides_weapon_functions() then
		local gadget_func = self:gadget_function_override("update_next_shooting_time")

		if gadget_func then
			return gadget_func
		end
	end

	local rof_cap = 0.12
	local rof = (self:weapon_fire_rate() / self:fire_rate_multiplier())
	local t = self._unit:timer():time()
	local next_fire = math.max(rof, self:fire_mode()=="single" and rof_cap or 0) * (self.AKIMBO and 0.5 or 1)
	self._next_fire_allowed = (bolting_factor and t or self._next_fire_allowed) + math.max(bolting_factor or 0, next_fire - (bolting_factor or 0))
end



--SPREAD
function RaycastWeaponBase:_get_spread(user_unit)
	local spread_multiplier = self:spread_multiplier()
	local current_state = user_unit:movement()._current_state

	if current_state._moving then
		for _, category in ipairs(self:weapon_tweak_data().categories) do
			spread_multiplier = spread_multiplier * managers.player:upgrade_value(category, "move_spread_multiplier", 1)
		end
	end

	if current_state:in_steelsight() then
		return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_steelsight" or "steelsight"] * spread_multiplier
	end

	for _, category in ipairs(self:weapon_tweak_data().categories) do
		spread_multiplier = spread_multiplier * managers.player:upgrade_value(category, "hip_fire_spread_multiplier", 1)
	end

	if current_state._state_data.ducking then
		return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_crouching" or "crouching"] * spread_multiplier
	end

	return self._spread * tweak_data.weapon[self._name_id].spread[current_state._moving and "moving_standing" or "standing"] * spread_multiplier
end

function RaycastWeaponBase:_collect_hits(from, to)
	local setup_data = {
		stop_on_impact = self:bullet_class().stop_on_impact,
		can_shoot_through_wall = self:can_shoot_through_wall(),
		can_shoot_through_shield = self:can_shoot_through_shield(),
		can_shoot_through_enemy = self:can_shoot_through_enemy(),
		bullet_slotmask = self._bullet_slotmask,
		enemy_mask = self.enemy_mask,
		wall_mask = self.wall_vehicle_mask,
		shield_mask = self.shield_mask,
		ignore_units = self._setup.ignore_units
	}

	return RaycastWeaponBase.collect_hits(from, to, setup_data)
end
function RaycastWeaponBase.collect_hits(from, to, setup_data)
	setup_data = setup_data or {}
	local ray_hits = nil
	local hit_enemy = false
	local ignore_unit = setup_data.ignore_units or {}
	local enemy_mask = setup_data.enemy_mask
	local bullet_slotmask = setup_data.bullet_slotmask or managers.slot:get_mask("bullet_impact_targets")

	if setup_data.stop_on_impact then
		ray_hits = {}
		local hit = World:raycast("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit)

		if hit then
			table.insert(ray_hits, hit)

			hit_enemy = hit.unit:in_slot(enemy_mask)
		end

		return ray_hits, hit_enemy, hit_enemy and {
			[hit.unit:key()] = hit.unit
		} or nil
	end

	local can_shoot_through_wall = setup_data.can_shoot_through_wall
	local can_shoot_through_shield = setup_data.can_shoot_through_shield
	local can_shoot_through_enemy = setup_data.can_shoot_through_enemy
	local wall_mask = setup_data.wall_mask
	local shield_mask = setup_data.shield_mask
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if can_shoot_through_wall then
		ray_hits = World:raycast_wall("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from, to, "slot_mask", bullet_slotmask, "ignore_unit", ignore_unit)
	end

	local unique_hits = {}
	local enemies_hit = {}
	local unit, u_key, is_enemy = nil
	local units_hit = {}
	local in_slot_func = Unit.in_slot
	local has_ray_type_func = Body.has_ray_type

	for i, hit in ipairs(ray_hits) do
		unit = hit.unit
		u_key = unit:key()

		if not units_hit[u_key] then
			units_hit[u_key] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			is_enemy = in_slot_func(unit, enemy_mask)

			if is_enemy then
				enemies_hit[u_key] = unit
				hit_enemy = true
			end

			if not can_shoot_through_enemy and is_enemy then
				break
			elseif not can_shoot_through_shield and in_slot_func(unit, shield_mask) then
				break
			elseif not can_shoot_through_wall and in_slot_func(unit, wall_mask) and (has_ray_type_func(hit.body, ai_vision_ids) or has_ray_type_func(hit.body, bulletproof_ids)) then
				break
			end
		end
	end

	return unique_hits, hit_enemy, hit_enemy and enemies_hit or nil
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	--managers.mission._fading_debug_output:script().log(tostring(shoot_through_data and shoot_through_data.penetration or shoot_through_data), Color.white)
	--managers.mission._fading_debug_output:script().log(tostring(shoot_through_data and shoot_through_data.ray_from_unit or "csc"), Color.white)
	--shoot_through_data = nil
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	end

	local wep_tweak = self:weapon_tweak_data()

	local result = {}
	local hit_unit = nil
	local hit_enemies = {}
	local col_rays = {}
	local ray_delay = 0.025
	--local penetrtion = shoot_through_data and shoot_through_data.penetration or self._penetration or 0
	local init_penetration = shoot_through_data and shoot_through_data.penetration or self._penetration or 0

	local spread_hip = (self.AKIMBO or wep_tweak.reverse_rise) and 4 or 2
	local ads_mod = user_unit:movement()._current_state:in_steelsight() or 1
	local theta1 = math.random() * 360
    local ax1 = math.sin(theta1) * math.random() * spread_hip * (spread_mul or 1) * ads_mod
	local ay1 = math.cos(theta1) * math.random() * spread_hip * (spread_mul or 1) * ads_mod

	for i=1, shoot_through_data and 1 or self._rays do
		local damage = shoot_through_data and shoot_through_data.damage or (self:_get_current_damage(dmg_mul) / self._rays)

		local spread_x, spread_y = self:_get_spread(user_unit)
		local angular_recoil = 0--self.angular_recoil or 0
		spread_y = spread_y or spread_x
		local ray_distance = 100000 --shoot_through_data and shoot_through_data.ray_distance or self._weapon_range or 20000
		local right = direction:cross(Vector3(0, 0, 1)):normalized()
		local up = direction:cross(right):normalized()
		local theta = math.random() * 360
		local ax = (math.sin(theta) * math.random() * spread_x * (spread_mul or 1)) + ax1
		local ay = (math.cos(theta) * math.random() * spread_y * (spread_mul or 1)) + ay1 - angular_recoil
		local vec_to = Vector3()
		local vec_spread_dir = Vector3()
		mvector3.set(vec_spread_dir, direction)
		mvector3.add(vec_spread_dir, right * math.rad(ax))
		mvector3.add(vec_spread_dir, up * math.rad(ay))
		mvector3.set(vec_to, vec_spread_dir)
		mvector3.multiply(vec_to, ray_distance)
		mvector3.add(vec_to, from_pos)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, vec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		local penetration = init_penetration

		local autoaim, suppression_enemies = self:check_autoaim(from_pos, direction)
		if suppression_enemies and self._suppression then result.enemies_in_cone = suppression_enemies end

		if col_ray and col_ray.unit and penetration~=0 then
			hit_unit = self._bullet_class:on_collision(col_ray, self._unit, user_unit, damage, nil, nil, penetration)
			if hit_unit and hit_unit.attack_data and hit_unit.attack_data.penetration then penetration = hit_unit.attack_data.penetration end

			local is_shield = col_ray.unit:in_slot(8)-- and alive(col_ray.unit:parent())
			local is_wall = (
				col_ray.unit:in_slot(managers.slot:get_mask("world_geometry"))
				or col_ray.unit:in_slot(14, 17)
			)

			if is_shield then
				local is_swat = col_ray.unit:name()==Idstring("units/payday2/characters/ene_acc_shield_small/shield_small")
				local is_phalanx = col_ray.unit:name()==Idstring("units/pd2_dlc_vip/characters/ene_acc_shield_phalanx/ene_acc_shield_phalanx")
				local prev_pen = penetration
				penetration = math.max(0, penetration - (is_swat and 2200 or is_phalanx and 6000 or 4000))
				damage = damage*(penetration/prev_pen)
			end

			if hit_unit or is_shield or is_wall then --instead of return

				local from_pos0 = Vector3()
				mvector3.set(from_pos0, vec_spread_dir) mvector3.multiply(from_pos0, 1) mvector3.add(from_pos0, col_ray.position)
				local testray_pre = World:raycast("ray", from_pos, from_pos0, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units) and 1 or 0

				local faces = (shoot_through_data and shoot_through_data.faces or 0) + testray_pre
				local from_pos1 = Vector3()
				mvector3.set(from_pos1, vec_spread_dir) mvector3.multiply(from_pos1, 15) mvector3.add(from_pos1, col_ray.position)

				while penetration~=0 and not is_shield do
					penetration = math.max(0, penetration - math.max(100, penetration*0.5))
					damage = math.max(0, damage - damage*0.5)

					local vec_minus15 = Vector3()
					mvector3.set(vec_minus15, vec_spread_dir) mvector3.multiply(vec_minus15, -15) mvector3.add(vec_minus15, from_pos1)

					local testray_fwd = World:raycast("ray", vec_minus15, from_pos1, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
					if testray_fwd and testray_fwd.distance>0.01 then
						faces = faces + 1
					end

					local testray_bwd = World:raycast("ray", from_pos1, vec_minus15, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
					if testray_bwd and testray_bwd.distance>0.01 then
						faces = math.max(0, faces - 1)
						if penetration>0 then self._bullet_class:on_collision(testray_bwd, self._unit, user_unit, damage, nil, nil, penetration) end
					end

					if faces==0 then
						break
					else
						local vec = Vector3()
						mvector3.set(vec, vec_spread_dir)
						mvector3.multiply(vec, 15)
						mvector3.add(vec, from_pos1)

						mvector3.set(from_pos1, vec)
					end
				end

				if penetration>0 then
					shoot_through_data = {
						from = Vector3(),
						faces = faces,
						has_hit_wall = is_wall,
						penetration = penetration,
						damage = damage,
					}

					mvector3.set(shoot_through_data.from, vec_spread_dir)
					mvector3.multiply(shoot_through_data.from, is_shield and 5 or 15)
					mvector3.add(shoot_through_data.from, from_pos1)
					managers.game_play_central:queue_fire_raycast(Application:time() + ray_delay, self._unit, user_unit, shoot_through_data.from, vec_spread_dir, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
				end

				if self._alert_events then table.insert(col_rays, col_ray) table.insert(hit_enemies, col_ray) end
			end
		end
	end

	result.hit_enemy = next(hit_enemies) and true or false
	if self._alert_events then result.rays = col_rays end
	managers.statistics:shot_fired({ hit = false, weapon_unit = self._unit })

	for k, v in pairs(hit_enemies) do
		managers.statistics:shot_fired({ hit = true, weapon_unit = self._unit, skip_bullet_count = true })
	end

	return result
end
function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound, penetration)
	local hit_unit = col_ray.unit
	user_unit = alive(user_unit) and user_unit or nil

	if user_unit and self:chk_friendly_fire(hit_unit, user_unit) then
		return "friendly_fire"
	end

	weapon_unit = alive(weapon_unit) and weapon_unit or nil
	local endurance_alive_chk = false

	if hit_unit:damage() then
		local body_dmg_ext = col_ray.body:extension() and col_ray.body:extension().damage

		if body_dmg_ext then
			local sync_damage = not blank and hit_unit:id() ~= -1
			local network_damage = math.ceil(damage * 163.84)
			local body_damage = network_damage / 163.84

			if sync_damage and managers.network:session() then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit and user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
			end

			local local_damage = not blank or hit_unit:id() == -1

			if local_damage then
				endurance_alive_chk = true
				local weap_cats = weapon_unit and weapon_unit:base().categories and weapon_unit:base():categories()

				body_dmg_ext:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)

				if hit_unit:alive() then
					body_dmg_ext:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, body_damage)
				end

				if weap_cats and hit_unit:alive() then
					for _, category in ipairs(weap_cats) do
						body_dmg_ext:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
					end
				end
			end
		end
	end

	if endurance_alive_chk and not hit_unit:alive() then
		return
	end

	local do_shotgun_push, result, do_push, push_mul = nil
	local hit_dmg_ext = hit_unit:character_damage()
	local play_impact_flesh = not hit_dmg_ext or not hit_dmg_ext._no_blood

	if not blank and weapon_unit then
		local weap_base = weapon_unit:base()

		local enemy_unit = col_ray.unit:in_slot(8) and col_ray.unit:parent() or col_ray.unit
		local mov_ext = alive(enemy_unit) and enemy_unit:movement()
		if mov_ext then mov_ext._dmg_accum = (mov_ext._dmg_accum or 0) + damage end

		if weap_base and weap_base.chk_shield_knock then
			weap_base:chk_shield_knock(hit_unit, col_ray, weapon_unit, user_unit, damage)
		end

		if hit_dmg_ext and hit_dmg_ext.damage_bullet then
			local was_alive = not hit_dmg_ext:dead()
			local armor_piercing, knock_down, stagger, variant = nil

			if weap_base then
				armor_piercing = weap_base.has_armor_piercing and weap_base:has_armor_piercing()
				knock_down = weap_base.is_knock_down and weap_base:is_knock_down()
				stagger = weap_base.is_stagger and weap_base:is_stagger()
				variant = weap_base.variant and weap_base:variant()
			end

			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, false, knock_down, stagger, variant, penetration)

			if result ~= "friendly_fire" then
				local has_died = hit_dmg_ext:dead()
				do_push = true
				push_mul = self:_get_character_push_multiplier(weapon_unit, was_alive and has_died)

				if weap_base and result and result.type == "death" and weap_base.should_shotgun_push and weap_base:should_shotgun_push() then
					do_shotgun_push = true
				end
			else
				play_impact_flesh = false
			end
		else
			do_push = true
		end
	else
		do_push = true
	end

	if do_push then managers.game_play_central:physics_push(col_ray, push_mul) end
	if do_shotgun_push then managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit) end
	if play_impact_flesh then
		if result and result.attack_data and result.attack_data.penetration and result.attack_data.penetration>0 then
			managers.game_play_central:play_impact_flesh({col_ray = col_ray, no_sound = no_sound})
		end
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound, result and result.switch or nil)
	end

	return result
end
function InstantBulletBase:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound, switch)
	managers.game_play_central:play_impact_sound_and_effects(self:_get_sound_and_effects_params(weapon_unit, col_ray, no_sound, switch))
end
function InstantBulletBase:_get_sound_and_effects_params(weapon_unit, col_ray, no_sound, switch)
	local bullet_tweak = self.id and (tweak_data.blackmarket.bullets[self.id] or {}) or {}
	local params = {
		col_ray = col_ray,
		no_sound = no_sound,
		effect = bullet_tweak.effect,
		sound_switch_name = bullet_tweak.sound_switch_name,
		switch = switch
	}

	return params
end
function InstantBulletBase:on_hit_player(col_ray, weapon_unit, user_unit, damage)
	local wep_tweak = weapon_unit:base():weapon_tweak_data()
	local rifle_round = alive(weapon_unit) and tweak_data.weapon.calibers[wep_tweak.caliber or "9x19"].class=="rifle"

	col_ray.unit = managers.player:player_unit()

	return self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, rifle_round)
end
--NEW PENETRATION DATA
function InstantBulletBase:give_impact_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, shield_knock, knock_down, stagger, variant, penetration)
	local action_data = {
		variant = variant or "bullet",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		shield_knock = shield_knock,
		origin = user_unit:position(),
		knock_down = knock_down,
		stagger = stagger,
		penetration = penetration --weapon_unit:base()._penetration
	}
	local defense_data = col_ray.unit:character_damage():damage_bullet(action_data)

	return defense_data
end

--NEW FUNCTION: GET_CHAMBER
function RaycastWeaponBase:get_chamber()
	local wep_tweak = self:weapon_tweak_data()
	return ((wep_tweak.chamber or 0) - (self.chamber_state and 1 or 0))*(self:is_category("akimbo") and 2 or 1)
end

function RaycastWeaponBase:start_shooting()
	if self:gadget_overrides_weapon_functions() then
		local gadget_func = self:gadget_function_override("start_shooting")

		if gadget_func then
			return gadget_func
		end
	end

	self._next_fire_allowed = math.max(self._next_fire_allowed, self._unit:timer():time())
	self._shooting = true
	self._bullets_fired = 0
end
function RaycastWeaponBase:play_tweak_data_sound(event, alternative_event)
	local event = self:_get_sound_event(event, alternative_event)

	if event then
		self:play_sound(event)
	end
end
function RaycastWeaponBase:_get_sound_event(event, alternative_event)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_get_sound_event", self, event, alternative_event)
	end

	local str_name = self._name_id

	if not self.third_person_important or not self:third_person_important() then
		str_name = self._name_id:gsub("_npc", "")
	end

	local sounds = tweak_data.weapon[str_name].sounds
	local event = sounds and (sounds[event] or sounds[alternative_event])

	return event
end

--SHOT_WITHOUT_MAG TRIGGER, NQAFSF
function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local wep_tweak = self:weapon_tweak_data()
	local is_mechanical = wep_tweak.action=="pump_action" or wep_tweak.action=="bolt_action" or wep_tweak.action=="lever_action"

	if self._bullets_fired then
		self:play_tweak_data_sound("stop_fire")
		self:_fire_sound()
		self._bullets_fired = self._bullets_fired + 1
	end
	if self._sound_singleshot then self:_sound_singleshot() end

	local is_player = self._setup.user_unit == managers.player:player_unit()
	local ammo_usage = self:ammo_usage()

	if is_player or Network:is_server() then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then return end

		local ammo_in_clip = base:get_ammo_remaining_in_clip()
		local remaining_ammo = ammo_in_clip - ammo_usage

		if remaining_ammo < 0 then
			ammo_usage = ammo_usage + remaining_ammo
			remaining_ammo = 0
		end

		if ammo_in_clip > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			if self.r_stage and (self.r_cycle[self.r_stage]=="r_keep_old_mag" or self.r_cycle[self.r_stage]=="r_get_new_mag_in") then
				self.shot_without_mag = true
			end

			if wep_tweak.animations and wep_tweak.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if wep_tweak.sounds and wep_tweak.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if wep_tweak.effects and wep_tweak.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
				self:set_mag_visibility(false)
			end

			self:set_magazine_empty(true)
		end

		if is_mechanical then self.chamber_state = -1 end
		base:set_ammo_remaining_in_clip(ammo_in_clip - ammo_usage)
		self:use_ammo(base, ammo_usage)
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then self:_spawn_muzzle_effect(from_pos, direction) end

	if not is_mechanical then self:_spawn_shell_eject_effect() end

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit, ammo_usage)

	if self._alert_events and ray_res.rays then self:_check_alert(ray_res.rays, from_pos, direction, user_unit) end

	self:_build_suppression(ray_res.enemies_in_cone, suppr_mul)
	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end

function RaycastWeaponBase:trigger_pressed(...)
	local fired = nil

	if self:start_shooting_allowed() then
		fired = self:fire(...)

		if fired then
			self:update_next_shooting_time()
		end
	end

	return fired
end
function RaycastWeaponBase:trigger_held(...)
	local fired = nil

	if not self.delayed and self:start_shooting_allowed() then
		fired = self:fire(...)
		if fired then self:update_next_shooting_time() end
	elseif self.delayed then
		fired = self:fire(...)
		if fired then self:update_next_shooting_time() end --?
	end

	return fired
end



function RaycastWeaponBase:play_sound(event)
	self._sound_fire:post_event(event)
end
