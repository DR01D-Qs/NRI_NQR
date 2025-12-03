function MenuSceneManager:get_henchmen_positioning(index)
	local offset = Vector3(0, -100, -130)
	local rotation = {
		-65,
		-79,
		-89
	}
	local mvec = Vector3()
	local math_up = math.UP
	local pos = Vector3()
	local rot = Rotation()

	mrotation.set_yaw_pitch_roll(rot, rotation[math.min(index, #rotation)], 0, 0)
	mvector3.set(pos, offset)
	mvector3.rotate_with(pos, rot)
	mvector3.set(mvec, pos)
	mvector3.negate(mvec)
	mvector3.set_z(mvec, 0)
	mvector3.set(mvec, mvec + Vector3(100, 150, 0))
	mrotation.set_look_at(rot, mvec, math_up)
	mvector3.set_x(pos, 50 + -80 * index)
	mvector3.set_z(pos, -135)

	return pos, rot
end

function MenuSceneManager:_setup_henchmen_characters()
	if self._henchmen_characters then
		for _, unit in ipairs(self._henchmen_characters) do
			self:_delete_character_mask(unit)
			World:delete_unit(unit)
		end
	end

	self._henchmen_characters = {}
	local masks = {
		"dallas",
		"dallas",
		"dallas"
	}

	for i = 1, 3 do
		local pos, rot = self:get_henchmen_positioning(i)
		local unit_name = tweak_data.blackmarket.characters.locked.menu_unit
		local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

		self:_init_character(unit, i)
		self:set_character_mask(tweak_data.blackmarket.masks[masks[i]].unit, unit, nil, masks[i])
		table.insert(self._henchmen_characters, unit)

		self._character_visibilities[unit:key()] = false

		self:_chk_character_visibility(unit)
	end
end