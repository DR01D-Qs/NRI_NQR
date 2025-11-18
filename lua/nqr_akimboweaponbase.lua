function AkimboWeaponBase:init(...)
	AkimboWeaponBase.super.init(self, ...)

	self._manual_fire_second_gun = self:weapon_tweak_data().manual_fire_second_gun

	self._unit:set_extension_update_enabled(Idstring("base"), true)

	self._fire_callbacks = {}

	self._fire_second_gun_next = self:is_category("revolver") or self:weapon_tweak_data().dao or self:weapon_tweak_data().open_bolt
end



function AkimboWeaponBase:fire(...)
	if not self._manual_fire_second_gun then
		local result = AkimboWeaponBase.super.fire(self, ...)

		if alive(self._second_gun) then
			table.insert(self._fire_callbacks, {
				t = self:get_fire_time(),
				callback = callback(self, self, "_fire_second", {
					...
				})
			})
		end

		return result
	else
		local result = nil

		if self._fire_second_gun_next then
			if alive(self._second_gun) and self._setup and alive(self._setup.user_unit) then
				result = self._second_gun:base().super.fire(self._second_gun:base(), ...)

				if result then
					self._second_gun:base():_fire_sound()
				end
			end

			if not self.delayed then self._fire_second_gun_next = false end
		else
			result = AkimboWeaponBase.super.fire(self, ...)

			if not self.delayed then self._fire_second_gun_next = true end
		end

		return result
	end
end



function AkimboWeaponBase:tweak_data_anim_play(anim, ...)
	local second_gun_anim = self:_second_gun_tweak_data_anim_version(anim)

	if anim=="fire" then
		return (
			not self._fire_second_gun_next
			and alive(self._second_gun)
			and self._second_gun:base():tweak_data_anim_play(second_gun_anim, ...)
		) or AkimboWeaponBase.super.tweak_data_anim_play(self, anim, ...)
	end

	if alive(self._second_gun) then
		self._second_gun:base():tweak_data_anim_play(second_gun_anim, ...)
	end

	return AkimboWeaponBase.super.tweak_data_anim_play(self, anim, ...)
end