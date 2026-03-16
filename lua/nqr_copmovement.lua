function CopMovement:damage_clbk(my_unit, damage_info)
	local hurt_type = damage_info.result.type

	if hurt_type == "healed" then
		self:request_healed_action()

		return
	end

	hurt_type = managers.modifiers:modify_value("CopMovement:HurtType", hurt_type, damage_info.variant)

	if hurt_type == "stagger" then
		hurt_type = "heavy_hurt"
	end

	local block_type = hurt_type

	if hurt_type ~= "death" and hurt_type ~= "bleedout" and hurt_type ~= "fatal" then
		block_type = "hurt"

		if hurt_type == "knock_down" or hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
			block_type = "heavy_hurt"
		end
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if not hurt_type or Network:is_server() and self:chk_action_forbidden(block_type) then
		if hurt_type == "death" then
			debug_pause_unit(self._unit, "[CopMovement:damage_clbk] Death action skipped!!!", self._unit)
			Application:draw_cylinder(self._m_pos, self._m_pos + math.UP * 5000, 30, 1, 0, 0)

			for body_part, action in ipairs(self._active_actions) do
				if action then
					print(body_part, action:type(), inspect(action._blocks))
				end
			end
		end

		return
	end

	if hurt_type == "hurt_sick" and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
		hurt_type = "shield_knock"
		damage_info.variant = "melee"
		damage_info.result = {
			variant = "melee",
			type = "shield_knock"
		}
		damage_info.shield_knock = true
	end

	if hurt_type == "death" then
		if self._rope then
			self._rope:base():retract()

			self._rope = nil
			self._rope_death = true

			if self._unit:sound().anim_clbk_play_sound then
				self._unit:sound():anim_clbk_play_sound(self._unit, "repel_end")
			end
		end

		if Network:is_server() then
			self:set_attention()
		else
			self:synch_attention()
		end

		local carry_unit = self._carry_unit

		if carry_unit then
			carry_unit:carry_data():unlink()
		end
	end

	local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
	local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
	local lgt_hurt = nil --hurt_type == "light_hurt"
	local body_part = lgt_hurt and 4 or 1
	local blocks = nil

	if not lgt_hurt then
		blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1
		}

		if hurt_type == "bleedout" then
			blocks.bleedout = -1
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.hurt_sick = -1
			blocks.concussion = -1
		end
	end

	if damage_info.variant == "tase" then
		block_type = "bleedout"
	elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	elseif hurt_type ~= "death" and hurt_type ~= "bleedout" and hurt_type ~= "fatal" then
		block_type = "hurt"
	end

	local client_interrupt = nil

	if Network:is_client() and (hurt_type == "light_hurt" or hurt_type == "hurt" and damage_info.variant ~= "tase" or hurt_type == "heavy_hurt" or hurt_type == "expl_hurt" or hurt_type == "shield_knock" or hurt_type == "counter_tased" or hurt_type == "taser_tased" or hurt_type == "counter_spooc" or hurt_type == "death" or hurt_type == "hurt_sick" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "concussion") then
		client_interrupt = true
	end

	local tweak = self._tweak_data
	local action_data = nil
	action_data = {
		type = "hurt",
		block_type = block_type,
		hurt_type = hurt_type,
		variant = damage_info.variant,
		direction_vec = attack_dir,
		hit_pos = hit_pos,
		body_part = body_part,
		blocks = blocks,
		client_interrupt = client_interrupt,
		weapon_unit = damage_info.weapon_unit,
		attacker_unit = damage_info.attacker_unit,
		death_type = tweak.damage.death_severity and (tweak.damage.death_severity < damage_info.damage / tweak.HEALTH_INIT and "heavy" or "normal") or "normal"
	}
	local request_action = Network:is_server() or not self:chk_action_forbidden(action_data)

	if damage_info.is_synced and (hurt_type == "knock_down" or hurt_type == "heavy_hurt") then
		request_action = false
	end

	if request_action then
		if self._ext_brain._current_logic_name=="intimidated" and (hurt_type=="heavy_hurt" or hurt_type=="hurt") then
			self._ext_brain:set_objective(nil)
			CopLogicBase._exit(self._unit, "idle")
		end

		self:action_request(action_data)

		if hurt_type == "death" and self._queued_actions then
			self._queued_actions = {}
		end
	end
end



