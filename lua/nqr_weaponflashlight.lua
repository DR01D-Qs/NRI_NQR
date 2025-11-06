function WeaponFlashLight:init(unit)
	WeaponFlashLight.super.init(self, unit)

	self._on_event = "gadget_flashlight_on"
	self._off_event = "gadget_flashlight_off"
	self._a_flashlight_obj = self._unit:get_object(Idstring("a_flashlight"))
	local is_haunted = nil --self:is_haunted()
	self._g_light = self._unit:get_object(Idstring("g_light"))
	local texture = is_haunted and "units/lights/spot_light_projection_textures/spotprojection_22_flashlight_df" or "units/lights/spot_light_projection_textures/spotprojection_11_flashlight_df"
	self._light = World:create_light("spot|specular|plane_projection", texture)
	self._light_multiplier = is_haunted and 2 or 2
	self._current_light_multiplier = self._light_multiplier

	self._light:set_spot_angle_end(60)
	self._light:set_far_range(is_haunted and 10000 or 5000)
	self._light:set_multiplier(self._current_light_multiplier)
	self._light:link(self._a_flashlight_obj)
	self._light:set_rotation(Rotation(self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y()))
	self._light:set_enable(false)

	local effect_path = is_haunted and "effects/particles/weapons/flashlight_spooky/fp_flashlight" or "effects/particles/weapons/flashlight/fp_flashlight_multicolor"
	self._light_effect = World:effect_manager():spawn({
		force_synch = true,
		effect = Idstring(effect_path),
		parent = self._a_flashlight_obj
	})

	World:effect_manager():set_hidden(self._light_effect, true)
end

function WeaponFlashLight:_check_state(current_state)
	WeaponFlashLight.super._check_state(self, current_state)
	self._light:set_enable(self._on)
	self._g_light:set_visibility(self._on)
	World:effect_manager():set_hidden(self._light_effect, true)

	self._is_haunted = self:is_haunted()

	self._unit:set_extension_update_enabled(Idstring("base"), self._on)
end

function WeaponFlashLight:update(unit, t, dt)
	mrotation.set_xyz(mrot1, self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y())

	if not self._is_haunted then
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)

		return
	end

	t = Application:time()

	self:update_flicker(t, dt)
	self:update_laughter(t, dt)
	self:update_frozen(t, dt)

	if not self._frozen_t then
		self._light_speed = self._light_speed or 1
		self._light_speed = math.step(self._light_speed, 1, dt * (math.random(4) + 2))
		self._light_rotation = (self._light_rotation or 0) + dt * -50 * self._light_speed

		mrotation.set_yaw_pitch_roll(mrot2, self._light_rotation, mrotation.pitch(mrot2), mrotation.roll(mrot2))
		mrotation.multiply(mrot1, mrot2)
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)
	end

	if not self._kittens_timer then
		self._kittens_timer = t + 25
	end

	if self._kittens_timer < t then
		if math.rand(1) < 0.75 then
			self:run_net_event(self.HALLOWEEN_FLICKER)

			self._kittens_timer = t + math.random(10) + 5
		elseif math.rand(1) < 0.35 then
			self:run_net_event(self.HALLOWEEN_WARP)

			self._kittens_timer = t + math.random(12) + 3
		elseif math.rand(1) < 0.3 then
			self:run_net_event(self.HALLOWEEN_FROZEN)

			self._kittens_timer = t + math.random(20) + 30
		elseif math.rand(1) < 0.25 then
			self:run_net_event(self.HALLOWEEN_LAUGHTER)

			self._kittens_timer = t + math.random(5) + 8
		elseif math.rand(1) < 0.15 then
			self:run_net_event(self.HALLOWEEN_SPOOC)

			self._kittens_timer = t + math.random(2) + 3
		else
			self._kittens_timer = t + math.random(5) + 3
		end
	end

	if not self.csc and not self._is_npc then self.csc = true self:set_color(self:color()) end
end


function WeaponFlashLight:set_color(color)
	if self:is_haunted() then
		return
	end

	if not color then
		return
	end

	local opacity_ids = Idstring("opacity")
	local col_vec = Vector3(color.r, color.g, color.b)

	self._light:set_color(col_vec)

	if self._is_npc then
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera r"), opacity_ids, opacity_ids, color.r * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera g"), opacity_ids, opacity_ids, color.g * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera b"), opacity_ids, opacity_ids, color.b * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone r"), opacity_ids, opacity_ids, color.r * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone g"), opacity_ids, opacity_ids, color.g * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone b"), opacity_ids, opacity_ids, color.b * 0)
	else
		local r_ids = Idstring("red")
		local g_ids = Idstring("green")
		local b_ids = Idstring("blue")

		World:effect_manager():set_simulator_var_float(self._light_effect, r_ids, r_ids, opacity_ids, color.r * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, g_ids, g_ids, opacity_ids, color.g * 0)
		World:effect_manager():set_simulator_var_float(self._light_effect, b_ids, b_ids, opacity_ids, color.b * 0)
	end
end

function WeaponFlashLight:set_power(power)
	if not power then return end

	self._light:set_far_range(is_haunted and 10000 or (5000*power))
	self._light:set_multiplier(power)
end