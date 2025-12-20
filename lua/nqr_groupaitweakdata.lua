Hooks:PostHook(GroupAITweakData, "_init_task_data", "nqr_GroupAITweakData:_init_task_data", function(self, difficulty_index, difficulty)
	local difficulty_index = difficulty_index or 5
	local job = Global.level_data and Global.level_data.level_id

	self.max_nr_simultaneous_boss_types = 0

	self.difficulty_curve_points = {0.5}

	if difficulty_index <= 2 then
		self.smoke_and_flash_grenade_timeout = {10, 20}
	else
		self.smoke_and_flash_grenade_timeout = {4, 6}
	end

	if difficulty_index <= 2 then
		self.smoke_grenade_lifetime = 7.5
	else
		self.smoke_grenade_lifetime = 12
	end

	self.flash_grenade_lifetime = 7.5
	--[[self.flash_grenade = {
		timer = 0.5,
		range = 1000,
		light_color = Vector3(0, 0, 0),
		light_range = 1,
		light_specular = 1,
		beep_speed = {10.1, 10.025},
		beep_fade_speed = 4,
		beep_multi = 0.3
	}
	if difficulty_index < 6 then
		self.flash_grenade.timer = 0.5
	else
		self.flash_grenade.timer = 0.5
	end]]

	self.optimal_trade_distance = {0, 0}
	self.bain_assault_praise_limits = {1, 3}

	if difficulty_index <= 2 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = { interval = {240, 320}, retire_delay = 30 },
			recurring_spawn_1 = { interval = {30, 60} }
		}
	elseif difficulty_index == 3 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = { interval = {120, 180}, retire_delay = 30 },
			recurring_spawn_1 = { interval = {30, 60} }
		}
	elseif difficulty_index == 4 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = { interval = {60, 90}, retire_delay = 30 },
			recurring_spawn_1 = { interval = {30, 60} }
		}
	elseif difficulty_index == 5 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = { interval = {30, 45}, retire_delay = 30 },
			recurring_spawn_1 = { interval = {30, 60} }
		}
	end

	self.besiege.regroup.duration = { 15, 15, 15 }
	self.besiege.assault = {}
	self.besiege.assault.anticipation_duration = { {30, 1}, {30, 1}, {45, 0.5} }
	self.besiege.assault.build_duration = 35
	self.besiege.assault.sustain_duration_min = { 0, 20, 30 }
	self.besiege.assault.sustain_duration_max = { 0, 40, 60 }
	self.besiege.assault.sustain_duration_balance_mul = { 1, 1.1, 1.2, 1.3 }
	self.besiege.assault.fade_duration = 5

	if difficulty_index == 2 then --<=2
		self.besiege.assault.delay = { 80, 70, 30 }
	elseif difficulty_index == 3 then --3
		self.besiege.assault.delay = { 45, 35, 20 }
	elseif difficulty_index == 4 then --4
		self.besiege.assault.delay = { 40, 30, 20 }
	elseif difficulty_index == 5 then --5
		self.besiege.assault.delay = { 30, 20, 15 }
	end

	if difficulty_index <= 3 then
		self.besiege.assault.hostage_hesitation_delay = { 30, 30, 30 }
	else
		self.besiege.assault.hostage_hesitation_delay = { 10, 10, 10 }
	end

	local job_mapping = {
		crojob2 = {2,1}, --bomb dockyard
		crojob3 = {2.2,2}, --bomb forest
		friend = {1.5,2}, --scarface mansion
		dah = {1.1,1}, --diamond heist
		peta = {2,1.5}, --goatsim 1
		peta2 = {1,2}, --goats day 2
		welcome_to_the_jungle_1 = {1.5,0.5}, --big oil 1
		welcome_to_the_jungle_1_night = {1.5,0.5}, --big oil 1
		welcome_to_the_jungle_2 = {1.3,1.2}, --big oil 2
		cane = {1,1.2}, --santa's workshop
		brb = {0.8,1.5}, --brooklyn bank
		mus = {1.1,1.5}, --the diamond
		run = {1.2,1}, --heat street
		bph = {0.7,0.7}, --hell's island
		glace = {0.6,1}, --green bridge
		pbr = {1.1,1.5}, --beneath the mountain
		pbr2 = {0.7,2}, --birth of sky
		dinner = {0.9,2}, --slaughterhouse
		born = {1.2,1.5}, --biker 1
		chew = {0.1,1}, --biker 2
		flat = {1,1.5}, --panic room
		spa = {0.6,1}, --brooklyn 10-10
		des = {0.8,1.5}, --henry's rock
		sah = {1.1,1}, --shacklethorne
		chill_combat = {1,1}, --safehouse raid
		man = {1.1,1}, --undercover
		jolly = {1.5,2}, --aftershock
		branchbank = {1.8,1.5}, --bank heist
		firestarter_1 = {2,1}, --firestarter 1
		firestarter_2 = {1.5,1}, --firestarter 2
		firestarter_3 = {2,1}, --firestarter 3
		mex = {1.5,1.5}, --border crossing
		mex_cooking = {0.8,1}, --border crystals
		roberts = {1.5,1.5}, --go bank
		family = {2,2}, --diamond store
		jewelry_store = {1,1}, --jewelry store
		ukrainian_job = {1.5,1}, --ukrainian job
		fex = {1.3,1.5}, --buluc's mansion
		rat = {1,1.5}, --cook off
		sand = {1,1}, --the ukrainian prisoner
		help = {1.2,1}, --prison nightmare
		rvd1 = {1.5,1.5}, --reservoir dogs 1
		rvd2 = {1,2.5}, --reservoir dogs 2
		vit = {0.8,1.5}, --white house
		mia_1 = {2,1}, --hotline miami 1
		mia_2 = {1,1.5}, --hotline miami 2
		nail = {2,2.5},	--lab rats
		hox_1 = {1.0,1}, --hoxton breakout 1
		hox_2 = {1.6,1}, --hoxton breakout 2
		hox_3 = {1.2,1.5}, --hoxton revenge
		xmn_hox1 = {1,1},
		hvh = {0.4,1}, --cursed kill room
		nmh = {0.9,0.5}, --no mercy
		big = {1.5,1}, --the big bank
		pent = {1.2,1}, --mountain master
		pines = {1.2,1.5}, --white xmas
		gallery = {1.5,1}, --art gallery
		alex_1 = {1.3,1.5}, --rats 1
		alex_2 = {1.2,1.5}, --rats 1
		alex_3 = {3,1.5}, --rats 3
		election_day_1 = {1.2,1.5}, --election
		election_day_2 = {1.5,2}, --election day 2
		election_day_3 = {1.4,1.5}, --election day 3
		election_day_3_skip1 = {1.4,1.5}, --election day 3
		election_day_3_skip2 = {1.4,1.5}, --election day 3
		bex = {2,1.5}, --san martin
		chas = {2,1}, --dragon heist
		escape_cafe = {0.4,1.5}, --escape cafe
		escape_cafe_day = {0.4,1.5}, --escape cafe
		escape_park = {0.4,1.5}, --escape park
		escape_park_day = {0.4,1.5}, --escape park
		escape_overpass = {0.4,1.5}, --escape overpass
		escape_overpass_night = {0.4,1.5}, --escape overpass
		escape_street = {0.4,1.5}, --escape street
		escape_garage = {0.4,1.5}, --escape garage
		watchdogs_1 = {1.2,1.5}, --
		watchdogs_2 = {1,1.5}, --
		ranc = {2.5,1.5}, --midland ranch
		trai = {3,1}, --lost in transit
		framing_frame_1 = {1.3,1.5}, --ff1
		framing_frame_3 = {1.5,1.5}, --ff3
		corp = {3,1.5}, --hostile takeover
		shoutout_raid = {2,2}, --meltdown
		pex = {2,1}, --policia federale
		deep = {1.5,2}, --crude awakening
		nightclub = {2,0.5}, --nightclub
		haunted = {0.5,0.5}, --safehouse nightmare
		four_stores = {1.8,0.5}, --four stores
		mallcrasher = {1.2,0.5}, --mallcrasher
		arm_par = {1.5,1.5}, --transport park
		arm_und = {1.2,1.5}, --transport underpass
		arm_cro = {1.5,1.5}, --transport crossroads
		arm_for = {1.2,2}, --transport train
		arena = {1.1,1.5}, --alesso
		wwh = {1,1.5}, --alaskan deal
		chca = {1.3,1.5}, --black cat
		mad = {1.2,1}, --boiling point
		kenaz = {1.2,1.5}, --golden grin casino
		pal = {1.5,2}, --counterfeit
	}
	local custom_force = {
		mia_2 = {2,1.3},
		friend = {2,1.3},
		mallcrasher = {2,1.3},
		four_stores = {2,1.3},
		crojob2 = {2,1.3},
		big = {2,1.3},
		welcome_to_the_jungle_1 = {2,1.3},
		welcome_to_the_jungle_1_night = {2,1.3},
		mex = {2,1.3},
		framing_frame_1 = {2,1.3},
		mus = {2, 1.3},

		firestarter_1 = {1.5, 1.2},
		firestarter_2 = {1.5, 1.2},
		welcome_to_the_jungle_2 = {1.5, 1.2},
		ranc = {1.5, 1.2},
		deep = {1.5, 1.2},
		hox_1 = {1.5, 1.2},
		hox_2 = {1.5, 1.2},
		wwh = {1.5, 1.2},
	}
	custom_force = custom_force[job] or {1, 1}
	local force_mul = (job_mapping[job] and job_mapping[job][1] or 1)

	if difficulty_index <= 2 then
		self.besiege.assault.force = { 3*force_mul*custom_force[1], 5*force_mul*custom_force[2], 7*force_mul }
		self.besiege.assault.force_pool = { 8, 12, 16 }
	else
		self.besiege.assault.force = { 4*force_mul*custom_force[1], 6*force_mul*custom_force[2], 8*force_mul }
		self.besiege.assault.force_pool = { 10, 14, 18 }
	end
	self.besiege.assault.force_balance_mul = { 1.0, 1.5, 2.0, 2.5 }
	self.besiege.assault.force_pool_balance_mul = { 1.0, 1.75, 2.5, 3.25 }

	local delay_mul = job_mapping[job] and job_mapping[job][2] or 1
	self.besiege.assault.delay = { 10*delay_mul, 20*delay_mul, 30*delay_mul }

	self.besiege.assault.groups = {
		tac_swat_shotgun_rush = { 0.0, 0.0, 0.1 },
		tac_swat_shotgun_flank = { 0.0, 0.0, 0.1 },
		tac_swat_rifle = { 0.6, 0.5, 0.4 },
		tac_swat_rifle_flank = { 0.6, 0.5, 0.4 },
		tac_shield_wall_charge = { 0.0, 0.5, 0.9 },
		tac_tazer_flanking = { 0.0, 0.5, 0.9 },
		tac_tazer_charge = { 0.0, 0.5, 0.9 },
		FBI_spoocs = { 0, 0.5, 0.9 },
		tac_bull_rush = { 0, 0.5, 0.9 },
	}
	self.besiege.assault.groups.single_spooc = { 0, 0, 0 }
	self.besiege.assault.groups.Phalanx = { 0, 0, 0 }
	if difficulty_index == 2 then
		self.besiege.assault.groups.tac_swat_shotgun_rush = { 0.0, 0.0, 0.05 }
	elseif difficulty_index == 4 then
		self.besiege.assault.groups.tac_swat_shotgun_rush = { 0.0, 0.0, 0.05 }
		self.besiege.assault.groups.tac_tazer_flanking = { 0.0, 0.2, 0.4 }
		self.besiege.assault.groups.tac_tazer_charge = { 0.0, 0.2, 0.4 }
	end

	self.besiege.reenforce.interval = { 10, 20, 30 }
	self.besiege.reenforce.groups = {}

	self.besiege.recon.interval = { 5, 5, 5 }
	self.besiege.recon.interval_variation = 40
	self.besiege.recon.force = { 1, 1, 1 }
	self.besiege.recon.groups = {
		tac_swat_shotgun_rush = { 0.1, 0.1, 0.1 },
		tac_swat_shotgun_flank = { 0.1, 0.1, 0.1 },
		tac_swat_rifle = { 0.1, 0.1, 0.1 },
		tac_swat_rifle_flank = { 0.1, 0.1, 0.1 }
	}

	self.besiege.recon.groups.single_spooc = { 0, 0, 0 }
	self.besiege.recon.groups.Phalanx = { 0, 0, 0 }
	self.besiege.cloaker.groups = { single_spooc = { 1, 1, 1 } }
	self.street = deep_clone(self.besiege)

	local players_amount_mul = managers.groupai and managers.groupai:state() and managers.groupai:state():_get_balancing_multiplier(self.besiege.assault.force_balance_mul) or 1
	self.phalanx.minions.min_count = 1
	self.phalanx.minions.amount = 4 * players_amount_mul
	self.phalanx.minions.distance = 100
	self.phalanx.vip.health_ratio_flee = 0.2
	self.phalanx.vip.damage_reduction = { start = 0.1, increase = 0.05, max = 0.5, increase_intervall = 5 }
	self.phalanx.check_spawn_intervall = 120
	self.phalanx.chance_increase_intervall = 120
	if difficulty_index == 5 then
		self.phalanx.spawn_chance = { start = 0.01, increase = 0.09, decrease = 0.7, max = 1, respawn_delay = 300000 }
	else
		self.phalanx.spawn_chance = { start = 0, increase = 0, decrease = 0, max = 0, respawn_delay = 120 }
	end

	self.safehouse = deep_clone(self.besiege)
