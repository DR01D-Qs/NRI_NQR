core:import("CoreMissionScriptElement")

ElementDifficulty = ElementDifficulty or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDifficulty:init(...)
	ElementDifficulty.super.init(self, ...)

	local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		pent = { diff_85 = 0.75, diff_20 = 0.01, diff_10 = 0.25, diff_085 = 0.75, },
	}
	self._values.difficulty = (lookup[job] and lookup[job][self._editor_name]) or self._values.difficulty
end

function ElementDifficulty:on_executed(instigator)
	if not self._values.enabled or self._values.difficulty==0.01 then
		return
	end

	managers.groupai:state():set_difficulty(self._values.difficulty)
	ElementDifficulty.super.on_executed(self, instigator)
end