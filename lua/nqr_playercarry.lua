--NO BAG TILT
function PlayerCarry:enter(state_data, enter_data)
	PlayerCarry.super.enter(self, state_data, enter_data)
	self._throw_redirect_t = nil
end
function PlayerCarry:exit(state_data, new_state_name)
	PlayerCarry.super.exit(self, state_data, new_state_name)

	local exit_data = {
		skip_equip = true
	}
	self._dye_risk = nil

	managers.job:set_memory("kill_count_carry", nil, true)
	managers.job:set_memory("kill_count_no_carry", nil, true)

	self._state_data.previous_state = "carry"

	return exit_data
end



--CHECK SPRINT: SPRINT WITH ANY BAG
function PlayerCarry:_check_action_run(...)
	PlayerCarry.super._check_action_run(self, ...)
end

--NQR BAG THROW
function PlayerCarry:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_release and self._throw_time and t and t < self._throw_time

	if input.btn_use_item_press then
		self._throw_down = true
		self._second_press = false
		self._throw_time = t + PlayerCarry.throw_limit_t
	end

	if action_wanted then
		local action_forbidden = (
			self._use_item_expire_t
			or self:_changing_weapon()
			or self:_interacting()
			or self._ext_movement:has_carry_restriction()
			or self:_is_throwing_projectile()
			or self:_on_zipline()
			or not self:_is_movement_equipped()
		)

		if not action_forbidden then
			self:_play_interact_redirect(t)
			self._throw_redirect_t = t + 0.4
			self._released = true
		end
	end

	if self._throw_redirect_t then
		if (self._throw_redirect_t < t) or (self._released and input.btn_use_item_press) then
			managers.player:drop_carry(nil, t <= self._throw_redirect_t)
			self._throw_redirect_t = nil
			self._throw_down = nil
			self._throw_time = nil
			self._released = nil

			new_action = true
		end
	end

	if self._throw_down then
		if input.btn_use_item_release then
			self._throw_down = false
			self._second_press = false

			return PlayerCarry.super._check_use_item(self, t, input)
		elseif self._throw_time < t then
			if not self._second_press then
				input.btn_use_item_press = true
				self._second_press = true
			end

			return PlayerCarry.super._check_use_item(self, t, input)
		end
	end

	return new_action
end

function PlayerCarry:_update_check_actions(...)
	return PlayerCarry.super._update_check_actions(self, ...)
end
