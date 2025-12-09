--FALL DAMAGE: LIGHT FALL DUCKING
function PlayerDamage:damage_fall(data)
	local damage_info = { result = { variant = "fall", type = "hurt" } }
	local is_free_falling = self._unit:movement():current_state_name() == "jerry1"
	local height_limit = 150
	local death_limit = 600

	if self._god_mode and not is_free_falling or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)
		return
	elseif self:incapacitated() then return
	elseif self._unit:movement():current_state().immortal then return
	elseif self._mission_damage_blockers.damage_fall_disabled then return end

	if data.height < height_limit then return end

	self._unit:sound():play("player_hit")
	SoundDevice:set_rtpc("shield_status", 0)
	--self:_send_set_armor()

	local die = data.height > death_limit

	managers.environment_controller:hit_feedback_down()

	if self._bleed_out and not is_free_falling then return end

	if die then
		--managers.mission._fading_debug_output:script().log("lethal fall, height: "..tostring(data.height),  Color.red)

		self:set_health(0)

		if is_free_falling then
			self._revives = Application:digest_value(1, true)

			self:_send_set_revives()
		end
	else
		--managers.mission._fading_debug_output:script().log("light fall, height: "..tostring(data.height),  Color.red)
	end

	local alert_rad = tweak_data.player.fall_damage_alert_size or 500
	local new_alert = {
		"vo_cbt",
		self._unit:movement():m_head_pos(),
		alert_rad,
		self._unit:movement():SO_access(),
		self._unit
	}
	managers.groupai:state():propagate_alert(new_alert)

	self._bleed_out_blocked_by_movement_state = nil

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	self:_damage_screen()
	self:_check_bleed_out(nil, true)
	self:_call_listeners(damage_info)

	local damage_to_take = die and 0 or (tweak_data.player.fall_health_damage * (math.max(0, data.height-200)*0.008))

	return true, damage_to_take
end



