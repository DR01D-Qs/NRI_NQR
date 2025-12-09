function HintManager:init()
	if not Global.hint_manager then
		Global.hint_manager = {
			hints = {}
		}

		self:_parse_hints()
	end

	Global.hint_manager.hints.not_refillable = {
        trigger_count = 0,
		text_id = "hint_not_refillable",
    	event = "stinger_feedback_positive",
	}

	self._cooldown = {}
end



function HintManager:_show_hint(id, time, params)
	local hint = self:hint(id)

	if not hint then
		return
	end

    local csc = id=="grabbed_small_loot"
    if csc then
        hint.event = nil
    end

	if hint.level and hint.level <= managers.experience:current_level() then
		return
	end

	if hint.stop_at_level and managers.experience:current_level() < hint.stop_at_level then
		return
	end

	if self._cooldown[id] and Application:time() < self._cooldown[id] and not csc then
		return
	end

	if not hint.trigger_times or hint.trigger_times ~= hint.trigger_count then
		self._cooldown[id] = Application:time() + 2
		hint.trigger_count = hint.trigger_count + 1
		self._last_shown_id = id
		params = params or {}
		params.BTN_INTERACT = managers.localization:btn_macro("interact")
		params.BTN_USE_ITEM = managers.localization:btn_macro("use_item")
		params.BTN_CROUCH = managers.localization:btn_macro("duck")
		params.BTN_STATS_VIEW = managers.localization:btn_macro("stats_screen")
		params.BTN_SWITCH_WEAPON = managers.localization:btn_macro("switch_weapon")

		managers.hud:show_hint({
			text = managers.localization:text(hint.text_id, params),
			event = hint.event,
			time = time
		})
	end
end