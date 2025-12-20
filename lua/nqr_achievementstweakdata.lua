Hooks:PostHook(AchievementsTweakData, "init", "nqr_AchievementsTweakData:init", function(self, tweak_data)

	self.enemy_kill_achievements.aru_3.weapons = { "ching" }
	self.enemy_kill_achievements.aru_4.weapons = { "erma" }

	self.enemy_kill_achievements.cg22_personal_2.mutators = nil
	self.enemy_kill_achievements.cg22_personal_3.mutators = nil
	self.enemy_kill_achievements.cg22_personal_3.difficulty = nil

	self.weapon_part_tracker = {}

end)