local ids_movement = Idstring("movement")
function CopMovement:update(unit, t, dt)
	self._gnd_ray = nil

	if self._pre_destroyed then
		return
	end

	local old_need_upd = self._need_upd
	self._need_upd = false

	self:_upd_actions(t)

	if self._need_upd ~= old_need_upd then
		unit:set_extension_update_enabled(ids_movement, self._need_upd)
	end

	if self._force_head_upd then
		self._force_head_upd = nil

		self:upd_m_head_pos()
	end



	if self._dmg_accum then
		self._dmg_accum = self._dmg_accum - (dt*50)
		if self._dmg_accum < 0 then self._dmg_accum = nil end
	end
end



function CopMovement:clbk_inventory(unit, event)
	if event ~= "shield_equip" and event ~= "shield_unequip" then
		local weapon = self._ext_inventory:equipped_unit()

		if weapon then
			if self._weapon_hold then
				for i, hold_type in ipairs(self._weapon_hold) do
					self._machine:set_global(hold_type, 0)
				end
			end

			if self._weapon_anim_global then
				self._machine:set_global(self._weapon_anim_global, 0)
			end

			self._weapon_hold = {}
			local reload_hold_param = nil
			local weap_tweak = weapon:base():weapon_tweak_data()

			if type(weap_tweak.hold) == "table" then
				local num = #weap_tweak.hold + 1
				local reload_times = HuskPlayerMovement.reload_times

				for i, hold_type in ipairs(weap_tweak.hold) do
					self._machine:set_global(hold_type, self:get_hold_type_weight(hold_type) or num - i)
					table.insert(self._weapon_hold, hold_type)

					real_hold = hold_type

					if not reload_hold_param and reload_times[hold_type] then
						reload_hold_param = hold_type

						self._machine:set_global("hold_" .. hold_type, 1)
						table.insert(self._weapon_hold, "hold_" .. hold_type)
					end
				end
			else
				self._machine:set_global(weap_tweak.hold, self:get_hold_type_weight(weap_tweak.hold) or 1)
				table.insert(self._weapon_hold, weap_tweak.hold)

				if HuskPlayerMovement.reload_times[weap_tweak.hold] then
					reload_hold_param = weap_tweak.hold

					self._machine:set_global("hold_" .. weap_tweak.hold, 1)
					table.insert(self._weapon_hold, "hold_" .. weap_tweak.hold)
				end
			end

			local anim_reload_type = nil

			if weap_tweak.reload then
				if weap_tweak.reload ~= "looped" then
					anim_reload_type = "reload_" .. weap_tweak.reload
				end
			elseif reload_hold_param then
				anim_reload_type = "reload_" .. reload_hold_param
			end

			if anim_reload_type then
				self._machine:set_global(anim_reload_type, 1)
				table.insert(self._weapon_hold, anim_reload_type)
			end

			local weapon_usage = weap_tweak.anim_usage or weap_tweak.usage

			self._machine:set_global(weapon_usage, 1)

			self._weapon_anim_global = weapon_usage

			self._machine:set_global("is_npc", 1)

			local weapon_usage_tweak = self._tweak_data.weapon[weap_tweak.usage]
			self._reload_speed_multiplier = weapon_usage_tweak.RELOAD_SPEED or 1

			if weap_tweak.reload == "looped" or weap_tweak.usage == "is_shotgun_pump" then
				local non_looped_reload_time = HuskPlayerMovement.reload_times[weap_tweak.usage == "is_shotgun_pump" and "shotgun" or reload_hold_param or "rifle"]
				self._looped_reload_time = non_looped_reload_time / self._reload_speed_multiplier
				local loop_amount = weap_tweak.looped_reload_single and 1 or weap_tweak.CLIP_AMMO_MAX
				local looped_reload_time = 0.45 * loop_amount
				self._reload_speed_multiplier = looped_reload_time / self._looped_reload_time
			else
				self._looped_reload_time = nil
			end

			local can_drop_mag = nil

			if self:allow_dropped_magazines() then
				local w_td_crew = self:_equipped_weapon_crew_tweak_data()

				if w_td_crew and w_td_crew.pull_magazine_during_reload and self:allow_dropped_magazines() then
					local left_hand = self._unit:get_object(Idstring("LeftHandMiddle1"))

					if left_hand then
						can_drop_mag = true

						if not self._get_reload_hand_velocity then
							self._get_reload_hand_velocity = true
							self._left_hand_obj = left_hand
							self._left_hand_pos = Vector3()
							self._left_hand_direction = Vector3()
							self._left_hand_velocity = nil
						end
					end
				end
			end

			if not can_drop_mag then
				self._get_reload_hand_velocity = nil
				self._left_hand_obj = nil
				self._left_hand_pos = nil
				self._left_hand_direction = nil
				self._left_hand_velocity = nil
			end
		end
	end

	for _, action in ipairs(self._active_actions) do
		if action and action.on_inventory_event then
			action:on_inventory_event(event)
		end
	end
end