end)



function GroupAITweakData:_init_enemy_spawn_groups(difficulty_index)
	local difficulty_index = difficulty_index or 5

	self._tactics = {
		Phalanx_minion = { "murder", "smoke_grenade", "charge", "provide_coverfire", "provide_support", "shield", "deathguard" },
		Phalanx_vip = { "smoke_grenade", "charge", "provide_coverfire", "provide_support", "shield", "deathguard" },
		swat_shotgun_rush = { "charge", "provide_coverfire", "provide_support", "deathguard", "flash_grenade" },
		swat_shotgun_flank = { "charge", "provide_coverfire", "provide_support", "flank", "deathguard", "flash_grenade" },
		swat_rifle = { "ranged_fire", "provide_coverfire", "provide_support" },
		swat_rifle_flank = { "ranged_fire", "provide_coverfire", "provide_support", "flank", "flash_grenade" },
		shield_wall_ranged = { "shield", "ranged_fire", "provide_support" },
		shield_support_ranged = { "shield_cover", "ranged_fire", "provide_coverfire" },
		shield_wall_charge = { "shield", "charge", "provide_support " },
		shield_support_charge = { "shield_cover", "charge", "provide_coverfire", "flash_grenade" },
		shield_wall = { "shield", "ranged_fire", "provide_support", "murder", "deathguard" },
		tazer_flanking = { "flanking", "charge", "provide_coverfire", "smoke_grenade", "murder" },
		tazer_charge = { "charge", "provide_coverfire", "murder" },
		tank_rush = { "charge", "provide_coverfire", "murder" },
		spooc = { "charge", "shield_cover", "smoke_grenade" },
		marshal_marksman = { "ranged_fire", "flank" },
		marshal_shield = { "shield", "ranged_fire" },
	}

	self.enemy_spawn_groups = {}

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_rush },
			--{ amount_min = 1, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "CS_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "CS_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = { amount = { 2, 3 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_heavy_R870", tactics = self._tactics.swat_shotgun_flank },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	end



	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_rifle = { amount = { 3, 4 }, spawn = {
			{ amount_min = 3, freq = 1, amount_max = 3, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "CS_swat_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_rifle = { amount = { 3, 4 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_rifle = { amount = { 3, 4 }, spawn = {
			{ amount_min = 3, freq = 1, amount_max = 3, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_rush },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_rifle = { amount = { 3, 4 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_rush },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.swat_rifle },
		} }
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { amount = { 3, 4 }, spawn = {
			{ amount_min = 3, freq = 1, amount_max = 3, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "CS_swat_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { amount = { 3, 4 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { amount = { 3, 4 }, spawn = {
			{ amount_min = 3, freq = 1, amount_max = 3, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 0, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_flank },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { amount = { 3, 4 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_R870", tactics = self._tactics.swat_shotgun_flank },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.swat_rifle_flank },
		} }
	end



	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { amount = { 3, 4 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.shield_support_ranged },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "CS_shield", tactics = self._tactics.shield_wall_ranged },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { amount = { 3, 4 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_heavy_M4", tactics = self._tactics.shield_support_ranged },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "CS_shield", tactics = self._tactics.shield_wall_ranged },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { amount = { 3, 4 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.shield_support_ranged },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_shield", tactics = self._tactics.shield_wall_ranged },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { amount = { 3, 4 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.shield_support_ranged },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_shield", tactics = self._tactics.shield_wall_ranged },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.shield_support_charge },
		} }
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.shield_support_charge },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_shield", tactics = self._tactics.shield_wall_charge },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.shield_support_charge },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_shield", tactics = self._tactics.shield_wall_charge },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.shield_support_charge },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_shield", tactics = self._tactics.shield_wall_charge },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.shield_support_charge },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_shield", tactics = self._tactics.shield_wall_charge },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_R870", tactics = self._tactics.shield_support_charge },
		} }
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall = { amount = { 1, 1 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "CS_shield", tactics = self._tactics.shield_wall },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall = { amount = { 1, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_shield", tactics = self._tactics.shield_wall },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall = { amount = { 1, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_shield", tactics = self._tactics.shield_wall },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall = { amount = { 1, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_shield", tactics = self._tactics.shield_wall },
			--{ amount_min = 0, freq = 0.2, amount_max = 1, rank = 1, unit = "medic_M4", tactics = self._tactics.shield_wall },
		} }
	end



	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_tazer_flanking = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_tazer_flanking = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_tazer_flanking = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_tazer_flanking = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
		} }
	else
		self.enemy_spawn_groups.tac_tazer_flanking = { amount = { 6, 6 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_tazer", tactics = self._tactics.tazer_flanking },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 3, freq = 3.0, amount_max = 3, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
		} }
	end

	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_tazer_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_tazer_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_tazer_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_tazer_charge = { amount = { 2, 3 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 2, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
		} }
	else
		self.enemy_spawn_groups.tac_tazer_charge = { amount = { 6, 6 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "CS_tazer", tactics = self._tactics.tazer_charge },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 3, freq = 3.0, amount_max = 3, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
		} }
	end



	if difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_bull_rush = { amount = { 2, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
		} }
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_bull_rush = { amount = { 2, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "CS_swat_MP5", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
		} }
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_bull_rush = { amount = { 2, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
		} }
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_bull_rush = { amount = { 2, 2 }, spawn = {
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 2, unit = "FBI_tank", tactics = self._tactics.tank_rush },
		} }
	else
		self.enemy_spawn_groups.tac_bull_rush = { amount = { 6, 6 }, spawn = {
			{ amount_min = 2, freq = 1, amount_max = 2, rank = 1, unit = "FBI_tank", tactics = self._tactics.tank_rush },
			{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "FBI_swat_M4", tactics = self._tactics.swat_rifle_flank },
			{ amount_min = 3, freq = 3.0, amount_max = 3, rank = 1, unit = "FBI_heavy_G36", tactics = self._tactics.swat_rifle_flank },
		} }
	end



	self.enemy_spawn_groups.Phalanx = { amount = { self.phalanx.minions.amount, self.phalanx.minions.amount }, spawn = {
		--{ amount_min = 1, freq = 1, amount_max = 1, rank = 1, unit = "Phalanx_vip", tactics = self._tactics.Phalanx_vip },
		{ amount_min = 1, freq = 1, rank = 1, unit = "Phalanx_minion", tactics = self._tactics.Phalanx_minion }
	} }
	self.enemy_spawn_groups.single_spooc = { amount = { 1, 1 }, spawn = {
		{ freq = 1, amount_min = 1, rank = 1, unit = "spooc", tactics = self._tactics.spooc }
	} }
	self.enemy_spawn_groups.FBI_spoocs = self.enemy_spawn_groups.single_spooc

	self.enemy_spawn_groups.snowman_boss = { amount = { 1, 1 }, spawn = {
		{ freq = 1, amount_min = 1, rank = 1, unit = "snowman_boss", tactics = self._tactics.tank_rush }
	}, spawn_point_chk_ref = table.list_to_set({ "tac_bull_rush" }) }
