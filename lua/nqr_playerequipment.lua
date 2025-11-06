--THROWING GRENADE: STAMINA DRAIN, STAMINA PENALTY, THROW SPREAD
function PlayerEquipment:throw_grenade()
	local grenade_name = managers.blackmarket:equipped_grenade()
	local grenade_tweak = tweak_data.blackmarket.projectiles[grenade_name]

	if grenade_tweak.client_authoritative then
		return self:throw_projectile()
	end

    local stamina_penalty = self._unit:movement():is_above_stamina_threshold() and 1 or 0.5
    self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.25 / managers.player:body_armor_value("stamina"))
	self._unit:movement():activate_regeneration()

	local from = self._unit:movement():m_head_pos()
	local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
	local dir = self._unit:movement():m_head_rot():y() * stamina_penalty
	local spread = 4
	local theta = 360 * math.random()
	local right = dir:cross(Vector3(0, 0, 1)):normalized()
	local up = dir:cross(right):normalized()
	local ax = math.sin(theta) * spread * math.random()
	local ay = math.cos(theta) * spread * math.random()
	mvector3.add(dir, right * math.rad(ax))
	mvector3.add(dir, up * math.rad(ay))

	if not grenade_tweak.no_shouting then
		self._unit:sound():play("g43", nil, true)
	end

	local grenade_index = tweak_data.blackmarket:get_index_from_projectile_id(grenade_name)

	if Network:is_client() then
		managers.network:session():send_to_host("request_throw_projectile", grenade_index, pos, dir)
	else
		ProjectileBase.throw_projectile(grenade_name, pos, dir, managers.network:session():local_peer():id())
		managers.player:verify_grenade(managers.network:session():local_peer():id())
	end

	managers.player:on_throw_grenade()
end
function PlayerEquipment:throw_projectile()
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_data = tweak_data.blackmarket.projectiles[projectile_entry]

    local stamina_penalty = self._unit:movement():is_above_stamina_threshold() and 1 or 0.5
    self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.25 / managers.player:body_armor_value("stamina"))
	self._unit:movement():activate_regeneration()

	local from = self._unit:movement():m_head_pos()
	local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
	local dir = self._unit:movement():m_head_rot():y() * stamina_penalty

	local say_line = projectile_data.throw_shout or "g43"
	if say_line and say_line ~= true then
		self._unit:sound():play(say_line, nil, true)
	end

	local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_entry)

	if not projectile_data.client_authoritative then
		if Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", projectile_index, pos, dir)
		else
			ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
			managers.player:verify_grenade(managers.network:session():local_peer():id())
		end
	else
		ProjectileBase.throw_projectile(projectile_entry, pos, dir, managers.network:session():local_peer():id())
		managers.player:verify_grenade(managers.network:session():local_peer():id())
	end

	managers.player:on_throw_grenade()
end