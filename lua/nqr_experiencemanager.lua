ExperienceManager = ExperienceManager or class()
ExperienceManager.LEVEL_CAP = Application:digest_value(100, true)

function ExperienceManager:get_xp_by_params(params)
	local job_id = params.job_id
	local job_stars = params.job_stars or 0
	local difficulty_stars = params.difficulty_stars or params.risk_stars or 0
	local job_and_difficulty_stars = job_stars + difficulty_stars
	local job_data = tweak_data.narrative:job_data(job_id)
	local job_mul = job_data and job_data.experience_mul and job_data.experience_mul[difficulty_stars + 1] or 1
	local success = params.success
	local num_winners = params.num_winners or 1
	local on_last_stage = params.on_last_stage
	local personal_win = params.personal_win
	local player_stars = params.player_stars or managers.experience:level_to_stars() or 0
	local level_id = params.level_id or false
	local ignore_heat = params.ignore_heat
	local current_job_stage = params.current_stage or 1
	local days_multiplier = params.professional and tweak_data:get_value("experience_manager", "pro_day_multiplier", current_job_stage) or tweak_data:get_value("experience_manager", "day_multiplier", current_job_stage)
	local pro_job_multiplier = params.professional and tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
	local ghost_multiplier = 1 + (managers.job:get_ghost_bonus() or 0)
	local total_stars = math.min(job_stars, player_stars)
	local total_difficulty_stars = difficulty_stars
	local xp_multiplier = managers.experience:get_contract_difficulty_multiplier(total_difficulty_stars)
	local contract_xp = 0
	local total_xp = 0
	local stage_xp_dissect = 0
	local job_xp_dissect = 0
	local level_limit_dissect = 0
	local risk_dissect = 0
	local failed_level_dissect = 0
	local personal_win_dissect = 0
	local alive_crew_dissect = 0
	local skill_dissect = 0
	local base_xp = 0
	local days_dissect = 0
	local job_heat_dissect = 0
	local base_heat_dissect = 0
	local risk_heat_dissect = 0
	local ghost_dissect = 0
	local ghost_base_dissect = 0
	local ghost_risk_dissect = 0
	local infamy_dissect = 0
	local extra_bonus_dissect = 0
	local gage_assignment_dissect = 0
	local mission_xp_dissect = 0
	local mission_xp_kills_dissect = 0
	local pro_job_xp_dissect = 0
	local bonus_xp = 0
	local bonus_mutators_dissect = 0

	if success and on_last_stage then
		job_xp_dissect = managers.experience:get_job_xp_by_stars(total_stars) * job_mul
		level_limit_dissect = level_limit_dissect + managers.experience:get_job_xp_by_stars(job_stars) * job_mul
		mission_xp_dissect = params.mission_xp or self:mission_xp()
		mission_xp_kills_dissect = params.mission_xp_kills or self:mission_xp_kills()
	end

	local static_stage_experience = level_id and tweak_data.levels[level_id].static_experience
	static_stage_experience = static_stage_experience and static_stage_experience[difficulty_stars + 1]
	stage_xp_dissect = static_stage_experience or managers.experience:get_stage_xp_by_stars(total_stars)
	level_limit_dissect = level_limit_dissect + (static_stage_experience or managers.experience:get_stage_xp_by_stars(job_stars))

	base_xp = job_xp_dissect + stage_xp_dissect + mission_xp_dissect
	pro_job_xp_dissect = math.round(base_xp * pro_job_multiplier - base_xp)
	base_xp = base_xp + pro_job_xp_dissect
	days_dissect = math.round(base_xp * days_multiplier - base_xp)
	local is_level_limited = player_stars < job_stars

	if is_level_limited then
		local diff_in_stars = job_stars - player_stars
		local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
		local old_base_xp = base_xp
		base_xp = math.round(base_xp * tweak_multiplier)
		level_limit_dissect = base_xp - old_base_xp
	end

	contract_xp = base_xp
	risk_dissect = math.round(contract_xp * xp_multiplier)
	contract_xp = contract_xp + risk_dissect

	if not success then
		local multiplier = tweak_data:get_value("experience_manager", "stage_failed_multiplier") or 1
		failed_level_dissect = math.round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + failed_level_dissect
	elseif not personal_win then
		local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
		personal_win_dissect = math.round(contract_xp * multiplier - contract_xp)
		contract_xp = contract_xp + personal_win_dissect
	end

	total_xp = contract_xp
	local total_contract_xp = total_xp
	bonus_xp = managers.player:get_skill_exp_multiplier(managers.groupai and managers.groupai:state():whisper_mode())
	skill_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + skill_dissect
	bonus_xp = managers.player:get_infamy_exp_multiplier()
	infamy_dissect = math.round(total_contract_xp * bonus_xp - total_contract_xp)
	total_xp = total_xp + infamy_dissect

	if success then
		local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
		alive_crew_dissect = math.round(total_contract_xp * num_players_bonus - total_contract_xp)
		total_xp = total_xp + alive_crew_dissect
	end

	total_xp = total_xp + gage_assignment_dissect
	total_xp = total_xp + mission_xp_kills_dissect
	ghost_dissect = math.round(total_xp * ghost_multiplier - total_xp)
	total_xp = total_xp + ghost_dissect
	local heat_xp_mul = ignore_heat and 1 or math.max(managers.job:get_job_heat_multipliers(job_id), 0)
	job_heat_dissect = math.round(total_xp * heat_xp_mul - total_xp)
	total_xp = total_xp + job_heat_dissect
	bonus_xp = managers.player:get_limited_exp_multiplier(job_id, level_id)
	extra_bonus_dissect = math.round(total_xp * bonus_xp - total_xp)
	total_xp = total_xp + extra_bonus_dissect

	local piggybank_rewards = tweak_data.mutators.piggybank.rewards
	local pig_level = false
	if managers.mutators:is_mutator_active(MutatorPiggyBank) then
		local piggybank_mutator = managers.mutators:get_mutator(MutatorPiggyBank)
		pig_level = piggybank_mutator:get_exploded_pig_level()
	end
	local bonus_piggybank_dissect = math.round(pig_level and (piggybank_rewards[Global.game_settings.difficulty] or piggybank_rewards.default) * tweak_data.mutators.piggybank.pig_levels[pig_level].bag_requirement or 0)
	total_xp = total_xp + bonus_piggybank_dissect
	local bonus_cg22_dissect = 0
	if managers.mutators:is_mutator_active(MutatorCG22) then
		local cg22_mutator = managers.mutators:get_mutator(MutatorCG22)
		bonus_cg22_dissect = math.round(cg22_mutator:get_xp_collected())
	end
	total_xp = total_xp + bonus_cg22_dissect

	local bonus_mutators_dissect = total_xp * managers.mutators:get_experience_reduction() * -1
	total_xp = total_xp + bonus_mutators_dissect
	local bonus_event_double_dissect = managers.mutators:is_mutator_active(MutatorCG22) and total_xp or 0
	total_xp = total_xp + bonus_event_double_dissect
	local dissection_table = {
		bonus_risk = math.round(risk_dissect),
		bonus_num_players = math.round(alive_crew_dissect),
		bonus_failed = math.round(failed_level_dissect),
		bonus_low_level = math.round(level_limit_dissect),
		bonus_skill = math.round(skill_dissect),
		bonus_days = math.round(days_dissect),
		bonus_pro_job = math.round(pro_job_xp_dissect),
		bonus_infamy = math.round(infamy_dissect),
		bonus_extra = math.round(extra_bonus_dissect),
		in_custody = math.round(personal_win_dissect),
		heat_xp = math.round(job_heat_dissect),
		bonus_ghost = math.round(ghost_dissect),
		bonus_gage_assignment = math.round(gage_assignment_dissect),
		bonus_mission_xp = math.round(mission_xp_dissect),
		bonus_mission_xp_kills = math.round(mission_xp_kills_dissect),
		bonus_mutators = math.round(bonus_mutators_dissect),
		bonus_event_double = math.round(bonus_event_double_dissect),
		bonus_piggybank = math.round(bonus_piggybank_dissect),
		bonus_cg22 = math.round(bonus_cg22_dissect),
		stage_xp = math.round(stage_xp_dissect),
		job_xp = math.round(job_xp_dissect),
		base = math.round(base_xp),
		total = math.round(total_xp),
		last_stage = on_last_stage
	}

	if Application:production_build() then
		local rounding_error = dissection_table.total - (dissection_table.stage_xp
			+ dissection_table.job_xp
			+ dissection_table.bonus_risk
			+ dissection_table.bonus_num_players
			+ dissection_table.bonus_failed
			+ dissection_table.bonus_skill
			+ dissection_table.bonus_days
			+ dissection_table.heat_xp
			+ dissection_table.bonus_infamy
			+ dissection_table.bonus_ghost
			+ dissection_table.bonus_gage_assignment
			+ dissection_table.bonus_mission_xp
			+ dissection_table.bonus_mission_xp_kills
			+ dissection_table.bonus_low_level
		)
		dissection_table.rounding_error = rounding_error
	else
		dissection_table.rounding_error = 0
	end

	return math.round(total_xp), dissection_table
