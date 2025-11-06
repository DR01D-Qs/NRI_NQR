core:module("CoreElementInstance")
core:import("CoreMissionScriptElement")
ElementInstanceParams = ElementInstanceParams or class(CoreMissionScriptElement.MissionScriptElement)
ElementInstanceSetParams = ElementInstanceSetParams or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstanceSetParams:_apply_instance_params()
	if self._values and self._values.params then
		if self._values.params.var_objective=="arena_mission_9" then
			self._values.params.var_amount_normal = 2
			self._values.params.var_amount_hard = 4
			self._values.params.var_amount_very_hard = 4
			self._values.params.var_amount_overkill = 4
			self._values.params.var_amount_death_wish = 4
		elseif self._values.params.var_objective=="nail_3" then
			self._values.params.var_amount_normal = 2
			self._values.params.var_amount_hard = 2
			self._values.params.var_amount_very_hard = 2
			self._values.params.var_amount_overkill = 2
			self._values.params.var_amount_death_wish = 2
		elseif self._values.params.var_objective=="dah_11" then
			self._values.params.var_amount_normal = 2
			self._values.params.var_amount_hard = 4
			self._values.params.var_amount_very_hard = 4
			self._values.params.var_amount_overkill = 4
			self._values.params.var_amount_death_wish = 4
		elseif self._values.params.var_objective=="friend_loud_08" then
			self._values.params.var_amount_normal = 2
			self._values.params.var_amount_hard = 4
			self._values.params.var_amount_very_hard = 4
			self._values.params.var_amount_overkill = 4
			self._values.params.var_amount_death_wish = 4
		elseif self._values.params.var_objective=="dinner_hide" then
			self._values.params.var_amount_normal = 2
			self._values.params.var_amount_hard = 4
			self._values.params.var_amount_very_hard = 4
			self._values.params.var_amount_overkill = 4
			self._values.params.var_amount_death_wish = 4
		end
	end

	if self._values.instance then
		managers.world_instance:set_instance_params(self._values.instance, self._values.params)
	elseif Application:editor() then
		managers.editor:output_error("[ElementInstanceSetParams:_apply_instance_params()] No instance defined in [" .. self._editor_name .. "]")
	end
end

ElementInstancePoint = ElementInstancePoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementInstancePoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self:_create()
	ElementInstancePoint.super.on_executed(self, instigator)
end

function ElementInstancePoint:_create()
	if self._has_created then
		return
	end

	self._has_created = true

	if Network:is_server() then
		self._mission_script:add_save_state_cb(self._id)
	end

	if self._values.instance then
		managers.world_instance:custom_create_instance(self._values.instance, {
			position = self._values.position,
			rotation = self._values.rotation
		})
	elseif Application:editor() then
		managers.editor:output_error("[ElementInstancePoint:_create()] No instance defined in [" .. self._editor_name .. "]")
	end
end