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
	pattern = "textures",
	color_c = "materials",
	color_a = "materials",
	color_b = "materials",
	material = "materials"
}
local DEFAULT_CUSTOMIZE_MASK_BLUEPRINT = {
	materials = {
		id = "plastic",
		global_value = "normal"
	},
	textures = {
		id = "no_color_full_material",
		global_value = "normal"
	},
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
	color_c = {
		id = "strip_paint",
		global_value = "normal"
	}
}



function BlackMarketManager:_setup()
	if not BeardLib then error(managers.localization:text("CRASH_NO_BEARDLIB")) end

	self._defaults = {
		mask = "character_locked",
		character = "locked",
		armor = "level_1",
		armor_skins = {},
		armor_skin = "none",
		player_style = "none",
		glove_id = "default",
		preferred_character = "russian",
		grenade = "frag",
		--melee_weapon = "weapon"
	}

	if _G.IS_VR then
		--self._defaults.melee_weapon = "fists"
	end

	self._defaults.henchman = {
		mask = "character_locked"
	}

	if not Global.blackmarket_manager then
		Global.blackmarket_manager = {}

		self:_setup_armors()
		self:_setup_weapons()
		self:_setup_characters()
		self:_setup_track_global_values()
		self:_setup_unlocked_mask_slots()
		self:_setup_unlocked_weapon_slots()
		self:_setup_grenades()
		self:_setup_melee_weapons()
		self:_setup_armor_skins()
		self:_setup_player_styles()
		self:_setup_gloves()

		Global.blackmarket_manager.inventory = {}
		Global.blackmarket_manager.crafted_items = {}
		Global.blackmarket_manager.new_drops = {}
		Global.blackmarket_manager.new_item_type_unlocked = {}
		Global.blackmarket_manager.new_tradable_items = {}
		Global.blackmarket_manager.tradable_items_received = {}
		Global.blackmarket_manager.inventory_tradable = {}
		Global.blackmarket_manager.tradable_inventory_sort = 1
		Global.blackmarket_manager.tradable_dlcs = {}
	end

	self._global = Global.blackmarket_manager
	self._preloading_list = {}
	self._preloading_index = 0
	self._category_resource_loaded = {}
	self._skin_editor = SkinEditor:new()
	self._armor_skin_editor = ArmorSkinEditor:new()
	self._event_listener_holder = EventListenerHolder:new()
end
function BlackMarketManager:_setup_melee_weapons()
	local melee_weapons = {}
	Global.blackmarket_manager.melee_weapons = melee_weapons

	local lookup = {
		weapon = true,
		fists = true,
		fight = true,
	}

	for melee_weapon, _ in pairs(tweak_data.blackmarket.melee_weapons) do
		melee_weapons[melee_weapon] = {
			unlocked = false,
			owned = false,
			durability = 1,
			equipped = false,
			equippedx2 = false,
			skill_based = false,
			level = 0
		}
		local is_default, weapon_level = managers.upgrades:get_value(melee_weapon, self._defaults.melee_weapon)
		melee_weapons[melee_weapon].level = weapon_level
		melee_weapons[melee_weapon].skill_based = not is_default and weapon_level == 0 and not tweak_data.blackmarket.melee_weapons[melee_weapon].dlc

		if _G.IS_VR then
			melee_weapons[melee_weapon].vr_locked = tweak_data.vr:is_locked("melee_weapons", melee_weapon)
		end
	end

	--melee_weapons[self._defaults.melee_weapon].equipped = true
	--melee_weapons[self._defaults.melee_weapon].owned = true
	--melee_weapons[self._defaults.melee_weapon].level = 0
end
function BlackMarketManager:get_sorted_melee_weapons(hide_locked, id_list_only)
	local items = {}
	local global_value, td, category = nil

	local lookup = {
		weapon = true,
		fists = true,
		fight = true,
	}
	for id, item in pairs(Global.blackmarket_manager.melee_weapons) do
		td = tweak_data.blackmarket.melee_weapons[id]
		global_value = td.dlc or td.global_value or "normal"
		category = td.type or "unknown"
		local add_item = item.unlocked or item.equipped or not hide_locked and not managers.dlc:should_hide_unavailable(global_value, true)

		if add_item and not lookup[id] and td.pcs~=false then
			table.insert(items, {
				id,
				item
			})
		end
	end

	local xd, yd, x_td, y_td, x_sn, y_sn, x_gv, y_gv = nil
	local m_tweak_data = tweak_data.blackmarket.melee_weapons
	local l_tweak_data = tweak_data.lootdrop.global_values
	local locked_sort_numbers = {}
	for _, item in ipairs(items) do
		local id = item[1]
		local data = item[2]
		local dlc = m_tweak_data[id] and m_tweak_data[id].dlc or managers.dlc:global_value_to_dlc(m_tweak_data[id].global_value)
		local func = data.func_based or false
		local skill = data.skill_based or false
		locked_sort_numbers[id] = tweak_data.gui:get_locked_sort_number(dlc, func, skill)
	end

	local nqr_sort_numbers = {}
	for i, k in pairs(tweak_data.upgrades.level_tree) do
		for id, upgrade in ipairs(k.upgrades) do
			if Global.blackmarket_manager.melee_weapons[upgrade] then
				local new_id = #nqr_sort_numbers + 1
				nqr_sort_numbers[new_id] = upgrade
				nqr_sort_numbers[upgrade] = new_id
			end
		end
	end
	--Utils.PrintTable(nqr_sort_numbers)

	local function sort_func(x, y)
		xd = x[2]
		yd = y[2]
		x_td = m_tweak_data[x[1]]
		y_td = m_tweak_data[y[1]]

		if _G.IS_VR and xd.vr_locked ~= yd.vr_locked then
			return not xd.vr_locked
		end

		if xd.unlocked ~= yd.unlocked then
			return xd.unlocked
		end

		if not xd.unlocked then
			x_sn = locked_sort_numbers[x[1]]
			y_sn = locked_sort_numbers[y[1]]

			if x_sn ~= y_sn then
				return x_sn < y_sn
			end
		end

		if xd.level ~= yd.level then
			return xd.level < yd.level
		end

		if nqr_sort_numbers[x[1]] ~= nqr_sort_numbers[y[1]] then
			return nqr_sort_numbers[x[1]] < nqr_sort_numbers[y[1]]
		end

		if x_td.instant ~= y_td.instant then
			return x_td.instant
		end

		if xd.skill_based ~= yd.skill_based then
			return xd.skill_based
		end

		if x_td.free ~= y_td.free then
			return x_td.free
		end

		x_gv = x_td.global_value or x_td.dlc or "normal"
		y_gv = y_td.global_value or y_td.dlc or "normal"
		x_sn = l_tweak_data[x_gv]
		y_sn = l_tweak_data[y_gv]
		x_sn = x_sn and x_sn.sort_number or 1
		y_sn = y_sn and y_sn.sort_number or 1

		if x_sn ~= y_sn then
			return x_sn < y_sn
		end

		if xd.level ~= yd.level then
			return xd.level < yd.level
		end

		return x[1] < y[1]
	end

	table.sort(items, sort_func)

	if id_list_only then
		local id_list = {}

		for _, data in ipairs(items) do
			table.insert(id_list, data[1])
		end

		return id_list
	end

	local override_slots = {
		4,
		4
	}
	local num_slots_per_category = override_slots[1] * override_slots[2]
	local sorted_categories = {}
	local item_categories = {}
	local category = nil

	for index, item in ipairs(items) do
		category = math.max(1, math.ceil(index / num_slots_per_category))
		item_categories[category] = item_categories[category] or {}

		table.insert(item_categories[category], item)
	end

	for i = 1, #item_categories do
		table.insert(sorted_categories, i)
	end

	return sorted_categories, item_categories, override_slots
