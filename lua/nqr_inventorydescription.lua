InventoryDescription = InventoryDescription or class()

local function is_weapon_category(weapon_tweak, ...)
	local arg = {
		...
	}
	local categories = weapon_tweak.categories

	for i = 1, #arg do
		if table.contains(categories, arg[i]) then
			return true
		end
	end

	return false
end

WeaponDescription = WeaponDescription or class()
WeaponDescription._stats_shown = {
	{ name = "weight", inverted = true, },
	{ name = "length", inverted = true, },
	{ name = "concealment", index = true, inverted = true, },
	{ name = "caliber", override = true, },
	{ name = "ammotype", override = true, },
	{ name = "barrel_length", override = true, },
	{ name = "damage", },
	{ name = "spread", percent = false, inverted = true, offset = false, revert = false, },
	{ name = "recoil", percent = false, inverted = true, offset = false, revert = false, },
	--{ name = "suppression", percent = false, offset = true, },
	{ name = "magazine", stat_name = "extra_ammo", round_value = true, },
	{ name = "totalammo", stat_name = "total_ammo_mod", },
	{ name = "fire_rate", round_value = true, },
	--{ name = "reload" },
}

function WeaponDescription._get_stats(name, category, slot, blueprint)
	WeaponDescription._stats_shown = {
		{ name = "weight", inverted = true, },
		{ name = "length", inverted = true, },
		{ name = "concealment", index = true, inverted = true, },
		{ name = "caliber", override = true, },
		{ name = "ammotype", override = true, },
		{ name = "barrel_length", override = true, },
		{ name = "damage", },
		{ name = "spread", percent = false, inverted = true, offset = false, revert = false, },
		{ name = "recoil", percent = false, inverted = true, offset = false, revert = false, },
		--{ name = "suppression", percent = false, offset = true, },
		{ name = "magazine", stat_name = "extra_ammo", round_value = true, },
		{ name = "totalammo", stat_name = "total_ammo_mod", },
		{ name = "fire_rate", round_value = true, },
		--{ name = "reload" },
	}

	local equipped_mods = nil
	local silencer = false
	local single_mod = false
	local auto_mod = false
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local blueprint = blueprint or slot and managers.blackmarket:get_weapon_blueprint(category, slot) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local cosmetics = managers.blackmarket:get_weapon_cosmetics(category, slot)
	local bonus_stats = {}

	if cosmetics and cosmetics.id and cosmetics.bonus and not managers.job:is_current_job_competitive() and not managers.weapon_factory:has_perk("bonus", factory_id, blueprint) then
		--bonus_stats = tweak_data:get_raw_value("economy", "bonuses", tweak_data.blackmarket.weapon_skins[cosmetics.id].bonus, "stats") or {}
	end

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)

		if equipped_mods then
			silencer = managers.weapon_factory:has_perk("silencer", factory_id, equipped_mods)
			single_mod = managers.weapon_factory:has_perk("fire_mode_single", factory_id, equipped_mods)
			auto_mod = managers.weapon_factory:has_perk("fire_mode_auto", factory_id, equipped_mods)
		end
	end

	local base_stats = WeaponDescription._get_base_stats(name)
	local mods_stats = WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local skill_stats = WeaponDescription._get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local clip_ammo, max_ammo, ammo_data = WeaponDescription.get_weapon_ammo_info(name, tweak_data.weapon[name].stats.extra_ammo--[[, base_stats.totalammo.index + mods_stats.totalammo.index]])

	local weapon = {
		factory_id = factory_id,
		blueprint = blueprint
	}

	local wep_tweak = tweak_data.weapon[name]
	local action_factor_spread = wep_tweak.action and (
		(wep_tweak.action=="moving_barrel" and 1.2) or
		((wep_tweak.action=="blowback" or wep_tweak.action=="roller_delayed") and 1.1)
		or 1
	) or 1.1
	local action_factor_recoil = wep_tweak.action and (
		(wep_tweak.action=="blowback" and 2) or
		(wep_tweak.action~="moving_barrel" and wep_tweak.action~="roller_delayed" and 3)
	) or 1
	local secondary_factor = ((wep_tweak.use_data.selection_index==1) and 2 or 1)

	local base_ammotype_data = tweak_data.weapon:nqr_ammotype_data(base_stats.caliber.value, base_stats.ammotype.value)
	local mods_ammotype_data = tweak_data.weapon:nqr_ammotype_data(
		mods_stats.caliber.value~=0 and mods_stats.caliber.value or base_stats.caliber.value,
		mods_stats.ammotype.value~=0 and mods_stats.ammotype.value or base_stats.ammotype.value
	)

	base_stats.damage.value = tweak_data.weapon:nqr_energy(
		base_ammotype_data,
		base_stats.barrel_length.value,
		name
	) * 0.025
	base_stats.spread.value = tweak_data.weapon:nqr_spread(
		base_ammotype_data,
		base_stats.barrel_length.value,
		name
	)
	base_stats.recoil.value = tweak_data.weapon:nqr_rise(
		base_ammotype_data,
		base_stats.barrel_length.value,
		base_stats.weight.value,
		name
	)

	mods_stats.damage.value = tweak_data.weapon:nqr_energy(
		mods_ammotype_data,
		mods_stats.barrel_length.value~=0 and mods_stats.barrel_length.value or base_stats.barrel_length.value,
		name
	) * 0.025
	mods_stats.spread.value = tweak_data.weapon:nqr_spread(
		mods_ammotype_data,
		mods_stats.barrel_length.value~=0 and mods_stats.barrel_length.value or base_stats.barrel_length.value,
		name
	)
	mods_stats.recoil.value = tweak_data.weapon:nqr_rise(
		mods_ammotype_data,
		mods_stats.barrel_length.value~=0 and mods_stats.barrel_length.value or base_stats.barrel_length.value,
		base_stats.weight.value+mods_stats.weight.value,
		name
	)

	return base_stats, mods_stats, skill_stats
