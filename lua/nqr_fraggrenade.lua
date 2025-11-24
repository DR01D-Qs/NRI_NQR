function FragGrenade:_setup_from_tweak_data()
	local grenade_entry = self._tweak_projectile_entry or "frag"
	local tweak_entry = tweak_data.projectiles[grenade_entry]
	self._init_timer = tweak_entry.init_timer or 2.5
	self._mass_look_up_modifier = tweak_entry.mass_look_up_modifier
	self._range = tweak_entry.range
	self._effect_name = tweak_entry.effect_name or "effects/payday2/particles/explosions/grenade_explosion"
	self._curve_pow = tweak_entry.curve_pow or 3
	self._damage = tweak_entry.damage
	self._player_damage = tweak_entry.player_damage
	self._alert_radius = tweak_entry.alert_radius
	self._idstr_decal = tweak_entry.idstr_decal
	self._idstr_effect = tweak_entry.idstr_effect
	local sound_event = tweak_entry.sound_event or "grenade_explode"
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		idstr_decal = self._idstr_decal,
		idstr_effect = self._idstr_effect,
		sound_event = sound_event,
		feedback_range = self._range * 2
	}

	return tweak_entry
end

function FragGrenade:update(unit, t, dt)
	FragGrenade.super.update(self, unit, t, dt)

    self._existing_t = (self._existing_t or 0) + dt

	self._despawn_t = self._despawn_t and (self._despawn_t - dt)
	if self._despawn_t and self._despawn_t<0 then
		self._despawn_t = nil
		self._unit:set_slot(0)
	end
end

function FragGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local reflect = other_unit and other_unit:vehicle() and other_unit:vehicle():is_active()
	reflect = managers.modifiers:modify_value("FragGrenade:ShouldReflect", reflect, other_unit, self._unit)

	local proj_tweak = tweak_data.projectiles[self._tweak_projectile_entry]
	local proj_bmtweak = tweak_data.blackmarket.projectiles[self._tweak_projectile_entry]

    if not self._detonated and self._existing_t
	and (proj_tweak and proj_tweak.arming_distance and proj_tweak.launch_speed)
	and ((proj_tweak.launch_speed * 2 * self._existing_t) < proj_tweak.arming_distance)
	then
        self._detonated = true

        self._despawn_t = proj_bmtweak and proj_bmtweak.physic_effect==Idstring("physic_effects/anti_gravitate") and 0 or 2

		return
    end

	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end

function FragGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:give_local_player_dmg(pos, range, self._damage, self:thrower_unit())
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 0,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit
	})

	if self._unit:id() ~= -1 then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)
	end

	self._unit:set_slot(0)
end
function FragGrenade:_detonate_on_client()
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local range = self._range

	managers.explosion:give_local_player_dmg(pos, range, self._damage, self:thrower_unit())
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)

	if self._unit:id() == -1 then
		self._unit:set_slot(0)
	else
		self._unit:set_visible(false)
	end
end



IncendiaryBurstGrenade = IncendiaryBurstGrenade or class(FragGrenade)
function IncendiaryBurstGrenade:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local normal = math.UP
	local range = self._range
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.fire:give_local_player_dmg(pos, range, self._damage, self:thrower_unit())
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)
	managers.explosion:client_damage_and_push(pos, normal, nil, self._damage, range, self._curve_pow)

	local params = {
		player_damage = 0,
		is_molotov = "fir_com",
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = self._curve_pow,
		damage = self._damage,
		ignore_unit = self._unit,
		alert_radius = self._alert_radius,
		user = self:thrower_unit() or self._unit,
		owner = self._unit,
		fire_dot_data = self._fire_dot_data
	}
	local hit_units, splinters = managers.fire:detect_and_give_dmg(params)

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", GrenadeBase.EVENT_IDS.detonate)

	self.burn_stop_time = TimerManager:game():time() + self._fire_dot_data.dot_length + 1

	self._unit:set_visible(false)
end
function IncendiaryBurstGrenade:_detonate_on_client()
	if self._detonated then
		return
	end

	self._detonated = true
	local pos = self._unit:position()
	local range = self._range

	managers.fire:give_local_player_dmg(pos, range, self._damage, self:thrower_unit())
	managers.explosion:explode_on_client(pos, math.UP, nil, self._damage, range, self._curve_pow, self._custom_params)
end



ConcussionGrenade = ConcussionGrenade or class(GrenadeBase)
function ConcussionGrenade:_flash_player()
	local detonate_pos = self._unit:position() + math.UP * 100
	local range = self._PLAYER_FLASH_RANGE
	local affected, line_of_sight, travel_dis, linear_dis = QuickFlashGrenade._chk_dazzle_local_player(self, detonate_pos, range)

	if affected then
		managers.environment_controller:set_concussion_grenade(detonate_pos, line_of_sight, travel_dis, linear_dis, tweak_data.character.concussion_multiplier * (managers.player:player_unit()==self:thrower_unit() and 1 or 0.5))

		local sound_eff_mul = math.clamp(1 - (travel_dis or linear_dis) / range, 0.3, 1)

		managers.player:player_unit():character_damage():on_concussion(sound_eff_mul)
	end
end