end

function BlackMarketManager:load(data)
	if data.blackmarket then
		local default_global = self._global or {}
		Global.blackmarket_manager = data.blackmarket
		self._global = Global.blackmarket_manager

		if not self._global._has_separated_mask_colors then
			self:_separate_mask_colors()
		end

		self._global._has_separated_mask_colors = true

		if self._global.equipped_armor and type(self._global.equipped_armor) ~= "string" then
			self._global.equipped_armor = nil
		end

		self._global.armors = default_global.armors or {}

		for armor, _ in pairs(tweak_data.blackmarket.armors) do
			if not self._global.armors[armor] then
				self._global.armors[armor] = {
					owned = false,
					unlocked = false,
					equipped = false
				}
			else
				self._global.armors[armor].equipped = false
			end
		end

		if not self._global.equipped_armor or not self._global.armors[self._global.equipped_armor] then
			self._global.equipped_armor = self._defaults.armor
		end

		self._global.armors[self._global.equipped_armor].equipped = true
		self._global.equipped_armor = nil
		self._global.grenades = default_global.grenades or {}

		if self._global.grenades[self._defaults.grenade] then
			self._global.grenades[self._defaults.grenade].equipped = false
		end

		if self._global.grenades[self._global.equipped_grenade] then
			self._global.grenades[self._global.equipped_grenade].equipped = true
		else
			self._global.grenades[self._defaults.grenade].equipped = true
		end

		for grenade, data in pairs(self._global.grenades) do
			self._global.grenades[grenade].skill_based = false
			self._global.grenades[grenade].skill_based = self._global.grenades[grenade].ability and true or false
		end

		self._global.equipped_grenade = nil
		self._global.melee_weapons = default_global.melee_weapons or {}

		if self._global.melee_weapons[self._defaults.melee_weapon] then
			self._global.melee_weapons[self._defaults.melee_weapon].equipped = false
		end

		if self._global.melee_weapons[self._global.equipped_melee_weapon] then
			self._global.melee_weapons[self._global.equipped_melee_weapon].equipped = true
		else
			--self._global.melee_weapons[self._defaults.melee_weapon].equipped = true
		end
		if self._global.melee_weapons[self._global.equipped_melee_weaponx2] then
			self._global.melee_weapons[self._global.equipped_melee_weaponx2].equippedx2 = true
		end

		for melee_weapon, data in pairs(self._global.melee_weapons) do
			local is_default, melee_weapon_level = managers.upgrades:get_value(melee_weapon)
			self._global.melee_weapons[melee_weapon].level = melee_weapon_level
			self._global.melee_weapons[melee_weapon].skill_based = not is_default and melee_weapon_level == 0 and not tweak_data.blackmarket.melee_weapons[melee_weapon].dlc and not tweak_data.blackmarket.melee_weapons[melee_weapon].free
		end

		self._global.equipped_melee_weapon = nil
		self._global.equipped_melee_weaponx2 = nil
		self._global.weapons = default_global.weapons or {}

		for weapon, data in pairs(tweak_data.weapon) do
			if not self._global.weapons[weapon] and data.autohit ~= nil then
				local selection_index = data.use_data.selection_index
				local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon)
				self._global.weapons[weapon] = {
					owned = false,
					equipped = false,
					unlocked = false,
					factory_id = factory_id,
					selection_index = selection_index
				}
			end
		end

		for weapon, data in pairs(self._global.weapons) do
			local is_default, weapon_level, got_parent = managers.upgrades:get_value(weapon)
			self._global.weapons[weapon].level = weapon_level
			self._global.weapons[weapon].skill_based = got_parent or not is_default and weapon_level == 0 and not tweak_data.weapon[weapon].global_value
			self._global.weapons[weapon].func_based = tweak_data.weapon[weapon].unlock_func
		end

		self._global._preferred_character = self._global._preferred_character or self._defaults.preferred_character
		local character_name = CriminalsManager.convert_old_to_new_character_workname(self._global._preferred_character)

		if not tweak_data.blackmarket.characters.locked[character_name] and not tweak_data.blackmarket.characters[character_name] then
			self._global._preferred_character = self._defaults.preferred_character
		end

		self._global._preferred_characters = self._global._preferred_characters or {
			self._global._preferred_character
		}

		for i, character in pairs(clone(self._global._preferred_characters)) do
			local character_name = CriminalsManager.convert_old_to_new_character_workname(character)

			if not tweak_data.blackmarket.characters.locked[character_name] and not tweak_data.blackmarket.characters[character_name] then
				self._global._preferred_characters[i] = self._defaults.preferred_character
			end
		end

		for character, _ in pairs(tweak_data.blackmarket.characters) do
			if not self._global.characters[character] then
				self._global.characters[character] = {
					owned = true,
					unlocked = true,
					equipped = false
				}
			end
		end

		for character, _ in pairs(clone(self._global.characters)) do
			if not tweak_data.blackmarket.characters[character] then
				self._global.characters[character] = nil
			end
		end

		if not self:equipped_character() then
			self._global.characters[self._defaults.character].equipped = true
		end

		self._global.equipped_van_skin = self._global.equipped_van_skin or tweak_data.van.default_skin_id
		self._global.inventory = self._global.inventory or {}
		self._global.inventory.normal = self._global.inventory.normal or {}
		self._global.new_tradable_items = self._global.new_tradable_items or {}
		self._global.inventory_tradable = self._global.inventory_tradable or {}
		self._global.tradable_items_received = self._global.tradable_items_received or {}
		self._global.tradable_inventory_sort = self._global.tradable_inventory_sort or 1
		self._global.tradable_dlcs = self._global.tradable_dlcs or {}
		self._global.armor_skins = self._global.armor_skins or default_global.armor_skins or {}
		self._global.equipped_armor_skin = self._global.equipped_armor_skin or self._defaults.armor_skin

		self:_setup_armor_skins()
		self:_remove_unowned_armor_skin(true)

		self._global.player_styles = self._global.player_styles or default_global.player_styles or {}
		self._global.equipped_player_style = self._global.equipped_player_style or self:get_default_player_style()

		self:_setup_player_styles()

		self._global.gloves = self._global.gloves or default_global.gloves or {}
		self._global.equipped_glove_id = self._global.equipped_glove_id or self:get_default_glove_id()

		self:_setup_gloves()

		self._global.crafted_items = self._global.crafted_items or {}

		if not self._global.unlocked_mask_slots then
			self:_setup_unlocked_mask_slots()
		end

		if not self._global.unlocked_weapon_slots then
			self:_setup_unlocked_weapon_slots()
		end

		if self._global.inventory.infamous and self._global.inventory.infamous.weapon_mods then
			for id, amount in pairs(self._global.inventory.infamous.weapon_mods) do
				self._global.inventory.normal = self._global.inventory.normal or {}
				self._global.inventory.normal.weapon_mods = self._global.inventory.normal.weapon_mods or {}
				self._global.inventory.normal.weapon_mods[id] = (self._global.inventory.normal.weapon_mods[id] or 0) + amount
			end

			self._global.inventory.infamous.weapon_mods = nil
		end

		for _, category in ipairs({
			"primaries",
			"secondaries"
		}) do
			if self._global.crafted_items[category] then
				for slot, crafted in pairs(self._global.crafted_items[category]) do
					if crafted.global_values then
						for id, global_value in pairs(crafted.global_values) do
							if global_value == "infamous" then
								crafted.global_values[id] = "normal"
							end
						end
					end
				end
			end
		end

		self._global.new_drops = self._global.new_drops or {}
		self._global.new_item_type_unlocked = self._global.new_item_type_unlocked or {}

		print("self._global.new_drops ", inspect(self._global.new_drops))
		print("self._global.new_item_type_unlocked ", inspect(self._global.new_item_type_unlocked))

		local old_drops = {}

		for global_value, categories in pairs(self._global.new_drops) do
			for category, ids in pairs(categories) do
				for id in pairs(ids) do
					if id and tweak_data.blackmarket[category] and not tweak_data.blackmarket[category][id] then
						Application:error("[BlackMarketManager:load] New drop no longer exists!", "global_value", global_value, "category", category, "id", id)

						self._global.new_drops[global_value][category][id] = false
						old_drops[global_value] = old_drops[global_value] or {}
						old_drops[global_value][category] = old_drops[global_value][category] or {}
						old_drops[global_value][category][id] = true
					elseif category == "primaries" or category == "secondaries" then
						local weapon_id = id or managers.weapon_factory:get_weapon_id_by_factory_id(id)
						local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(id) or id

						if not factory_id or not tweak_data.weapon.factory[factory_id] or not weapon_id or not tweak_data.weapon[weapon_id] then
							Application:error("[BlackMarketManager:load] New drop weapon no longer exists!", "global_value", global_value, "category", category, "weapon_id", weapon_id, "factory_id", factory_id)

							self._global.new_drops[global_value][category][id] = false
							old_drops[global_value] = old_drops[global_value] or {}
							old_drops[global_value][category] = old_drops[global_value][category] or {}
							old_drops[global_value][category][id] = true
						end
					end
				end
			end
		end

		for global_value, categories in pairs(old_drops) do
			for category, ids in pairs(categories) do
				for id in pairs(ids) do
					if self._global.new_drops[global_value] then
						if self._global.new_drops[global_value][category] then
							self._global.new_drops[global_value][category][id] = nil

							if table.size(self._global.new_drops[global_value][category]) == 0 then
								self._global.new_drops[global_value][category] = nil
							end
						end

						if table.size(self._global.new_drops[global_value]) == 0 then
							self._global.new_drops[global_value] = nil
						end
					end
				end
			end
		end

		for category, id in pairs(self._global.new_item_type_unlocked) do
			if category == "announcements" then
				if type(id) ~= "table" then
					Application:error("[BlackMarketManager:load] 'New item type unlocked' announcements was not a table", "announcements", id)

					self._global.new_item_type_unlocked[category] = {}
				end
			elseif id and tweak_data.blackmarket[category] and not tweak_data.blackmarket[category][id] then
				debug_pause("[BlackMarketManager:load] 'New item type unlocked' no longer exists!", "category", category, "id", id)

				self._global.new_item_type_unlocked[category] = false
			elseif category == "primaries" or category == "secondaries" then
				local test_factory_id = id

				if test_factory_id ~= false and test_factory_id ~= true and not managers.weapon_factory:get_weapon_id_by_factory_id(test_factory_id) then
					local fixed = nil

					for weapon_id, weapon_data in pairs(self._global.weapons) do
						if test_factory_id == managers.weapon_factory:get_weapon_name_by_factory_id(weapon_data.factory_id) then
							self._global.new_item_type_unlocked[category] = weapon_data.factory_id
							fixed = true

							Application:debug("[BlackMarketManager:load] Found weapon from string for 'new item type unlocked'", "test_name", test_factory_id, "weapon_id", weapon_id, "category", category)

							break
						end
					end

					if not fixed then
						debug_pause("[BlackMarketManager:load] Unknown weapon in 'new item type unlocked'", self._global.new_item_type_unlocked[category], "category", category)

						self._global.new_item_type_unlocked[category] = false
					end
				end
			end
		end

		if not self._unlocked_crew_items then
			self:_setup_unlocked_crew_items()
		end

		self._refill_global_values = self:_setup_track_global_values() or nil

		if not self._global._has_given_infamy_clrs then
			self:_give_infamy_colors()
		end

		self._global._has_given_infamy_clrs = true
	end
