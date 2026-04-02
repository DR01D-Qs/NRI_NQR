local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()



function HUDManager:add_waypoint(id, data)
	if string.find(id, "susp", 1, true) then return end

	if self._hud.waypoints[id] then
		self:remove_waypoint(id)
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)

	if not hud then
		self._hud.stored_waypoints[id] = data

		return
	end

	local waypoint_panel = hud.panel
	local icon = data.icon or "wp_standard"
	local text = ""
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(icon, {
		0,
		0,
		32,
		32
	})
	local bitmap = waypoint_panel:bitmap({
		layer = 0,
		rotation = 360,
		name = "bitmap" .. id,
		texture = icon,
		texture_rect = texture_rect,
		w = texture_rect[3],
		h = texture_rect[4],
		blend_mode = data.blend_mode
	})
	local arrow_icon, arrow_texture_rect = tweak_data.hud_icons:get_icon_data("wp_arrow")
	local arrow = waypoint_panel:bitmap({
		layer = 0,
		visible = false,
		rotation = 360,
		name = "arrow" .. id,
		texture = arrow_icon,
		texture_rect = arrow_texture_rect,
		color = (data.color or Color.white):with_alpha(0.75),
		w = arrow_texture_rect[3],
		h = arrow_texture_rect[4],
		blend_mode = data.blend_mode
	})
	local distance = nil

	if data.distance then
		distance = waypoint_panel:text({
			vertical = "center",
			h = 24,
			w = 128,
			align = "center",
			text = "16.5",
			rotation = 360,
			layer = 0,
			name = "distance" .. id,
			color = data.color or Color.white,
			font = tweak_data.hud.medium_font_noshadow,
			font_size = tweak_data.hud.default_font_size,
			blend_mode = data.blend_mode
		})

		distance:set_visible(false)
	end

	local timer = data.timer and waypoint_panel:text({
		font_size = 32,
		h = 32,
		vertical = "center",
		w = 32,
		align = "center",
		rotation = 360,
		layer = 0,
		name = "timer" .. id,
		text = (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer),
		font = tweak_data.hud.medium_font_noshadow
	})
	text = waypoint_panel:text({
		h = 24,
		vertical = "center",
		w = 512,
		align = "center",
		rotation = 360,
		layer = 0,
		name = "text" .. id,
		text = utf8.to_upper(" " .. text),
		font = tweak_data.hud.small_font,
		font_size = tweak_data.hud.small_font_size
	})
	local _, _, w, _ = text:text_rect()

	text:set_w(w)

	local w, h = bitmap:size()
	self._hud.waypoints[id] = {
		move_speed = 1,
		init_data = data,
		state = data.state or "present",
		present_timer = data.present_timer or 2,
		bitmap = bitmap,
		arrow = arrow,
		size = Vector3(w, h, 0),
		text = text,
		distance = distance,
		timer_gui = timer,
		timer = data.timer,
		pause_timer = data.pause_timer or data.timer and 0,
		position = data.position,
		unit = data.unit,
		no_sync = data.no_sync,
		radius = data.radius or 160
	}
	self._hud.waypoints[id].init_data.position = data.position or data.unit:position()
	local slot = 1
	local t = {}

	for _, data in pairs(self._hud.waypoints) do
		if data.slot then
			t[data.slot] = data.text:w()
		end
	end

	for i = 1, 10 do
		if not t[i] then
			self._hud.waypoints[id].slot = i

			break
		end
	end

	self._hud.waypoints[id].slot_x = 0

	if self._hud.waypoints[id].slot == 2 then
		self._hud.waypoints[id].slot_x = t[1] / 2 + self._hud.waypoints[id].text:w() / 2 + 10
	elseif self._hud.waypoints[id].slot == 3 then
		self._hud.waypoints[id].slot_x = -t[1] / 2 - self._hud.waypoints[id].text:w() / 2 - 10
	elseif self._hud.waypoints[id].slot == 4 then
		self._hud.waypoints[id].slot_x = t[1] / 2 + t[2] + self._hud.waypoints[id].text:w() / 2 + 20
	elseif self._hud.waypoints[id].slot == 5 then
		self._hud.waypoints[id].slot_x = -t[1] / 2 - t[3] - self._hud.waypoints[id].text:w() / 2 - 20
	end
