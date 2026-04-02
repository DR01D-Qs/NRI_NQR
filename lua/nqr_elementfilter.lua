core:import("CoreMissionScriptElement")

ElementFilter = ElementFilter or class(CoreMissionScriptElement.MissionScriptElement)

function ElementFilter:init(...)
	ElementFilter.super.init(self, ...)



	local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		bex = {
			logic_filter_012 = { difficulty_hard = false, difficulty_overkill = false, difficulty_overkill145 = false },
			logic_filter_013 = { difficulty_hard = false, difficulty_overkill = false, difficulty_overkill145 = false },
		},
		election_day_2 = {
			diff001 = { difficulty_hard = true },
			diff002 = { difficulty_hard = false, difficulty_overkill145 = true },
		},
		ranc = {
			logic_filter_018 = { difficulty_normal = false, difficulty_hard = false, difficulty_overkill = false },
			logic_filter_019 = { difficulty_normal = true, difficulty_hard = true, difficulty_overkill = true },
		},
	}
	for i, k in pairs((lookup[job] and lookup[job][self._editor_name]) or {}) do self._values[i] = k end
end
