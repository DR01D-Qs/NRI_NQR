Hooks:PreHook(Setup, "init_managers", "nqr_Setup:init_managers", function(self, managers)
	Global.game_settings = Global.game_settings or {
		is_playing = false,
		auto_kick = true,
		drop_in_option = 1,
		permission = "public",
		job_plan = -1,
		search_modded_lobbies = true,
		search_appropriate_jobs = true,
		gamemode = "standard",
		drop_in_allowed = true,
		reputation_permission = 0,
		difficulty = "normal",
		team_ai_option = 1,
		--team_ai = false,
		kick_option = 1,
		one_down = false,
		allow_modded_players = true,
		search_one_down_lobbies = false,
		level_id = managers.dlc:is_trial() and "bank_trial" or "branchbank"
	}
end)