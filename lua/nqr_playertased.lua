--ENTER TASED: REMOVE RELOAD
function PlayerTased:enter(state_data, enter_data)
	PlayerTased.super.enter(self, state_data, enter_data)

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_steelsight()

	local t = managers.player:player_timer():time()

	self:_interupt_action_melee(t)
	self:_interupt_action_ladder(t)
	self:_interupt_action_charging_weapon(t)
	self:_start_action_tased(managers.player:player_timer():time(), state_data.non_lethal_electrocution)

	local non_lethal = state_data.non_lethal_electrocution

	if non_lethal then
		state_data.non_lethal_electrocution = nil
		local recover_time = TimerManager:game():time() + tweak_data.player.damage.TASED_TIME * self._non_lethal_tase_time_mul * (state_data.electrocution_duration_multiplier or 1)
		state_data.electrocution_duration_multiplier = nil
		self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"

		managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), recover_time)
	else
		self._fatal_delayed_clbk = "PlayerTased_fatal_delayed_clbk"
		local tased_time = tweak_data.player.damage.TASED_TIME
		tased_time = managers.modifiers:modify_value("PlayerTased:TasedTime", tased_time)

		managers.enemy:add_delayed_clbk(self._fatal_delayed_clbk, callback(self, self, "clbk_exit_to_fatal"), TimerManager:game():time() + tased_time)

		if Network:is_server() then
			self:_register_revive_SO()
		end
	end

	self._countering_tase = nil
	self._next_shock = 0.5
	self._taser_value = 1
	self._num_shocks = 0

	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")

	self._rumble_electrified = managers.rumble:play("electrified")
	self.tased = true
	self._state_data = state_data

	CopDamage.register_listener("on_criminal_tased", {
		"on_criminal_tased"
	}, callback(self, self, "_on_tased_event"))
end



--LYING WHEN OUT OF STAMINA
function PlayerTased:update(t, dt)
	PlayerTased.super.update(self, t, dt)

	if self._unit:movement():is_stamina_drained() and not self._state_data.lying then PlayerTased.super._start_action_lying(self, t) end
end



