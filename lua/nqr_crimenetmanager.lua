function CrimeNetManager:get_jobs_by_player_stars(span)
	local t = {}
	local pstars = managers.experience:level_to_stars() * 10
	span = span or 20

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local pass_all_tests = true
		pass_all_tests = pass_all_tests and not tweak_data.narrative:is_job_locked(job_id)

		if pass_all_tests then
			local job_data = tweak_data.narrative:job_data(job_id)
			local start_difficulty = job_data.professional and 1 or 0
			local num_difficulties = 3

			for i = start_difficulty, num_difficulties do
				local job_jc = math.clamp(job_data.jc + i * 10, 0, 100)
				local difficulty_id = 2 + i
				local difficulty = tweak_data:index_to_difficulty(difficulty_id)

				if job_jc <= pstars + span and job_jc >= pstars - span then
					table.insert(t, {
						job_jc = job_jc,
						job_id = job_id,
						difficulty_id = difficulty_id,
						difficulty = difficulty,
						marker_dot_color = job_data.marker_dot_color or nil,
						color_lerp = job_data.color_lerp or nil
					})
				end
			end
		else
			print("SKIP DUE TO COOLDOWN OR THE JOB IS WRAPPED INSIDE AN OTHER JOB", job_id)
		end
	end

	return t
end

function CrimeNetManager:_get_jobs_by_jc()
	local t = {}
	local plvl = managers.experience:current_level()
	local prank = managers.experience:current_rank()

	for _, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local is_cooldown_ok = managers.job:check_ok_with_cooldown(job_id)
		local is_not_wrapped = not tweak_data.narrative.jobs[job_id].wrapped_to_job
		local dlc = tweak_data.narrative:job_data(job_id).dlc
		local is_not_dlc_or_got = not dlc or managers.dlc:is_dlc_unlocked(dlc)
		local pass_all_tests = is_cooldown_ok and is_not_wrapped and is_not_dlc_or_got
		pass_all_tests = pass_all_tests and not tweak_data.narrative:is_job_locked(job_id)

		if pass_all_tests then
			local job_data = tweak_data.narrative:job_data(job_id)
			local start_difficulty = job_data.professional and 1 or 0
			local num_difficulties = 3

			for i = start_difficulty, num_difficulties do
				local job_jc = math.clamp(job_data.jc + i * 10, 0, 100)
				local difficulty_id = 2 + i
				local difficulty = tweak_data:index_to_difficulty(difficulty_id)
				local level_lock = tweak_data.difficulty_level_locks[difficulty_id] or 0
				local is_not_level_locked = prank >= 1 or level_lock <= plvl

				if is_not_level_locked then
					t[job_jc] = t[job_jc] or {}

					table.insert(t[job_jc], {
						job_id = job_id,
						difficulty_id = difficulty_id,
						difficulty = difficulty,
						marker_dot_color = job_data.marker_dot_color or nil,
						color_lerp = job_data.color_lerp or nil
					})
				end
			end
		else
			print("SKIP DUE TO COOLDOWN OR THE JOB IS WRAPPED INSIDE AN OTHER JOB", job_id)
		end
	end

	return t
end

function CrimeNetGui:patch_job_gui(job_gui_result)
	job_gui_result.side_panel:child("stars_panel"):clear()

	if job_gui_result.job_id then
		local x = 0
		local y = 0
		local difficulty_stars = job_gui_result.difficulty_id - 2
		local start_difficulty = 1
		local num_difficulties = 3

		for i = start_difficulty, num_difficulties do
			job_gui_result.side_panel:child("stars_panel"):bitmap({
				texture = "guis/textures/pd2/cn_miniskull",
				h = 16,
				layer = 0,
				w = 12,
				x = x,
				y = y,
				texture_rect = {
					0,
					0,
					12,
					16
				},
				alpha = difficulty_stars < i and 0.5 or 1,
				blend_mode = difficulty_stars < i and "normal" or "add",
				color = difficulty_stars < i and Color.black or tweak_data.screen_colors.risk
			})

			x = x + 11
		end
	end
end

local orig_create_job_gui = CrimeNetGui._create_job_gui
function CrimeNetGui:_create_job_gui(data, type, fixed_x, fixed_y, fixed_location)
	local result = orig_create_job_gui(self, data, type, fixed_x, fixed_y, fixed_location)
	self:patch_job_gui(result)

	return result
end