end
function BlackMarketManager:save(data)
	local save_data = deep_clone(self._global)
	save_data.equipped_armor = self:equipped_armor()
	save_data.equipped_grenade = self:equipped_grenade()
	save_data.equipped_melee_weapon = self:equipped_melee_weapon()
	save_data.equipped_melee_weaponx2 = self:equipped_melee_weaponx2()
	save_data.equipped_van_skin = self:equipped_van_skin()
	save_data.equipped_armor_skin = self:equipped_armor_skin()
	save_data.equipped_player_style = self:equipped_player_style()
	save_data.equipped_glove_id = self:equipped_glove_id()
	save_data.armors = nil
	save_data.grenades = nil
	save_data.melee_weapons = nil
	save_data.masks = nil
	save_data.weapon_upgrades = nil
	save_data.weapons = nil
	data.blackmarket = save_data
end

function BlackMarketManager:_verfify_equipped_category(category)
	if category == "armors" then
		local armor_id = self._defaults.armor

		for armor, craft in pairs(Global.blackmarket_manager.armors) do
			if craft.equipped and craft.unlocked and craft.owned then
				armor_id = armor
			end
		end

		for s, data in pairs(Global.blackmarket_manager.armors) do
			data.equipped = s == armor_id
		end

		if managers.menu_scene then
			managers.menu_scene:set_character_armor(armor_id)
		end

		return
	end

	if category == "grenades" then
		local grenade_id = self._defaults.grenade

		for grenade, craft in pairs(Global.blackmarket_manager.grenades) do
			if craft.equipped and craft.unlocked then
				grenade_id = grenade
			end

			local grenade_data = tweak_data.blackmarket.projectiles[grenade] or {}
			craft.amount = (not grenade_data.dlc or managers.dlc:is_dlc_unlocked(grenade_data.dlc)) and managers.player:get_max_grenades(grenade) or 0
		end

		for s, data in pairs(Global.blackmarket_manager.grenades) do
			data.equipped = s == grenade_id
		end

		return
	end

	if category == "melee_weapons" then
		local melee_weapon_id = self._defaults.melee_weapon
		local melee_weapon_idx2 = nil

		for melee_weapon, craft in pairs(Global.blackmarket_manager.melee_weapons) do
			local melee_weapon_data = tweak_data.blackmarket.melee_weapons[melee_weapon] or {}

			if craft.equipped and craft.unlocked and (not melee_weapon_data.dlc or managers.dlc:is_dlc_unlocked(melee_weapon_data.dlc)) and (not _G.IS_VR or not craft.vr_locked) then
				melee_weapon_id = melee_weapon
			end
			if craft.equippedx2 and craft.unlocked and (not melee_weapon_data.dlc or managers.dlc:is_dlc_unlocked(melee_weapon_data.dlc)) and (not _G.IS_VR or not craft.vr_locked) then
				melee_weapon_idx2 = melee_weapon
			end
		end

		for s, data in pairs(Global.blackmarket_manager.melee_weapons) do
			data.equipped = s == melee_weapon_id
			data.equippedx2 = s == melee_weapon_idx2
		end

		return
	end

	if not self._global.crafted_items[category] then
		return
	end

	local is_weapon = category == "secondaries" or category == "primaries"

	if not is_weapon then
		for slot, craft in pairs(self._global.crafted_items[category]) do
			if craft.equipped then
				return
			end
		end

		local slot, craft = next(self._global.crafted_items[category])

		print("  Equip", category, slot)

		craft.equipped = true

		return
	end

	local weap_factory_manager = managers.weapon_factory
	local weap_verify_f = weap_factory_manager.verify_weapon
	local on_sell_weap_f = self.on_sell_weapon
	local cur_equip_data = nil

	for slot, craft in pairs(self._global.crafted_items[category]) do
		if not weap_verify_f(weap_factory_manager, craft.weapon_id, craft.factory_id) then
			on_sell_weap_f(self, category, slot, not craft.equipped)
		end
	end

	for slot, craft in pairs(self._global.crafted_items[category]) do
		if craft.equipped then
			if self:weapon_unlocked_by_crafted(category, slot) then
				return
			else
				craft.equipped = false
			end
		end
	end

	for slot, craft in pairs(self._global.crafted_items[category]) do
		if self:weapon_unlocked_by_crafted(category, slot) then
			print("  Equip", category, slot)

			craft.equipped = true

			self:clean_weapon_equipped_cache()

			return
		end
	end

	local free_slot = self:_get_free_weapon_slot(category) or 1

	self:on_sell_weapon(category, free_slot)

	local weapon_id = category == "primaries" and "amcar" or "glock_17"
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local blueprint = deep_clone(managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
	self._global.crafted_items[category][free_slot] = {
		equipped = true,
		weapon_id = weapon_id,
		factory_id = factory_id,
		blueprint = blueprint
	}

	managers.money:on_buy_weapon_platform(weapon_id, true)
end

function BlackMarketManager:equipped_melee_weapon_damage_info(lerp_value, custom_melee)
	lerp_value = lerp_value or 0
	local melee_entry = custom_melee or self:equipped_melee_weapon()
	local stats = tweak_data.blackmarket.melee_weapons[melee_entry].stats
	local primary = self:equipped_primary()
	local bayonet_id = self:equipped_bayonet(primary.weapon_id)
	local player = managers.player:player_unit()

	if bayonet_id and player:movement():current_state()._equipped_unit:base():selection_index() == 2 and melee_entry == "weapon" then
		stats = tweak_data.weapon.factory.parts[bayonet_id].stats
	end

	local dmg = math.lerp(stats.min_damage, stats.max_damage, lerp_value)
	local dmg_effect = dmg * math.lerp(stats.min_damage_effect, stats.max_damage_effect, lerp_value)

	return dmg, dmg_effect
end

function BlackMarketManager:player_loadout_data(show_all_icons)
	local primary_texture = "guis/textures/pd2/endscreen/what_is_this"
	local primary_bg_texture = "guis/textures/pd2/endscreen/what_is_this"
	local secondary_texture = "guis/textures/pd2/endscreen/what_is_this"
	local secondary_bg_texture = "guis/textures/pd2/endscreen/what_is_this"
	local melee_weapon_texture = "guis/textures/pd2/endscreen/what_is_this"
	local grenade_texture = "guis/textures/pd2/endscreen/what_is_this"
	local armor_texture = "guis/textures/pd2/endscreen/what_is_this"
	local deployable_texture = "guis/textures/pd2/endscreen/what_is_this"
	local mask_texture = "guis/textures/pd2/endscreen/what_is_this"
	local character_texture = "guis/textures/pd2/endscreen/what_is_this"
	local secondary_deployable_texture = "guis/textures/pd2/endscreen/what_is_this"
	local empty_string = managers.localization:to_upper_text("menu_loadout_empty")
	local primary_string = empty_string
	local secondary_string = empty_string
	local melee_weapon_string = empty_string
	local grenade_string = empty_string
	local armor_string = empty_string
	local deployable_string = empty_string
	local mask_string = empty_string
	local character_string = empty_string
	local secondary_deployable_string = empty_string
	local primary_color, secondary_color = nil
	local primary_perks = {}
	local secondary_perks = {}
	local primary_akimbo, secondary_akimbo = nil
	local primary = self:equipped_primary()
	local secondary = self:equipped_secondary()
	local melee_weapon = self:equipped_melee_weapon()
	local melee_weaponx2 = self:equipped_melee_weaponx2()
	local grenade, grenade_amount = self:equipped_grenade()
	local armor = self:equipped_armor()
	local deployable = self:equipped_deployable()
	local mask = self:equipped_mask()
	local character = self:get_preferred_character()
	local secondary_deployable = self:equipped_deployable(2)
	local player_style_texture = "guis/textures/pd2/endscreen/what_is_this"
	local player_style_string = empty_string
	local player_style = self:equipped_player_style()
	local glove_texture = "guis/textures/pd2/endscreen/what_is_this"
	local glove_string = empty_string
	local glove_id = self:equipped_glove_id()

	if primary then
		primary_akimbo = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].akimbo_gui_data
		primary_texture, primary_bg_texture = managers.blackmarket:get_weapon_icon_path(primary.weapon_id, primary.cosmetics)
		local equipped_weapon = self:equipped_primary()
		local equipped_slot = self:equipped_weapon_slot("primaries")
		primary_string = self:get_weapon_name_by_category_slot("primaries", equipped_slot)
		primary_color = equipped_weapon.locked_name and equipped_weapon.cosmetics and tweak_data.economy.rarities[tweak_data.blackmarket.weapon_skins[equipped_weapon.cosmetics.id].rarity or "common"].color

		if equipped_weapon and equipped_slot then
			local icon_list = {}

			for i, icon in ipairs(managers.menu_component:create_weapon_mod_icon_list(equipped_weapon.weapon_id, "primaries", equipped_weapon.factory_id, equipped_slot)) do
				if show_all_icons or icon.equipped then
					table.insert(icon_list, icon)
				end
			end

			primary_perks = icon_list
		end
	end

	if secondary then
		secondary_akimbo = tweak_data.weapon[secondary.weapon_id] and tweak_data.weapon[secondary.weapon_id].akimbo_gui_data
		secondary_texture, secondary_bg_texture = managers.blackmarket:get_weapon_icon_path(secondary.weapon_id, secondary.cosmetics)
		local equipped_weapon = self:equipped_secondary()
		local equipped_slot = self:equipped_weapon_slot("secondaries")
		secondary_string = self:get_weapon_name_by_category_slot("secondaries", equipped_slot)
		secondary_color = equipped_weapon.locked_name and equipped_weapon.cosmetics and tweak_data.economy.rarities[tweak_data.blackmarket.weapon_skins[equipped_weapon.cosmetics.id].rarity or "common"].color

		if equipped_weapon and equipped_slot then
			local icon_list = {}

			for i, icon in ipairs(managers.menu_component:create_weapon_mod_icon_list(equipped_weapon.weapon_id, "secondaries", equipped_weapon.factory_id, equipped_slot)) do
				if show_all_icons or icon.equipped then
					table.insert(icon_list, icon)
				end
			end

			secondary_perks = icon_list
		end
	end

	if melee_weapon then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.melee_weapons[melee_weapon] and tweak_data.blackmarket.melee_weapons[melee_weapon].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		melee_weapon_texture = guis_catalog .. "textures/pd2/blackmarket/icons/melee_weapons/" .. tostring(melee_weapon)
		melee_weapon_string = managers.localization:text(tweak_data.blackmarket.melee_weapons[melee_weapon].name_id)..(melee_weaponx2 and " x2" or "")
	else
		melee_weapon_texture = "guis/textures/pd2/add_icon"
	end

	if grenade and grenade_amount > 0 then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.projectiles[grenade] and tweak_data.blackmarket.projectiles[grenade].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		grenade_texture = guis_catalog .. "textures/pd2/blackmarket/icons/grenades/" .. tostring(grenade)
		grenade_string = managers.localization:text(tweak_data.blackmarket.projectiles[grenade].name_id)
	else
		grenade_texture = "guis/textures/pd2/add_icon"
	end

	if armor then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.armors[armor].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		armor_texture = guis_catalog .. "textures/pd2/blackmarket/icons/armors/" .. tostring(armor)
		armor_string = managers.localization:text(tweak_data.blackmarket.armors[armor].name_id)
	end

	if player_style then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.player_styles[player_style].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		player_style_texture = guis_catalog .. "textures/pd2/blackmarket/icons/player_styles/" .. tostring(player_style)
		player_style_string = managers.localization:text(tweak_data.blackmarket.player_styles[player_style].name_id)
	end

	if glove_id then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.gloves[glove_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		glove_texture = guis_catalog .. "textures/pd2/blackmarket/icons/gloves/" .. tostring(glove_id)
		glove_string = managers.localization:text(tweak_data.blackmarket.gloves[glove_id].name_id)
	end

	if deployable then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.deployables[deployable] and tweak_data.blackmarket.deployables[deployable].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		deployable_texture = guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. tostring(deployable)
		deployable_string = managers.localization:text(tweak_data.upgrades.definitions[deployable].name_id)
	else
		deployable_texture = "guis/textures/pd2/add_icon"
	end

	if mask then
		mask_texture = self:get_mask_icon(mask.mask_id)
		local equipped_slot = self:equipped_weapon_slot("masks")
		mask_string = self:get_mask_name_by_category_slot("masks", equipped_slot)
	end

	if character then
		character_texture = self:get_character_icon(character)
		character_string = managers.localization:text("menu_" .. character)
	end

	if secondary_deployable then
		local guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.deployables[secondary_deployable] and tweak_data.blackmarket.deployables[secondary_deployable].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		secondary_deployable_texture = guis_catalog .. "textures/pd2/blackmarket/icons/deployables/" .. tostring(secondary_deployable)
		secondary_deployable_string = managers.localization:text(tweak_data.upgrades.definitions[secondary_deployable].name_id)
	end

	local primary = {
		item_texture = primary_texture or false,
		item_bg_texture = primary_bg_texture,
		info_text = primary_string,
		info_icons = primary_perks,
		info_text_color = primary_color,
		akimbo_gui_data = primary_akimbo
	}
	local secondary = {
		item_texture = secondary_texture or false,
		item_bg_texture = secondary_bg_texture,
		info_text = secondary_string,
		info_icons = secondary_perks,
		info_text_color = secondary_color,
		akimbo_gui_data = secondary_akimbo
	}
	local melee_weapon = {
		item_texture = melee_weapon_texture or false,
		info_text = melee_weapon_string,
		dual_texture_1 = primary_texture or false,
		dual_texture_2 = secondary_texture or false
	}
	local grenade = {
		item_texture = grenade_texture or false,
		info_text = grenade_string
	}
	local armor = {
		item_texture = armor_texture or false,
		info_text = armor_string
	}
	local deployable = {
		item_texture = deployable_texture or false,
		info_text = deployable_string
	}
	local mask = {
		item_texture = mask_texture or false,
		info_text = mask_string
	}
	local character = {
		item_texture = character_texture or false,
		info_text = character_string
	}
	local outfit = {
		armor = armor
	}

	if player_style ~= self:get_default_player_style() then
		outfit.player_style = {
			item_texture = player_style_texture or false,
			info_text = player_style_string
		}
	end

	if glove_id ~= self:get_default_glove_id() then
		outfit.glove_id = {
			item_texture = glove_texture or false,
			info_text = glove_string
		}
	end

	if secondary_deployable then
		local secondary_deployable = {
			item_texture = secondary_deployable_texture or false,
			info_text = secondary_deployable_string
		}
		deployable.secondary = secondary_deployable
	elseif managers.player:has_category_upgrade("player", "second_deployable") then
		local secondary_deployable = {
			item_texture = "guis/textures/pd2/add_icon",
			info_text = secondary_deployable_string
		}
		deployable.secondary = secondary_deployable
	end

	local data = {
		primary = primary,
		secondary = secondary,
		melee_weapon = melee_weapon,
		grenade = grenade,
		armor = armor,
		deployable = deployable,
		mask = mask,
		character = character,
		outfit = outfit
	}

	return data
end

function BlackMarketManager:equip_melee_weapon(melee_weapon_id)
	for s, data in pairs(Global.blackmarket_manager.melee_weapons) do
		data.equipped = s == melee_weapon_id
		data.equippedx2 = nil
	end

	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_equipped_to_steam()
	end
end
function BlackMarketManager:equip_melee_weaponx2(melee_weapon_id)
	for s, data in pairs(Global.blackmarket_manager.melee_weapons) do
		data.equipped = s == melee_weapon_id
		data.equippedx2 = tweak_data.blackmarket.melee_weapons[melee_weapon_id] and not tweak_data.blackmarket.melee_weapons[melee_weapon_id].large and s == melee_weapon_id or nil
	end

	MenuCallbackHandler:_update_outfit_information()

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_equipped_to_steam()
	end
end
function BlackMarketManager:equipped_melee_weaponx2()
	local melee_weapon = nil

	for melee_weapon_id, data in pairs(tweak_data.blackmarket.melee_weapons) do
		melee_weapon = Global.blackmarket_manager.melee_weapons[melee_weapon_id]

		if melee_weapon.equipped and melee_weapon.equippedx2 and melee_weapon.unlocked then
			return melee_weapon_id
		end
	end

	self:aquire_default_weapons()

	return self._defaults.melee_weapon
end
function BlackMarketManager:equip_next_melee_weapon()
	local melee_weapons = self:get_sorted_melee_weapons(true, true) or {}
	local equipped_melee_weapon = self:equipped_melee_weapon()
	local equipped_index = table.get_vector_index(melee_weapons, equipped_melee_weapon) or 0

	local next_index = (equipped_index + 1) % (#melee_weapons + 1)
	local next_melee_weapon = melee_weapons[next_index]

	if self:equipped_melee_weaponx2() then
		self:equip_melee_weaponx2(next_melee_weapon)
	else
		self:equip_melee_weapon(next_melee_weapon)
	end

	return true
end
function BlackMarketManager:equip_previous_melee_weapon()
	local melee_weapons = self:get_sorted_melee_weapons(true, true) or {}
	local equipped_melee_weapon = self:equipped_melee_weapon()
	local equipped_index = table.get_vector_index(melee_weapons, equipped_melee_weapon) or 0

	local previous_index = (equipped_index - 1) % (#melee_weapons + 1)
	local previous_melee_weapon = melee_weapons[previous_index]

	if self:equipped_melee_weaponx2() then
		self:equip_melee_weaponx2(previous_melee_weapon)
	else
		self:equip_melee_weapon(previous_melee_weapon)
	end

	return true
end



function BlackMarketManager:get_part_custom_colors(category, slot, part_id, require_existing)
	if require_existing == nil then
		require_existing = false
	end

	local part_tweak = tweak_data.weapon.factory.parts[part_id] or {}
	local is_gadget = (part_tweak.type=="gadget" or table.contains(part_tweak.perks or {}, "gadget") or part_tweak.sub_type=="laser" or part_tweak.sub_type=="flashlight")
	for i, k in pairs(part_tweak.adds or {}) do
		local added_part = tweak_data.weapon.factory.parts[k]
		if added_part and (added_part.sub_type=="flashlight" or added_part.sub_type=="laser") then is_gadget = true end
	end

	local gadget_power = part_tweak and part_tweak.stats and part_tweak.stats.gadget_power or {}
	local ls_color = (gadget_power.laser or 1)*0.3
	local fl_color = (gadget_power.flashlight or 1)*0.4+0.2
	local default_colors = {
		laser = Color(0, ls_color, 0),
		flashlight = Color(fl_color, fl_color, fl_color),
	}

	if not self._global.nqr_reset_custom_colors then
		for i, k in pairs(self._global.crafted_items or {}) do
			for u, j in pairs(k or {}) do
				for y, h in pairs(j.custom_colors or {}) do
					self._global.crafted_items[i][u].custom_colors[y] = nil
					managers.blackmarket:set_part_custom_colors(category, slot, part_id, default_colors)
				end
			end
		end
		self._global.nqr_reset_custom_colors = true
		log("nqr_reset_custom_colors")
	end

	local crafted_category = self._global.crafted_items[category]
	local crafted_item = crafted_category and crafted_category[slot]
	local custom_colors = crafted_item and crafted_item.custom_colors

	if custom_colors and custom_colors[part_id] then
		local colors = self:get_custom_colors_from_string(custom_colors and custom_colors[part_id])
		local sub_types = {}

		if part_tweak.sub_type then
			sub_types[part_tweak.sub_type] = true
		end

		if part_tweak.adds then
			for _, added_part_id in pairs(part_tweak.adds) do
				local added_part_tweak = tweak_data.weapon.factory.parts[part_id]

				if added_part_tweak.sub_type then
					sub_types[added_part_tweak.sub_type] = true
				end
			end
		end

		for sub_type, _ in pairs(sub_types) do
			colors[sub_type] = colors[sub_type] or tweak_data.custom_colors.defaults[sub_type]
		end

		return colors
	--elseif not require_existing then
	elseif is_gadget then
		--Utils.PrintTable(default_colors, 3)
		return default_colors
	end
end



local ALLOWED_CREW_WEAPON_CATEGORIES = {
	smg = true,
	assault_rifle = true,
	shotgun = true,
	lmg = true,
	snp = true,
	dmr = true,
	machine_pistol = true,
}
function BlackMarketManager:is_weapon_category_allowed_for_crew(weapon_category)
	return not not ALLOWED_CREW_WEAPON_CATEGORIES[weapon_category]
end



function BlackMarketManager:_get_weapon_stats(weapon_id, blueprint, cosmetics)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local weapon_tweak_data = tweak_data.weapon[weapon_id] or {}
	local weapon_stats = managers.weapon_factory:get_stats(factory_id, blueprint)
	local bonus_stats = {}

	for stat, value in pairs(weapon_tweak_data.stats) do
		local _stat = weapon_tweak_data.stats[stat]

		if type(_stat) == "number" then
			weapon_stats[stat] = (weapon_stats[stat] or 0) + _stat
		elseif type(_stat) == "table" then
			local total = 0

			for _, v in ipairs(_stat) do
				total = total + v
			end

			total = total / #_stat
			weapon_stats[stat] = (weapon_stats[stat] or 0) + total
		end
	end

	return weapon_stats
end

function BlackMarketManager:get_weapon_icon_path(weapon_id, cosmetics)
	local akimbo_gui_data = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].akimbo_gui_data
	local use_cosmetics = cosmetics and cosmetics.id and cosmetics.id ~= "nil" and true or false
	local data = use_cosmetics and tweak_data.blackmarket.weapon_skins or tweak_data.weapon
	local id = use_cosmetics and cosmetics.id or akimbo_gui_data and akimbo_gui_data.weapon_id or weapon_id
	local path = use_cosmetics and "weapon_skins/" or "textures/pd2/blackmarket/icons/weapons/"
	local weapon_tweak = data and id and data[id]
	local texture_path, rarity_path = nil

	if weapon_tweak then
		local guis_catalog = "guis/"
		local bundle_folder = weapon_tweak.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/"

			if use_cosmetics then
				guis_catalog = guis_catalog .. "cash/safes/"
			end

			guis_catalog = guis_catalog .. tostring(bundle_folder) .. "/"
		end

		local texture_name = nil

		if use_cosmetics then
			local skin_data = tweak_data.blackmarket.weapon_skins[cosmetics.id]
			local is_cosmetic_base_weapon_id = skin_data.weapon_id == weapon_id

			--if is_cosmetic_base_weapon_id then
				texture_name = cosmetics.id .. (string.find(weapon_id or "", "x_") and ("_" .. weapon_id) or "")
			--else
			--	texture_name = cosmetics.id .. "_" .. weapon_id
			--end
		elseif not weapon_tweak.texture_name then
			texture_name = tostring(id)
		end

		texture_path = guis_catalog .. path .. texture_name

		if use_cosmetics then
			if weapon_tweak.color then
				rarity_path = "guis/dlcs/wcs/textures/pd2/blackmarket/icons/rarity_color"
				texture_path = self:get_weapon_icon_path(weapon_id, nil)
			else
				local rarity = weapon_tweak.rarity or "common"
				rarity_path = tweak_data.economy.rarities[rarity] and tweak_data.economy.rarities[rarity].bg_texture
			end
		end
	end

	return texture_path, rarity_path
end

function BlackMarketManager:set_crafted_custom_name(category, slot, custom_name)
	local crafted_slot = self:get_crafted_category_slot(category, slot)

	if crafted_slot.locked_name then
		--return
	end

	crafted_slot.custom_name = custom_name ~= "" and custom_name
end

function BlackMarketManager:get_crafted_custom_name(category, slot, add_quotation)
	local crafted_slot = self:get_crafted_category_slot(category, slot)
	local cosmetics = crafted_slot and crafted_slot.cosmetics

	if cosmetics and cosmetics.id and tweak_data.blackmarket.weapon_skins[cosmetics.id] and tweak_data.blackmarket.weapon_skins[cosmetics.id].unique_name_id then
		--return
	end

	local custom_name = crafted_slot and crafted_slot.custom_name

	if custom_name then
		if add_quotation then
			return "\"" .. custom_name .. "\""
		end

		return custom_name
	end
end

function BlackMarketManager:get_weapon_name_by_category_slot(category, slot)
	if category == "primaries" then
		local forced_primary = self:forced_primary()

		if forced_primary then
			return managers.weapon_factory:get_weapon_name_by_factory_id(forced_primary.factory_id)
		end
	else
		local forced_secondary = self:forced_secondary()

		if forced_secondary then
			return managers.weapon_factory:get_weapon_name_by_factory_id(forced_secondary.factory_id)
		end
	end

	local crafted_slot = self:get_crafted_category_slot(category, slot)

	if crafted_slot then
		local cosmetics = crafted_slot.cosmetics
		local cosmetic_name = cosmetics and cosmetics.id and tweak_data.blackmarket.weapon_skins[cosmetics.id] and tweak_data.blackmarket.weapon_skins[cosmetics.id].unique_name_id and managers.localization:text(tweak_data.blackmarket.weapon_skins[cosmetics.id].unique_name_id)
		local custom_name = crafted_slot.custom_name or cosmetic_name

		if custom_name then
			return "\"" .. custom_name .. "\""
		end

		if cosmetic_name and crafted_slot.locked_name then
			return utf8.to_upper(cosmetic_name)
		end

		return managers.weapon_factory:get_weapon_name_by_factory_id(crafted_slot.factory_id)
	end

	return ""
end



function BlackMarketManager:weapon_unlocked(weapon_id)
	local data = Global.blackmarket_manager.weapons[weapon_id]

	if data.func_based and not self[data.func_based](self) then
		return false
	end

	if data.level and (data.level > managers.experience:current_level()) then data.unlocked = false end

	return data.unlocked
end



function BlackMarketManager:is_crew_item_unlocked(item) end



function BlackMarketManager:has_unlocked_ching()
	return managers.generic_side_jobs:has_completed_and_claimed_rewards("aru_2"), "bm_menu_locked_erma"
end
function BlackMarketManager:has_unlocked_erma()
	return managers.generic_side_jobs:has_completed_and_claimed_rewards("aru_3"), "bm_menu_locked_ching"
end



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
	local melee_weapon_data = melee_weapon and tweak_data.blackmarket.melee_weapons[melee_weapon].stats

	return melee_weapon_data and melee_weapon_data.concealment or tweak_data.weapon.stats.concealment
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
				local def = tweak_data.upgrades.definitions[upgrade]

				if not def then
				log(upgrade)

				end

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



--[[function BlackMarketManager:_cleanup_blackmarket()
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
end]]
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

	local function chk_global_value_func(global_value, data, real_global_value)
		return tweak_data.lootdrop.global_values[global_value or "normal"] and true or false
	end

	local cleanup_mask = false
	local crafted_masks = crafted_items.masks

	for i, mask in pairs(crafted_masks) do
		local mask_data = tweak_data.blackmarket.masks[mask.mask_id]
		cleanup_mask = not mask_data or mask_data.inaccessible
		cleanup_mask = cleanup_mask or not chk_global_value_func(mask.global_value, mask, mask_data.infamous and "infamous" or mask_data.dlc or mask_data.global_value)
		local blueprint = mask.blueprint or {}

		if not cleanup_mask then
			if not blueprint.color_c then
				print("[BlackMarketManager:LICConverter] Mask was missing a color_c, adding...")

				blueprint.color_c = {
					id = "strip_paint",
					global_value = "normal"
				}
			end

			for part_type, data in pairs(blueprint) do
				local converted_category = MASK_COLOR_CONVERT_MAP[part_type] or part_type
				local part_data = tweak_data.blackmarket[converted_category] and tweak_data.blackmarket[converted_category][data.id]

				if converted_category == "materials" and (part_type == "color_a" or part_type == "color_b") and not part_data then
					print("[BlackMarketManager:LICConverter] Has convert color?", data.id, tweak_data.blackmarket.mask_colors[data.id] and tweak_data.blackmarket.mask_colors[data.id].convert_to_material)

					local convert_to_material = tweak_data.blackmarket.mask_colors[data.id] and tweak_data.blackmarket.mask_colors[data.id].convert_to_material or "plastic"
					part_data = tweak_data.blackmarket.materials[convert_to_material]

					print("[BlackMarketManager:LICConverter] Converting material to " .. convert_to_material, data.id, inspect(part_data or {}))

					if part_data then
						data.id = convert_to_material
						data.global_value = part_data.infamous and "infamous" or part_data.global_value or "normal"
					end
				end

				cleanup_mask = not part_data
				cleanup_mask = cleanup_mask or not chk_global_value_func(data.global_value, data, part_data.infamous and "infamous" or part_data.dlc or part_data.global_value)

				if cleanup_mask then
					print("[BlackMarketManager:LICConverter] Mask added to cleanup due to", converted_category, part_type, "-", data.id)

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

			local csc = { primaries = 2, secondaries = 1 }
			if tweak_data.weapon[weapon_id]
			and tweak_data.weapon[weapon_id].use_data
			and tweak_data.weapon[weapon_id].use_data.selection_index~=csc[category] then
				log("BlackMarketManager:_cleanup_blackmarket()", "Weapon is in the wrong category", weapon_id)
				table.insert(invalid_weapons, slot)
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
										reason = "not for weapon (default)",
										slot = slot,
										default_mod = default_mod,
										part_id = part_id
									})
								else
									table.insert(invalid_parts, {
										refund = true,
										reason = "not for weapon",
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
			self:on_sell_weapon(category, slot, true)
		end

		for _, data in ipairs(invalid_parts) do
			if crafted_category[data.slot] then
				Application:error("BlackMarketManager:_cleanup_blackmarket() Removing invalid Weapon part", data.reason, "slot", data.slot, "part_id", data.part_id, "default_mod", data.default_mod, "inspect", inspect(crafted_category[data.slot]), inspect(data))

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

	local function convert_color_to_material_item_func(global_value, category, item, num_owned, material_id)
		print("[BlackMarketManager:LICConverter] Trying...", global_value, category, item, num_owned, material_id)

		local inventory = self._global.inventory
		local material_tweak_data = tweak_data.blackmarket.materials[material_id] or tweak_data.blackmarket.materials.plastic

		if material_tweak_data then
			local material_global_value = material_tweak_data.global_value or material_tweak_data.infamous and "infamous" or "normal"
			inventory[material_global_value] = inventory[material_global_value] or {}
			inventory[material_global_value].materials = inventory[material_global_value].materials or {}
			inventory[material_global_value].materials[material_id] = num_owned

			print("[BlackMarketManager:LICConverter]", item, "into", material_id, num_owned)
		end

		add_invalid_item_func(global_value, category, item)
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
						elseif category == "mask_colors" and item_tweak_data.convert_to_material then
							convert_color_to_material_item_func(global_value, category, item, num, item_tweak_data.convert_to_material)
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