end

function GroupAITweakData:_init_enemy_spawn_groups_level(tweak_data, difficulty_index)
	local lvl_tweak_data = tweak_data.levels[Global.game_settings and Global.game_settings.level_id or Global.level_data and Global.level_data.level_id]
	local difficulty_index = difficulty_index or 5

	if lvl_tweak_data and lvl_tweak_data.ai_unit_group_overrides then
		local unit_types = nil

		for unit_type, faction_type_data in pairs(lvl_tweak_data.ai_unit_group_overrides) do
			unit_types = self.unit_categories[unit_type] and self.unit_categories[unit_type].unit_types

			if unit_types then
				for faction_type, override in pairs(faction_type_data) do
					if unit_types[faction_type] then
						unit_types[faction_type] = override
					end
				end
			end
		end
	end

	if difficulty_index==5 and lvl_tweak_data and not lvl_tweak_data.ai_marshal_spawns_disabled then
		if lvl_tweak_data.ai_marshal_spawns_fast then
			self.enemy_spawn_groups.marshal_squad = {
				spawn_cooldown = 60,
				max_nr_simultaneous_groups = 2,
				initial_spawn_delay = 90,
				amount = {
					2,
					2
				},
				spawn = {
					{
						respawn_cooldown = 30,
						amount_min = 1,
						rank = 1,
						freq = 1,
						unit = "marshal_shield",
						tactics = self._tactics.marshal_shield
					},
					{
						respawn_cooldown = 30,
						amount_min = 1,
						rank = 1,
						freq = 1,
						unit = "marshal_marksman",
						tactics = self._tactics.marshal_marksman
					}
				},
				spawn_point_chk_ref = table.list_to_set({
					"tac_shield_wall",
					"tac_shield_wall_ranged",
					"tac_shield_wall_charge"
				})
			}
		else
			self.enemy_spawn_groups.marshal_squad = {
				spawn_cooldown = 60,
				max_nr_simultaneous_groups = 2,
				initial_spawn_delay = 480,
				amount = {
					2,
					2
				},
				spawn = {
					{
						respawn_cooldown = 30,
						amount_min = 1,
						rank = 1,
						freq = 1,
						unit = "marshal_shield",
						tactics = self._tactics.marshal_shield
					},
					{
						respawn_cooldown = 30,
						amount_min = 1,
						rank = 1,
						freq = 1,
						unit = "marshal_marksman",
						tactics = self._tactics.marshal_marksman
					}
				},
				spawn_point_chk_ref = table.list_to_set({
					"tac_shield_wall",
					"tac_shield_wall_ranged",
					"tac_shield_wall_charge"
				})
			}
		end
	end