--PRIMARY FIRE: BOLTING CHECK
function PlayerTased:_check_action_primary_attack(t, input)
	local new_action = nil
	local action_forbidden =
		   self:chk_action_forbidden("primary_attack")
		or self:_is_reloading()
		or self:_changing_weapon()
		or self._melee_expire_t
		or self._use_item_expire_t
		or self:_interacting()
		or alive(self._counter_taser_unit)
	local action_wanted = input.btn_primary_attack_state
	action_wanted = action_wanted or self:is_shooting_count()
	action_wanted = action_wanted or self:_is_charging_weapon()

	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	wep_base._is_bolting =
		(wep_tweak.action=="bolt_action" or wep_tweak.action=="pump_action" or wep_tweak.action=="lever_action")
		and (t < wep_base._next_fire_allowed-wep_base:weapon_fire_rate()*0.66)
	if wep_base._is_bolting and not wep_base._bolting_interupted then
		wep_base._bolting_interupted = true
		wep_base:tweak_data_anim_stop("fire")
	end

	if action_wanted then
		if not action_forbidden then
			if wep_base._bolting_interupted then return end

			self._queue_reload_interupt = nil

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local weap_base = self._equipped_unit:base()
				local fire_mode = weap_base:fire_mode()

				if weap_base:out_of_ammo() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif weap_base.clip_empty and weap_base:clip_empty() then
					if fire_mode == "single" and input.btn_primary_attack_press then
						weap_base:dryfire()
					end
				elseif self._num_shocks > 1 and weap_base.can_refire_while_tased and not weap_base:can_refire_while_tased() then
					-- Nothing
				elseif self._running then
					self:_interupt_action_running(t)
				else
					if not self._shooting and weap_base:start_shooting_allowed() then
						local start = fire_mode == "single" and input.btn_primary_attack_press
						start = start or fire_mode == "auto" and input.btn_primary_attack_state
						start = start or fire_mode == "burst" and input.btn_primary_attack_press
						start = start or fire_mode == "volley" and input.btn_primary_attack_press

						if start then
							weap_base:start_shooting()
							self._camera_unit:base():start_shooting()

							if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", weap_base:fire_rate_multiplier()) then
								weap_base:tweak_data_anim_play("fire", weap_base:fire_rate_multiplier())
							end
						end
					end

					local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
					local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
					local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
					local suppression_mul = managers.blackmarket:threat_multiplier()
					local dmg_mul = managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)

					if managers.player:has_category_upgrade("player", "overkill_all_weapons") or weap_base:is_category("shotgun", "saw") then
						dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "overkill_damage_multiplier", 1)
					end

					local health_ratio = self._ext_damage:health_ratio()
					local primary_category = weap_base:weapon_tweak_data().categories[1]
					local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, primary_category)

					if damage_health_ratio > 0 then
						local upgrade_name = primary_category == "saw" and "melee_damage_health_ratio_multiplier" or "damage_health_ratio_multiplier"
						local damage_ratio = damage_health_ratio
						dmg_mul = dmg_mul * (1 + managers.player:upgrade_value("player", upgrade_name, 0) * damage_ratio)
					end

					dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
					dmg_mul = dmg_mul * managers.player:get_property("trigger_happy", 1)
					local fired = nil

					if fire_mode == "single" then
						if input.btn_primary_attack_press then
							fired = weap_base:trigger_pressed(self._ext_camera:position(), self._ext_camera:forward(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

							if weap_base:fire_on_release() then
								if weap_base.set_tased_shot then
									weap_base:set_tased_shot(true)
								end

								fired = weap_base:trigger_released(self._ext_camera:position(), self._ext_camera:forward(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)

								if weap_base.set_tased_shot then
									weap_base:set_tased_shot(false)
								end
							end
						end
					elseif fire_mode == "burst" then
						fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					elseif fire_mode == "volley" then
						if self._shooting then
							fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						end
					elseif input.btn_primary_attack_state then
						fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					local charging_weapon = weap_base:charging()

					if not self._state_data.charging_weapon and charging_weapon then
						self:_start_action_charging_weapon(t)
					elseif self._state_data.charging_weapon and not charging_weapon then
						self:_end_action_charging_weapon(t)
					end

					new_action = true

					if fired then
						local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
						local recoil_multiplier = weap_base:recoil() * weap_base:recoil_multiplier() + weap_base:recoil_addend()
						local kick_tweak_data = weap_tweak_data.kick[fire_mode] or weap_tweak_data.kick
						local up, down, left, right = unpack(kick_tweak_data[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

						self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)

						local spread_multiplier = weap_base:spread_multiplier()

						self._equipped_unit:base():tweak_data_anim_stop("unequip")
						self._equipped_unit:base():tweak_data_anim_stop("equip")

						if managers.player:has_category_upgrade(primary_category, "stacking_hit_damage_multiplier") then
							self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
							self._state_data.stacking_dmg_mul[primary_category] = self._state_data.stacking_dmg_mul[primary_category] or {
								nil,
								0
							}
							local stack = self._state_data.stacking_dmg_mul[primary_category]

							if fired.hit_enemy then
								stack[1] = t + managers.player:upgrade_value(primary_category, "stacking_hit_expire_t", 1)
								stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_weapon_dmg_mul_stacks or 5)
							else
								stack[1] = nil
								stack[2] = 0
							end
						end

						managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

						if self._ext_network then
							local impact = not fired.hit_enemy

							self._ext_network:send("shot_blank", impact, 0)
						end

						if fire_mode == "volley" then
							self:_check_stop_shooting()
						end
					elseif fire_mode == "single" then
						new_action = false
					elseif fire_mode == "burst" then
						if weap_base:shooting_count() == 0 then
							new_action = false
						end
					elseif fire_mode == "volley" then
						new_action = self:_is_charging_weapon()
					end
				end
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt = true
		end
	end

	if not new_action and self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting()
	end

	self._shooting = new_action

	return new_action
end