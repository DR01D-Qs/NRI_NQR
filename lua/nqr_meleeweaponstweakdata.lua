Hooks:PostHook( BlackMarketTweakData, "_init_melee_weapons", "nqr_BlackMarketTweakData:_init_melee_weapons", function(self, tweak_data)
	local animset = {}
	for i, k in pairs(self.melee_weapons) do
		if k.anim_global_param then animset[k.anim_global_param] = true end
	end

	self.m_animsets = {
		fists = {
			{ "melee_fist" },

			{ "melee_fist", 1 }, --rf
			{ "melee_fist", 2 }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 1 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_fist", 4 }, --lf
			{ "melee_fist", 3 }, --lr
			{ "melee_cleaver", 4 }, --ll
			{ "melee_knife", 3 }, --ld
		},
		fists_mirrored = {
			{ "melee_fist", nil, { a_weapon_left = { rot = Rotation(0,180,180) } } },

			{ "melee_fist", 1, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --rf
			{ "melee_fist", 2, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 1 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_fist", 4, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --lf
			{ "melee_fist", 3, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --ll
			{ "melee_knife", 3, { a_weapon_left = { rot = Rotation(0,180,180) } } }, --ld
		},
		pencil = {
			{ "melee_ballistic" },

			{ "melee_ballistic", 2 }, --rf
			{ "melee_clean", 1 }, --{ "melee_stab", 3 }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_ballistic", 1 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_twins", 3 }, --lf
			{ "melee_knife2", 1 }, --{ "melee_grip", 1, { a_weapon_left = { rot = Rotation(180,0,0) } } }, --lr { "melee_ostry", 1, rot = Rotation(90,0,0) }
			{ "melee_cleaver", 4 }, --ll
			{ "melee_cleaver", 1 }, --ld
        },
		pencil_reversed = {
            { "melee_fist" },

			{ "melee_psycho", 1 }, --rf
			{ "melee_fist", 2 }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 4 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_knife", 1 }, --lf
			{ "melee_fist", 3 }, --lr { "melee_grip", 1 }
			{ "melee_cleaver", 4 }, --ll
			{ "melee_knife", 3 }, --ld { "melee_knife", 3 }
		},
        knife = {
			{ "melee_ballistic" },

			{ "melee_ballistic", 2 }, --rf
			{ "melee_clean", 1 }, --rl { "melee_axe", 3 }
			{ "melee_sandsteel", 1 }, --rr { "melee_twins", 4 }
			{ "melee_ballistic", 1 }, --rd { "melee_boxcutter", 4 } { "melee_twins", 1 }

			{ "melee_buck", 1 }, --bb

			{ "melee_twins", 3 }, --lf
			{ "melee_knife2", 1 }, --lr
			{ "melee_cleaver", 4 }, --ll
			{ "melee_cleaver", 1 }, --ld
        },
		knife_reversed = {
            { "melee_fist" },

			{ "melee_psycho", 1 }, --rf
			{ "melee_fist", 2 }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 4 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_knife", 1 }, --lf
			{ "melee_fist", 3 }, --lr { "melee_grip", 1 }
			{ "melee_cleaver", 4 }, --ll
			{ "melee_knife", 3 }, --ld { "melee_knife", 3 }
		},
		knife_mirrored = {
			{ "melee_ballistic", nil, { a_weapon_left = { rot = Rotation(0,0,180) } } },

			{ "melee_ballistic", 2, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rf
			{ "melee_clean", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rl { "melee_axe", 3 }
			{ "melee_sandsteel", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rr { "melee_twins", 4 }
			{ "melee_ballistic", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rd { "melee_boxcutter", 4 } { "melee_twins", 1 }

			{ "melee_buck", 1 }, --bb

			{ "melee_twins", 3, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lf
			{ "melee_knife2", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ll
			{ "melee_cleaver", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ld
        },
		knife_mirrored_reversed = {
            { "melee_fist", nil, { a_weapon_right = { rot = Rotation(0,0,180) } } },

			{ "melee_psycho", 1, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --rf
			{ "melee_fist", 2, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --rl
			{ "melee_sandsteel", 1, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --rr
			{ "melee_chac", 4, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --rd

			{ "melee_buck", 1, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --bb

			{ "melee_knife", 1, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --lf
			{ "melee_fist", 3, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --lr { "melee_grip", 1 }
			{ "melee_cleaver", 4, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --ll
			{ "melee_knife", 3, { a_weapon_right = { rot = Rotation(0,0,180) } } }, --ld { "melee_knife", 3 }
		},
		sword = {
			{ "melee_sandsteel" },
            false,false,false,false,false,false,false,false,false,

			{ "melee_great", 3 }, --bf
			{ "melee_sandsteel", 2 }, --bl
			{ "melee_sandsteel", 1 }, --br
			{ "melee_road", 2, { a_weapon_right = { pos = Vector3(-5,0,0), rot = Rotation(0,0,180) } }, force_hit = true }, --bd
			
			{ "melee_buck", 1 }, --bb
		},

		boxing_gloves = {
			{ "melee_fist", nil, { a_weapon_left = { pos = Vector3(3,-3,-15), rot = Rotation(0,180+30,0) }, a_weapon_right = { pos = Vector3(3,2,-15) } } },

			{ "melee_fist", 1, { a_weapon_left = { rot = Rotation(0,180+30,0) } } }, --rf
			{ "melee_fist", 2, { a_weapon_left = { rot = Rotation(0,180+30,0) } } }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 1 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_fist", 4, { a_weapon_left = { rot = Rotation(0,180+30,0) } } }, --lf
			{ "melee_fist", 3, { a_weapon_left = { rot = Rotation(0,180+30,0) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,180+30,0) } } }, --ll
			{ "melee_knife", 3, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ld
		},
		brick = {
			{ "melee_ballistic", nil, { a_weapon_left = { rot = Rotation(0,0,180) } } },

			{ "melee_ballistic", 2, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rf
			{ "melee_clean", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rl { "melee_axe", 3 }
			{ "melee_sandsteel", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rr { "melee_twins", 4 }
			{ "melee_ballistic", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rd { "melee_boxcutter", 4 } { "melee_twins", 1 }

			{ "melee_buck", 1 }, --bb

			{ "melee_twins", 3, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lf
			{ "melee_knife2", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ll
			{ "melee_cleaver", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ld
        },
		brick_reversed = {
            { "melee_fist", nil, { a_weapon_left = { rot = Rotation(0,0,180) } } },

			{ "melee_psycho", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rf
			{ "melee_fist", 2, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rl
			{ "melee_sandsteel", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rr
			{ "melee_chac", 4, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_knife", 1, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lf
			{ "melee_fist", 3, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --lr { "melee_grip", 1 }
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ll
			{ "melee_knife", 3, { a_weapon_left = { rot = Rotation(0,0,180) } } }, --ld { "melee_knife", 3 }
		},
		money = {
			{ "melee_ballistic", nil, { a_weapon_left = { rot = Rotation(0,0,-90) } } },

			{ "melee_ballistic", 2, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --rf
			{ "melee_clean", 1, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --rl { "melee_axe", 3 }
			{ "melee_sandsteel", 1, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --rr { "melee_twins", 4 }
			{ "melee_ballistic", 1, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --rd { "melee_boxcutter", 4 } { "melee_twins", 1 }

			{ "melee_buck", 1 }, --bb

			{ "melee_twins", 3, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --lf
			{ "melee_knife2", 1, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --ll
			{ "melee_cleaver", 1, { a_weapon_left = { rot = Rotation(0,0,-90) } } }, --ld
        },
        cutters = {
			{ "melee_cutters" },
            false,false,false,false,false,false,false,false,false,

			{ "melee_cutters", 4 }, --bf
			{ "melee_sandsteel", 2, { a_weapon_right = { rot = Rotation(0,0,90) } } }, --bl
			{ "melee_sandsteel", 1, { a_weapon_right = { rot = Rotation(0,0,-90) } } }, --br
			{ "melee_cutters", 3 }, --bd

			{ "melee_buck", 1 }, --bb
		},
        briefcase = {
			{ "melee_briefcase" },
            false,false,false,false,false,false,false,false,false,

			{ "melee_briefcase", 2 }, --bf
			{ "melee_sandsteel", 2, { a_weapon_right = { rot = Rotation(180,0,0) } } }, --bl
			{ "melee_sandsteel", 1, { a_weapon_right = { pos = Vector3(-38,0,0), rot = Rotation(180,0,0) } } }, --br
			{ "melee_briefcase", 1 }, --bd

			{ "melee_briefcase", 2 }, --bb
		},
        road = {
			{ "melee_road" },
            false,false,false,false,false,false,false,false,false,

			{ "melee_great", 3, { a_weapon_right = { pos = Vector3(0,0,0), rot = Rotation(0,0,180) } } }, --bf
			{ "melee_sandsteel", 2, { a_weapon_right = { pos = Vector3(0,0,0), rot = Rotation(5,-5,135) } } }, --bl
			{ "melee_sandsteel", 1, { a_weapon_right = { pos = Vector3(1,10,-3), rot = Rotation(0,15,180) } } }, --br
			{ "melee_road", 2, force_hit = true }, --bd

			{ "melee_buck", 1, { a_weapon_right = { pos = Vector3(0,0,0), rot = Rotation(0,0,180) } } }, --bb
		},
        cs = {
			{ "melee_cs" },
            false,false,false,false,false,false,false,false,false,

			{ "melee_cutters", 4, { a_weapon_right = { pos = Vector3(0,-5,15), rot = Rotation(0,0,-90) } } }, --bf
			{ "melee_cs", 3 }, --bl
			{ "melee_cs", 2 }, --br
			{ "melee_cs", 4 }, --bd

			{ "melee_cutters", 4, { a_weapon_right = { pos = Vector3(0,-5,15), rot = Rotation(0,0,-90) } } }, --bf
		},
        nin = {
			{ "melee_fist" },

			{ "melee_fist", 1 }, --rf
			{ "melee_fist", 2 }, --rl
			{ "melee_sandsteel", 1 }, --rr
			{ "melee_chac", 1 }, --rd

			{ "melee_buck", 1 }, --bb

			{ "melee_fist", 4 }, --lf
			{ "melee_fist", 3 }, --lr
			{ "melee_cleaver", 4 }, --ll
			{ "melee_knife", 3 }, --ld
        },
        buck = {
			{ "melee_fist", nil, { a_weapon_left = { rot = Rotation(0,0,135) } } },

			{ "melee_fist", 1, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --rf
			{ "melee_fist", 2, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --rl
			{ "melee_sandsteel", 1, { a_weapon_left = { pos = Vector3(0,0,0) } } }, --rr
			{ "melee_chac", 1, { a_weapon_right = { rot = Rotation(0,0,0) } } }, --rd

			{ "melee_buck", 1, { a_weapon_right = { rot = Rotation(0,0,-45) } } }, --bb

			{ "melee_fist", 4, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --lf
			{ "melee_fist", 3, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --lr
			{ "melee_cleaver", 4, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --ll
			{ "melee_knife", 3, { a_weapon_left = { rot = Rotation(0,0,135) } } }, --ld
        },
        ostry = {
			{ "melee_ostry" },

			{ "melee_ballistic", 2 }, --rf
			{ "melee_clean", 1 }, --rl { "melee_axe", 3 }
			{ "melee_sandsteel", 1 }, --rr { "melee_twins", 4 }
			{ "melee_ballistic", 1 }, --rd { "melee_boxcutter", 4 } { "melee_twins", 1 }

            { "melee_buck", 1 }, --bb

			{ "melee_twins", 3 }, --lf
			{ "melee_knife2", 1 }, --lr
			{ "melee_cleaver", 4 }, --ll
			{ "melee_cleaver", 1 }, --ld
        },
	}

    local dmgtype_presets = {
        pencil = { tip = "piercing" },
        knife = { front = "slashing", tip = "piercing" },
        knife_double = { front = "slashing", back = "slashing", tip = "piercing" },
        cleaver = { front = "slashing" },
    }



	self.melee_weapons.fists.sounds.hit_air = "fist_equip"
	self.melee_weapons.fists.animset = "fists"
	self.melee_weapons.fists.stats = { concealment = 1, weight = 5, length = 30 }

	self.melee_weapons.sword.animset = "pencil"
	self.melee_weapons.sword.stats = { concealment = 1, weight = 1, length = 4, damage_types = dmgtype_presets.pencil }
	self.melee_weapons.toothbrush.animset = "pencil"
	self.melee_weapons.toothbrush.stats = { concealment = 1, weight = 1, length = 3, damage_types = dmgtype_presets.pencil }
	self.melee_weapons.whiskey.animset = "knife"
	self.melee_weapons.whiskey.stats = { concealment = 1, weight = 3, length = 10 }
	self.melee_weapons.slot_lever.animset = "knife"
	self.melee_weapons.slot_lever.stats = { concealment = 1, weight = 4, length = 15 }
	self.melee_weapons.chac.info_id = nil
	self.melee_weapons.chac.animset = "knife"
	self.melee_weapons.chac.stats = { concealment = 1, weight = 2, length = 6 }
	self.melee_weapons.brick.animset = "brick"
	self.melee_weapons.brick.reverse_axis = Rotation(0,180,0)
	self.melee_weapons.brick.shifts = { rot = Rotation(180,90,-90) }
	self.melee_weapons.brick.stats = { concealment = 1, weight = 11, length = 5 }
	self.melee_weapons.sap.animset = "knife_mirrored"
	self.melee_weapons.sap.stats = { concealment = 1, weight = 1, length = 2 }
	self.melee_weapons.boxing_gloves.pcs = false
	self.melee_weapons.boxing_gloves.animset = "boxing_gloves"
	self.melee_weapons.boxing_gloves.shifts = { rot = Rotation(90,90-15,180) }
	self.melee_weapons.boxing_gloves.stats = { concealment = 1, weight = 4, length = 4, fist_addon = true }
	self.melee_weapons.aziz.animset = "knife"
	self.melee_weapons.aziz.shifts = { pos = Vector3(0,4,0), rot = Rotation(0,0,180) }
	self.melee_weapons.aziz.stats = { concealment = 1, weight = 3, length = 2 }
	self.melee_weapons.micstand.pcs = false
	self.melee_weapons.micstand.animset = "knife"
	self.melee_weapons.micstand.stats = { concealment = 1, weight = 13, length = 30 }
	self.melee_weapons.microphone.animset = "knife"
	self.melee_weapons.microphone.stats = { concealment = 1, weight = 2, length = 2 }
	self.melee_weapons.bonk.info_id = nil
	self.melee_weapons.bonk.twohanded = true
	self.melee_weapons.bonk.animset = "sword"
	self.melee_weapons.bonk.shifts = { pos = Vector3(1,2,0), rot = Rotation(0,0,90) }
	self.melee_weapons.bonk.stats = { concealment = 1, weight = 30, length = 10 }
	self.melee_weapons.bonk2.info_id = nil
	self.melee_weapons.bonk2.twohanded = true
	self.melee_weapons.bonk2.animset = "sword"
	self.melee_weapons.bonk2.shifts = { pos = Vector3(1,2,0), rot = Rotation(0,0,90) }
	self.melee_weapons.bonk2.stats = { concealment = 1, weight = 15, length = 10 }
	self.melee_weapons.hockey.animset = "sword"
	self.melee_weapons.hockey.twohanded = true
	self.melee_weapons.hockey.stats = { concealment = 1, weight = 5, length = 40 }
	self.melee_weapons.selfie.animset = "knife"
	self.melee_weapons.selfie.stats = { concealment = 1, weight = 3, length = 25 }
	self.melee_weapons.briefcase.twohanded = true
	self.melee_weapons.briefcase.large = true
	self.melee_weapons.briefcase.animset = "briefcase"
	self.melee_weapons.briefcase.shifts = { rot = Rotation(90,0,0) }
	self.melee_weapons.briefcase.stats = { concealment = 1, weight = 20, length = 3 }

	self.melee_weapons.moneybundle.animset = "money"
	self.melee_weapons.moneybundle.stats = { concealment = 1, weight = 1, length = 2 }
	self.melee_weapons.boxcutter.animset = "knife"
	self.melee_weapons.boxcutter.stats = { concealment = 1, weight = 1, length = 5, damage_types = dmgtype_presets.knife }
	self.melee_weapons.fork.animset = "pencil"
	self.melee_weapons.fork.stats = { concealment = 1, weight = 1, length = 10, damage_types = dmgtype_presets.pencil }
	self.melee_weapons.spatula.animset = "knife_mirrored"
	self.melee_weapons.spatula.shifts = { rot = Rotation(0,0,-90) }
	self.melee_weapons.spatula.stats = { concealment = 1, weight = 1, length = 5, damage_types = { front = "slashing", back = "slashing", tip = "slashing" } }
	self.melee_weapons.shawn.animset = "pencil"
	self.melee_weapons.shawn.shifts = { rot = Rotation(0,0,180) }
	self.melee_weapons.shawn.stats = { concealment = 1, weight = 2, length = 4, damage_types = dmgtype_presets.pencil }
	self.melee_weapons.tenderizer.animset = "knife"
	self.melee_weapons.tenderizer.shifts = { rot = Rotation(0,0,180) }
	self.melee_weapons.tenderizer.stats = { concealment = 1, weight = 20, length = 12, damage_types = { front = "puncturing", back = "puncturing" } }
	self.melee_weapons.clean.animset = "knife"
	self.melee_weapons.clean.chargeanimoffset = 0.5
	self.melee_weapons.clean.shifts = { rot = Rotation(-90,0,180) }
	self.melee_weapons.clean.stats = { concealment = 1, weight = 1, length = 5, damage_types = dmgtype_presets.knife }
	self.melee_weapons.chef.animset = "knife"
	self.melee_weapons.chef.stats = { concealment = 1, weight = 2, length = 8, damage_types = dmgtype_presets.knife }
	self.melee_weapons.road.twohanded = true
	self.melee_weapons.road.large = true
	self.melee_weapons.road.animset = "road"
	self.melee_weapons.road.shifts = { pos = Vector3(-20,0,0), rot = Rotation(90,90,0) }
	self.melee_weapons.road.stats = { concealment = 1, weight = 5, length = 25 }
	self.melee_weapons.swagger.animset = "knife"
	self.melee_weapons.swagger.stats = { concealment = 1, weight = 3, length = 25 }
	self.melee_weapons.stick.animset = "knife"
	self.melee_weapons.stick.stats = { concealment = 1, weight = 8, length = 35 }
	self.melee_weapons.croupier_rake.animset = "knife"
	self.melee_weapons.croupier_rake.stats = { concealment = 1, weight = 3, length = 25 }
	self.melee_weapons.baseballbat.animset = "sword"
	self.melee_weapons.baseballbat.twohanded = true
	self.melee_weapons.baseballbat.align_objects = { "a_weapon_right" }
	self.melee_weapons.baseballbat.shifts = { pos = Vector3(0.5,0,0) }
	self.melee_weapons.baseballbat.stats = { concealment = 1, weight = 9, length = 25 }
	self.melee_weapons.hammer.animset = "knife"
	self.melee_weapons.hammer.stats = { concealment = 1, weight = 7, length = 12, damage_types = { back = "piercing" } }
	self.melee_weapons.cleaver.animset = "knife"
	self.melee_weapons.cleaver.stats = { concealment = 1, weight = 3, length = 11, damage_types = dmgtype_presets.cleaver }
	self.melee_weapons.meat_cleaver.animset = "knife"
	self.melee_weapons.meat_cleaver.stats = { concealment = 1, weight = 4, length = 13, damage_types = dmgtype_presets.cleaver }
	self.melee_weapons.branding_iron.animset = "sword"
	self.melee_weapons.branding_iron.twohanded = true
	self.melee_weapons.branding_iron.stats = { concealment = 1, weight = 14, length = 20 }
	self.melee_weapons.meter.twohanded = true
	self.melee_weapons.meter.animset = "sword"
	self.melee_weapons.meter.shifts = { pos = Vector3(0,0,0.5), rot = Rotation(0,-3,-10) }
	self.melee_weapons.meter.stats = { concealment = 1, weight = 10, length = 30, damage_types = dmgtype_presets.cleaver }
	self.melee_weapons.poker.animset = "knife"
	self.melee_weapons.poker.stats = { concealment = 1, weight = 8, length = 25, damage_types = { tip = "piercing" } }
	self.melee_weapons.pitchfork.pcs = false
	self.melee_weapons.pitchfork.stats = {}
	self.melee_weapons.shovel.animset = "knife"
	self.melee_weapons.shovel.stats = { concealment = 1, weight = 12, length = 18, damage_types = { tip = "puncturing" } }
	self.melee_weapons.shock.animset = "sword"
	self.melee_weapons.shock.twohanded = true
	self.melee_weapons.shock.shifts = { pos = Vector3(0,-3,0) }
	self.melee_weapons.shock.stats = { concealment = 1, weight = 28, length = 12 }
	self.melee_weapons.cutters.twohanded = true
	self.melee_weapons.cutters.large = true
	self.melee_weapons.cutters.animset = "cutters"
	self.melee_weapons.cutters.stats = { concealment = 1, weight = 41, length = 20 }

	self.melee_weapons.catch.animset = "knife"
	self.melee_weapons.catch.reverse_axis = Rotation(180,0,0)
	self.melee_weapons.catch.shifts = { pos = Vector3(0,0,6), rot = Rotation(0,90,90) }
	self.melee_weapons.catch.stats = { concealment = 1, weight = 5, length = 5, damage_types = { front = "piercing" } }
	self.melee_weapons.bullseye.animset = "knife"
	self.melee_weapons.bullseye.stats = { concealment = 1, weight = 6, length = 6, damage_types = dmgtype_presets.knife }
	self.melee_weapons.machete.animset = "knife"
	self.melee_weapons.machete.shifts = { pos = Vector3(0,-2,0) }
	self.melee_weapons.machete.stats = { concealment = 1, weight = 7, length = 9, damage_types = dmgtype_presets.knife }
	self.melee_weapons.iceaxe.animset = "knife"
	self.melee_weapons.iceaxe.stats = { concealment = 1, weight = 7, length = 12, damage_types = { front = "piercing", back = "puncturing" } }
	self.melee_weapons.mining_pick.twohanded = true
	self.melee_weapons.mining_pick.animset = "sword"
	self.melee_weapons.mining_pick.align_objects = { "a_weapon_right" }
	self.melee_weapons.mining_pick.shifts = { pos = Vector3(0.5,-8,0) }
	self.melee_weapons.mining_pick.stats = { concealment = 1, weight = 25, length = 15, damage_types = { front = "piercing", back = "puncturing" } }
	self.melee_weapons.fireaxe.twohanded = true
	self.melee_weapons.fireaxe.animset = "sword"
	self.melee_weapons.fireaxe.shifts = { pos = Vector3(0.5,-4,0) }
	self.melee_weapons.fireaxe.stats = { concealment = 1, weight = 30, length = 20, damage_types = { front = "slashing", back = "puncturing" } }
	self.melee_weapons.cs.twohanded = true
	self.melee_weapons.cs.large = true
	self.melee_weapons.cs.animset = "cs"
	self.melee_weapons.cs.stats = { concealment = 1, weight = 35, length = 11, damage_types = { front = "slashing", back = "slashing", tip = "slashing" } }
	self.melee_weapons.nin.animset = "nin"
	self.melee_weapons.nin.shifts = { rot = Rotation(180,90,180) }
	self.melee_weapons.nin.stats = { concealment = 1, weight = 38, length = 4, damage_types = dmgtype_presets.pencil }

	self.melee_weapons.shillelagh.animset = "knife"
	self.melee_weapons.shillelagh.stats = { concealment = 1, weight = 4, length = 15 }
	self.melee_weapons.barbedwire.animset = "sword"
	self.melee_weapons.barbedwire.twohanded = true
	self.melee_weapons.barbedwire.align_objects = { "a_weapon_right" }
	self.melee_weapons.barbedwire.shifts = { pos = Vector3(0.5,0,0) }
	self.melee_weapons.barbedwire.stats = { concealment = 1, weight = 12, length = 25, damage_types = { front = "puncturing", back = "puncturing" } }


	self.melee_weapons.detector.animset = "knife"
	self.melee_weapons.detector.shifts = { pos = Vector3(0,-7,0) }
	self.melee_weapons.detector.stats = { concealment = 1, weight = 4, length = 12 }
	self.melee_weapons.model24.animset = "knife"
	self.melee_weapons.model24.stats = { concealment = 1, weight = 4, length = 8 }
	self.melee_weapons.oldbaton.animset = "knife"
	self.melee_weapons.oldbaton.stats = { concealment = 1, weight = 6, length = 15 }

	self.melee_weapons.buck.animset = "buck"
	self.melee_weapons.buck.shifts = { pos = Vector3(0,0,0), rot = Rotation(0,0,45) }
	self.melee_weapons.buck.stats = { concealment = 1, weight = 15, length = 12 }

	self.melee_weapons.brass_knuckles.animset = "fists_mirrored"
	self.melee_weapons.brass_knuckles.shifts = { pos = Vector3(0,0,1.5), rot = Rotation(0,0,180) }
	self.melee_weapons.brass_knuckles.stats = { concealment = 1, weight = 2, length = 0, fist_addon = true }

	self.melee_weapons.cqc.info_id = nil
    self.melee_weapons.cqc.animset = "pencil"
	self.melee_weapons.cqc.stats = { concealment = 1, weight = 3, length = 6, damage_types = dmgtype_presets.pencil }

    self.melee_weapons.twins.animset = "pencil"
	self.melee_weapons.twins.shifts = { rot = Rotation(0,0,90) }
	self.melee_weapons.twins.stats = { concealment = 1, weight = 5, length = 13, damage_types = dmgtype_presets.pencil }

	self.melee_weapons.push.animset = "fists_mirrored"
	self.melee_weapons.push.shifts = { pos = Vector3(0,0,1.5), rot = Rotation(180,0,180) }
	self.melee_weapons.push.stats = { concealment = 1, weight = 2, length = 4, damage_types = dmgtype_presets.pencil, fist_addon = true }

	self.melee_weapons.fairbair.animset = "knife"
	self.melee_weapons.fairbair.shifts = { rot = Rotation(0,0,90) }
	self.melee_weapons.fairbair.stats = { concealment = 1, weight = 4, length = 6, damage_types = dmgtype_presets.knife_double }

	self.melee_weapons.tiger.animset = "fists_mirrored"
	self.melee_weapons.tiger.shifts = { pos = Vector3(0,0,3), rot = Rotation(0,180,0) }
	self.melee_weapons.tiger.stats = { concealment = 1, weight = 6, length = 3, damage_types = dmgtype_presets.pencil, fist_addon = true }

	self.melee_weapons.scoutknife.animset = "knife"
	self.melee_weapons.scoutknife.shifts = { pos = Vector3(0,2,0) }
	self.melee_weapons.scoutknife.stats = { concealment = 1, weight = 1, length = 3, damage_types = dmgtype_presets.knife }

	self.melee_weapons.gerber.animset = "knife"
	self.melee_weapons.gerber.stats = { concealment = 1, weight = 2, length = 4, damage_types = dmgtype_presets.knife }

	self.melee_weapons.switchblade.animset = "knife"
	self.melee_weapons.switchblade.stats = { concealment = 1, weight = 1, length = 4, damage_types = dmgtype_presets.knife }

	self.melee_weapons.wing.nochargeanim = true
	self.melee_weapons.wing.animset = "knife"
	self.melee_weapons.wing.stats = { concealment = 1, weight = 2, length = 4, damage_types = dmgtype_presets.knife }

	self.melee_weapons.scalper.animset = "knife"
	self.melee_weapons.scalper.stats = { concealment = 1, weight = 6, length = 14, damage_types = dmgtype_presets.knife }

	self.melee_weapons.pugio.animset = "knife"
	self.melee_weapons.pugio.shifts = { pos = Vector3(0,-1,0) }
	self.melee_weapons.pugio.stats = { concealment = 1, weight = 2, length = 4, damage_types = dmgtype_presets.knife_double }

	self.melee_weapons.bowie.animset = "knife"
	self.melee_weapons.bowie.shifts = { pos = Vector3(0,1,0), rot = Rotation(0,0,180) }
	self.melee_weapons.bowie.stats = { concealment = 1, weight = 7, length = 12, damage_types = dmgtype_presets.knife }
	self.melee_weapons.grip.animset = "knife"
	self.melee_weapons.grip.shifts = { rot = Rotation(0,0,180) }
	self.melee_weapons.grip.stats = { concealment = 1, weight = 4, length = 7, damage_types = dmgtype_presets.knife_double }

	self.melee_weapons.happy.animset = "knife"
	self.melee_weapons.happy.nochargeanim = true
	self.melee_weapons.happy.noswinganim = true
	self.melee_weapons.happy.stats = { concealment = 1, weight = 4, length = 12 }
	self.melee_weapons.baton.animset = "knife"
	self.melee_weapons.baton.stats = { concealment = 1, weight = 5, length = 15 }

	self.melee_weapons.bayonet.animset = "knife"
	self.melee_weapons.bayonet.shifts = { pos = Vector3(0,-2,0) }
	self.melee_weapons.bayonet.stats = { concealment = 1, weight = 3, length = 5, damage_types = dmgtype_presets.knife }
	self.melee_weapons.x46.animset = "knife"
	self.melee_weapons.x46.stats = { concealment = 1, weight = 3, length = 6, damage_types = dmgtype_presets.knife }
	self.melee_weapons.kabar.animset = "knife"
	self.melee_weapons.kabar.stats = { concealment = 1, weight = 3, length = 7, damage_types = dmgtype_presets.knife }
	self.melee_weapons.kampfmesser.animset = "knife"
	self.melee_weapons.kampfmesser.stats = { concealment = 1, weight = 3, length = 7, damage_types = dmgtype_presets.knife }
	self.melee_weapons.kabartanto.animset = "knife"
	self.melee_weapons.kabartanto.stats = { concealment = 1, weight = 3, length = 8, damage_types = dmgtype_presets.knife }

	self.melee_weapons.funder_strike.sounds.hit_air = self.melee_weapons.happy.sounds.hit_air
	self.melee_weapons.funder_strike.sounds.hit_gen = self.melee_weapons.happy.sounds.hit_gen
	self.melee_weapons.funder_strike.sounds.hit_body = self.melee_weapons.happy.sounds.hit_body
	self.melee_weapons.funder_strike.animset = "knife"
	self.melee_weapons.funder_strike.chargeanimoffset = 0.8
	self.melee_weapons.funder_strike.info_id = nil
	self.melee_weapons.funder_strike.stats = { concealment = 1, weight = 6, length = 15, damage_special = { tip = "shocking" } }

	self.melee_weapons.rambo.animset = "knife"
	self.melee_weapons.rambo.stats = { concealment = 1, weight = 5, length = 9, damage_types = dmgtype_presets.knife }
	self.melee_weapons.becker.animset = "knife"
	self.melee_weapons.becker.stats = { concealment = 1, weight = 6, length = 7, damage_types = dmgtype_presets.knife }

	self.melee_weapons.zeus.sounds.hit_air = self.melee_weapons.brass_knuckles.sounds.hit_air
	self.melee_weapons.zeus.sounds.hit_gen = self.melee_weapons.brass_knuckles.sounds.hit_gen
	self.melee_weapons.zeus.sounds.hit_body = self.melee_weapons.brass_knuckles.sounds.hit_body
	self.melee_weapons.zeus.info_id = nil
	self.melee_weapons.zeus.animset = "fists"
	self.melee_weapons.zeus.shifts = { pos = Vector3(0,0,2), rot = Rotation(0,0,180) }
	self.melee_weapons.zeus.stats = { concealment = 1, weight = 7, length = 3, damage_types = { tip = "puncturing" }, fist_addon = true, damage_special = { tip = "shocking" } }
	self.melee_weapons.oxide.animset = "knife"
	self.melee_weapons.oxide.stats = { concealment = 1, weight = 7, length = 10, damage_types = { front = "slashing", tip = "slashing" } }
	self.melee_weapons.gator.animset = "knife"
	self.melee_weapons.gator.shifts = { pos = Vector3(0,-3,1) }
	self.melee_weapons.gator.stats = { concealment = 1, weight = 8, length = 12, damage_types = { front = "slashing", back = "piercing" } }

	self.melee_weapons.taser.sounds.hit_air = self.melee_weapons.microphone.sounds.hit_air
	self.melee_weapons.taser.sounds.hit_gen = self.melee_weapons.microphone.sounds.hit_gen
	self.melee_weapons.taser.sounds.hit_body = self.melee_weapons.microphone.sounds.hit_body
	self.melee_weapons.taser.info_id = nil
	self.melee_weapons.taser.animset = "knife"
	self.melee_weapons.taser.stats = { concealment = 1, weight = 9, length = 7, damage_types = { tip = "puncturing" }, damage_special = { tip = "shocking" } }

	self.melee_weapons.agave.animset = "knife"
	self.melee_weapons.agave.shifts = { pos = Vector3(0,1,0) }
	self.melee_weapons.agave.stats = { concealment = 1, weight = 6, length = 20, damage_types = dmgtype_presets.knife }

	self.melee_weapons.tomahawk.animset = "knife"
	self.melee_weapons.tomahawk.stats = { concealment = 1, weight = 9, length = 13, damage_types = dmgtype_presets.cleaver }

	self.melee_weapons.ballistic.animset = "knife"
	self.melee_weapons.ballistic.shifts = { pos = Vector3(0,-3,0) }
	self.melee_weapons.ballistic.stats = { concealment = 1, weight = 6, length = 5, damage_types = dmgtype_presets.knife_double }

    self.melee_weapons.hauteur.animset = "knife"
	self.melee_weapons.hauteur.shifts = { pos = Vector3(0,4,0), rot = Rotation(0,0,180) }
	self.melee_weapons.hauteur.stats = { concealment = 1, weight = 3, length = 8, damage_types = dmgtype_presets.knife }

	--self.melee_weapons.morning.twohanded = true
	--self.melee_weapons.morning.animset = "sword"
	self.melee_weapons.morning.animset = "knife"
	self.melee_weapons.morning.stats = { concealment = 1, weight = 16, length = 14, damage_types = { front = "puncturing", back = "puncturing", tip = "puncturing" } }

	self.melee_weapons.beardy.twohanded = true
	self.melee_weapons.beardy.animset = "sword"
	self.melee_weapons.beardy.shifts = { pos = Vector3(0.5,0,0) }
	self.melee_weapons.beardy.stats = { concealment = 1, weight = 15, length = 25, damage_types = dmgtype_presets.cleaver }

	self.melee_weapons.sandsteel.twohanded = true
	self.melee_weapons.sandsteel.animset = "sword"
	self.melee_weapons.sandsteel.shifts = { pos = Vector3(0,7,0) }
	self.melee_weapons.sandsteel.stats = { concealment = 1, weight = 11, length = 30, damage_types = dmgtype_presets.knife }

	self.melee_weapons.dingdong.twohanded = true
	self.melee_weapons.dingdong.animset = "sword"
	self.melee_weapons.dingdong.shifts = { pos = Vector3(0.5,-2,0) }
	self.melee_weapons.dingdong.stats = { concealment = 1, weight = 30, length = 15 }

	self.melee_weapons.great.twohanded = true
	self.melee_weapons.great.large = true
	self.melee_weapons.great.animset = "sword"
	self.melee_weapons.great.shifts = { pos = Vector3(0,3,0) }
	self.melee_weapons.great.stats = { concealment = 1, weight = 25, length = 35, damage_types = dmgtype_presets.knife_double }

	self.melee_weapons.spoon.twohanded = true
	self.melee_weapons.spoon.animset = "sword"
	self.melee_weapons.spoon.stats = { concealment = 1, weight = 25, length = 20 }
	self.melee_weapons.spoon_gold.twohanded = true
	self.melee_weapons.spoon_gold.animset = "sword"
	self.melee_weapons.spoon_gold.stats = { concealment = 1, weight = 50, length = 20 }
	self.melee_weapons.alien_maul.twohanded = true
	self.melee_weapons.alien_maul.animset = "sword"
	self.melee_weapons.alien_maul.shifts = { pos = Vector3(0,3,0) }
	self.melee_weapons.alien_maul.stats = { concealment = 1, weight = 40, length = 20 }
	self.melee_weapons.ostry.animset = "ostry"
	self.melee_weapons.ostry.shifts = { rot = Rotation(90,-90,0) }
	self.melee_weapons.ostry.stats = { concealment = 1, weight = 8, length = 8, damage_types = dmgtype_presets.knife_double }
	self.melee_weapons.piggy_hammer.pcs = false
	self.melee_weapons.piggy_hammer.twohanded = true
	self.melee_weapons.piggy_hammer.animset = "sword"
	self.melee_weapons.piggy_hammer.stats = { concealment = 1, weight = 50, length = 25 }

	self.melee_weapons.fear.info_id = nil
	self.melee_weapons.fear.pcs = false
	self.melee_weapons.freedom.pcs = false



	for i, k in pairs(self.melee_weapons) do
        k.anim_attack_vars = { "var1", "var2", "var3", "var4" }

		if not (k.stats.weight and k.stats.length) or ((k.stats.weight*(k.stats.length+5))>400) then
			k.large = true
		end
	end



	--bayonet knife and gerber uses a left-handed anim that could be used for quick melee maybe?

end)