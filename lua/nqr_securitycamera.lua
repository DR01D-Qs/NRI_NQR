SecurityCamera = SecurityCamera or class()
SecurityCamera.cameras = SecurityCamera.cameras or {}
SecurityCamera.active_tape_loop_unit = nil
SecurityCamera.is_security_camera = true
SecurityCamera._NET_EVENTS = {
	suspicion_4 = 6,
	start_tape_loop_2 = 10,
	suspicion_1 = 3,
	start_tape_loop_1 = 9,
	suspicion_2 = 4,
	request_start_tape_loop_1 = 11,
	request_start_tape_loop_2 = 12,
	alarm_start = 2,
	deactivate_tape_loop = 13,
	suspicion_5 = 7,
	suspicion_6 = 8,
	suspicion_3 = 5,
	sound_off = 1
}
local tmp_rot1 = Rotation()



function SecurityCamera:_set_suspicion_sound(suspicion_level)
end

function SecurityCamera:_sound_the_alarm(detected_unit)
	if self._alarm_sound then
		return
	end

	if Network:is_server() then
		if self._mission_script_element then
			self._mission_script_element:on_alarm(self._unit)
		end

		self:_send_net_event(self._NET_EVENTS.alarm_start)

		self._call_police_clbk_id = "cam_call_cops" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._call_police_clbk_id, callback(self, self, "clbk_call_the_police"), Application:time() + 7)

		local reason_called = managers.groupai:state().analyse_giveaway("security_camera", detected_unit)
		self._reason_called = managers.groupai:state():fetch_highest_giveaway(self._reason_called, reason_called)

		self:_destroy_all_detected_attention_object_data()
		self:set_detection_enabled(false, nil, nil)
	end
end