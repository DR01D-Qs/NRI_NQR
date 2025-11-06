Hooks:PostHook(PlayerManager, "check_skills", "nqr_PlayerManager:check_skills", function(self)
	self._message_system:register(Message.OnEnemyKilled, "xp_on_kill", callback(self, self, "award_xp_on_kill"))
end)
function PlayerManager:award_xp_on_kill(equipped_unit, variant, killed_unit)
	local diff_id = tweak_data:difficulty_to_index(Global.game_settings and Global.game_settings.difficulty or "normal")
	local diff_mul = { 0, 1, 1.5, 2, 3 }

	local enemy_tweak = killed_unit:base()._tweak_table and killed_unit:base()._tweak_table
	local xp_mul_lookup = {
		sniper = 1.2,
		shield = 1.2,
		marshal_shield = 1.2,
		marshal_shield_break = 1.2,
		medic = 1.2,
		taser = 1.5,
		spooc = 1.2,
		phalanx_minion = 1.5,
		drug_lord_boss = 1.5,
		drug_lord_boss_stealth = 10.0,
		triad_boss = 1.5,
		triad_boss_no_armor = 10.0,
		deep_boss = 1.5,
		tank = 1.5,
		tank_hw = 1.5,
	}
	local xp_mul = xp_mul_lookup[enemy_tweak] or 1

	local xp = 100 * (diff_mul[diff_id] or 1) * xp_mul

	log("+ "..xp.." ( "..diff_mul[diff_id].." * "..xp_mul.." ) "..enemy_tweak)

	managers.experience:mission_xp_award_kills(xp)
end



function PlayerManager:_attempt_copr_ability()
	if self:has_activate_temporary_upgrade("temporary", "copr_ability") then
		return false
	end

	local character_damage = self:local_player():character_damage()
	local duration = self:upgrade_value("temporary", "copr_ability")[2]
	local now = managers.game_play_central:get_heist_timer()

	managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)

	local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)

	self:set_property("copr_risen", is_downed)

	if is_downed then
		character_damage:revive(true)
	end

	self:activate_temporary_upgrade("temporary", "copr_ability")

	local expire_time = self:get_activate_temporary_expire_time("temporary", "copr_ability")

	managers.enemy:add_delayed_clbk("copr_ability_active", callback(self, self, "clbk_copr_ability_ended"), expire_time)
	managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, duration)

	local bonus_health = self:upgrade_value("player", "copr_activate_bonus_health_ratio", tweak_data.upgrades.values.player.copr_activate_bonus_health_ratio[1])

	character_damage:restore_health(bonus_health)
	character_damage:set_armor(0)
	character_damage:send_set_status()

	local speed_up_on_kill_time = self:upgrade_value("player", "copr_speed_up_on_kill", 0)

	if speed_up_on_kill_time > 0 then
		local function speed_up_on_kill_func()
			managers.player:speed_up_grenade_cooldown(speed_up_on_kill_time)
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_copr_ability", speed_up_on_kill_func)
	end

	character_damage:on_copr_ability_activated()

	self._copr_kill_life_leech_num = 0
	local static_damage_ratio = self:upgrade_value("player", "copr_static_damage_ratio", 0)

	managers.hud:set_copr_indicator(true, static_damage_ratio)

	if is_downed then
		self:register_message("ability_activated", "copr_risen_cooldown_key", callback(self, self, "add_copr_risen_cooldown"))
	end

	return true
end

function PlayerManager:add_copr_risen_cooldown()
	self:speed_up_grenade_cooldown(-tweak_data.upgrades.copr_risen_cooldown_add)
	self:unregister_message("ability_activated", "copr_risen_cooldown_key")
	self:set_property("copr_risen_cooldown_added", true)
end

function PlayerManager:remove_copr_risen_cooldown()
	if self:get_property("copr_risen_cooldown_added") then
		self:speed_up_grenade_cooldown(tweak_data.upgrades.copr_risen_cooldown_add)
		self:set_property("copr_risen_cooldown_added", nil)
	end
end

function PlayerManager:force_end_copr_ability()
	if self:has_activate_temporary_upgrade("temporary", "copr_ability") then
		self:deactivate_temporary_upgrade("temporary", "copr_ability")
		managers.enemy:remove_delayed_clbk("copr_ability_active", true)
		self:set_property("copr_risen", nil)
		managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, 0)

		local player_unit = self:local_player()
		local character_damage = alive(player_unit) and player_unit:character_damage()

		if character_damage then
			character_damage:on_copr_ability_deactivated()
		end

		managers.hud:set_copr_indicator(false)
	end
end

function PlayerManager:clbk_copr_ability_ended()
	self:deactivate_temporary_upgrade("temporary", "copr_ability")

	local player_unit = self:local_player()
	local character_damage = alive(player_unit) and player_unit:character_damage()

	if character_damage then
		local out_of_health = character_damage:health_ratio() < self:upgrade_value("player", "copr_static_damage_ratio", 0)
		local risen_from_dead = self:get_property("copr_risen", false) == true

		character_damage:on_copr_ability_deactivated()

		if out_of_health or risen_from_dead then
			character_damage:force_into_bleedout(false, risen_from_dead)
		end
	end

	self:set_property("copr_risen", nil)
	managers.hud:set_copr_indicator(false)
end

