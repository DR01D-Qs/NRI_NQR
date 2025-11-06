local mvec_to = Vector3()
local mvec_spread = Vector3()

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = {}
	local hit_enemies = {}
	local hit_unit = nil
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)

	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	end

	if self._alert_events then
		col_rays = {}
	end

	local wep_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1

	local damage = (self._damage * (dmg_mul or 1)) / wep_rays
	local spread = 2
	for i = 1, wep_rays do
		mvector3.set(mvec_to, direction)
		mvector3.spread(mvec_to, spread)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
		--Draw:brush(Color.red, 0.5):cylinder(from_pos, mvec_to, 0.1)
		local player_hit, player_ray_data = nil

		if shoot_player and self._hit_player then
			player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction, result)

			if player_hit then
				self._unit:base():bullet_class():on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
			end
		end
 
		if col_ray then
			if col_rays then table.insert(col_rays, col_ray) end

			local char_hit = nil
			if not player_hit then
				char_hit = self._unit:base():bullet_class():on_collision(col_ray, self._unit, user_unit, damage, self._fires_blanks)
			end
		end

		if not shoot_player and (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
			target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
		end
	end

	result.hit_enemy = next(hit_enemies) and true or false

	if self._alert_events then
		result.rays = #col_rays > 0 and col_rays
	end
	self:_cleanup_smoke_shot()

	return result
end
