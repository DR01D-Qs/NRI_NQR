function UpgradesManager:get_value(upgrade_id, ...)
	local upgrade = tweak_data.upgrades.definitions[upgrade_id]

	if not upgrade then
		Application:error("[UpgradesManager:get_value] Missing Upgrade ID: ", upgrade_id)
	end

	local u = upgrade.upgrade

	if upgrade.category == "feature" then
		return tweak_data.upgrades.values[u.category][u.upgrade][u.value]
	elseif upgrade.category == "equipment" then
		return upgrade.equipment_id
	elseif upgrade.category == "equipment_upgrade" then
		return tweak_data.upgrades.values[u.category][u.upgrade][u.value]
	elseif upgrade.category == "temporary" then
		local temporary = tweak_data.upgrades.values[u.category][u.upgrade][u.value]

		return "Value: " .. tostring(temporary[1]) .. " Time: " .. temporary[2]
	elseif upgrade.category == "cooldown" then
		local cooldown = tweak_data.upgrades.values[u.category][u.upgrade][u.value]

		return "Value: " .. tostring(cooldown[1]) .. " Time: " .. cooldown[2]
	elseif upgrade.category == "team" then
		local value = tweak_data.upgrades.values.team[u.category][u.upgrade][u.value]

		return value
	elseif upgrade.category == "weapon" then
		local default_weapons = {
			"peacemaker",
			"coach",
		}
		local weapon_id = upgrade.weapon_id
		local is_default_weapon = table.contains(default_weapons, weapon_id) and true or false
		local weapon_level = 0
		local new_weapon_id = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].parent_weapon_id or weapon_id

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, new_weapon_id) then
				weapon_level = level

				break
			end
		end

		return is_default_weapon, weapon_level, weapon_id ~= new_weapon_id
	elseif upgrade.category == "melee_weapon" then
		local params = {
			...
		}
		local default_id = params[1] or managers.blackmarket and managers.blackmarket:get_category_default("melee_weapon") or "weapon"
		local melee_weapon_id = upgrade_id
		local is_default_weapon = melee_weapon_id == default_id
		local melee_weapon_level = 0

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, melee_weapon_id) then
				melee_weapon_level = level

				break
			end
		end

		return is_default_weapon, melee_weapon_level
	elseif upgrade.category == "grenade" then
		local params = {
			...
		}
		local default_id = params[1] or managers.blackmarket and managers.blackmarket:get_category_default("grenade") or "weapon"
		local grenade_id = upgrade_id
		local is_default_weapon = grenade_id == default_id
		local grenade_level = 0

		for level, data in pairs(tweak_data.upgrades.level_tree) do
			local upgrades = data.upgrades

			if upgrades and table.contains(upgrades, grenade_id) then
				grenade_level = level

				break
			end
		end

		return is_default_weapon, grenade_level
	elseif upgrade.category == "rep_upgrade" then
		return upgrade.value
	end

	print("no value for", upgrade_id, upgrade.category)
end



function UpgradesManager:aquire(id, loading, identifier)
	if not tweak_data.upgrades.definitions[id] then
		Application:error("Tried to aquire an upgrade that doesn't exist: " .. (id or "nil") .. "")

		return
	end

	local upgrade = tweak_data.upgrades.definitions[id]

	if upgrade.dlc and not managers.dlc:is_dlc_unlocked(upgrade.dlc) and id~="peacemaker" then
		Application:error("Tried to aquire an upgrade locked to a dlc you do not have: " .. id .. " DLC: ", upgrade.dlc)

		return
	end

	if not identifier then
		debug_pause(identifier, "[UpgradesManager:aquire] No identifier for upgrade aquire", "id", id, "loading", loading)

		identifier = UpgradesManager.AQUIRE_STRINGS[1]
	end

	local identify_key = Idstring(identifier):key()

	if self._global.aquired[id] and self._global.aquired[id][identify_key] then
		Application:error("Tried to aquire an upgrade that has already been aquired: " .. id, "identifier", identifier, "id_key", identify_key)
		Application:stack_dump()

		return
	end

	self._global.aquired[id] = self._global.aquired[id] or {}
	self._global.aquired[id][identify_key] = identifier

	self:_aquire_upgrade(upgrade, id, loading)
	self:setup_current_weapon()
end