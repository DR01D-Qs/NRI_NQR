GrenadeCrateDeployableBase = GrenadeCrateDeployableBase or class(GrenadeCrateBase)

local dec_mul = 10000
function GrenadeCrateBase:round_value(val)
	return math.floor(val * dec_mul) / dec_mul
end
function GrenadeCrateBase:_take_ammo(unit)
	local taken = 0

	for id, weapon in pairs(unit:inventory() and unit:inventory():available_selections() or {}) do
		local took = self:round_value(weapon.unit:base():add_ammo_from_bag(1000, true))
		taken = taken + took
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end

	return taken
end

function GrenadeCrateDeployableBase:take_grenade(unit)
	local took_ammo = self:_take_ammo(unit)

	if self._empty or (not self:_can_take_grenade() and took_ammo==0) or not managers.network:session() then
		return
	end

	unit:sound():play("pickup_ammo")

	local max_grenades = managers.player:get_max_grenades()
	local grenade_amount = managers.player:add_grenade_amount(max_grenades, true)

	managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 1)

	self._grenade_amount = self._grenade_amount - 1

	if self._grenade_amount <= 0 then
		self:_set_empty()
	end

	self:_set_visual_stage()

	return grenade_amount
end