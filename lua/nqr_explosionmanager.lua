ExplosionManager = ExplosionManager or class()
local idstr_small_light_fire = Idstring("effects/particles/fire/small_light_fire")
local idstr_explosion_std = Idstring("explosion_std")
local empty_idstr = Idstring("")
local molotov_effect = "effects/payday2/particles/explosions/molotov_grenade"
local tmp_vec3 = Vector3()



function ExplosionManager:give_local_player_dmg(pos, range, damage, thrower)
	local player = managers.player:player_unit()

	if player then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = pos,
			range = range,
			damage = damage * (thrower==player and 0.1 or 0.001),
		})
	end
end