end

function WeaponDescription._get_base_stats(name)
	local base_stats = {}
	local tweak_default_stats = tweak_data.weapon.stats
	local wep_tweak = tweak_data.weapon[name]

	local action_factor = wep_tweak.action and ((wep_tweak.action=="blowback" and 2) or (wep_tweak.action~="moving_barrel" and wep_tweak.action~="roller_delayed" and 3)) or 1
	local secondary_factor = ((wep_tweak.use_data.selection_index==1) and 2 or 1)
	local base_reload_time = 2
	local mag_release = (wep_tweak.mag_release=="doublebutton" and 1.3) or (wep_tweak.mag_release=="paddle" and 1.2) or (wep_tweak.mag_release=="pushbutton" and 1.1) or 1
	local bolt_release = ((wep_tweak.bolt_release=="none" and 0.8) or (wep_tweak.bolt_release=="quarter" and 0.6) or (wep_tweak.bolt_release=="half" and 0.3) or 0.2)
	local wep_weight = wep_tweak["weight"]
	local mag_weight = 1 --weapon_base._current_stats.mag_weight
	local is_bullpup = wep_tweak.bullpup and 1.2 or 1
	local is_revolver = wep_tweak.categories[1]=="revolver" and 1.5 or 1
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

	for _, stat in pairs(WeaponDescription._stats_shown) do
		base_stats[stat.name] = {}

		if stat.name == "magazine" then
			for i, k in pairs(default_blueprint) do
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(k, factory_id, default_blueprint)
				if part_data.stats and part_data.stats.CLIP_AMMO_MAX then
					base_stats[stat.name].value = (
						type(part_data.stats.CLIP_AMMO_MAX)=="table"
						and (part_data.stats.CLIP_AMMO_MAX[wep_tweak.caliber or "9x19"] or 0)
						or part_data.stats.CLIP_AMMO_MAX
					)
				end
			end
			base_stats[stat.name].value = (base_stats[stat.name].value or wep_tweak.CLIP_AMMO_MAX or 0)
		elseif stat.name == "totalammo" then
			for i, k in pairs(default_blueprint) do
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(k, factory_id, default_blueprint)
				if part_data.stats and part_data.stats.mag_amount then
					base_stats[stat.name].value = (
						part_data.stats.mag_amount[2]
					)
				end
			end
			base_stats[stat.name].value = base_stats[stat.name].value or wep_tweak.AMMO_MAX
		elseif stat.name == "fire_rate" and wep_tweak.fire_mode_data then
			local fire_rate = 60 / wep_tweak.fire_mode_data.fire_rate
			base_stats[stat.name].value = fire_rate / 10 * 10
		elseif stat.name == "caliber" then
			base_stats[stat.name].value = tweak_data.weapon.calibers[wep_tweak.caliber] and wep_tweak.caliber or "9x19"
		elseif stat.name == "ammotype" then
			base_stats[stat.name].value = (
				tweak_data.weapon.calibers[wep_tweak.caliber]
				and tweak_data.weapon.calibers[wep_tweak.caliber][1]
				and tweak_data.weapon.calibers[wep_tweak.caliber][1].name
			) or "Default"
		elseif stat.name == "barrel_length" then
			for i, k in pairs(default_blueprint) do
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(k, factory_id, default_blueprint)
				if part_data.stats and part_data.stats.barrel_length then
					base_stats[stat.name].value = part_data.stats.barrel_length
					break
				end
			end
			base_stats[stat.name].value = base_stats[stat.name].value or 0
		elseif stat.name == "weight" then
			base_stats[stat.name].value = wep_tweak[stat.name] or 0
		elseif stat.name == "length" then
			base_stats[stat.name].value = base_stats[stat.name].value or 0

			for i, k in pairs(default_blueprint) do
				part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(k, factory_id, default_blueprint)
				if part_data.stats and (part_data.stats.length or part_data.stats.barrel_length) then
					base_stats[stat.name].value = base_stats[stat.name].value + (part_data.stats.length or 0) + (part_data.stats.barrel_length or 0)
				end
			end
		elseif tweak_default_stats[stat.name] then
			base_stats[stat.name].value = type(wep_tweak[stat.name])=="number" and wep_tweak[stat.name] or 0 --stat.index and index or tweak_default_stats[stat.name][index] * tweak_data.gui.stats_present_multiplier
		end
	end

	return base_stats
