require("lib/managers/workshop/SkinEditor")
require("lib/managers/workshop/ArmorSkinEditor")
require("lib/utils/accelbyte/TelemetryConst")

BlackMarketManager = BlackMarketManager or class()
local INV_TO_CRAFT = Idstring("inventory_to_crafted")
local CRAFT_TO_INV = Idstring("crafted_to_inventroy")
local INV_ADD = Idstring("add_to_inventory")
local INV_REMOVE = Idstring("remove_from_inventory")
local CRAFT_ADD = Idstring("add_to_crafted")
local CRAFT_REMOVE = Idstring("remove_from_crafted")
local MASK_COLOR_CONVERT_MAP = {
	color_b = "mask_colors",
	material = "materials",
	color_a = "mask_colors",
	pattern = "textures"
}
local DEFAULT_MASK_BLUEPRINT = {
	color = {
		id = "nothing",
		global_value = "normal"
	},
	pattern = {
		id = "no_color_no_material",
		global_value = "normal"
	},
	material = {
		id = "plastic",
		global_value = "normal"
	}
}
local DEFAULT_CUSTOMIZE_MASK_BLUEPRINT = {
	mask_colors = {
		id = "nothing",
		global_value = "normal"
	},
	color_a = {
		id = "nothing",
		global_value = "normal"
	},
	color_b = {
		id = "nothing",
		global_value = "normal"
	},
	textures = {
		id = "no_color_full_material",
		global_value = "normal"
	},
	materials = {
		id = "plastic",
		global_value = "normal"
	}
}



function BlackMarketManager:weapon_unlocked_by_crafted(category, slot)
	local crafted = self._global.crafted_items[category][slot]

	if not crafted then
		return false
	end

	local weapon_id = crafted.weapon_id
	local cosmetics = crafted.cosmetics
	local cosmetics_data = cosmetics and cosmetics.id and tweak_data.blackmarket.weapon_skins[cosmetics.id]
	local cosmetic_blueprint = cosmetics_data and cosmetics_data.default_blueprint or {}
	local data = Global.blackmarket_manager.weapons[weapon_id]
	local unlocked = data.unlocked
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id))

	if _G.IS_VR then
		unlocked = unlocked and not data.vr_locked
	end

	if unlocked then
		local is_any_part_dlc_locked = false

		for part_id, dlc in pairs(crafted.global_values or {}) do
			local shs = table.contains(default_blueprint, part_id)
			if not table.contains(cosmetic_blueprint, part_id) and dlc ~= "normal" and dlc ~= "infamous" and not managers.dlc:is_dlc_unlocked(dlc) and not shs then
				return false, dlc
			end
		end

		if cosmetics_data then
			local dlc = cosmetics_data.dlc or managers.dlc:global_value_to_dlc(cosmetics_data.global_value)

			if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
				return false, dlc
			end
		end
	end

	if data.func_based and not self[data.func_based](self) then
		return false
	end

	if crafted.previewing then
		return false
	end

	for _, part_id in ipairs(crafted.blueprint) do
		local event_job_challenge = managers.event_jobs:get_challenge_from_reward("weapon_mods", part_id)
		local shs = table.contains(default_blueprint, part_id)

		if event_job_challenge and not event_job_challenge.completed and not shs then
			--return false, event_job_challenge.locked_id or "menu_event_job_lock_info" --todo remove later
		end
	end

	return unlocked
end



