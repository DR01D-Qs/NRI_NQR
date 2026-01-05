function BlackMarketTweakData:_init_deployables(tweak_data)
	self.deployables = {
		doctor_bag = {}
	}
	self.deployables.doctor_bag.name_id = "bm_equipment_doctor_bag"
	self.deployables.ammo_bag = {
		name_id = "bm_equipment_ammo_bag"
	}
	self.deployables.ecm_jammer = {
		name_id = "bm_equipment_ecm_jammer"
	}
	self.deployables.sentry_gun = {
		name_id = "bm_equipment_sentry_gun"
	}
	self.deployables.trip_mine = {
		name_id = "bm_equipment_trip_mine"
	}
	self.deployables.first_aid_kit = {
		name_id = "bm_equipment_first_aid_kit"
	}
	self.deployables.grenade_crate = {
		name_id = "bm_equipment_grenade_crate",
		dlc = "mxm",
		texture_bundle_folder = "mxm"
	}

	self:_add_desc_from_name_macro(self.deployables)
end

Hooks:PostHook( BlackMarketTweakData, "_init_melee_weapons", "nqr_projectilestweakdata:_init_melee_weapons", function(self, tweak_data)
	self.melee_weapons.taser.tase_data = nil
	self.melee_weapons.taser.sounds.charge = "fist_charge"

	self.melee_weapons.zeus.tase_data = nil
	self.melee_weapons.zeus.sounds.charge = "fist_charge"

	self.melee_weapons.cqc.fire_dot_data = nil

	self.melee_weapons.fear.fire_dot_data = nil

	self.melee_weapons.spoon_gold.fire_dot_data = nil
end)

