local plr = managers and managers.player and managers.player:player_unit() and managers.player:player_unit():movement():current_state()
if not plr then return end

plr._nqr_key_melee = 3