end

function ExperienceManager:mission_xp_award_kills(amount)
	if amount > 0 then
		local current_xp = self._global.mission_xp_kills and Application:digest_value(self._global.mission_xp_kills, false) or 0
		self._global.mission_xp_kills = Application:digest_value(current_xp + amount, true)
	end
end
function ExperienceManager:mission_xp_kills()
	local current_xp_kills = self._global.mission_xp_kills and Application:digest_value(self._global.mission_xp_kills, false) or 0

	return current_xp_kills
end
function ExperienceManager:mission_xp_clear()
	self._global.mission_xp_total = nil
	self._global.mission_xp_current = nil
	self._global.mission_xp_kills = nil
end



function ExperienceManager:add_points(points, present_xp, debug)
	if not debug and managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	if points <= 0 then
		return
	end

	if not managers.dlc:has_full_game() and self:current_level() >= 10 then
		self:_set_total(self:total() + points)
		self:_set_next_level_data_current_points(0)
		self:present()
		managers.statistics:aquired_money(points)

		return points
	end

	if self:level_cap() <= self:current_level() then
		self:_set_total(self:total() + points)
		managers.statistics:aquired_money(points)

		if self:current_rank() > 0 then
			self:set_current_prestige_xp(self:get_current_prestige_xp() + points)
		end

		return points
	end

	if present_xp then
		self:_present_xp(points)
	end

	local points_left = self:next_level_data_points() - self:next_level_data_current_points()

	if points < points_left then
		self:_set_total(self:total() + points)
		self:_set_xp_gained(self:total())
		self:_set_next_level_data_current_points(self:next_level_data_current_points() + points)
		self:present()
		managers.statistics:aquired_money(points)

		return
	end

	self:_set_total(self:total() + points_left)
	self:_set_xp_gained(self:total())
	self:_set_next_level_data_current_points(self:next_level_data_current_points() + points_left)
	self:present()
	self:_level_up()
	managers.statistics:aquired_money(points_left)

	return self:add_points(points - points_left, present_xp, debug)
end

function ExperienceManager:_set_total(value)
	self._global.total = Application:digest_value(value, true)
end