function PlayerDamage:damage_explosion(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:incapacitated() then
		return
	end

	local distance = mvector3.distance(attack_data.position, self._unit:position())

	if attack_data.range < distance then
		return
	end

	attack_data.damage = (attack_data.damage or 1) * (1 - distance / attack_data.range)

	if self._bleed_out then
		return
	end

	local armor_attack_data = deep_clone(attack_data)
	armor_attack_data.damage = armor_attack_data.damage*3
	local armor_subtracted = self:_calc_armor_damage(armor_attack_data)

	local health_subtracted = self:_calc_health_damage(attack_data)

	managers.player:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end



--STOP LYING ON REVIVE
function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:player_unit():movement():current_state():_end_action_ducking()
	managers.player:set_player_state("standard")
	managers.player:remove_copr_risen_cooldown()

	if not silent then
		PlayerStandard.say_line(self, "s05x_sin")
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil

	if not arrested then
		self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * (self._revive_health_multiplier or 1) * managers.player:upgrade_value("player", "revived_health_regain", 1))
		self:set_armor(self:_max_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()

	self._revive_health_multiplier = nil

	self._listener_holder:call("on_revive")
end



--STOP MOVING WHILE BEING REVIVED
function PlayerDamage:pause_downed_timer(timer, peer_id)
	self._downed_paused_counter = self._downed_paused_counter + 1

	self:set_peer_paused_counter(peer_id, "downed")

	if self._downed_paused_counter == 1 then
		managers.hud:pd_pause_timer()
		managers.hud:pd_start_progress(0, timer or tweak_data.interaction.revive.timer, "debug_interact_being_revived", "interaction_help")
	end

	self._unit:movement():current_state()._stop_moving = true

	if Network:is_server() then
		managers.network:session():send_to_peers("pause_downed_timer", self._unit)
	end
end
function PlayerDamage:unpause_downed_timer(peer_id)
	self._downed_paused_counter = self._downed_paused_counter - 1

	self:set_peer_paused_counter(peer_id, nil)

	if self._downed_paused_counter == 0 then
		managers.hud:pd_unpause_timer()
		managers.hud:pd_stop_progress()
	end

	self._unit:movement():current_state()._stop_moving = nil

	if Network:is_server() then
		managers.network:session():send_to_peers("unpause_downed_timer", self._unit)
	end
end



--ADD ARMOR VALUE
function PlayerDamage:_raw_max_armor()
	local base_max_armor = 8 + managers.player:body_armor_value("armor") --self._ARMOR_INIT + managers.player:body_armor_skill_addend()
	local mul = managers.player:body_armor_skill_multiplier()
	mul = managers.modifiers:modify_value("PlayerDamage:GetMaxArmor", mul)

	return base_max_armor --* mul
end



--CHECK BLEEDOUT: LYING
function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state, ignore_reduce_revive)
	local time = Application:time()
	local playerstandard = managers.player:player_unit():movement():current_state()
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and managers.player:has_category_upgrade("player", "copr_out_of_health_move_slow") then
			return
		end


		if not self._block_medkit_auto_revive and not ignore_reduce_revive and time > self._uppers_elapsed + self._UPPERS_COOLDOWN then
			local auto_recovery_kit = FirstAidKitBase.GetFirstAidKit(self._unit:position())

			if auto_recovery_kit then
				auto_recovery_kit:take(self._unit)
				self._unit:sound():play("pickup_fak_skill")

				self._uppers_elapsed = time

				return
			end
		end

		if can_activate_berserker and not self._check_berserker_done then
			local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

			if has_berserker_skill and not self._disable_next_swansong then
				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
				managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				self._current_state = nil
				self._check_berserker_done = true

				if alive(self._interaction:active_unit()) and not self._interaction:active_unit():interaction():can_interact(self._unit) then
					self._unit:movement():interupt_interact()
				end

				self._listener_holder:call("on_enter_swansong")
			end

			self._disable_next_swansong = nil
		end

		self._hurt_value = 0.2
		self._damage_to_hot_stack = {}

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not self._check_berserker_done or not can_activate_berserker then
			if not ignore_reduce_revive then
				self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)

				self:_send_set_revives()
			end

			self._check_berserker_done = nil

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

			if Application:digest_value(self._revives, false) == 0 then
				self._down_time = 0
			end

			self._bleed_out = true
			self._current_state = nil

			managers.player:set_player_state("bleed_out")

			self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			self._slomo_sound_instance = self._unit:sound():play("downed_slomo_fx")
			self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

			self:_drop_blood_sample()
			self:on_downed()
		end
	elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.25 then
		self._said_hurt = true

		PlayerStandard.say_line(self, "g80x_plu")
	end
end