end

function WeaponDescription._get_mods_stats(name, base_stats, equipped_mods, bonus_stats)
	local mods_stats = {}
	local wep_tweak = tweak_data.weapon[name]

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mods_stats[stat.name] = {
			index = 0,
			value = 0
		}
	end

	if equipped_mods then
		local tweak_stats = tweak_data.weapon.stats
		local tweak_factory = tweak_data.weapon.factory.parts
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		local part_data = nil

		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data and part_data.stats then
				for _, stat in pairs(WeaponDescription._stats_shown) do
					if stat.override then
						if part_data.stats[stat.name] then mods_stats[stat.name].value = part_data.stats[stat.name] end
					elseif stat.name=="magazine" then
						--nothing lol
					elseif stat.name=="totalammo" then
						--nothing lol
					elseif stat.name == "fire_rate" then
						if part_data.custom_stats and part_data.custom_stats.fire_rate_multiplier then
							mods_stats[stat.name].value = mods_stats[stat.name].value + part_data.custom_stats.fire_rate_multiplier - 1
						end
					else
						mods_stats[stat.name].value = mods_stats[stat.name].value + (part_data.stats[stat.name] or 0)
					end
				end
			end
		end

		for o, l in pairs(default_blueprint) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(l, factory_id, default_blueprint)
			if part_data.stats then
				for i, k in pairs(mods_stats) do
					if part_data.stats[i] then
						if i=="barrel_length" then
							if mods_stats.barrel_length.value==base_stats.barrel_length.value then
								mods_stats.barrel_length.value = mods_stats.barrel_length.value - part_data.stats.barrel_length
							end
						else
							mods_stats[i].value = mods_stats[i].value - part_data.stats[i]
						end
					end
				end

				if part_data.stats.CLIP_AMMO_MAX then
					if mods_stats.magazine.value==base_stats.magazine.value then
						mods_stats.magazine.value = 0
					end
				end
			end
		end

		if mods_stats.caliber.value~=0 and mods_stats.ammotype.value==0 then
			mods_stats.ammotype.value = (
				tweak_data.weapon.calibers[mods_stats.caliber.value]
				and tweak_data.weapon.calibers[mods_stats.caliber.value][1]
				and tweak_data.weapon.calibers[mods_stats.caliber.value][1].name
			) or "Default"
		end

		mods_stats.length.value = 0 - (base_stats.barrel_length and base_stats.barrel_length.value or 0)
		local mag_dflt = wep_tweak.CLIP_AMMO_MAX
		local mag_main = 0
		local mag_ext = 0
		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data and part_data.stats then
				if part_data.stats.CLIP_AMMO_MAX then
					local stats_mag = (
						type(part_data.stats.CLIP_AMMO_MAX)=="table"
						and (part_data.stats.CLIP_AMMO_MAX[mods_stats.caliber.value~=0 and mods_stats.caliber.value or base_stats.caliber.value] or 0)
						or part_data.stats.CLIP_AMMO_MAX
					)

					if stats_mag==base_stats.magazine.value then
						mag_dflt = stats_mag
						mag_main = 0
					elseif part_data.type~="magazine" and part_data.type~="barrel" and part_data.type~="exclusive_set" then
						mag_ext = stats_mag
					elseif stats_mag then
						mag_dflt = stats_mag
						mag_main = (stats_mag - base_stats.magazine.value)
					end
				end

				mods_stats.length.value = mods_stats.length.value + --[[(part_data.stats.length or 0) +]] (part_data.stats.barrel_length or 0)
			end
		end
		mods_stats.magazine.value = mag_main + mag_ext

		local main_total_ammo = 0
		local added_total_ammo = 0
		for _, mod in ipairs(equipped_mods) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod, factory_id, default_blueprint)

			if part_data and part_data.stats then
				if part_data.stats.totalammo then
					added_total_ammo = added_total_ammo + (
						(wep_tweak.use_shotgun_reload or wep_tweak.feed_system=="break_action")
						and part_data.stats.totalammo
						or (part_data.stats.totalammo / (mag_dflt + mag_ext))
					)
				elseif part_data.stats.mag_amount then
					main_total_ammo = part_data.stats.mag_amount[2]
				end
			end
		end
		main_total_ammo = (main_total_ammo==0 and wep_tweak.AMMO_MAX or main_total_ammo) + added_total_ammo
		mods_stats.totalammo.value = main_total_ammo - base_stats.totalammo.value

		local index, stat_name = nil

		for _, stat in pairs(WeaponDescription._stats_shown) do
			if mods_stats[stat.name] and tweak_stats[stat.name] then
				if stat.name == "fire_rate" then
					mods_stats[stat.name].value = base_stats[stat.name].value * mods_stats[stat.name].value
				end
			end
		end
	end

	return mods_stats
