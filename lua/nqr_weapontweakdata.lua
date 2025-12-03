require("lib/tweak_data/WeaponFactoryTweakData")
require("lib/tweak_data/WeaponFalloffTweakData")
local PICKUP = {
	AR_LOW_CAPACITY = 7,
	SHOTGUN_HIGH_CAPACITY = 4,
	OTHER = 1,
	LMG_CAPACITY = 9,
	AR_MED_CAPACITY = 3,
	SNIPER_HIGH_DAMAGE = 6,
	AR_HIGH_CAPACITY = 2,
	SNIPER_LOW_DAMAGE = 5,
	AR_DMR_CAPACITY = 8
}
local SELECTION = {
	SECONDARY = 1,
	PRIMARY = 2,
	UNDERBARREL_SECONDARY = 3,
	UNDERBARREL_PRIMARY = 4
}
local FALLOFF_TEMPLATE = WeaponFalloffTemplate.setup_weapon_falloff_templates()
WeaponTweakData = WeaponTweakData or class()

function WeaponTweakData:_init_bessy(weapon_data)
	self.bessy = {
		categories = {
			"dmr"
		},
		upgrade_blocks = {
			weapon = {
				"clip_ammo_increase"
			}
		},
		--has_description = true,
		damage_melee = weapon_data.damage_melee_default,
		damage_melee_effect_mul = weapon_data.damage_melee_effect_multiplier_default,
		sounds = {}
	}
	self.bessy.sounds.fire = "musket_fire"
	self.bessy.sounds.dryfire = "primary_dryfire"
	self.bessy.sounds.enter_steelsight = "lmg_steelsight_enter"
	self.bessy.sounds.leave_steelsight = "lmg_steelsight_exit"
	self.bessy.timers = {
		reload_not_empty = 11.1,
		reload_empty = 11.1,
		unequip = 0.6,
		equip = 0.5
	}
	self.bessy.name_id = "bm_w_bessy"
	self.bessy.desc_id = "bm_w_bessy_desc"
	self.bessy.description_id = "des_bessy"
	self.bessy.global_value = "pda10"
	self.bessy.texture_bundle_folder = "pda10"
	self.bessy.unlock_func = "has_unlocked_bessy"
	self.bessy.muzzleflash = "effects/payday2/particles/weapons/bessy_muzzle"
	self.bessy.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.bessy.use_data = {
		selection_index = SELECTION.PRIMARY,
		align_place = "left_hand"
	}
	self.bessy.DAMAGE = 1
	self.bessy.damage_falloff = FALLOFF_TEMPLATE.SNIPER_FALL_HIGH
    self.bessy.CLIP_AMMO_MAX = 1
	self.bessy.NR_CLIPS_MAX = 15
	self.bessy.AMMO_MAX = self.bessy.CLIP_AMMO_MAX * self.bessy.NR_CLIPS_MAX
	self.bessy.AMMO_PICKUP = {
		0.2,
		0.8
	}
	self.bessy.FIRE_MODE = "single"
	self.bessy.fire_mode_data = {
		fire_rate = 1
	}
	self.bessy.CAN_TOGGLE_FIREMODE = false
	self.bessy.single = {
		fire_rate = 20
	}
	self.bessy.spread = {
		standing = self.new_m4.spread.standing,
		crouching = self.new_m4.spread.crouching,
		steelsight = self.new_m4.spread.steelsight,
		moving_standing = self.new_m4.spread.moving_standing,
		moving_crouching = self.new_m4.spread.moving_crouching,
		moving_steelsight = self.new_m4.spread.moving_steelsight
	}
	self.bessy.kick = {
		standing = {
			3,
			4.8,
			-0.3,
			0.3
		}
	}
	self.bessy.kick.crouching = self.bessy.kick.standing	self.bessy.kick.crouching = self.bessy.kick.standing
	self.bessy.kick.steelsight = self.bessy.kick.standing	self.bessy.kick.steelsight = self.bessy.kick.standing
	self.bessy.crosshair = {
		standing = {},
		crouching = {},
		steelsight = {}
	}
	self.bessy.crosshair.standing.offset = 1.14	self.bessy.crosshair.standing.offset = 1.14
	self.bessy.crosshair.standing.moving_offset = 1.8	self.bessy.crosshair.standing.moving_offset = 1.8
	self.bessy.crosshair.standing.kick_offset = 1.6	self.bessy.crosshair.standing.kick_offset = 1.6
	self.bessy.crosshair.crouching.offset = 1.1	self.bessy.crosshair.crouching.offset = 1.1
	self.bessy.crosshair.crouching.moving_offset = 1.6	self.bessy.crosshair.crouching.moving_offset = 1.6
	self.bessy.crosshair.crouching.kick_offset = 1.4	self.bessy.crosshair.crouching.kick_offset = 1.4
	self.bessy.crosshair.steelsight.hidden = true	self.bessy.crosshair.steelsight.hidden = true
	self.bessy.crosshair.steelsight.offset = 1	self.bessy.crosshair.steelsight.offset = 1
	self.bessy.crosshair.steelsight.moving_offset = 1	self.bessy.crosshair.steelsight.moving_offset = 1
	self.bessy.crosshair.steelsight.kick_offset = 1.14	self.bessy.crosshair.steelsight.kick_offset = 1.14
	self.bessy.shake = {
		fire_multiplier = 3.5,
		fire_steelsight_multiplier = -3.5
	}
	self.bessy.autohit = weapon_data.autohit_snp_default	self.bessy.autohit = weapon_data.autohit_snp_default
	self.bessy.aim_assist = weapon_data.aim_assist_snp_default	self.bessy.aim_assist = weapon_data.aim_assist_snp_default
	self.bessy.weapon_hold = "bessy"	self.bessy.weapon_hold = "bessy"
	self.bessy.animations = {
		equip_id = "equip_bessy",		equip_id = "equip_bessy",
		recoil_steelsight = true
	}
	self.bessy.can_shoot_through_enemy = true	self.bessy.can_shoot_through_enemy = true
	self.bessy.can_shoot_through_shield = true	self.bessy.can_shoot_through_shield = true
	self.bessy.can_shoot_through_wall = true	self.bessy.can_shoot_through_wall = true
	self.bessy.panic_suppression_chance = 0.2	self.bessy.panic_suppression_chance = 0.2
	self.bessy.stats = {
		zoom = 1,
		total_ammo_mod = 21,
		damage = 200,
		alert_size = 7,
		spread = 24,
		spread_moving = 24,
		recoil = 1,
		value = 9,
		extra_ammo = 51,
		reload = 11,
		suppression = 5,
		concealment = 6
	}
	self.bessy.special_damage_multiplier = 5	self.bessy.special_damage_multiplier = 5
	self.bessy.armor_piercing_chance = 1	self.bessy.armor_piercing_chance = 1
	self.bessy.stats_modifiers = {
		damage = 50
	}
end

Hooks:PostHook( WeaponTweakData, "_init_new_weapons", "nqr_WeaponTweakData:_init_new_weapons", function(self, weapon_data)
    self:_init_bessy(weapon_data)
end)

Hooks:PostHook( WeaponTweakData, "init", "nqr_weapontweakdata:init", function(self)

function WeaponTweakData:_init_stats()
	self.stats = {
		alert_size = {
			30000,
			20000,
			15000,
			10000,
			7500,
			6000,
			4500,
			4000,
			3500,
			1800,
			1500,
			1200,
			1000,
			850,
			700,
			500,
			350,
			200,
			100,
			0
		},
		suppression = {
			4.5,
			3.9,
			3.6,
			3.3,
			3,
			2.8,
			2.6,
			2.4,
			2.2,
			1.6,
			1.5,
			1.4,
			1.3,
			1.2,
			1.1,
			1,
			0.8,
			0.6,
			0.4,
			0.2
		},
		damage = {
			0.1,
			0.2,
			0.3,
			0.4,
			0.5,
			0.6,
			0.7,
			0.8,
			0.9,
			1,
			1.1,
			1.2,
			1.3,
			1.4,
			1.5,
			1.6,
			1.7,
			1.8,
			1.9,
			2,
			2.1,
			2.2,
			2.3,
			2.4,
			2.5,
			2.6,
			2.7,
			2.8,
			2.9,
			3,
			3.1,
			3.2,
			3.3,
			3.4,
			3.5,
			3.6,
			3.7,
			3.8,
			3.9,
			4,
			4.1,
			4.2,
			4.3,
			4.4,
			4.5,
			4.6,
			4.7,
			4.8,
			4.9,
			5,
			5.1,
			5.2,
			5.3,
			5.4,
			5.5,
			5.6,
			5.7,
			5.8,
			5.9,
			6,
			6.1,
			6.2,
			6.3,
			6.4,
			6.5,
			6.6,
			6.7,
			6.8,
			6.9,
			7,
			7.1,
			7.2,
			7.3,
			7.4,
			7.5,
			7.6,
			7.7,
			7.8,
			7.9,
			8,
			8.1,
			8.2,
			8.3,
			8.4,
			8.5,
			8.6,
			8.7,
			8.8,
			8.9,
			9,
			9.1,
			9.2,
			9.3,
			9.4,
			9.5,
			9.6,
			9.7,
			9.8,
			9.9,
			10,
			10.1,
			10.2,
			10.3,
			10.4,
			10.5,
			10.6,
			10.7,
			10.8,
			10.9,
			11,
			11.1,
			11.2,
			11.3,
			11.4,
			11.5,
			11.6,
			11.7,
			11.8,
			11.9,
			12,
			12.1,
			12.2,
			12.3,
			12.4,
			12.5,
			12.6,
			12.7,
			12.8,
			12.9,
			13,
			13.1,
			13.2,
			13.3,
			13.4,
			13.5,
			13.6,
			13.7,
			13.8,
			13.9,
			14,
			14.1,
			14.2,
			14.3,
			14.4,
			14.5,
			14.6,
			14.7,
			14.8,
			14.9,
			15,
			15.1,
			15.2,
			15.3,
			15.4,
			15.5,
			15.6,
			15.7,
			15.8,
			15.9,
			16,
			16.1,
			16.2,
			16.3,
			16.4,
			16.5,
			16.6,
			16.7,
			16.8,
			16.9,
			17,
			17.1,
			17.2,
			17.3,
			17.4,
			17.5,
			17.6,
			17.7,
			17.8,
			17.9,
			18,
			18.1,
			18.2,
			18.3,
			18.4,
			18.5,
			18.6,
			18.7,
			18.8,
			18.9,
			19,
			19.1,
			19.2,
			19.3,
			19.4,
			19.5,
			19.6,
			19.7,
			19.8,
			19.9,
			20,
			20.1,
			20.2,
			20.3,
			20.4,
			20.5,
			20.6,
			20.7,
			20.8,
			20.9,
			21
		},
		zoom = {
			63,
			60,
			55,
			50,
			45,
			40,
			35,
			30,
			25,
			20
		}
	}
	if _G.IS_VR then
		self.stats.zoom = {
			30,
			30,
			30,
			30,
			30,
			20,
			20,
			20,
			20,
			20
		}
	end
	self.stats.spread = {
		2,
		1.92,
		1.84,
		1.76,
		1.68,
		1.6,
		1.52,
		1.44,
		1.36,
		1.28,
		1.2,
		1.12,
		1.04,
		0.96,
		0.88,
		0.8,
		0.72,
		0.64,
		0.56,
		0.48,
		0.4,
		0.32,
		0.24,
		0.16,
		0.08,
		0
	}
	self.stats.spread_moving = {
		2.5,
		2.42,
		2.34,
		2.26,
		2.18,
		2.1,
		2.02,
		1.94,
		1.86,
		1.78,
		1.7,
		1.62,
		1.54,
		1.46,
		1.38,
		1.3,
		1.22,
		1.14,
		1.06,
		0.98,
		0.9,
		0.82,
		0.74,
		0.66,
		0.58,
		0.5
	}
	self.stats.recoil = {
		3,
		2.9,
		2.8,
		2.7,
		2.6,
		2.5,
		2.4,
		2.3,
		2.2,
		2.1,
		2,
		1.9,
		1.8,
		1.7,
		1.6,
		1.5,
		1.4,
		1.3,
		1.2,
		1.1,
		1,
		0.9,
		0.8,
		0.7,
		0.6,
		0.5
	}
	self.stats.value = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10
	}
	self.stats.concealment = {
		0.3,
		0.4,
		0.5,
		0.6,
		0.65,
		0.7,
		0.75,
		0.8,
		0.825,
		0.85,
		1,
		1.05,
		1.1,
		1.15,
		1.2,
		1.225,
		1.25,
		1.275,
		1.3,
		1.325,
		1.35,
		1.375,
		1.4,
		1.425,
		1.45,
		1.475,
		1.5,
		1.525,
		1.55,
		1.6
	}
	self.stats.extra_ammo = {}

	for i = -100, 100, 2 do
		table.insert(self.stats.extra_ammo, i)
	end

	self.stats.total_ammo_mod = {}

	for i = -100, 100, 5 do
		table.insert(self.stats.total_ammo_mod, i / 100)
	end

	self.stats.reload = {}

	for i = 5, 20, 0.5 do
		if i <= 10 or i == math.floor(i) then
			table.insert(self.stats.reload, i / 10)
		end
	end
end

--DEFAULT STATS: TABLES TO NUMERIC
    self.stats.alert_size = 69
    self.stats.suppression = 4.5 --[20]0.2
    self.stats.extra_ammo = 69
    self.stats.spread = 69
    self.stats.spread_moving = 69
    self.stats.recoil = 69
    self.stats.damage = 69
    self.stats.value = 69
	self.stats.concealment = 1.6 --[1]0.3
    self.stats.total_ammo_mod = 0
	self.stats.reload = 69
    self.stats.zoom = 1

--DISABLED
    local disabled_weps = {
    ------ASSAULT RIFLE
        "x_olympic",
        "x_hajk",
        "x_akmsu",
    ------SMG
        "x_coal",
        "x_m1928",
        "x_mp5",
        "x_erma",
        --"x_sr2",
        "x_p90",
        "x_m45",
        "x_mp7",
        "x_uzi",
        "x_sterling",
        --"x_cobray",
        "x_polymer",
        "x_schakal",
        "x_vityaz",
        "x_shepheard",
    ------SHOTGUN
        "x_basset",
        "x_sko12",
        "x_rota",
    ------AKIMBO
        "x_model3",
    ------SPECIAL
        "saw",
        "saw_secondary",
        "shuno",
        "hunter",
        "plainsrider",
        "frankish",
        "ecp",
        "long",
        "elastic",
        "arblast",
        "flamethrower_mk2",
        "system",
        "hailstorm",
    } for _, wep in pairs(disabled_weps) do self[wep].use_data.selection_index = 3 end

--SECONDARY TO PRIMARY
    local to_primary_weps = {
    ------ASSAULT RIFLE
        "olympic",
        "hajk",
        "akmsu",
    ------SMG
        "coal",
        "m1928",
        "new_mp5",
        "erma",
        "p90",
        "m45",
        "mp7",
        "uzi",
        "sterling",
        --"cobray",
        "polymer",
        "schakal",
        "vityaz",
        "shepheard",
    ------SNIPER RIFLE
        "scout",
        "victor",
    ------SHOTGUN
        "serbu",
        "basset",
        "striker",
        "rota",
        "m37",
        "ultima",
        "coach",
    ------MACHINE PISTOL
        "fmg9",
        "x_fmg9",
    ------SPECIAL
        "system",
        "rpg7",
        "china",
        "arbiter",
        "ms3gl",
        "ray",
    } for _, wep in pairs(to_primary_weps) do if self[wep] and not table.contains(disabled_weps, wep) then self[wep].use_data.selection_index = 2 end end

--AKIMBO TO SECONDARY
    local to_secondary_weps = {
    ------PISTOL
        "x_ppk",
        "x_stech",
        "x_g17",
        "x_g18c",
        "jowi",
        "x_g22c",
        "x_shrew",
        "x_c96",
        "x_beer",
        "x_czech",
        "x_holt",
        "x_maxim9",
        "x_pl14",
        "x_sparrow",
        "x_legacy",
        "x_breech",
        "x_b92fs",
        "x_packrat",
        "x_usp",
        "x_p226",
        "x_hs2000",
        "x_1911",
        "x_m1911",
        "x_type54",
        "x_deagle",
        --"x_contender",
        "x_korth",
        "x_2006m",
        "x_chinchilla",
        "x_rage",
        --"x_model3",
        "x_judge",
    ------MACHINE PISTOL
        "x_mac10",
        "x_pm9",
        "x_scorpion",
        "x_baka",
        "x_mp9",
        "x_tec9",
        "x_sr2",
        "x_cobray",
    ------CUSTOM
        "x_lemming",
        "x_rsh12",
    } for _, wep in pairs(to_secondary_weps) do if self[wep] then self[wep].use_data.selection_index = 1 end end

