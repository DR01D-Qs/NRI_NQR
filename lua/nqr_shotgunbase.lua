ShotgunBase = ShotgunBase or class(NewRaycastWeaponBase)

local mvec_temp = Vector3()
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()

function ShotgunBase:init(...)
	ShotgunBase.super.init(self, ...)
	self:setup_default()

	self._hip_fire_rate_inc = 0
	self._do_shotgun_push = false
end

--GET AMOUNT OF RAYS
function ShotgunBase:setup_default()
	self._damage_near = tweak_data.weapon[self._name_id].damage_near
	self._damage_far = tweak_data.weapon[self._name_id].damage_far
	self._rays = tweak_data.weapon:nqr_ammotype_data(self._caliber, self._ammotype).proj_amount or 1
	self._range = self._damage_far

	if tweak_data.weapon[self._name_id].use_shotgun_reload == nil then
		self._use_shotgun_reload = self._use_shotgun_reload or self._use_shotgun_reload == nil
	else
		self._use_shotgun_reload = tweak_data.weapon[self._name_id].use_shotgun_reload
	end
end

function ShotgunBase:_update_stats_values(disallow_replenish, ammo_data)
	ShotgunBase.super._update_stats_values(self, disallow_replenish, ammo_data)
	self:setup_default()

	if self._ammo_data then
		if self._ammo_data.damage_near ~= nil then
			self._damage_near = self._ammo_data.damage_near
		end

		if self._ammo_data.damage_near_mul ~= nil then
			self._damage_near = self._damage_near * self._ammo_data.damage_near_mul
		end

		if self._ammo_data.damage_far ~= nil then
			self._damage_far = self._ammo_data.damage_far
		end

		if self._ammo_data.damage_far_mul ~= nil then
			self._damage_far = self._damage_far * self._ammo_data.damage_far_mul
		end

		self._range = self._damage_far
	end
end

--RAYCAST: PER-PELLET DAMAGE
function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	if self._rays then
		local result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
		return result
	end
end