function PlayerManager:count_copr_ability_players()
	local count = 0

	if managers.network:session() then
		local skills = nil

		for _, peer in pairs(managers.network:session():all_peers()) do
			skills = peer:unpacked_skills()

			if skills and skills.specializations and tonumber(skills.specializations[1]) == tweak_data.upgrades.copr_specialization_tree_id and tonumber(skills.specializations[2]) > 0 then
				count = count + 1
			end
		end
	end

	return count
end



--REMOVE HEALTH REGEN
function PlayerManager:health_regen()
	return 0
end



--INFINITE BODYBAGS
function PlayerManager:_set_body_bags_amount(body_bags_amount)
	self._local_player_body_bags = 69
end



--ARMOR REGEN MUL
function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = 1
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_tier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "armor_regen_timer_multiplier_passive", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "regen_time_multiplier", 1)
	multiplier = multiplier * self:team_upgrade_value("armor", "passive_regen_time_multiplier", 1)
	multiplier = multiplier * self:upgrade_value("player", "perk_armor_regen_timer_multiplier", 1)

	if not moving then
		multiplier = multiplier * managers.player:upgrade_value("player", "armor_regen_timer_stand_still_multiplier", 1)
	end

	if health_ratio then
		local damage_health_ratio = self:get_damage_health_ratio(health_ratio, "armor_regen")
		multiplier = multiplier * (1 - managers.player:upgrade_value("player", "armor_regen_damage_health_ratio_multiplier", 0) * damage_health_ratio)
	end

	return multiplier*0.5
end



--
function PlayerManager:mod_movement_penalty(movement_penalty)
	local skill_mods = 1 --self:upgrade_value("player", "passive_armor_movement_penalty_multiplier", 1)
	--skill_mods = skill_mods * self:upgrade_value("team", "crew_reduce_speed_penalty", 1)

	if skill_mods < 1 and movement_penalty < 1 then
		local penalty = 1 - movement_penalty
		penalty = penalty * skill_mods
		movement_penalty = 1 - penalty
	end

	return movement_penalty
end
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = 1 + self:mod_movement_penalty(self:body_armor_value("movement", upgrade_level, 1)) - 1
	--if speed_state then multiplier = multiplier + self:upgrade_value("player", speed_state .. "_speed_multiplier", 1) - 1 end
	--multiplier = multiplier + self:upgrade_value("player", "movement_speed_multiplier", 1) - 1
	if health_ratio then multiplier = multiplier * (1 - (0.25 * (1 - health_ratio))) end

	return multiplier
end



--BAG THROW: STAMINA DRAIN, STAMINA PENALTY, DISTANCE NERF
function PlayerManager:drop_carry(zipline_unit, weak_throw)
	local carry_data = self:get_my_carry_data()
	if not carry_data then return end

	local player = self:player_unit()
	local camera_ext = player:camera()
	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	weak_throw = weak_throw or not player:movement():is_above_stamina_threshold()
	local throw_distance_multiplier_upgrade_level = weak_throw and 1 or 0
	carry_data.multiplier = player:movement():is_above_stamina_threshold() and 1 or 0
	local position = camera_ext:position()
	local rotation = camera_ext:rotation()
	local forward = player:camera():forward()

	if player then player:sound():play("Play_bag_generic_throw", nil, false) end

	if not weak_throw then
		player:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN / self:body_armor_value("stamina"))
		player:movement():activate_regeneration()
	end

	if _G.IS_VR then
		local active_hand = player:hand():get_active_hand("bag")

		if active_hand then
			position = active_hand:position()
			rotation = active_hand:rotation()
			forward = rotation:y()
		end
	end

	if Network:is_client() then
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, forward, throw_distance_multiplier_upgrade_level, zipline_unit)
	else
		self:server_drop_carry(carry_data.carry_id, carry_data.multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, rotation, forward, throw_distance_multiplier_upgrade_level, zipline_unit, managers.network:session():local_peer())
	end

	managers.hud:remove_teammate_carry_info(HUDManager.PLAYER_PANEL)
	managers.hud:temp_hide_carry_bag()
	self:update_removed_synced_carry_to_peers()

	if self._current_state == "carry" then managers.player:set_player_state("standard") end
end

function PlayerManager:sync_carry_data(unit, carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier, position, dir, throw_distance_multiplier_upgrade_level, zipline_unit, peer_id)
	local carry_type = tweak_data.carry[carry_id].type
	local throw_distance_multiplier = tweak_data.carry.types[carry_type].throw_distance_multiplier

	if throw_distance_multiplier_upgrade_level==1 then throw_distance_multiplier = 0.25 end

	unit:carry_data():set_carry_id(carry_id)
	unit:carry_data():set_multiplier(1)
	unit:carry_data():set_value(managers.money:get_bag_value(carry_id, 1))
	unit:carry_data():set_dye_pack_data(dye_initiated, has_dye_pack, dye_value_multiplier)
	unit:carry_data():set_latest_peer_id(peer_id)

	if alive(zipline_unit) then
		zipline_unit:zipline():attach_bag(unit)
	else
		unit:push(100, dir * 600 * throw_distance_multiplier)
	end

	unit:interaction():register_collision_callbacks()
end



--NEW FUNCTION: NQR_CHECK_BACKPACK_VALUE
function PlayerManager:nqr_check_backpack_value(a)
	local carry_data = self:get_my_carry_data()
	if not carry_data then return end

	local carry_id = carry_data.carry_id

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local multiplier = carry_data.multiplier
	multiplier = math.max(carry_data.multiplier - a, 0)

	self:update_synced_carry_to_peers(carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, multiplier))
end



--NO SCAVENGER ACED
function PlayerManager:spawn_extra_ammo(unit)
	return
end
