--CATEGORIES
    --ASSAULT RIFLE
    self.rpk.categories = {"assault_rifle"}
    self.olympic.categories = {"assault_rifle"}
    self.hajk.categories = {"assault_rifle"}
    self.akmsu.categories = {"assault_rifle"}
    self.x_olympic.categories = {"assault_rifle"}
    self.x_hajk.categories = {"assault_rifle"}
    self.x_akmsu.categories = {"assault_rifle"}
    self.victor.categories = {"assault_rifle"}
    --DMR
    self.scar.categories = {"dmr"}
    self.new_m14.categories = {"dmr"}
    self.ching.categories = {"dmr"}
    self.galil.categories = {"dmr"}
    self.shak12.categories = {"dmr"}
    self.contraband.categories = {"dmr"}
    self.fal.categories = {"dmr"}
    self.g3.categories = {"dmr"}
    self.sbl.categories = {"dmr"}
    self.tti.categories = {"dmr"}
    self.winchester1874.categories = {"dmr"}
    self.siltstone.categories = {"dmr"}
    self.qbu88.categories = {"dmr"}
    self.hcar.categories = {"dmr"}
    --SMG
    self.sub2000.categories = {"smg"}
    --MACHINE PISTOL
    self.mac10.categories = {"machine_pistol"}
    self.pm9.categories = {"machine_pistol"}
    self.scorpion.categories = {"machine_pistol"}
    self.baka.categories = {"machine_pistol"}
    self.mp9.categories = {"machine_pistol"}
    self.tec9.categories = {"machine_pistol"}
    self.fmg9.categories = {"machine_pistol"}
    self.sr2.categories = {"machine_pistol"}
    self.cobray.categories = {"machine_pistol"}
    self.x_mac10.categories = {"akimbo", "machine_pistol"}
    self.x_pm9.categories = {"akimbo", "machine_pistol"}
    self.x_scorpion.categories = {"akimbo", "machine_pistol"}
    self.x_baka.categories = {"akimbo", "machine_pistol"}
    self.x_mp9.categories = {"akimbo", "machine_pistol"}
    self.x_tec9.categories = {"akimbo", "machine_pistol"}
    self.x_cobray.categories = {"akimbo", "machine_pistol"}
    self.x_sr2.categories = {"akimbo", "machine_pistol"}
    --PISTOL
    self.contender.categories = {"pistol"}
    --REVOLVER
    self.judge.categories = {"revolver"}
    self.new_raging_bull.categories = {"revolver"}
    self.korth.categories = {"revolver"}
    self.chinchilla.categories = {"revolver"}
    self.model3.categories = {"revolver"}
    self.rsh12.categories = {"revolver"}
    self.mateba.categories = {"revolver"}
    self.peacemaker.categories = {"revolver"}
    self.x_rage.categories = {"akimbo", "revolver"}
    self.x_korth.categories = {"akimbo", "revolver"}
    self.x_chinchilla.categories = {"akimbo", "revolver"}
    self.x_model3.categories = {"akimbo", "revolver"}
    self.x_2006m.categories = {"akimbo", "revolver"}
    self.x_judge.categories = {"akimbo", "revolver"}
    --CUSTOM
    if self.x_rsh12 then self.x_rsh12.categories = {"akimbo", "revolver"} end
    if self.x_fmg9 then self.x_fmg9.categories = {"akimbo", "machine_pistol"} end



--MUZZLEFLASHES
    self.muzzleflashes = {
        brake2 = "effects/payday2/particles/weapons/308_muzzle",
        brake3 = "effects/payday2/particles/weapons/50cal_auto_fps"
    }



--RELOAD STATS
    self.r_timings = {
        topcover = 0.8,
        doublebutton = 0.5,
        paddle = 0.3,
        pushbutton = 0.2,

        rotate = 1.0,
        none = 0.6,
        quarter = 0.5,
        half = 0.3
    }

--CALIBERS
    self.calibers = {
      --RIFLE
        ["7.62x51"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 147,
                default_speed = 850,
                default_energy = 3470,
                default_barrel = 22,
                caliber_weight = 25,
            },
        },
        ["7.62x54 R"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 181,
                default_speed = 786,
                default_energy = 3614,
                default_barrel = 28,
                caliber_weight = 26,
            },
        },
        [".50 BMG"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 750,
                default_speed = 860,
                default_energy = 18000,
                default_barrel = 45,
                caliber_weight = 114,
            },
        },
        [".338 LM"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 300,
                default_speed = 847,
                default_energy = 6973,
                default_barrel = 27.5,
                caliber_weight = 47,
            },
        },
        ["7.92x57"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 181,
                default_speed = 820,
                default_energy = 3934,
                default_barrel = 23.6,
                caliber_weight = 27,
            },
        },
        [".30-06"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 165,
                default_speed = 850,
                default_energy = 3894,
                default_barrel = 24,
                caliber_weight = 26,
            },
        },
        ["12.7x55"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 108,
                default_speed = 900,
                default_energy = 2835,
                default_barrel = 14.7,
                caliber_weight = 44,
            },
            { name = "Sub FMJ",
                proj_type = "pointy",
                proj_weight = 509,
                default_speed = 300,
                default_energy = 1484,
                default_barrel = 14.7,
                caliber_weight = 70,
            },
            { name = "STs-130",
                proj_type = "pointy",
                proj_weight = 1173,
                default_speed = 295,
                default_energy = 3307,
                default_barrel = 17.7,
                caliber_weight = 100, --roughly
            },
        },
        [".45-70"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 300,
                default_speed = 693,
                default_energy = 4676,
                default_barrel = 24,
                caliber_weight = 41,
            },
        },
        [".300 WM"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 180,
                default_speed = 973,
                default_energy = 5526,
                default_barrel = 24,
                caliber_weight = 32,
            },
        },
        [".50 Beo"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 325,
                default_speed = 550,
                default_energy = 3170,
                default_barrel = 16,
                caliber_weight = 33.6
            },
        },
      --INTERMEDIATE
        ["5.56x45"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 62,
                default_speed = 948,
                default_energy = 1797,
                default_barrel = 20,
                caliber_weight = 12,
            },
        },
        ["7.62x39"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 122,
                default_speed = 730,
                default_energy = 2100,
                default_barrel = 20,
                caliber_weight = 17.2,
            },
        },
        ["5.45x39"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 56,
                default_speed = 880,
                default_energy = 1400,
                default_barrel = 16.3,
                caliber_weight = 10.7,
            },
        },
        ["9x39"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 278,
                default_speed = 327,
                default_energy = 964,
                default_barrel = 10.5,
                caliber_weight = 23,
            },
        },
        ["5.8x42"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 77,
                default_speed = 870,
                default_energy = 1900,
                default_barrel = 21.9,
                caliber_weight = 12.9,
            },
        },
        [".300 BLK"] = {
            class = "rifle",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 125,
                default_speed = 675,
                default_energy = 1840,
                default_barrel = 16,
                caliber_weight = 13.9,
            },
            { name = "Sub FMJ",
                proj_type = "pointy",
                proj_weight = 220,
                default_speed = 310,
                default_energy = 675,
                default_barrel = 16,
                caliber_weight = 19.9,
            },
        },
      --SHOTGUN
        ["12 gauge"] = {
            class = "shotgun",
            { name = "00 Buck",
                proj_type = "sphere",
                proj_amount = 12,
                proj_size = 8.38,
                proj_weight = 12*54,
                default_speed = 390,
                default_energy = 3250,
                default_barrel = 18,
                caliber_weight = 40,
            },
            { name = "000 Buck",
                proj_type = "sphere",
                proj_amount = 8,
                proj_size = 9.14,
                proj_weight = 8*70,
                default_speed = 400,
                default_energy = 2950,
                default_barrel = 18,
                caliber_weight = 40,
            },
            { name = "Slug",
                proj_type = "pointy",
                proj_size = 17.52,
                proj_weight = 300,
                default_speed = 600,
                default_energy = 3450,
                default_barrel = 18,
                caliber_weight = 40,
            },
            { name = "Slug AP",
                proj_type = "sphere",
                proj_size = 18.51,
                proj_weight = 630,
                proj_ap = true,
                default_speed = 427,
                default_energy = 3700,
                default_barrel = 18,
                caliber_weight = 40,
            },
            { name = "Flechette",
                proj_type = "arrow",
                proj_amount = 20,
                proj_size = 2,
                proj_weight = 140,
                default_speed = 600,
                default_energy = 1700,
                default_barrel = 18,
                caliber_weight = 40,
            },
            { name = "Dragon's Breath",
                proj_type = "sphere",
                proj_amount = 50,
                proj_size = 2,
                proj_weight = 1,
                default_speed = 100,
                default_energy = 1000,
                default_barrel = 18,
                caliber_weight = 40,
            },
        },
        [".410 bore"] = {
            class = "shotgun",
            { name = "00 Buck",
                proj_type = "sphere",
                proj_amount = 4,
                proj_size = 8.38,
                proj_weight = 4*54,
                default_speed = 400,
                default_energy = 1100,
                default_barrel = 18,
                caliber_weight = 25,
            },
            { name = "000 Buck",
                proj_type = "sphere",
                proj_amount = 3,
                proj_size = 9.14,
                proj_weight = 3*70,
                default_speed = 400,
                default_energy = 1070,
                default_barrel = 18,
                caliber_weight = 25,
            },
            { name = "Slug",
                proj_type = "pointy",
                proj_size = 10.16,
                proj_weight = 200,
                default_speed = 400,
                default_energy = 1020,
                default_barrel = 18,
                caliber_weight = 25,
            },
            { name = "Flechette",
                proj_type = "arrow",
                proj_amount = 7,
                proj_size = 2,
                proj_weight = 56,
                default_speed = 533,
                default_energy = 515,
                default_barrel = 18,
                caliber_weight = 25,
            },
        },
      --PISTOL
        [".32 ACP"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 73,
                default_speed = 318,
                default_energy = 240,
                default_barrel = 4,
                caliber_weight = 7.83,
            },
        },
        [".380 ACP"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 95,
                default_speed = 300,
                default_energy = 275,
                default_barrel = 3.7,
                caliber_weight = 9.5,
            },
        },
        ["9x18"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 95,
                default_speed = 319,
                default_energy = 313,
                default_barrel = 3.8,
                caliber_weight = 10.2,
            },
        },
        ["9x19"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 124,
                default_speed = 350,
                default_energy = 494,
                default_barrel = 4.65,
                caliber_weight = 12.6,
            },
        },
        [".40 S&W"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 165,
                default_speed = 340,
                default_energy = 635,
                default_barrel = 4,
                caliber_weight = 16.7,
            },
        },
        [".45 ACP"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 230,
                default_speed = 290,
                default_energy = 639,
                default_barrel = 5,
                caliber_weight = 20.9,
            },
        },
        [".357 Mag"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 125,
                default_speed = 440,
                default_energy = 790,
                default_barrel = 4,
                caliber_weight = 15.7,
            },
        },
        [".44 Mag"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 240,
                default_speed = 450,
                default_energy = 1570,
                default_barrel = 7.5,
                caliber_weight = 24.5,
            },
        },
        [".50 AE"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 300,
                default_speed = 450,
                default_energy = 1965,
                default_barrel = 6,
                caliber_weight = 32,
            },
        },
        [".454 CSL"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 300,
                default_speed = 500,
                default_energy = 2458,
                default_barrel = 7.5,
                caliber_weight = 32,
            },
        },
        [".45 LC"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 200,
                default_speed = 300,
                default_energy = 602,
                default_barrel = 7,
                caliber_weight = 24.1,
            },
        },
        [".44 RU"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 246,
                default_speed = 230,
                default_energy = 420,
                default_barrel = 6.5,
                caliber_weight = 111,
            },
        },
        ["5.7x28"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 31,
                default_speed = 716,
                default_energy = 515,
                default_barrel = 10.3,
                caliber_weight = 6,
            },
        },
        ["4.6x30"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 26,
                default_speed = 725,
                default_energy = 447,
                default_barrel = 7.1,
                caliber_weight = 7.1,
            },
        },
        ["7.62x25"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "rounded",
                proj_weight = 90,
                default_speed = 409,
                default_energy = 488,
                default_barrel = 4.7,
                caliber_weight = 10.6,
            },
        },
        ["9x21"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "pointy",
                proj_weight = 122,
                default_speed = 390,
                default_energy = 601,
                default_barrel = 6.9,
                caliber_weight = 11,
            },
        },
        [".44-40"] = {
            class = "pistol",
            { name = "FMJ",
                proj_type = "flat",
                proj_weight = 200,
                default_speed = 379,
                default_energy = 933,
                default_barrel = 20,
                caliber_weight = 111
            },
        },
      --SPECIAL
        ["1.7x210mm Saw"] = {
            {
                proj_type = "rounded",
                proj_weight = 3000,
                default_speed = 80,
                default_energy = 600,
                default_barrel = 14.5,
                caliber_weight = 250,
            },
        },
        ["40x46mm"] = {
            {
                proj_type = "rounded",
                proj_weight = 3000,
                default_speed = 80,
                default_energy = 600,
                default_barrel = 14.5,
                caliber_weight = 250,
            },
        },
        ["25x40mm"] = {
            {
                proj_type = "rounded",
                proj_weight = 1200,
                default_speed = 210,
                default_energy = 1700,
                default_barrel = 16,
                caliber_weight = 108,
            },
        },
        ["PG-7VL"] = {
            {
                proj_type = "pointy",
                proj_weight = 40000,
                default_speed = 295,
                default_energy = 83442,
                default_barrel = 1,
                caliber_weight = 2600,
            },
        },
        [".71 Ball"] = {
            {
                proj_type = "sphere",
                proj_weight = 490,
                default_speed = 550,
                default_energy = 4800,
                default_barrel = 42,
                caliber_weight = 31,
            },
        },
    }
    local ammo_pickup_ratio = {
        rifle = {30*self.calibers["5.56x45"][1].default_energy, 0.6},
        pistol = {40*self.calibers["9x19"][1].default_energy, 0.4},
        shotgun = {12*self.calibers["12 gauge"][1].default_energy, 0.6},
    }
--

--TO ALL GUNS
    for wep, i in pairs(self) do
        if self[wep].stats then
            self[wep].stats.reload = 1
            self[wep].stats.zoom = 1
            if self[wep].animations then self[wep].animations.magazine_empty = nil end
            if self[wep].sounds and wep~="ching" then self[wep].sounds.magazine_empty = nil end
            --if self[wep].effects then self[wep].effects.magazine_empty = nil end
        end
    end
--