end
function HUDManager:_update_waypoints(t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, wp_cam_forward)

	for id, data in pairs(self._hud.waypoints) do
		local panel = data.bitmap:parent()

		if data.state == "dirty" then
			-- Nothing
		end

		if data.state == "sneak_present" then
			data.current_position = Vector3(panel:center_x(), panel:center_y())

			data.bitmap:set_center_x(data.current_position.x)
			data.bitmap:set_center_y(data.current_position.y)

			data.slot = nil
			data.current_scale = 1
			data.state = "present_ended"
			data.text_alpha = 0.5
			data.in_timer = 0
			data.target_scale = 1

			if data.distance then
				data.distance:set_visible(true)
			end
		elseif data.state == "present" then
			data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)

			data.bitmap:set_center_x(data.current_position.x)
			data.bitmap:set_center_y(data.current_position.y)
			data.text:set_center_x(data.bitmap:center_x())
			data.text:set_top(data.bitmap:bottom())

			data.present_timer = data.present_timer - dt

			if data.present_timer <= 0 then
				data.slot = nil
				data.current_scale = 1
				data.state = "present_ended"
				data.text_alpha = 0.5
				data.in_timer = 0
				data.target_scale = 1

				if data.distance then
					data.distance:set_visible(true)
				end
			end
		else
			if data.text_alpha ~= 0 then
				data.text_alpha = math.clamp(data.text_alpha - dt, 0, 1)

				data.text:set_color(data.text:color():with_alpha(data.text_alpha))
			end

			data.position = data.unit and data.unit:position() or data.position

			mvector3.set(wp_pos, self._saferect:world_to_screen(cam, data.position))
			mvector3.set(wp_dir, data.position)
			mvector3.subtract(wp_dir, cam_pos)
			mvector3.set(wp_dir_normalized, wp_dir)
			mvector3.normalize(wp_dir_normalized)

			local alpha = 0.5
			local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)
			if dot < 0 or panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
				if data.state ~= "offscreen" then
					data.state = "offscreen"

					data.arrow:set_visible(true)
					data.arrow:set_color(data.arrow:color():with_alpha(alpha))
					data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))

					data.off_timer = 0 - (1 - data.in_timer)
					data.target_scale = 0.75

					if data.distance then
						data.distance:set_visible(false)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(false)
					end
				end

				local direction = wp_onscreen_direction
				local panel_center_x, panel_center_y = panel:center()

				mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
				mvector3.normalize(direction)

				local distance = data.radius * tweak_data.scale.hud_crosshair_offset_multiplier
				local target_pos = wp_onscreen_target_pos

				mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

				data.off_timer = math.clamp(data.off_timer + dt / data.move_speed, 0, 1)

				if data.off_timer ~= 1 then
					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						target_pos,
						target_pos
					}, data.off_timer))

					data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.off_timer)

					data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, target_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
				data.arrow:set_center(mvector3.x(data.current_position) + direction.x * 24, mvector3.y(data.current_position) + direction.y * 24)

				local angle = math.X:angle(direction) * math.sign(direction.y)

				data.arrow:set_rotation(angle)

				if data.text_alpha ~= 0 then
					data.text:set_center_x(data.bitmap:center_x())
					data.text:set_top(data.bitmap:bottom())
				end
			else
				if data.state == "offscreen" then
					data.state = "onscreen"

					data.arrow:set_visible(false)
					data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))

					data.in_timer = 0 - (1 - data.off_timer)
					data.target_scale = 1

					if data.distance then
						data.distance:set_visible(true)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(true)
					end
				end

				if dot > 0.96 then
					local val = 14.9 - dot * 15
					alpha = (val > 0.1) and val or 0.1
				end
				--managers.mission._fading_debug_output:script().log(tostring(dot), Color.white)
				--managers.mission._fading_debug_output:script().log(tostring(alpha), Color.white)

				if data.bitmap:color().alpha ~= alpha then
					data.bitmap:set_color(data.bitmap:color():with_alpha(alpha))

					if data.distance then
						data.distance:set_color(data.distance:color():with_alpha(alpha))
					end

					if data.timer_gui then
						data.timer_gui:set_color(data.bitmap:color():with_alpha(alpha))
					end
				end

				if data.in_timer ~= 1 then
					data.in_timer = math.clamp(data.in_timer + dt / data.move_speed, 0, 1)

					mvector3.set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						wp_pos,
						wp_pos
					}, data.in_timer))

					data.current_scale = math.bezier({
						data.current_scale,
						data.current_scale,
						data.target_scale,
						data.target_scale
					}, data.in_timer)

					data.bitmap:set_size(data.size.x * data.current_scale, data.size.y * data.current_scale)
				else
					mvector3.set(data.current_position, wp_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

				if data.text_alpha ~= 0 then
					data.text:set_center_x(data.bitmap:center_x())
					data.text:set_top(data.bitmap:bottom())
				end

				if data.distance then
					local length = wp_dir:length()

					data.distance:set_font_size(16)
					data.distance:set_text(string.format("%.0f", length / 100) .. "m")
					data.distance:set_center_x(data.bitmap:center_x())
					data.distance:set_top(data.bitmap:bottom()-4)
				end
			end
		end

		if data.timer_gui then
			data.timer_gui:set_center_x(data.bitmap:center_x())
			data.timer_gui:set_bottom(data.bitmap:top())

			if data.pause_timer == 0 then
				data.timer = data.timer - dt
				local text = data.timer < 0 and "00" or (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer)

				data.timer_gui:set_text(text)
			end
		end
	end
end



function HUDManager:show_hint(params)
	self._cooldown = (self._cooldown and self._cooldown[params.text]) and self._cooldown or {}

	if self._cooldown[params.text] and Application:time() < self._cooldown[params.text] then return end
	self._cooldown[params.text] = params.cd_start

	self._hud_hint:show(params)

	if params.event then self._sound_source:post_event(params.event) end
end



function HUDManager:on_hit_confirmed(damage_scale) end
function HUDManager:on_crit_confirmed(damage_scale) end



function HUDManager:_create_suspicion(hud) end
function HUDManager:set_suspicion(status) end