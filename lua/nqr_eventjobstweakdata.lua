Hooks:PostHook(EventJobsTweakData, "init", "nqr_EventJobsTweakData:init", function(self, tweak_data)

	for i, k in pairs(self.challenges) do
		if k.id=="cg22_1" then
			k.objectives = {
				tweak_data.safehouse:_progress("cg22_post_objective_1", 200, {
					name_id = "menu_cg22_post_objective_1",
					desc_id = "menu_cg22_post_objective_1_desc"
				}),
			}
		elseif k.id=="cg22_2" then
			k.objectives = {
				self:_choice({
					tweak_data.safehouse:_progress("cg22_personal_2", 50, {
						name_id = "menu_cg22_personal_2",
						desc_id = "menu_cg22_personal_2_desc"
					}),
					tweak_data.safehouse:_progress("cg22_post_objective_2", 15, {
						name_id = "menu_cg22_post_objective_2",
						desc_id = "menu_cg22_post_objective_2_desc"
					})
				}, 1, {
					name_id = "menu_cg22_2_choice_obj",
					choice_id = "cg22_personal_2",
					desc_id = "menu_cg22_post_objective_2_desc"
				})
			}
		elseif k.id=="cg22_3" then
			k.objectives = {
				self:_choice({
					tweak_data.safehouse:_progress("cg22_personal_3", 15, {
						name_id = "menu_cg22_personal_3",
						desc_id = "menu_cg22_personal_3_desc"
					}),
					tweak_data.safehouse:_progress("cg22_post_objective_3", 5, {
						name_id = "menu_cg22_post_objective_3",
						desc_id = "menu_cg22_post_objective_3_desc"
					})
				}, 1, {
					name_id = "menu_cg22_3_choice_obj",
					choice_id = "cg22_personal_3",
					desc_id = "menu_cg22_post_objective_3_desc"
				})
			}
		elseif k.id=="aru_2" then
			k.objectives = {
				tweak_data.safehouse:_progress("aru_2", 10, {
					name_id = "menu_aru_job_2_obj",
					desc_id = "menu_aru_job_2_obj_desc"
				})
			}
			k.rewards = {
				{
					item_entry = "ching",
					type_items = "weapon"
				},
				{
					"safehouse_coins",
					tweak_data.safehouse.rewards.challenge
				}
			}
		elseif k.id=="aru_3" then
			k.desc_id = "menu_aru_job_4_desc"
			k.objectives = {
				tweak_data.safehouse:_progress("aru_3", 20, {
					name_id = "menu_aru_job_3_obj",
					desc_id = "menu_aru_job_3_obj_desc"
				})
			}
			k.rewards = {
				{
					item_entry = "erma",
					type_items = "weapon"
				},
				{
					"safehouse_coins",
					tweak_data.safehouse.rewards.challenge
				}
			}
		elseif k.id=="aru_4" then
			k.desc_id = "menu_aru_job_3_desc"
			k.objectives = {
				tweak_data.safehouse:_progress("aru_4", 50, {
					name_id = "menu_aru_job_4_obj",
					desc_id = "menu_aru_job_4_obj_desc"
				})
			}
		end
	end

end)

Hooks:PostHook(RaidJobsTweakData, "init", "nqr_RaidJobsTweakData:init", function(self, tweak_data)

	for i, k in pairs(self.challenges) do
		if k.id=="aru_1" then
			k.objectives = {
				tweak_data.safehouse:_progress("aru_1", 5, {
					name_id = "menu_aru_job_1_obj",
					desc_id = "menu_aru_job_1_obj_desc"
				})
			}
		elseif k.id=="aru_2" then
			k.objectives = {
				tweak_data.safehouse:_progress("aru_2", 10, {
					name_id = "menu_aru_job_2_obj",
					desc_id = "menu_aru_job_2_obj_desc"
				})
			}
			k.rewards = {
				{
					item_entry = "ching",
					type_items = "weapon"
				},
				{
					"safehouse_coins",
					tweak_data.safehouse.rewards.challenge
				}
			}
		elseif k.id=="aru_3" then
			k.desc_id = "menu_aru_job_4_desc"
			k.objectives = {
				tweak_data.safehouse:_progress("aru_3", 20, {
					name_id = "menu_aru_job_3_obj",
					desc_id = "menu_aru_job_3_obj_desc"
				})
			}
			k.rewards = {
				{
					item_entry = "erma",
					type_items = "weapon"
				},
				{
					"safehouse_coins",
					tweak_data.safehouse.rewards.challenge
				}
			}
		elseif k.id=="aru_4" then
			k.desc_id = "menu_aru_job_3_desc"
			k.objectives = {
				tweak_data.safehouse:_progress("aru_4", 50, {
					name_id = "menu_aru_job_4_obj",
					desc_id = "menu_aru_job_4_obj_desc"
				})
			}
		end
	end

end)