--THE STATS
------ASSAULT RIFLE
    self.new_m4.caliber = "5.56x45"
    self.new_m4.weight = 29
    self.new_m4.stats.alert_size = 7
    self.new_m4.stats.value = 1
    self.new_m4.stats.suppression = 10
    self.new_m4.stats.concealment = 21
    self.new_m4.timers = {
        reload_not_empty = 2.7,
        reload_empty = 3.5,
        unequip = 0.6,
        equip = 0.6 }
    self.new_m4.NR_CLIPS_MAX = 6
	self.new_m4.AMMO_MAX = self.new_m4.CLIP_AMMO_MAX * self.new_m4.NR_CLIPS_MAX
	self.new_m4.FIRE_MODE = "auto"
	self.new_m4.fire_mode_data.fire_rate = 0.075
	self.new_m4.CAN_TOGGLE_FIREMODE = true
	self.new_m4.auto = {
	    fire_rate = 0.11 }
	self.new_m4.spread = {
	    standing = 6,
	    crouching = 3,
	    steelsight = 3,
	    moving_standing = self.new_m4.spread.standing,
	    moving_crouching = self.new_m4.spread.crouching,
	    moving_steelsight = self.new_m4.spread.steelsight }
	self.new_m4.kick.crouching = self.new_m4.kick.standing
	self.new_m4.kick.steelsight = self.new_m4.kick.standing
	self.new_m4.crosshair = {
	    standing = {},
	    crouching = {},
	    steelsight = {} }
	self.new_m4.crosshair.standing.offset = 0.16
	self.new_m4.crosshair.standing.moving_offset = 0.8
	self.new_m4.crosshair.standing.kick_offset = 0.6
	self.new_m4.crosshair.crouching.offset = 0.08
	self.new_m4.crosshair.crouching.moving_offset = 0.7
	self.new_m4.crosshair.crouching.kick_offset = 0.4
	self.new_m4.crosshair.steelsight.hidden = true
	self.new_m4.crosshair.steelsight.offset = 0
	self.new_m4.crosshair.steelsight.moving_offset = 0
	self.new_m4.crosshair.steelsight.kick_offset = 0.1
	self.new_m4.shake = {
	    fire_multiplier = 1,
	    fire_steelsight_multiplier = -1
	}
	self.new_m4.weapon_hold = "m4"
	self.new_m4.animations = {
	    reload = "reload",
	    reload_not_empty = "reload_not_empty",
	    equip_id = "equip_m4",
	    recoil_steelsight = true,
	    magazine_empty = "last_recoil"
    }
	self.new_m4.panic_suppression_chance = 0.2
    self.new_m4.rise_factor = 0
    self.new_m4.bolt_release = "half"
    self.new_m4.eq_fr = {0,9,12}
    self.new_m4.shot_anim_mul = 1.25

    self.amcar.caliber = "5.56x45"
    self.amcar.weight = 27
	self.amcar.fire_mode_data.fire_rate = 0.075
    self.amcar.rise_factor = 0
    self.amcar.bolt_release = "half"
    --self.amcar.timers.reload_not_empty = 2.0
    --self.amcar.timers.reload_empty = 2.8
    self.amcar.animations.reload_name_id = "m4"
    self.amcar.eq_fr = self.new_m4.eq_fr
    self.amcar.shot_anim_mul = 1.25
    --self.amcar.r_no_bullet_clbk = true
    self.amcar.weapon_hold = self.new_m4.weapon_hold
    self.amcar.timers = self.new_m4.timers

    self.m16.caliber = "5.56x45"
    self.m16.weight = 37
    self.m16.fire_mode_data.fire_rate = 0.08
    self.m16.rise_factor = 0
    self.m16.bolt_release = "half"
    self.m16.animations.reload_name_id = "m4"
    self.m16.eq_fr = self.new_m4.eq_fr
    self.m16.shot_anim_mul = 1.5
    --self.m16.r_no_bullet_clbk = true
    self.m16.weapon_hold = self.new_m4.weapon_hold
    self.m16.timers = self.new_m4.timers

    self.olympic.caliber = "5.56x45"
    self.olympic.weight = 27
    self.olympic.rise_factor = 0
    self.olympic.bolt_release = "half"
    self.olympic.fire_mode_data.fire_rate = 0.0667
    self.olympic.timers.reload_empty = 3.2
    self.olympic.animations.reload_name_id = "m4"
    self.olympic.eq_fr = self.new_m4.eq_fr
    self.olympic.shot_anim_mul = 1.25
    --self.olympic.r_no_bullet_clbk = true
    self.olympic.weapon_hold = self.new_m4.weapon_hold
    self.olympic.timers = self.new_m4.timers

    self.victor.caliber = "5.56x45"
    self.victor.fire_mode_data.fire_rate = 0.08
    self.victor.weight = 33 --roughly
    self.victor.rise_factor = 0
    self.victor.bolt_release = "half"
    --self.victor.eq_fr = {0,7,14}
    self.victor.animations.reload_name_id = "m4"
    self.victor.weapon_hold = self.new_m4.weapon_hold
    self.victor.eq_fr = self.new_m4.eq_fr
    self.victor.timers = self.new_m4.timers
    self.victor.CAN_TOGGLE_FIREMODE = true
    self.victor.fire_mode_data.toggable = { "single", "auto" }
	self.victor.sounds.fire_single = self.victor.sounds.fire
    self.victor.sounds.fire_auto = self.victor.sounds.fire
    self.victor.sounds.fire = nil
    self.victor.has_description = nil
    self.victor.shot_anim_mul = 1.25
    self.victor_crew.CLIP_AMMO_MAX = 30
	self.victor_crew.auto.fire_rate = self.victor.fire_mode_data.fire_rate

    self.ak74.caliber = "5.45x39"
    self.ak74.weight = 32
    self.ak74.rise_factor = 2
    self.ak74.mag_release = "paddle"
    self.ak74.bolt_release = "none"
    self.ak74.timers.reload_empty = 3.9
    self.ak74.fire_mode_data.fire_rate = 0.0923
    self.ak74.r_no_bullet_clbk = true
    self.ak74.eq_fr = {1,13,12}

    self.akm.caliber = "7.62x39"
    self.akm.weight = 33
    self.akm.fire_mode_data.fire_rate = 0.1
	self.akm.timers = {
		reload_not_empty = 2.15,
		reload_empty = 3.67,
		unequip = 0.5,
		equip = 0.5
	}
    self.akm.eq_fr = self.ak74.eq_fr
    self.akm.rise_factor = 2
    self.akm.mag_release = "paddle"
    self.akm.bolt_release = "none"
    self.akm.animations.reload_name_id = "ak74"
    self.akm.weapon_hold = self.ak74.weapon_hold
    self.akm.timers = self.ak74.timers
    self.akm.r_no_bullet_clbk = self.ak74.r_no_bullet_clbk

    self.akm_gold.caliber = "7.62x39"
    self.akm_gold.weight = 34
    self.akm_gold.fire_mode_data.fire_rate = self.akm.fire_mode_data.fire_rate
    self.akm_gold.rise_factor = 2
    self.akm_gold.mag_release = "paddle"
    self.akm_gold.bolt_release = "none"
    self.akm_gold.timers = {
		reload_not_empty = 2.1,
		reload_empty = 3.87,
		unequip = 0.5,
		equip = 0.5
	}
    self.akm_gold.animations.reload_name_id = "ak74"
    self.akm_gold.eq_fr = self.ak74.eq_fr
    self.akm_gold.weapon_hold = self.ak74.weapon_hold
    self.akm_gold.timers = self.ak74.timers
    self.akm_gold.r_no_bullet_clbk = self.ak74.r_no_bullet_clbk

    self.akmsu.caliber = "5.45x39"
    self.akmsu.weight = 27
    self.akmsu.rise_factor = 2
    self.akmsu.mag_release = "paddle"
    self.akmsu.bolt_release = "none"
    self.akmsu.fire_mode_data.fire_rate = 0.08
    self.akmsu.timers.reload_not_empty = 2.0
    self.akmsu.timers.reload_empty = 3.6
    self.akmsu.animations.reload_name_id = "ak74"
    self.akmsu.eq_fr = self.ak74.eq_fr
    self.akmsu.shot_anim_mul = 1.25
    self.akmsu.timers = self.ak74.timers
    self.akmsu.r_no_bullet_clbk = self.ak74.r_no_bullet_clbk

    self.rpk.caliber = "7.62x39"
    self.rpk.CAN_TOGGLE_FIREMODE = true
    self.rpk.weight = 48
    self.rpk.fire_mode_data.fire_rate = self.akm.fire_mode_data.fire_rate
    self.rpk.rise_factor = 2
    self.rpk.mag_release = "paddle"
    self.rpk.bolt_release = "none"
    --self.rpk.timers.reload_not_empty = 3.3
    --self.rpk.timers.reload_empty = 4.4
    --self.rpk.eq_fr = {1,20,21}
    --self.rpk.r_no_bullet_clbk = true
    --self.rpk.anim_no_full = true
    self.rpk.animations.reload_name_id = "ak74"
    self.rpk.weapon_hold = self.ak74.weapon_hold
    self.rpk.eq_fr = self.ak74.eq_fr
    self.rpk.timers = self.ak74.timers
    self.rpk.r_no_bullet_clbk = self.ak74.r_no_bullet_clbk

    self.flint.caliber = "5.45x39"
    self.flint.weight = 35
    self.flint.rise_factor = 2
    self.flint.mag_release = "paddle"
    self.flint.bolt_release = "none"
    self.flint.BURST_COUNT = 2
    self.flint.fire_mode_data.fire_rate = 0.0857
    self.flint.fire_mode_data.burst_cooldown = 0.1
    self.flint.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.flint.burst = { fire_rate = 1 }
    self.flint.timers.reload_empty = 3.3
    self.flint.eq_fr = {0,12,11}

    self.ak5.caliber = "5.56x45"
    self.ak5.weight = 39
    self.ak5.fire_mode_data.fire_rate = 0.0857
    self.ak5.anim_without_lockback = true
    self.ak5.bolt_release = "quarter"
    self.ak5.timers.reload_empty = 3.2
    self.ak5.eq_fr = {0,9,14}
    self.ak5.shot_anim_mul = 1.25

    self.aug.caliber = "5.56x45"
    self.aug.weight = 36
    self.aug.bullpup = true
    self.aug.rise_factor = 0
    self.aug.mag_release = "pushbutton"
    self.aug.bolt_release = "half"
    self.aug.fire_mode_data.fire_rate = 0.0857
    self.aug.timers.reload_not_empty = 3.0
    self.aug.timers.reload_empty = 3.25
    self.aug.eq_fr = {0,14,13}
    self.aug.shot_anim_mul = 1.25

    self.g36.caliber = "5.56x45"
    self.g36.weight = 30
    self.g36.rise_factor = 0
    self.g36.mag_release = "paddle"
    self.g36.fire_mode_data.fire_rate = 0.08
    self.g36.bolt_release = "quarter"
    self.g36.anim_without_lockback = true
    self.g36.timers.reload_empty = 3.55
    self.g36.eq_fr = {0,10,12}
    self.g36.shot_anim_mul = 1.25

    self.s552.caliber = "5.56x45"
    self.s552.weight = 32
    self.s552.mag_release = "paddle"
    self.s552.bolt_release = "half"
    self.s552.timers.reload_not_empty = 1.8
    self.s552.timers.reload_empty = 2.4
    self.s552.fire_mode_data.fire_rate = 0.08
    self.s552.eq_fr = self.ak74.eq_fr
    self.s552.shot_anim_mul = 1.25
    self.s552.fire_mode_data.burst_cooldown = 0.1
    self.s552.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.s552.burst = { fire_rate = 1 }
    self.s552.r_ass = 1/30

    self.famas.caliber = "5.56x45"
    self.famas.weight = 36
    self.famas.rise_factor = 0
    self.famas.bullpup = true
    self.famas.mag_release = "pushbutton"
    self.famas.bolt_release = "none"
    self.famas.timers.reload_not_empty = 2.6
    self.famas.timers.reload_empty = 3.55
    self.famas.eq_fr = {4,17,11}
    self.famas.shot_anim_mul = 1.75
    self.famas.fire_mode_data.burst_cooldown = 0.1
    self.famas.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.famas.burst = { fire_rate = 1 }

    self.l85a2.caliber = "5.56x45"
    self.l85a2.weight = 39
    self.l85a2.bullpup = true
    self.l85a2.mag_release = "pushbutton"
    self.l85a2.bolt_release = "half"
    self.l85a2.anim_without_lockback = true
    self.l85a2.timers.reload_not_empty = 3.1
    self.l85a2.timers.reload_empty = 3.9
    self.l85a2.fire_mode_data.fire_rate = 0.0857
    self.l85a2.eq_fr = {0,13,12}
    self.l85a2.shot_anim_mul = 1.75
    self.l85a2.r_no_bullet_clbk = true
    self.l85a2.timers.reload_empty = self.l85a2.timers.reload_empty - 0.5
    self.l85a2.anim_no_semi = true

    self.vhs.caliber = "5.56x45"
    self.vhs.weight = 38
    self.vhs.fire_mode_data.fire_rate = 0.0706
    self.vhs.rise_factor = 0
    self.vhs.bullpup = true
    self.vhs.mag_release = "pushbutton" --not_sure
    self.vhs.bolt_release = "half"
    self.vhs.timers.reload_empty = 4.55
    self.vhs.eq_fr = {0,11,13}
    self.vhs.anim_no_semi = true
    self.vhs.r_no_bullet_clbk = true

    self.corgi.caliber = "5.56x45"
    self.corgi.weight = 34
    self.corgi.fire_mode_data.fire_rate = 0.0706
    self.corgi.rise_factor = 0
    self.corgi.mag_release = "pushbutton"
    self.corgi.bolt_release = "none"
    self.corgi.eq_fr = {0,13,11}

    self.hajk.caliber = "5.56x45"
    self.hajk.weight = 35
    self.hajk.bolt_release = "quarter"
    self.hajk.timers.reload_not_empty = 1.95
    self.hajk.timers.reload_empty = 3.2
    self.hajk.eq_fr = {0,15,13}
    self.hajk.shot_anim_mul = 1.25
    self.hajk.fire_mode_data.burst_cooldown = 0.1
    self.hajk.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.hajk.burst = { fire_rate = 1 }
    self.hajk.BURST_COUNT = 2
    self.hajk.r_ass = 1/30

    self.tecci.caliber = "5.56x45"
    self.tecci.weight = 40
    self.tecci.fire_mode_data.fire_rate = 0.075
    self.tecci.rise_factor = 0
    self.tecci.eq_fr = {1,28,12}
    --self.tecci.anim_no_full = true
    self.tecci.animations.reload_name_id = "m4"
    self.tecci.weapon_hold = self.new_m4.weapon_hold
    self.tecci.eq_fr = self.new_m4.eq_fr
    self.tecci.timers = self.new_m4.timers
    self.tecci.r_no_bullet_clbk = self.new_m4.r_no_bullet_clbk

    self.komodo.caliber = "5.56x45"
    self.komodo.weight = 31
    self.komodo.rise_factor = 0
    self.komodo.bullpup = true
    self.komodo.mag_release = "pushbutton"
    self.komodo.bolt_release = "half"
    self.komodo.fire_mode_data.fire_rate = 0.0706
    self.komodo.timers.reload_not_empty = 2.1
    self.komodo.timers.reload_empty = 2.8
    self.komodo.eq_fr = {0,15,22}
    self.komodo.r_no_bullet_clbk = true

    self.tkb.caliber = "7.62x39"
    self.tkb.weight = 43
    self.tkb.fire_mode_data.toggable = nil
    self.tkb.rise_factor = 0
    self.tkb.mag_release = "paddle"
    self.tkb.bolt_release = "none"
    --self.tkb.eq_fr = {0,XXX,XXX}
    self.tkb.r_no_bullet_clbk = true
    self.tkb.anim_equip_swap = "stop_running"
    self.tkb.fire_mode_data.toggable = { "single", "auto" }

    self.asval.caliber = "9x39"
    self.asval.weight = 25
    self.asval.mag_release = "paddle"
    self.asval.bolt_release = "none"
    self.asval.timers.reload_not_empty = 2.5
    self.asval.timers.reload_empty = 3.6
    self.asval.fire_mode_data.fire_rate = 0.0667
    self.asval.eq_fr = {0,10,13}
    self.asval.shot_anim_mul = 1.5
    self.asval.r_no_bullet_clbk = true

    self.groza.caliber = "9x39"
    self.groza.weight = 40
    self.groza.fire_mode_data.fire_rate = 0.08
    self.groza.rise_factor = 0
    self.groza.bullpup = true
    self.groza.mag_release = "paddle"
    self.groza.bolt_release = "none"
    self.groza.eq_fr = {1,10,14}



------DMR
    self.new_m14.caliber = "7.62x51"
    self.new_m14.weight = 47
    self.new_m14.mag_release = "paddle"
    self.new_m14.bolt_release = "half"
    self.new_m14.fire_mode_data.fire_rate = 0.0857
    self.new_m14.timers.reload_not_empty = 2.6
    self.new_m14.timers.reload_empty = 3.1
    self.new_m14.eq_fr = self.ak74.eq_fr
    self.new_m14.shot_anim_mul = 2
    self.new_m14.r_no_bullet_clbk = true
    self.new_m14.r_ass = 1/30
    self.new_m14.anim_no_semi = true

    self.g3.caliber = "7.62x51"
    self.g3.action = "roller_delayed"
    self.g3.weight = 44 --plus a sniper stock
    self.g3.fire_mode_data.fire_rate = 0.1
    self.g3.mag_release = "paddle"
    self.g3.bolt_release = "none"
    self.g3.timers.reload_empty = 2.1
    self.g3.eq_fr = self.ak74.eq_fr
    self.g3.anim_no_semi = true

    self.galil.caliber = "7.62x51"
    self.galil.weight = 46
    self.galil.rise_factor = 2
    self.galil.fire_mode_data.fire_rate = 0.1
    self.galil.mag_release = "paddle"
    self.galil.bolt_release = "none"
    self.galil.timers.reload_not_empty = 2.7
    self.galil.timers.reload_empty = 3.8
    self.galil.eq_fr = self.ak74.eq_fr
    self.galil.shot_anim_mul = 1.5

    self.fal.caliber = "7.62x51"
    self.fal.weight = 40 --not_sure
    self.fal.mag_release = "paddle"
    self.fal.bolt_release = "half"
    self.fal.anim_without_lockback = true
    self.fal.fire_mode_data.fire_rate = 0.0923
    self.fal.timers.reload_empty = 3.05
    self.fal.eq_fr = self.ak74.eq_fr
    self.fal.shot_anim_mul = 1.25

    self.contraband.caliber = "7.62x51"
    self.contraband.weight = 44
    self.contraband.rise_factor = 0
    self.contraband.bolt_release = "half"
    self.contraband.fire_mode_data.fire_rate = 0.1
    self.contraband.timers.reload_not_empty = 2.25
    self.contraband.timers.reload_empty = 3.2
    --self.contraband.timers.reload_empty = 3.3
    self.contraband.eq_fr = self.new_m4.eq_fr --{0,9,13}
    self.contraband.weapon_hold = "tti"
    self.contraband.animations.reload_name_id = "tti"
    --self.contraband.anim_reload_mul = 1.36
    self.contraband.shot_anim_steelsight = true
    self.contraband.anim_no_full = true
    --self.contraband.force_anim_reload_transition = true

    self.scar.caliber = "7.62x51"
    self.scar.weight = 36
    self.scar.bolt_release = "half"
    self.scar.anim_without_lockback = true
    self.scar.fire_mode_data.fire_rate = 0.109
    self.scar.timers.reload_not_empty = 2.3
    self.scar.timers.reload_empty = 2.8
    self.scar.eq_fr = {0,10,13}
    self.scar.shot_anim_mul = 1.3
    self.scar.r_no_bullet_clbk = true

    self.tti.caliber = "7.62x51"
    self.tti.weight = 38 --not_sure
    self.tti.rise_factor = 0
    self.tti.fire_mode_data.fire_rate = 0.0857
    self.tti.bolt_release = "half"
    self.tti.timers.reload_not_empty = 2.25
    self.tti.timers.reload_empty = 3.2
	self.tti.shot_anim_steelsight = true
    self.tti.eq_fr = {0,11,12}
    self.tti.has_description = nil

    self.siltstone.caliber = "7.62x54 R"
    self.siltstone.weight = 39
    self.siltstone.fire_mode_data.fire_rate = 0.12
    self.siltstone.mag_release = "paddle"
    self.siltstone.bolt_release = "quarter"
    self.siltstone.timers.reload_not_empty = 2.25
    self.siltstone.timers.reload_empty = 3.1
    self.siltstone.eq_fr = {1,12,12}
    self.siltstone.r_ass = 1/30
    self.siltstone.has_description = nil
	self.siltstone.shot_anim_steelsight = true

    self.qbu88.caliber = "5.8x42"
    self.qbu88.weight = 41
    self.qbu88.rise_factor = 0
    self.qbu88.fire_mode_data.fire_rate = 0.12
    self.qbu88.bullpup = true
    self.qbu88.mag_release = "paddle"
    self.qbu88.bolt_release = "none"
    self.qbu88.timers.reload_not_empty = 2.1
    self.qbu88.timers.reload_empty = 2.85
    self.qbu88.eq_fr = {1,10,14}
    self.qbu88.has_description = nil
	self.qbu88.shot_anim_steelsight = true

    self.winchester1874.caliber = ".44-40"
    self.winchester1874.weight = 43
    self.winchester1874.rise_factor = 3
    self.winchester1874.feed_system = "tube_fed"
    self.winchester1874.action = "lever_action"
    self.winchester1874.r_enter = 11
    self.winchester1874.r_shell = 12
    self.winchester1874.fire_mode_data.fire_rate = 0.4
	self.winchester1874.single.fire_rate = 0.4
    self.winchester1874.shot_anim_hands = 24
	self.winchester1874.shot_anim_steelsight = true
    self.winchester1874.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
    self.winchester1874.eq_fr = {4,18,17}
    self.winchester1874.has_description = nil

    self.ching.caliber = ".30-06"
    self.ching.weight = 43
    self.ching.rise_factor = 2
    self.ching.feed_system = "ejecting_mag"
    self.ching.mag_release = "doublebutton"
    self.ching.bolt_release = "half"
    self.ching.bolt_release_ratio = { 2, 1 }
    self.ching.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.ching.custom_cycle_2 = { "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release" }
    self.ching.eq_fr = {0,8,12}
    self.ching.r_ass = 1/30
	self.ching.r_no_bullet_clbk = true
	self.ching.shot_anim_steelsight = true

    self.sbl.caliber = ".45-70"
    self.sbl.weight = 33
    self.sbl.rise_factor = 2
    self.sbl.feed_system = "tube_fed"
    self.sbl.action = "lever_action"
    self.sbl.r_enter = self.winchester1874.r_enter
    self.sbl.r_shell = self.winchester1874.r_shell
    self.sbl.fire_mode_data.fire_rate = 0.6
	self.sbl.single.fire_rate = 0.6
    self.sbl.shot_anim_hands = self.winchester1874.shot_anim_hands
    self.sbl.eq_fr = self.winchester1874.eq_fr
    self.sbl.has_description = nil

    self.shak12.stats.value = 1
    self.shak12.caliber = "12.7x55"
    self.shak12.weight = 52
    self.shak12.action = "moving_barrel"
    self.shak12.fire_mode_data.fire_rate = 0.1
    self.shak12.timers.reload_not_empty = 2
    self.shak12.timers.reload_empty = 2.8
    self.shak12.rise_factor = 0
    self.shak12.bullpup = true
    self.shak12.mag_release = "paddle"
    self.shak12.bolt_release = "none"
    self.shak12.eq_fr = {0,11,13}
    self.shak12.shot_anim_mul = 2
    self.shak12.r_no_bullet_clbk = true

    self.hcar.caliber = ".30-06"
    self.hcar.weight = 53
    self.hcar.rise_factor = 1
    self.hcar.mag_release = "paddle"
    self.hcar.bolt_release = "none"
    self.hcar.eq_fr = {1,11,12}
    self.hcar.r_no_bullet_clbk = true
    self.hcar.FIRE_MODE = "single"
    self.hcar.CAN_TOGGLE_FIREMODE = false
	self.hcar_crew.usage = "is_sniper"