end

function WeaponDescription.get_stats_for_mod(mod_name, weapon_name, category, slot)
	local equipped_mods = nil
	local blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

	if blueprint then
		equipped_mods = deep_clone(blueprint)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	end

	local base_stats = WeaponDescription._get_base_stats(weapon_name)
	local mods_stats = WeaponDescription._get_mods_stats(weapon_name, base_stats, equipped_mods)

	local part_data = nil
	for i, k in pairs(equipped_mods) do
		for o, l in pairs(default_blueprint) do
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(l, factory_id, default_blueprint)
			if part_data.stats.CLIP_AMMO_MAX and l==k then
				base_stats["weight"].value = base_stats["weight"].value + part_data.stats.weight
				mods_stats["weight"].value = mods_stats["weight"].value - part_data.stats.weight
			end
		end
	end
	local wep_tweak = tweak_data.weapon[weapon_name]
	local action_factor_spread = wep_tweak.action and (
		(wep_tweak.action=="moving_barrel" and 1.2) or
		((wep_tweak.action=="blowback" or wep_tweak.action=="roller_delayed") and 1.1)
		or 1
	) or 1.1
	local action_factor_recoil = wep_tweak.action and (
		(wep_tweak.action=="blowback" and 2) or
		(wep_tweak.action~="moving_barrel" and wep_tweak.action~="roller_delayed" and 3)
	) or 1
	local secondary_factor = ((wep_tweak.use_data.selection_index==1) and 2 or 1)

	local base_ammotype_data = tweak_data.weapon:nqr_ammotype_data(base_stats.caliber.value, base_stats.ammotype.value)

	base_stats.damage.value = tweak_data.weapon:nqr_energy(
		base_ammotype_data,
		base_stats.barrel_length.value,
		name
	) * 0.025
	base_stats.spread.value = tweak_data.weapon:nqr_spread(
		base_ammotype_data,
		base_stats.barrel_length.value,
		name
	)
	base_stats.recoil.value = tweak_data.weapon:nqr_rise(
		base_ammotype_data,
		base_stats.barrel_length.value,
		base_stats.weight.value,
		name
	)

	return WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
