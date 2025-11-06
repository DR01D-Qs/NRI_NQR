core:module("CoreLocalizationManager")
core:import("CoreClass")
core:import("CoreEvent")

LocalizationManager = LocalizationManager or CoreClass.class()

function LocalizationManager:text(string_id, macros)
	local return_string = "ERROR: " .. tostring(string_id)
	local str_id = nil

	if not string_id or string_id == "" or type(string_id) ~= "string" then
		return_string = ""
	elseif self:exists(string_id .. "_" .. self._platform) then
		str_id = string_id .. "_" .. self._platform
	elseif self:exists(string_id) then
		str_id = string_id
	end

	if str_id then
		self._macro_context = macros
		return_string = Localizer:lookup(Idstring(str_id))
		self._macro_context = nil

		if string.find(str_id, "hud_v_four_stores_mission2") then
			return_string = string.gsub(return_string, "15", "150")
		end
	end

	return return_string
end