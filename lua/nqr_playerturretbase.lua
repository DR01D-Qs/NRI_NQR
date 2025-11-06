function PlayerTurretBase:update_damage()
	local weapon_stats = tweak_data.weapon.stats
	local damage_modifier = weapon_stats.stats_modifiers and weapon_stats.stats_modifiers.damage or 1
	local stats = tweak_data.weapon[self._name_id].stats
	local base_damage = (stats and stats.damage or 0) * damage_modifier
	self._damage = (base_damage + self:damage_addend()) * self:damage_multiplier()
end
