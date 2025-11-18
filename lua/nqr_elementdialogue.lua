core:import("CoreMissionScriptElement")

ElementDialogue = ElementDialogue or class(CoreMissionScriptElement.MissionScriptElement)
ElementDialogue.MutedDialogs = {
	"pln_",
	"play_pln_",
	"btc_",
	"play_btc_",
	"vld_",
	"play_vld_",
	"plt_",
	"play_plt_",
	"dr1_",
	"play_dr1_",
	"dr2_",
	"play_dr2_",
	"pyr_",
	"play_pyr_",
	"dlr_",
	"play_dlr_",
	"rb5_",
	"play_rb5_",
	"ope_",
	"play_ope_",
	"pt1_",
	"play_pt1_",
	"pt2_",
	"play_pt2_",
	"crn_",
	"play_crn_",
	"hnc_",
	"play_hnc_",
	"cpn_",
	"play_cpn_",
	"zep_",
	"play_zep_",
	"drv_",
	"play_drv_",
	"loc_",
	"play_loc_",
	"brs_",
	"play_brs_",
	"cpg_",
	"play_cpg_",
	"mga_",
	"play_mga_",
	"bot_",
	"play_bot_",
	"snp_",
	"play_snp_",
	"com_",
	"play_com_"
}

function ElementDialogue:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.play_on_player_instigator_only and instigator ~= managers.player:player_unit() then
		ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)

		return
	end

    local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		escape_park = {
			["time_limit_1"] = "none",
			["time_limit_10sec"] = "none",
			["time_limit_10sec001"] = "none",
			["time_limit_2"] = "none",
			["time_limit_3"] = "none",
			["time_limit_30sec"] = "none",
			["time_limit_4"] = "none",
			["time_limit_5"] = "none",
		},
		escape_cafe = {
			["10sec"] = "none",
			["10sec001"] = "none",
			["1min_VAN"] = "none",
			["2min_VAN"] = "none",
			["30sec_VAN"] = "none",
			["3min_VAN"] = "none",
			["4min"] = "none",
			["5min"] = "none",
		},
		escape_street = {
			["2min"] = "none",
			["3min"] = "none",
			["4min"] = "none",
			["5min"] = "none",
		},
		escape_street = {
			["2min"] = "none",
			["3min"] = "none",
			["4min"] = "none",
			["5min"] = "none",
		},
		escape_overpass = {
			["leaving_in_1min_HELI"] = "none",
			["leaving_in_1min_VAN"] = "none",
			["leaving_in_2min"] = "none",
			["leaving_in_30sec_HELI"] = "none",
			["leaving_in_30sec_VAN"] = "none",
			["leaving_in_3min"] = "none",
			["leaving_in_4min"] = "none",
			["heli_leave_1min"] = "none",
			["heli_leave_1min001"] = "none",
			["heli_leave_1min002"] = "none",
			["heli_leave_2min"] = "none",
			["heli_leave_2min001"] = "none",
			["van_leave_1min"] = "none",
			["van_leave_1min001"] = "none",
			["van_leave_1min002"] = "none",
			["van_leave_1min003"] = "none",
			["van_leave_2min"] = "none",
			["van_leave_2min001"] = "none",
		},
		escape_garage = {
			["Diag5min"] = "none",
			["Diag4min"] = "none",
			["Diag3min"] = "none",
			["Diag2min"] = "none",
			["Diag2min001"] = "none",
			["Diag1min"] = "none",
			["Diag1min001"] = "none",
			["Diag30sec"] = "none",
			["Diag10sec"] = "none",
			["Diag10sec001"] = "none",
		},
	}
	lookup.escape_cafe_day = deep_clone(lookup.escape_cafe)
	lookup.escape_park_day = deep_clone(lookup.escape_park)
	self._values.dialogue = (lookup[job] and lookup[job][self._editor_name]) or self._values.dialogue

    local lookup = {
		dia_vo_4s_b015 = { dialogue = "pln_fost_en_03" },

		--escape_street lines, as some of them have the same _editor_name's
		pln_esc_01_to_departure_heli = { dialogue = "none" },
		pln_esc_10secs_to_departure_heli = { dialogue = "none" },
		pln_esc_30secs_to_departure_heli = { dialogue = "none" },
    }
	self._values.dialogue = (lookup[self._editor_name] and lookup[self._editor_name].dialogue) or self._values.dialogue

	if self._values.dialogue ~= "none" then
		if self:_can_play() then
			if self._values.force_quit_current then
				managers.dialog:quit_dialog()
			end

			local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator) or nil

			managers.dialog:queue_dialog(self._values.dialogue, {
				case = managers.criminals:character_name_by_unit(instigator),
				done_cbk = done_cbk,
				position = self._values.position,
				skip_idle_check = Application:editor(),
				on_unit = self._values.use_instigator and instigator
			})
		else
			print("[ElementDialogue] Skipping muted dialogue: ", self._values.dialogue)

			local done_cbk = self._values.execute_on_executed_when_done and callback(self, self, "_done_callback", instigator) or nil

			if done_cbk then
				done_cbk()
			end
		end
	elseif Application:editor() then
		managers.editor:output_warning("Dialogue not specified in element " .. self._editor_name .. ".", nil, true)
	end

	ElementDialogue.super.on_executed(self, instigator, nil, self._values.execute_on_executed_when_done)
end