core:import("CoreMissionScriptElement")

ElementExplosion = ElementExplosion or class(ElementFeedback)

function ElementExplosion:init(...)
	ElementExplosion.super.init(self, ...)

	if Application:editor() and self._values.explosion_effect ~= "none" then
		CoreEngineAccess._editor_load(self.IDS_EFFECT, self._values.explosion_effect:id())
	end

	local job = Global.level_data and Global.level_data.level_id
    local lookup = {
        short2_stage2b = { point_explosion_001 = { player_damage = 4, }, },
    }

    for i, k in pairs(lookup[job] and lookup[job][self._editor_name] or {}) do
		self._values[i] = k
	end
end