end

function WeaponDescription._get_weapon_mod_stats(mod_name, weapon_name, base_stats, mods_stats, equipped_mods)
	WeaponDescription._stats_shown = {
		{ name = "weight", inverted = true, },
		{ name = "length", inverted = true, },
		{ name = "concealment", index = true, inverted = true, },
		{ name = "caliber", override = true, },
		{ name = "ammotype", override = true, },
		{ name = "barrel_length", override = true, },
		{ name = "damage", },
		{ name = "spread", percent = false, inverted = true, offset = false, revert = false, },
		{ name = "recoil", percent = false, inverted = true, offset = false, revert = false, },
		--{ name = "suppression", percent = false, offset = true, },
		{ name = "magazine", stat_name = "extra_ammo", round_value = true, },
		{ name = "totalammo", stat_name = "total_ammo_mod", },
		{ name = "fire_rate", round_value = true, },
		--{ name = "reload" },
	}

	local tweak_stats = tweak_data.weapon.stats
	local tweak_factory = tweak_data.weapon.factory.parts
	local weapon_tweak = tweak_data.weapon[weapon_name]
	local modifier_stats = weapon_tweak.stats_modifiers
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
	local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local part_data = nil
	local mod_stats = {
		chosen = {},
		equip = {}
	}

	for _, stat in pairs(WeaponDescription._stats_shown) do
		mod_stats.chosen[stat.name] = 0
		mod_stats.equip[stat.name] = 0
	end

	mod_stats.chosen.name = mod_name

	if equipped_mods then
		for _, mod in ipairs(equipped_mods) do
			if tweak_factory[mod] and tweak_factory[mod_name].type == tweak_factory[mod].type then
				mod_stats.equip.name = mod

				break
			end
		end
	end

	local curr_stats = base_stats
	local index, wanted_index = nil

	for _, mod in pairs(mod_stats) do
		part_data = nil

		if mod.name then
			part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(mod.name, factory_id, default_blueprint)
		end

		for _, stat in pairs(WeaponDescription._stats_shown) do
			if part_data and part_data.stats then
				if stat.name == "magazine" then
					if part_data.stats.CLIP_AMMO_MAX then
						local stats_mag = (
							type(part_data.stats.CLIP_AMMO_MAX)=="table"
							and (part_data.stats.CLIP_AMMO_MAX[mods_stats.caliber.value~=0 and mods_stats.caliber.value or base_stats.caliber.value] or 0)
							or part_data.stats.CLIP_AMMO_MAX
						)

						mod[stat.name] = stats_mag
					end
				elseif stat.name == "totalammo" then
					if part_data.stats.mag_amount then
						mod[stat.name] = (part_data.stats.mag_amount[2])-base_stats.totalammo.value
					elseif part_data.stats.totalammo then
						mod[stat.name] = part_data.stats[stat.name]
					end
				else
					if type(mod[stat.name])~="string" and type(curr_stats[stat.name].value)~="string" then
						mod[stat.name] = curr_stats[stat.name].value + (part_data.stats[stat.name] or 0)
						mod[stat.name] = mod[stat.name] - curr_stats[stat.name].value
					end
				end
			end
		end
	end

	return mod_stats
end

