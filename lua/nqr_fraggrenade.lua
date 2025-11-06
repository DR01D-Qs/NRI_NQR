
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
    if not self._detonated and proj_tweak and proj_tweak.arming_distance and proj_tweak.launch_speed
	and ((proj_tweak.launch_speed * 2 * self._existing_t) < (proj_tweak.arming_distance or 0)) then
        self._detonated = true

		local proj_bmtweak = tweak_data.blackmarket.projectiles[self._tweak_projectile_entry]
        self._despawn_t = proj_bmtweak and proj_bmtweak.physic_effect==Idstring("physic_effects/anti_gravitate") and 0 or 2

		return
    end

	self:_detonate(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
end
function FragGrenade:_on_collision(col_ray)
	local reflect = col_ray and col_ray.unit:vehicle() and col_ray.unit:vehicle():is_active()
	reflect = managers.modifiers:modify_value("FragGrenade:ShouldReflect", reflect, col_ray and col_ray.unit, self._unit)

    if (tweak_data.projectiles[self._tweak_projectile_entry].launch_speed * 2 * self._existing_t) < (tweak_data.projectiles[self._tweak_projectile_entry].arming_distance or 0) then
        if col_ray then
            CoreSerialize.string_to_classtable("InstantBulletBase"):on_collision(col_ray, self._weapon_unit or self._unit, self._thrower_unit, self._damage, false)
        end

        self._detonated = true

        return
    end

	self:_detonate()
end
