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
