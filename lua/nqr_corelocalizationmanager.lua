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

		local lookup_delet = {
			["bm_wp_upg_ns_ass_smg_firepig_desc"] = true,
			["bm_wp_upg_ns_ass_smg_stubby_desc"] = true,
			["bm_wp_upg_ns_ass_smg_tank_desc"] = true,
			["bm_wp_upg_ns_shot_shark_desc"] = true,
			["bm_wp_upg_ns_pis_small_desc"] = true,
			["bm_wp_upg_ns_ass_smg_small_desc"] = true,
			["bm_wp_upg_ns_pis_medium_desc"] = true,
			["bm_wp_upg_ns_ass_smg_medium_desc"] = true,
			["bm_wp_upg_ns_pis_large_desc"] = true,
			["bm_wp_upg_ns_ass_smg_large_desc"] = true,
			["bm_wp_upg_ns_shot_thick_desc"] = true,

			["bm_wp_m4_uupg_b_long_desc"] = true,
			["bm_wp_m4_uupg_b_medium_desc"] = true,
			["bm_wp_m4_uupg_b_short_desc"] = true,
			["bm_wp_m4_uupg_b_sd_desc"] = true,
			["bm_wp_74_b_standard_desc"] = true,
			["bm_wp_akm_b_standard_desc"] = true,
			["bm_wp_g36_b_short_desc"] = true,
			["bm_wp_aug_b_long_desc"] = true,
			["bm_wp_aug_b_short_desc"] = true,
			["bm_wp_p90_b_long_desc"] = true,
			["bm_wp_rage_b_comp1_desc"] = true,
			["bm_wp_rage_b_long_desc"] = true,
			["bm_wp_rage_b_short_desc"] = true,
			["bm_wp_rage_b_comp2_desc"] = true,
			["bm_wp_rage_b_comp2_desc"] = true,
			["bm_wp_deagle_co_short_desc"] = true,
			["bm_wp_1911_co_1_desc"] = true,
			["bm_wp_1911_co_2_desc"] = true,
			["bm_wp_g18c_co_1_desc"] = true,
			["bm_wp_g18c_co_comp_2_desc"] = true,
		}
		return_string = lookup_delet[str_id] and "" or return_string

		if string.find(str_id, "hud_v_four_stores_mission2") then
			return_string = string.gsub(return_string, "15", "150")
		elseif string.find(str_id, "menu_cg22_post_objective_1_desc") then
			return_string = string.gsub(return_string, "2000", "200")
		elseif string.find(str_id, "menu_cg22_post_objective_2_desc") then
			return_string = string.gsub(return_string, "150", "15")
			return_string = string.gsub(return_string, self:text("menu_difficulty_very_hard"), string.capitalize(self:text("menu_difficulty_hard")))
		elseif string.find(str_id, "menu_cg22_post_objective_3_desc") then
			return_string = string.gsub(return_string, "1000", "5")
		elseif string.find(str_id, "menu_aru_job_3_obj_desc") then
			return_string = string.gsub(return_string, self:text("bm_w_erma"), self:text("bm_w_ching"))
		elseif string.find(str_id, "menu_aru_job_4_obj_desc") then
			return_string = string.gsub(return_string, self:text("bm_w_ching"), self:text("bm_w_erma"))
		end
	end

	return return_string
end