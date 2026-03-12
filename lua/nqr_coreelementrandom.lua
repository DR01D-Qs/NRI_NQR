core:module("CoreElementRandom")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementRandom = ElementRandom or class(CoreMissionScriptElement.MissionScriptElement)

function ElementRandom:init(...)
	ElementRandom.super.init(self, ...)

	self._original_on_executed = CoreTable.clone(self._values.on_executed)



    local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		framing_frame_3 = { [104685] = { base_delay = 15 } },
		election_day_1 = { [102675] = { base_delay = 15 } },
		crojob2 = { [104665] = { base_delay = 15 } },
	}
	for i, k in pairs(lookup[job] or {}) do
		for u, j in pairs(k or {}) do
			if self._mission_script and self._mission_script._elements and self._mission_script._elements[i]  and self._mission_script._elements[i]._values then
				self._mission_script._elements[i]._values[u] = j
			end
		end
	end
end

function ElementRandom:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self._unused_randoms = {}

	for i, element_data in ipairs(self._original_on_executed) do
		if not self._values.ignore_disabled or self._values.ignore_disabled and self:get_mission_element(element_data.id):enabled() then
			table.insert(self._unused_randoms, i)
		end
	end

	self._values.on_executed = {}
	local amount = self:_calc_amount()

	if self._values.counter_id then
		local element = self:get_mission_element(self._values.counter_id)
		amount = element:counter_value()
	end



    local job = Global.level_data and Global.level_data.level_id
	local difficulty = Global.game_settings.difficulty
	local lookup_amount = {
		nail = { random_mu_drops = 2, random_cs_drops = 2, random_hcl_drops = 2 },
		framing_frame_3 = { logic_random_018 = difficulty=="normal" and 1 or 2 },
		election_day_1 = { select_additional = difficulty=="normal" and 0 or 1 },
		crojob3 = { random_wagon_door_open = 0 },
	}
	amount = lookup_amount[job] and lookup_amount[job][self._editor_name] or amount

	for i = 1, math.min(amount, #self._original_on_executed) do
		table.insert(self._values.on_executed, self._original_on_executed[self:_get_random_elements()])
	end

	ElementRandom.super.on_executed(self, instigator)
end