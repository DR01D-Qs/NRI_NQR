PlayerInventory = PlayerInventory or class()
PlayerInventory._all_event_types = {
	"add",
	"equip",
	"unequip",
	"shield_equip",
	"shield_unequip"
}
local ids_unit = Idstring("unit")
PlayerInventory._NET_EVENTS = {
	feedback_start = 3,
	jammer_start = 1,
	jammer_stop = 2,
	feedback_stop = 4
}



function PlayerInventory._get_weapon_name_from_sync_index(w_index)
	if not w_index then return end

	if w_index <= #tweak_data.character.weap_unit_names then
		return tweak_data.character.weap_unit_names[w_index]
	end

	w_index = w_index - #tweak_data.character.weap_unit_names

	PlayerInventory._chk_create_w_factory_indexes()

	return PlayerInventory._weapon_factory_indexed[w_index]
end



function PlayerInventory:hide_equipped_unit()
	local unit = self._equipped_selection and self._available_selections[self._equipped_selection].unit

	if unit then
		unit:base():set_visibility_state(false)

		--log("hide_equipped_unit1", unit:base()._name_id, unit:base()._last_gadget_idx)

		if unit:base():enabled() then
			local was_gadget_on = unit:base().is_gadget_on and unit:base()._gadget_on or false
			if was_gadget_on then
				unit:base()._last_gadget_idx = was_gadget_on
			end

			--unit:base():set_gadget_on(0)
			unit:base():on_disabled()
		end

		--log("hide_equipped_unit2", unit:base()._name_id, unit:base()._last_gadget_idx)
	end
end
function PlayerInventory:show_equipped_unit()
	local unit = self._equipped_selection and self._available_selections[self._equipped_selection].unit

	if unit then
		unit:base():set_visibility_state(true)
		unit:base():on_enabled()

		--log("show_equipped_unit1", unit:base()._name_id, unit:base()._last_gadget_idx)

		if unit:base()._last_gadget_idx and unit:base()._last_gadget_idx > 0 then
			unit:base():set_gadget_on(unit:base()._last_gadget_idx)
		end

		--log("show_equipped_unit2", unit:base()._name_id, unit:base()._last_gadget_idx)
	end
end



function PlayerInventory:set_melee_weapon(melee_weapon_id, is_npc)
	if not melee_weapon_id then return end
	self._melee_weapon_data = managers.blackmarket:get_melee_weapon_data(melee_weapon_id)
	self._melee_weapon_id = melee_weapon_id

	if is_npc then
		if self._melee_weapon_data.third_unit then
			self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.third_unit)
		end
	elseif self._melee_weapon_data.unit then
		self._melee_weapon_unit_name = Idstring(self._melee_weapon_data.unit)
	end

	if self._melee_weapon_unit_name then
		managers.dyn_resource:load(Idstring("unit"), self._melee_weapon_unit_name, "packages/dyn_resources", false)
	end
end



function PlayerInventory:need_ammo()
	local refillable = nil

	for _, weapon in pairs(self._available_selections) do
		local caliber_class = (
			weapon.unit:base()
			and weapon.unit:base()._caliber
			and tweak_data.weapon.calibers[weapon.unit:base()._caliber]
			and tweak_data.weapon.calibers[weapon.unit:base()._caliber].class
		)
		local conv_ammo = caliber_class=="rifle" or caliber_class=="shotgun" or caliber_class=="pistol"
		local is_special = weapon.unit:base():is_special()
		refillable = refillable or (conv_ammo and not is_special)

		if conv_ammo and not is_special and not weapon.unit:base():ammo_full() then
			return true
		end
	end

	return false, nil, not refillable and "not_refillable"
end

function PlayerInventory:need_special_ammo()
	for _, weapon in pairs(self._available_selections) do
		local caliber_class = (
			weapon.unit:base()
			and weapon.unit:base()._caliber
			and tweak_data.weapon.calibers[weapon.unit:base()._caliber]
			and tweak_data.weapon.calibers[weapon.unit:base()._caliber].class
		)
		local conv_ammo = caliber_class=="rifle" or caliber_class=="shotgun" or caliber_class=="pistol"

		if not conv_ammo and not weapon.unit:base():ammo_full() then
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



--[[function PlayerInventory:equip_selection(selection_index, instant)
	--log("equip_selection 1", self._equipped_selection, self._selected_primary, selection_index)
	if selection_index and selection_index ~= self._equipped_selection and self._available_selections[selection_index] then
		if self._equipped_selection then
			self:unequip_selection(nil, instant)
		end

		self._equipped_selection = selection_index

		self:_place_selection(selection_index, true)

		self._selected_primary = selection_index

		self:_send_equipped_weapon()
		self:_call_listeners("equip")

		if self._unit:unit_data().mugshot_id then
			local hud_icon_id = self:equipped_unit():base():weapon_tweak_data().hud_icon

			managers.hud:set_mugshot_weapon(self._unit:unit_data().mugshot_id, hud_icon_id, self:equipped_unit():base():weapon_tweak_data().use_data.selection_index)
		end

		self:equipped_unit():base():set_flashlight_enabled(true)
		self:equipped_unit():base():set_scope_enabled(true)

	--log("equip_selection 2", self._equipped_selection, self._selected_primary, selection_index)
		return true
	end
	--log("equip_selection 3", self._equipped_selection, self._selected_primary, selection_index)

	return false
end

function PlayerInventory:_select_new_primary()
	for index, use_data in pairs(self._available_selections) do
		return index
	end
end

function PlayerInventory:add_unit(new_unit, is_equip, equip_is_instant)
	--log("add_unit 1", self._selected_primary, is_equip)
	local new_selection = {}
	local use_data = new_unit:base():get_use_data(self._use_data_alias)
	new_selection.use_data = use_data
	new_selection.unit = new_unit

	new_unit:base():add_destroy_listener(self._listener_id, callback(self, self, "clbk_weapon_unit_destroyed"))

	local selection_index = use_data.selection_index
	is_equip = selection_index==2

	if self._available_selections[selection_index] then
		local old_weapon_unit = self._available_selections[selection_index].unit
		is_equip = is_equip or old_weapon_unit == self:equipped_unit()

		old_weapon_unit:base():remove_destroy_listener(self._listener_id)
		old_weapon_unit:base():set_slot(old_weapon_unit, 0)
		World:delete_unit(old_weapon_unit)

		if self._equipped_selection == selection_index then
			self._equipped_selection = nil
		end
	end

	self._available_selections[selection_index] = new_selection
	self._latest_addition = selection_index
	self._selected_primary = selection_index --self._selected_primary or selection_index

	self:_call_listeners("add")

	--log("add_unit 2", self._selected_primary, is_equip)
	if is_equip then
		self:equip_latest_addition(equip_is_instant)
	else
		self:_place_selection(selection_index, is_equip)
	end
	--log("add_unit 3", self._selected_primary, is_equip)
end
]]