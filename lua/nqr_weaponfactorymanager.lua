--OVERRIDE SUPPORT
function WeaponFactoryManager:get_sound_switch(switch_group, factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local assembled_blueprint = self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	local part = nil

	for _, part_id in ipairs(blueprint) do
		part = self:_part_data(part_id, factory_id, override)

		if not forbidden[part_id] and part.sound_switch and part.sound_switch[switch_group] then
			return self:_part_data(part_id, factory_id, override).sound_switch[switch_group]
		end
	end

	return nil
end



--GET STATS: SUPPORT NEW STATS
function WeaponFactoryManager:get_stats(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)
	local override = self:_get_override_parts(factory_id, blueprint)
	local stats = {}

	for _, part_id in ipairs(blueprint) do
		if not forbidden[part_id] and factory.parts[part_id].stats then
			local part = self:_part_data(part_id, factory_id, override)

			for stat_type, value in pairs(part.stats) do
				if type(value) == "number" then
					stats[stat_type] = (stats[stat_type] or 0) + value
				elseif type(value) == "string" then
					stats[stat_type] = value
				elseif type(value) == "table" then
					stats[stat_type] = stats[stat_type] or {}
					for i, k in pairs(value) do
						if type(k)~="number" then
							stats[stat_type][i] = k
						else
							stats[stat_type][i] = (stats[stat_type][i] or 0) + k
						end
					end
				end
			end
		end
	end

	return stats
end

function WeaponFactoryManager:_get_forbidden_parts(factory_id, blueprint, log)
	local factory = tweak_data.weapon.factory
	local forbidden = {}
	local override = self:_get_override_parts(factory_id, blueprint)

	for _, part_id in ipairs(blueprint) do
		if self:is_part_valid(part_id) then
			local part = self:_part_data(part_id, factory_id, override)

			if part.depends_on then
				local part_forbidden = true

				for _, other_part_id in ipairs(blueprint) do
					local other_part = self:_part_data(other_part_id, factory_id, override)

					if part.depends_on == other_part.type then
						part_forbidden = false

						break
					end
				end

				if part_forbidden then
					forbidden[part_id] = part.depends_on
				end
			end

			if part.forbids then
				for _, forbidden_id in ipairs(part.forbids) do
					forbidden[forbidden_id] = part_id
				end
			end

			if part.adds then
				local add_forbidden = self:_get_forbidden_parts(factory_id, part.adds)

				for forbidden_id, part_id in pairs(add_forbidden) do
					forbidden[forbidden_id] = part_id
				end
			end
		else
			Application:error("[WeaponFactoryManager:_get_forbidden_parts] Part do not exist!", part_id, "factory_id", factory_id)

			forbidden[part_id] = part_id
		end
	end

	return forbidden
end

function WeaponFactoryManager:_get_override_parts(factory_id, blueprint)
	local factory = tweak_data.weapon.factory
	local overridden = {}
	local override_override = {}

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				if override_data.override then
					override_override[override_id] = override_data
				end
			end
		end
	end

	for _, part_id in ipairs(blueprint) do
		local part = self:_part_data(part_id, factory_id, override_override)

		if part and part.override then
			for override_id, override_data in pairs(part.override) do
				overridden[override_id] = override_data
			end
		end

	end

	return overridden
end

function WeaponFactoryManager:can_add_part(factory_id, part_id, blueprint)
	local new_blueprint = deep_clone(blueprint)

	table.insert(new_blueprint, part_id)

	local forbidden = self:_get_forbidden_parts(factory_id, new_blueprint, true)

	for forbid_part_id, forbidder_part_id in pairs(forbidden) do
		if forbid_part_id == part_id then
			return forbidder_part_id
		end
	end

	return nil
end



function WeaponFactoryManager:_part_data(part_id, factory_id, override)
	local factory = tweak_data.weapon.factory

	if not self:is_part_valid(part_id) then
		Application:error("[WeaponFactoryManager:_part_data] Part do not exist!", part_id, "factory_id", factory_id)

		return {}
	end

	local part = deep_clone(factory.parts[part_id])

	if factory[factory_id].override and factory[factory_id].override[part_id] then
		for d, v in pairs(factory[factory_id].override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	if override and override[part_id] then
		for d, v in pairs(override[part_id]) do
			part[d] = type(v) == "table" and deep_clone(v) or v
		end
	end

	return part
end



--REMOVE STINKY Y STANCE_MOD OF SIGHTS
function WeaponFactoryManager:get_stance_mod(factory_id, blueprint, using_second_sight)
	local factory = tweak_data.weapon.factory
	local wep_factory = tweak_data.weapon.factory[factory_id]
	local assembled_blueprint = self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, assembled_blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	local part = nil
	local translation = Vector3()
	local rotation = Rotation()
	local is_not_sight_type, is_weapon_sight, is_second_sight = nil
	local second_sight_id = using_second_sight

	local has_main_sight = nil
	local has_ironsight_extrable = nil
	local using_stance_mod = nil
	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			local part = self:_part_data(part_id, factory_id, override)
			has_main_sight = has_main_sight or (part.type=="sight" and not part.blank_sight and part.sub_type~="ironsight")
			has_ironsight_extrable = has_ironsight_extrable or (part.sub_type=="ironsight_extrable")
			using_stance_mod = using_stance_mod or (part.stats and part.stats.use_stance_mod)
		end
	end

	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			part = self:_part_data(part_id, factory_id, override)

			if part.stance_mod or (part.stats and (part.stats.sightheight or part.stats.sightpos)) then
				is_ironsight = part.type=="ironsight" or part.sub_type=="ironsight"

				is_not_sight_type = part.type~="sight" and part.type~="second_sight" and part.sub_type~="second_sight" or false
				is_weapon_sight = not second_sight_id and (part.type=="sight" and not part.blank_sight) or is_ironsight or false
				is_second_sight = second_sight_id and part_id==second_sight_id or false

				if (is_not_sight_type or is_weapon_sight or is_second_sight) and ((part.stance_mod and part.stance_mod[factory_id]) or (part.stats and (part.stats.sightheight or part.stats.sightpos))) then
					local part_translation = (
						(part.stats and part.stats.sightpos) and Vector3(part.stats.sightpos[1], 0, part.stats.sightpos[2])
						or ((part.stats and part.stats.sightheight) and Vector3(0, 0, -part.stats.sightheight))
					) or (part.stance_mod and part.stance_mod[factory_id] and part.stance_mod[factory_id].translation)

					local sm = part.stance_mod and part.stance_mod[factory_id] and part.stance_mod[factory_id].translation
					part_translation = (
						using_stance_mod
						and (sm and Vector3(sm.x, 0, sm.z))
						or part_translation
					)

					if part.stats and part.stats.use_stance_mod and wep_factory.sightheight_mod then
						part_translation = part_translation + Vector3(0,0,-wep_factory.sightheight_mod)
					end

					if part_translation then
						if (
							not ((is_ironsight and (has_main_sight or using_second_sight)))
							and not (part.type=="extra" and using_stance_mod)
							and not (not has_main_sight and not is_ironsight and not using_second_sight)
						) then
							mvector3.add(translation, part_translation)
						end
					end

					local part_rotation = part.stats and part.stats.sightpos and math.string_to_rotation(CoreMath.vector_to_string(Vector3(0, 0, part.stats.sightpos[3]==-45 and -NQR.settings.nqr_secondsightangle_value or part.stats.sightpos[3]))) or (part.stance_mod and part.stance_mod[factory_id] and part.stance_mod[factory_id].rotation)
					if part_rotation then mrotation.multiply(rotation, part_rotation) end
				end
			end
		end
	end

	return { translation = translation, rotation = rotation }
end



function WeaponFactoryManager:_assemble(factory_id, p_unit, blueprint, third_person, npc, done_cb, skip_queue)
	if not done_cb then
		Application:error("-----------------------------")
		Application:stack_dump()
	end

	local factory = tweak_data.weapon.factory
	local factory_weapon = factory[factory_id]
	local forbidden = self:_get_forbidden_parts(factory_id, blueprint)



	return self:_add_parts(p_unit, factory_id, factory_weapon, blueprint, forbidden, third_person, npc, done_cb, skip_queue)
end