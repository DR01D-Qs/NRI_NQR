--KNOCKDOWN INSTEAD OF INCAP
function PlayerMovement:on_SPOOCed(enemy_unit)
	if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
		self._current_state:discharge_melee()

		return "countered"
	end

	if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
		return
	end

	if self._current_state_name == "standard" or self._current_state_name == "carry" or self._current_state_name == "bleed_out" or self._current_state_name == "tased" or self._current_state_name == "bipod" then
		local state = "incapacitated"
		state = managers.modifiers:modify_value("PlayerMovement:OnSpooked", state)

		managers.player:player_unit():movement():current_state():_start_action_lying(TimerManager:game():time())

		managers.achievment:award(tweak_data.achievement.finally.award)

		return true
	end
end



--STAMINA: STATE MULTIPLIERS
function PlayerMovement:update_stamina(t, dt, ignore_running)
    self._move_dir = mvector3.copy(self._unit:base():controller():get_input_axis("move"))
    local is_moving = (self._move_dir~=Vector3(0,0,0)) and self.move_speed and self.move_speed:length()>0
    local is_ducking = self._state_data.ducking
    local is_running = self._is_running

    local dt = self._last_stamina_regen_t and t - self._last_stamina_regen_t or dt
	self._last_stamina_regen_t = t

	if self:tased() then
		self:subtract_stamina(dt * ((tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE*16) / managers.player:body_armor_value("stamina")))
	elseif not ignore_running and (is_running or (is_moving and is_ducking)) then
		self:subtract_stamina(dt * ((tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE - (is_ducking and 0.5 or 0) + (is_running and 1 or 0)) / managers.player:body_armor_value("stamina")))
	elseif self._regenerate_timer then
		self._regenerate_timer = self._regenerate_timer - dt

		if self._regenerate_timer < 0 then
			self:add_stamina(dt * (tweak_data.player.movement_state.stamina.STAMINA_REGEN_RATE - (is_moving and 0.2 or 0) + (is_ducking and 0.5 or 0)))

			if self:_max_stamina() <= self._stamina then
				self._regenerate_timer = nil
			end
		end
	elseif self._stamina < self:_max_stamina() then
		self:_restart_stamina_regen_timer()
	end

	if _G.IS_VR then
		managers.hud:set_stamina({
			current = self._stamina,
			total = self:_max_stamina()
		})
	end

end



function PlayerMovement:_change_stamina(value)
	local max_stamina = self:_max_stamina()
	local min_stamina_threshold = tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
	local stamina_maxed = self._stamina == max_stamina
	self._stamina = math.clamp(self._stamina + value, 0, max_stamina)

	managers.hud:set_stamina_value(self._stamina)

	if stamina_maxed and self._stamina < max_stamina then
		self._unit:sound():play("fatigue_breath")
	elseif not stamina_maxed and max_stamina <= self._stamina then
		self._unit:sound():play("fatigue_breath_stop")
	end

	self.stamina_breath = math.clamp((self._stamina-min_stamina_threshold) / (max_stamina-min_stamina_threshold), 0, 1) * 75
	SoundDevice:set_rtpc("stamina", self.stamina_breath)
end



--REMOVE MAX STAMINA PENALTY FROM ARMOR
function PlayerMovement:_max_stamina()
	local base_stamina = self._STAMINA_INIT + managers.player:stamina_addend()
	local max_stamina = base_stamina * managers.player:stamina_multiplier() -- * managers.player:body_armor_value("stamina")

	managers.hud:set_max_stamina(max_stamina)

	return max_stamina
end
