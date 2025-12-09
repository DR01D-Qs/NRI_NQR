require("lib/player_actions/PlayerActionManager")
require("lib/managers/player/SmokeScreenEffect")
require("lib/managers/player/PoisonGasEffect")
require("lib/utils/ValueModifier")
require("lib/managers/player/SniperGrazeDamage")

PlayerManager = PlayerManager or class()
PlayerManager.WEAPON_SLOTS = 2
PlayerManager.TARGET_COCAINE_AMOUNT = 1500
PlayerManager._SHOCK_AND_AWE_TARGET_KILLS = 2

local function get_as_digested(amount)
	local list = {}

	for i = 1, #amount do
		table.insert(list, Application:digest_value(amount[i], false))
	end

	return list
end

local function make_double_hud_string(a, b)
	return string.format("%01d|%01d", a, b)
end

local function add_hud_item(amount, icon)
	if #amount > 1 then
		managers.hud:add_item_from_string({
			amount_str = make_double_hud_string(amount[1], amount[2]),
			amount = amount,
			icon = icon
		})
	else
		managers.hud:add_item({
			amount = amount[1],
			icon = icon
		})
	end
end

local function set_hud_item_amount(index, amount)
	if #amount > 1 then
		managers.hud:set_item_amount_from_string(index, make_double_hud_string(amount[1], amount[2]), amount)
	else
		managers.hud:set_item_amount(index, amount[1])
	end
end



--[[function PlayerManager:register_carry(peer, carry_id)
	if Network:is_client() or not managers.network:session() then
		return true
	end

	if not peer then
		return false
	end

	return peer:verify_bag(carry_id, true)
end



function PlayerManager:spawned_player(id, unit)
	self._players[id] = unit

	MenuCallbackHandler:_update_outfit_information()
	self:setup_viewports()
	self:_internal_load()



	self:_change_player_state()

	if id == 1 then
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 1, unit:inventory():unit_by_selection(1):base():fire_mode())
		managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, 2, unit:inventory():unit_by_selection(2):base():fire_mode())

		local grenade_cooldown = tweak_data.blackmarket.projectiles[managers.blackmarket:equipped_grenade()].base_cooldown

		if grenade_cooldown and not self:got_max_grenades() then
			self:replenish_grenades(grenade_cooldown)
		end
	end



	local player = self:player_unit()
	local peer = managers.network:session():local_peer()
	local peer_id = managers.network:session():local_peer():id()

	if not self:get_my_carry_data() then
		for i, k in pairs(self:player_unit():inventory():available_selections()) do
			if k.unit:base():weapon_tweak_data().feed_system=="backpack" then
				--if Network:is_server() then
					self:set_carry("ammo_backpack", 1, true, false, 100)
					--self:register_carry(peer_id, "ammo_backpack")
					--managers.mission:call_global_event("on_picked_up_carry", self:player_unit()._unit)
				--else
					managers.network:session():send_to_peers_synched_except(peer_id, "sync_interacted", player, nil, nil, 1)
					self:sync_interacted(nil, player)
					self:register_carry(peer, "ammo_backpack")

					if Network:is_client() then
						--player:movement():set_carry_restriction(true)
					end

				--end
				break
			end
		end
	end

end
function PlayerManager:sync_interacted(peer, player, status, skip_alive_check)
	local no_player = player == nil
	player = player or peer:unit()

	if peer and not self:register_carry(peer, "ammo_backpack") then
		return
	end

	if self._global_event then
		managers.mission:call_global_event(self._global_event, player)
	end

	if Network:is_server() then
		if peer then
			self:set_carry_approved(peer)
		end
	end

	if no_player then
		managers.mission:call_global_event("on_picked_up_carry", self._unit)
	end
end



function PlayerManager:verify_carry(peer, carry_id)
	if Network:is_client() or not managers.network:session() then
		return true
	end

	if not peer then
		if Network:is_server() then
			return true
		end

		local level_id = managers.job:current_level_id()
		local amount_bags = tweak_data.levels[level_id] and tweak_data.levels[level_id].max_bags or 20
		self._total_bags = self._total_bags and self._total_bags + 1 or 1

		if amount_bags < self._total_bags then
			local peer = managers.network:session():server_peer()

			log("csc")
			peer:mark_cheater(VoteManager.REASON.many_bags)

			return false
		end
	end

	return peer:verify_bag(carry_id, false)
end