------LMG
    self.m249.caliber = "5.56x45"
    self.m249.weight = 72
    self.m249.timers.reload_not_empty = 4.1
	self.m249.timers.reload_empty = 5.3
    self.m249.fire_mode_data.fire_rate = 0.0667
    self.m249.open_bolt = true
    self.m249.mag_safety = true
    self.m249.mag_release = "topcover"
    self.m249.bolt_release = "none"
    self.m249.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.m249.custom_cycle_2 = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.m249.eq_fr = {0,30,13}
    self.m249.anim_no_semi = true
    --self.m249.force_anim_reload_transition = true

    self.hk21.caliber = "7.62x51"
    self.hk21.action = "roller_delayed"
    self.hk21.weight = 79
    self.hk21.mag_safety = true
    self.hk21.mag_release = "pushbutton"
    self.hk21.timers.reload_not_empty = 4.45
    self.hk21.bolt_release = "none"
    self.hk21.bolt_release_ratio = { 1.0, 0.5 }
    self.hk21.custom_cycle = { "r_reach_for_old_mag", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in" }
    self.hk21.custom_cycle_2 = { "r_reach_for_old_mag", "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.hk21.stancemod = { trn = Vector3(-2, -14, 0), rot = Vector3(0, 0, 3) }
    self.hk21.eq_fr = {0,30,11}
    self.hk21.r_no_bullet_clbk = true
    --self.hk21.CAN_TOGGLE_FIREMODE = true --todo
    self.hk21.fire_mode_data.fire_rate = 0.075
    self.hk21.fire_mode_data.burst_cooldown = 0.1
    self.hk21.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.hk21.burst = { fire_rate = 1 }
    self.hk21.anim_no_semi = true

    self.hk51b.caliber = "7.62x51"
    self.hk51b.action = "roller_delayed"
    self.hk51b.weight = 50
    self.hk51b.mag_safety = true
    self.hk51b.timers.reload_not_empty = 3.0
    self.hk51b.timers.reload_empty = 3.4
    self.hk51b.fire_mode_data.fire_rate = 0.0667
    self.hk51b.mag_release = "topcover"
    self.hk51b.bolt_release = "none"
    self.hk51b.bolt_release_ratio = { 1.0, 0.5 }
    self.hk51b.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_1", "r_bolt_release_2" }
    self.hk51b.custom_cycle_2 = { "r_reach_for_old_mag", "r_bolt_release_1", "r_reach_for_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.hk51b.eq_fr = {1,8,12}

    self.m60.caliber = "7.62x51"
    self.m60.weight = 100
    self.m60.mag_safety = true
    self.m60.rise_factor = 0
    self.m60.open_bolt = true
    self.m60.timers.reload_not_empty = 4.7
	self.m60.timers.reload_empty = 5.9
    self.m60.mag_release = "topcover"
    self.m60.bolt_release = "none"
    self.m60.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.m60.custom_cycle_2 = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.m60.eq_fr = {0,30,16}
    --self.m60.force_anim_reload_transition = true

    self.par.caliber = "7.62x51"
    self.par.weight = 125
    self.par.mag_safety = true
    self.par.timers.reload_not_empty = 6.4
    self.par.timers.reload_empty = 6.4
    self.par.fire_mode_data.fire_rate = 0.08
    self.par.rise_factor = 0
    self.par.open_bolt = true
    self.par.mag_release = "topcover"
    self.par.bolt_release = "none"
    self.par.custom_cycle = { "r_bolt_release", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.par.custom_cycle_2 = { "r_bolt_release", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.par.stancemod = { trn = Vector3(-2, -17, 0), rot = Vector3(0, 0, 3) }
    self.par.eq_fr = {0,30,13}

    self.mg42.caliber = "7.92x57"
    self.mg42.weight = 116
    self.mg42.mag_safety = true
    self.mg42.rise_factor = 0
    self.mg42.open_bolt = true
    self.mg42.mag_release = "topcover"
    self.mg42.bolt_release = "none"
    self.mg42.custom_cycle = { "r_bolt_release", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.mg42.custom_cycle_2 = { "r_bolt_release", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.mg42.stancemod = { trn = Vector3(-2, -14, 0), rot = Vector3(0, 0, 3) }
    self.mg42.eq_fr = {0,30,11}
    self.mg42.anim_no_semi = true
    self.mg42.sounds.fire_single = nil

    self.kacchainsaw.caliber = "5.56x45"
    self.kacchainsaw.weight = 45
    --self.kacchainsaw.timers.reload_not_empty = 4.15
	--self.kacchainsaw.timers.reload_empty = 5.25
    self.kacchainsaw.fire_mode_data.fire_rate = 0.109
    self.kacchainsaw.reverse_rise = true
    self.kacchainsaw.open_bolt = true
    self.kacchainsaw.mag_safety = true
    self.kacchainsaw.mag_release = "topcover"
    self.kacchainsaw.bolt_release = "none"
    self.kacchainsaw.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2" }
    self.kacchainsaw.custom_cycle_2 = { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.kacchainsaw.eq_fr = {0,53,46}
    --self.kacchainsaw.anim_no_semi = true



------SNIPER RIFLE
    self.m95.caliber = ".50 BMG"
    self.m95.weight = 107
    self.m95.timers = {
		reload_not_empty = 4,
		reload_empty = 5.3,
		unequip = 0.9,
		equip = 0.9
	}
    self.m95.rise_factor = 0
    self.m95.bullpup = true
    self.m95.action = "bolt_action"
    self.m95.bolt_release = "rotate"
    self.m95.fire_mode_data.fire_rate = 1.8
    self.m95.shot_anim_hands = 50
    self.m95.mag_release = "topcover"
    self.m95.eq_fr = {2,20,23}
    self.m95.r_no_bullet_clbk = true
    self.m95.has_description = nil

    self.msr.caliber = ".338 LM" --308
    self.msr.weight = 57
    self.msr.rise_factor = 0
    self.msr.action = "bolt_action"
    self.msr.fire_mode_data.fire_rate = 1.4
    self.msr.shot_anim_hands = 32
    self.msr.bolt_release = "rotate"
    self.msr.mag_release = "paddle"
    self.msr.timers.reload_empty = 3.5
    self.msr.eq_fr = {1,12,12}
    self.msr.r_no_bullet_clbk = true
    self.msr.has_description = nil

    self.r93.caliber = ".338 LM"
    self.r93.weight = 58
    self.r93.action = "bolt_action"
    self.r93.fire_mode_data.fire_rate = 1.3
    self.r93.shot_anim_hands = 36
    self.r93.mag_release = "doublebutton"
    self.r93.bolt_release = "none"
    self.r93.eq_fr = {1,21,18}
    self.r93.r_no_bullet_clbk = true
    self.r93.has_description = nil

    self.mosin.caliber = "7.62x54 R"
    self.mosin.weight = 40
    self.mosin.timers.reload_not_empty = 3.6
    self.mosin.timers.reload_empty = 3.6
    self.mosin.rise_factor = 2
    self.mosin.action = "bolt_action"
    self.mosin.feed_system = "clip_loader"
    self.mosin.fire_mode_data.fire_rate = 1.4
    self.mosin.shot_anim_hands = 31
    self.mosin.bolt_release = "rotate"
    self.mosin.bolt_release_ratio = { 0.7, 0.7 }
    self.mosin.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release_2" }
    self.mosin.custom_cycle_2 = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release_2" }
    self.mosin.eq_fr = {0,10,15}
    self.mosin.r_no_bullet_clbk = true
    self.mosin.has_description = nil

    self.wa2000.caliber = ".300 WM" --308
    self.wa2000.weight = 70
    self.wa2000.rise_factor = 0
    self.wa2000.bullpup = true
    self.wa2000.fire_mode_data.fire_rate = 0.15
    self.wa2000.mag_release = "paddle"
    self.wa2000.bolt_release = "none" --not_sure
    self.wa2000.timers.reload_empty = 5.8
    self.wa2000.eq_fr = {3,19,19}
    self.wa2000.r_no_bullet_clbk = true
	self.wa2000.shot_anim_steelsight = true
    self.wa2000.has_description = nil

    self.model70.caliber = "7.62x51"
    self.model70.weight = 36
    self.model70.rise_factor = 2
    self.model70.action = "bolt_action"
    self.model70.fire_mode_data.fire_rate = 1.2
    self.model70.shot_anim_hands = 29
    self.model70.mag_release = "pushbutton"
    self.model70.bolt_release = "rotate"
    self.model70.bolt_release_ratio = { 0.5, 0.5 }
    self.model70.custom_cycle_2 = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.model70.timers.reload_empty = 4.3
    self.model70.eq_fr = {3,11,11}
    self.model70.r_no_bullet_clbk = true
	self.model70.global_value = nil
    self.model70.has_description = nil

    self.scout.caliber = "7.62x51"
    self.scout.weight = 30
    self.scout.action = "bolt_action"
    self.scout.fire_mode_data.fire_rate = 1.2
    self.scout.shot_anim_hands = 29
    self.scout.mag_release = "paddle"
    self.scout.bolt_release = "rotate"
    self.scout.bolt_release_ratio = { 0.5, 0.5 }
    self.scout.custom_cycle_2 = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.scout.eq_fr = {2,9,10}
    self.scout.has_description = nil

    self.r700.caliber = "7.62x51"
    self.r700.weight = 41
    self.r700.timers.reload_not_empty = 3.2
    self.r700.timers.reload_empty = 4.9
    self.r700.action = "bolt_action"
    self.r700.fire_mode_data.fire_rate = 1.2
    self.r700.shot_anim_hands = 29
    self.r700.mag_release = "paddle"
    self.r700.bolt_release = "rotate"
    self.r700.bolt_release_ratio = { 0.5, 0.5 }
    self.r700.custom_cycle_2 = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.r700.eq_fr = {2,12,12}
    self.r700.r_no_bullet_clbk = true
    self.r700.has_description = nil

    self.desertfox.caliber = ".338 LM"
    self.desertfox.weight = 38
    self.desertfox.rise_factor = 0
    self.desertfox.bullpup = true
    self.desertfox.action = "bolt_action"
    self.desertfox.fire_mode_data.fire_rate = 1.5
    self.desertfox.shot_anim_hands = 40
    self.desertfox.mag_release = "paddle"
    self.desertfox.bolt_release = "rotate"
    self.desertfox.timers.reload_not_empty = 2.65
    self.desertfox.timers.reload_empty = 3.8
    self.desertfox.eq_fr = {1,13,12}
    self.desertfox.has_description = nil

    self.awp.caliber = "7.62x51"
    self.awp.weight = 58 --roughly
    self.awp.action = "bolt_action"
    self.awp.timers.reload_not_empty = self.awp.timers.reload_not_empty - 0.6
    self.awp.timers.reload_empty = self.awp.timers.reload_empty - 0.3
    self.awp.fire_mode_data.fire_rate = 1.4
    self.awp.shot_anim_hands = 38
    self.awp.mag_release = "paddle"
    self.awp.bolt_release = "rotate"
    self.awp.bolt_release_ratio = { 0.5, 0.5 }
    self.awp.eq_fr = {0,19,17}
    self.awp.has_description = nil

    self.bessy.caliber = ".71 Ball"
    self.bessy.weight = 48
    self.bessy.rise_factor = 2
    self.bessy.feed_system = "break_action"
    --self.bessy.timers = { reload_empty = 1.6, reload_not_empty = 1.6, reload_steelsight = 1.6, reload_steelsight_not_empty = 1.6, unequip = 0.6, equip = 0.6}
    self.bessy.bolt_release = "none"
    self.bessy.bolt_release_ratio = { 1, 1 }
    --self.bessy.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.bessy.custom_cycle = { "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_get_new_mag_in_2", "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_keep_old_mag", "r_bolt_release_2" }



------SHOTGUN
    self.b682.caliber = "12 gauge"
    self.b682.weight = 37
    self.b682.rise_factor = 2
    self.b682.feed_system = "break_action"
    self.b682.timers.reload_not_empty = 2.7
    self.b682.bolt_release = "none"
    self.b682.bolt_release_ratio = { 0.6, 0.6 }
    self.b682.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.b682.custom_cycle_2 = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.b682.always_empty = false
    self.b682.eq_fr = {1,13,12}

    self.huntsman.caliber = "12 gauge"
    self.huntsman.weight = 20
    self.huntsman.rise_factor = 2
    self.huntsman.feed_system = "break_action"
    self.huntsman.timers.reload_empty = 2.4
    self.huntsman.bolt_release = "none"
    self.huntsman.bolt_release_ratio = { 1, 0.5 }
    self.huntsman.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.huntsman.eq_fr = {1,14,13}

    self.coach.caliber = "12 gauge"
    self.coach.weight = 20
    self.coach.rise_factor = 2
    self.coach.feed_system = "break_action"
    self.coach.bolt_release = "none"
    self.coach.bolt_release_ratio = { 0.3, 0.5 }
    self.coach.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release_2" }
    self.coach.eq_fr = {0,13,23}

    self.boot.caliber = "12 gauge"
    self.boot.weight = 36
    self.boot.rise_factor = 2
    self.boot.action = "lever_action"
    self.boot.feed_system = "tube_fed"
    --self.boot.shot_anim_hands = 19
    self.boot.timers.shotgun_reload_first_shell_offset = 6/30
    self.boot.r_enter = 22
    self.boot.r_shell = 6
    self.boot.r_get_new_mag_in = 0.7
    self.boot.anim_empty_chamber = true
    self.boot.bolt_release = "none"
    self.boot.bolt_release_ratio = { 1.2, 0.5 }
    self.boot.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
	self.boot.exit_anim_partial = true
	self.boot.custom_enter = 11/30
    self.boot.eq_fr = self.m1897.eq_fr
    self.boot.use_shotgun_reload = true

    self.r870.caliber = "12 gauge"
    self.r870.weight = 34
    self.r870.rise_factor = 2 --0
    self.r870.action = "pump_action"
    self.r870.feed_system = "tube_fed"
    self.r870.fire_mode_data.fire_rate = 0.6
    self.r870.shot_anim_hands = 12
    self.r870.r_can_doubleload = true
    self.r870.r_enter = 10
    self.r870.r_shell = 12
    self.r870.eq_fr = {0,11,12}
    self.r870.use_shotgun_reload = true

    self.serbu.caliber = "12 gauge"
    self.serbu.weight = 26
    self.serbu.rise_factor = 2
    self.serbu.action = "pump_action"
    self.serbu.feed_system = "tube_fed"
    self.serbu.fire_mode_data.fire_rate = 0.6
    self.serbu.shot_anim_hands = self.r870.shot_anim_hands
    self.serbu.r_can_doubleload = true
    self.serbu.r_enter = self.r870.r_enter
    self.serbu.r_shell = self.r870.r_shell
    self.serbu.eq_fr = self.r870.eq_fr
    self.serbu.use_shotgun_reload = true

    self.m590.caliber = "12 gauge"
    self.m590.weight = 58 --plus a stock
    self.m590.rise_factor = 2
    self.m590.action = "pump_action"
    self.m590.feed_system = "tube_fed"
    self.m590.fire_mode_data.fire_rate = 0.6
    self.m590.shot_anim_hands = self.r870.shot_anim_hands
    self.m590.r_can_doubleload = true
    self.m590.r_enter = self.r870.r_enter
    self.m590.r_shell = self.r870.r_shell
    self.m590.eq_fr = self.r870.eq_fr
    self.m590.use_shotgun_reload = true

    self.m1897.caliber = "12 gauge"
    self.m1897.weight = 36
    self.m1897.action = "pump_action"
    self.m1897.feed_system = "tube_fed"
    self.m1897.fire_mode_data.fire_rate = 0.6
    self.m1897.shot_anim_hands = 18
    self.m1897.r_can_doubleload = true
    self.m1897.r_enter = 20
    self.m1897.r_shell = 13
    self.m1897.eq_fr = {0,23,12}
    self.m1897.use_shotgun_reload = true

    self.m37.caliber = "12 gauge"
    self.m37.weight = 29
    self.m37.rise_factor = 2
    self.m37.action = "pump_action"
    self.m37.feed_system = "tube_fed"
    self.m37.fire_mode_data.fire_rate = 0.6
    self.m37.r_can_doubleload = true
    self.m37.shot_anim_hands = self.m1897.shot_anim_hands
    self.m37.r_enter = self.m1897.r_enter
    self.m37.r_shell = self.m1897.r_shell
    self.m37.eq_fr = self.m1897.eq_fr
    self.m37.use_shotgun_reload = true

    self.supernova.caliber = "12 gauge"
    self.supernova.weight = 34
    self.supernova.rise_factor = 2 --0
    self.supernova.action = "pump_action"
    self.supernova.feed_system = "tube_fed"
    self.supernova.fire_mode_data.fire_rate = 0.6
    self.supernova.shot_anim_hands = 18
    self.supernova.r_can_doubleload = true
    self.supernova.r_enter = self.r870.r_enter
    self.supernova.r_shell = self.r870.r_shell
    self.supernova.r_anim_swap = "r870"
    self.supernova.eq_fr = self.m1897.eq_fr
    self.supernova.use_shotgun_reload = true

    self.ksg.caliber = "12 gauge"
    self.ksg.weight = 31
    self.ksg.rise_factor = 0
    self.ksg.bullpup = true
    self.ksg.action = "pump_action"
    self.ksg.feed_system = "tube_fed"
    self.ksg.fire_mode_data.fire_rate = 0.6
    self.ksg.shot_anim_hands = 13
    self.ksg.timers.shotgun_reload_enter = 14/30
    self.ksg.r_enter = 8
    self.ksg.r_shell = 10
    self.ksg.eq_fr = {0,13,13}
    self.ksg.use_shotgun_reload = true

    self.spas12.caliber = "12 gauge"
    self.spas12.weight = 42 --44
    self.spas12.rise_factor = 2
    self.spas12.fire_mode_data.fire_rate = 0.15
    self.spas12.feed_system = "tube_fed"
    self.spas12.bolt_release = "half"
    self.spas12.anim_r_exit = "reload"
    self.spas12.timers.shotgun_reload_exit_empty = 1
    self.spas12.r_enter = self.r870.r_enter
    self.spas12.r_shell = self.r870.r_shell
    self.spas12.r_exit_mul = 0.6
    self.spas12.eq_fr = self.r870.eq_fr
    self.spas12.shot_anim_mul = 0.6
    --self.spas12.weapon_hold = self.r870.weapon_hold
    self.spas12.use_shotgun_reload = true

    self.benelli.caliber = "12 gauge"
    self.benelli.weight = 35
    self.benelli.rise_factor = 2
    self.benelli.fire_mode_data.fire_rate = 0.15
    self.benelli.feed_system = "tube_fed"
    self.benelli.bolt_release = "half"
    self.benelli.anim_r_exit = "reload"
    self.benelli.r_exit_mul = 0.6
    self.benelli.r_can_doubleload = true
    self.benelli.r_enter = self.r870.r_enter
    self.benelli.r_shell = self.r870.r_shell
    self.benelli.eq_fr = self.r870.eq_fr
    self.benelli.shot_anim_mul = self.spas12.shot_anim_mul
	--[[self.benelli.animations.reload_shell_data = {
        align = "left",
        ammo_units = {
            "units/payday2/weapons/wpn_fps_shell/wpn_fps_shell",
            "units/pd2_dlc_lawp/weapons/wpn_fps_shot_ultima_pts/wpn_fps_sho_ultima_m_double"
        }
    }]]
    self.benelli.use_shotgun_reload = true

    self.ultima.caliber = "12 gauge"
    self.ultima.weight = 42
    self.ultima.fire_mode_data.fire_rate = 0.15
    self.ultima.feed_system = "tube_fed"
    self.ultima.r_can_doubleload = true
    self.ultima.r_enter = self.m1897.r_enter
    self.ultima.r_shell = self.m1897.r_shell
    self.ultima.r_anim_swap = "m1897"
    self.ultima_orig = {}
    self.ultima_orig.timers = deep_clone(self.ultima.timers)
    self.ultima_orig.r_enter = 14
    self.ultima_orig.r_shell = 24
    self.ultima_orig.r_redienter = 0.3
    self.ultima.eq_fr = self.m1897.eq_fr

    self.striker.caliber = "12 gauge"
    self.striker.weight = 42 --not_sure
    self.striker.feed_system = "cylinder_fixed"
    self.striker.r_enter = 16
    self.striker.r_shell = 15
    self.striker.r_get_new_mag_in = 0.7
    self.striker.eq_fr = {7,25,17}
    self.striker.use_shotgun_reload = true

    self.rota.caliber = "12 gauge"
    self.rota.weight = 30 --not_sure
    self.rota.rise_factor = 0
    self.rota.bullpup = true
    self.rota.mag_release = "doublebutton"
    self.rota.feed_system = "cylinder_detachable"
    self.rota.dao = true
    self.rota.anim_custom_click = 8/30
    self.rota.timers.reload_not_empty = 2.5
    self.rota.timers.reload_empty = 2.5
    self.rota.eq_fr = {0,16,13}

    self.saiga.caliber = "12 gauge"
    self.saiga.weight = 35
    self.saiga.FIRE_MODE = "single"
    self.saiga.CAN_TOGGLE_FIREMODE = false
    self.saiga.fire_mode_data.fire_rate = 0.15
    self.saiga.timers.reload_empty = 3.9
    self.saiga.rise_factor = 2
    self.saiga.mag_release = "paddle"
    self.saiga.bolt_release = "none"
    self.saiga.eq_fr = {1,13,13}
    self.saiga.r_no_bullet_clbk = true
    self.saiga.anim_no_semi = true

    self.basset.caliber = "12 gauge"
    self.basset.caliber = "12 gauge"
    self.basset.CAN_TOGGLE_FIREMODE = false
    self.basset.FIRE_MODE = "single"
    self.basset.weight = 40 --not_sure
    self.basset.fire_mode_data.fire_rate = 0.15
    self.basset.bullpup = true
    self.basset.mag_release = "paddle"
    self.basset.bolt_release = "none"
    self.basset.timers.reload_not_empty = 2.1
    self.basset.timers.reload_empty = 2.7
    self.basset.eq_fr = {0,12,13}

    self.sko12.caliber = "12 gauge"
    self.sko12.FIRE_MODE = "single"
    self.sko12.CAN_TOGGLE_FIREMODE = false
    self.sko12.fire_mode_data.fire_rate = 0.15
    self.sko12.weight = 35
    self.sko12.bolt_release = "half"
    self.sko12.eq_fr = {0,9,13}
    self.sko12.r_ass = 1/30
    --self.sko12.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"

    self.aa12.caliber = "12 gauge"
    self.aa12.weight = 48
    self.aa12.rise_factor = 0
    self.aa12.open_bolt = true
    self.aa12.mag_release = "paddle"
    self.aa12.bolt_release = "none"
    self.aa12.timers.reload_empty = 3.8
    self.aa12.eq_fr = {0,13,13}
    self.aa12.r_no_bullet_clbk = true
    self.aa12.CAN_TOGGLE_FIREMODE = false



------SMG
    self.coal.caliber = "9x18"
    self.coal.weight = 27 --not_sure
    self.coal.action = "blowback"
    self.coal.mag_release = "doublebutton"
    self.coal.bolt_release = "none"
    self.coal.fire_mode_data.fire_rate = 0.0857
    self.coal.timers.reload_not_empty = 3.1
    self.coal.timers.reload_empty = 4.1
    self.coal.eq_fr = {0,16,12}
    self.coal.shot_anim_mul = 1.25
	self.coal.shot_anim_hands_offset = 1/30
	self.coal.anim_no_semi = true

    self.new_mp5.caliber = "9x19"
    self.new_mp5.weight = 27
    self.new_mp5.fire_mode_data.fire_rate = 0.075
    self.new_mp5.timers.reload_empty = 3.5
    self.new_mp5.action = "roller_delayed"
    self.new_mp5.mag_release = "paddle"
    self.new_mp5.bolt_release = "none"
    self.new_mp5.bolt_release_ratio = { 0.8, 0.5 }
    self.new_mp5.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.new_mp5.eq_fr = {1,12,13}
    self.new_mp5.shot_anim_mul = 1.25
	self.new_mp5.anim_no_semi = true

    self.uzi.caliber = "9x19"
    self.uzi.weight = 35
    self.uzi.action = "blowback"
    self.uzi.open_bolt = true
    self.uzi.mag_release = "pushbutton"
    self.uzi.bolt_release = "none"
    self.uzi.anim_shoot_stop = true
    self.uzi.fire_mode_data.fire_rate = 0.1
    self.uzi.timers.reload_empty = 3.4
    self.uzi.eq_fr = {1,14,13}
	self.uzi.anim_no_full = true

    self.sterling.caliber = "9x19"
    self.sterling.weight = 27
    self.sterling.rise_factor = 2
    self.sterling.action = "blowback"
    self.sterling.open_bolt = true
    self.sterling.mag_release = "paddle"
    self.sterling.bolt_release = "none"
    self.sterling.bolt_speed = 0.6
    self.sterling.fire_mode_data.fire_rate = 0.109
    self.sterling.timers.reload_empty = 3.2
    self.sterling.stancemod = { trn = Vector3(-2, -1, 0), rot = Vector3(0, 0, -10) }
    self.sterling.eq_fr = {1,16,13}
    self.sterling.r_ass = 1/30
	self.sterling.anim_no_full = true

    self.sub2000.caliber = "9x19"
    self.sub2000.weight = 19
    self.sub2000.rise_factor = 0
    self.sub2000.action = "blowback"
    self.sub2000.bolt_release = "none"
    self.sub2000.fire_mode_data.fire_rate = 0.0857
    self.sub2000.timers.reload_empty = 3.2
    self.sub2000.eq_fr = {0,9,13} --{1,18,13}
    self.sub2000.r_no_bullet_clbk = true
    self.sub2000.anim_equip_swap = "stop_running"
    self.sub2000.anim_unequip_swap = "start_running"
    self.sub2000.has_description = true
    self.sub2000.desc_id = "bm_w_folding_gun_desc"

    self.vityaz.caliber = "9x19"
    self.vityaz.weight = 29
    self.vityaz.action = "blowback"
    self.vityaz.mag_release = "paddle"
    self.vityaz.bolt_release = "none"
    self.vityaz.shot_anim_mul = 1.25
    self.vityaz.eq_fr = {0,10,13}

    self.m45.caliber = "9x19"
    self.m45.weight = 34
    self.m45.rise_factor = 2
    self.m45.action = "blowback"
    self.m45.open_bolt = true
    self.m45.mag_release = "paddle"
    self.m45.bolt_release = "none"
    self.m45.timers.reload_not_empty = 2.7
    self.m45.timers.reload_empty = 3.5
    self.m45.eq_fr = {1,13,11}
    self.m45.r_no_bullet_clbk = true
    self.m45.r_ass = 1/30
    self.m45.anim_no_semi = true

    self.shepheard.caliber = "9x19"
    self.shepheard.weight = 27
    self.shepheard.rise_factor = 0
    self.shepheard.fire_mode_data.fire_rate = 0.0706
    self.shepheard.timers.reload_empty = 2.8
    self.shepheard.eq_fr = {0,7,13}
    self.shepheard.shot_anim_hands_offset = 7/30 --31/30
	self.shepheard.anim_no_full = true

    self.erma.caliber = "9x19"
    self.erma.weight = 40
    self.erma.fire_mode_data.fire_rate = 0.109
    self.erma.action = "blowback"
    self.erma.open_bolt = true
    self.erma.mag_release = "paddle"
    self.erma.bolt_release = "none"
    self.erma.eq_fr = {0,16,12}
    self.erma.r_ass = 1/30
    self.erma.anim_no_semi = true

    self.schakal.caliber = ".45 ACP"
    self.schakal.weight = 25
    self.schakal.action = "blowback"
    self.schakal.mag_release = "paddle"
    self.schakal.bolt_release = "half" --todo
    self.schakal.anim_without_lockback = true
    self.schakal.bolt_release_ratio = { 0.8, 0.2 }
    self.schakal.custom_cycle_2 = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.schakal.fire_mode_data.fire_rate = 0.0923
    self.schakal.timers.reload_not_empty = 2.3
    self.schakal.timers.reload_empty = 3.5
    self.schakal.eq_fr = {0,15,13}
    self.schakal.shot_anim_mul = 1.25
	self.schakal.anim_no_semi = true

    self.m1928.caliber = ".45 ACP"
    self.m1928.weight = 50
    self.m1928.rise_factor = 2
    self.m1928.action = "blowback"
    self.m1928.open_bolt = true
    self.m1928.mag_release = "topcover"
    self.m1928.bolt_release = "none"
    self.m1928.bolt_speed = 0.8
    self.m1928.fire_mode_data.fire_rate = 0.0857
    self.m1928.timers.reload_not_empty = 3.3
    self.m1928.timers.reload_empty = 4.0
    self.m1928.stancemod = { trn = Vector3(-2, -14, 0), rot = Vector3(0, 0, 3) }
    self.m1928.eq_fr = {0,27,12}
    self.m1928.r_no_bullet_clbk = true
    self.m1928.r_ass = 1/30
	self.m1928.anim_no_full = true

    self.polymer.caliber = ".45 ACP"
    self.polymer.weight = 27
    self.polymer.rise_factor = -1
    self.polymer.action = "blowback"
    self.polymer.mag_release = "pushbutton"
    self.polymer.bolt_release = "half"
    self.polymer.timers.reload_not_empty = 1.95
    self.polymer.timers.reload_empty = 2.5
    self.polymer.stancemod = { trn = Vector3(0, -5, 0), rot = Vector3(0, 0, 3) }
    self.polymer.eq_fr = {2,11,11}
    self.polymer.BURST_COUNT = 2
    self.polymer.fire_mode_data.burst_cooldown = 0.1
    self.polymer.fire_mode_data.toggable = { "single", "burst", "auto" }
    self.polymer.burst = { fire_rate = 1 }

    self.p90.caliber = "5.7x28"
    self.p90.weight = 26
    self.p90.fire_mode_data.fire_rate = 0.0667
    self.p90.rise_factor = 0
    self.p90.action = "blowback"
    self.p90.bullpup = true
    self.p90.mag_release = "doublebutton"
    self.p90.bolt_release = "none"
    self.p90.timers.reload_not_empty = 2.6
    self.p90.eq_fr = {1,12,13}
    self.p90.r_no_bullet_clbk = true
	self.p90.anim_no_semi = true

    self.mp7.caliber = "4.6x30"
    self.mp7.weight = 18
    self.mp7.rise_factor = 0
    self.mp7.fire_mode_data.fire_rate = 0.06315
    self.mp7.timers.reload_not_empty = 1.75
    self.mp7.timers.reload_empty = 2.3
    self.mp7.eq_fr = {1,13,12}
    self.mp7.shot_anim_mul = 1.75
	self.mp7.anim_no_full = true



------MACHINE PISTOL
    self.scorpion.caliber = ".32 ACP"
    self.scorpion.weight = 13
    self.scorpion.action = "blowback"
    self.scorpion.rise_factor = 2
    self.scorpion.mag_release = "pushbutton"
    self.scorpion.bolt_release = "none"
    self.scorpion.fire_mode_data.fire_rate = 0.0667
    self.scorpion.timers.reload_not_empty = 1.95
    self.scorpion.timers.reload_empty = 2.7
    self.scorpion.eq_fr = {0,10,18}
    self.scorpion.shot_anim_mul = 1.75
    self.scorpion.anim_no_full = true

    self.mac10.caliber = ".380 ACP"
    self.mac10.weight = 16
    self.mac10.open_bolt = true
    self.mac10.action = "blowback"
    self.mac10.mag_release = "paddle"
    self.mac10.bolt_release = "none"
    self.mac10.bolt_speed = 2
    self.mac10.fire_mode_data.fire_rate = 0.05
    self.mac10.timers.reload_not_empty = 1.5
    self.mac10.timers.reload_empty = 2.3
    self.mac10.eq_fr = {1,14,12}
    self.mac10.r_no_bullet_clbk = true
    self.mac10.anim_no_full = true

    self.baka.caliber = "9x19"
    self.baka.weight = 19
    self.baka.action = "blowback"
    self.baka.mag_release = "paddle"
    self.baka.bolt_release = "none"
    self.baka.anim_shoot_stop = true
    self.baka.timers.reload_not_empty = 1.8
    self.baka.timers.reload_empty = 2.5
    self.baka.eq_fr = {0,11,13}
    self.baka.anim_no_full = true

    self.pm9.caliber = "9x19"
    self.pm9.weight = 28
    self.pm9.action = "blowback"
    self.pm9.open_bolt = true
    self.pm9.mag_release = "paddle"
    self.pm9.bolt_release = "none"
    self.pm9.anim_shoot_stop = true
    self.pm9.timers = self.baka.timers
    self.pm9.eq_fr = self.baka.eq_fr

    self.mp9.caliber = "9x19"
    self.mp9.weight = 14
    self.mp9.action = "moving_barrel"
    self.mp9.fire_mode_data.fire_rate = 0.0667
    self.mp9.timers.reload_empty = 2.3
    self.mp9.eq_fr = {2,14,12}
    self.mp9.shot_anim_mul = 1.5
    self.mp9.r_no_bullet_clbk = true
    self.mp9.anim_no_full = true

    self.tec9.caliber = "9x19"
    self.tec9.weight = 15
    self.tec9.action = "blowback"
    self.tec9.open_bolt = true --not_sure
    self.tec9.bolt_release = "none"
    self.tec9.mag_release = "paddle"
    self.tec9.fire_mode_data.fire_rate = 0.05455
    self.tec9.timers.reload_not_empty = 2.3
    self.tec9.timers.reload_empty = 3.2
    self.tec9.eq_fr = {0,10,13}

    self.fmg9.caliber = "9x19"
    self.fmg9.weight = 20 --not_sure
    self.fmg9.rise_factor = 0
    self.fmg9.action = "moving_barrel"
    self.fmg9.fire_mode_data.fire_rate = 0.05455
    self.fmg9.timers.reload_not_empty = 2.35
	self.fmg9.timers.reload_empty = 3.6
	self.fmg9.bolt_release = "quarter"
    self.fmg9.eq_fr = {0,9,12} --{1,43,16}
    self.fmg9.r_no_bullet_clbk = true
    --self.fmg9.shot_anim_hands_offset = 1
    self.fmg9.anim_equip_swap = "stop_running"
    self.fmg9.anim_unequip_swap = "start_running"
    self.fmg9.has_description = true
    self.fmg9.desc_id = "bm_w_folding_gun_desc"

    self.sr2.caliber = "9x21"
    self.sr2.weight = 16
    self.sr2.bolt_release = "none"
    self.sr2.fire_mode_data.fire_rate = 0.0667
    self.sr2.timers.reload_not_empty = 2.0
    self.sr2.timers.reload_empty = 3.8
    self.sr2.eq_fr = {5,16,14}
    self.sr2.shot_anim_mul = 1.25
    self.sr2.anim_no_semi = true

    self.cobray.caliber = "9x19"
    self.cobray.weight = 28
    self.cobray.rise_factor = 2
    self.cobray.action = "blowback"
    self.cobray.open_bolt = true
    self.cobray.mag_release = "paddle"
    self.cobray.bolt_release = "none"
    self.cobray.timers.reload_not_empty = 1.9
    self.cobray.timers.reload_empty = 3.9
    self.cobray.eq_fr = {1,16,13}
    self.cobray.anim_no_full = true
    self.cobray.bolt_speed = 1.75
    self.cobray.shot_anim_hands_offset = 2/30

    self.pm9.timers.reload_not_empty = self.mac10.timers.reload_not_empty
	self.pm9.timers.reload_empty = self.mac10.timers.reload_empty
    self.pm9.action = "blowback"
    self.pm9.weapon_hold = "mac11"
    self.pm9.animations.reload_name_id = "mac10"
    self.pm9.anim_reload_mul = 1.11
    self.pm9.eq_fr = self.mac10.eq_fr
    self.pm9.r_no_bullet_clbk =  true
    self.pm9.anim_no_full = true

    self.baka.timers.reload_not_empty = self.mac10.timers.reload_not_empty
	self.baka.timers.reload_empty = self.mac10.timers.reload_empty
    self.baka.weapon_hold = "mac11"
    self.baka.animations.reload_name_id = "mac10"
    self.baka.anim_reload_mul = 1.11
    self.baka.eq_fr = self.mac10.eq_fr
    self.baka.r_no_bullet_clbk =  true
    self.baka.anim_no_full = true



------PISTOL
    self.glock_17.caliber = "9x19"
    self.glock_17.weight = 7
    self.glock_17.fire_mode_data.fire_rate = 0.06
    self.glock_17.action = "moving_barrel"
    self.glock_17.timers = { reload_not_empty = 1.5, reload_empty = 2.1, unequip = 0.5, equip = 0.35 }
    self.glock_17.eq_fr = {0,15,11}
    self.glock_17.r_no_bullet_clbk = true
    self.glock_17.r_ass = 1/30
	self.glock_17.anim_no_full = true

    self.glock_18c.caliber = "9x19"
    self.glock_18c.weight = 7
    self.glock_18c.fire_mode_data.fire_rate = 0.05
    self.glock_18c.action = "moving_barrel"
    self.glock_18c.timers = self.glock_17.timers
    self.glock_18c.eq_fr = self.glock_17.eq_fr
    self.glock_18c.shot_anim_hip = true
    self.glock_18c.r_no_bullet_clbk = true
    self.glock_18c.r_ass = 1/30
    self.glock_18c.shot_anim_mul = 1.75
	self.glock_18c.anim_no_full = true

    self.jowi.caliber = "9x19"
    self.jowi.weight = 6
    self.jowi.fire_mode_data.fire_rate = 0.05
    self.jowi.action = "moving_barrel"
    self.jowi.eq_fr = self.glock_17.eq_fr
    self.jowi.r_ass = 1/30

    self.g26.caliber = "9x19"
    self.g26.stats.recoil = 1
    self.g26.stats.spread = 1
    self.g26.weight = 6
    self.g26.fire_mode_data.fire_rate = 0.05
    self.g26.action = "moving_barrel"
    self.g26.timers = self.glock_17.timers
    self.g26.eq_fr = self.glock_17.eq_fr
    self.g26.shot_anim_hip = true
    self.g26.r_no_bullet_clbk = true
    self.g26.r_ass = 1/30
	self.g26.global_value = "pd2_clan"

    self.g22c.caliber = ".40 S&W"
    self.g22c.weight = 8
    self.g22c.fire_mode_data.fire_rate = 0.05
    self.g22c.action = "moving_barrel"
    self.g22c.timers = self.glock_17.timers
    self.g22c.eq_fr = self.glock_17.eq_fr
    self.g22c.r_no_bullet_clbk = true
    self.g22c.r_ass = 1/30
	self.g22c.anim_no_full = true

    self.ppk.caliber = ".380 ACP"
    self.ppk.fire_mode_data.fire_rate = 0.05
    self.ppk.weight = 7
    self.ppk.rise_factor = 2
    self.ppk.action = "blowback"
    self.ppk.bolt_release = "quarter"
    self.ppk.eq_fr = self.glock_17.eq_fr
    self.ppk.r_no_bullet_clbk = true
    self.ppk.r_ass = 1/30

    self.stech.caliber = "9x18"
    self.stech.weight = 13
    self.stech.rise_factor = 3
    self.stech.action = "blowback"
    self.stech.mag_release = "paddle"
    self.stech.eq_fr = self.glock_17.eq_fr
    self.stech.shot_anim_mul = 1.25
    self.stech.r_ass = 1/30
	self.stech.anim_no_full = true

    self.shrew.caliber = "9x19"
    self.shrew.weight = 7
    self.shrew.fire_mode_data.fire_rate = 0.06
    self.shrew.rise_factor = 2
    self.shrew.action = "moving_barrel"
    self.shrew.eq_fr = self.glock_17.eq_fr
    self.shrew.r_no_bullet_clbk = true
    self.shrew.r_ass = 1/30

    self.c96.caliber = "9x19"
    self.c96.weight = 13
    self.c96.rise_factor = 3
    self.c96.feed_system = "clip_loader"
    self.c96.action = "moving_barrel"
    self.c96.only_empty = true
    self.c96.clip_size = self.c96.CLIP_AMMO_MAX
    self.c96.bolt_release = "quarter"
    self.c96.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release_2" }
    self.c96.custom_cycle_2 = { "r_keep_old_mag", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.c96.shot_anim_mul = 1.2
    self.c96.eq_fr = self.glock_17.eq_fr
    self.c96.r_ass = 1/30

    self.czech.caliber = "9x19"
    self.czech.weight = 13
    self.czech.action = "moving_barrel"
    self.czech.eq_fr = self.beer.eq_fr
    self.czech.shot_anim_mul = 1.75
    self.czech.timers.reload_not_empty = 1.5
	self.czech.timers.reload_empty = 2.1
    self.czech.weapon_hold = "glock"
    self.czech.animations.reload_name_id = "glock"
    self.czech.anim_reload_mul = 0.95
    --self.czech.force_anim_reload_transition = true
    self.czech.r_no_bullet_clbk = true
    self.czech.r_ass = 1/30
	self.czech.anim_no_full = true

    self.beer.caliber = "9x19"
    self.beer.FIRE_MODE = "burst"
    self.beer.BURST_COUNT = 3
    self.beer.CAN_TOGGLE_FIREMODE = true
    self.beer.fire_mode_data = { fire_rate = 0.06, burst_cooldown = 0.1 }
    self.beer.fire_mode_data.toggable = { "single", "burst" }
    self.beer.burst = { fire_rate = 1 }
    self.beer.weight = 12
    self.beer.rise_factor = 2
    self.beer.action = "moving_barrel"
    self.beer.eq_fr = {0,15,12}
    self.beer.shot_anim_mul = 1.75
    self.beer.timers = self.czech.timers
    self.beer.weapon_hold = self.czech.weapon_hold
    self.beer.animations.reload_name_id = self.czech.animations.reload_name_id
    self.beer.anim_reload_mul = self.czech.anim_reload_mul
    self.beer.r_no_bullet_clbk = true
    --self.beer.force_anim_reload_transition = true
    self.beer.r_ass = self.czech.r_ass

    self.packrat.caliber = "9x19"
    self.packrat.weight = 8
    self.packrat.fire_mode_data.fire_rate = 0.06
    self.packrat.rise_factor = 2
    self.packrat.action = "moving_barrel"
    self.packrat.timers.reload_not_empty = 1.39
	self.packrat.timers.reload_empty = 2.05
    self.packrat.shot_anim_hands = 1.25
    self.packrat.eq_fr = {3,15,12}
    self.packrat.r_ass = 1/30

    self.holt.caliber = "9x19"
    self.holt.weight = 10
    self.holt.fire_mode_data.fire_rate = 0.06
    self.holt.rise_factor = 0
    self.holt.action = "moving_barrel"
    self.holt.timers = self.packrat.timers
    self.holt.shot_anim_hands = self.packrat.shot_anim_hands
    self.holt.eq_fr = self.packrat.eq_fr
    self.holt.r_ass = 1/30

    self.maxim9.caliber = "9x19"
    self.maxim9.weight = 11
    self.maxim9.fire_mode_data.fire_rate = 0.06
    self.maxim9.action = "roller_delayed"
    self.maxim9.timers = self.packrat.timers
    self.maxim9.shot_anim_hands = self.packrat.shot_anim_hands
    self.maxim9.eq_fr = self.packrat.eq_fr
    self.maxim9.r_ass = 1/30
    self.maxim9.desc_id = self.asval.desc_id

    self.pl14.caliber = "9x19"
    self.pl14.weight = 8
    self.pl14.fire_mode_data.fire_rate = 0.06
    self.pl14.rise_factor = 0
    self.pl14.action = "moving_barrel"
    self.pl14.eq_fr = self.glock_17.eq_fr
    self.pl14.r_ass = 1/30

    self.sparrow.caliber = "9x19"
    self.sparrow.weight = 8
    self.sparrow.fire_mode_data.fire_rate = 0.06
    self.sparrow.action = "moving_barrel"
    self.sparrow.eq_fr = self.glock_17.eq_fr
    self.sparrow.r_ass = 1/30

    self.legacy.caliber = "9x19"
    self.legacy.weight = 9
    self.legacy.fire_mode_data.fire_rate = 0.06
    self.legacy.action = "roller_delayed"
    self.legacy.timers = self.packrat.timers
    self.legacy.shot_anim_hands = self.packrat.shot_anim_hands
    self.legacy.eq_fr = self.packrat.eq_fr
    self.legacy.r_ass = 1/30

    self.breech.caliber = "9x19"
    self.breech.weight = 9
    self.breech.rise_factor = 2
    self.breech.action = "moving_barrel"
    self.breech.bolt_release = "quarter"
    self.breech.eq_fr = {4,11,13}
    self.breech.r_ass = 1/30

    self.b92fs.caliber = "9x19"
    self.b92fs.weight = 10
    self.b92fs.fire_mode_data.fire_rate = 0.06
    self.b92fs.rise_factor = 2
    self.b92fs.action = "moving_barrel"
    self.b92fs.eq_fr = self.glock_17.eq_fr
    self.b92fs.r_no_bullet_clbk = true
    self.b92fs.r_ass = 1/30

    self.usp.caliber = ".45 ACP"
    self.usp.weight = 9
    self.usp.fire_mode_data.fire_rate = 0.07
    self.usp.rise_factor = 2
    self.usp.action = "moving_barrel"
    self.usp.timers.reload_empty = 2.05
    self.usp.eq_fr = self.glock_17.eq_fr
    self.usp.r_no_bullet_clbk = true
    self.usp.r_ass = 1/30

    self.p226.caliber = ".40 S&W"
    self.p226.weight = 9
    self.p226.fire_mode_data.fire_rate = 0.07
    self.p226.rise_factor = 2
    self.p226.action = "moving_barrel"
    self.p226.eq_fr = self.glock_17.eq_fr
    self.p226.r_no_bullet_clbk = true
    self.p226.r_ass = 1/30

    self.hs2000.caliber = ".40 S&W" --not_sure
    self.hs2000.weight = 9
    self.hs2000.fire_mode_data.fire_rate = 0.07
    self.hs2000.action = "moving_barrel"
    self.hs2000.eq_fr = self.glock_17.eq_fr
    self.hs2000.r_no_bullet_clbk = true
    self.hs2000.r_ass = 1/30

    self.colt_1911.caliber = ".45 ACP"
    self.colt_1911.weight = 12
    self.colt_1911.fire_mode_data.fire_rate = 0.07
    self.colt_1911.rise_factor = 2
    self.colt_1911.action = "moving_barrel"
    self.colt_1911.timers.reload_empty = 2.05
    self.colt_1911.eq_fr = self.glock_17.eq_fr
    self.colt_1911.shot_anim_hip = true
    self.colt_1911.r_no_bullet_clbk = true
    self.colt_1911.r_ass = 1/30

    self.m1911.caliber = ".45 ACP"
    self.m1911.weight = 12
    self.m1911.fire_mode_data.fire_rate = 0.07
    self.m1911.rise_factor = 2
    self.m1911.action = "moving_barrel"
    self.m1911.eq_fr = self.glock_17.eq_fr
    self.m1911.r_ass = 1/30

    self.lemming.caliber = "5.7x28"
    self.lemming.weight = 7
    self.lemming.fire_mode_data.fire_rate = 0.07
    self.lemming.rise_factor = 2
    self.lemming.action = "moving_barrel"
    self.lemming.shot_anim_hands = self.packrat.shot_anim_hands
    self.lemming.eq_fr = self.packrat.eq_fr
    self.lemming.r_ass = 1/30
    self.lemming.has_description = nil

    self.type54.caliber = "7.62x25"
    self.type54.weight = 9
    self.type54.fire_mode_data.fire_rate = 0.07
    self.type54.rise_factor = 2
    self.type54.action = "moving_barrel"
    self.type54.eq_fr = self.glock_17.eq_fr
    self.type54.r_ass = 1/30

    self.deagle.caliber = ".50 AE"
    self.deagle.weight = 19
    self.deagle.fire_mode_data.fire_rate = 0.07
    self.deagle.rise_factor = 3 --4?
    self.deagle.muzzleflash = "effects/payday2/particles/weapons/shotgun/sho_muzzleflash_hornet"
    self.deagle.timers.reload_not_empty = 1.8
    self.deagle.timers.reload_empty = 2.75
    self.deagle.eq_fr = self.glock_17.eq_fr
    --self.deagle.animations.reload_name_id = "holt"
    --self.deagle.timers.reload_empty = 2.3
    --self.deagle.anim_reload_mul = 1.3
    --self.deagle.force_anim_reload_transition = true
    self.deagle.sounds.fire = "rota_fire"
    self.deagle.shot_anim_mul = 1
    self.deagle.shot_anim_hands = 0.9
    self.deagle.r_ass = 1/30

    self.contender.caliber = ".45-70"
    self.contender.weight = 17
    self.contender.rise_factor = 2
    self.contender.feed_system = "break_action"
    self.contender.timers = { reload_empty = 1.6, reload_not_empty = 1.6, reload_steelsight = 1.6, reload_steelsight_not_empty = 1.6, unequip = 0.6, equip = 0.6}
    self.contender.bolt_release = "none"
    self.contender.bolt_release_ratio = { 0.3, 0.4 }
    --self.contender.custom_cycle = { "r_reach_for_old_mag", "r_mag_out", "r_get_new_mag_in", "r_get_new_mag_in_2", "r_bolt_release" }
    self.contender.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2", "r_get_new_mag_in_2" }
    self.contender.eq_fr = self.glock_17.eq_fr
    self.contender.has_description = nil



------REVOLVER
    self.new_raging_bull.caliber = ".44 Mag"
    self.new_raging_bull.weight = 15
    self.new_raging_bull.rise_factor = 2
    self.new_raging_bull.feed_system = "cylinder_open"
    self.new_raging_bull.timers.reload_not_empty = 2.1
    self.new_raging_bull.timers.reload_empty = self.new_raging_bull.timers.reload_not_empty
	--self.new_raging_bull.shell_ejection = "effects/payday2/particles/weapons/shells/shell_9mm"
    --self.new_raging_bull.mag_release = "doublebutton"
    self.new_raging_bull.bolt_release = "none"
    self.new_raging_bull.bolt_release_ratio = { 1.2, 1.0 }
    self.new_raging_bull.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    --self.new_raging_bull.r_anim_swap = "chinchilla"
    self.new_raging_bull.shot_anim_hands = 1.2
    self.new_raging_bull.eq_fr = {1,14,13}
    self.new_raging_bull.r_no_bullet_clbk = true

    self.korth.caliber = ".357 Mag"
    self.korth.weight = 15
    self.korth.rise_factor = 2
    self.korth.feed_system = "cylinder_open"
    self.korth.fire_mode_data = { fire_rate = 0.15 }
	self.korth.single = { fire_rate = 0.15 }
    self.korth.timers.reload_not_empty = 2.85
    self.korth.timers.reload_empty = self.korth.timers.reload_not_empty
    self.korth.bolt_release = "none"
    self.korth.bolt_release_ratio = { 1.2, 0.5 }
    self.korth.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.korth.weapon_hold = "raging_bull"
    --self.korth.force_anim_reload_transition = true
    --self.korth.animations.reload_name_id = "raging_bull"
    --self.korth.anim_reload_mul = 1.45
    --self.korth.timers.reload_not_empty = 2.1
    --self.korth.timers.reload_empty = self.korth.timers.reload_not_empty
    self.korth.shot_anim_hands = 1.2
    self.korth.shot_anim_hands = self.new_raging_bull.shot_anim_hands
    self.korth.eq_fr = self.new_raging_bull.eq_fr
    self.korth.r_no_bullet_clbk = true

    self.mateba.caliber = ".357 Mag"
    self.mateba.weight = 12
    self.mateba.feed_system = "cylinder_open"
    self.mateba.bolt_release = "none"
    self.mateba.bolt_release_ratio = { 1.0, 1.0 }
    self.mateba.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.mateba.shot_anim_hands = self.new_raging_bull.shot_anim_hands
    self.mateba.eq_fr = self.new_raging_bull.eq_fr
    self.mateba.r_no_bullet_clbk = true

    self.chinchilla.caliber = ".44 Mag"
    self.chinchilla.weight = 14
    self.chinchilla.rise_factor = 2
    self.chinchilla.feed_system = "cylinder_open"
    self.chinchilla.bolt_release = "none"
    self.chinchilla.bolt_release_ratio = { 0.7, 0.5 }
    self.chinchilla.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.chinchilla.shot_anim_hands = self.new_raging_bull.shot_anim_hands
    self.chinchilla.eq_fr = self.new_raging_bull.eq_fr
    self.chinchilla.r_no_bullet_clbk = true

    self.peacemaker.caliber = ".45 LC"
    self.peacemaker.weight = 12
    self.peacemaker.rise_factor = 2
    self.peacemaker.feed_system = "cylinder_fixed"
    self.peacemaker.sao = true
    self.peacemaker.bolt_release = "none"
    self.peacemaker.bolt_release_ratio = { 0.8, 0.6 }
    self.peacemaker.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.peacemaker.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.peacemaker.weapon_hold = "raging_bull"
    self.peacemaker.force_anim_reload_transition = true
    self.peacemaker.shot_anim_hip = true
    self.peacemaker.shot_anim_mul = 0.8
    self.peacemaker.shot_anim_hands = 0.8
    self.peacemaker.r_get_new_mag_in = 0.7
    self.peacemaker.anim_r_loop = "reload"
    --self.peacemaker.r_enter = 43
    --self.peacemaker.r_shell = 20
    self.peacemaker.eq_fr = {1,17,18}
	--self.peacemaker.custom_enter = 11/30

    self.model3.caliber = ".44 RU"
    self.model3.weight = 13
    self.model3.rise_factor = 2
    self.model3.feed_system = "cylinder_open"
    self.model3.sao = true
    self.model3.timers.reload_not_empty = 2.2
    self.model3.timers.reload_empty = self.model3.timers.reload_not_empty
    self.model3.bolt_release = "none"
    self.model3.bolt_release_ratio = { 1.0, 0.5 }
    self.model3.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.model3.weapon_hold = "raging_bull"
    self.model3.shot_anim_hip = true
    self.model3.r_no_bullet_clbk = true
    self.model3.eq_fr = self.new_raging_bull.eq_fr

    self.judge.caliber = ".410 bore"
    self.judge.weight = 8
    self.judge.rise_factor = 2
    self.judge.feed_system = "cylinder_open"
    self.judge.timers.reload_not_empty = self.new_raging_bull.timers.reload_not_empty
    self.judge.timers.reload_empty = self.new_raging_bull.timers.reload_not_empty
    self.judge.shot_anim_hands = self.new_raging_bull.shot_anim_hands
    self.judge.bolt_release = "none"
    self.judge.bolt_release_ratio = { 1.6, 1.0 }
    self.judge.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.judge.eq_fr = self.new_raging_bull.eq_fr
    self.judge.r_no_bullet_clbk = true

    self.rsh12.caliber = "12.7x55"
    self.rsh12.weight = 22
    self.rsh12.feed_system = "cylinder_open"
    self.rsh12.timers.reload_not_empty = self.new_raging_bull.timers.reload_not_empty
    self.rsh12.timers.reload_empty = self.new_raging_bull.timers.reload_not_empty
    self.rsh12.bolt_release = "none"
    self.rsh12.bolt_release_ratio = self.judge.bolt_release_ratio
    self.rsh12.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    self.rsh12.shot_anim_hands = self.new_raging_bull.shot_anim_hands
    self.rsh12.eq_fr = self.new_raging_bull.eq_fr
    self.rsh12.has_description = nil
    self.rsh12.sounds.fire = "tcg2_fire"
    self.rsh12.r_no_bullet_clbk = true
    --self.rsh12.sounds.fire = "model70_fire"



------AKIMBO
    self.x_g18c.timers.reload_not_empty = self.x_g18c.timers.reload_not_empty-0.07

    self.x_2006m.animations.reload_name_id = "x_chinchilla"
    self.x_judge.animations.reload_name_id = "x_chinchilla"
	--self.x_2006m.animations.second_gun_versions = self.x_rage.animations.second_gun_versions or {}
    --self.x_2006m.animations.second_gun_versions.reload = "reload"
    --self.x_judge.sounds.fire = "judge_fire"
	--self.x_judge.sounds.fire_single = nil
    self.x_sr2.sounds = self.sr2.sounds
    self.x_deagle.sounds = self.deagle.sounds
    if self.x_lemming then self.x_lemming.has_description = nil end
    if self.x_rsh12 then self.x_rsh12.has_description = nil end

	self.jowi.global_value = "pd2_clan"
	self.x_g22c.global_value = "pd2_clan"
	self.x_usp.global_value = "pd2_clan"
	self.x_judge.global_value = "pd2_clan"

    local aki_origs = {
        "glock_17",
        "glock_18c",
        "g22c",
        "g26",
        "colt_1911",
        "beer",
        "b92fs",
        "breech",
        "c96",
        "czech",
        "deagle",
        "holt",
        "hs2000",
        "legacy",
        "m1911",
        "maxim9",
        "p226",
        "packrat",
        "pl14",
        "ppk",
        "shrew",
        "sparrow",
        "stech",
        "type54",
        "usp",
        "mac10",
        "pm9",
        "scorpion",
        "baka",
        "mp9",
        "tec9",
        "cobray",
        "sr2",
        "new_raging_bull",
        "korth",
        "chinchilla",
        "model3",
        "mateba",
        "judge",

        "rsh12",
        "lemming",
        "fmg9",
    }
    local aki_weps = {
        "x_g17",
        "x_g18c",
        "x_g22c",
        "jowi",
        "x_1911",
        "x_beer",
        "x_b92fs",
        "x_breech",
        "x_c96",
        "x_czech",
        "x_deagle",
        "x_holt",
        "x_hs2000",
        "x_legacy",
        "x_m1911",
        "x_maxim9",
        "x_p226",
        "x_packrat",
        "x_pl14",
        "x_ppk",
        "x_shrew",
        "x_sparrow",
        "x_stech",
        "x_type54",
        "x_usp",
        "x_mac10",
        "x_pm9",
        "x_scorpion",
        "x_baka",
        "x_mp9",
        "x_tec9",
        "x_cobray",
        "x_sr2",
        "x_rage",
        "x_korth",
        "x_chinchilla",
        "x_model3",
        "x_2006m",
        "x_judge",

        "x_rsh12",
        "x_lemming",
        "x_fmg9",
    }
    for i, k in pairs(aki_origs) do
        for o, l in pairs(self[k] or {}) do
            if not self[ aki_weps[i] ] then break end

            if o=="CLIP_AMMO_MAX" then
                self[ aki_weps[i] ][o] = l*2
            elseif o=="weight" then
                self[ aki_weps[i] ][o] = l*2
            elseif o~="name_id"
            --and o~="desc_id"
            --and o~="description_id"
            and o~="use_data"
            and o~="categories"
            and o~="texture_bundle_folder"
            and o~="global_value"
            and o~="weapon_hold"
            and o~="animations"
            and o~="timers"
            and o~="sounds"
            and o~="anim_equip_swap"
            and o~="anim_unequip_swap"
            then
                self[ aki_weps[i] ][o] = l
            end
        end

        local aki_wep = self[ aki_weps[i] ]
        if aki_wep then
            aki_wep.manual_fire_second_gun = true
            aki_wep.shot_anim_hip = true
            aki_wep.anim_custom_click = 8/30
            aki_wep.anim_no_full = true
            --aki_wep.use_data.selection_index = 3
            --aki_wep.anim_no_full = true

            if table.contains(aki_wep and aki_wep.categories or {}, "akimbo")
            and table.contains(aki_wep and aki_wep.categories or {}, "machine_pistol") then
                aki_wep.weapon_hold = self.x_g18c.weapon_hold
                aki_wep.animations.reload_name_id = "x_g18c"
                aki_wep.anim_reload_mul = 0.6
                aki_wep.timers = self.x_g18c.timers
            end
        end
    end



------SPECIAL
    self.gre_m79.weight = 27
    self.gre_m79.caliber = "40x46mm"
    self.gre_m79.stats.reload = 2
    self.gre_m79.animations = { equip_id = "equip_gre_m79", recoil_steelsight = true }
    self.gre_m79.feed_system = "break_action"
    self.gre_m79.bolt_release = "none"
    self.gre_m79.bolt_release_ratio = { 0.5, 0.3 }
    self.gre_m79.custom_cycle = { "r_bolt_release_1", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }
    --11 13

    self.m32.weight = 53
    self.m32.caliber = "40x46mm"
    self.m32.feed_system = "cylinder_open"
    self.m32.mag_release = "pushbutton"
    self.m32.bolt_release = "rotate"
    self.m32.bolt_release_ratio = { 1.0, 0.4 }
    self.m32.custom_cycle = { "r_bolt_release_1", "r_mag_out", "r_get_new_mag_in", "r_reach_for_old_mag", "r_bolt_release_2"  }
    self.m32.r_exit_mul = 0.4
    self.m32.dao = true
    self.m32.dao_delayed = true
    self.m32.anim_r_loop = "reload"
    self.m32.r_enter = 58
    self.m32.r_shell = 44
    self.m32.r_get_new_mag_in = 1.5
    self.m32.shot_anim_mul = 2
    self.m32.anim_custom_click = 12/30
    self.m32.fire_mode_data.fire_rate = 0.3
    self.m32.eq_fr = {0,14,11}
    self.m32.use_shotgun_reload = true
    --self.m32.custom_enter = 11/30

    self.slap.weight = 22
    self.slap.caliber = "40x46mm"
    self.slap.feed_system = "break_action"
    self.slap.timers.reload_empty = self.slap.timers.reload_empty+0.6
    self.slap.timers.reload_not_empty = self.slap.timers.reload_empty

    self.china.weight = 37
    self.china.caliber = "40x46mm"
    self.china.action = "pump_action"
    self.china.feed_system = "tube_fed"
    self.china.fire_mode_data.fire_rate = 1
    self.china.shot_anim_hands = 38
    self.china.r_get_new_mag_in = 0.7
    self.china.r_ffs = 1
    self.china.r_hide_mag_on_bolting = 1
    self.china.timers.shotgun_reload_first_shell_offset = nil
    --self.china.timers.shotgun_reload_shell = 18/30
    self.china.anim_r_loop = "reload"
    self.china.r_enter = 26
    --self.china.r_shell = 18
    self.china.r_exit_mul = 1
    self.china.ads_reset = true
    self.china.eq_fr = self.m1897.eq_fr
    self.china.use_shotgun_reload = true

    self.ms3gl.weight = 30 --roughly
    self.ms3gl.caliber = "40x46mm"
    self.ms3gl.feed_system = "stacked"
    self.ms3gl.use_shotgun_reload = true

    self.arbiter.weight = 64
    self.arbiter.caliber = "25x40mm"
    self.arbiter.fire_mode_data.fire_rate = 0.2
    self.arbiter.bullpup = true
    self.arbiter.bolt_release = "half"
    self.arbiter.timers.reload_not_empty = 3.3
	self.arbiter.timers.reload_empty = 4.4
    self.arbiter.mag_release = "paddle"

    self.m134.caliber = "7.62x51"
    self.m134.weight = 190 --not_sure
    self.m134.CLIP_AMMO_MAX = 1000
    self.m134.fire_mode_data.fire_rate = 0.04
    self.m134.action = "gatling"
    self.m134.feed_system = "backpack"
    self.m134.reverse_rise = true
    self.m134.eq_fr = {0,30,17}
    self.m134.fire_offset = 0.5/30
    self.m134.r_no_bullet_clbk = true
    self.m134.anim_no_semi = true
    self.m134.has_description = true
    self.m134.desc_id = "bm_wp_backpack_feed_desc"
    self.m134.sounds.fire_single = nil

    self.ray.weight = 53
    self.ray.caliber = "M235"
    self.ray.feed_system = "cylinder_detachable"
    self.ray.has_description = nil
    self.ray.fire_mode_data.fire_rate = 0.5
    self.ray.mag_release = "topcover"
    self.ray.bolt_release = "none"
    self.ray.bolt_release_ratio = { 0.4, 1.2 }
    self.ray.custom_cycle = { "r_bolt_release_1", "r_reach_for_old_mag", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2" }

    self.rpg7.weight = 63
    self.rpg7.caliber = "PG-7VL"
    self.rpg7.recoilless = true
    self.rpg7.bolt_release = "half"
    self.rpg7.custom_cycle_2 = { "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release" }
    self.rpg7.timers.reload_empty = 6.6
    self.rpg7.has_description = nil

    self.flamethrower_mk2.caliber = nil
    self.flamethrower_mk2.feed_system = "fuel"
    self.flamethrower_mk2.r_no_bullet_clbk = true
    self.flamethrower_mk2.sounds.fire_single = nil
    -- 19 13

    --self.plainsrider.caliber = "XXX"

    self.hailstorm.caliber = nil
    self.hailstorm.feed_system = "stacked"
    self.hailstorm.bullpup = true
    self.hailstorm.fire_mode_data.toggable = { "single", "auto" }

    self.hunter.weight = 4
    self.hunter.caliber = nil --50lbs 46ms 

    self.saw.caliber = nil
    self.saw.feed_system = "saw"
    self.saw_secondary.feed_system = "saw"
    self.saw.has_description = nil

    self.long.caliber = nil
    -- 14 16

    self.elastic.caliber = nil

    self.arblast.caliber = nil

    self.system.caliber = nil
    self.system.feed_system = "fuel"
    self.system.r_no_bullet_clbk = true

    self.frankish.caliber = nil

    self.ecp.caliber = nil

    self.trip_mines.player_damage = 30

    --airgun 12 13

    --light bow 14 16 

    --heavy cross 17 13
    --light cross 17 13

--TO ALL GUNS
    for wep, k in pairs(self) do
        if self[wep].stats then
            --INIT
            self[wep].rise_factor = self[wep].rise_factor or 1
            self[wep].weight = self[wep].weight or 100

            --CHAMBER
            if self[wep].open_bolt
            or self[wep].feed_system=="break_action"
            or self[wep].CLIP_AMMO_MAX==1
            or string.find(self[wep].feed_system or "", "cylinder")
            then
                self[wep].chamber = 0
            else
                self[wep].chamber = 1
            end

            --ALWAYS EMPTY
            if (self[wep].custom_cycle and self[wep].custom_cycle[1]=="r_bolt_release_1")
            and not (self[wep].custom_cycle_2 and self[wep].custom_cycle_2[1]~="r_bolt_release_1") then
                self[wep].always_empty = self[wep].always_empty==nil and true
            end

            --ACTION MECHANICAL
            if self[wep].feed_system=="break_action"
            or string.find(self[wep].feed_system or "", "cylinder")
            then
                self[wep].action = "mechanical"
            end

            --EJECTION EFFECT WITH NO DELAY
            local ejection_swaps = {
                ["effects/payday2/particles/weapons/shells/shell_slug_semi"] = "effects/payday2/particles/weapons/shells/shell_slug",
                ["effects/payday2/particles/weapons/shells/shell_slug_g2"] = "effects/payday2/particles/weapons/shells/shell_slug",
                ["effects/payday2/particles/weapons/shells/shell_sniper"] = "effects/payday2/particles/weapons/shells/shell_556",
                ["effects/payday2/particles/weapons/shells/shell_sniper_m95"] = "effects/payday2/particles/weapons/shells/shell_shak",
                ["effects/payday2/particles/weapons/shells/shell_sniper_9mm"] = "effects/payday2/particles/weapons/shells/shell_9mm",
                ["effects/payday2/particles/weapons/shells/shell_awp"] = "effects/payday2/particles/weapons/shells/shell_556",
            }
            self[wep].shell_ejection = ejection_swaps[self[wep].shell_ejection] or self[wep].shell_ejection

            if table.contains(self[wep].categories, "pistol") then
                self[wep].shot_anim_mul = self[wep].shot_anim_mul or 1.25
                --self[wep].shot_anim_hands = self[wep].shot_anim_hands or 1.25
            end

            --FIX DEFAULT STATS
            self[wep].stats.recoil = 1
            self[wep].stats.spread = 0.5
            self[wep].stats.extra_ammo = 0
            self[wep].stats.total_ammo_mod = 0
            self[wep].NR_CLIPS_MAX = self[wep].NR_CLIPS_MAX * 1.5
            local caliber = self[wep].caliber
            if self[wep].AMMO_PICKUP and caliber and self.calibers[caliber] and self.calibers[caliber].class then
                self[wep].AMMO_PICKUP[1] = math.round((ammo_pickup_ratio[self.calibers[caliber].class][1] or 0) / self.calibers[caliber][1].default_energy)
                self[wep].AMMO_PICKUP[2] = self[wep].AMMO_PICKUP[1] * ammo_pickup_ratio[self.calibers[caliber].class][2]
            else
                self[wep].AMMO_PICKUP = {0,0}
            end
            if self.calibers[caliber] then
                self[wep].AMMO_MAX = 32
            end

            if self[wep].CAN_TOGGLE_FIREMODE then self[wep].FIRE_MODE = "single" end
        end

        if string.find(wep or "", "_crew") and self[wep] and self[string.gsub(wep, "_crew", "")] then
			local crewless = self[string.gsub(wep, "_crew", "")]
            local category = crewless.categories and crewless.categories[1]

            local lookup = {
                assault_rifle = "is_rifle",
            }
            self[wep].usage = lookup[category] or self[wep].usage
            self[wep].use_data = crewless.use_data or self[wep].use_data
            self[wep].selection_index = crewless.selection_index or self[wep].selection_index
        end
    end

    self.m134.AMMO_PICKUP = { 0, 0 }
    self.m134.AMMO_MAX = 0



--NPC GUNS
    local mag_amounts = {
        rifle = { {1,2}, {1,3}, {2,3} },
        lmg = { {2,3}, {3,5}, {4,6} },
        smg = { {2,3}, {3,5}, {4,6} },
        pistol = { {1,2}, {2,3}, {2,4} },
    }
    mag_amounts.pistol[0] = {0,0}

------IS_RIFLE
    self.m4_npc.DAMAGE = 4
    self.m4_npc.caliber = "5.56x45"
    self.m4_npc.mag_amount = mag_amounts.rifle
    self.m4_npc.auto.fire_rate = 0.08

    self.m4_yellow_npc.DAMAGE = 4
    self.m4_yellow_npc.caliber = "5.56x45"
    self.m4_yellow_npc.mag_amount = mag_amounts.rifle
    self.m4_yellow_npc.auto.fire_rate = 0.08

    self.g36_npc.DAMAGE = 4
    self.g36_npc.caliber = "5.56x45"
    self.g36_npc.mag_amount = mag_amounts.rifle
    self.g36_npc.auto.fire_rate = 0.08

    self.smoke_npc.DAMAGE = 4
    self.smoke_npc.caliber = "5.56x45"
    self.smoke_npc.mag_amount = mag_amounts.rifle

    self.s552_npc.DAMAGE = 4
    self.s552_npc.caliber = "5.56x45"
    self.s552_npc.mag_amount = mag_amounts.rifle

    self.ak47_npc.DAMAGE = 4
    self.ak47_npc.caliber = "7.62x39"
    self.ak47_npc.mag_amount = mag_amounts.rifle
    self.ak47_npc.auto.fire_rate = 0.1
    self.ak47_ass_npc = deep_clone(self.ak47_npc)
    self.akmsu_smg_npc = deep_clone(self.ak47_npc)
    self.akmsu_smg_npc.DAMAGE = 3
    self.akmsu_smg_npc.caliber = "5.45x39"
    self.akmsu_smg_npc.has_suppressor = "suppressed_a"

	self.asval_smg_npc = deep_clone(self.akmsu_smg_npc)
    self.asval_smg_npc.caliber = "9x39"
    self.asval_smg_npc.mag_amount = mag_amounts.rifle

    self.m14_sniper_npc.DAMAGE = 7
    self.m14_sniper_npc.caliber = "7.62x51"
    self.m14_sniper_npc.mag_amount = mag_amounts.rifle

    self.scar_npc.DAMAGE = 5
    self.scar_npc.caliber = "7.62x51"
    self.scar_npc.mag_amount = mag_amounts.rifle
    self.scar_murky = self.scar_murky or {}
    self.scar_murky.DAMAGE = 5
    self.scar_murky.caliber = "7.62x51"
    self.scar_murky.mag_amount = mag_amounts.rifle

    self.contraband_npc.DAMAGE = 5
    self.contraband_npc.caliber = "7.62x51"
    self.contraband_npc.mag_amount = mag_amounts.rifle
    self.contraband_m203_npc.DAMAGE = 50
    --self.contraband_m203_npc.caliber = "7.62x51"

    self.dmr_npc.DAMAGE = 4
    self.dmr_npc.caliber = "5.56x45"
    self.dmr_npc.mag_amount = mag_amounts.rifle

------IS_LMG
    self.m249_npc.DAMAGE = 4
    self.m249_npc.caliber = "5.56x45"
    self.m249_npc.mag_amount = mag_amounts.lmg

    self.rpk_lmg_npc = deep_clone(self.ak47_npc)
	self.rpk_lmg_npc.categories = clone(self.m249.categories)
    self.rpk_lmg_npc.DAMAGE = 4
    self.rpk_lmg_npc.caliber = "5.45x39"
    self.rpk_lmg_npc.mag_amount = mag_amounts.rifle

    self.hk21_npc.DAMAGE = 5
    self.hk21_npc.caliber = "7.62x51"
    self.hk21_npc.mag_amount = mag_amounts.lmg

------IS_SHOTGUN
    self.r870_npc.DAMAGE = 8
    self.r870_npc.caliber = "12 gauge"
    self.r870_npc.mag_amount = mag_amounts.rifle

    self.benelli_npc.DAMAGE = 8
    self.benelli_npc.caliber = "12 gauge"
    self.benelli_npc.usage = "is_shotgun_mag"
    self.benelli_npc.mag_amount = mag_amounts.rifle

    self.mossberg_npc.DAMAGE = 7
    self.mossberg_npc.caliber = "12 gauge"
    self.mossberg_npc.mag_amount = mag_amounts.rifle

    self.saiga_npc.DAMAGE = 8
    self.saiga_npc.caliber = "12 gauge"
    self.saiga_npc.mag_amount = mag_amounts.rifle

    self.sko12_conc_npc.bullet_class = nil
    self.sko12_conc_npc.concussion_data = nil
    self.sko12_conc_npc.DAMAGE = 7
    self.sko12_conc_npc.caliber = "12 gauge"
    self.sko12_conc_npc.mag_amount = mag_amounts.rifle
    self.sko12_conc_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_slug"

    for i, k in pairs(self) do if k.rays and k.caliber and self.calibers[k.caliber] then k.rays = self.calibers[k.caliber][1].proj_amount or k.rays end end

    --[[
    self.sko12_npc = deep_clone(self.sko12_conc_npc)
    self.sko12_npc.bullet_class = nil
    self.sko12_npc.concussion_data = nil
    self.sko12_npc.DAMAGE = 6
    ]]

------IS_SMG
    self.mp5_npc.DAMAGE = 2
    self.mp5_npc.caliber = "9x19"
    self.mp5_npc.mag_amount = mag_amounts.smg
    self.mp5_npc.auto.fire_rate = 0.08

    self.mp5_tactical_npc.DAMAGE = 2
    self.mp5_tactical_npc.caliber = "9x19"
    self.mp5_tactical_npc.mag_amount = mag_amounts.smg
    self.mp5_tactical_npc.auto.fire_rate = 0.07

    self.ump_npc.DAMAGE = 2
    self.ump_npc.caliber = ".45 ACP"
    self.ump_npc.mag_amount = mag_amounts.smg
    self.ump_npc.auto.fire_rate = 0.1

    self.mac11_npc.DAMAGE = 1
    self.mac11_npc.caliber = ".380 ACP"
    self.mac11_npc.mag_amount = mag_amounts.smg
    self.mac11_npc.auto.fire_rate = 0.06

    self.mp9_npc.DAMAGE = 2
    self.mp9_npc.caliber = "9x19"
    self.mp9_npc.mag_amount = mag_amounts.smg
    self.mp9_npc.auto.fire_rate = 0.08

------IS_PISTOL
    self.c45_npc.DAMAGE = 2
    self.c45_npc.caliber = "9x19"
    self.c45_npc.mag_amount = mag_amounts.pistol

    self.beretta92_npc.DAMAGE = 2
    self.beretta92_npc.caliber = "9x19"
    self.beretta92_npc.mag_amount = mag_amounts.pistol

    self.glock_18_npc.DAMAGE = 2
    self.glock_18_npc.caliber = "9x19"
    self.glock_18_npc.mag_amount = mag_amounts.pistol

    self.deagle_npc.DAMAGE = 3
    self.deagle_npc.caliber = ".50 AE"
    self.deagle_npc.mag_amount = mag_amounts.pistol

------IS_AKIMBO_PISTOL
    self.x_c45_npc.DAMAGE = self.c45_npc.DAMAGE

------IS_REVOLVER
    self.raging_bull_npc.DAMAGE = 3
    self.raging_bull_npc.caliber = ".44 Mag"
    self.raging_bull_npc.mag_amount = mag_amounts.pistol

------IS_MINI
    self.mini_npc.DAMAGE = 5
    self.mini_npc.caliber = "7.62x51"
    self.mini_npc.mag_amount = mag_amounts.lmg

------IS_FLAMETHROWER
    self.flamethrower_npc.DAMAGE = 0.2

    self.snowthrower_npc.DAMAGE = 0.3
------MELEE
	self.npc_melee = {
		baton = {}
	}
	self.npc_melee.baton.unit_name = Idstring("units/payday2/characters/ene_acc_baton/ene_acc_baton")
	self.npc_melee.baton.damage = 3
	self.npc_melee.baton.animation_param = "melee_baton"
	self.npc_melee.baton.player_blood_effect = true
	self.npc_melee.knife_1 = {
		unit_name = Idstring("units/payday2/characters/ene_acc_knife_1/ene_acc_knife_1"),
		damage = 5,
		animation_param = "melee_knife",
		player_blood_effect = true
	}
	self.npc_melee.fists = {
		unit_name = nil,
		damage = 1,
		animation_param = "melee_fist",
		player_blood_effect = true
	}
	self.npc_melee.helloween = {
		unit_name = Idstring("units/pd2_halloween/weapons/wpn_mel_titan_hammer/wpn_mel_titan_hammer"),
		damage = 10,
		animation_param = "melee_fireaxe",
		player_blood_effect = true
	}

--

end)



function WeaponTweakData:_init_data_swat_van_turret_module_npc()
	self.swat_van_turret_module.name_id = "debug_sentry_gun"
	self.swat_van_turret_module.DAMAGE = 5
	self.swat_van_turret_module.DAMAGE_MUL_RANGE = { { 800, 4 }, { 1000, 1.1 }, { 1500, 1 } }
	self.swat_van_turret_module.SUPPRESSION = 0
	self.swat_van_turret_module.SPREAD = 3
	self.swat_van_turret_module.FIRE_RANGE = 10000
	self.swat_van_turret_module.CLIP_SIZE = 50
	self.swat_van_turret_module.AUTO_RELOAD = true
	self.swat_van_turret_module.AUTO_RELOAD_DURATION = 4
	self.swat_van_turret_module.CAN_GO_IDLE = true
	self.swat_van_turret_module.IDLE_WAIT_TIME = 5
	self.swat_van_turret_module.AUTO_REPAIR = true
	self.swat_van_turret_module.AUTO_REPAIR_MAX_COUNT = 2
	self.swat_van_turret_module.AUTO_REPAIR_DURATION = 30
	self.swat_van_turret_module.ECM_HACKABLE = true
	self.swat_van_turret_module.FLASH_GRENADE = { effect_duration = 6, range = 300, chance = 1, check_interval = { 1, 1 }, quiet_time = { 10, 13 } }
	self.swat_van_turret_module.HACKABLE_WITH_ECM = true
	self.swat_van_turret_module.VELOCITY_COMPENSATION = { OVERCOMPENSATION = 50, SNAPSHOT_INTERVAL = 0.3 }
	self.swat_van_turret_module.muzzleflash = "effects/payday2/particles/weapons/big_762_auto"
	self.swat_van_turret_module.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556_lmg"
	self.swat_van_turret_module.auto.fire_rate = 0.06
	self.swat_van_turret_module.alert_size = 2500
	self.swat_van_turret_module.headshot_dmg_mul = 4
	self.swat_van_turret_module.EXPLOSION_DMG_MUL = 7
	self.swat_van_turret_module.FIRE_DMG_MUL = 0.1
	self.swat_van_turret_module.BAG_DMG_MUL = 100
	self.swat_van_turret_module.SHIELD_DMG_MUL = 1
	self.swat_van_turret_module.HEALTH_INIT = 5000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 600 --1000
	self.swat_van_turret_module.SHIELD_DAMAGE_CLAMP = 10000
	self.swat_van_turret_module.BODY_DAMAGE_CLAMP = 10000
	self.swat_van_turret_module.DEATH_VERIFICATION = { 0.4, 0.75 }
	self.swat_van_turret_module.DETECTION_RANGE = 8000
	self.swat_van_turret_module.DETECTION_DELAY = { { 900, 0.3 }, { 3500, 1.5 } }
	self.swat_van_turret_module.KEEP_FIRE_ANGLE = 0.95
	self.swat_van_turret_module.MAX_VEL_SPIN = 72
	self.swat_van_turret_module.MIN_VEL_SPIN = self.swat_van_turret_module.MAX_VEL_SPIN * 0.05
	self.swat_van_turret_module.SLOWDOWN_ANGLE_SPIN = 30
	self.swat_van_turret_module.ACC_SPIN = self.swat_van_turret_module.MAX_VEL_SPIN * 5
	self.swat_van_turret_module.MAX_VEL_PITCH = 60
	self.swat_van_turret_module.MIN_VEL_PITCH = self.swat_van_turret_module.MAX_VEL_PITCH * 0.05
	self.swat_van_turret_module.SLOWDOWN_ANGLE_PITCH = 20
	self.swat_van_turret_module.ACC_PITCH = self.swat_van_turret_module.MAX_VEL_PITCH * 5
	self.swat_van_turret_module.recoil = { horizontal = { 1, 1.5, 1, 1 }, vertical = { 1, 1.5, 1, 1 } }
	self.swat_van_turret_module.challenges = { group = "sentry_gun", weapon = "sentry_gun" }
	self.swat_van_turret_module.suppression = 0
end

function WeaponTweakData:_init_data_aa_turret_module_npc()
    self.aa_turret_module = deep_clone(self.swat_van_turret_module)
    self.aa_turret_module.CAN_GO_IDLE = false
    self.aa_turret_module.FLASH_GRENADE = nil
	self.aa_turret_module.AUTO_REPAIR = false
    --self.aa_turret_module.AUTO_REPAIR_MAX_COUNT = math.huge
end

function WeaponTweakData:_init_data_crate_turret_module_npc()
    self.crate_turret_module = deep_clone(self.swat_van_turret_module)
    self.crate_turret_module.AUTO_REPAIR = false
    self.crate_turret_module.FLASH_GRENADE = nil
    self.crate_turret_module.HEALTH_INIT = self.crate_turret_module.HEALTH_INIT * 0.25
    self.crate_turret_module.SHIELD_HEALTH_INIT = self.crate_turret_module.SHIELD_HEALTH_INIT * 0.5
end

function WeaponTweakData:_init_data_ceiling_turret_module_npc()
    self.ceiling_turret_module = deep_clone(self.swat_van_turret_module)
    self.ceiling_turret_module.AUTO_REPAIR = false
    --self.ceiling_turret_module.FLASH_GRENADE = nil
    self.ceiling_turret_module.HEALTH_INIT = self.ceiling_turret_module.HEALTH_INIT * 0.5
    self.ceiling_turret_module.SHIELD_HEALTH_INIT = 2
	self.ceiling_turret_module_no_idle = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_no_idle.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range = deep_clone(self.ceiling_turret_module)
	self.ceiling_turret_module_longer_range.CAN_GO_IDLE = false
	self.ceiling_turret_module_longer_range.FIRE_RANGE = 30000
	self.ceiling_turret_module_longer_range.DETECTION_RANGE = self.ceiling_turret_module_longer_range.FIRE_RANGE
end



function WeaponTweakData:nqr_ammotype_data(caliber, ammotype)
    local caliber_data = tweak_data.weapon.calibers[caliber] or tweak_data.weapon.calibers["9x19"]
    local ammotype_data = nil
    if ammotype and ammotype~="Default" then
        for i, k in pairs(caliber_data) do
            if k.name==ammotype then ammotype_data = k break end
        end
    end
    ammotype_data = ammotype_data or caliber_data[1]

    return ammotype_data
end
function WeaponTweakData:nqr_energy(ammotype_data, barrel, name)
	local default_barrel = ammotype_data.default_barrel or 1
	local default_energy = ammotype_data.default_energy or 1
	local barrel = barrel or 1
    local weight_factor = nil --todo

	local energy = (
		(barrel > default_barrel) and ( --LONGER
            default_energy + default_energy*(1-((default_barrel/barrel)^(1/2)))
        ) or (barrel < default_barrel) and ( --SHORTER
			--(default_energy * (1 - ((default_barrel - barrel) / default_barrel) ^ 1.5)) or
			default_energy * ( (barrel / default_barrel) ^ (1/3) )
        ) or --SAME
			default_energy
    )

    return energy
end
function WeaponTweakData:nqr_spread(ammotype_data, barrel, name)
    local wep_tweak = self[name]
	if not wep_tweak or not ammotype_data or not barrel then return 10 end

	local default_barrel = ammotype_data.default_barrel or 1
	local default_energy = ammotype_data.default_energy or 1
	local default_speed = ammotype_data.default_speed or 1
	local proj_weight = ammotype_data.proj_weight
	local proj_type = ammotype_data.proj_type
	local proj_amount = ammotype_data.proj_amount or 1
	local result_energy = self:nqr_energy(ammotype_data, barrel)
	local result_speed = default_speed * (result_energy / default_energy)
    local action_factor = wep_tweak.action and (
		(wep_tweak.action=="moving_barrel" and 1.2)
		or ((wep_tweak.action=="blowback" or wep_tweak.action=="roller_delayed") and 1.1)
		or 1
	) or 1.1

    local spread = (400+proj_weight)^(1/(10+(barrel))) * action_factor
	--spread = spread * (1+(proj_amount*0.1)-0.1) * (proj_type=="pointy" and 1.0 or proj_type=="rounded" and 1.05 or 1.1) -1.15
	spread = spread * (1+((proj_amount^(1*0.8))-1)*0.1) * (proj_type=="pointy" and 1.0 or proj_type=="rounded" and 1.05 or 1.1) -1.15

	--local result_spread = (300+proj_weight)^(1/(10+(barrel))) * action_factor
	--result_spread = result_spread * (1+(proj_amount*0.2)-0.1) * (proj_type=="pointy" and 1.0 or proj_type=="rounded" and 1.2 or 1.4)
    -- * 10 -11.5
	--managers.mission._fading_debug_output:script().log(tostring(action_factor), Color.white)
	return spread * 15
end
function WeaponTweakData:nqr_rise(ammotype_data, barrel, weight, name)
    local wep_tweak = self[name]
	if not wep_tweak or not ammotype_data or not barrel then return 100 end

	local default_barrel = ammotype_data.default_barrel or 1
	local default_energy = ammotype_data.default_energy or 1
	local proj_weight = ammotype_data.proj_weight
	local proj_type = ammotype_data.proj_type
	local proj_amount = ammotype_data.proj_amount or 1
	local barrel = barrel or 1
    local action_factor = wep_tweak.action and (
		(wep_tweak.action=="gatling" and 1)
		or (wep_tweak.action=="blowback" and 2)
		or (wep_tweak.action~="moving_barrel" and wep_tweak.action~="roller_delayed" and 3)
	) or 1
	local secondary_factor = ((wep_tweak.use_data.selection_index==1) and 1 or 0.75)
    local rise_factor = wep_tweak.rise_factor or 1

	local rise = (
        ((self:nqr_energy(ammotype_data, barrel)/(math.sqrt(weight)))*(1+rise_factor*0.2*secondary_factor))
        * action_factor
        
    ) * 0.005

	return rise
end
function WeaponTweakData:nqr_kick(ammotype_data, barrel, weight, name)
    local wep_tweak = self[name]
	if not wep_tweak or not ammotype_data or not barrel then return 100 end

	local default_barrel = ammotype_data.default_barrel or 1
	local default_energy = ammotype_data.default_energy or 1
	local proj_weight = ammotype_data.proj_weight
	local proj_type = ammotype_data.proj_type
	local proj_amount = ammotype_data.proj_amount or 1
	local barrel = barrel or 1
	local action_factor = wep_tweak.action and (
        wep_tweak.action~="moving_barrel"
        and wep_tweak.action~="blowback"
        and wep_tweak.action~="roller_delayed"
        and 1
    ) or 0.5
    local rise_factor = wep_tweak.rise_factor or 1

    local recoil = (0.1
		* ((self:nqr_energy(ammotype_data, barrel) / weight) * 0.25)
		--* (self._current_stats.shouldered and 1 or 0.5)
		* ((wep_tweak.action and wep_tweak.action~="moving_barrel" and wep_tweak.action~="blowback" and wep_tweak.action~="roller_delayed") and 1 or 0.5)
		* (wep_tweak.rise_factor and 1-wep_tweak.rise_factor*0.2 or 1)
		--* md_flash * md_brake * md_can
	)

	return recoil
end
function WeaponTweakData:nqr_bullet_size(caliber, ammotype_data)
    local size = 550
    if not self.calibers[caliber] then return size end

    size = ammotype_data.proj_size or size

    if string.sub(caliber, 1, 1)=="." then
        size = tonumber(string.sub("0"..caliber, 1, (string.find(caliber, " ") or string.find(caliber, "-"))-1)) * 25.4
    elseif string.find(caliber, "x") then
        size = tonumber(string.sub(caliber, 1, string.find(caliber, "x")-1))
    end

    return size
end



function WeaponTweakData:debug(text)
    managers.mission._fading_debug_output:script().log(text,  Color.white)
end



function WeaponTweakData:_set_easy() end
function WeaponTweakData:_set_normal() end
function WeaponTweakData:_set_hard() end
function WeaponTweakData:_set_overkill() end
function WeaponTweakData:_set_overkill_145() end
function WeaponTweakData:_set_easy_wish() end
function WeaponTweakData:_set_overkill_290() end
function WeaponTweakData:_set_sm_wish() end