--STATS TABLES TO NUMERIC
function BlackMarketManager:recoil_addend(name, categories, recoil_index, silencer, blueprint, current_state, is_single_shot)
	local addend = 0

	if recoil_index then
		local index = recoil_index
		index = index + managers.player:upgrade_value("weapon", "recoil_index_addend", 0)
		index = index + managers.player:upgrade_value("player", "stability_increase_bonus_1", 0)
		index = index + managers.player:upgrade_value("player", "stability_increase_bonus_2", 0)
		index = index + managers.player:upgrade_value(name, "recoil_index_addend", 0)

		for _, category in ipairs(categories) do
			index = index + managers.player:upgrade_value(category, "recoil_index_addend", 0)
		end

		if managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
			for _, category in ipairs(categories) do
				if managers.player:has_team_category_upgrade(category, "suppression_recoil_index_addend") then
					index = index + managers.player:team_upgrade_value(category, "suppression_recoil_index_addend", 0)
				end
			end

			if managers.player:has_team_category_upgrade("weapon", "suppression_recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "suppression_recoil_index_addend", 0)
			end
		else
			for _, category in ipairs(categories) do
				if managers.player:has_team_category_upgrade(category, "recoil_index_addend") then
					index = index + managers.player:team_upgrade_value(category, "recoil_index_addend", 0)
				end
			end

			if managers.player:has_team_category_upgrade("weapon", "recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "recoil_index_addend", 0)
			end
		end

		if silencer then
			index = index + managers.player:upgrade_value("weapon", "silencer_recoil_index_addend", 0)

			for _, category in ipairs(categories) do
				index = index + managers.player:upgrade_value(category, "silencer_recoil_index_addend", 0)
			end
		end

		if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
			index = index + managers.player:upgrade_value("weapon", "modded_recoil_index_addend", 0)
		end

		--local recoil_tweak = tweak_data.weapon.stats.recoil
		--index = math.clamp(index, 1, #recoil_tweak)
		--recoil_index = math.clamp(recoil_index, 1, #recoil_tweak)

		--if index ~= recoil_index then
		--	local diff = recoil_tweak[index] - recoil_tweak[recoil_index]
		--	addend = addend + diff
		--end
	end

	return addend
end
function BlackMarketManager:accuracy_addend(name, categories, spread_index, silencer, current_state, fire_mode, blueprint, is_moving, is_single_shot)
	local addend = 0

	if spread_index then
		local index = spread_index
		index = index + managers.player:upgrade_value("player", "weapon_accuracy_increase", 0)

		for _, category in ipairs(categories) do
			index = index + managers.player:upgrade_value(category, "spread_index_addend", 0)

			if current_state and current_state._moving then
				index = index + managers.player:upgrade_value(category, "move_spread_index_addend", 0)
			end
		end

		if silencer then
			index = index + managers.player:upgrade_value("weapon", "silencer_spread_index_addend", 0)

			for _, category in ipairs(categories) do
				index = index + managers.player:upgrade_value(category, "silencer_spread_index_addend", 0)
			end
		end

		if fire_mode == "single" and table.contains_any(tweak_data.upgrades.sharpshooter_categories, categories) then
			index = index + managers.player:upgrade_value("weapon", "single_spread_index_addend", 0)
		elseif fire_mode == "auto" then
			index = index + managers.player:upgrade_value("weapon", "auto_spread_index_addend", 0)
		end

		--local spread_tweak = tweak_data.weapon.stats.spread
		--index = math.clamp(index, 1, #spread_tweak)
		--spread_index = math.clamp(spread_index, 1, #spread_tweak)

		--if index ~= spread_index then
		--	local diff = spread_tweak[index] - spread_tweak[spread_index]
		--	addend = addend + diff
		--end
	end

	return addend
end
function BlackMarketManager:calculate_weapon_visibility(weapon)
	return tweak_data.weapon.stats.concealment - self:calculate_weapon_concealment(weapon)
end
function BlackMarketManager:calculate_armor_visibility(armor)
	return tweak_data.weapon.stats.concealment - self:_calculate_armor_concealment(armor or self:equipped_armor(true))
end
function BlackMarketManager:calculate_melee_weapon_visibility(melee_weapon)
	return tweak_data.weapon.stats.concealment - self:_calculate_melee_weapon_concealment(melee_weapon or self:equipped_melee_weapon())
end
function BlackMarketManager:_get_concealment(primary, secondary, armor, melee_weapon, modifier)
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility(primary)
	local secondary_visibility = self:calculate_weapon_visibility(secondary)
	local armor_visibility = self:calculate_armor_visibility(armor)
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(melee_weapon)
	local modifier = modifier or 0
	modifier = modifier - self:team_visibility_modifiers()
	local total_visibility = math.clamp(primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier, 1, stats_tweak_data.concealment)
	total_visibility = managers.modifiers:modify_value("BlackMarketManager:GetConcealment", total_visibility)
	local total_concealment = math.clamp(stats_tweak_data.concealment - total_visibility, 1, stats_tweak_data.concealment)

	return stats_tweak_data.concealment--[total_concealment]
	, total_concealment
end
function BlackMarketManager:get_real_visibility_index_from_custom_data(data)
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility(data.primaries or "primaries")
	local secondary_visibility = self:calculate_weapon_visibility(data.secondaries or "secondaries")
	local armor_visibility = self:calculate_armor_visibility(data.armors)
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility(data.melee_weapon)
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier
	local total_concealment = stats_tweak_data.concealment - total_visibility

	return total_concealment
end
function BlackMarketManager:get_real_visibility_index_of_local_player()
	local stats_tweak_data = tweak_data.weapon.stats
	local primary_visibility = self:calculate_weapon_visibility("primaries")
	local secondary_visibility = self:calculate_weapon_visibility("secondaries")
	local armor_visibility = self:calculate_armor_visibility()
	local melee_weapon_visibility = self:calculate_melee_weapon_visibility()
	local modifier = self:visibility_modifiers()
	local total_visibility = primary_visibility + secondary_visibility + armor_visibility + melee_weapon_visibility + modifier
	local total_concealment = stats_tweak_data.concealment - total_visibility

	return total_concealment
end
function BlackMarketManager:_calculate_suspicion_offset(index, lerp)
	local con_val = tweak_data.weapon.stats.concealment--[index]
	local min_val = tweak_data.weapon.stats.concealment--[1]
	local max_val = tweak_data.weapon.stats.concealment--[#tweak_data.weapon.stats.concealment]
	local max_ratio = max_val / min_val
	local mul_ratio = math.max(1, con_val / min_val)
	local susp_lerp = math.clamp(1 - (con_val - min_val) / (max_val - min_val), 0, 1)

	return 0.99 --math.lerp(0, lerp, susp_lerp)
end
function BlackMarketManager:get_suspicion_offset_of_local(lerp, ignore_armor_kit)
	local con_mul, index = self:_get_concealment_from_local_player(ignore_armor_kit)
	local val = self:_calculate_suspicion_offset(index, lerp or 1)

	return val, index == 1, index == tweak_data.weapon.stats.concealment - 1
end
function BlackMarketManager:get_suspicion_offset_from_custom_data(data, lerp)
	local index = self:get_real_visibility_index_from_custom_data(data)
	index = math.clamp(index, 1, tweak_data.weapon.stats.concealment)
	local val = self:_calculate_suspicion_offset(index, lerp or 1)

	return val, index == 1, index == tweak_data.weapon.stats.concealment - 1
end
function BlackMarketManager:_calculate_melee_weapon_concealment(melee_weapon)
	local melee_weapon_data = tweak_data.blackmarket.melee_weapons[melee_weapon].stats

	return melee_weapon_data.concealment or tweak_data.weapon.stats.concealment
end



--[[function BlackMarketManager:get_sorted_armors(hide_locked)
	local sort_data = {}

	for id, d in pairs(Global.blackmarket_manager.armors) do
		if not hide_locked or d.unlocked then
			table.insert(sort_data, id)
		end
	end

	local armor_level_data = {}

	for level, data in pairs(tweak_data.upgrades.level_tree) do
		if data.upgrades then
			for _, upgrade in ipairs(data.upgrades) do
				log(upgrade)
				local def = tweak_data.upgrades.definitions[upgrade]

				if def and def.armor_id then
					armor_level_data[def.armor_id] = level
				end
			end
		end
	end

	table.sort(sort_data, function (x, y)
		local x_level = x == "level_1" and 0 or armor_level_data[x] or 100
		local y_level = y == "level_1" and 0 or armor_level_data[y] or 100

		return x_level < y_level
	end)

	return sort_data, armor_level_data
end]]



function BlackMarketManager:buy_and_modify_weapon(category, slot, global_value, part_id, free_of_charge, no_consume, loading)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:modify_weapon] Trying to buy and modify weapon that doesn't exist", category, slot)

		return
	end

	--managers.mission._fading_debug_output:script().log(tostring("csc"), Color.white)

	self:modify_weapon(category, slot, global_value, part_id, loading)

	if not free_of_charge then
		managers.money:on_buy_weapon_modification(self._global.crafted_items[category][slot].weapon_id, part_id, global_value)
		managers.achievment:award("would_you_like_your_receipt")
	end

	if not no_consume then
		self:remove_item(global_value, "weapon_mods", part_id)
		self:alter_global_value_item(global_value, "weapon_mods", slot, part_id, INV_REMOVE)
		self:alter_global_value_item(global_value, category, slot, part_id, CRAFT_ADD)
	end
end
function BlackMarketManager:modify_weapon(category, slot, global_value, part_id, remove_part, loading)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:modify_weapon] Trying to modify weapon that doesn't exist", category, slot)

		return
	end

	if self:is_previewing_legendary_skin() and not loading then
		managers.blackmarket:view_weapon(category, slot, nil, nil, BlackMarketGui.get_crafting_custom_data())
		managers.blackmarket:clear_preview_blueprint()
	end

	local replaces, removes = self:get_modify_weapon_consequence(category, slot, part_id, remove_part)
	local craft_data = self._global.crafted_items[category][slot]

	managers.weapon_factory:change_part_blueprint_only(craft_data.factory_id, part_id, craft_data.blueprint, remove_part)

	craft_data.global_values = craft_data.global_values or {}
	local old_gv = "" .. (craft_data.global_values[part_id] or "normal")

	if remove_part then
		craft_data.global_values[part_id] = nil
	else
		craft_data.global_values[part_id] = global_value or "normal"
	end

	local parts_tweak_data = tweak_data.blackmarket.weapon_mods
	local removed_parts = {}

	for _, part in pairs(replaces) do
		table.insert(removed_parts, part)
	end

	for _, part in pairs(removes) do
		table.insert(removed_parts, part)
	end

	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(craft_data.factory_id)
	local default_t = {}

	for _, default_part in ipairs(default_blueprint) do
		default_t[default_part] = true
	end

	local global_value = "normal"

	for _, removed_part_id in pairs(removed_parts) do
		if removed_part_id == part_id then
			global_value = old_gv or "normal"
		else
			global_value = craft_data.global_values[removed_part_id] or "normal"
			craft_data.global_values[removed_part_id] = nil
		end

		if not default_t[removed_part_id] and parts_tweak_data[removed_part_id] and (parts_tweak_data[removed_part_id].pcs or parts_tweak_data[removed_part_id].pc) then
			if not parts_tweak_data[removed_part_id].is_a_unlockable then
				local cosmetic_blueprint = craft_data.cosmetics and craft_data.cosmetics.id and tweak_data.blackmarket.weapon_skins[craft_data.cosmetics.id] and tweak_data.blackmarket.weapon_skins[craft_data.cosmetics.id].default_blueprint

				if not cosmetic_blueprint or not table.contains(cosmetic_blueprint, removed_part_id) then
					self:add_to_inventory(global_value, "weapon_mods", removed_part_id, true)
				end
			end

			self:alter_global_value_item(global_value, category, slot, removed_part_id, CRAFT_REMOVE)
		end
	end

	if not loading then
		self:_on_modified_weapon(category, slot)
	end

	--managers.mission._fading_debug_output:script().log(tostring(removes), Color.white)
	--for i, k in pairs(removed_parts) do managers.mission._fading_debug_output:script().log(tostring(i)..": "..tostring(k), Color.white) end


end



function BlackMarketManager:aquire_default_weapons(only_enable)
	local peacemaker = self._global and self._global.weapons and self._global.weapons.peacemaker
	if peacemaker and (not self._global.crafted_items.secondaries or not peacemaker.unlocked) and not managers.upgrades:aquired("peacemaker", UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			managers.upgrades:enable_weapon("peacemaker", UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons.peacemaker.unlocked = true
		else
			managers.upgrades:aquire("peacemaker", nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end

	local coach = self._global and self._global.weapons and self._global.weapons.coach
	if coach and (not self._global.crafted_items.primaries or not coach.unlocked) and not managers.upgrades:aquired("coach", UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			managers.upgrades:enable_weapon("coach", UpgradesManager.AQUIRE_STRINGS[1])

			self._global.weapons.coach.unlocked = true
		else
			managers.upgrades:aquire("coach", nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end

	local melee_weapon = self._global and self._global.melee_weapons and self._global.melee_weapons[self._defaults.melee_weapon]
	if melee_weapon and not melee_weapon.unlocked and not managers.upgrades:aquired(self._defaults.melee_weapon, UpgradesManager.AQUIRE_STRINGS[1]) then
		if only_enable then
			self._global.melee_weapons[self._defaults.melee_weapon].unlocked = true
		else
			managers.upgrades:aquire(self._defaults.melee_weapon, nil, UpgradesManager.AQUIRE_STRINGS[1])
		end
	end
end



--REMOVE THE COST OF INSTALLING A PART
function BlackMarketManager:buy_and_modify_weapon(category, slot, global_value, part_id, free_of_charge, no_consume, loading)
	if not self._global.crafted_items[category] or not self._global.crafted_items[category][slot] then
		Application:error("[BlackMarketManager:modify_weapon] Trying to buy and modify weapon that doesn't exist", category, slot)

		return
	end

	self:modify_weapon(category, slot, global_value, part_id, loading)

	if not free_of_charge then
		managers.achievment:award("would_you_like_your_receipt")
	end

	if not no_consume then
		self:remove_item(global_value, "weapon_mods", part_id)
		self:alter_global_value_item(global_value, "weapon_mods", slot, part_id, INV_REMOVE)
		self:alter_global_value_item(global_value, category, slot, part_id, CRAFT_ADD)
	end
end



function BlackMarketManager:_cleanup_blackmarket()
	print("[BlackMarketManager:_cleanup_blackmarket] STARTING BLACKMARKET CLEANUP")
	print("----------------------------------------------------------------------")

	local crafted_items = self._global.crafted_items

	for category, data in pairs(crafted_items) do
		if not data or type(data) ~= "table" then
			Application:error("BlackMarketManager:_cleanup_blackmarket() Crafted items category invalid", "category", category, "data", inspect(data))

			self._global.crafted_items[category] = {}
		end
	end

	local crafted_masks = crafted_items.masks

	local function chk_global_value_func(global_value, data, real_global_value)
		return tweak_data.lootdrop.global_values[global_value or "normal"] and true or false
	end

	local cleanup_mask = false

	for i, mask in pairs(crafted_masks) do
		local mask_data = tweak_data.blackmarket.masks[mask.mask_id]
		cleanup_mask = not mask_data or mask_data.inaccessible
		cleanup_mask = cleanup_mask or not chk_global_value_func(mask.global_value, mask, mask_data.infamous and "infamous" or mask_data.dlc or mask_data.global_value)
		local blueprint = mask.blueprint or {}

		if not cleanup_mask then
			for part_type, data in pairs(blueprint) do
				local converted_category = MASK_COLOR_CONVERT_MAP[part_type] or part_type
				local part_data = tweak_data.blackmarket[converted_category][data.id]
				cleanup_mask = not part_data
				cleanup_mask = cleanup_mask or not chk_global_value_func(data.global_value, data, part_data.infamous and "infamous" or part_data.dlc or part_data.global_value)

				if cleanup_mask then
					break
				end
			end
		end

		if cleanup_mask then
			if i == 1 then
				self._global.crafted_items.masks[i] = false

				self:on_buy_mask(self._defaults.mask, "normal", 1, nil)
			else
				Application:error("BlackMarketManager:_cleanup_blackmarket() Mask or component of mask invalid, Selling the mask!", "mask_id", mask.mask_id, "global_value", mask.global_value, "blueprint", inspect(blueprint))
				self:on_sell_mask(i, true)
			end
		end
	end

	local invalid_weapons = {}
	local invalid_parts = {}
	local invalid_cosmetics = {}

	local function invalid_add_weapon_remove_parts_func(slot, item, part_id)
		table.insert(invalid_weapons, slot)
		Application:error("BlackMarketManager:_cleanup_blackmarket() Part non-existent, weapon invalid", "weapon_id", item.weapon_id, "slot", slot)
		log("BlackMarketManager:_cleanup_blackmarket() Part non-existent, weapon invalid"..tostring(weapon_id)..tostring(slot)..tostring(part_id))

		for i = #invalid_parts, 1, -1 do
			if invalid_parts[i] and invalid_parts[i].slot == slot then
				Application:error("removing part from invalid_parts", "part_id", part_id)
				table.remove(invalid_parts, i)
			end
		end
	end

	local missing_from_default = {
		wpn_fps_smg_olympic = {
			"wpn_fps_amcar_bolt_standard"
		}
	}
	local factory = tweak_data.weapon.factory

	for _, category in ipairs({
		"primaries",
		"secondaries"
	}) do
		local crafted_category = self._global.crafted_items[category]
		invalid_weapons = {}
		invalid_parts = {}
		invalid_cosmetics = {}

		for slot, item in pairs(crafted_category) do
			local factory_id = item.factory_id
			local weapon_id = item.weapon_id
			local blueprint = item.blueprint
			local global_values = item.global_values or {}
			local texture_switches = item.texture_switches
			local cosmetics = item.cosmetics
			local index_table = {}
			local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

			if missing_from_default[factory_id] then
				for _, part in ipairs(missing_from_default[factory_id]) do
					if not table.contains(blueprint, part) then
						tag_print("BlackMarketManager:_cleanup_blackmarket()", "Weapon is missing a default part from it's blueprint", weapon_id, part)
						table.insert(blueprint, part)
					end
				end
			end

			local weapon_invalid = not Global.blackmarket_manager.weapons[weapon_id] or not tweak_data.weapon[weapon_id] or not tweak_data.weapon.factory[factory_id] or managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id) ~= factory_id or managers.weapon_factory:get_weapon_id_by_factory_id(factory_id) ~= weapon_id or not chk_global_value_func(tweak_data.weapon[weapon_id].global_value)

			if weapon_invalid then
				table.insert(invalid_weapons, slot)
			else
				item.global_values = item.global_values or {}

				for i, part_id in ipairs(factory[factory_id].uses_parts) do
					index_table[part_id] = i
				end

				for i, part_id in ipairs(blueprint) do
					if not index_table[part_id] or not chk_global_value_func(item.global_values[part_id]) then
						Application:error("BlackMarketManager:_cleanup_blackmarket() Weapon part no longer in uses parts or bad global value", "part_id", part_id, "weapon_id", item.weapon_id, "part_global_value", item.global_values[part_id])
						log("BlackMarketManager:_cleanup_blackmarket() Weapon part no longer in uses parts or bad global value "..tostring(part_id).." "..tostring(item.global_values[part_id]))

						if table.contains(default_blueprint, part_id) then
							invalid_add_weapon_remove_parts_func(slot, item, part_id)

							break
						else
							local default_mod = nil

							if tweak_data.weapon.factory.parts[part_id] then
								local ids_id = Idstring(tweak_data.weapon.factory.parts[part_id].type)

								for i, d_mod in ipairs(default_blueprint) do
									if Idstring(tweak_data.weapon.factory.parts[d_mod].type) == ids_id then
										default_mod = d_mod

										break
									end
								end

								if default_mod then
									table.insert(invalid_parts, {
										global_value = "normal",
										refund = false,
										slot = slot,
										default_mod = default_mod,
										part_id = part_id
									})
								else
									table.insert(invalid_parts, {
										refund = true,
										slot = slot,
										global_value = item.global_values[part_id] or "normal",
										part_id = part_id
									})
								end
							else
								invalid_add_weapon_remove_parts_func(slot, item, part_id)

								break
							end
						end
					end
				end

				local duplicate_parts = managers.weapon_factory:get_duplicate_parts_by_type(blueprint)

				for _, part_id in ipairs(duplicate_parts) do
					local default_mod = nil
					local ids_id = Idstring(tweak_data.weapon.factory.parts[part_id].type)

					for i, d_mod in ipairs(default_blueprint) do
						if Idstring(tweak_data.weapon.factory.parts[d_mod].type) == ids_id then
							default_mod = d_mod

							break
						end
					end

					local remove_part = true

					if remove_part then
						if default_mod then
							table.insert(invalid_parts, {
								global_value = "normal",
								refund = false,
								reason = "duplicate part (default)",
								slot = slot,
								default_mod = default_mod,
								part_id = part_id
							})
						else
							table.insert(invalid_parts, {
								refund = true,
								reason = "duplicate part",
								slot = slot,
								global_value = item.global_values[part_id] or "normal",
								part_id = part_id
							})
						end
					end
				end

				if cosmetics then
					local invalid_cosmetic = not cosmetics.id or not tweak_data.blackmarket.weapon_skins[cosmetics.id]

					if invalid_cosmetic then
						table.insert(invalid_cosmetics, slot)
					end
				else
					item.customize_locked = nil
				end
			end

			if texture_switches then
				local invalid_texture_switches = {}

				for part_id, texture_id in pairs(texture_switches) do
					if not tweak_data.weapon.factory.parts[part_id] then
						table.insert(invalid_texture_switches, part_id)
					else
						local texture = self:get_part_texture_switch(category, slot, part_id)

						if not texture or type(texture) ~= "string" or texture == "" then
							table.insert(invalid_texture_switches, part_id)
						end
					end
				end

				for _, part_id in ipairs(invalid_texture_switches) do
					texture_switches[part_id] = nil

					Application:error("BlackMarketManager:_cleanup_blackmarket() Removing invalid weapon texture switch", "category", category, "slot", slot, "part_id", part_id)
				end
			end

			local t = {}

			for part_id, gv in pairs(global_values) do
				if not table.contains(blueprint, part_id) then
					Application:error("BlackMarketManager:_cleanup_blackmarket() part exists in weapons global values but not in its blueprint. Removing it", "category", category, "slot", slot, "part_id", part_id, "global_value", gv)
					table.insert(t, part_id)
				end
			end

			for i, part_id in ipairs(t) do
				global_values[part_id] = nil
			end
		end

		for _, slot in ipairs(invalid_cosmetics) do
			Application:error("BlackMarketManager:_cleanup_blackmarket() Removing invalid Weapon skin", "slot", slot, "inspect", inspect(crafted_category[slot]))
			self:on_remove_weapon_cosmetics(category, slot, true)
		end

		for _, slot in ipairs(invalid_weapons) do
			Application:error("BlackMarketManager:_cleanup_blackmarket() Removing invalid Weapon", "slot", slot, "inspect", inspect(crafted_category[slot]))
			log("BlackMarketManager:_cleanup_blackmarket() Removing invalid Weapon")
			self:on_sell_weapon(category, slot, true)
		end

		for _, data in ipairs(invalid_parts) do
			if crafted_category[data.slot] then
				Application:error("BlackMarketManager:_cleanup_blackmarket() Removing invalid Weapon part", data.reason, "slot", data.slot, "part_id", data.part_id, "inspect", inspect(crafted_category[data.slot]), inspect(data))

				if data.default_mod then
					self:buy_and_modify_weapon(category, data.slot, data.global_value, data.default_mod, true, true, true)
				else
					self:remove_weapon_part(category, data.slot, data.global_value, data.part_id, true)
				end

				if data.refund ~= false then
					managers.money:refund_weapon_part(crafted_category[data.slot].weapon_id, data.part_id, data.global_value)
				end
			else
				Application:error("BlackMarketManager:_cleanup_blackmarket() No crafted item in slot", "category", category, "slot", data.slot)
				log("BlackMarketManager:_cleanup_blackmarket() No crafted item in slot")
			end
		end
	end

	local bm_tweak_data = tweak_data.blackmarket
	local invalid_items = {}
	local changed_items = {}

	local function add_invalid_global_value_func(global_value)
		invalid_items[global_value] = true

		Application:error("BlackMarketManager:_cleanup_blackmarket() Invalid inventory global_value detected", "global_value", global_value)
	end

	local function add_invalid_category_func(global_value, category)
		invalid_items[global_value] = invalid_items[global_value] or {}
		invalid_items[global_value][category] = true

		Application:error("BlackMarketManager:_cleanup_blackmarket() Invalid inventory category detected", "global_value", global_value, "category", category)
	end

	local function add_invalid_item_func(global_value, category, item)
		invalid_items[global_value] = invalid_items[global_value] or {}
		invalid_items[global_value][category] = invalid_items[global_value][category] or {}
		invalid_items[global_value][category][item] = true

		Application:error("BlackMarketManager:_cleanup_blackmarket() Invalid inventory item detected", "global_value", global_value, "category", category, "item", item)
	end

	if self._global.inventory.normal and self._global.inventory.normal.masks and self._global.inventory.normal.masks.arch_nemesis then
		self._global.inventory.normal.masks.arch_nemesis = nil
	end

	for global_value, categories in pairs(self._global.inventory or {}) do
		if not chk_global_value_func(global_value) then
			add_invalid_global_value_func(global_value)
		else
			for category, items in pairs(categories) do
				if not bm_tweak_data[category] then
					add_invalid_category_func(global_value, category)
				else
					for item, num in pairs(items) do
						local item_tweak_data = bm_tweak_data[category][item]

						if not item_tweak_data then
							add_invalid_item_func(global_value, category, item)
						elseif item_tweak_data.inaccessible then
							add_invalid_item_func(global_value, category, item)
						elseif category ~= "mask_colors" then
							local global_values = {}

							if item_tweak_data.infamous then
								table.insert(global_values, "infamous")
							end

							if item_tweak_data.dlc then
								table.insert(global_values, item_tweak_data.dlc)
							end

							if item_tweak_data.dlcs then
								for _, dlc in ipairs(item_tweak_data.dlcs) do
									table.insert(global_values, dlc)
								end
							end

							if item_tweak_data.global_value then
								table.insert(global_values, item_tweak_data.global_value)
							end

							if #global_values == 0 then
								table.insert(global_values, "normal")
							end

							global_values = table.list_union(global_values)

							if not table.contains(global_values, global_value) then
								add_invalid_item_func(global_value, category, item)
							else
								for _, gv in ipairs(global_values) do
									if not chk_global_value_func(gv) then
										add_invalid_item_func(global_value, category, item)

										break
									end
								end
							end
						end
					end
				end
			end
		end
	end

	for global_value, categories in pairs(invalid_items) do
		if type(categories) == "boolean" then
			self._global.inventory[global_value] = nil
			self._global.new_drops[global_value] = nil
		else
			for category, items in pairs(categories) do
				if type(items) == "boolean" then
					if not self._global.inventory[global_value] then
						Application:error("[BlackMarketManager] global_value do not exists in inventory", global_value)
					else
						self._global.inventory[global_value][category] = nil

						if self._global.new_drops[global_value] then
							self._global.new_drops[global_value][category] = nil
						end
					end
				else
					for item, invalid in pairs(items) do
						if not self._global.inventory[global_value] then
							Application:error("[BlackMarketManager] global_value do not exists in inventory", global_value)
						elseif not self._global.inventory[global_value][category] then
							Application:error("[BlackMarketManager] category do not exists in inventory", category)
						else
							self._global.inventory[global_value][category][item] = nil

							if self._global.new_drops[global_value] and self._global.new_drops[global_value][category] then
								self._global.new_drops[global_value][category][item] = nil
							end
						end
					end
				end
			end
		end
	end

	for _, item in pairs(changed_items) do
		self._global.inventory[item.global_value] = self._global.inventory[item.global_value] or {}
		self._global.inventory[item.global_value][item.category] = self._global.inventory[item.global_value][item.category] or {}
		self._global.inventory[item.global_value][item.category][item.id] = (self._global.inventory[item.global_value][item.category][item.id] or 0) + 1

		Application:error("[BlackMarketManager] Inventory item changed global value: ", item.category, item.id, item.global_value)
	end

	if self._global.inventory_tradable then
		local invalid_tradable_items = {}

		for instance_id, data in pairs(self._global.inventory_tradable) do
			if not data.category or not data.entry or not data.amount then
				table.insert(invalid_tradable_items, instance_id)
			end
		end

		for _, instance_id in ipairs(invalid_tradable_items) do
			self._global.inventory_tradable[instance_id] = nil
		end
	end

	print("----------------------------------------------------------------------")
	print("[BlackMarketManager:_cleanup_blackmarket] BLACKMARKET CLEANUP DONE")
end