function PlayerManager:_internal_load()
	local player = self:player_unit()

	if not player then
		return
	end

	local default_weapon_selection = 1
	local secondary = managers.blackmarket:equipped_secondary()
	local secondary_slot = managers.blackmarket:equipped_weapon_slot("secondaries")
	local texture_switches = managers.blackmarket:get_weapon_texture_switches("secondaries", secondary_slot, secondary)

	player:inventory():add_unit_by_factory_name(secondary.factory_id, default_weapon_selection == 1, false, secondary.blueprint, secondary.cosmetics, texture_switches)

	local primary = managers.blackmarket:equipped_primary()

	if primary then
		local primary_slot = managers.blackmarket:equipped_weapon_slot("primaries")
		local texture_switches = managers.blackmarket:get_weapon_texture_switches("primaries", primary_slot, primary)

		player:inventory():add_unit_by_factory_name(primary.factory_id, default_weapon_selection == 2, false, primary.blueprint, primary.cosmetics, texture_switches)
	end

	player:inventory():hide_equipped_unit()
	player:inventory():set_melee_weapon(managers.blackmarket:equipped_melee_weapon())

	local peer_id = managers.network:session():local_peer():id()
	local grenade, amount = managers.blackmarket:equipped_grenade()

	if self:has_grenade(peer_id) then
		amount = self:get_grenade_amount(peer_id) or amount
	end

	amount = managers.modifiers:modify_value("PlayerManager:GetThrowablesMaxAmount", amount)

	self:_set_grenade({
		grenade = grenade,
		amount = math.min(amount, self:get_max_grenades())
	})
	self:_set_body_bags_amount(managers.blackmarket:forced_body_bags() or self._local_player_body_bags or self:total_body_bags())

	if not self._respawn then
		self:_add_level_equipment(player)

		for i, name in ipairs(self._global.default_kit.special_equipment_slots) do
			local ok_name = self._global.equipment[name] and name

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < 2 or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id
					})
				end
			end
		end

		local slot = 2

		if self:has_category_upgrade("player", "second_deployable") then
			slot = 3
		else
			self:set_equipment_in_slot(nil, 2)
		end

		local equipment_list = self:equipment_slots()

		for i, name in ipairs(equipment_list) do
			local ok_name = self._global.equipment[name] and name or self:equipment_in_slot(i)

			if ok_name then
				local upgrade = tweak_data.upgrades.definitions[ok_name]

				if upgrade and (upgrade.slot and upgrade.slot < slot or not upgrade.slot) then
					self:add_equipment({
						silent = true,
						equipment = upgrade.equipment_id,
						slot = i
					})
				end
			end
		end

		self:update_deployable_selection_to_peers()
	end

	local equipment = self:selected_equipment()

	if equipment then
		add_hud_item(get_as_digested(equipment.amount), equipment.icon)
	end

	if self:has_equipment("armor_kit") then
		managers.mission:call_global_event("player_regenerate_armor", true)
	end



end

function PlayerManager:set_carry(carry_id, carry_multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	local carry_data = tweak_data.carry[carry_id]
	local carry_type = carry_data.type

	self:set_player_state("carry")

	local title = managers.localization:text("hud_carrying_announcement_title")
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local text = managers.localization:text("hud_carrying_announcement", {
		CARRY_TYPE = type_text
	})
	local icon = nil

	if not dye_initiated then
		dye_initiated = true

		if carry_data.dye then
			local chance = tweak_data.carry.dye.chance * managers.player:upgrade_value("player", "dye_pack_chance_multiplier", 1)

			if false then
				has_dye_pack = true
				dye_value_multiplier = math.round(tweak_data.carry.dye.value_multiplier * managers.player:upgrade_value("player", "dye_pack_cash_loss_multiplier", 1))
			end
		end
	end

	self:update_synced_carry_to_peers(carry_id, carry_multiplier or 1, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, carry_multiplier or 1))
	managers.hud:temp_show_carry_bag(carry_id, managers.loot:get_real_value(carry_id, carry_multiplier or 1))

	local player = self:player_unit()

	if not player then
		return
	end

	player:movement():current_state():set_tweak_data(carry_type)
	player:sound():play("Play_bag_generic_pickup", nil, false)

	if carry_id=="ammo_backpack" then
		for i, k in pairs(player:inventory():available_selections()) do
			local wep_base = k.unit:base()
			if wep_base:weapon_tweak_data().feed_system=="backpack" then
				--managers.player:set_synced_carry(managers.network:session():local_peer(), "ammo_backpack", 1, true, false, 1)
				--managers.player:update_synced_carry_to_peers("ammo_backpack", 1, true, false, 1)
				wep_base:set_ammo_total(dye_value_multiplier*10)
				managers.hud:set_ammo_amount(i, wep_base:ammo_info())
			end
		end
	end
end]]



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
	local job = Global.level_data and Global.level_data.level_id

	self._local_player_body_bags = job=="short1_stage1" and 1 or 69
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
	--carry_data.multiplier = player:movement():is_above_stamina_threshold() and 1 or 0
	local position = camera_ext:position()
	local rotation = camera_ext:rotation()
	local forward = player:camera():forward()

	if player then player:sound():play("Play_bag_generic_throw", nil, false) end

	if not weak_throw and not zipline_unit then
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

	if carry_data.carry_id=="ammo_backpack" then
		for i, k in pairs(player:inventory():available_selections()) do
			local wep_base = k.unit:base()
			if wep_base:weapon_tweak_data().feed_system=="backpack" then
				local dye = wep_base:get_ammo_total()*0.1
				local deducted_dye = dye-math.floor(dye)
				deducted_dye = deducted_dye==0 and wep_base:get_ammo_remaining_in_clip()~=0 and 1 or deducted_dye
				dye_value_multiplier = math.max(0, dye - deducted_dye)
				wep_base:set_ammo_total(0)
				wep_base:set_ammo_remaining_in_clip(0)
				managers.hud:set_ammo_amount(i, wep_base:ammo_info())
			end
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
	unit:carry_data():set_multiplier(carry_multiplier)
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
	--[[local carry_data = self:get_my_carry_data()
	if not carry_data then return end

	local carry_id = carry_data.carry_id

	local dye_initiated = carry_data.dye_initiated
	local has_dye_pack = carry_data.has_dye_pack
	local dye_value_multiplier = carry_data.dye_value_multiplier
	local multiplier = carry_data.multiplier
	dye_value_multiplier = math.max(carry_data.dye_value_multiplier - a, 0)

	self:update_synced_carry_to_peers(carry_id, multiplier, dye_initiated, has_dye_pack, dye_value_multiplier)
	managers.hud:set_teammate_carry_info(HUDManager.PLAYER_PANEL, carry_id, managers.loot:get_real_value(carry_id, multiplier))]]
end



--NO SCAVENGER ACED
function PlayerManager:spawn_extra_ammo(unit)
	return
end
















