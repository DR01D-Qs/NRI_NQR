core:import("CoreMissionScriptElement")
ElementObjective = ElementObjective or class(CoreMissionScriptElement.MissionScriptElement)

function ElementObjective:init(...)
	ElementObjective.super.init(self, ...)



    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        chca = { objective_activate_objective_027 = 4 },
        arm_for = { activate_objective004 = 4, activate_objective006 = 4 },
        family = { func_objective_003 = 4, func_objective_004 = 4, func_objective_002 = 4, func_objective_001 = 2 },
        jewelry_store = { steal8 = 6, steal6 = 6, steal3 = 3 },
        firestarter_1 = { func_objective_010 = 4, func_objective_009 = 4 },
        mex = {
            objective_activate_006 = 2,
            objective_activate_007 = 2,
            objective_activate_008 = 2,
            objective_activate_009 = 4,
            objective_activate_010 = 4,
            objective_activate_011 = 4,
            objective_activate_012 = 4,
            objective_activate_013 = 4,
            objective_activate_014 = 4,
            objective_activate_015 = 4,
            objective_activate_016 = 4,
            objective_activate_017 = 4,
        },
        trai = {
            func_obj_enter_loot_wagon_6 = 4,
            func_obj_enter_loot_wagon_5 = 3,
            func_obj_enter_loot_wagon_4 = 2,
            func_obj_enter_loot_wagon_3 = 1,
            func_obj_enter_loot_wagon_2 = 0,
        },
        ranc = {
            --fulton nrm
            func_objective_032 = 2,
            func_objective_033 = 1,
            func_objective_034 = 0,
            func_objective_035 = 0,
            func_objective_036 = 0,
            func_objective_037 = 0,

            --fulton ovk
            func_objective_008 = 4,
            func_objective_007 = 3,
            func_objective_006 = 2,
            func_objective_005 = 1,
            func_objective_004 = 0,
            func_objective_003 = 0,
            func_objective_002 = 0,
            func_objective_001 = 0,

            --boat nrm
            func_objective_022 = 2,
            func_objective_023 = 1,
            func_objective_024 = 0,
            func_objective_025 = 0,
            func_objective_026 = 0,
            func_objective_027 = 0,
            func_objective_028 = 0,

            --boat ovk
            func_objective_047 = 4,
            func_objective_046 = 3,
            func_objective_045 = 2,
            func_objective_044 = 1,
            func_objective_043 = 0,
            func_objective_042 = 0,
            func_objective_041 = 0,
            func_objective_040 = 0,
            func_objective_039 = 0,
        },
    }
    if Global.game_settings.difficulty=="normal" then
        lookup.arm_for.activate_objective006 = 2
        lookup.firestarter_1.func_objective_009 = 2
    end

    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end



--[[function ElementObjective:on_executed(instigator)
	if not self._values.enabled then
		return
	end

    log(self._editor_name)

	local objective = self:value("objective")
	local amount = self:value("amount")
	amount = amount and amount > 0 and amount or nil

	if objective ~= "none" then
		if self._values.state == "activate" then
			if self._values.countdown then
				managers.objectives:activate_objective_countdown(objective, nil, {
					amount = amount
				})
			else
				managers.objectives:activate_objective(objective, nil, {
					amount = amount
				})
			end
		elseif self._values.state == "complete_and_activate" then
			managers.objectives:complete_and_activate_objective(objective, nil, {
				amount = amount
			})
		elseif self._values.state == "complete" then
			if self._values.sub_objective and self._values.sub_objective ~= "none" then
				managers.objectives:complete_sub_objective(objective, self._values.sub_objective)
			elseif self._values.countdown then
				managers.objectives:complete_objective_countdown(objective)
			else
				managers.objectives:complete_objective(objective)
			end
		elseif self._values.state == "update" then
			managers.objectives:update_objective(objective)
		elseif self._values.state == "remove" then
			managers.objectives:remove_objective(objective)
		elseif self._values.state == "remove_and_activate" then
			managers.objectives:remove_and_activate_objective(objective, nil, {
				amount = amount
			})
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant operate on objective " .. objective .. " in element " .. self._editor_name .. ".")
	end

	ElementObjective.super.on_executed(self, instigator)
end]]