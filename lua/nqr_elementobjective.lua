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
    }
    if Global.game_settings.difficulty=="normal" then
        lookup.arm_for.activate_objective006 = 2
        lookup.firestarter_1.func_objective_009 = 2
    end

    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end