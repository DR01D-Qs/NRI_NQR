function CopBrain:action_request(new_action_data)
	local new_action_data = new_action_data or {}
	if new_action_data.variant=="hands_up" and new_action_data.blocks then
		new_action_data.blocks.heavy_hurt = nil
		new_action_data.blocks.hurt = nil
		new_action_data.blocks.light_hurt = nil
	end

	return self._unit:movement():action_request(new_action_data)
end



--NQR_CORPSE_LOOT ON PAGER
function CopBrain:on_alarm_pager_interaction(status, player)
	if not managers.groupai:state():whisper_mode() then
		return
	end

	local is_dead = self._unit:character_damage():dead()
	local pager_data = self._alarm_pager_data

	if not pager_data then
		return
	end

	if status == "started" then
		self._unit:sound():stop()
		self._unit:interaction():set_outline_flash_state(nil, true)

		if pager_data.pager_clbk_id then
			managers.enemy:remove_delayed_clbk(pager_data.pager_clbk_id)

			pager_data.pager_clbk_id = nil
		end
	elseif status == "complete" then
		local nr_previous_bluffs = managers.groupai:state():get_nr_successful_alarm_pager_bluffs()
		local has_upgrade = nil

		if player:base().is_local_player then
			has_upgrade = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff")
		else
			has_upgrade = player:base():upgrade_value("player", "corpse_alarm_pager_bluff")
		end

		local chance_table = tweak_data.player.alarm_pager[has_upgrade and "bluff_success_chance_w_skill" or "bluff_success_chance"]
		local chance_index = math.min(nr_previous_bluffs + 1, #chance_table)
		local is_last = chance_table[math.min(chance_index + 1, #chance_table)] == 0
		local rand_nr = math.random()
		local success = chance_table[chance_index] > 0 and rand_nr < chance_table[chance_index]

		self._unit:sound():stop()

		if success then
			managers.groupai:state():on_successful_alarm_pager_bluff()

			local cue_index = is_last and 4 or 1

			if is_dead then
				self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(cue_index)), nil, true)
			else
				self._unit:sound():play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(cue_index)), nil, true)
			end

			if is_last then
				-- Nothing
			end
		else
			managers.groupai:state():on_police_called("alarm_pager_bluff_failed")
			self._unit:interaction():set_active(false, true)

			if is_dead then
				self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
				self._unit:interaction():set_tweak_data("nqr_corpse_loot")
				self._unit:interaction():set_active(true, true)
			else
				self._unit:sound():play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
			end
		end

		self:end_alarm_pager()
		managers.mission:call_global_event("player_answer_pager")

		if not self:_chk_enable_bodybag_interaction() then
			self._unit:interaction():set_active(false, true)
		end
	elseif status == "interrupted" then
		managers.groupai:state():on_police_called("alarm_pager_hang_up")
		self._unit:interaction():set_active(false, true)
		self._unit:sound():stop()

		if is_dead then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
			self._unit:interaction():set_tweak_data("nqr_corpse_loot")
			self._unit:interaction():set_active(true, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
		end

		self:end_alarm_pager()
	end
end



--NQR_CORPSE_LOOT CHECK
function CopBrain:_chk_enable_bodybag_interaction()
	if self:is_pager_started() then
		return
	end

	if not self._unit:character_damage():dead() then
		return
	end

	if not self._alarm_pager_has_run and self._unit:unit_data().has_alarm_pager then
		return
	end

	if self._unit:interaction().tweak_data~="nqr_corpse_loot" then
		self._unit:interaction():set_tweak_data("corpse_dispose")
		self._unit:interaction():set_active(true, true)
	end
	return true
end
