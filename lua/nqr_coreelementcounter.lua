core:module("CoreElementCounter")
core:import("CoreMissionScriptElement")
core:import("CoreClass")



ElementCounter = ElementCounter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCounter:init(...)
	ElementCounter.super.init(self, ...)

	self._digital_gui_units = {}
	self._triggers = {}



    if not self._values then return end

    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        arm_for = { logic_counter_023 = 3, },
        nail = { all_ingredients = 2, },
        --peta = { count_to_13 = 4,},
        peta2 = { count_to_13 = 1, },
    }

    self._values.counter_target = (lookup[job] and lookup[job][self._editor_name]) or self._values.counter_target
end



ElementCounterTrigger = ElementCounterTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCounterTrigger:init(...)
	ElementCounterTrigger.super.init(self, ...)



    if not self._values then return end

    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        bph = { check_amount_deathwish = 15 },
        flat = { ["10_snipers_killed"] = 7 },
        family = { logic_counter_trigger_004 = 4, logic_counter_trigger_003 = 4, logic_counter_trigger_002 = 4, logic_counter_trigger_001 = 2 },
    }

    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end



ElementCounterFilter = ElementCounterFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCounterFilter:init(...)
	ElementCounterFilter.super.init(self, ...)



    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        haunted = { filter_BD_ovk = 1, filter_BD_very_hard = 1 },
    }

    self._values.value = (lookup[job] and lookup[job][self._editor_name]) or self._values.value
end



ElementCounterOperator = ElementCounterOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementCounterOperator:init(...)
	ElementCounterOperator.super.init(self, ...)



    if not self._values then return end

    local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        chca = { set_bag_number_8 = 4 },
        family = { set8 = 4, set6 = 4, set006 = 4, set3 = 2, set014 = 2 },
        firestarter_1 = { logic_counter_operator_009 = 4, logic_counter_operator_004 = 4 },
        crojob2 = { random_circuit_breakers_SET_5 = 2, random_circuit_breakers_SET_4 = 2, random_circuit_breakers_SET_3 = 2, random_circuit_breakers_SET_2 = 1 },
        mus = { set_4 = 8 },
        mex = { set12 = 4, set8 = 4, set6 = 4, set4 = 2 },
    }
    if Global.game_settings.difficulty=="normal" then
        lookup.chca.set_bag_number_4 = 2
        lookup.firestarter_1.logic_counter_operator_004 = 2
    end

    self._values.amount = (lookup[job] and lookup[job][self._editor_name]) or self._values.amount
end