--MELEE DAMAGE: NQR_FORCE_REEQUIP ON MELEE DAMAGE
local mvec1 = Vector3()
function PlayerDamage:damage_melee(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local pm = managers.player
	local can_counter_strike = pm:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		self._unit:movement():current_state():discharge_melee()

		return "countered"
	end

	local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
	blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

	if blood_effect then
		local pos = mvec1

		mvector3.set(pos, self._unit:camera():forward())
		mvector3.multiply(pos, 20)
		mvector3.add(pos, self._unit:camera():position())

		local rot = self._unit:camera():rotation():z()

		World:effect_manager():spawn({
			effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
			position = pos,
			normal = rot
		})
	end

	local dmg_mul = pm:damage_reduction_skill_multiplier("melee")
	attack_data.damage = attack_data.damage * dmg_mul

	self:copr_update_attack_data(attack_data)
	self._unit:sound():play("melee_hit_body", nil, nil)

	local result = self:damage_bullet(attack_data)
	local vars = {
		"melee_hit",
		"melee_hit_var2"
	}

	self._unit:camera():play_shaker(vars[math.random(#vars)], 1)

	managers.mission._fading_debug_output:script().log(tostring("nqr_force_reequip on melee damage"),  Color.red)
	self._unit:movement():current_state():_nqr_force_reequip()

	if pm:current_state() == "bipod" then
		self._unit:movement()._current_state:exit(nil, "standard")
		pm:set_player_state("standard")
	end

	self._unit:movement():push(attack_data.push_vel)

	return result
end

function PlayerDamage:damage_killzone(attack_data)
	local damage_info = {
		result = {
			variant = "killzone",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	self._unit:sound():play("player_hit")

	if attack_data.instant_death then
		self:set_armor(0)
		self:set_health(0)
		self:_send_set_armor()
		self:_send_set_health()
		managers.hud:set_player_health({
			current = self:get_real_health(),
			total = self:_max_health(),
			revives = Application:digest_value(self._revives, false)
		})
		self:_set_health_effect()
		self:_damage_screen()
		self:_check_bleed_out(nil)
	else
		self:_hit_direction(attack_data.col_ray.origin, attack_data.col_ray.ray)

		attack_data.damage = attack_data.damage * 0.75
		self:_calc_health_damage(attack_data)

		attack_data.damage = attack_data.damage * ((self:get_real_armor()>6) and 4 or 0)
		self:_calc_armor_damage(attack_data)
	end

	self:_call_listeners(damage_info)
end



function PlayerDamage:set_health(health)
	self:_check_update_max_health()

	local max_health = self:_max_health() * self._max_health_reduction
	health = math.min(health, max_health)
	local prev_health = self._health and Application:digest_value(self._health, false) or health
	self._health = Application:digest_value(math.clamp(health, 0, max_health), true)

	self:_send_set_health()
	self:_set_health_effect()

	if self._said_hurt and self:get_real_health() / self:_max_health() > 0.2 then
		self._said_hurt = false
	end

	if self:health_ratio() < 0.3 then
		self._heartbeat_start_t = TimerManager:game():time()
		self._heartbeat_t = self._heartbeat_start_t + tweak_data.vr.heartbeat_time
	end

	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})

	return prev_health ~= Application:digest_value(self._health, false)
end



function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0

	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		self:change_armor(-attack_data.damage)

		health_subtracted = health_subtracted - self:get_real_armor()

		self:_damage_screen()
		SoundDevice:set_rtpc("shield_status", self:armor_ratio() * 100)
		self:_send_set_armor()

		if self:get_real_armor() <= 0 then
			self._unit:sound():play("player_armor_gone_stinger")

			local pm = managers.player

			self:_start_regen_on_the_side(pm:upgrade_value("player", "passive_always_regen_armor", 0))

			if pm:has_inactivate_temporary_upgrade("temporary", "armor_break_invulnerable") then
				pm:activate_temporary_upgrade("temporary", "armor_break_invulnerable")

				self._can_take_dmg_timer = pm:temporary_upgrade_value("temporary", "armor_break_invulnerable", 0)
			end

			managers.player:player_unit():movement():current_state():_start_action_lying(Application:time())
		end
	end

	managers.hud:damage_taken()

	return attack_data.damage
end
function PlayerDamage:_calc_health_damage(attack_data)
	if attack_data.weapon_unit then
		local wep_base = alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()
		local wep_tweak = wep_base and wep_base.weapon_tweak_data and wep_base:weapon_tweak_data()
		if wep_tweak and wep_tweak.slowdown_data then self:apply_slowdown(wep_tweak.slowdown_data) end
	end

	local health_subtracted = 0
	health_subtracted = self:get_real_health()
	self:change_health(-attack_data.damage)
	health_subtracted = health_subtracted - self:get_real_health()

	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)

	if self:get_real_health() == 0 and trigger_skills then self:_chk_cheat_death() end

	self:_damage_screen()
	self:_check_bleed_out(trigger_skills)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)

	self._health_regen_update_timer = 30

	return health_subtracted
end
function PlayerDamage:_hit_direction(position_vector, direction_vector, color)
	if position_vector then
		managers.hud:on_hit_direction(position_vector, color or (self:get_real_armor() > 0 and HUDHitDirection.DAMAGE_TYPES.ARMOUR or HUDHitDirection.DAMAGE_TYPES.HEALTH))

		if direction_vector then
			local infront = math.dot(self._unit:camera():forward(), direction_vector)

			if infront < -0.9 then
				managers.environment_controller:hit_feedback_front()
			elseif infront > 0.9 then
				managers.environment_controller:hit_feedback_back()
			else
				local polar = self._unit:camera():forward():to_polar_with_reference(-direction_vector, math.UP)
				local direction = Vector3(polar.spin, polar.pitch, 0):normalized()

				if math.abs(direction.y) < math.abs(direction.x) then
					if direction.x < 0 then
						managers.environment_controller:hit_feedback_left()
					else
						managers.environment_controller:hit_feedback_right()
					end
				elseif direction.y < 0 then
					managers.environment_controller:hit_feedback_up()
				else
					managers.environment_controller:hit_feedback_down()
				end
			end
		end
	end
end

function PlayerDamage:_regenerate_armor(no_sound) end

function PlayerDamage:_upd_suppression(t, dt)
	if self._unit:movement() and
	self._unit:movement():current_state() and
	self._unit:movement():current_state()._state_data and
	self._unit:movement():current_state()._state_data.lying then
		return
	end

	local steadiness_regen_speed = 20
	if not (self._regenerate_timer and self._regenerate_timer>0) and self:get_real_armor()<self:_max_armor() then
		self:set_armor(self:get_real_armor() + (steadiness_regen_speed * dt))
		self:_send_set_armor()
	end
end
function PlayerDamage:set_armor(armor)
	if self._armor_change_blocked then
		return
	end

	self:_check_update_max_armor()

	armor = math.clamp(armor, 0, self:_max_armor())

	if self._armor then
		local current_armor = self:get_real_armor()

		if current_armor == 0 and armor ~= 0 then
			self:consume_armor_stored_health()
		elseif current_armor ~= 0 and armor == 0 and self._dire_need then
			local function clbk()
				return self:is_regenerating_armor()
			end

			managers.player:add_coroutine(PlayerAction.DireNeed, PlayerAction.DireNeed, clbk, managers.player:upgrade_value("player", "armor_depleted_stagger_shot", 0))
		end
	end

	self._armor = Application:digest_value(armor, true)
end
function PlayerDamage:_update_regenerate_timer(t, dt)
	self._regenerate_timer = math.max(self._regenerate_timer - dt * (self._regenerate_speed or 1), 0)
end
function PlayerDamage:_upd_health_regen(t, dt)
	if self._health_regen_update_timer then
		self._health_regen_update_timer = self._health_regen_update_timer - dt

		if self._health_regen_update_timer <= 0 then
			self._health_regen_update_timer = nil
		end
	elseif (self:get_real_health()<self:_max_health()) then
		self:change_health(0.5 * dt)
	end
end
function PlayerDamage:band_aid_health()
	if managers.platform:presence() == "Playing" and (self:arrested() or self:need_revive()) then
		return
	end

	self._health_regen_update_timer = math.min(self._health_regen_update_timer or 0, 3)
	self._said_hurt = false
end

function PlayerDamage:set_regenerate_timer_to_max()
	self._regenerate_timer = 0.2
	self._regenerate_speed = self._regenerate_speed or 1
	self._current_state = self._update_regenerate_timer
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then return end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit,
		attack_dir = attack_data.attacker_unit and attack_data.attacker_unit:movement():m_pos() - self._unit:movement():m_pos() or Vector3(1, 0, 0),
		pos = mvector3.copy(self._unit:movement():m_head_pos())
	}
	local pm = managers.player
	local dmg_mul = pm:damage_reduction_skill_multiplier("bullet")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage, attack_data.attacker_unit:base()._tweak_table)

	if _G.IS_VR then
		local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

		if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
			local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
			local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
			attack_data.damage = attack_data.damage * mul
		end
	end

	local damage_absorption = pm:damage_absorption()
	if damage_absorption > 0 then attack_data.damage = math.max(0, attack_data.damage - damage_absorption) end

	if self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end
		self:_call_listeners(damage_info)
		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)
		return
	elseif self:incapacitated() then return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then return
	elseif self._unit:movement():current_state().immortal then return
	elseif self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)
		return
	end

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
	local armor_id = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)].upgrade_level
	local armor_dodge_chance = pm:body_armor_value("dodge")
	local dodge_roll = math.random()

	self._unit:sound():play((dodge_roll<armor_dodge_chance) and "player_hit" or "player_hit_permadamage")

	local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
	local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
	gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
	shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
	local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier
	self._unit:camera():play_shaker("player_bullet_damage", 2 * shake_multiplier)
	if not _G.IS_VR then managers.rumble:play("damage_bullet") end

	local hudhit_color = dodge_roll > armor_dodge_chance and HUDHitDirection.DAMAGE_TYPES.HEALTH or HUDHitDirection.DAMAGE_TYPES.ARMOUR
	self:_hit_direction(attack_data.attacker_unit:position(), attack_data.col_ray and attack_data.col_ray.ray or damage_info.attacK_dir, hudhit_color)

	pm:check_damage_carry(attack_data)

	attack_data.damage = managers.player:modify_value("damage_taken", attack_data.damage, attack_data)

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)
		return
	end

	if not attack_data.ignore_suppression and not self:is_suppressed() then return end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if ((dodge_roll>pm:body_armor_value("dodge", 3)) or (armor_id<3)) then
		if (dodge_roll<armor_dodge_chance) then
			attack_data.damage = attack_data.damage*(attack_data.armor_piercing and 0.25 or 0)
		end
		if attack_data.damage~=0 then self:_calc_health_damage(attack_data) end
	end

	if not self._bleed_out and health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	elseif self._bleed_out then
		self:chk_queue_taunt_line(attack_data)
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_fire(attack_data)
	if attack_data.is_hit then
		return self:damage_fire_hit(attack_data)
	end

	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:incapacitated() then
		return
	end

	local distance = mvector3.distance(attack_data.position or attack_data.col_ray.position, self._unit:position())

	if attack_data.range < distance then
		return
	end

	local damage = attack_data.damage or 1

	if self:get_real_armor() > 0 then
		self._unit:sound():play("player_hit")
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	if self._bleed_out then
		return
	end

	local armor_attack_data = deep_clone(attack_data)
	armor_attack_data.damage = armor_attack_data.damage*3
	local armor_subtracted = self:_calc_armor_damage(armor_attack_data)

	local health_subtracted = self:_calc_health_damage(attack_data)

	self:_call_listeners(damage_info)
end



--INIT: REMOVE GRACE
Hooks:PostHook( PlayerDamage, "init", "nqr_PlayerDamage:init", function(self, unit)
	self._dmg_interval = 0
end)



function PlayerDamage:is_friendly_fire(unit)
	local attacker_mov_ext = alive(unit) and unit:movement()

	if not attacker_mov_ext or not attacker_mov_ext.team or not attacker_mov_ext.friendly_fire then
		return false
	end

	local my_team = self._unit:movement():team()
	local attacker_team = attacker_mov_ext:team()

	if attacker_team ~= my_team and attacker_mov_ext:friendly_fire() then
		return false
	end

	local friendly_fire = attacker_team and not attacker_team.foes[my_team.id]
	friendly_fire = managers.mutators:modify_value("PlayerDamage:FriendlyFire", friendly_fire)

	return friendly_fire
end