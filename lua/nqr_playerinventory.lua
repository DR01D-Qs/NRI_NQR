function PlayerInventory:need_ammo()
	for _, weapon in pairs(self._available_selections) do
		if not weapon.unit:base():ammo_full() then
			return true
		end
	end

	return false, nil, "csc"
end



function PlayerInventory:_start_feedback_effect(end_time)
	if self._jammer_data then
		self:_chk_queue_jammer_effect("feedback")

		return
	end

	end_time = end_time or self:get_jammer_time()

	if end_time == 0 then
		return false
	end

	local interval, range, nr_ticks = nil

	if Network:is_server() then
		interval, range = self:get_feedback_values()

		if interval == 0 or range == 0 then
			return false
		end

		nr_ticks = math.max(1, math.floor(end_time / interval))
	end

	local t = TimerManager:game():time()
	local key_str = tostring(self._unit:key())
	end_time = t + end_time
	self._jammer_data = {
		effect = "feedback",
		t = end_time,
		interval = interval,
		range = range,
		sound = self._unit:sound_source():post_event("ecm_jammer_puke_signal"),
		feedback_callback_key = "PocketECMFeedback" .. key_str,
		nr_ticks = nr_ticks
	}

	if Network:is_server() then
		local interval_t = t + interval

		if nr_ticks == 1 and end_time < interval_t then
			interval_t = end_time or interval_t
		end

		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_do_feedback"), interval_t)
	else
		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_clbk_stop_feedback_effect"), end_time)
	end

	local local_player = managers.player:player_unit()
	local user_is_local_player = local_player and local_player:key() == self._unit:key()
	local dodge = user_is_local_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")
	local heal = user_is_local_player and self._unit:base():upgrade_value("player", "pocket_ecm_heal_on_kill") or self._unit:base():upgrade_value("team", "pocket_ecm_heal_on_kill")

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "PocketECMFeedbackDodge" .. key_str

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end

	if heal then
		self._jammer_data.heal = heal
		self._jammer_data.heal_listener_key = "PocketECMFeedbackHeal" .. key_str

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, callback(self, self, "_feedback_heal_on_kill"))
	end

	return true
end
