local curr_diff = Global.game_settings and Global.game_settings.difficulty or "easy"

tweak_data.player.damage.LIVES_INIT = 2

tweak_data.casino.prefer_cost = 1
tweak_data.casino.entrance_fee = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
}
tweak_data.casino.secure_card_cost = {
	1,
	2,
	3,
}

tweak_data.difficulty_name_ids = {
	easy = "menu_difficulty_easy",
	normal = "menu_difficulty_easy",
	hard = "menu_difficulty_normal",
	overkill = "menu_difficulty_hard",
	overkill_145 = "menu_difficulty_overkill",
	easy_wish = "menu_difficulty_easy_wish",
	overkill_290 = "menu_difficulty_apocalypse",
	sm_wish = "menu_difficulty_sm_wish",
}
tweak_data.difficulty_level_locks = {
	0,
	0,
	0,
	0,
	0,
}
tweak_data.difficulties = {
	"easy",
	"normal",
	"hard",
	"overkill",
	"overkill_145",
}
tweak_data.difficulty_name_id = tweak_data.difficulty_name_ids[curr_diff] or tweak_data.difficulty_name_id

tweak_data.experience_manager.difficulty_multiplier = {
	0.5,
	1,
	2,
	0,
	0,
	0,
}
tweak_data.experience_manager.alive_humans_multiplier = {
	[0] = 1,
	1,
	1.05,
	1.1,
	1.15
}
tweak_data.experience_manager.in_custody_multiplier = 0.5

	local multiplier = 1
	local exp_step_start = 1
	local exp_step_end = 100
	local exp_step = 1 / (exp_step_end - exp_step_start)
	local exp_step_last_points = 10000
	local exp_step_curve = 2.4

	for i = exp_step_start, exp_step_end do
		tweak_data.experience_manager.levels[i] = {
			points = Application:digest_value(math.round(((1000000 - exp_step_last_points) * math.pow(exp_step * (i - exp_step_start), exp_step_curve) + exp_step_last_points)*0.001)*1000 * multiplier, true)
		}
	end

tweak_data.projectiles.wpn_prj_jav = nil

tweak_data.projectiles.concussion.damage = 5
tweak_data.projectiles.concussion.player_damage = 3
tweak_data.projectiles.concussion.curve_pow = 0.1
tweak_data.projectiles.concussion.range = 1000
tweak_data.projectiles.concussion.init_timer = 1

tweak_data.projectiles.frag.launch_speed = 350
tweak_data.projectiles.frag_com.launch_speed = 350
tweak_data.projectiles.dada_com.launch_speed = 300
tweak_data.projectiles.concussion.launch_speed = 400
tweak_data.projectiles.wpn_prj_ace.launch_speed = 1750
tweak_data.projectiles.wpn_prj_four.launch_speed = 1500
tweak_data.projectiles.wpn_prj_target.launch_speed = 1250
--tweak_data.projectiles.wpn_prj_hur.launch_speed = 1000
--tweak_data.projectiles.molotov.launch_speed = 250
--tweak_data.projectiles.dynamite.launch_speed = 250
tweak_data.projectiles.fir_com.launch_speed = 300
tweak_data.projectiles.smoke_screen_grenade.launch_speed = 300
tweak_data.projectiles.wpn_gre_electric.launch_speed = 300
tweak_data.projectiles.poison_gas_grenade.launch_speed = 300
--tweak_data.projectiles.xmas_snowball.launch_speed = 1000

tweak_data.projectiles.launcher_frag.damage = 200
tweak_data.projectiles.launcher_frag.launch_speed = 1750
tweak_data.projectiles.launcher_frag.arming_distance = 500
tweak_data.projectiles.launcher_incendiary.launch_speed = 1750
tweak_data.projectiles.launcher_incendiary.arming_distance = 500
tweak_data.projectiles.launcher_frag_m32.launch_speed = 1750
tweak_data.projectiles.launcher_frag_m32.arming_distance = 500
tweak_data.projectiles.launcher_incendiary_m32.launch_speed = 1750
tweak_data.projectiles.launcher_incendiary_m32.arming_distance = 500
tweak_data.projectiles.launcher_frag_china.launch_speed = 1750
tweak_data.projectiles.launcher_frag_china.arming_distance = 500
tweak_data.projectiles.launcher_incendiary_china.launch_speed = 1750
tweak_data.projectiles.launcher_incendiary_china.arming_distance = 500
tweak_data.projectiles.launcher_frag_arbiter.arming_distance = 500
tweak_data.projectiles.launcher_incendiary_arbiter.arming_distance = 500
tweak_data.projectiles.launcher_frag_slap.launch_speed = 1750
tweak_data.projectiles.launcher_frag_slap.arming_distance = 500
tweak_data.projectiles.launcher_incendiary_slap.launch_speed = 1750
tweak_data.projectiles.launcher_incendiary_slap.arming_distance = 500
tweak_data.projectiles.launcher_m203.launch_speed = 1750
tweak_data.projectiles.launcher_m203.arming_distance = 500
tweak_data.projectiles.launcher_electric.arming_distance = 500
tweak_data.projectiles.underbarrel_electric.arming_distance = 500
tweak_data.projectiles.underbarrel_m203_groza.launch_speed = 1750
tweak_data.projectiles.underbarrel_m203_groza.arming_distance = 500
tweak_data.projectiles.launcher_poison.arming_distance = 500
tweak_data.projectiles.launcher_frag_ms3gl.launch_speed = 1750
tweak_data.projectiles.launcher_frag_ms3gl.arming_distance = 500
tweak_data.projectiles.launcher_incendiary_ms3gl.launch_speed = 1750
tweak_data.projectiles.launcher_incendiary_ms3gl.arming_distance = 500
tweak_data.projectiles.launcher_electric_ms3gl.arming_distance = 500
tweak_data.projectiles.launcher_rocket.arming_distance = 500
tweak_data.projectiles.rocket_frag.arming_distance = 500
tweak_data.projectiles.rocket_ray_frag.arming_distance = 500

tweak_data.projectiles.rocket_ray_frag.player_damage = 2
tweak_data.projectiles.rocket_ray_frag.fire_dot_data = {
	dot_trigger_chance = 35,
	dot_damage = 25,
	dot_length = 6.1,
	dot_trigger_max_distance = 3000,
	dot_tick_period = 0.5
}
tweak_data.projectiles.rocket_ray_frag.sound_event_impact_duration = 1
tweak_data.projectiles.rocket_ray_frag.burn_duration = 3
tweak_data.projectiles.rocket_ray_frag.burn_tick_period = 0.5

for i, k in pairs(tweak_data.projectiles) do
	k.range = k.range and k.range*2
end

tweak_data.scene_poses.weapon.scout = nil



function TweakData:_set_normal()
	self.player:_set_normal()
	self.character:_set_normal()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_normal()

	self.experience_manager.civilians_killed = 35
	self.difficulty_name_id = self.difficulty_name_ids.easy
	self.experience_manager.total_level_objectives = 2000
	self.experience_manager.total_criminals_finished = 50
	self.experience_manager.total_objectives_finished = 1000
end



function TweakData:difficulty_to_index(difficulty)
	return table.index_of(self.difficulties, difficulty)==-1 and 5 or table.index_of(self.difficulties, difficulty)
end
