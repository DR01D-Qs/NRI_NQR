function HUDTeammate:_create_primary_weapon_firemode()
	local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
	local weapon_selection_panel = primary_weapon_panel:child("weapon_selection")
	local old_single = weapon_selection_panel:child("firemode_single")
	local old_auto = weapon_selection_panel:child("firemode_auto")

	if alive(old_single) then
		weapon_selection_panel:remove(old_single)
	end

	if alive(old_auto) then
		weapon_selection_panel:remove(old_auto)
	end

	if self._main_player then
		local equipped_primary = managers.blackmarket:equipped_primary()
		local weapon_tweak_data = tweak_data.weapon[equipped_primary.weapon_id]
		local fire_mode = weapon_tweak_data.FIRE_MODE
		local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
		local toggable_fire_modes = weapon_tweak_data.fire_mode_data and weapon_tweak_data.fire_mode_data.toggable

		if toggable_fire_modes then
			can_toggle_firemode = #toggable_fire_modes > 1
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			self._firemode_primary_mapping = {
				[firemode_single_key] = "single",
				[firemode_auto_key] = "auto"
			}
		end

		local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_primary.factory_id, equipped_primary.blueprint)
		local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_primary.factory_id, equipped_primary.blueprint)
		locked_to_auto = managers.weapon_factory:has_perk("fire_mode_burst", equipped_primary.factory_id, equipped_primary.blueprint)
		local single_id = "firemode_single" .. ((not can_toggle_firemode or locked_to_single) and "_locked" or "")

		if toggable_fire_modes and can_toggle_firemode then
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			--single_id = string.format("firemode_%s_%s", firemode_single_key, firemode_auto_key)
		end

		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(single_id)
		local firemode_single = weapon_selection_panel:bitmap({
			name = "firemode_single",
			blend_mode = "mul",
			layer = 1,
			x = 2,
			texture = texture,
			texture_rect = texture_rect
		})

		firemode_single:set_bottom(weapon_selection_panel:h() - 2)
		firemode_single:hide()

		local auto_id = "firemode_auto" .. ((not can_toggle_firemode or locked_to_auto) and "_locked" or "")

		if toggable_fire_modes and can_toggle_firemode then
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			--auto_id = string.format("firemode_%s_%s", firemode_auto_key, firemode_single_key)
		end

		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(auto_id)
		local firemode_auto = weapon_selection_panel:bitmap({
			name = "firemode_auto",
			blend_mode = "mul",
			layer = 1,
			x = 2,
			texture = texture,
			texture_rect = texture_rect
		})

		firemode_auto:set_bottom(weapon_selection_panel:h() - 2)
		firemode_auto:hide()

		if self._firemode_primary_mapping then
			fire_mode = self._firemode_primary_mapping[fire_mode] or fire_mode
		end

		if locked_to_single or not locked_to_auto and fire_mode == "single" then
			firemode_single:show()
		else
			firemode_auto:show()
		end
	end
end

function HUDTeammate:_create_secondary_weapon_firemode()
	local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	local weapon_selection_panel = secondary_weapon_panel:child("weapon_selection")
	local old_single = weapon_selection_panel:child("firemode_single")
	local old_auto = weapon_selection_panel:child("firemode_auto")

	if alive(old_single) then
		weapon_selection_panel:remove(old_single)
	end

	if alive(old_auto) then
		weapon_selection_panel:remove(old_auto)
	end

	if self._main_player then
		local equipped_secondary = managers.blackmarket:equipped_secondary()
		local weapon_tweak_data = tweak_data.weapon[equipped_secondary.weapon_id]
		local fire_mode = weapon_tweak_data.FIRE_MODE
		local can_toggle_firemode = weapon_tweak_data.CAN_TOGGLE_FIREMODE
		local toggable_fire_modes = weapon_tweak_data.fire_mode_data and weapon_tweak_data.fire_mode_data.toggable

		if toggable_fire_modes then
			can_toggle_firemode = #toggable_fire_modes > 1
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			self._firemode_secondary_mapping = {
				[firemode_single_key] = "single",
				[firemode_auto_key] = "auto"
			}
		end

		local locked_to_auto = managers.weapon_factory:has_perk("fire_mode_auto", equipped_secondary.factory_id, equipped_secondary.blueprint)
		local locked_to_single = managers.weapon_factory:has_perk("fire_mode_single", equipped_secondary.factory_id, equipped_secondary.blueprint)
		locked_to_auto = managers.weapon_factory:has_perk("fire_mode_burst", equipped_secondary.factory_id, equipped_secondary.blueprint)
		local single_id = "firemode_single" .. ((not can_toggle_firemode or locked_to_single) and "_locked" or "")

		if toggable_fire_modes and can_toggle_firemode then
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			--single_id = string.format("firemode_%s_%s", firemode_single_key, firemode_auto_key)
		end

		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(single_id)
		local firemode_single = weapon_selection_panel:bitmap({
			name = "firemode_single",
			blend_mode = "mul",
			layer = 1,
			x = 2,
			texture = texture,
			texture_rect = texture_rect
		})

		firemode_single:set_bottom(weapon_selection_panel:h() - 2)
		firemode_single:hide()

		local auto_id = "firemode_auto" .. ((not can_toggle_firemode or locked_to_auto) and "_locked" or "")

		if toggable_fire_modes and can_toggle_firemode then
			local firemode_single_key = toggable_fire_modes[1] or "single"
			local firemode_auto_key = toggable_fire_modes[2] or "auto"
			--auto_id = string.format("firemode_%s_%s", firemode_auto_key, firemode_single_key)
		end

		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(auto_id)
		local firemode_auto = weapon_selection_panel:bitmap({
			name = "firemode_auto",
			blend_mode = "mul",
			layer = 1,
			x = 2,
			texture = texture,
			texture_rect = texture_rect
		})

		firemode_auto:set_bottom(weapon_selection_panel:h() - 2)
		firemode_auto:hide()

		if self._firemode_secondary_mapping then
			fire_mode = self._firemode_secondary_mapping[fire_mode] or fire_mode
		end

		if locked_to_single or not locked_to_auto and fire_mode == "single" then
			firemode_single:show()
		else
			firemode_auto:show()
		end
	end
end