end



function GroupAITweakData:_init_unit_categories(difficulty_index)
	local access_type_walk_only = { walk = true }
	local access_type_all = { acrobatic = true, walk = true }

	if 	   difficulty_index <= 2 then self.special_unit_spawn_limits = { shield = 1, medic = 1, taser = 0, tank = 0, spooc = 1 }
	elseif difficulty_index == 3 then self.special_unit_spawn_limits = { shield = 2, medic = 1, taser = 1, tank = 0, spooc = 2 }
	elseif difficulty_index == 4 then self.special_unit_spawn_limits = { shield = 2, medic = 1, taser = 1, tank = 1, spooc = 2 }
	elseif difficulty_index == 5 then self.special_unit_spawn_limits = { shield = 2, medic = 2, taser = 1, tank = 1, spooc = 2 }
	elseif difficulty_index == 6 then self.special_unit_spawn_limits = { shield = 4, medic = 3, taser = 3, tank = 2, spooc = 2 }
	elseif difficulty_index == 7 then self.special_unit_spawn_limits = { shield = 4, medic = 3, taser = 3, tank = 2, spooc = 2 }
	elseif difficulty_index == 8 then self.special_unit_spawn_limits = { shield = 4, medic = 3, taser = 3, tank = 3, spooc = 2 }
								 else self.special_unit_spawn_limits = { shield = 8, medic = 3, taser = 4, tank = 2, spooc = 2 } end

	self.unit_categories = {}

	self.unit_categories.spooc = { access = access_type_all, special_type = "spooc", unit_types = {
		america = { Idstring("units/payday2/characters/ene_spook_1/ene_spook_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale") },
	}, }

	self.unit_categories.CS_cop_C45_R870 = { access = access_type_walk_only, unit_types = {
		america = {
			Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
			Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
			Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
		},
		russia = {
			Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
		},
		zombie = {
			Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
			Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
			Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4"),
		},
		murkywater = {
			Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
			Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
			Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
		},
		federales = {
			Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
			Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
			Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
		},
	}, }
	self.unit_categories.CS_cop_stealth_MP5 = { access = access_type_walk_only, unit_types = {
		america = { Idstring("units/payday2/characters/ene_cop_3/ene_cop_3") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2") },
		murkywater = { Idstring("units/payday2/characters/ene_cop_3/ene_cop_3") },
		federales = { Idstring("units/payday2/characters/ene_cop_3/ene_cop_3") },
	}, }

  --SWAT
	self.unit_categories.CS_swat_MP5 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_swat_1/ene_swat_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale") },
	}, }
	self.unit_categories.CS_swat_R870 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_swat_2/ene_swat_2") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870/ene_swat_policia_federale_r870") },
	}, }
  --

  --SWAT HEAVY
	self.unit_categories.CS_heavy_M4 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale") },
	}, }
	self.unit_categories.CS_heavy_R870 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_r870/ene_swat_heavy_policia_federale_r870") },
	}, }
	self.unit_categories.CS_heavy_M4_w = { access = access_type_walk_only, unit_types = {
		america = { Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale") },
	}, }
  --

	self.unit_categories.CS_tazer = { access = access_type_all, special_type = "taser", unit_types = {
		america = { Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_tazer_policia_federale/ene_swat_tazer_policia_federale") },
	}, }

	self.unit_categories.CS_shield = { access = access_type_walk_only, special_type = "shield", unit_types = {
		america = { Idstring("units/payday2/characters/ene_shield_2/ene_shield_2") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45") },
	}, }

	self.unit_categories.FBI_suit_C45_M4 = { access = access_type_all, unit_types = {
		america = {
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
			Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
		},
		russia = {
			Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
			Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
		},
		zombie = {
			Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
			Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
		},
		murkywater = {
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2"),
		},
		federales = {
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2"),
		},
	}, }
	self.unit_categories.FBI_suit_M4_MP5 = { access = access_type_all, unit_types = {
		america = {
			Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
			Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
		},
		russia = {
			Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg"),
			Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg"),
		},
		zombie = {
			Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
			Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3"),
		},
		murkywater = {
			Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
			Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_3"),
		},
		federales = {
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_2"),
			Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_3"),
		},
	}, }
	self.unit_categories.FBI_suit_stealth_MP5 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3") },
		murkywater = { Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3") },
		federales = { Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3") },
	}, }

	self.unit_categories.FBI_swat_M4 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi") },
	}, }
		--[[america = { Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_city/ene_murkywater_light_city") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_city/ene_swat_policia_federale_city") } }, }]]

	self.unit_categories.FBI_swat_R870 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870/ene_swat_policia_federale_r870") },
	}, }
		--[[america = { Idstring("units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_city_r870/ene_murkywater_light_city_r870") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_city_r870/ene_swat_policia_federale_city_r870") } }, }]]

	self.unit_categories.FBI_heavy_G36 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_g36/ene_swat_heavy_policia_federale_fbi_g36") },
	}, }
		--[[america = { Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_g36/ene_swat_heavy_policia_federale_fbi_g36") } }, }]]

	self.unit_categories.FBI_heavy_R870 = { access = access_type_all, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870") },
	}, }
		--[[america = { Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870") },
		murkywater = { Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870") } }, }]]

	self.unit_categories.FBI_heavy_G36_w = { access = access_type_walk_only, unit_types = {
		america = { Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale") },
	}, }

	self.unit_categories.FBI_shield = { access = access_type_walk_only, special_type = "shield", unit_types = {
		america = { Idstring("units/payday2/characters/ene_shield_1/ene_shield_1") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9") },
	}, }
		--[[america = { Idstring("units/payday2/characters/ene_city_shield/ene_city_shield") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9") } }, }]]

	if difficulty_index <= 4 then
		self.unit_categories.FBI_tank = { access = access_type_all, special_type = "tank", unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
			},
		}, }
	elseif difficulty_index == 5 then
		self.unit_categories.FBI_tank = { access = access_type_all, special_type = "tank", unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
				Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
			},
		}, }
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_tank = { access = access_type_all, special_type = "tank", unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
				Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
				Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
				Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
				Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
			},
		}, }
	end

	self.unit_categories.medic_M4 = { access = access_type_all, special_type = "medic", unit_types = {
		america = { Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale/ene_swat_medic_policia_federale") },
	}, }
	self.unit_categories.medic_R870 = { access = access_type_all, special_type = "medic", unit_types = {
		america = { Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870") },
		russia = { Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870") },
		zombie = { Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870") },
		murkywater = { Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870") },
		federales = { Idstring("units/pd2_dlc_bex/characters/ene_swat_medic_policia_federale_r870/ene_swat_medic_policia_federale_r870") },
	}, }
	self.unit_categories.Phalanx_minion = { is_captain = true, access = access_type_walk_only, special_type = "shield", unit_types = {
		america = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
		russia = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
		zombie = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
		murkywater = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
		federales = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
	}, }
	self.unit_categories.Phalanx_vip = { is_captain = true, access = access_type_walk_only, special_type = "shield", unit_types = {
		america = { Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1") },
		russia = { Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1") },
		zombie = { Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1") },
		murkywater = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
		federales = { Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") },
	}, }
	self.unit_categories.marshal_marksman = { access = access_type_all, unit_types = {
		america = { Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_1/ene_male_marshal_marksman_1") },
		russia = { Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2") },
		zombie = { Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2") },
		murkywater = { Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2") },
		federales = { Idstring("units/pd2_dlc_usm1/characters/ene_male_marshal_marksman_2/ene_male_marshal_marksman_2") },
	}, }
	self.unit_categories.marshal_shield = { access = access_type_walk_only, unit_types = {
		america = { Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_1/ene_male_marshal_shield_1") },
		russia = { Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2") },
		zombie = { Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2") },
		murkywater = { Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2") },
		federales = { Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2") },
	}, }
	self.unit_categories.snowman_boss = { access = access_type_all, unit_types = {
		america = { Idstring("units/pd2_dlc_cg22/characters/ene_snowman_boss/ene_snowman_boss") },
		russia = { Idstring("units/pd2_dlc_cg22/characters/ene_snowman_boss/ene_snowman_boss") },
		zombie = { Idstring("units/pd2_dlc_cg22/characters/ene_snowman_boss/ene_snowman_boss") },
		murkywater = { Idstring("units/pd2_dlc_cg22/characters/ene_snowman_boss/ene_snowman_boss") },
		federales = { Idstring("units/pd2_dlc_cg22/characters/ene_snowman_boss/ene_snowman_boss") },
	}, }

end