Hooks:PostHook( BlackMarketTweakData, "_init_weapon_skins", "nqr_BlackMarketTweakData:_init_weapon_skins", function(self)
	local families = {
		m4 = { "new_m4", "amcar", "m16", "olympic", "victor", },
		ak = { "ak74", "akm", "akm_gold", "rpk", },
		glock = { "glock_17", "glock_18c", "g22c", "x_g17", "x_g18c", "x_g22c", },
		r870 = { "r870", "serbu", },
	}

	self.weapon_skins.ak74_rodina.default_blueprint = {
		"wpn_fps_foregrip_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_ass_74_body_upperreceiver",
		"wpn_fps_ass_ak_body_lowerreceiver",
		"wpn_fps_ass_74_b_legend",
		"wpn_fps_upg_ak_m_uspalm",
		"wpn_upg_ak_s_legend",
		"wpn_upg_ak_g_legend",
		"wpn_upg_ak_fg_legend",
		"wpn_upg_ak_fl_legend",
		"wpn_fps_upg_o_cmore",
		"wpn_fps_upg_o_ak_scopemount",

		"wpn_fps_ass_74_ns_legend",
		"wpn_upg_ak_gb_standard",
		"wpn_fps_o_pos_a_o_sm",
	}
	self.weapon_skins.ak74_rodina.parts.wpn_upg_ak_fg_legend[Idstring("handguard_upper_wood"):key()] = nil
	self.weapon_skins.ak74_rodina.parts.wpn_upg_ak_gb_standard = {
		[Idstring("handguard_upper_wood"):key()] = {
			sticker = Idstring("units/payday2_cash/safes/sputnik/sticker/sticker_stbasil_df"),
			uv_scale = Vector3(1.54989, 2.0685, 1),
			uv_offset_rot = Vector3(-0.108275, 0.995172, -1.56)
		}
	}

	self.weapon_skins.deagle_bling.default_blueprint = {
		"wpn_fps_extra3_lock_gadgets",
		--"wpn_fps_extra_sightheightmod",

		"wpn_fps_pis_deagle_body_standard",
		"wpn_fps_pis_deagle_m_standard",
		"wpn_fps_pis_deagle_b_legend",
		"wpn_fps_pis_deagle_g_ergo",
		"wpn_fps_upg_o_rmr",

		"wpn_fps_pis_deagle_b_standard",
		"wpn_fps_remove_ironsight",
	}
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_standard[Idstring("barrel"):key()] = self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_legend[Idstring("mtr_barrel"):key()]
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_legend[Idstring("mtr_barrel"):key()] = nil
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_long = { [Idstring("longbarrel"):key()] = self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_standard[Idstring("barrel"):key()] }
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_modern = { [Idstring("mtr_barrel_custom"):key()] = self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_standard[Idstring("barrel"):key()] }
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_co_short = { [Idstring("comp2"):key()] = self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_legend[Idstring("mtr_legendcomp"):key()] }
	self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_co_long = { [Idstring("comp1"):key()] = self.weapon_skins.deagle_bling.parts.wpn_fps_pis_deagle_b_legend[Idstring("mtr_legendcomp"):key()] }

	self.weapon_skins.flamethrower_mk2_fire.default_blueprint = {
		"wpn_fps_fla_mk2_empty",
		"wpn_fps_fla_mk2_body_fierybeast",
		"wpn_fps_fla_mk2_mag"
	}

	self.weapon_skins.rpg7_boom.default_blueprint = {
		"wpn_fps_extra_lock_sights",

		"wpn_fps_rpg7_body",
		"wpn_fps_rpg7_m_grinclown",
		"wpn_fps_rpg7_barrel",
		"wpn_fps_upg_o_rx30",

		"wpn_fps_rpg7_sight_adapter",
	}

	self.weapon_skins.m134_bulletstorm.default_blueprint = {
		"wpn_fps_lmg_m134_body",
		"wpn_fps_lmg_m134_m_standard",
		"wpn_fps_lmg_m134_barrel_legendary",
		"wpn_fps_lmg_m134_body_upper_spikey",
		"wpn_fps_upg_fl_ass_utg",

		"wpn_fps_lmg_m134_body_upper",
	}

	self.weapon_skins.p90_dallas_sallad.default_blueprint = {
		--"wpn_fps_smg_p90_body_p90",
		"wpn_fps_smg_p90_m_std",
		"wpn_fps_smg_p90_b_legend",
		"wpn_fps_upg_o_cmore",
		"wpn_fps_upg_fl_ass_utg",

		"wpn_fps_smg_p90_b_short",
	}
	self.weapon_skins.p90_dallas_sallad.parts.wpn_fps_smg_p90_b_legend = deep_clone(self.weapon_skins.p90_dallas_sallad.parts.wpn_fps_smg_p90_body_p90)
	self.weapon_skins.p90_dallas_sallad.parts.wpn_fps_smg_p90_body_p90 = nil

	self.weapon_skins.r870_waves.default_blueprint = {
		"wpn_fps_extra_lock_sights",
		"wpn_fps_extra2_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_shot_r870_body_standard",
		--"wpn_fps_shot_r870_b_legendary",
		"wpn_fps_shot_r870_fg_legendary",
		"wpn_fps_shot_r870_s_legendary",

		"wpn_fps_shot_r870_b_long",
		"wpn_fps_shot_r870_s_nostock",
		"wpn_fps_shot_r870_b_legendary",
	}
	self.weapon_skins.r870_waves.types.grip = deep_clone(self.weapon_skins.r870_waves.types.stock)
	self.weapon_skins.r870_waves.types.stock = nil

	self.weapon_skins.x_1911_ginger.default_blueprint = {
		"wpn_fps_pis_1911_g_legendary",
		"wpn_fps_pis_1911_fl_legendary",
		"wpn_fps_pis_1911_body_standard",
		"wpn_fps_pis_1911_b_long",
		"wpn_fps_pis_1911_o_long",
		"wpn_fps_pis_1911_m_standard",

		"wpn_fps_pis_1911_bb_long_vented",
	}

	self.weapon_skins.colt_1911_wwt.default_blueprint = {
		"wpn_fps_pis_1911_body_standard",
		"wpn_fps_pis_1911_g_standard",
		"wpn_fps_pis_1911_b_long",
		"wpn_upg_o_marksmansight_rear",
		"wpn_fps_pis_1911_m_extended",

		"wpn_fps_pis_1911_bb_long_vented",
	}

	self.weapon_skins.model70_baaah.default_blueprint = {
		"wpn_fps_extra_lock_sights",
		"wpn_fps_extra2_lock_gadgets",

		"wpn_fps_snp_model70_b_legend",
		"wpn_fps_snp_model70_body_standard",
		"wpn_fps_snp_model70_s_legend",
		"wpn_fps_snp_model70_m_standard",
		"wpn_fps_upg_o_leupold",
		"wpn_fps_upg_fl_ass_peq15",

		"wpn_fps_snp_model70_b_short",
		"wpn_fps_snp_model70_sights",
		"wpn_fps_snp_model70_o_rail",
		"wpn_fps_addon_ris",
	}
	self.weapon_skins.model70_baaah.parts.wpn_fps_snp_model70_s_standard = deep_clone(self.weapon_skins.model70_baaah.parts.wpn_fps_snp_model70_s_legend)
	self.weapon_skins.model70_baaah.parts.wpn_fps_snp_model70_s_standard[Idstring("mtr_body"):key()].uv_offset_rot = Vector3(0.0068784, 1.284013, 3.569029)
	self.weapon_skins.model70_baaah.parts.wpn_fps_snp_model70_s_standard[Idstring("mtr_body"):key()].uv_scale = Vector3(3.42316, 1.71177, 0)

	self.weapon_skins.par_wolf.default_blueprint = {
		"wpn_fps_extra2_lock_gadgets",

		"wpn_fps_lmg_svinet_b_standard",
		"wpn_fps_lmg_par_body_standard",
		"wpn_fps_lmg_par_m_standard",
		"wpn_fps_lmg_svinet_s_legend",
		"wpn_fps_lmg_par_upper_reciever",
		"wpn_fps_upg_bp_lmg_lionbipod",
		"wpn_fps_upg_fl_ass_utg",

		"wpn_fps_lmg_par_b_standard",
		"wpn_fps_addon_ris",
	}
	self.weapon_skins.par_wolf.types.wep_cos = self.weapon_skins.par_wolf.types.barrel

	self.weapon_skins.m16_cola.default_blueprint = {
		"wpn_fps_upper_lock_sights",
		"wpn_fps_foregrip_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_m4_uupg_draghandle",
		"wpn_fps_upg_m4_m_pmag",
		"wpn_fps_upg_o_acog",
		--"wpn_fps_ass_m16_b_legend",
		"wpn_fps_ass_m16_fg_legend",
		"wpn_fps_ass_m16_s_legend",
		--"wpn_fps_upg_m4_g_mgrip",
		"wpn_fps_upg_ass_m4_lower_reciever_core",
		"wpn_fps_upg_ass_m4_upper_reciever_core",
		"wpn_fps_amcar_bolt_standard",

		"wpn_fps_m16_fg_standard",
		"wpn_fps_upg_m4_g_standard",
		"wpn_fps_upg_blankcal_556",
		"wpn_fps_m4_uupg_b_medium_os2",
		"wpn_fps_m4_uupg_fg_rail_ext",
		"wpn_fps_remove_ironsight",
		"wpn_fps_remove_s_addon",
	}

	self.weapon_skins.judge_burn.default_blueprint = {
		"wpn_fps_extra3_lock_gadgets",

		"wpn_fps_pis_judge_body_standard",
		"wpn_fps_pis_judge_b_legend",
		"wpn_fps_pis_judge_g_legend",
	}
	--[[self.weapon_skins.judge_burn.types = {
		--grip = self.weapon_skins.judge_burn.parts.wpn_fps_pis_judge_g_legend[Idstring("mtr_grip_legendary"):key()],
	}
	self.weapon_skins.judge_burn.parts.wpn_fps_pis_rage_g_ergo = {
		[Idstring("ergo"):key()] = deep_clone(self.weapon_skins.judge_burn.parts.wpn_fps_pis_judge_g_legend[Idstring("mtr_grip_legendary"):key()])
	}
	self.weapon_skins.judge_burn.parts.wpn_fps_pis_rage_g_ergo[Idstring("ergo"):key()].uv_scale = Vector3(0.66967, 1.20804, 0.310756)
	self.weapon_skins.judge_burn.parts.wpn_fps_pis_rage_g_ergo[Idstring("ergo"):key()].uv_offset_rot = Vector3(-0.095752, 1.00125, 4.7108)]]

	self.weapon_skins.boot_buck.default_blueprint = {
		"wpn_fps_extra_lock_sights_boot",
		"wpn_fps_extra4_lock_sights",
		"wpn_fps_extra2_lock_gadgets",
	
		"wpn_fps_sho_boot_b_legendary",
		--"wpn_fps_sho_boot_fg_legendary",
		"wpn_fps_sho_boot_o_legendary",
		"wpn_fps_sho_boot_s_legendary",
		"wpn_fps_sho_boot_body_standard",
		"wpn_fps_sho_boot_em_extra",
		"wpn_fps_sho_boot_m_standard",

		"wpn_fps_sho_boot_b_standard",
		"wpn_fps_sho_boot_b_legendary_axe",
		"wpn_fps_sho_boot_fg_standard",
	}
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary[Idstring("mtr_fg_legend"):key()] = deep_clone(self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_fg_legendary[Idstring("mtr_fg_legend"):key()])
	--self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary[Idstring("mtr_sight_legend"):key()] = deep_clone(self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_o_legendary[Idstring("mtr_sight_legend"):key()])
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary_axe = deep_clone(self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary)
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary_stock = deep_clone(self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_b_legendary)
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_s_legendary[Idstring("mtr_s_legend"):key()].sticker = Idstring("units/payday2_cash/safes/buck/sticker/buck_sticker_019_df")
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_s_legendary[Idstring("mtr_s_legend"):key()].uv_offset_rot = Vector3(-0.275371, 1.02687, 4.73275)
	self.weapon_skins.boot_buck.parts.wpn_fps_sho_boot_s_legendary[Idstring("mtr_s_legend"):key()].uv_scale = Vector3(3.74393, 2.69409, 0.115192)
	self.weapon_skins.boot_buck.types.stock = nil

	self.weapon_skins.ksg_same.default_blueprint = {
		"wpn_fps_extra2_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_sho_ksg_body_standard",
		"wpn_fps_sho_ksg_b_legendary",
		"wpn_fps_sho_ksg_fg_standard",
		"wpn_fps_upg_o_dd_rear",

		"wpn_fps_sight_pos_default",
	}

	self.weapon_skins.tecci_grunt.default_blueprint = {
		"wpn_fps_foregrip_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_ass_tecci_dh_standard",
		"wpn_fps_ass_tecci_lower_reciever",
		"wpn_fps_ass_tecci_m_drum",
		"wpn_fps_ass_tecci_upper_reciever",
		"wpn_fps_ass_tecci_vg_standard",
		"wpn_fps_upg_m4_g_hgrip",
		"wpn_fps_upg_o_eotech",
		--"wpn_fps_ass_tecci_b_legend",
		"wpn_fps_ass_tecci_fg_legend",
		"wpn_fps_ass_tecci_s_legend",

		"wpn_fps_ass_tecci_b_standard",
		"wpn_fps_ass_tecci_fg_standard",
		"wpn_fps_ass_tecci_ns_standard",
		"wpn_fps_remove_ironsight",
	}

	self.weapon_skins.serbu_lones.default_blueprint = {
		"wpn_fps_extra_lock_sights",
		"wpn_fps_extra2_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_shot_r870_body_standard",
		"wpn_fps_shot_shorty_b_legendary",
		"wpn_fps_shot_shorty_fg_legendary",
		"wpn_fps_shot_shorty_s_legendary",
		"wpn_fps_upg_ns_shot_shark",
		"wpn_fps_upg_o_reflex",

		"wpn_fps_shot_r870_b_short",
		"wpn_fps_shot_r870_ris_special",
		"wpn_fps_upg_m4_g_standard",
	}
	self.weapon_skins.serbu_lones.parts.wpn_fps_shot_r870_b_short = deep_clone(self.weapon_skins.serbu_lones.parts.wpn_fps_shot_shorty_b_legendary)

	self.weapon_skins.new_m14_lones.default_blueprint = {
		"wpn_fps_extra2_lock_gadgets",
		"wpn_fps_extra3_lock_vertical_grips",

		--"wpn_fps_ass_m14_b_legendary",
		--"wpn_fps_ass_m14_body_lower_legendary",
		--"wpn_fps_ass_m14_body_upper_legendary",
		"wpn_fps_ass_m14_m_standard",
		"wpn_fps_ass_m14_body_legendary",
		"wpn_fps_upg_o_m14_scopemount",
		"wpn_fps_upg_o_acog",
		"wpn_fps_upg_ns_ass_smg_medium",

		"wpn_fps_ass_m14_b_standard",
		"wpn_fps_ass_m14_body_lower",
		"wpn_fps_ass_m14_body_upper",
		"wpn_fps_ass_m14_body_dmr",
		"wpn_fps_o_pos_a_o_sm",
		"wpn_fps_ass_m14_body_legendary_stock",
	}
	self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_b_standard = deep_clone(self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_b_legendary)
	self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_body_lower = deep_clone(self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_body_lower_legendary)
	self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_body_upper = deep_clone(self.weapon_skins.new_m14_lones.parts.wpn_fps_ass_m14_body_upper_legendary)

	self.weapon_skins.new_raging_bull_smosh.default_blueprint = {
		"wpn_fps_extra_lock_sights",

		"wpn_fps_pis_rage_body_standard",
		"wpn_fps_pis_rage_b_long",
		--"wpn_fps_pis_rage_extra",
		"wpn_fps_pis_rage_g_standard",
	}
	self.weapon_skins.new_raging_bull_smosh.types = { grip = deep_clone(self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_rage_g_ergo[Idstring("ergo"):key()]) }
	self.weapon_skins.new_raging_bull_smosh.types.grip.sticker = nil
	self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_judge_g_standard = { [Idstring("mtr_grip"):key()] = deep_clone(self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_rage_g_standard[Idstring("grip"):key()]) }
	self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_judge_g_standard[Idstring("mtr_grip"):key()].sticker = nil
	self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_korth_g_houge = { [Idstring("mtr_korth_grip_03"):key()] = deep_clone(self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_rage_g_standard[Idstring("grip"):key()]) }
	self.weapon_skins.new_raging_bull_smosh.parts.wpn_fps_pis_korth_g_houge[Idstring("mtr_korth_grip_03"):key()].sticker = nil

	self.weapon_skins.contraband_sfs.default_blueprint = {
		"wpn_fps_ass_contraband_b_standard",
		"wpn_fps_ass_contraband_body_standard",
		"wpn_fps_ass_contraband_dh_standard",
		"wpn_fps_ass_contraband_fg_standard",
		"wpn_fps_ass_contraband_g_standard",
		--"wpn_fps_ass_contraband_gl_m203",
		"wpn_fps_ass_contraband_m_standard",
		--"wpn_fps_ass_contraband_s_standard",
		"wpn_fps_ass_contraband_bolt_standard",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_upg_ns_ass_smg_small",
		"wpn_fps_ass_contraband_o_standard",

		"wpn_fps_m16_s_solid",
	}

	self.weapon_skins.x_akmsu_wac.default_blueprint = {
		"wpn_fps_foregrip_lock_gadgets",
		"wpn_fps_foregrip_lock_vertical_grips",

		"wpn_fps_smg_akmsu_body_lowerreceiver",
		"wpn_fps_ass_akm_body_upperreceiver_vanilla",
		"wpn_fps_smg_akmsu_b_standard",
		"wpn_fps_upg_ak_g_wgrip",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_upg_ass_ns_surefire",
		"wpn_fps_upg_ak_m_uspalm",
		"wpn_fps_smg_akmsu_fg_rail",

		"wpn_fps_addon_ris",
	}

	self.weapon_skins.ppk_cs3.default_blueprint = {
		"wpn_fps_extra3_lock_gadgets",

		"wpn_fps_pis_ppk_body_standard",
		"wpn_fps_pis_ppk_m_standard",
		"wpn_fps_pis_ppk_b_long",
		"wpn_fps_upg_ns_pis_jungle",
		"wpn_fps_pis_ppk_g_laser",
		"wpn_fps_upg_fl_pis_tlr1",

		"wpn_fps_pis_ppk_b_barrel_long",
		"wpn_fps_pis_ppk_fl_mount",
	}

	self.weapon_skins.x_chinchilla_mxs.default_blueprint = {
		"wpn_fps_pis_chinchilla_body",
		"wpn_fps_pis_chinchilla_cylinder",
		"wpn_fps_pis_chinchilla_dh_hammer",
		"wpn_fps_pis_chinchilla_ejector",
		"wpn_fps_pis_chinchilla_ejectorpin",
		"wpn_fps_pis_chinchilla_lock_arm",
		"wpn_fps_pis_chinchilla_m_bullets",
		"wpn_fps_pis_chinchilla_b_satan",
		"wpn_fps_pis_chinchilla_g_death"
	}

	self.weapon_skins.mac10_skf.default_blueprint = {
		"wpn_fps_extra_lock_sights",
		"wpn_fps_extra_lock_gadgets",
		"wpn_fps_extra_lock_vertical_grips",

		"wpn_fps_smg_mac10_body_mac10",
		"wpn_fps_smg_mac10_b_dummy",
		"wpn_fps_smg_mac10_body_ris",
		"wpn_fps_upg_ns_ass_smg_tank",
		"wpn_fps_upg_fl_ass_smg_sho_peqbox",
		"wpn_fps_smg_mac10_m_extended",
		"wpn_fps_upg_o_eotech",
		--"wpn_fps_smg_mac10_s_skel",
	}
	self.weapon_skins.mac10_skf.parts.wpn_fps_smg_mac10_s_fold[Idstring("fold"):key()] = self.weapon_skins.mac10_skf.parts.wpn_fps_smg_mac10_s_skel[Idstring("skeletal"):key()]

	self.weapon_skins.polymer_css.default_blueprint = {
		"wpn_fps_extra2_lock_gadgets",

		"wpn_fps_smg_polymer_body_standard",
		"wpn_fps_smg_polymer_dh_standard",
		"wpn_fps_smg_polymer_fg_standard",
		"wpn_fps_smg_polymer_barrel_standard",
		"wpn_fps_smg_polymer_m_standard",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_smg_polymer_ns_silencer",
		"wpn_fps_smg_polymer_bolt_standard",
		"wpn_fps_smg_polymer_bolt_standard",
		"wpn_fps_upg_m4_s_ubr",
		"wpn_fps_upg_o_eotech_xps",

		"wpn_fps_addon_ris",
		"wpn_fps_remove_ironsight",
	}

	self.weapon_skins.shrew_dss.default_blueprint = {
		"wpn_fps_extra3_lock_gadgets",

		"wpn_fps_pis_shrew_b_barrel",
		"wpn_fps_pis_shrew_body_frame",
		"wpn_fps_pis_shrew_h_hammer",
		"wpn_fps_pis_shrew_m_standard",
		"wpn_fps_pis_shrew_g_bling",
		"wpn_fps_pis_shrew_sl_milled",
	}

	self.weapon_skins.p226_cat.default_blueprint = {
		"wpn_fps_pis_p226_body_standard",
		"wpn_fps_pis_p226_m_standard",
		"wpn_fps_pis_p226_b_long",
		"wpn_fps_upg_pis_ns_flash",
		"wpn_fps_pis_p226_g_standard",

		"wpn_fps_pis_p226_b_barrel_long",
	}

	self.weapon_skins.scar_ait.default_blueprint = {
		"wpn_fps_ass_scar_m_standard",
		"wpn_fps_ass_scar_body_standard",
		"wpn_fps_upg_vg_ass_smg_afg",
		--"wpn_fps_ass_scar_b_short",
		"wpn_fps_ass_scar_fg_railext",
		"wpn_fps_upg_fl_ass_peq15",
		"wpn_fps_upg_m4_g_ergo",
		"wpn_fps_ass_scar_s_sniper",
		"wpn_fps_upg_o_cs",
		"wpn_fps_upg_ns_ass_smg_medium",

		"wpn_fps_ass_scar_b_medium",
		"wpn_fps_fold_ironsight",
	}

	self.weapon_skins.saw_nin.default_blueprint = {
		"wpn_fps_saw_b_normal",
		"wpn_fps_saw_body_speed",
		"wpn_fps_saw_m_blade_durable"
	}



	for i, k in pairs(self.weapon_skins) do
		k.default_blueprint = k.rarity=="legendary" and k.default_blueprint
		k.bonus = nil
		k.locked = nil
		--k.unique_name_id = nil
		k.special_blueprint = nil
		for u, j in pairs(k.weapon_ids or {}) do
			k.special_blueprint = k.special_blueprint or {} 
			k.special_blueprint[j] = {} --k.default_blueprint and deep_clone(k.default_blueprint)
		end

		for u, j in pairs(string.find(i, "x_") and k.weapon_ids or {}) do
			--if string.find(j, "x_") then k.weapon_id = j end
		end

		for u, j in pairs(families) do
			local wep = table.contains(j, k.weapon_id)
			if wep then
				k.weapon_ids = k.weapon_ids or {}
				for y, h in pairs(j) do
					if h~=wep and not table.contains(k.weapon_ids or {}, h) then table.insert(k.weapon_ids, h) end
				end
				break
			end
		end

		if k.parts and k.parts.wpn_fps_pis_rage_body_standard then
			k.parts.wpn_fps_pis_rage_m_body = deep_clone(k.parts.wpn_fps_pis_rage_body_standard)
			k.parts.wpn_fps_pis_rage_m_body[Idstring("smooth"):key()] = deep_clone(k.parts.wpn_fps_pis_rage_body_standard[Idstring("cylinder"):key()])
		end
	end

	self.weapon_skins.mac10_skf.special_blueprint = {
		mac10 = { "wpn_fps_smg_mac10_s_fold" },
		x_mac10 = { "wpn_fps_remove_s" },
	}
	self.weapon_skins.x_akmsu_wac.special_blueprint = {
		akmsu = { "wpn_fps_upg_ak_s_solidstock" },
		x_akmsu = { "wpn_fps_remove_s" },
	}
end )