function WeaponDescription._get_skill_stats(name, category, slot, base_stats, mods_stats, silencer, single_mod, auto_mod, blueprint)
	local skill_stats = {}
	local tweak_stats = tweak_data.weapon.stats

	for _, stat in pairs(WeaponDescription._stats_shown) do
		skill_stats[stat.name] = {
			value = 0
		}
	end

	local detection_risk = 0

	if category then
		local custom_data = {
			[category] = managers.blackmarket:get_crafted_category_slot(category, slot)
		}
		detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data(custom_data, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
		detection_risk = detection_risk * 100
	end

	local base_value, base_index, modifier, multiplier = nil
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(name)
	local weapon_tweak = tweak_data.weapon[name]
	local primary_category = weapon_tweak.categories[1]

	for _, stat in ipairs(WeaponDescription._stats_shown) do
		if weapon_tweak.stats[stat.stat_name or stat.name] or stat.name == "totalammo" or stat.name == "fire_rate" then
			if stat.name == "magazine" then
				skill_stats[stat.name].value = managers.player:upgrade_value(name, "clip_ammo_increase", 0)
				local has_magazine = weapon_tweak.has_magazine
				local add_modifier = false

				if is_weapon_category(weapon_tweak, "shotgun") and has_magazine then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("shotgun", "magazine_capacity_inc", 0)
					add_modifier = managers.player:has_category_upgrade("shotgun", "magazine_capacity_inc")

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end
				elseif is_weapon_category(weapon_tweak, "pistol") and not is_weapon_category(weapon_tweak, "revolver") and managers.player:has_category_upgrade("pistol", "magazine_capacity_inc") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("pistol", "magazine_capacity_inc", 0)

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end

					add_modifier = true
				elseif is_weapon_category(weapon_tweak, "smg", "assault_rifle", "lmg") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("player", "automatic_mag_increase", 0)
					add_modifier = managers.player:has_category_upgrade("player", "automatic_mag_increase")

					if primary_category == "akimbo" then
						skill_stats[stat.name].value = skill_stats[stat.name].value * 2
					end
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks.weapon or not table.contains(weapon_tweak.upgrade_blocks.weapon, "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
				end

				if not weapon_tweak.upgrade_blocks or not weapon_tweak.upgrade_blocks[primary_category] or not table.contains(weapon_tweak.upgrade_blocks[primary_category], "clip_ammo_increase") then
					skill_stats[stat.name].value = skill_stats[stat.name].value + managers.player:upgrade_value(primary_category, "clip_ammo_increase", 0)
				end

				skill_stats[stat.name].skill_in_effect = managers.player:has_category_upgrade(name, "clip_ammo_increase") or managers.player:has_category_upgrade("weapon", "clip_ammo_increase") or add_modifier
			elseif stat.name == "totalammo" then
				-- Nothing
			elseif stat.name == "reload" then
				local skill_in_effect = false
				local mult = 1

				for _, category in ipairs(weapon_tweak.categories) do
					if managers.player:has_category_upgrade(category, "reload_speed_multiplier") then
						mult = mult + 1 - managers.player:upgrade_value(category, "reload_speed_multiplier", 1)
						skill_in_effect = true
					end
				end

				mult = 1 / managers.blackmarket:_convert_add_to_mul(mult)
				local diff = base_stats[stat.name].value * mult - base_stats[stat.name].value
				skill_stats[stat.name].value = skill_stats[stat.name].value + diff
				skill_stats[stat.name].skill_in_effect = skill_in_effect
			else
				base_value = math.max(base_stats[stat.name].value + mods_stats[stat.name].value, 0)

				if base_stats[stat.name].index and mods_stats[stat.name].index then
					base_index = base_stats[stat.name].index + mods_stats[stat.name].index
				end

				multiplier = 1
				modifier = 0
				local is_single_shot = managers.weapon_factory:has_perk("fire_mode_single", factory_id, blueprint)

				if stat.name == "damage" then
					multiplier = managers.blackmarket:damage_multiplier(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint)
					modifier = math.floor(managers.blackmarket:damage_addend(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint) * tweak_data.gui.stats_present_multiplier * multiplier)
				elseif stat.name == "spread" then
					local fire_mode = single_mod and "single" or auto_mod and "auto" or weapon_tweak.FIRE_MODE or "single"
					multiplier = managers.blackmarket:accuracy_multiplier(name, weapon_tweak.categories, silencer, nil, nil, fire_mode, blueprint, nil, is_single_shot)
					modifier = managers.blackmarket:accuracy_addend(name, weapon_tweak.categories, base_index, silencer, nil, fire_mode, blueprint, nil, is_single_shot) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "recoil" then
					multiplier = managers.blackmarket:recoil_multiplier(name, weapon_tweak.categories, silencer, blueprint)
					modifier = managers.blackmarket:recoil_addend(name, weapon_tweak.categories, base_index, silencer, blueprint, nil, is_single_shot) * tweak_data.gui.stats_present_multiplier
				elseif stat.name == "suppression" then
					multiplier = managers.blackmarket:threat_multiplier(name, weapon_tweak.categories, silencer)
				elseif stat.name == "concealment" then
					if silencer and managers.player:has_category_upgrade("player", "silencer_concealment_increase") then
						modifier = managers.player:upgrade_value("player", "silencer_concealment_increase", 0)
					end

					if silencer and managers.player:has_category_upgrade("player", "silencer_concealment_penalty_decrease") then
						local stats = managers.weapon_factory:get_perk_stats("silencer", factory_id, blueprint)

						if stats and stats.concealment then
							modifier = modifier + math.min(managers.player:upgrade_value("player", "silencer_concealment_penalty_decrease", 0), math.abs(stats.concealment))
						end
					end
				elseif stat.name == "fire_rate" then
					base_value = math.max(base_stats[stat.name].value, 0)

					if base_stats[stat.name].index then
						base_index = base_stats[stat.name].index
					end

					multiplier = managers.blackmarket:fire_rate_multiplier(name, weapon_tweak.categories, silencer, detection_risk, nil, blueprint)
				end

				if modifier ~= 0 then
					local offset = math.min(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

					if stat.revert then
						modifier = -modifier
					end

					if stat.percent then
						local max_stat = stat.index and #tweak_stats[stat.name] or math.max(tweak_stats[stat.name][1], tweak_stats[stat.name][#tweak_stats[stat.name]]) * tweak_data.gui.stats_present_multiplier

						if stat.offset then
							max_stat = max_stat - offset
						end

						local ratio = modifier / max_stat
						modifier = ratio * 100
					end
				end

				if stat.revert then
					multiplier = 1 / math.max(multiplier, 0.01)
				end

				skill_stats[stat.name].skill_in_effect = multiplier ~= 1 or modifier ~= 0
				skill_stats[stat.name].value = modifier + base_value * multiplier - base_value
			end
		end
	end

	return skill_stats
end

function WeaponDescription.get_weapon_ammo_info(weapon_id, extra_ammo, total_ammo_mod)
	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)
	local primary_category = weapon_tweak_data.categories[1]
	local category_skill_in_effect = false
	local category_multiplier = 1

	for _, category in ipairs(weapon_tweak_data.categories) do
		if managers.player:has_category_upgrade(category, "extra_ammo_multiplier") then
			category_multiplier = category_multiplier + managers.player:upgrade_value(category, "extra_ammo_multiplier", 1) - 1
			category_skill_in_effect = true
		end
	end

	ammo_max_multiplier = 1

	local function get_ammo_max_per_clip(weapon_id)
		local function upgrade_blocked(category, upgrade)
			if not weapon_tweak_data.upgrade_blocks then
				return false
			end

			if not weapon_tweak_data.upgrade_blocks[category] then
				return false
			end

			return table.contains(weapon_tweak_data.upgrade_blocks[category], upgrade)
		end

		local clip_base = weapon_tweak_data.CLIP_AMMO_MAX
		local clip_mod = extra_ammo and (extra_ammo) or 0
		local clip_skill = managers.player:upgrade_value(weapon_id, "clip_ammo_increase")

		if not upgrade_blocked("weapon", "clip_ammo_increase") then
			clip_skill = clip_skill + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
		end

		for _, category in ipairs(weapon_tweak_data.categories) do
			if not upgrade_blocked(category, "clip_ammo_increase") then
				clip_skill = clip_skill + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
			end
		end

		return clip_base + clip_mod + clip_skill
	end

	local ammo_max_per_clip = get_ammo_max_per_clip(weapon_id)
	local ammo_max = tweak_data.weapon[weapon_id].AMMO_MAX
	local ammo_from_mods = 0 --ammo_max -- * (total_ammo_mod and tweak_data.weapon.stats.total_ammo_mod--[total_ammo_mod]
	 or 0--)
	ammo_max = (ammo_max + ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier
	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)
	local ammo_data = {
		base = tweak_data.weapon[weapon_id].AMMO_MAX,
		mod = ammo_from_mods + managers.player:upgrade_value(weapon_id, "clip_amount_increase") * ammo_max_per_clip
	}
	ammo_data.skill = (ammo_data.base + ammo_data.mod) * ammo_max_multiplier - ammo_data.base - ammo_data.mod
	ammo_data.skill_in_effect = false --managers.player:has_category_upgrade("player", "extra_ammo_multiplier") or category_skill_in_effect or managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul")

	return ammo_max_per_clip, ammo_max, ammo_data
end
