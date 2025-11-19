function table.addto(main_table, table_of_components)
    for i, k in pairs(deep_clone(table_of_components)) do table.insert(main_table, k) end
end
function table.addto_dict(main_table, table_of_components)
    for i, k in pairs(deep_clone(table_of_components)) do main_table[i] = k end
end

function table.deletefrom(main_table, table_of_components)
    for i, k in pairs(deep_clone(table_of_components)) do table.delete(main_table, k) end
end
function table.deletefrom_dict(main_table, table_of_components)
    for i, k in pairs(deep_clone(table_of_components)) do main_table[k] = nil end
end

function table.with(main_table, to_add)
    local table_clone = deep_clone(main_table)

    if type(to_add)=="table" then
        local is_dict = nil
        for i, k in pairs(table_clone) do if type(i)=="string" then is_dict = true break end end
        if is_dict then
            table.addto_dict(table_clone, to_add)
        else
            table.addto(table_clone, to_add)
        end
    else
        table.insert(table_clone, to_add)
    end

    return table_clone
end
function table.without(main_table, to_delete)
    local table_clone = deep_clone(main_table)

    if type(to_delete)=="table" then
        local is_dict = nil
        for i, k in pairs(table_clone) do if type(i)=="string" then is_dict = true break end end
        if is_dict then
            table.deletefrom_dict(table_clone, to_delete)
        else
            table.deletefrom(table_clone, to_delete)
        end
    else
        table.delete(table_clone, to_delete)
    end

    return table_clone
end
function table.copy_append(t, ...)
    local new_table = deep_clone(t)

	for _, list_table in ipairs({
		...
	}) do
		for key, value in pairs(list_table) do
			new_table[key] = value
		end
	end

	return new_table
end

function WeaponFactoryTweakData:deletefrom_by_param(main_table, parameter, value)
    local table_clone = deep_clone(main_table)
    local csc = {}
    for i, k in pairs(table_clone) do if self.parts[k][parameter]==value then table.insert(csc, k) end end
    table.deletefrom(table_clone, csc)
end

function table.swap(main_table, value1, value2)
    local csc = table.get_vector_index(main_table, value1)
    if csc then
        main_table[csc] = value2
        --table.remove(main_table, csc)
        --table.insert(main_table, csc, value2)
    end
end

function table.combine(...)
    local result_table = {}
    for i, k in pairs({...}) do table.addto(result_table, deep_clone(k)) end
    return deep_clone(result_table)
end
function table.combine_dict(...)
    local result_table = {}
    for i, k in pairs({...}) do table.addto_dict(result_table, k) end
    return result_table
end



Hooks:PostHook( WeaponFactoryTweakData, "_init_m16", "nqr_weaponfactorytweakdata__init_m16", function(self)
    --self.parts.wpn_fps_m16_fg_standard.pcs = {}
end)



function WeaponFactoryTweakData:_init_steelsight_units()
	local optic_steelsights = {
		wpn_fps_upg_o_acog = {
			third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
			unit = "units/pd2_dlc_ivs/weapons/wpn_fps_upg_o_acog_cut/wpn_fps_upg_o_acog_cut",
			steelsight_swap_progress_trigger = 0.9
		},
		wpn_fps_upg_o_specter = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_ivs/weapons/wpn_fps_upg_o_specter_cut/wpn_fps_upg_o_specter_cut"
		},
		wpn_fps_upg_o_bmg = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_ivs/weapons/wpn_fps_upg_o_bmg_cut/wpn_fps_upg_o_bmg_cut"
		},
		wpn_fps_upg_o_tf90 = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_ivs/weapons/wpn_fps_upg_o_tf90_cut/wpn_fps_upg_o_tf90_cut"
		},
		wpn_fps_upg_o_poe = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_tawp/weapons/wpn_fps_upg_o_poe/wpn_fps_upg_o_poe_cut"
		},
		wpn_fps_upg_o_hamr = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_mxm/weapons/wpn_fps_upg_o_hamr/wpn_fps_upg_o_hamr_cut"
		},
		wpn_fps_upg_o_atibal = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_mxm/weapons/wpn_fps_upg_o_atibal/wpn_fps_upg_o_atibal_cut"
		},
        wpn_fps_upg_o_shortdot = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_pxp3/weapons/wpn_fps_upg_o_northtac/wpn_fps_upg_o_northtac_inside"
		},
		wpn_fps_upg_o_northtac = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_pxp3/weapons/wpn_fps_upg_o_northtac/wpn_fps_upg_o_northtac_inside"
		},
		wpn_fps_upg_o_schmidt = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_pxp4/weapons/wpn_fps_upg_o_schmidt/wpn_fps_upg_o_schmidt_inside"
		},
        wpn_fps_upg_o_box = {
			steelsight_swap_progress_trigger = 0.9,
			unit = "units/pd2_dlc_tng/weapons/wpn_fps_upg_o_box/wpn_fps_upg_o_box"
		},
	}
	local steelsight_id = nil

	for part_id, steelsight_data in pairs(optic_steelsights) do
		steelsight_id = part_id .. "_steelsight"
		self.parts[part_id].steelsight_visible = false
		self.parts[part_id].adds = self.parts[part_id].adds or {}

		table.insert(self.parts[part_id].adds, steelsight_id)

		self.parts[steelsight_id] = steelsight_data
		self.parts[steelsight_id].steelsight_visible = true
		self.parts[steelsight_id].steelsight_parent = part_id
		self.parts[steelsight_id].stats = {
			value = 1
		}
		self.parts[steelsight_id].type = "sight_swap"
		self.parts[steelsight_id].parent = "sight"
		self.parts[steelsight_id].a_obj = nil
		self.parts[steelsight_id].texture_switch = self.parts[steelsight_id].texture_switch or self.parts[part_id].texture_switch
		self.parts[steelsight_id].material_parameters = self.parts[steelsight_id].material_parameters or self.parts[part_id].material_parameters
		self.parts[steelsight_id].third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy"
		self.parts[steelsight_id].skip_third_thq = true
	end
end



Hooks:PostHook( WeaponFactoryTweakData, "init", "nqr_weaponfactorytweakdata", function(self)
    self.nqr = {}

    for i, k in pairs(self) do
        if k.uses_parts then
            k.adds = k.adds or {}
            k.override = k.override or {}
        end
    end
    for i, k in pairs(self.parts) do
        k.forbids = k.forbids or {}
        k.adds = k.adds or {}
        k.override = k.override or {}
        k.is_a_unlockable = nil
        k.stats = k.stats or {}
        k.stats.damage = nil
        k.stats.spread = nil
        k.stats.recoil = nil
        k.stats.reload = nil
        k.stats.zoom = nil
        --if k.animations then k.animations.magazine_empty = nil end
    end
    --for wep, i in pairs(self) do if self[wep].animations then self[wep].animations.magazine_empty = nil end end

    local fantom_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy"

--DEFINITIONS
    self.nqr.all_sights = {
        "wpn_fps_o_blank",

        "wpn_fps_upg_o_tf90",
        "wpn_fps_upg_o_aimpoint",
        "wpn_fps_upg_o_aimpoint_2",
        "wpn_fps_upg_o_cs",
        "wpn_fps_upg_o_t1micro",
        "wpn_fps_upg_o_eotech",
        "wpn_fps_upg_o_eotech_xps",
        "wpn_fps_upg_o_docter",
        "wpn_fps_upg_o_uh",
        "wpn_fps_upg_o_fc1",
        "wpn_fps_upg_o_rx01",
        "wpn_fps_upg_o_rx30",
        "wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_reflex",
        "wpn_fps_pis_c96_sight",

        "wpn_fps_upg_o_poe",
        "wpn_fps_upg_o_atibal",
        "wpn_fps_upg_o_hamr",
        "wpn_fps_upg_o_acog",
        "wpn_fps_upg_o_specter",
        "wpn_fps_upg_o_spot",

        "wpn_fps_upg_o_bmg",
        "wpn_fps_upg_o_shortdot",
        "wpn_fps_upg_o_northtac",
        "wpn_fps_upg_o_box",
        "wpn_fps_upg_o_schmidt",
        "wpn_fps_upg_o_leupold",

        "wpn_fps_upg_o_45steel",
        "wpn_fps_upg_o_45iron",
        "wpn_fps_upg_o_45rds_v2",
        "wpn_fps_upg_o_45rds",
        "wpn_fps_upg_o_xpsg33_magnifier",
        "wpn_fps_upg_o_sig",
        "wpn_fps_upg_o_northtac_reddot",
        "wpn_fps_upg_o_atibal_reddot",

        "wpn_fps_upg_o_hamr_reddot",
    }
    self.nqr.all_main_sights = {
        "wpn_fps_upg_o_tf90",
        "wpn_fps_upg_o_aimpoint",
        "wpn_fps_upg_o_aimpoint_2",
        "wpn_fps_upg_o_cs",
        "wpn_fps_upg_o_t1micro",
        "wpn_fps_upg_o_eotech",
        "wpn_fps_upg_o_eotech_xps",
        "wpn_fps_upg_o_docter",
        "wpn_fps_upg_o_uh",
        "wpn_fps_upg_o_fc1",
        "wpn_fps_upg_o_rx01",
        "wpn_fps_upg_o_rx30",
        "wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_reflex",
        "wpn_fps_pis_c96_sight",

        "wpn_fps_upg_o_poe",
        "wpn_fps_upg_o_atibal",
        "wpn_fps_upg_o_hamr",
        "wpn_fps_upg_o_acog",
        "wpn_fps_upg_o_specter",
        "wpn_fps_upg_o_spot",

        "wpn_fps_upg_o_bmg",
        "wpn_fps_upg_o_shortdot",
        "wpn_fps_upg_o_northtac",
        "wpn_fps_upg_o_box",
        "wpn_fps_upg_o_schmidt",
        "wpn_fps_upg_o_leupold",
    }
    self.nqr.all_optics = {
        "wpn_fps_upg_o_poe",
        "wpn_fps_upg_o_atibal",
        "wpn_fps_upg_o_hamr",
        "wpn_fps_upg_o_acog",
        "wpn_fps_upg_o_specter",
        "wpn_fps_upg_o_spot",

        "wpn_fps_upg_o_bmg",
        "wpn_fps_upg_o_shortdot",
        "wpn_fps_upg_o_northtac",
        "wpn_fps_upg_o_box",
        "wpn_fps_upg_o_schmidt",
        "wpn_fps_upg_o_leupold",

        "wpn_fps_upg_o_xpsg33_magnifier",
        "wpn_fps_upg_o_sig",
    }
    self.nqr.all_assault_optics = {
        "wpn_fps_upg_o_poe",
        "wpn_fps_upg_o_atibal",
        "wpn_fps_upg_o_hamr",
        "wpn_fps_upg_o_acog",
        "wpn_fps_upg_o_specter",
        "wpn_fps_upg_o_spot",
    }
    self.nqr.all_snoptics = {
        "wpn_fps_upg_o_bmg",
        "wpn_fps_upg_o_shortdot",
        "wpn_fps_upg_o_northtac",
        "wpn_fps_upg_o_box",
        "wpn_fps_upg_o_schmidt",
		"wpn_fps_upg_o_leupold",
    }
    self.nqr.all_big_snoptics = {
        "wpn_fps_upg_o_box",
        "wpn_fps_upg_o_schmidt",
		"wpn_fps_upg_o_leupold",
    }
    self.nqr.all_reddots = {
        "wpn_fps_upg_o_docter",
        "wpn_fps_upg_o_t1micro",
        "wpn_fps_upg_o_reflex",
        "wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_fc1",
        "wpn_fps_upg_o_uh",

        "wpn_fps_upg_o_aimpoint",
        "wpn_fps_upg_o_aimpoint_2",
        "wpn_fps_upg_o_eotech",
        "wpn_fps_upg_o_eotech_xps",
        "wpn_fps_upg_o_rx30",
        "wpn_fps_upg_o_rx01",
        "wpn_fps_upg_o_tf90",
        "wpn_fps_upg_o_cs",
        "wpn_fps_upg_o_uh",
        "wpn_fps_pis_c96_sight",
    }
    self.nqr.all_light_reddots = {
        "wpn_fps_upg_o_docter",
        "wpn_fps_upg_o_t1micro",
        "wpn_fps_upg_o_reflex",
        "wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_fc1",
        "wpn_fps_upg_o_uh",

        "wpn_fps_upg_o_northtac_reddot",
        "wpn_fps_upg_o_atibal_reddot",
    }
    self.nqr.all_big_reddots = {
        "wpn_fps_upg_o_aimpoint",
        "wpn_fps_upg_o_aimpoint_2",
        "wpn_fps_upg_o_eotech",
        "wpn_fps_upg_o_rx30",
        "wpn_fps_upg_o_rx01",
        --"wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_tf90",
        "wpn_fps_upg_o_cs",
        "wpn_fps_upg_o_uh",
        "wpn_fps_pis_c96_sight",
    }
    self.nqr.all_angled_sights = {
        "wpn_fps_upg_o_45iron",
        "wpn_fps_upg_o_45steel",
        "wpn_fps_upg_o_45rds",
        "wpn_fps_upg_o_45rds_v2",
    }
    self.nqr.all_magnifiers = {
        "wpn_fps_upg_o_xpsg33_magnifier",
        "wpn_fps_upg_o_sig",
    }
    self.nqr.all_piggyback_sights = {
        "wpn_fps_upg_o_northtac_reddot",
        "wpn_fps_upg_o_atibal_reddot",
    }
    self.nqr.all_second_sights = table.combine(self.nqr.all_angled_sights, self.nqr.all_magnifiers, self.nqr.all_piggyback_sights)

    self.nqr.i_f_base = table.with(self.nqr.all_big_snoptics, self.nqr.all_magnifiers)
    self.nqr.i_f_lpvo = {"wpn_fps_upg_o_shortdot", "wpn_fps_upg_o_northtac"}
    self.nqr.i_f_spot = {"wpn_fps_upg_o_spot"}
    self.nqr.i_f_c96 = {"wpn_fps_pis_c96_sight"}
    self.nqr.i_f_acog = {"wpn_fps_upg_o_acog", "wpn_fps_upg_o_bmg", "wpn_fps_upg_o_poe"}
    self.nqr.i_f_base_lpvo = table.with(self.nqr.i_f_base, self.nqr.i_f_lpvo)
    self.nqr.all_pistol_reddots = {
        "wpn_fps_upg_o_rmr",
        "wpn_fps_upg_o_rms",
        "wpn_fps_upg_o_rikt",
    }
    self.nqr.all_sights_no_optics = table.without(self.nqr.all_sights, self.nqr.all_optics)
    self.nqr.all_sights_no_snoptics = table.without(self.nqr.all_sights, self.nqr.all_snoptics)
    --[[for i, k in pairs(self.nqr.all_big_reddots) do
        self.parts[k].override = {
            wpn_fps_lmg_hcar_sight = { unit = fantom_unit },
            wpn_fps_upg_o_mbus_pro_rear = { unit = fantom_unit },
            wpn_fps_upg_o_mbus_rear = { unit = fantom_unit },
            wpn_fps_upg_o_dd_rear = { unit = fantom_unit },
        }
    end]]

    self.nqr.all_mds1 = {
        "wpn_fps_ass_komodo_ns",
        "wpn_fps_smg_hajk_ns_standard",
        "wpn_fps_ass_corgi_ns_standard",
        "wpn_fps_smg_vityaz_ns_standard",
        "wpn_fps_ass_tecci_ns_standard",
        "wpn_fps_ass_tecci_ns_special",
        "wpn_fps_smg_coal_ns_standard",
        "wpn_fps_snp_victor_ns_standard",
        "wpn_fps_snp_victor_ns_hera_muzzle",
        "wpn_fps_upg_pis_ns_flash",
        "wpn_fps_ass_vhs_ns_vhs",
        "wpn_fps_upg_ak_ns_ak105",
        "wpn_fps_upg_ak_ns_jmac",
        "wpn_fps_lmg_hk51b_ns_jcomp",
        "wpn_fps_lmg_kacchainsaw_ns_muzzle",
        "wpn_fps_upg_ass_ns_surefire",
        "wpn_fps_snp_tti_ns_standard",
        "wpn_fps_upg_ass_ns_jprifles",
        "wpn_fps_lmg_m60_ns_standard",
        "wpn_fps_ass_scar_ns_standard",
        "wpn_fps_ass_l85a2_ns_standard",
        --"wpn_fps_pis_czech_ns_standard",
        --"wpn_fps_smg_pm9_b_standard",
        --"wpn_fps_snp_siltstone_ns_variation_a",
        --"wpn_fps_snp_siltstone_ns_variation_b",
    }
    self.nqr.all_mds0 = {
        "wpn_fps_upg_ass_ns_battle",
        "wpn_fps_upg_ns_pis_typhoon",
        "wpn_fps_snp_desertfox_ns_comp",
        "wpn_fps_upg_ak_ns_zenitco",
        "wpn_fps_upg_ns_ass_smg_firepig",
        "wpn_fps_upg_ns_ass_smg_stubby",
        "wpn_fps_upg_ass_ns_linear",
        --"wpn_fps_pis_sparrow_b_comp",

        "wpn_fps_snp_awp_ns_muzzle",

        "wpn_fps_sho_sko12_ns_default",
        "wpn_fps_sho_sko12_ns_stiletto",
        "wpn_fps_upg_ns_shot_shark",
        "wpn_fps_upg_shot_ns_king",
        "wpn_fps_upg_ns_duck",
        "wpn_fps_upg_ns_ass_smg_v6",
    }
    self.nqr.all_mds2 = {
        "wpn_fps_upg_ns_ass_smg_tank",

        "wpn_fps_sho_ultima_ns_comp",
    }
    self.nqr.all_mds = table.combine(self.nqr.all_mds1, self.nqr.all_mds0, self.nqr.all_mds2)
    table.addto(self.nqr.all_mds1, self.nqr.all_mds0)
    table.addto(self.nqr.all_mds2, self.nqr.all_mds0)

    self.nqr.all_sps1 = {
        "wpn_fps_upg_ns_pis_small",
        "wpn_fps_smg_baka_b_smallsupp",
        "wpn_fps_upg_ns_pis_medium",
        "wpn_fps_upg_ns_ass_smg_small",
        "wpn_fps_upg_ns_pis_medium_gem",
        "wpn_fps_upg_ns_pis_medium_slim",
        "wpn_fps_lmg_kacchainsaw_ns_suppressor",
        "wpn_fps_ass_sub2000_ns_supp",
        "wpn_fps_upg_ns_pis_large_kac",
        "wpn_fps_upg_ns_ass_smg_medium",
        --"wpn_fps_smg_schakal_ns_silencer", --todo
        "wpn_fps_ass_vhs_b_silenced",
        "wpn_fps_upg_ns_pis_jungle",
        "wpn_fps_upg_ns_pis_large",
    }
    self.nqr.all_sps2 = {
        "wpn_fps_snp_victor_ns_hera_supp",
        "wpn_fps_upg_ak_ns_tgp",
        "wpn_fps_smg_uzi_b_suppressed",
        "wpn_fps_lmg_hcar_suppressor",
        "wpn_fps_smg_mp7_b_suppressed",
        "wpn_fps_smg_cobray_ns_silencer",
        "wpn_fps_ass_famas_b_suppressed",
        --"wpn_fps_smg_schakal_ns_silencer",
        --"wpn_fps_snp_tti_ns_hex",
    }
    self.nqr.all_sps0 = {
        "wpn_fps_upg_ns_ass_filter",
        "wpn_fps_snp_model70_ns_suppressor",
    }
    self.nqr.all_sps3 = {
        "wpn_fps_upg_ns_pis_putnik",
        "wpn_fps_smg_baka_b_midsupp",
        "wpn_fps_snp_desertfox_b_silencer",
        "wpn_fps_snp_victor_ns_omega",
        "wpn_fps_smg_polymer_ns_silencer",
        "wpn_fps_upg_ns_ass_smg_large",
        "wpn_fps_upg_ns_ass_pbs1",
        "wpn_fps_m4_upg_ns_mk12",
        "wpn_fps_snp_awp_ns_suppressor",
        "wpn_fps_snp_contender_suppressor",
    }
    self.nqr.all_sps4 = {
        "wpn_fps_smg_baka_b_longsupp",
        "wpn_fps_snp_msr_ns_suppressor",
        "wpn_fps_upg_ns_shot_thick",
        "wpn_fps_upg_ns_sho_salvo_small",
        "wpn_fps_upg_ns_sho_salvo_large",
    }
    self.nqr.all_sps = table.combine(self.nqr.all_sps1, self.nqr.all_sps2, self.nqr.all_sps0, self.nqr.all_sps3, self.nqr.all_sps4)

    self.nqr.all_bxs = table.combine(self.nqr.all_mds, self.nqr.all_sps)
    self.nqr.all_bxs_sbp = table.combine(self.nqr.all_mds1, self.nqr.all_sps1)
    self.nqr.all_bxs_mbp = table.combine(self.nqr.all_mds1, self.nqr.all_sps1, self.nqr.all_sps2, self.nqr.all_sps3)
    self.nqr.all_bxs_bbp = table.combine(self.nqr.all_mds2, self.nqr.all_sps3)
    table.delete(self.nqr.all_bxs_bbp, "wpn_fps_sho_ultima_ns_comp")
    self.nqr.all_bxs_sbr = table.combine(self.nqr.all_mds, self.nqr.all_sps)
    self.nqr.all_bxs_bbr = table.combine(self.nqr.all_mds2, self.nqr.all_sps3, self.nqr.all_sps4)
    for i, k in pairs(self.nqr.all_bxs) do if self.parts[k] then self.parts[k].parent = "barrel" end end
    self.nqr.all_bxs_magext = table.without(self.nqr.all_bxs_bbr, self.nqr.all_mds)

    for i, k in pairs(self) do
        if k.uses_parts then
            if table.contains(k.uses_parts, "wpn_fps_upg_ns_pis_small") then table.deletefrom(k.uses_parts, self.nqr.all_bxs) table.addto(k.uses_parts, self.nqr.all_bxs_sbp)
            elseif table.contains(k.uses_parts, "wpn_fps_upg_ns_ass_smg_small") then table.deletefrom(k.uses_parts, self.nqr.all_bxs) table.addto(k.uses_parts, self.nqr.all_bxs_sbr)
            elseif table.contains(k.uses_parts, "wpn_fps_upg_ns_shot_thick") then table.deletefrom(k.uses_parts, self.nqr.all_bxs) table.addto(k.uses_parts, self.nqr.all_bxs_bbr)
            end

            if table.contains(k.uses_parts, "wpn_fps_upg_o_bmg") and not table.contains(k.uses_parts, "wpn_fps_upg_o_leupold") then
                table.delete(k.uses_parts, "wpn_fps_upg_o_bmg")
            end
        end
    end

    self.nqr.all_gadgets = {
        "wpn_fps_upg_fl_pis_laser",
        "wpn_fps_upg_fl_pis_tlr1",
        "wpn_fps_upg_fl_pis_perst",
        "wpn_fps_upg_fl_pis_crimson",
        "wpn_fps_upg_fl_pis_x400v",
        "wpn_fps_upg_fl_pis_m3x",

        "wpn_fps_upg_fl_ass_smg_sho_peqbox",
        "wpn_fps_upg_fl_ass_smg_sho_surefire",
        "wpn_fps_upg_fl_ass_peq15",
        "wpn_fps_upg_fl_ass_laser",
        "wpn_fps_upg_fl_dbal_laser",
        "wpn_fps_upg_fl_ass_utg",
    }
    self.nqr.all_pistol_gadgets = {
        "wpn_fps_upg_fl_pis_laser",
        "wpn_fps_upg_fl_pis_tlr1",
        "wpn_fps_upg_fl_pis_perst",
        "wpn_fps_upg_fl_pis_crimson",
        "wpn_fps_upg_fl_pis_x400v",
        "wpn_fps_upg_fl_pis_m3x",
    }
    self.nqr.all_rifle_gadgets = {
        "wpn_fps_upg_fl_ass_smg_sho_peqbox",
        "wpn_fps_upg_fl_ass_smg_sho_surefire",
        "wpn_fps_upg_fl_ass_peq15",
        "wpn_fps_upg_fl_ass_laser",
        "wpn_fps_upg_fl_dbal_laser",
        "wpn_fps_upg_fl_ass_utg",
    }

    self.nqr.all_gadgetrails = {
        "wpn_fps_addon_ris",
        "wpn_fps_snp_r700_fl_rail",
        "wpn_fps_pis_beretta_body_rail",
        "wpn_fps_pis_sparrow_fl_rail",
        "wpn_fps_pis_judge_fl_adapter",
    }
    --[[self.nqr.all_sightrails = {
        "wpn_fps_ak_extra_ris",
        "wpn_fps_smg_vityaz_body_standard",
        "wpn_fps_upg_o_ak_scopemount",
        "wpn_fps_smg_coal_o_scopemount_standard",
        "wpn_fps_upg_ak_body_upperreceiver_zenitco",
        "wpn_fps_shot_r870_ris_special",
        "wpn_fps_shot_r870_s_nostock_single",
        "wpn_fps_shot_shorty_s_nostock_short",
        "wpn_fps_shot_r870_s_nostock_big",
    }]]
    self.nqr.all_sightmounts = {
        "wpn_fps_upg_o_ak_scopemount",
        "wpn_fps_smg_coal_o_scopemount_standard",
        --"wpn_fps_upg_ak_body_upperreceiver_zenitco",
        "wpn_fps_upg_o_m14_scopemount",
    }
    self.nqr.all_sightshifters = {
        --"wpn_fps_upg_o_ak_scopemount",
        --"wpn_fps_smg_coal_o_scopemount_standard",
        --"wpn_fps_upg_ak_body_upperreceiver_zenitco",
        --"wpn_fps_upg_o_m14_scopemount",
        "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_o_pos_zenitco",
        "wpn_fps_o_pos_a_o_sm",
        "wpn_fps_o_pos_fg",
    }
    self.nqr.all_railed_attachments = {
        "wpn_fps_upg_o_specter",
        "wpn_fps_upg_o_aimpoint",
        "wpn_fps_upg_o_docter",
        "wpn_fps_upg_o_eotech",
        "wpn_fps_upg_o_t1micro",
        "wpn_fps_upg_o_rx30",
        "wpn_fps_upg_o_rx01",
        "wpn_fps_upg_o_reflex",
        "wpn_fps_upg_o_eotech_xps",
        "wpn_fps_upg_o_cmore",
        "wpn_fps_upg_o_aimpoint_2",
        "wpn_fps_upg_o_acog",
        "wpn_fps_upg_o_cs",
        "wpn_fps_upg_o_spot",
        "wpn_fps_upg_o_bmg",
        "wpn_fps_upg_o_uh",
        "wpn_fps_upg_o_fc1",
        "wpn_fps_upg_o_tf90",
        "wpn_fps_upg_o_poe",
        "wpn_fps_upg_o_hamr",
        "wpn_fps_upg_o_atibal",
        "wpn_fps_upg_o_xpsg33_magnifier",
        "wpn_fps_upg_o_sig",
        "wpn_fps_upg_o_45iron",
        "wpn_fps_upg_o_45steel",
        "wpn_fps_upg_o_45rds",
        "wpn_fps_upg_o_45rds_v2",

        "wpn_fps_upg_fl_pis_laser",
        "wpn_fps_upg_fl_pis_tlr1",
        "wpn_fps_upg_fl_pis_perst",
        "wpn_fps_upg_fl_pis_crimson",
        "wpn_fps_upg_fl_pis_x400v",
        "wpn_fps_upg_fl_pis_m3x",

        "wpn_fps_upg_fl_ass_smg_sho_peqbox",
        "wpn_fps_upg_fl_ass_smg_sho_surefire",
        "wpn_fps_upg_fl_ass_peq15",
        "wpn_fps_upg_fl_ass_laser",
        "wpn_fps_upg_fl_dbal_laser",
        "wpn_fps_upg_fl_ass_utg",
    }
    self.nqr.all_vertical_grips = {
        "wpn_fps_smg_hajk_vg_moe",
        "wpn_fps_smg_schakal_vg_surefire",
        "wpn_fps_upg_vg_ass_smg_verticalgrip",
        "wpn_fps_upg_vg_ass_smg_stubby",
        "wpn_fps_upg_vg_ass_smg_afg",
        "wpn_fps_snp_tti_vg_standard",
        "wpn_fps_ass_tecci_vg_standard",
        "wpn_fps_smg_polymer_fg_standard",

        --"wpn_fps_snp_victor_vg_hera",
    }
    self.nqr.all_weps_with_vertical_grips = {
        "wpn_fps_ass_m4",
        "wpn_fps_ass_m16",
        "wpn_fps_smg_olympic",
        "wpn_fps_ass_tecci",
        "wpn_fps_ass_scar",
        "wpn_fps_snp_tti",
        "wpn_fps_snp_victor",
        "wpn_fps_ass_akm",
        "wpn_fps_ass_74",
        "wpn_fps_lmg_rpk",
        "wpn_fps_smg_akmsu",
        "wpn_fps_ass_aug",
        "wpn_fps_ass_s552",
        "wpn_fps_ass_corgi",
        "wpn_fps_smg_hajk",
        "wpn_fps_ass_g36",
        "wpn_fps_ass_ak5",
        "wpn_fps_ass_m14",
        "wpn_fps_smg_mp5",
        "wpn_fps_smg_schakal",
        "wpn_fps_shot_serbu",
        "wpn_fps_shot_r870",
        "wpn_fps_shot_saiga",
        "wpn_fps_sho_rota",
        "wpn_fps_smg_polymer",
        "wpn_fps_smg_mp7",
        "wpn_fps_smg_uzi",
        "wpn_fps_smg_mp9",
        "wpn_fps_gre_slap",
        --no afgs
        "wpn_fps_smg_mac10",
        "wpn_fps_smg_pm9",
        "wpn_fps_smg_scorpion",
        "wpn_fps_smg_baka",
        --[[ --todo
        "wpn_fps_ass_shak12",
        "wpn_fps_sho_aa12",
        "wpn_fps_snp_sbl",
        "wpn_fps_ass_amcar",
        "wpn_fps_sho_sko12",
        "wpn_fps_ass_flint",
        "wpn_fps_smg_vityaz",
        "wpn_fps_smg_shepheard",
        "wpn_fps_ass_asval",
        "wpn_fps_ass_famas",
        "wpn_fps_ass_komodo",
        "wpn_fps_ass_fal",
        "wpn_fps_ass_g3",
        "wpn_fps_ass_galil",
        "wpn_fps_ass_vhs",
        "wpn_fps_ass_sub2000",
        "wpn_fps_snp_msr",
        "wpn_fps_snp_desertfox",
        "wpn_fps_snp_siltstone",
        "wpn_fps_lmg_hcar",
        "wpn_fps_sho_basset",
        "wpn_fps_sho_ultima",
        "wpn_fps_sho_ksg",
        "wpn_fps_sho_spas12",
        "wpn_fps_shot_m37",
        "wpn_fps_shot_m1897",
        "wpn_fps_sho_m590",]]
    }
    for i, k in pairs(self.nqr.all_weps_with_vertical_grips) do table.addto(self[k].uses_parts, self.nqr.all_vertical_grips) end

    self.nqr.all_gadgets_and_vertical_grips = {
        "wpn_fps_upg_fl_pis_laser",
        "wpn_fps_upg_fl_pis_tlr1",
        "wpn_fps_upg_fl_pis_perst",
        "wpn_fps_upg_fl_pis_crimson",
        "wpn_fps_upg_fl_pis_x400v",
        "wpn_fps_upg_fl_pis_m3x",

        "wpn_fps_upg_fl_ass_smg_sho_peqbox",
        "wpn_fps_upg_fl_ass_smg_sho_surefire",
        "wpn_fps_upg_fl_ass_peq15",
        "wpn_fps_upg_fl_ass_laser",
        "wpn_fps_upg_fl_dbal_laser",
        "wpn_fps_upg_fl_ass_utg",

        "wpn_fps_smg_hajk_vg_moe",
        "wpn_fps_smg_schakal_vg_surefire",
        "wpn_fps_upg_vg_ass_smg_verticalgrip",
        "wpn_fps_upg_vg_ass_smg_stubby",
        "wpn_fps_upg_vg_ass_smg_afg",
        "wpn_fps_snp_tti_vg_standard",
        "wpn_fps_ass_tecci_vg_standard",
        "wpn_fps_smg_polymer_fg_standard",
    }
    local ironsights_pistol = {
        "wpn_fps_pis_beretta_o_std",
        "wpn_fps_pis_1911_o_long",
        "wpn_fps_pis_1911_o_standard",
        "wpn_fps_pis_packrat_o_expert",
        "wpn_fps_pis_packrat_o_standard",
    }
    local ironsights_low = {
        "wpn_fps_ass_flint_o_standard",
        "wpn_fps_smg_mp7_body_ironsights",
    }
    local ironsights_high = {
        "wpn_fps_smg_hajk_o_standard",
        "wpn_fps_m4_uupg_o_flipup",
        "wpn_fps_ass_tecci_o_standard",
        "wpn_fps_ass_contraband_o_standard",
        "wpn_fps_ass_vhs_o_standard",
        "wpn_fps_snp_qbu88_o_standard",
        "wpn_fps_lmg_hcar_sight",
        "wpn_fps_upg_o_mbus_pro_front",
        "wpn_fps_upg_o_mbus_pro_rear",
        "wpn_fps_sho_rota_o_standard",
        "wpn_fps_sho_basset_o_standard",
        "wpn_fps_sho_basset_o_short",
        "wpn_fps_smg_shepheard_o_standard",
        --"wpn_fps_smg_shepheard_o_short", --no attachment
        "wpn_fps_smg_polymer_o_iron",
        "wpn_fps_gre_arbiter_o_standard",
        "wpn_fps_snp_awp_o_irons",
        "wpn_fps_upg_o_mbus_front",
        "wpn_fps_upg_o_mbus_rear",
        "wpn_fps_upg_o_dd_front",
        "wpn_fps_upg_o_dd_rear",
        "wpn_fps_smg_polymer_o_iron",
        --"wpn_fps_ass_sub2000_o_front",
        --"wpn_fps_ass_sub2000_o_back",

        --"wpn_fps_ass_m16_os_frontsight", --a_os
        --"wpn_fps_ass_m16_o_handle_sight",
        --"wpn_fps_ass_l85a2_o_standard",
    }
    local ironsights_foldable = {
        "wpn_fps_snp_victor_o_standard",
        "wpn_fps_snp_victor_o_down",
        "wpn_fps_ass_scar_o_flipups_up",
        "wpn_fps_ass_scar_o_flipups_down",
    }
    local ironsights_foldable_unique = {
        "wpn_fps_ass_s552_o_flipup",
        "wpn_fps_ass_komodo_o_flipups_up",
        "wpn_fps_ass_komodo_o_flipups_down",
        "wpn_fps_snp_scout_o_iron_up",
        "wpn_fps_snp_scout_o_iron_down",
    }
    local ironsights = {
        "wpn_fps_remove_ironsight",
    }
    table.addto(ironsights, ironsights_low)
    table.addto(ironsights, ironsights_high)
    table.addto(ironsights, ironsights_foldable)
    table.addto(ironsights, ironsights_foldable_unique)
    local ironsights_railable = {
        "wpn_fps_smg_hajk_o_standard",
        "wpn_fps_m4_uupg_o_flipup",
        "wpn_fps_ass_tecci_o_standard",
        "wpn_fps_ass_contraband_o_standard",
        "wpn_fps_ass_vhs_o_standard",
        "wpn_fps_lmg_hcar_sight",
        "wpn_fps_upg_o_mbus_pro_front",
        "wpn_fps_upg_o_mbus_pro_rear",
        "wpn_fps_sho_rota_o_standard",
        "wpn_fps_sho_basset_o_standard",
        "wpn_fps_sho_basset_o_short",
        "wpn_fps_smg_shepheard_o_standard",
        --"wpn_fps_smg_shepheard_o_short", --no attachment
        "wpn_fps_smg_polymer_o_iron",
        "wpn_fps_gre_arbiter_o_standard",
        "wpn_fps_snp_awp_o_irons",
        "wpn_fps_upg_o_mbus_front",
        "wpn_fps_upg_o_mbus_rear",
        "wpn_fps_upg_o_dd_front",
        "wpn_fps_upg_o_dd_rear",
        "wpn_fps_smg_polymer_o_iron",

        "wpn_fps_snp_victor_o_standard",
        "wpn_fps_snp_victor_o_down",
    }
    for i, k in pairs(ironsights_low) do
        if self.parts[k] then
            --self.parts[k].pcs = {}
            self.parts[k].type = "ironsight"
            self.parts[k].sub_type = "ironsight"
            self.parts[k].forbids = {}
        end
    end
    for i, k in pairs(ironsights_high) do
        self.parts[k].pcs = {}
        self.parts[k].type = "ironsight"
        self.parts[k].sub_type = "ironsight"
        self.parts[k].forbids = {}
        --[[self.parts[k].forbids = {
            --"wpn_fps_gadgets_pos_a_fl_2",

            "wpn_fps_upg_o_spot",
            "wpn_fps_upg_o_poe",
            "wpn_fps_upg_o_hamr",
            "wpn_fps_upg_o_acog",
            "wpn_fps_upg_o_bmg",
            "wpn_fps_upg_o_specter",
            "wpn_fps_upg_o_atibal",
        }]]
    end
    for i, k in pairs(ironsights_foldable) do
        --self.parts[k].pcs = {}
        self.parts[k].type = "ironsight"
        self.parts[k].sub_type = "ironsight"
        self.parts[k].forbids = {}
    end
    for i, k in pairs(ironsights_foldable_unique) do
        self.parts[k].type = "ironsight"
        self.parts[k].sub_type = "ironsight"
        self.parts[k].forbids = {}
    end

    self.parts.wpn_fps_o_blank = {
        --unit = fantom_unit,
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        pcs = {},
        unit = self.parts.wpn_fps_upg_o_docter.unit,
	    a_obj = "a_o",
	    type = "sight",
        blank_sight = true,
	    name_id = "bm_wp_remove_o",
        adds = {}, forbids = {}, stats = {},
        override = {},
        visibility = { { objects = { g_reddot = false, g_docter = false, g_gfx_lens = false, g_mullplan = false } } },
    }
--



--LOCKS
    self.parts.wpn_fps_mngr_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_fg",
	    type = "mngr",
	    name_id = "bm_wp_mngr",
        adds = { "wpn_fps_extra_lock_sights" },
        override = {}, stats = {}, forbids = {},
    }

    self.parts.wpn_fps_fg_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_fg",
	    type = "foregrip_lock",
	    name_id = "bm_wp_fg_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }

    self.parts.wpn_fps_upper_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "upper_reciever_lock",
	    name_id = "bm_wp_upper_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }

    self.parts.wpn_fps_extra_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra_lock",
	    name_id = "bm_wp_extra_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }

    self.parts.wpn_fps_extra_lock_sights_boot = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra",
	    name_id = "bm_wp_extra_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }
    table.addto(self.parts.wpn_fps_extra_lock_sights_boot.forbids, self.nqr.all_pistol_reddots)
    table.insert(self.parts.wpn_fps_extra_lock_sights_boot.forbids, "wpn_fps_ak_extra_ris")

    self.parts.wpn_fps_extra_lock_optics = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra",
	    name_id = "bm_wp_extra_lock_optics",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_optics),
    } table.addto(self.parts.wpn_fps_extra_lock_optics.forbids, self.nqr.all_magnifiers)

    self.parts.wpn_fps_extra_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra_lock",
	    name_id = "bm_wp_extra_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets),
    }
    self.parts.wpn_fps_extra2_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra2_lock",
	    name_id = "bm_wp_extra2_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets),
    }
    self.parts.wpn_fps_extra3_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra3_lock",
	    name_id = "bm_wp_extra3_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets),
    }

    self.parts.wpn_fps_foregrip_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "foregrip_lock",
	    name_id = "bm_wp_foregrip_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets),
    }

    self.parts.wpn_fps_stock_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "stock_lock",
	    name_id = "bm_wp_stock_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets),
    }

    self.parts.wpn_fps_stock_lock_optics = {
        unit = fantom_unit,
	    a_obj = "a_s",
	    type = "stock_lock",
	    name_id = "bm_wp_stock_lock_optics",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_optics),
    }

    self.parts.wpn_fps_extra4_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra4_lock",
	    name_id = "bm_wp_extra4_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }

    self.parts.wpn_fps_extra4_lock_o_pos = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra4_lock",
	    name_id = "bm_wp_extra4_lock_o_pos",
        adds = {}, override = {}, stats = {},
        forbids = { "wpn_fps_o_pos_fg" },
    }
    self.parts.wpn_fps_fg_lock_extra4 = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "foregrip_lock2",
	    name_id = "bm_wp_fg_lock_extra4",
        adds = {}, override = {}, stats = {},
        forbids = { "wpn_fps_ak_extra_ris" },
    }

    self.parts.wpn_fps_upper_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "upper_reciever_lock",
	    name_id = "bm_wp_upper_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }

    self.parts.wpn_fps_foregrip_lock_vertical_grips = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "foregrip_lock",
	    name_id = "bm_wp_foregrip_lock_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_vertical_grips),
    }

    self.parts.wpn_fps_stock_lock_vertical_grips = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "stock_lock",
	    name_id = "bm_wp_stock_lock_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_vertical_grips),
    }

    self.parts.wpn_fps_extra_lock_vertical_grips = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra_lock",
	    name_id = "bm_wp_extra_lock_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_vertical_grips),
    }

    self.parts.wpn_fps_extra3_lock_vertical_grips = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra3_lock",
	    name_id = "bm_wp_extra3_lock_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_vertical_grips),
    }

    self.parts.wpn_fps_extra_lock_gadgets_and_vertical_grips = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra_lock",
	    name_id = "bm_wp_extra_lock_gadgets_and_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets_and_vertical_grips),
    }
    self.parts.wpn_fps_extra2_lock_gadgets_and_vertical_grips = {
        unit = fantom_unit,
        third_unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra2_lock",
	    name_id = "bm_wp_extra2_lock_gadgets_and_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets_and_vertical_grips),
    }
    self.parts.wpn_fps_extra3_lock_gadgets_and_vertical_grips = {
        unit = fantom_unit,
        third_unit = fantom_unit,
	    a_obj = "a_body",
	    type = "extra3_lock",
	    name_id = "bm_wp_extra3_lock_gadgets_and_vertical_grips",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_gadgets_and_vertical_grips),
    }

    self.parts.wpn_fps_vertical_grip_lock_gadgets = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "vertical_grip_lock",
	    name_id = "bm_wp_vertical_grip_lock_gadgets",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_pistol_gadgets),
    }

    self.parts.wpn_fps_gadgets_lock_vertical_grip = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "gadgets_lock",
	    name_id = "bm_wp_gadgets_lock_vertical_grip",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_vertical_grips),
    }

    self.parts.wpn_fps_gadgets_lock_secondsights = {
        unit = fantom_unit,
	    a_obj = "a_fl",
	    type = "gadgets_lock",
	    name_id = "bm_wp_gadgets_lock_secondsights",
        adds = {}, stats = {}, forbids = {},
        override = {},
    }
    for i, k in pairs(self.nqr.all_gadgets) do
        self.parts.wpn_fps_gadgets_lock_secondsights.override[k] = { forbids = deep_clone(self.parts[k].forbids) }
        table.addto(self.parts.wpn_fps_gadgets_lock_secondsights.override[k].forbids, self.nqr.all_second_sights)
    end

    self.parts.wpn_fps_fg_lock_upper_zenitco = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "foregrip_lock",
	    name_id = "bm_wp_fg_lock_upper_zenitco",
        adds = {}, override = {}, stats = {},
        forbids = { "wpn_fps_upg_ak_body_upperreceiver_zenitco" },
    }

    self.parts.wpn_fps_ironsight_lock_sights = {
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "ironsight_lock",
	    name_id = "bm_wp_ironsight_lock_sights",
        adds = {}, override = {}, stats = {},
        forbids = deep_clone(self.nqr.all_sights),
    }
--

--REMOVE'S
    self.parts.wpn_fps_remove_ironsight = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "ironsight",
	    name_id = "bm_wp_remove_ironsight",
        adds = {},
        forbids = {},
        override = {},
        stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_fold_ironsight = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "ironsight",
	    name_id = "bm_wp_fold_ironsight",
        adds = {},
        forbids = {},
        override = {},
        stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_remove_o = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "sight",
	    name_id = "bm_wp_remove_o",
        pcs = {},
        adds = {}, forbids = {}, override = {}, stats = {},
    }
    self.parts.wpn_fps_remove_fg = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_fg",
	    type = "foregrip",
	    name_id = "bm_wp_remove_fg",
        adds = {},
        forbids = { "wpn_fps_addon_ris", "wpn_nqr_extra3_rail" },
        override = {},
        stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_remove_vg = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_vg",
	    type = "vertical_grip",
	    name_id = "bm_wp_remove_vg",
        adds = {},
        forbids = {},
        override = {},
        stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_remove_s = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_s",
	    type = "stock",
	    name_id = "bm_wp_remove_s",
        pcs = {},
        adds = {}, forbids = {}, override = {}, stats = {},
    }
    self.parts.wpn_fps_remove_ns = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        pcs = {},
        unit = fantom_unit,
	    a_obj = "a_ns",
	    type = "barrel_ext",
	    name_id = "bm_wp_remove_ns",
        adds = {}, forbids = {}, override = {}, stats = {},
    }
    self.parts.wpn_fps_remove_s_addon = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_s",
	    type = "stock_addon",
	    name_id = "bm_wp_stock_remove_s_addon",
        pcs = {},
        adds = {}, forbids = {}, override = {}, stats = {},
    }
    self.parts.wpn_fps_remove_extra = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "extra",
	    name_id = "bm_wp_remove_extra",
        forbids = {}, override = {}, stats = {},
        pcs = {},
        adds = { "wpn_fps_extra_lock_sights" },
    }
    self.parts.wpn_fps_remove_extra2 = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "extra",
	    name_id = "bm_wp_remove_extra",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_ironsight_fantom_folded = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_o",
	    type = "ironsight",
	    name_id = "bm_wp_ironsight_folded",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_remove_bipod = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "bipod",
	    name_id = "bm_wp_remove_bipod",
        adds = {}, forbids = {}, override = {},
        stats = { concealment = 0, weight = 0 },
        pcs = {},
    }
    self.parts.wpn_fps_remove_cos = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "wep_cos",
	    name_id = "bm_wp_remove_cos",
        adds = {}, forbids = {}, override = {},
        stats = { concealment = 0, weight = 0 },
        pcs = {},
    }
    self.parts.wpn_fps_remove_gb = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "f_gasblock",
	    name_id = "bm_wp_remove_gb",
        adds = {}, override = {},
        forbids = {},
        stats = { concealment = 0, weight = 0 },
        pcs = {},
    }
    self.parts.wpn_fps_remove_upper = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "upper_reciever",
	    name_id = "bm_wp_remove_upper",
        adds = {}, forbids = {}, override = {},
        stats = { concealment = 0, weight = 0 },
        pcs = {},
    }
--

--POS'S
    self.parts.wpn_fps_sight_pos_default = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_default",
        adds = {}, forbids = {}, stats = {},
        override = {
            wpn_fps_upg_o_eotech = { override = overrides_remove_rear },
            wpn_fps_upg_o_aimpoint = { override = overrides_remove_rear },
            wpn_fps_upg_o_aimpoint_2 = { override = overrides_remove_rear },
            wpn_fps_upg_o_cmore = { override = overrides_remove_rear },
            wpn_fps_upg_o_cs = { override = overrides_remove_rear },
            wpn_fps_upg_o_rx30 = { override = overrides_remove_rear },
            wpn_fps_upg_o_rx01 = { override = overrides_remove_rear },
            wpn_fps_upg_o_tf90 = { override = overrides_remove_rear },
            wpn_fps_upg_o_uh = { override = overrides_remove_rear },
        }
    }

    self.parts.wpn_fps_sight_pos_a_o_f = {
        unit = fantom_unit,
	    a_obj = "a_o_f",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_a_o_f",
        adds = {}, stats = {},
        pcs = {},
        forbids = {
            "wpn_fps_gadgets_pos_a_fl_2",

            "wpn_fps_upg_o_xpsg33_magnifier",
            "wpn_fps_upg_o_sig",
        },
        override = {
            wpn_fps_upg_o_aimpoint = { a_obj = "a_o_f" },
            wpn_fps_upg_o_aimpoint_2 = { a_obj = "a_o_f" },
            wpn_fps_upg_o_docter = { a_obj = "a_o_f" },
            wpn_fps_upg_o_eotech = { a_obj = "a_o_f" },
            wpn_fps_upg_o_eotech_xps = { a_obj = "a_o_f" },
            wpn_fps_upg_o_t1micro = { a_obj = "a_o_f" },
            wpn_fps_upg_o_rx30 = { a_obj = "a_o_f" },
            wpn_fps_upg_o_rx01 = { a_obj = "a_o_f" },
            wpn_fps_upg_o_reflex = { a_obj = "a_o_f" },
            wpn_fps_upg_o_cmore = { a_obj = "a_o_f" },
            wpn_fps_upg_o_tf90 = { a_obj = "a_o_f" },
            wpn_fps_upg_o_cs = { a_obj = "a_o_f" },
            wpn_fps_upg_o_uh = { a_obj = "a_o_f" },
            wpn_fps_upg_o_fc1 = { a_obj = "a_o_f" },
        }
    }

    self.parts.wpn_fps_sight_pos_a_o_f_short = {
        unit = fantom_unit,
	    a_obj = "a_o_f",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_a_o_f_short",
        adds = {}, stats = {},
        pcs = {},
        forbids = {
            "wpn_fps_gadgets_pos_a_fl_2",

            "wpn_fps_upg_o_xpsg33_magnifier",
            "wpn_fps_upg_o_sig",
        },
        override = {
            wpn_fps_upg_o_aimpoint = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_aimpoint_2 = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_docter = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_eotech = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_eotech_xps = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_t1micro = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_rx30 = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_rx01 = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_reflex = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_cmore = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_tf90 = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_cs = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_uh = { a_obj = "a_o_f", override = overrides_remove_front },
            wpn_fps_upg_o_fc1 = { a_obj = "a_o_f", override = overrides_remove_front },
        }
    }

    self.parts.wpn_fps_sight_pos_a_o_f_2 = {
        unit = fantom_unit,
	    a_obj = "a_o_f_2",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_a_o_f_2",
        adds = {}, stats = {},
        pcs = {},
        forbids = {
            "wpn_fps_gadgets_pos_a_fl_2",

            "wpn_fps_upg_o_xpsg33_magnifier",
            "wpn_fps_upg_o_sig",
        },
        override = {
            wpn_fps_upg_o_aimpoint = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_aimpoint_2 = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_docter = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_eotech = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_eotech_xps = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_t1micro = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_rx30 = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_rx01 = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_reflex = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_cmore = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_tf90 = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_cs = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_uh = { a_obj = "a_o_f_2", override = overrides_remove_front },
            wpn_fps_upg_o_fc1 = { a_obj = "a_o_f_2", override = overrides_remove_front },
        }
    }

    self.parts.wpn_fps_sight_pos_a_of = {
        unit = fantom_unit,
	    a_obj = "a_of",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_a_of",
        adds = {}, stats = {},
        pcs = {},
        forbids = { "wpn_fps_gadgets_pos_a_fl_2", },
        override = {
            wpn_fps_extra_lock_sights = { forbids = {} },
        }
    } for i, k in pairs(self.nqr.all_reddots) do self.parts.wpn_fps_sight_pos_a_of.override[k] = { a_obj = "a_of", override = overrides_remove_front } end
    table.addto(self.parts.wpn_fps_sight_pos_a_of.forbids, self.nqr.all_optics)

    self.parts.wpn_fps_sight_pos_a_quite = {
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_sight_pos_a_of",
        adds = {}, forbids = {}, stats = {},
        pcs = {},
        override = {
            wpn_fps_upg_o_rms = { parent = false, a_obj = "a_os" },
            wpn_fps_upg_o_rikt = { parent = false, a_obj = "a_os" },
            wpn_fps_upg_o_rmr = { parent = false, a_obj = "a_os" },
        }
    }

    self.parts.wpn_fps_o_pos_fg = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_o_pos_fg",
	    has_description = true,
        pcs = {},
        adds = { "wpn_fps_fg_lock_sights" },
        forbids = deep_clone(self.nqr.all_optics),
        override = {
            --wpn_fps_extra_lock_sights = { forbids = {} },
            --wpn_fps_upg_ak_body_upperreceiver_zenitco = { override = {} },
            wpn_fps_upg_o_ak_scopemount = {
                --verride = table.without(self.parts.wpn_fps_upg_o_ak_scopemount.override, all_sights),
                --override = {},
                stats = table.copy_append(self.parts.wpn_fps_upg_o_ak_scopemount.stats, {sightheight = 0})
            },
            wpn_fps_smg_coal_o_scopemount_standard = {
                --override = table.without(self.parts.wpn_fps_smg_coal_o_scopemount_standard.override, all_sights),
                --override = {},
                stats = table.copy_append(self.parts.wpn_fps_smg_coal_o_scopemount_standard.stats, {sightheight = 0})
            },
            --wpn_fps_upg_ak_body_upperreceiver_zenitco = {
                --override = table.without(self.parts.wpn_fps_smg_coal_o_scopemount_standard.override, all_sights),
                --override = {},
                --stats = table.copy_append(self.parts.wpn_fps_upg_ak_body_upperreceiver_zenitco.stats, {sightheight = 0})
            --},
            --wpn_fps_upg_fg_midwest = { override = { wpn_fps_ak_extra_ris = { override = { wpn_fps_extra_lock_sights = { forbids = {} } } } } },
            --wpn_fps_upg_fg_midwest = { override = { wpn_fps_extra_lock_sights = { forbids = {} } } },
            --wpn_fps_o_blank = { override = {} },
            wpn_fps_o_blank = { a_obj = "a_of" },
        },
        stats = {},
    }

    self.parts.wpn_fps_o_pos_extra = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_o_pos_extra",
	    has_description = true,
        pcs = {},
        adds = { "wpn_fps_extra_lock_sights" },
        forbids = {},
        override = {},
        stats = {},
    }

    self.parts.wpn_fps_o_pos_a_o_sm = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_o_pos_a_o_sm",
        pcs = {},
        adds = { "wpn_fps_extra_lock_sights" },
        forbids = {},
        override = {
            --wpn_fps_o_blank = { override = {} },
            wpn_fps_o_blank = { a_obj = "a_o_sm" },
        },
        stats = {},
    }

    self.parts.wpn_fps_o_pos_zenitco = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_body",
	    type = "sight_a_pos",
	    name_id = "bm_wp_o_pos_upper",
        pcs = {},
        adds = { "wpn_fps_upper_lock_sights" },
        forbids = {},
        override = {
            --wpn_fps_extra_lock_sights = { forbids = {} },
            --wpn_fps_upg_ak_fg_zenitco = { override = { wpn_fps_extra_lock_sights = { forbids = {} } } },
            --wpn_fps_o_blank = { override = {} },
            wpn_fps_o_blank = { a_obj = "a_o_zenit", parent = "upper_reciever" },
            wpn_fps_upg_ak_body_upperreceiver_zenitco = { stats = table.copy_append(self.parts.wpn_fps_upg_ak_body_upperreceiver_zenitco.stats, { sightheight = 0.3 }) }
        },
        stats = {},
    }

    self.parts.wpn_fps_gadgets_pos_a_fl_2 = {
        unit = fantom_unit,
	    a_obj = "a_fl_2",
	    type = "gadget_pos",
	    name_id = "bm_wp_gadgets_pos_a_fl_2",
        adds = {}, stats = {},
        pcs = {},
        forbids = {
            "wpn_fps_sight_pos_a_o_f",
            "wpn_fps_sight_pos_a_o_f_short",
            "wpn_fps_sight_pos_a_o_f_2",
        },
        override = {
            wpn_fps_upg_fl_ass_smg_sho_peqbox = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_upg_fl_ass_smg_sho_surefire = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_upg_fl_ass_peq15 = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_upg_fl_ass_laser = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_upg_fl_dbal_laser = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_upg_fl_ass_utg = { a_obj = "a_fl_2", override = overrides_remove_front },
            wpn_fps_sho_ksg_body_standard = { adds = {} },
            wpn_fps_gadgets_lock_secondsights = { forbids = {} },
        }
    } --table.addto(self.parts.wpn_fps_gadgets_pos_a_fl_2.forbids, ironsights)

    self.parts.wpn_fps_gadgets_pos_a_fl2 = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_fl2",
	    type = "gadget_pos",
	    name_id = "bm_wp_gadgets_pos_a_fl2",
        adds = {}, forbids = {}, stats = {},
        pcs = {},
        override = {
            wpn_fps_upg_fl_ass_smg_sho_peqbox = { a_obj = "a_fl2" },
            wpn_fps_upg_fl_ass_smg_sho_surefire = { a_obj = "a_fl2" },
            wpn_fps_upg_fl_ass_peq15 = { a_obj = "a_fl2" },
            wpn_fps_upg_fl_ass_laser = { a_obj = "a_fl2" },
            wpn_fps_upg_fl_dbal_laser = { a_obj = "a_fl2" },
            wpn_fps_upg_fl_ass_utg = { a_obj = "a_fl2" },
            wpn_fps_addon_ris = { a_obj = "a_fl2" },
        },
    }

    self.parts.wpn_fps_gadgets_pos_a_fl3 = {
        is_a_unlockable = true,
        dlc = "nqr_dlc",
        unit = fantom_unit,
	    a_obj = "a_fl3",
	    type = "gadget_pos",
	    name_id = "bm_wp_gadgets_pos_a_fl3",
        adds = {}, stats = {},
        pcs = {},
        override = {
            wpn_fps_upg_fl_ass_smg_sho_peqbox = { a_obj = "a_fl3" },
            wpn_fps_upg_fl_ass_smg_sho_surefire = { a_obj = "a_fl3" },
            wpn_fps_upg_fl_ass_peq15 = { a_obj = "a_fl3" },
            wpn_fps_upg_fl_ass_laser = { a_obj = "a_fl3" },
            wpn_fps_upg_fl_dbal_laser = { a_obj = "a_fl3" },
            wpn_fps_upg_fl_ass_utg = { a_obj = "a_fl3" },
            wpn_fps_addon_ris = { a_obj = "a_fl3" },
        },
    }
--

--OVERRIDE_THINGS
    local overrides_pistol_reddots_thing = {}
    for i, k in pairs(self.nqr.all_pistol_reddots) do  overrides_pistol_reddots_thing[k] = { a_obj = "a_o" } end

    local overrides_pistol_ns_thing = {}
    for i, k in pairs(self.nqr.all_bxs_sbp) do  overrides_pistol_ns_thing[k] = { parent = "barrel" } end

    local overrides_ironsights_high_thing = {
        wpn_fps_smg_hajk_o_standard = { unit = fantom_unit },
        wpn_fps_m4_uupg_o_flipup = { unit = fantom_unit },
        wpn_fps_ass_tecci_o_standard = { unit = fantom_unit },
        wpn_fps_ass_contraband_o_standard = { unit = fantom_unit },
        wpn_fps_ass_vhs_o_standard = { unit = fantom_unit },
        wpn_fps_snp_qbu88_o_standard = { unit = fantom_unit },
        wpn_fps_lmg_hcar_sight = { unit = fantom_unit },
        wpn_fps_upg_o_mbus_pro_front = { unit = fantom_unit },
        wpn_fps_upg_o_mbus_pro_rear = { unit = fantom_unit },
        wpn_fps_sho_rota_o_standard = { unit = fantom_unit },
        wpn_fps_sho_basset_o_standard = { unit = fantom_unit },
        wpn_fps_sho_basset_o_short = { unit = fantom_unit },
        wpn_fps_smg_shepheard_o_standard = { unit = fantom_unit },
        wpn_fps_smg_shepheard_o_short = { unit = fantom_unit },
        wpn_fps_smg_polymer_o_iron = { unit = fantom_unit },
        wpn_fps_gre_arbiter_o_standard = { unit = fantom_unit },
        wpn_fps_snp_awp_o_irons = { unit = fantom_unit },
        wpn_fps_upg_o_mbus_front = { unit = fantom_unit },
        wpn_fps_upg_o_mbus_rear = { unit = fantom_unit },
        wpn_fps_upg_o_dd_front = { unit = fantom_unit },
        wpn_fps_upg_o_dd_rear = { unit = fantom_unit },
    }

    local overrides_ironsights_foldable_thing = {
        wpn_fps_snp_victor_o_standard = {
            unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down",
        },
        wpn_fps_ass_komodo_o_flipups_up = {
            unit = "units/pd2_dlc_tar/weapons/wpn_fps_ass_komodo_pts/wpn_fps_ass_komodo_o_flipups_down",
            third_unit = "units/pd2_dlc_tar/weapons/wpn_fps_ass_komodo_pts/wpn_third_ass_komodo_o_flipups_down",
        },
        wpn_fps_ass_scar_o_flipups_up = {
            unit = "units/pd2_dlc_dec5/weapons/wpn_fps_ass_scar_pts/wpn_fps_ass_scar_o_flipups_down",
            third_unit = "units/pd2_dlc_dec5/weapons/wpn_third_ass_scar_pts/wpn_third_ass_scar_o_flipups_down",
        },
        wpn_fps_snp_scout_o_iron_up = {
            unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_o_iron_down",
            third_unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_conversion_dummy",
        },
    }

    local overrides_all_sights_to_a_o_2 = {
        wpn_fps_ass_m16_o_handle_sight = { a_obj = "a_o_2", parent = "foregrip" },
        wpn_fps_o_blank = { a_obj = "a_o_2", parent = "foregrip" },
    }
    for i, k in pairs(self.nqr.all_sights) do overrides_all_sights_to_a_o_2[k] = { a_obj = "a_o_2", parent = "foregrip" } end
    for i, k in pairs(ironsights) do overrides_all_sights_to_a_o_2[k] = { a_obj = "a_o_2", parent = "foregrip" } end

    local overrides_remove_rear = {
        wpn_fps_upg_o_mbus_pro_rear = { unit = fantom_unit },
        wpn_fps_upg_o_mbus_rear = { unit = fantom_unit },
        wpn_fps_upg_o_dd_rear = { unit = fantom_unit }
    }

    local overrides_remove_front = {
        wpn_fps_upg_o_mbus_pro_front = {unit=fantom_unit },
        wpn_fps_upg_o_mbus_front = { unit=fantom_unit },
        wpn_fps_upg_o_dd_front = { unit=fantom_unit }
    }

    local overrides_beltfed_sights = {}
    for i, k in pairs(self.nqr.all_sights) do overrides_beltfed_sights[k] = { a_obj = "a_o_parented", parent = "upper_reciever" } end
    --for i, k in pairs(self.nqr.all_optics) do overrides_beltfed_sights[k] = { forbids = { "wpn_fps_lmg_m60_o_sight" } } end

    local overrides_vertical_grip_and_gadget_thing = {}
    for i, k in pairs(self.nqr.all_vertical_grips) do overrides_vertical_grip_and_gadget_thing[k] = { a_obj = "a_fl", adds = table.with(self.parts[k] and self.parts[k].adds or {}, "wpn_fps_vertical_grip_lock_gadgets") } end
    for i, k in pairs(self.nqr.all_gadgets) do overrides_vertical_grip_and_gadget_thing[k] = { adds = table.with(self.parts[k] and self.parts[k].adds or {}, "wpn_fps_gadgets_lock_vertical_grip") } end

    local overrides_pistol_gadgets_to_vertical_grips_thing = {}
    for i, k in pairs(self.nqr.all_vertical_grips) do overrides_pistol_gadgets_to_vertical_grips_thing[k] = { adds = table.with(self.parts[k] and self.parts[k].adds or {}, "wpn_fps_vertical_grip_lock_gadgets") } end
    for i, k in pairs(self.nqr.all_pistol_gadgets) do overrides_pistol_gadgets_to_vertical_grips_thing[k] = { a_obj = "a_vg", adds = table.with(self.parts[k] and self.parts[k].adds or {}, "wpn_fps_gadgets_lock_vertical_grip") } end

    local overrides_gadget_foregrip_parent_thing = {}
    for i, k in pairs(self.nqr.all_gadgets) do overrides_gadget_foregrip_parent_thing[k] = { parent = "foregrip" } end

    local overrides_sights_and_second_sights_thing = {}
    for i, k in pairs(table.with(self.nqr.all_angled_sights, self.nqr.all_magnifiers)) do overrides_sights_and_second_sights_thing[k] = { parent = "sight", a_obj = "a_magnifier" } end

    local overrides_no_space_for_second_sight_behind = {
        --[[wpn_fps_upg_o_aimpoint = { override = {} },
        wpn_fps_upg_o_aimpoint_2 = { override = {} },
        --wpn_fps_upg_o_docter = { override = {} },
        wpn_fps_upg_o_eotech = { override = {} },
        --wpn_fps_upg_o_eotech_xps = { override = {} },
       -- wpn_fps_upg_o_t1micro = { override = {} },
        wpn_fps_upg_o_rx30 = { override = {} },
        wpn_fps_upg_o_rx01 = { override = {} },
        --wpn_fps_upg_o_reflex = { override = {} },
        wpn_fps_upg_o_cmore = { override = {} },
        wpn_fps_upg_o_tf90 = { override = {} },
        wpn_fps_upg_o_cs = { override = {} },
        wpn_fps_upg_o_uh = { override = {} },
        --wpn_fps_upg_o_fc1 = { override = {} },
        --wpn_fps_pis_c96_sight = { override = {} },

        --wpn_fps_upg_o_spot = { override = {} },
        --wpn_fps_upg_o_poe = { override = {} },
        --wpn_fps_upg_o_hamr = { override = {} },
        wpn_fps_upg_o_acog = { override = {} },
        wpn_fps_upg_o_specter = { override = {} },
        --wpn_fps_upg_o_atibal = { override = {} },

        wpn_fps_upg_o_bmg = { override = {} },
        wpn_fps_upg_o_shortdot = { override = {} },
        wpn_fps_upg_o_leupold = { override = {} },
        wpn_fps_upg_o_box = { override = {} },
        wpn_fps_upg_o_northtac = { override = {} },
        wpn_fps_upg_o_schmidt = { override = {} },]]
    }

    local overrides_barrelexts_noparent_thing = {}
    for i, k in pairs(self.nqr.all_bxs) do overrides_barrelexts_noparent_thing[k] = { parent = false } end

    local overrides_barrelexts_noparent_fire_thing = {}

    for i, k in pairs(self.nqr.all_bxs) do overrides_barrelexts_noparent_fire_thing[k] = { parent = false, a_obj = "fire" } end

    local overrides_barrelexts_fire_thing = {}
    for i, k in pairs(self.nqr.all_bxs) do overrides_barrelexts_fire_thing[k] = { a_obj = "fire" } end

    local overrides_shotgun_sps_sound = {}
    for i, k in pairs(table.combine(self.nqr.all_sps3, self.nqr.all_sps4)) do
        overrides_shotgun_sps_sound[k] = { sound_switch = { suppressed = "suppressed_a" } }
    end
--



--
    local hcar_vec = Vector3(-4.925, -20, -2.4)
    self.parts.wpn_fps_lmg_hcar_sight.stance_mod = nil
    for i, k in pairs(self.parts) do
        if self.parts[i] and self.parts[i].stance_mod and self.parts[i].stance_mod.wpn_fps_lmg_hcar then
            self.parts[i].stance_mod.wpn_fps_lmg_hcar.translation = Vector3(0, 0, self.parts[i].stance_mod.wpn_fps_lmg_hcar.translation.z - hcar_vec.z) --  - 0.318
            self.parts[i].stance_mod.wpn_fps_lmg_hcar.rotation = nil
        end
    end

    self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_lmg_rpk = deep_clone(self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_akm)

    table.insert(self.wpn_fps_ass_shak12.default_blueprint, "wpn_fps_ass_shak12_o_carry_sight") --removed down there
    local dflt_default_blueprints = {}
    for i, k in pairs(self.parts.wpn_fps_upg_o_specter.stance_mod) do
        dflt_default_blueprints[i] = { default_blueprint = self[i] and self[i].default_blueprint and deep_clone(self[i].default_blueprint) or nil }
    end
    local height_dflt = 3.8
--



--DELET
    for i, k in pairs(self) do
        if k.uses_parts then
            table.delete(k.uses_parts, "wpn_fps_upg_m4_s_ubr")
            if i~="wpn_fps_ass_shak12" then
                table.delete(k.uses_parts, "wpn_fps_ass_shak12_ns_suppressor")
                table.delete(k.uses_parts, "wpn_fps_ass_shak12_ns_muzzle")
                table.delete(k.uses_parts, "wpn_fps_ass_shak12_ns_suppressor")
                table.delete(k.uses_parts, "wpn_fps_ass_shak12_ns_muzzle")
            end

            table.delete(k.uses_parts, "wpn_fps_upg_o_health")

            if table.contains(k.uses_parts, "wpn_fps_upg_o_45rds") and not table.contains(k.uses_parts, "wpn_fps_upg_o_45iron") then table.insert(k.uses_parts, "wpn_fps_upg_o_45iron") end
            if table.contains(k.uses_parts, "wpn_fps_upg_o_specter") and not table.contains(k.uses_parts, "wpn_fps_upg_o_leupold") then table.addto(k.uses_parts, self.nqr.all_snoptics) end
            if table.contains(k.uses_parts, "wpn_fps_upg_o_cs") and not table.contains(k.uses_parts, "wpn_fps_pis_c96_sight") then table.insert(k.uses_parts, "wpn_fps_pis_c96_sight") end

            for u, j in pairs(k.default_blueprint or {}) do
                if string.find(j, "_vanilla") then
                    local nonvanilla, _ = string.gsub(j, "_vanilla", "")
                    table.swap(k.default_blueprint, j, nonvanilla)
                    if not table.contains(k.uses_parts, nonvanilla) then table.insert(k.uses_parts, nonvanilla) end
                end
            end

        end
    end

    for i, k in pairs(self.parts) do
        table.delete(k.adds, "wpn_fps_addon_ris")

        if k.type=="bonus" then k.pcs = nil end
        --if string.find(i, "_m_quick") then k.pcs = nil end --todo
        if k.type=="exclusive_set" then k.pcs = nil end

        if k.type=="sight" and k.forbids then
            table.delete(k.forbids, "wpn_fps_ass_m16_os_frontsight")
            table.delete(k.forbids, "wpn_fps_amcar_uupg_body_upperreciever")
            table.delete(k.forbids, "wpn_fps_ass_scar_o_flipups_up")
            table.delete(k.forbids, "wpn_fps_ass_shak12_o_carry_dummy")
        end
        --if k.type=="second_sight" and k.override then k.override.wpn_fps_ass_m14_body_ruger = nil end
        if (k.type=="sight" or k.type=="second_sight") and k.override then k.override.wpn_fps_ass_m14_body_ruger = nil end
    end

    self.parts.wpn_fps_upg_i_singlefire.pcs = nil
    self.parts.wpn_fps_upg_i_autofire.pcs = nil
    self.parts.wpn_fps_ammo_type.pcs = nil
    self.parts.wpn_fps_m4_uupg_s_fold.pcs = nil

    for i, k in pairs(self) do
        if string.find(i, "korth")
        or string.find(i, "ppk")
        or string.find(i, "sparrow")
        or string.find(i, "lemming")
        or string.find(i, "legacy")
        or string.find(i, "stech")
        or string.find(i, "holt")
        or string.find(i, "packrat")
        or string.find(i, "rsh12")
        or string.find(i, "deagle") then
            table.delete(k.uses_parts, "wpn_fps_upg_ns_pis_meatgrinder")
            table.delete(k.uses_parts, "wpn_fps_upg_ns_pis_ipsccomp")
        end
    end
--



--UNIVERSAL
    self.parts.wpn_fps_addon_ris.texture_bundle_folder = "nqr_dlc"
    self.parts.wpn_fps_addon_ris.dlc = "nqr_dlc"
    self.parts.wpn_fps_addon_ris.pcs = {}
    self.parts.wpn_fps_addon_ris.name_id = "bm_wp_generic_gadgetrail"
    self.parts.wpn_fps_addon_ris.type = "extra2"
    self.parts.wpn_fps_addon_ris.override = {
        wpn_fps_extra2_lock_gadgets = { forbids = {} },
        wpn_fps_foregrip_lock_gadgets = { forbids = {} },
        wpn_fps_stock_lock_gadgets = { forbids = {} },
    }
    self.parts.wpn_fps_addon_ris.stats = { concealment = 1, weight = 1 }

    self.parts.wpn_nqr_extra3_rail = {
        texture_bundle_folder = "nqr_dlc",
        dlc = "nqr_dlc",
		a_obj = "a_vg",
		type = "extra3",
		name_id = "bm_wp_extra3_rail",
		unit = "units/pd2_dlc_sawp/weapons/wpn_fps_smg_pm9_pts/wpn_fps_smg_pm9_fl_adapter",
		--unit = "units/pd2_dlc_tawp/weapons/wpn_fps_pis_type54_pts/wpn_fps_pis_type54_fl_rail",
        pcs = {},
        adds = {},
        forbids = {},
        override = {
            wpn_fps_extra3_lock_vertical_grips = { forbids = {} },
            wpn_fps_foregrip_lock_vertical_grips = { forbids = {} },
            --wpn_fps_stock_lock_vertical_grips = { forbids = {} },
        },
        stats = { concealment = 2, weight = 1 },
	}
--



--AMMO
    self.parts.wpn_fps_upg_cal_9x19 = {
        unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
        third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
        a_obj = "a_body",
        pcs = {},
        name_id = "bm_wp_upg_cal_9x19",
        dlc = "nqr_dlc",
        type = "a_caliber",
        internal_part = true,
        stats = { caliber = "9x19" },
    }

    self.parts.wpn_fps_upg_cal_40sw = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_40sw.name_id = "bm_wp_upg_cal_40sw"
    self.parts.wpn_fps_upg_cal_40sw.stats = { caliber = ".40 S&W" }

    self.parts.wpn_fps_upg_cal_45acp = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_45acp.name_id = "bm_wp_upg_cal_45acp"
    self.parts.wpn_fps_upg_cal_45acp.stats = { caliber = ".45 ACP" }

    self.parts.wpn_fps_upg_cal_50beo = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_50beo.name_id = "bm_wp_upg_cal_50beo"
    self.parts.wpn_fps_upg_cal_50beo.forbids = {}
    table.addto(self.parts.wpn_fps_upg_cal_50beo.forbids, {"wpn_fps_upg_a_slug", "wpn_fps_upg_a_piercing", "wpn_fps_upg_a_dragons_breath", "wpn_fps_upg_a_subfmj"})
    self.parts.wpn_fps_upg_cal_50beo.stats = { caliber = ".50 Beo" }

    self.parts.wpn_fps_upg_cal_300blk = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_300blk.name_id = "bm_wp_upg_cal_300blk"
    self.parts.wpn_fps_upg_cal_300blk.stats = { caliber = ".300 BLK" }

    self.parts.wpn_fps_upg_cal_762x39 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_762x39.name_id = "bm_wp_upg_cal_762x39"
    self.parts.wpn_fps_upg_cal_762x39.stats = { caliber = "7.62x39" }

    self.parts.wpn_fps_upg_cal_545x39 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_545x39.name_id = "bm_wp_upg_cal_545x39"
    self.parts.wpn_fps_upg_cal_545x39.forbids = { "wpn_fps_upg_a_subfmj" }
    self.parts.wpn_fps_upg_cal_545x39.stats = { caliber = "5.45x39" }

    self.parts.wpn_fps_upg_cal_9x39 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_9x39.name_id = "bm_wp_upg_cal_9x39"
    self.parts.wpn_fps_upg_cal_9x39.stats = { caliber = "9x39" }

    self.parts.wpn_fps_upg_cal_44mag = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_44mag.name_id = "bm_wp_upg_cal_44mag"
    self.parts.wpn_fps_upg_cal_44mag.stats = { caliber = ".44 Mag" }

    self.parts.wpn_fps_upg_cal_357mag = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_357mag.name_id = "bm_wp_upg_cal_357mag"
    self.parts.wpn_fps_upg_cal_357mag.stats = { caliber = ".357 Mag" }

    self.parts.wpn_fps_upg_cal_454csl = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_454csl.name_id = "bm_wp_upg_cal_454csl"
    self.parts.wpn_fps_upg_cal_454csl.stats = { caliber = ".454 CSL" }

    self.parts.wpn_fps_upg_cal_410 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_410.name_id = "bm_wp_upg_cal_410"
    self.parts.wpn_fps_upg_cal_410.shell_eject = "effects/payday2/particles/weapons/shells/shell_slug"
    self.parts.wpn_fps_upg_cal_410.forbids = {}
    table.addto(self.parts.wpn_fps_upg_cal_410.forbids, {"wpn_fps_upg_a_subfmj"})
    self.parts.wpn_fps_upg_cal_410.stats = { caliber = ".410 bore" }

    self.parts.wpn_fps_upg_cal_12g = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_12g.name_id = "bm_wp_upg_cal_12g"
    self.parts.wpn_fps_upg_cal_12g.shell_eject = "effects/payday2/particles/weapons/shells/shell_slug"
    self.parts.wpn_fps_upg_cal_12g.stats = { caliber = "12 gauge" }

    self.parts.wpn_fps_upg_cal_556x45 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_556x45.name_id = "bm_wp_upg_cal_556x45"
    self.parts.wpn_fps_upg_cal_556x45.stats = { caliber = "5.56x45" }

    self.parts.wpn_fps_upg_cal_762x51 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_762x51.name_id = "bm_wp_upg_cal_762x51"
    self.parts.wpn_fps_upg_cal_762x51.stats = { caliber = "7.62x51" }

    self.parts.wpn_fps_upg_cal_338lm = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_cal_338lm.name_id = "bm_wp_upg_cal_338lm"
    self.parts.wpn_fps_upg_cal_338lm.stats = { caliber = ".338 LM" }

    self.parts.wpn_fps_upg_a_custom.pcs = nil
    self.parts.wpn_fps_upg_a_custom_free.custom_stats = nil
    self.parts.wpn_fps_upg_a_custom_free.stats = { ammotype = "000 Buck" }
    self.parts.wpn_fps_upg_a_slug.custom_stats = nil
    self.parts.wpn_fps_upg_a_slug.stats = { ammotype = "Slug" }
    self.parts.wpn_fps_upg_a_piercing.custom_stats = nil
    self.parts.wpn_fps_upg_a_piercing.stats = { ammotype = "Flechette" }
    self.parts.wpn_fps_upg_a_dragons_breath.pcs = nil
    --self.parts.wpn_fps_upg_a_dragons_breath.custom_stats = nil
    self.parts.wpn_fps_upg_a_dragons_breath.stats = { ammotype = "Dragon's Breath" }

    self.parts.wpn_fps_upg_a_subfmj = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_a_subfmj.name_id = "bm_wp_upg_a_subfmj"
    self.parts.wpn_fps_upg_a_subfmj.has_description = true
    self.parts.wpn_fps_upg_a_subfmj.type = "ammo"
    self.parts.wpn_fps_upg_a_subfmj.stats = { ammotype = "Sub FMJ" }

    self.nqr.all_shotgun_ammotypes = {
        "wpn_fps_upg_a_custom_free",
        "wpn_fps_upg_a_slug",
        "wpn_fps_upg_a_piercing",
        "wpn_fps_upg_a_dragons_breath",
    }
--



----MUZZLE DEVICES
    self.parts.wpn_fps_upg_ns_ass_smg_firepig.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,1,0,0,0} }
    self.parts.wpn_fps_upg_ns_ass_smg_tank.stats = { concealment = 4, weight = 2, length = 2, md_code = {0,0,0,3,0} }
    self.parts.wpn_fps_upg_ns_ass_smg_v6.stats = { concealment = 6, weight = 3, length = 4, md_code = {0,0,2,3,0} }
    self.parts.wpn_fps_upg_ass_ns_battle.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_upg_ass_ns_linear.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,1,0,1,0} }
    self.parts.wpn_fps_upg_ass_ns_surefire.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_upg_ass_ns_jprifles.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_upg_ns_ass_smg_stubby.stats = { concealment = 2, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_lmg_hk51b_ns_jcomp.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,1,0,2,0} }
    self.parts.wpn_fps_lmg_kacchainsaw_ns_muzzle.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,1,0,2,0} }

    self.parts.wpn_fps_upg_pis_ns_flash.a_obj = "a_ns"
    self.parts.wpn_fps_upg_pis_ns_flash.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_upg_ns_pis_typhoon.a_obj = "a_ns"
    self.parts.wpn_fps_upg_ns_pis_typhoon.stats = { concealment = 3, weight = 1, length = 2, md_code = {0,0,2,1,0} }
    self.parts.wpn_fps_upg_ns_pis_ipsccomp.dlc = "pd2_clan"
    self.parts.wpn_fps_upg_ns_pis_ipsccomp.parent = "barrel"
    self.parts.wpn_fps_upg_ns_pis_ipsccomp.stats = { concealment = 6, weight = 2, length = 2, md_code = {0,0,3,0,0} }
    self.parts.wpn_fps_upg_ns_pis_meatgrinder.dlc = "pd2_clan"
    self.parts.wpn_fps_upg_ns_pis_meatgrinder.parent = "barrel"
    self.parts.wpn_fps_upg_ns_pis_meatgrinder.stats = { concealment = 6, weight = 2, length = 2 }

    self.parts.wpn_fps_upg_ns_shot_shark.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,1,0,1,0} }
    self.parts.wpn_fps_upg_shot_ns_king.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,1,0,1,0} }
    self.parts.wpn_fps_upg_ns_duck.stats = { concealment = 2, weight = 1, length = 3, md_code = {0,0,0,1,0} }



----SILENCERS
    self.nqr.sps_stats = {
        giant = { concealment = 24, weight = 8, length = 11, md_code = {5,0,0,0,0} },
        thicc = { concealment = 10, weight = 4, length = 5, md_code = {3,0,0,0,0} },
        big = { concealment = 18, weight = 7, length = 9, md_code = {4,0,0,0,0} },
        medium2 = { concealment = 13, weight = 5, length = 8, md_code = {3,0,0,0,0} },
        medium = { concealment = 10, weight = 4, length = 7, md_code = {3,0,0,0,0} },
        small = { concealment = 8, weight = 3, length = 5, md_code = {2,0,0,0,0} },
    }

    self.parts.wpn_fps_upg_ns_ass_filter.stats = { concealment = 14, weight = 1, length = 5, md_code = {1,0,0,0,0} }
    self.parts.wpn_fps_upg_ns_ass_filter.sort_number = 190000
    self.parts.wpn_fps_upg_ns_pis_small.stats = { concealment = 5, weight = 2, length = 4, md_code = {1,0,0,0,0} }

    self.parts.wpn_fps_upg_ns_ass_smg_small.stats = deep_clone(self.nqr.sps_stats.small)
    self.parts.wpn_fps_upg_ns_pis_medium.stats = deep_clone(self.nqr.sps_stats.small)
    self.parts.wpn_fps_upg_ns_pis_medium_gem.stats = deep_clone(self.nqr.sps_stats.small)
    self.parts.wpn_fps_upg_ns_pis_medium_slim.stats = deep_clone(self.nqr.sps_stats.small)
    self.parts.wpn_fps_lmg_kacchainsaw_ns_suppressor.stats = deep_clone(self.nqr.sps_stats.small)

    self.parts.wpn_fps_upg_ns_ass_smg_medium.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_upg_ns_pis_large.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_upg_ns_pis_large_kac.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_upg_ns_pis_jungle.stats = deep_clone(self.nqr.sps_stats.medium2)
    self.parts.wpn_fps_upg_ak_ns_tgp.stats = deep_clone(self.nqr.sps_stats.medium2)

    self.parts.wpn_fps_upg_ns_pis_putnik.sound_switch.suppressed = "suppressed_b"
    self.parts.wpn_fps_upg_ns_pis_putnik.stats = deep_clone(self.nqr.sps_stats.thicc)

    self.parts.wpn_fps_upg_ns_ass_pbs1.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_upg_ns_ass_pbs1.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_upg_ns_ass_smg_large.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_m4_upg_ns_mk12.is_a_unlockable = true
    self.parts.wpn_fps_m4_upg_ns_mk12.texture_bundle_folder = "ja22"
    self.parts.wpn_fps_m4_upg_ns_mk12.dlc = "ja22"
    self.parts.wpn_fps_m4_upg_ns_mk12.pcs = {}
    self.parts.wpn_fps_m4_upg_ns_mk12.perks = { "silencer" }
    self.parts.wpn_fps_m4_upg_ns_mk12.sound_switch = { suppressed = "suppressed_c" }
    self.parts.wpn_fps_m4_upg_ns_mk12.stats = deep_clone(self.nqr.sps_stats.big)

    self.parts.wpn_fps_upg_ns_shot_thick.sound_switch.suppressed = "suppressed_b"
    self.parts.wpn_fps_upg_ns_shot_thick.stats = { concealment = 20, weight = 8, length = 6, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_upg_ns_sho_salvo_large.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_upg_ns_sho_salvo_large.stats = { concealment = 26, weight = 10, length = 10, md_code = {5,0,0,0,0} }
    self.parts.wpn_fps_upg_ns_sho_salvo_small = deep_clone(self.parts.wpn_fps_upg_ns_sho_salvo_large)
    self.parts.wpn_fps_upg_ns_sho_salvo_small.name_id = "bm_wp_upg_ns_sho_salvo_small"
    self.parts.wpn_fps_upg_ns_sho_salvo_small.unit = "units/pd2_dlc_butcher_mods/weapons/wpn_fps_upg_ns_sho_salvo/wpn_fps_upg_ns_sho_salvo_small"
    self.parts.wpn_fps_upg_ns_sho_salvo_small.sound_switch.suppressed = "suppressed_b"
    self.parts.wpn_fps_upg_ns_sho_salvo_small.stats = { concealment = 14, weight = 6, length = 5, md_code = {3,0,0,0,0} }



----SIGHTS
    self.parts.wpn_fps_upg_o_mbus_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_mbus_rear.forbids = {}
    table.addto(self.parts.wpn_fps_upg_o_mbus_rear.forbids, table.without(self.nqr.all_sights, table.combine(self.nqr.all_angled_sights, self.nqr.all_piggyback_sights, self.nqr.all_light_reddots)))
    self.parts.wpn_fps_upg_o_mbus_rear.stats = { concealment = 2, weight = 0, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_mbus_pro.pcs = nil
    self.parts.wpn_fps_upg_o_mbus_pro.stats = { concealment = 0, weight = 0, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_mbus_pro_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_mbus_pro_rear.stats = { concealment = 2, weight = 1, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_dd_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_dd_rear.forbids = {}
    table.addto(self.parts.wpn_fps_upg_o_dd_rear.forbids, table.without(self.nqr.all_sights, table.combine(self.nqr.all_angled_sights, self.nqr.all_piggyback_sights, self.nqr.all_light_reddots)))
    self.parts.wpn_fps_upg_o_dd_rear.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_m4_uupg_o_flipup.forbids = {}
    table.addto(self.parts.wpn_fps_m4_uupg_o_flipup.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_spot, self.nqr.i_f_c96, self.nqr.i_f_acog))
    self.parts.wpn_fps_m4_uupg_o_flipup.stats = { concealment = 2, weight = 1 } --sigthheight is being calculated somehow lol

    self.parts.wpn_fps_upg_o_docter.stats = { concealment = 2, weight = 2, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_t1micro.stats = { concealment = 4, weight = 2, sightheight = height_dflt }
    table.addto(self.parts.wpn_fps_upg_o_reflex.forbids, self.nqr.all_magnifiers)
    self.parts.wpn_fps_upg_o_reflex.stats = { concealment = 3, weight = 2, sightheight = height_dflt }
    table.addto(self.parts.wpn_fps_upg_o_rx01.forbids, self.nqr.all_magnifiers)
    self.parts.wpn_fps_upg_o_rx01.stats = { concealment = 5, weight = 2, sightheight = height_dflt }
    table.addto(self.parts.wpn_fps_upg_o_rx30.forbids, self.nqr.all_magnifiers)
    self.parts.wpn_fps_upg_o_rx30.stats = { concealment = 6, weight = 3, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_eotech.stats = { concealment = 6, weight = 4, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_eotech_xps.stats = { concealment = 5, weight = 3, sightheight = height_dflt }
    table.addto(self.parts.wpn_fps_upg_o_cmore.forbids, self.nqr.all_magnifiers)
    self.parts.wpn_fps_upg_o_cmore.stats = { concealment = 4, weight = 2, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_uh.stats = { concealment = 4, weight = 3, sightheight = height_dflt-0.05 }
    self.parts.wpn_fps_upg_o_fc1.stats = { concealment = 3, weight = 3, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_cs.desc_id = "bm_wp_upg_o_piggyback_canpiggyback_desc"
    self.parts.wpn_fps_upg_o_cs.reticle_obj = nil
    self.parts.wpn_fps_upg_o_cs.visibility = nil
    self.parts.wpn_fps_upg_o_cs.camera = nil
    self.parts.wpn_fps_upg_o_cs.texture_switch = { material = "gfx_reddot", channel = "diffuse_texture" }
    self.parts.wpn_fps_upg_o_cs.material_parameters = deep_clone(self.parts.wpn_fps_upg_o_specter.material_parameters)
    self.parts.wpn_fps_upg_o_cs.piggyback_height = 6.5
    self.parts.wpn_fps_upg_o_cs.stats = { concealment = 13, weight = 4, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_cs_piggyback.type = "piggyback_iron"
    self.parts.wpn_fps_upg_o_cs_piggyback.stats = { concealment = 0, weight = 0, sightheight = height_dflt+3.3 }
    self.parts.wpn_fps_upg_o_tf90.stats = { concealment = 13, weight = 3, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_tf90_steelsight.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_aimpoint.forbids = {}
    self.parts.wpn_fps_upg_o_aimpoint.stats = { concealment = 6, weight = 3, sightheight = height_dflt }
    self.parts.wpn_fps_upg_o_aimpoint_2.forbids = {}
    self.parts.wpn_fps_upg_o_aimpoint_2.stats = { concealment = 6, weight = 3, sightheight = height_dflt }

    self.parts.wpn_fps_upg_o_specter.reticle_obj = "g_gfx"
    self.parts.wpn_fps_upg_o_specter.stats = { concealment = 9, weight = 7, sightheight = height_dflt, zoom = 4 } --1-4
    self.parts.wpn_fps_upg_o_specter_piggyback.type = "piggyback_iron"
    self.parts.wpn_fps_upg_o_specter_piggyback.stats = { concealment = 0, weight = 0, sightheight = height_dflt+3.2 }
    self.parts.wpn_fps_upg_o_acog.stats = { concealment = 7, weight = 5, sightheight = height_dflt, zoom = 4 }
    self.parts.wpn_fps_upg_o_spot.has_description = true
    self.parts.wpn_fps_upg_o_spot.desc_id = "bm_wp_upg_o_can_sightaddon_desc"
    self.parts.wpn_fps_upg_o_spot.reticle_obj = "g_reddot"
    self.parts.wpn_fps_upg_o_spot.visibility = { { objects = { g_inside = false, g_illum = false, g_display = false, g_display_upper = false } } }
    self.parts.wpn_fps_upg_o_spot.stats = { concealment = 10, weight = 5, sightheight = height_dflt, zoom = 4 } --3-9
    self.parts.wpn_fps_upg_o_spot_rangefinder = deep_clone(self.parts.wpn_fps_upg_o_spot)
    self.parts.wpn_fps_upg_o_spot_rangefinder.unit = "units/pd2_dlc_tng/weapons/wpn_fps_upg_o_spot/wpn_fps_upg_o_spot_rangefinder"
    self.parts.wpn_fps_upg_o_spot_rangefinder.name_id = "bm_wp_upg_o_spot_rangefinder"
    self.parts.wpn_fps_upg_o_spot_rangefinder.desc_id = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.type = "sight_addon"
    self.parts.wpn_fps_upg_o_spot_rangefinder.stance_mod = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.texture_switch = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.camera = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.reticle_obj = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.visibility = nil
    self.parts.wpn_fps_upg_o_spot_rangefinder.stats = { concealment = 5, weight = 2 }
    self.parts.wpn_fps_upg_o_poe.reticle_obj = "g_reddot"
    self.parts.wpn_fps_upg_o_poe.stats = { concealment = 7, weight = 5, sightheight = height_dflt, zoom = 4 }
    self.parts.wpn_fps_upg_o_atibal.has_description = true
    self.parts.wpn_fps_upg_o_atibal.desc_id = "bm_wp_upg_o_canpiggyback_desc"
    self.parts.wpn_fps_upg_o_atibal.adds = { "wpn_fps_upg_o_atibal_steelsight" }
    self.parts.wpn_fps_upg_o_atibal.reticle_obj = "g_gfx"
    self.parts.wpn_fps_upg_o_atibal.piggyback_height = height_dflt+5.9 -1.9 +0.1
    self.parts.wpn_fps_upg_o_atibal.stats = { concealment = 5, weight = 4, sightheight = height_dflt+0.7, zoom = 3 } --weight = 5
    self.parts.wpn_fps_upg_o_atibal_reddot.pcs = {}
    self.parts.wpn_fps_upg_o_atibal_reddot.name_id = "bm_wp_upg_o_atibal_reddot"
    self.parts.wpn_fps_upg_o_atibal_reddot.texture_bundle_folder = "mxm"
    self.parts.wpn_fps_upg_o_atibal_reddot.dlc = "mxm"
    self.parts.wpn_fps_upg_o_atibal_reddot.type = "second_sight"
    self.parts.wpn_fps_upg_o_atibal_reddot.sub_type = "piggyback"
    self.parts.wpn_fps_upg_o_atibal_reddot.stats = { concealment = 3, weight = 1, sightheight = 1.9 } --height_dflt+5.9 --2.7
    self.parts.wpn_fps_upg_o_hamr.reticle_obj = "g_gfx"
    self.parts.wpn_fps_upg_o_hamr.forbids = {}
    table.addto(self.parts.wpn_fps_upg_o_hamr.forbids, self.nqr.all_second_sights)
    self.parts.wpn_fps_upg_o_hamr.stats = { concealment = 7, weight = 5, sightheight = height_dflt, zoom = 4 }
    self.parts.wpn_fps_upg_o_hamr_reddot.stats = { concealment = 0, weight = 0, sightheight = height_dflt+3.3 } --3.45

    self.parts.wpn_fps_upg_o_shortdot.pcs = {}
    self.parts.wpn_fps_upg_o_shortdot.name_id = "bm_wp_upg_o_shortdot"
    self.parts.wpn_fps_upg_o_shortdot.is_a_unlockable = false
    self.parts.wpn_fps_upg_o_shortdot.override = {}
    self.parts.wpn_fps_upg_o_shortdot.stats = { concealment = 14, weight = 7, sightheight = height_dflt+0.75-0.75, zoom = 6 } --1-8
    self.parts.wpn_fps_upg_o_shortdot_steelsight.visibility = { { objects = { g_vr_lens = false, g_vr_phong = false, g_screen = false } } }
    self.parts.wpn_fps_upg_o_northtac_steelsight.visibility = { { objects = { g_vr_lens = false, g_vr_phong = false, g_screen = false } } }
    self.parts.wpn_fps_upg_o_northtac.has_description = true
    self.parts.wpn_fps_upg_o_northtac.desc_id = "bm_wp_upg_o_canpiggyback_desc"
    self.parts.wpn_fps_upg_o_northtac.piggyback_height = height_dflt+5.1 -2.3 +0.1
    self.parts.wpn_fps_upg_o_northtac.adds = { "wpn_fps_upg_o_northtac_steelsight" }
    self.parts.wpn_fps_upg_o_northtac.override = {}
    self.parts.wpn_fps_upg_o_northtac.stats = { concealment = 15, weight = 8, sightheight = height_dflt, zoom = 6 } --not_sure weight --1-4
    self.parts.wpn_fps_upg_o_northtac_reddot.pcs = {}
    self.parts.wpn_fps_upg_o_northtac_reddot.name_id = "bm_wp_upg_o_northtac_reddot"
    self.parts.wpn_fps_upg_o_northtac_reddot.texture_bundle_folder = "pxp3"
    self.parts.wpn_fps_upg_o_northtac_reddot.dlc = "pxp3"
    self.parts.wpn_fps_upg_o_northtac_reddot.type = "second_sight"
    self.parts.wpn_fps_upg_o_northtac_reddot.sub_type = "piggyback"
    self.parts.wpn_fps_upg_o_northtac_reddot.stats = { concealment = 3, weight = 1, sightheight = 2.3 } --height_dflt+5.1 --2.6
    self.parts.wpn_fps_upg_o_northtac_magnified = {
		type = "extra",
		a_obj = "a_o",
		sub_type = "ironsight",
		name_id = "bm_wpn_fps_upg_o_schmidt_magnified",
		unit = "units/pd2_dlc_pxp4/weapons/wpn_fps_upg_o_schmidt/wpn_fps_upg_o_schmidt_magnified",
        adds = {}, forbids = {}, override = {},
		stats = { concealment = 0, weight = 0, sightheight = height_dflt, zoom = 4 },
		perks = { "second_sight" },
		custom_stats = { use_primary_steelsight_unit = true },
    }
    self.parts.wpn_fps_upg_o_leupold.has_description = true
    self.parts.wpn_fps_upg_o_leupold.desc_id = "bm_wp_upg_o_rangefinder_desc"
    table.delete(self.parts.wpn_fps_upg_o_leupold.perks, "highlight")
    self.parts.wpn_fps_upg_o_leupold.override = {}
    self.parts.wpn_fps_upg_o_leupold.visibility = { { objects = { g_inside = false, } } }
    self.parts.wpn_fps_upg_o_leupold.stats = { concealment = 22, weight = 11, sightheight = height_dflt+0.85, zoom = 16 } --8.5-25
    self.parts.wpn_fps_upg_o_bmg.has_description = true
    self.parts.wpn_fps_upg_o_bmg.desc_id = "bm_wp_upg_o_canpiggyback_desc"
    self.parts.wpn_fps_upg_o_bmg.piggyback_height = self.parts.wpn_fps_upg_o_atibal.piggyback_height
    self.parts.wpn_fps_upg_o_bmg.override = {}
    self.parts.wpn_fps_upg_o_bmg.stats = { concealment = 15, weight = 10, sightheight = height_dflt, zoom = 6 }
    self.parts.wpn_fps_upg_o_box.has_description = true
    self.parts.wpn_fps_upg_o_box.piggyback_height = 8.3
    self.parts.wpn_fps_upg_o_box.override = {}
    self.parts.wpn_fps_upg_o_box.visibility = { { objects = { g_inside = false, } } }
    self.parts.wpn_fps_upg_o_box.stats = { concealment = 20, weight = 11, sightheight = height_dflt+0.85, zoom = 10 } --3.5-14
    self.parts.wpn_fps_upg_o_box_steelsight.visibility = { { objects = { g_box = false, g_gfx_lens = false, g_gfx_lens_2 = false, g_gfx_lens_3 = false } } }
    self.parts.wpn_fps_upg_o_schmidt.reticle_obj = "g_reddot"
    table.delete(self.parts.wpn_fps_upg_o_schmidt.perks, "highlight")
    self.parts.wpn_fps_upg_o_schmidt.adds = { "wpn_fps_upg_o_schmidt_steelsight" }
    self.parts.wpn_fps_upg_o_schmidt.override = {}
    self.parts.wpn_fps_upg_o_schmidt.visibility = { { objects = { g_cap_front = false, g_cap_rear = false, } } }
    self.parts.wpn_fps_upg_o_schmidt.stats = { concealment = 18, weight = 13, sightheight = height_dflt+0.75, zoom = 12 } --5-25
    self.parts.wpn_fps_upg_o_schmidt_steelsight.visibility = { { objects = { g_vr_lens = false, g_screen = false, g_vr_phong = false, } } }
    self.parts.wpn_fps_upg_o_schmidt_magnified.stats = { concealment = 0, weight = 0, sightheight = height_dflt+0.75, zoom = 20 } --5-25
    for i, k in pairs({} or self.nqr.all_optics) do
        self.parts[k].override = self.parts[k].override or {}
        for u, j in pairs(ironsights) do
            self.parts[k].override[j] = self.parts[k].override[j] or {}
            self.parts[k].override[j].override = self.parts[k].override[j].override or {}
            self.parts[k].override[j].unit = fantom_unit
        end
    end
    for i, k in pairs({} or self.nqr.all_reddots) do
        self.parts[k].override = self.parts[k].override or {}
        for u, j in pairs({} or ironsights) do --todo
            for y, h in pairs(self.nqr.all_angled_sights) do
                self.parts[k].override[h] = self.parts[k].override[h] or {}
                self.parts[k].override[h].override = self.parts[k].override[h].override or {}
                self.parts[k].override[h].override[j] = { unit = fantom_unit }
            end
        end
    end
    for i, k in pairs({} or self) do
        if k.uses_parts then
            local has_ironsight = nil
            for u, j in pairs(ironsights_railable) do
            --for u, j in pairs(ironsights_high) do
                if table.contains(k.uses_parts, j) then has_ironsight = true break end
            end
            if has_ironsight then table.addto(k.uses_parts, ironsights_railable) end
            if has_ironsight then table.insert(k.uses_parts, "wpn_fps_remove_ironsight") end
        end
    end

    self.parts.wpn_fps_upg_o_45iron.depends_on = nil
    self.parts.wpn_fps_upg_o_45iron.stats = { concealment = 0, weight = 1, sightpos = {-5.34, -2.1, -45} }
    self.parts.wpn_fps_upg_o_45steel.depends_on = nil
    self.parts.wpn_fps_upg_o_45steel.stats = { concealment = 0, weight = 1, sightpos = {-5.34, -2.1, -45} }
    self.parts.wpn_fps_upg_o_45rds.is_a_unlockable = nil
    self.parts.wpn_fps_upg_o_45rds.depends_on = nil
    self.parts.wpn_fps_upg_o_45rds.a_obj = "a_magnifier"
    self.parts.wpn_fps_upg_o_45rds.parent = "sight"
    self.parts.wpn_fps_upg_o_45rds.stats = { concealment = 0, weight = 2, sightpos = {-5.34, -2.1, -45} }
    self.parts.wpn_fps_upg_o_45rds_v2.depends_on = nil
    self.parts.wpn_fps_upg_o_45rds_v2.a_obj = "a_magnifier"
    self.parts.wpn_fps_upg_o_45rds_v2.parent = "sight"
    self.parts.wpn_fps_upg_o_45rds_v2.stats = { concealment = 0, weight = 2, sightpos = {-5.34, -2.1, -45} }
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.has_description = true
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.desc_id = "bm_wp_magnifier_desc"
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.depends_on = nil
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.a_obj = "a_magnifier"
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.parent = "sight"
    self.parts.wpn_fps_upg_o_xpsg33_magnifier.stats = { concealment = 0, weight = 3, sightheight = height_dflt, zoom = 3 }
    self.parts.wpn_fps_upg_o_sig.has_description = true
    self.parts.wpn_fps_upg_o_sig.desc_id = "bm_wp_magnifier_desc"
    self.parts.wpn_fps_upg_o_sig.depends_on = nil
    self.parts.wpn_fps_upg_o_sig.a_obj = "a_magnifier"
    self.parts.wpn_fps_upg_o_sig.parent = "sight"
    self.parts.wpn_fps_upg_o_sig.stats = { concealment = 0, weight = 3, sightheight = height_dflt, zoom = 3 }

    for i, k in pairs({} or self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.parts.wpn_fps_o_pos_fg.override.wpn_fps_o_blank.override[k] = { a_obj = "a_of", parent = false }
            --self.parts.wpn_fps_o_pos_zenitco.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_zenit", parent = "upper_reciever" }
            --self.parts.wpn_fps_o_pos_a_o_sm.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.parts.wpn_fps_o_pos_fg.override[k] = { a_obj = "a_of" }
            --self.parts.wpn_fps_o_pos_zenitco.override[k] = { a_obj = "a_o_zenit", parent = "upper_reciever" }
            --self.parts.wpn_fps_o_pos_a_o_sm.override[k] = { a_obj = "a_o_sm" }
        end
    end
    for i, k in pairs(self.nqr.all_sights_no_optics) do if not self.parts[k].parent then self.parts.wpn_fps_o_pos_fg.override[k] = { a_obj = "a_of" } end end
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.parts.wpn_fps_o_pos_a_o_sm.override[k] = { a_obj = "a_o_sm" } end end
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.parts.wpn_fps_o_pos_zenitco.override[k] = { a_obj = "a_o_zenit", parent = "upper_reciever" } end end

    self.parts.wpn_upg_o_marksmansight_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_upg_o_marksmansight_rear.type = "ironsight"
    self.parts.wpn_upg_o_marksmansight_rear.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_rmr.parent = nil
    self.parts.wpn_fps_upg_o_rmr.stats = { concealment = 2, weight = 1, sightheight = 1, use_stance_mod = true }
    self.parts.wpn_fps_upg_o_rms.parent = nil
    self.parts.wpn_fps_upg_o_rms.stats = { concealment = 2, weight = 1, sightheight = 1, use_stance_mod = true }
    self.parts.wpn_fps_upg_o_rikt.parent = nil
    self.parts.wpn_fps_upg_o_rikt.stats = { concealment = 3, weight = 1, sightheight = 1.7, use_stance_mod = true }



----FLASHLIGHTS/LASERS
    self.parts.wpn_fps_upg_fl_ass_laser.power = { laser = 0.5 }
    self.parts.wpn_fps_upg_fl_ass_laser.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_ass_smg_sho_peqbox.power = { laser = 0.5 }
    self.parts.wpn_fps_upg_fl_ass_smg_sho_peqbox.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_ass_peq15.adds = {}
    self.parts.wpn_fps_upg_fl_ass_peq15.power = { laser = 1 }
    self.parts.wpn_fps_upg_fl_ass_peq15.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_fl_ass_smg_sho_surefire.power = { flashlight = 1 }
    self.parts.wpn_fps_upg_fl_ass_smg_sho_surefire.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_fl_ass_utg.power = { laser = 0.5, flashlight = 1 }
    self.parts.wpn_fps_upg_fl_ass_utg.stats = { concealment = 0, weight = 3 }

    self.parts.wpn_fps_upg_fl_pis_laser.power = { laser = 0.5 }
    self.parts.wpn_fps_upg_fl_pis_laser.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_pis_crimson.power = { laser = 0.5 }
    self.parts.wpn_fps_upg_fl_pis_crimson.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_pis_tlr1.power = { flashlight = 0.5 }
    self.parts.wpn_fps_upg_fl_pis_tlr1.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_pis_m3x.power = { flashlight = 0.5 }
    self.parts.wpn_fps_upg_fl_pis_m3x.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_fl_pis_perst.power = { laser = 1 }
    self.parts.wpn_fps_upg_fl_pis_perst.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_fl_dbal_laser.desc_id = "bm_wp_upg_fl_x400v_desc"
    self.parts.wpn_fps_upg_fl_dbal_laser.adds = { "wpn_fps_upg_fl_ass_peq15_flashlight" }
    self.parts.wpn_fps_upg_fl_dbal_laser.override = { wpn_fps_upg_fl_ass_peq15_flashlight = { parent = false } }
    self.parts.wpn_fps_upg_fl_dbal_laser.power = { laser = 0.5, flashlight = 0.5 }
    self.parts.wpn_fps_upg_fl_dbal_laser.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_fl_pis_x400v.power = { laser = 0.5, flashlight = 1 }
    self.parts.wpn_fps_upg_fl_pis_x400v.stats = { concealment = 0, weight = 3 }



----UNDERBARREL
    self.parts.wpn_fps_upg_bp_lmg_lionbipod.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_vg_ass_smg_afg.pcs = {}
    self.parts.wpn_fps_upg_vg_ass_smg_afg.name_id = "bm_wp_fps_upg_vg_ass_smg_afg"
    self.parts.wpn_fps_upg_vg_ass_smg_afg.forbids = { "wpn_fps_smg_schakal_vg_extra" }
    self.parts.wpn_fps_upg_vg_ass_smg_afg.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_vg_ass_smg_stubby.pcs = {}
    self.parts.wpn_fps_upg_vg_ass_smg_stubby.name_id = "bm_wp_fps_upg_vg_ass_smg_stubby"
    self.parts.wpn_fps_upg_vg_ass_smg_stubby.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_vg_ass_smg_verticalgrip.pcs = {}
    self.parts.wpn_fps_upg_vg_ass_smg_verticalgrip.name_id = "bm_wp_fps_upg_vg_ass_smg_verticalgrip"
    self.parts.wpn_fps_upg_vg_ass_smg_verticalgrip.stats = { concealment = 0, weight = 1 }



----ASSAULT RIFLE
--------M4
    self.parts.wpn_fps_snp_victor_o_standard.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_o_standard.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_snp_victor_o_standard.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_spot, self.nqr.i_f_c96, self.nqr.i_f_acog))
    self.parts.wpn_fps_snp_victor_o_standard.stats = { concealment = 2, weight = 0, sightheight = height_dflt-0.325 }
    self.parts.wpn_fps_snp_victor_o_hera = deep_clone(self.parts.wpn_fps_snp_victor_o_standard)
    self.parts.wpn_fps_snp_victor_o_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_o_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_hera"
    self.parts.wpn_fps_snp_victor_o_hera.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera"

    local forbids_fg_1 = {
        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_m16_fg_standard", "wpn_fps_m16_fg_vietnam",
        "wpn_fps_upg_fg_jp", "wpn_fps_upg_fg_smr", "wpn_fps_m16_fg_railed",
        "wpn_fps_upg_ass_m4_fg_moe", "wpn_fps_upg_ass_m4_fg_lvoa", "wpn_fps_snp_victor_fg_hera", "wpn_fps_uupg_fg_radian",
        "wpn_fps_amcar_uupg_fg_amcar", "wpn_fps_m4_uupg_fg_lr300",
    }
    local forbids_b_os1 = {
        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12", "wpn_fps_m4_uupg_b_sd",

        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_m16_fg_standard", "wpn_fps_m16_fg_vietnam",
        "wpn_fps_upg_fg_jp", "wpn_fps_upg_fg_smr", "wpn_fps_m16_fg_railed",
        "wpn_fps_upg_ass_m4_fg_moe", "wpn_fps_upg_ass_m4_fg_lvoa", "wpn_fps_snp_victor_fg_hera", "wpn_fps_uupg_fg_radian",
        "wpn_fps_m4_uupg_fg_lr300",
    } table.addto(forbids_b_os1, {"wpn_fps_upg_o_leupold"})
    local forbids_b_os2 = {
        --"wpn_fps_m4_uupg_b_sd",

        --"wpn_fps_upg_fg_jp", "wpn_fps_upg_fg_smr", "wpn_fps_m16_fg_railed",
        --"wpn_fps_upg_ass_m4_fg_moe", "wpn_fps_upg_ass_m4_fg_lvoa", "wpn_fps_snp_victor_fg_hera", "wpn_fps_uupg_fg_radian",
        --"wpn_fps_m4_uupg_fg_lr300",

        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12", "wpn_fps_m4_uupg_b_sd",
    }
    local forbids_b_os3 = {
        "wpn_fps_m4_uupg_b_sd",

        "wpn_fps_upg_fg_jp", "wpn_fps_upg_fg_smr", "wpn_fps_m16_fg_railed",
        "wpn_fps_upg_ass_m4_fg_moe", "wpn_fps_upg_ass_m4_fg_lvoa", "wpn_fps_snp_victor_fg_hera", "wpn_fps_uupg_fg_radian",
        "wpn_fps_m4_uupg_fg_lr300",
    } table.addto(forbids_b_os3, {"wpn_fps_upg_o_leupold", "wpn_fps_upg_o_schmidt"})
    local forbids_fg_3 = {
        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_m16_fg_standard", "wpn_fps_m16_fg_vietnam",
    }
    local forbids_fg_sd = {
        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_m16_fg_vietnam",
        "wpn_fps_upg_fg_smr",
        "wpn_fps_snp_victor_fg_hera", "wpn_fps_uupg_fg_radian",
    }
    local forbids_fg_4 = {
        "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_m16_fg_standard", "wpn_fps_m16_fg_vietnam",
        "wpn_fps_upg_fg_jp", "wpn_fps_upg_fg_smr", "wpn_fps_m16_fg_railed",
    }
    self.parts.wpn_fps_m4_uupg_b_long.forbids = { "wpn_fps_amcar_uupg_fg_amcar", "wpn_fps_m4_uupg_fg_lr300", }
    self.parts.wpn_fps_m4_uupg_b_long.stats = { concealment = 0, weight = 20, barrel_length = 20, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_m4_uupg_b_medium.forbids = { "wpn_fps_m16_fg_standard", "wpn_fps_m16_fg_vietnam", }
    self.parts.wpn_fps_m4_uupg_b_medium.override = {}
    self.parts.wpn_fps_m4_uupg_b_medium.override.wpn_fps_ass_m16_os_frontsight = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_medium.override.wpn_fps_ass_m16_os_frontsight2 = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_medium.override.wpn_fps_ass_m16_os_frontsight3 = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_medium.stats = { concealment = 0, weight = 15, barrel_length = 14.5, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_m4_uupg_b_medium_os2 = deep_clone(self.parts.wpn_fps_m4_uupg_b_medium)
    self.parts.wpn_fps_m4_uupg_b_medium_os2.name_id = "bm_wp_m4_uupg_b_medium_os2"
    self.parts.wpn_fps_m4_uupg_b_medium_os2.forbids = { "wpn_fps_amcar_uupg_fg_amcar", "wpn_fps_m4_uupg_fg_lr300" }
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_m4_uupg_fg_rail_ext = { a_obj = "a_os2" }
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight.a_obj = "a_os2"
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight2.a_obj = "a_os2"
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight3.a_obj = "a_os2"
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight.forbids = deep_clone(forbids_b_os2)
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight2.forbids = deep_clone(forbids_b_os2)
    self.parts.wpn_fps_m4_uupg_b_medium_os2.override.wpn_fps_ass_m16_os_frontsight3.forbids = deep_clone(forbids_b_os2)
    self.parts.wpn_fps_m4_uupg_b_short.forbids = deep_clone(forbids_fg_3)
    self.parts.wpn_fps_m4_uupg_b_short.override = {}
    self.parts.wpn_fps_m4_uupg_b_short.override.wpn_fps_ass_m16_os_frontsight = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_short.override.wpn_fps_ass_m16_os_frontsight2 = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_short.override.wpn_fps_ass_m16_os_frontsight3 = { forbids = deep_clone(forbids_b_os1) }
    self.parts.wpn_fps_m4_uupg_b_short.stats = { concealment = 0, weight = 12, barrel_length = 11.5, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_m4_uupg_b_short_os3 = deep_clone(self.parts.wpn_fps_m4_uupg_b_short)
    self.parts.wpn_fps_m4_uupg_b_short_os3.name_id = "bm_wp_m4_uupg_b_short_os3"
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_m4_uupg_fg_rail_ext = { a_obj = "a_os3" }
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight.a_obj = "a_os3"
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight2.a_obj = "a_os3"
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight3.a_obj = "a_os3"
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight.forbids = deep_clone(forbids_b_os3)
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight2.forbids = deep_clone(forbids_b_os3)
    self.parts.wpn_fps_m4_uupg_b_short_os3.override.wpn_fps_ass_m16_os_frontsight3.forbids = deep_clone(forbids_b_os3)
    self.parts.wpn_fps_m4_uupg_b_short_os3.stats = { concealment = 0, weight = 12, barrel_length = 11.5, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    table.insert(self.parts.wpn_fps_m4_uupg_b_short_os3.forbids, "wpn_fps_amcar_uupg_fg_amcar")
    table.insert(self.parts.wpn_fps_m4_uupg_b_short_os3.forbids, "wpn_fps_m4_uupg_fg_lr300")
    self.parts.wpn_fps_para_b_medium = {
        unit = "units/payday2/weapons/wpn_fps_ass_m4_pts/wpn_fps_para_b_medium",
		a_obj = "a_b",
		type = "barrel",
		name_id = "bm_wp_para_b_medium",
		pcs = {},
        adds = {},
        forbids = deep_clone(forbids_fg_4),
        override = {
            wpn_fps_ass_m16_os_frontsight = { forbids = deep_clone(forbids_b_os2) },
            wpn_fps_ass_m16_os_frontsight2 = { forbids = deep_clone(forbids_b_os2) },
            wpn_fps_ass_m16_os_frontsight3 = { forbids = deep_clone(forbids_b_os2) },
        },
		stats = { concealment = 0, weight = 0, barrel_length = 10.5 },
    }
    self.parts.wpn_fps_para_b_medium_os3 = deep_clone(self.parts.wpn_fps_para_b_medium)
    self.parts.wpn_fps_para_b_medium_os3.name_id = "bm_wp_para_b_medium_os3"
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_m4_uupg_fg_rail_ext = { a_obj = "a_os3" }
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight.a_obj = "a_os3"
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight2.a_obj = "a_os3"
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight3.a_obj = "a_os3"
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight.forbids = deep_clone(forbids_b_os3)
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight2.forbids = deep_clone(forbids_b_os3)
    self.parts.wpn_fps_para_b_medium_os3.override.wpn_fps_ass_m16_os_frontsight3.forbids = deep_clone(forbids_b_os3)
    table.insert(self.parts.wpn_fps_para_b_medium_os3.forbids, "wpn_fps_amcar_uupg_fg_amcar")
    table.insert(self.parts.wpn_fps_para_b_medium_os3.forbids, "wpn_fps_m4_uupg_fg_lr300")
    self.parts.wpn_fps_para_b_short = {
        unit = "units/payday2/weapons/wpn_fps_ass_m4_pts/wpn_fps_para_b_short",
		a_obj = "a_b",
		type = "barrel",
		name_id = "bm_wp_para_b_short",
		pcs = {},
        adds = {}, override = {},
		forbids = deep_clone(forbids_fg_1),
        override = {
            wpn_fps_ass_m16_os_frontsight = { forbids = deep_clone(forbids_b_os3) },
            wpn_fps_ass_m16_os_frontsight2 = { forbids = deep_clone(forbids_b_os3) },
            wpn_fps_ass_m16_os_frontsight3 = { forbids = deep_clone(forbids_b_os3) },
        },
		stats = { concealment = 0, weight = 0, barrel_length = 6.5 }
    }
    self.parts.wpn_fps_m4_uupg_b_sd.forbids = deep_clone(forbids_fg_sd)
    self.parts.wpn_fps_m4_uupg_b_sd.override = { wpn_fps_m4_uupg_fg_rail_ext = { unit = fantom_unit } }
    self.parts.wpn_fps_m4_uupg_b_sd.stats = { concealment = 0, weight = 11, barrel_length = 6, md_code = {5,0,0,0,0} } --not_sure barrel
    self.parts.wpn_fps_upg_ass_m4_b_beowulf.sound_switch = nil
    self.parts.wpn_fps_upg_ass_m4_b_beowulf.stats = { concealment = 0, weight = 0, barrel_length = 23 } --roughly

    self.parts.wpn_fps_ass_m16_o_handle_sight.pcs = {}
    self.parts.wpn_fps_ass_m16_o_handle_sight.type = "ironsight"
    self.parts.wpn_fps_ass_m16_o_handle_sight.sightpairs = { "wpn_fps_ass_m16_os_frontsight", "wpn_fps_ass_m16_os_frontsight2", "wpn_fps_ass_m16_os_frontsight3" }
    self.parts.wpn_fps_ass_m16_o_handle_sight.adds = {}
    self.parts.wpn_fps_ass_m16_o_handle_sight.forbids = { --[["wpn_fps_m4_uupg_o_flipup",]] "wpn_fps_amcar_uupg_body_upperreciever" } --"wpn_fps_m4_upg_fg_mk12"
    --table.addto(self.parts.wpn_fps_ass_m16_o_handle_sight.forbids, self.nqr.all_second_sights)
    table.addto(self.parts.wpn_fps_ass_m16_o_handle_sight.forbids, self.nqr.all_sights)
    self.parts.wpn_fps_ass_m16_o_handle_sight.stats = { concealment = 5, weight = 3 }
    self.parts.wpn_fps_ass_m16_os_frontsight.pcs = {}
    self.parts.wpn_fps_ass_m16_os_frontsight.a_obj = "a_os1"
    self.parts.wpn_fps_ass_m16_os_frontsight.parent = "barrel"
    self.parts.wpn_fps_ass_m16_os_frontsight.type = "f_gasblock"
    self.parts.wpn_fps_ass_m16_os_frontsight.forbids = {
        "wpn_fps_m4_uupg_o_flipup",

        "wpn_fps_m4_uupg_fg_lr300", "wpn_fps_snp_tti_fg_standard", "wpn_fps_snp_victor_fg_standard", "wpn_fps_m4_upg_fg_mk12", "wpn_fps_m4_uupg_b_sd",
    }
    self.parts.wpn_fps_ass_m16_os_frontsight.override = {
        wpn_fps_m4_uupg_fg_rail = { forbids = { "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_m4_uupg_fg_lr300 = { forbids = { "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_upg_ass_m4_fg_moe = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_upg_ass_m4_fg_lvoa = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_uupg_fg_radian = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_snp_victor_fg_hera = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_upg_fg_jp = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_upg_fg_smr = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", }, },
        wpn_fps_m16_fg_railed = { forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", }, },
    } --add original forbids later
    self.parts.wpn_fps_ass_m16_os_frontsight.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_m4_uupg_fg_rail_ext.pcs = {}
    self.parts.wpn_fps_m4_uupg_fg_rail_ext.a_obj = "a_os1"
    self.parts.wpn_fps_m4_uupg_fg_rail_ext.parent = "barrel"
    self.parts.wpn_fps_m4_uupg_fg_rail_ext.type = "f_gasblock"
    self.parts.wpn_fps_m4_uupg_fg_rail_ext.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_amcar_bolt_standard.pcs = {}
    self.parts.wpn_fps_amcar_bolt_standard.name_id = "bm_wp_amcar_bolt_standard"
    self.parts.wpn_fps_amcar_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_bolt_round = {
        name_id = "bm_wp_upg_ass_m4_bolt_round",
        type = "bolt",
        a_obj = "a_bolt",
        unit = "units/payday2/weapons/wpn_fps_ass_m4_pts/wpn_fps_m4_bolt_round",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_upg_ass_m4_bolt_ballos = {
        name_id = "bm_wp_upg_ass_m4_bolt_ballos",
        type = "bolt",
        a_obj = "a_bolt",
        unit = "units/pd2_dlc_akm4_modpack/weapons/wpn_fps_upg_ass_m4_bolt_ballos/wpn_fps_upg_ass_m4_bolt_ballos",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_upg_ass_m4_bolt_core = {
        name_id = "bm_wp_upg_ass_m4_bolt_core",
        a_obj = "a_bolt",
        unit = "units/pd2_dlc_akm4_modpack/weapons/wpn_fps_upg_ass_m4_bolt_core/wpn_fps_upg_ass_m4_bolt_core",
        type = "bolt",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_m4_bolt_edge = {
        name_id = "bm_wp_upg_ass_m4_bolt_edge",
        a_obj = "a_bolt",
        unit = "units/payday2/weapons/wpn_fps_ass_m4_pts/wpn_fps_m4_bolt_edge",
        type = "bolt",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }

    self.parts.wpn_fps_m4_upper_reciever_round.pcs = {}
    self.parts.wpn_fps_m4_upper_reciever_round.name_id = "bm_wp_fps_m4_upper_reciever_round"
    self.parts.wpn_fps_m4_upper_reciever_round.override = {
        wpn_fps_upper_lock_sights = { forbids = {} },
    }
    self.parts.wpn_fps_m4_upper_reciever_round.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_upper_reciever_edge.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_m4_upper_reciever_edge.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_uupg_upper_radian.visibility = { { objects = { g_reciever = false } } }
    self.parts.wpn_fps_m4_uupg_upper_radian.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_m4_uupg_upper_radian.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ass_m4_upper_reciever_ballos.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_upg_ass_m4_upper_reciever_ballos.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ass_m4_upper_reciever_core.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_upg_ass_m4_upper_reciever_core.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_m4_lower_reciever.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_upg_ass_m4_lower_reciever_core.stats = { concealment = 0, weight = -1, length = 8 }
    self.parts.wpn_fps_m4_uupg_lower_radian.stats = { concealment = 0, weight = 0, length = 8 }

    self.parts.wpn_fps_m4_uupg_draghandle.pcs = {}
    self.parts.wpn_fps_m4_uupg_draghandle.name_id = "bm_wp_fps_m4_uupg_draghandle"
    self.parts.wpn_fps_m4_uupg_draghandle.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_uupg_draghandle_ballos.pcs = {}
    self.parts.wpn_fps_m4_uupg_draghandle_ballos.name_id = "bm_wp_m4_uupg_draghandle_ballos"
    self.parts.wpn_fps_m4_uupg_draghandle_ballos.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_uupg_draghandle_core.pcs = {}
    self.parts.wpn_fps_m4_uupg_draghandle_core.name_id = "bm_wp_m4_uupg_draghandle_core"
    self.parts.wpn_fps_m4_uupg_draghandle_core.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_m4_uupg_draghandle_radian = {
        a_obj = "a_dh",
        type = "drag_handle",
        name_id = "bm_wp_m4_uupg_draghandle_radian",
        unit = "units/pd2_dlc_mxm/weapons/wpn_fps_upg_mxm_m4/wpn_fps_m4_uupg_draghandle_radian",
        third_unit = "units/payday2/weapons/wpn_third_ass_m4_pts/wpn_third_m4_uupg_draghandle",
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
    }

    self.parts.wpn_fps_upg_m4_m_drum.texture_bundle_folder = "nqr_dlc"
    self.parts.wpn_fps_upg_m4_m_drum.dlc = "nqr_dlc"
    self.parts.wpn_fps_upg_m4_m_drum.pcs = {}
    self.parts.wpn_fps_upg_m4_m_drum.name_id = "bm_wp_fps_upg_m4_m_drum"
    self.parts.wpn_fps_upg_m4_m_drum.stats = { concealment = 48, weight = 10, mag_amount = { 1, 1, 2 }, CLIP_AMMO_MAX = { ["5.56x45"] = 100, [".300 BLK"] = 100, [".50 Beo"] = 8 }, retention = false }
    self.parts.wpn_fps_upg_m4_m_l5.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 30, [".50 Beo"] = 10 } }
    self.parts.wpn_fps_upg_m4_m_pmag.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 30, [".50 Beo"] = 10 } }
    self.parts.wpn_fps_upg_m4_m_quad.stats = { concealment = 18, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["5.56x45"] = 60, [".300 BLK"] = 60, [".50 Beo"] = 5 }, retention = false }
    self.parts.wpn_fps_upg_m4_m_straight.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 20, [".300 BLK"] = 20, [".50 Beo"] = 7 } }
    self.parts.wpn_fps_m4_uupg_m_std.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 30, [".50 Beo"] = 10 } }
    self.parts.wpn_fps_m4_uupg_m_strike.stats = { concealment = 11, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = {  ["5.56x45"] = 37, [".300 BLK"] = 37,[".50 Beo"] = 12 } }
    self.parts.wpn_fps_m4_upg_m_quick.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 30, [".50 Beo"] = 10 } }

    self.parts.wpn_fps_m4_uupg_fg_rail.pcs = {}
    self.parts.wpn_fps_m4_uupg_fg_rail.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_m4_uupg_fg_rail.adds = {}
    self.parts.wpn_fps_m4_uupg_fg_rail.forbids = { "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_m4_uupg_fg_rail.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_m4_uupg_fg_lr300.adds = {}
    self.parts.wpn_fps_m4_uupg_fg_lr300.forbids = { "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_m4_uupg_b_long", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short", }
    self.parts.wpn_fps_m4_uupg_fg_lr300.override = { wpn_fps_m4_uupg_fg_rail_ext = { unit = fantom_unit } }
    self.parts.wpn_fps_m4_uupg_fg_lr300.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_upg_ass_m4_fg_moe.rails = { "top", "side" }
    self.parts.wpn_fps_upg_ass_m4_fg_moe.adds = {}
    self.parts.wpn_fps_upg_ass_m4_fg_moe.forbids = { "wpn_fps_gadgets_pos_a_fl2", "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_upg_ass_m4_fg_moe.override = {
        wpn_fps_fold_ironsight = {
            unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down_hera",
            third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
            stats = { concealment = 2, weight = 0 },
        },
        wpn_fps_snp_victor_o_standard = {
            unit = self.parts.wpn_fps_snp_victor_o_hera.unit,
            third_unit = self.parts.wpn_fps_snp_victor_o_hera.third_unit,
            stats = { concealment = 2, weight = 0 },
        },
    }
    self.parts.wpn_fps_upg_ass_m4_fg_moe.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_upg_ass_m4_fg_lvoa.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_upg_ass_m4_fg_lvoa.adds = {}
    self.parts.wpn_fps_upg_ass_m4_fg_lvoa.forbids = { "wpn_fps_para_b_short" }
    self.parts.wpn_fps_upg_ass_m4_fg_lvoa.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_upg_fg_jp.rails = { "top" }
    self.parts.wpn_fps_upg_fg_jp.adds = {}
    self.parts.wpn_fps_upg_fg_jp.forbids = { "wpn_fps_para_b_short", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3" }
    self.parts.wpn_fps_upg_fg_jp.override = {
        wpn_fps_fold_ironsight = {
            unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down_hera",
            third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
            stats = { concealment = 2, weight = 0 },
        },
        wpn_fps_snp_victor_o_standard = {
            unit = self.parts.wpn_fps_snp_victor_o_hera.unit,
            third_unit = self.parts.wpn_fps_snp_victor_o_hera.third_unit,
            stats = { concealment = 2, weight = 0 },
        },
    }
    self.parts.wpn_fps_upg_fg_jp.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_upg_fg_smr.rails = { "top" }
    self.parts.wpn_fps_upg_fg_smr.adds = {}
    self.parts.wpn_fps_upg_fg_smr.forbids = { "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_upg_fg_smr.override = {}
    self.parts.wpn_fps_upg_fg_smr.override = {
        wpn_fps_fold_ironsight = {
            unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down_hera",
            third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
            stats = { concealment = 2, weight = 0 },
        },
        wpn_fps_snp_victor_o_standard = {
            unit = self.parts.wpn_fps_snp_victor_o_hera.unit,
            third_unit = self.parts.wpn_fps_snp_victor_o_hera.third_unit,
            stats = { concealment = 2, weight = 0 },
        },
    }
    self.parts.wpn_fps_upg_fg_smr.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_uupg_fg_radian.rails = { "top" }
    self.parts.wpn_fps_uupg_fg_radian.adds = {}
    self.parts.wpn_fps_uupg_fg_radian.forbids = { "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_uupg_fg_radian.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_m4_upg_fg_mk12.pcs = {}
    self.parts.wpn_fps_m4_upg_fg_mk12.type = "foregrip"
    self.parts.wpn_fps_m4_upg_fg_mk12.perks = nil
    self.parts.wpn_fps_m4_upg_fg_mk12.sound_switch = nil
    self.parts.wpn_fps_m4_upg_fg_mk12.rails = { "top", "side" }
    self.parts.wpn_fps_m4_upg_fg_mk12.adds = {}
    self.parts.wpn_fps_m4_upg_fg_mk12.forbids = { "wpn_fps_m4_uupg_b_sd", "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_m4_upg_fg_mk12.override = {}
    table.addto_dict(self.parts.wpn_fps_m4_upg_fg_mk12.override, overrides_all_sights_to_a_o_2)
    self.parts.wpn_fps_m4_upg_fg_mk12.stats = { concealment = 0, weight = 6, sightheight = 1.76 }

    self.parts.wpn_fps_m4_uupg_g_billet.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_m4_g_ergo.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_m4_g_hgrip.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_m4_g_mgrip.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_m4_g_sniper.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_m4_g_standard.pcs = {}
    self.parts.wpn_fps_upg_m4_g_standard.name_id = "bm_wp_fps_upg_m4_g_standard"
    self.parts.wpn_fps_upg_m4_g_standard.stats = { concealment = 4, weight = 1 }
    self.parts.wpn_fps_upg_g_m4_surgeon.stats = { concealment = 0, weight = 1 }

    self.parts.wpn_fps_upg_m4_s_adapter.pcs = {}
    self.parts.wpn_fps_upg_m4_s_adapter.type = "stock"
    self.parts.wpn_fps_upg_m4_s_adapter.stats = { concealment = 0, weight = 2, length = 6 }
    self.parts.wpn_fps_upg_m4_s_ubr.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_ubr.stats = { concealment = 20, weight = 6, length = 10.08, shouldered = true }
    self.parts.wpn_fps_m4_uupg_s_zulu.stats = { concealment = 7, weight = 6, length = 9.08, shouldered = true }
    self.parts.wpn_fps_upg_m4_s_crane.type = "stock_addon"
    self.parts.wpn_fps_upg_m4_s_crane.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_crane.stats = { concealment = 15, weight = 3, length = 10.07, shouldered = true }
    self.parts.wpn_fps_upg_m4_s_mk46.type = "stock_addon"
    self.parts.wpn_fps_upg_m4_s_mk46.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_mk46.stats = { concealment = 18, weight = 4, length = 10.07, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_upg_m4_s_pts.type = "stock_addon"
    self.parts.wpn_fps_upg_m4_s_pts.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_pts.stats = { concealment = 10, weight = 3, length = 9.06, shouldered = true }
    self.parts.wpn_fps_upg_m4_s_standard.pcs = {}
    self.parts.wpn_fps_upg_m4_s_standard.name_id = "bm_wp_fps_upg_m4_s_standard"
    self.parts.wpn_fps_upg_m4_s_standard.type = "stock_addon"
    self.parts.wpn_fps_upg_m4_s_standard.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_standard.stats = { concealment = 9, weight = 2, length = 9.06, shouldered = true }

    self.parts.wpn_fps_upg_blankcal_556 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_blankcal_556.pcs = nil
    self.parts.wpn_fps_upg_blankcal_556.forbids = { "wpn_fps_upg_a_subfmj" }
    table.addto(self.parts.wpn_fps_upg_blankcal_556.forbids, self.nqr.all_shotgun_ammotypes)
    self.parts.wpn_fps_upg_blankcal_556.stats = {}

    local m4_collection_old = {
        "wpn_fps_amcar_uupg_fg_amcar",
        "wpn_fps_m4_uupg_fg_rail",
        "wpn_fps_m4_uupg_fg_lr300",
        "wpn_fps_upg_ass_m4_fg_moe",
        "wpn_fps_upg_ass_m4_fg_lvoa",
        "wpn_fps_upg_fg_jp",
        "wpn_fps_upg_fg_smr",
        "wpn_fps_uupg_fg_radian",
        "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_m16_fg_standard",
        "wpn_fps_m16_fg_vietnam",
        "wpn_fps_m16_fg_railed",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_smg_olympic_fg_olympic",
        "wpn_fps_smg_olympic_fg_railed",
        "wpn_fps_upg_smg_olympic_fg_lr300",
        "wpn_fps_snp_victor_fg_standard",
        "wpn_fps_snp_victor_fg_hera",
        "wpn_fps_snp_victor_fg_hera_covers",
        "wpn_fps_snp_tti_fg_standard",

        "wpn_fps_addon_ris",
        "wpn_nqr_extra3_rail",
        "wpn_fps_gadgets_pos_a_fl2",
        "wpn_fps_gadgets_pos_a_fl3",

        "wpn_fps_upg_m4_m_drum",
        "wpn_fps_upg_m4_m_l5",
        "wpn_fps_upg_m4_m_pmag",
        "wpn_fps_upg_m4_m_quad",
        "wpn_fps_upg_m4_m_straight",
        "wpn_fps_m4_uupg_m_std",
        "wpn_fps_m4_uupg_m_strike",
        "wpn_fps_m4_upg_m_quick",
        "wpn_fps_ass_tecci_m_drum",

        "wpn_fps_m4_uupg_draghandle",
        "wpn_fps_m4_uupg_draghandle_ballos",
        "wpn_fps_m4_uupg_draghandle_core",
        "wpn_fps_m4_uupg_draghandle_radian",
        "wpn_fps_ass_amcar_dh",
        "wpn_fps_snp_victor_dh_standard",
        "wpn_fps_snp_tti_dh_standard",
        "wpn_fps_ass_tecci_dh_standard",

        "wpn_fps_m4_lower_reciever",
        "wpn_fps_upg_ass_m4_lower_reciever_core",
        "wpn_fps_m4_uupg_lower_radian",
        "wpn_fps_snp_victor_body_receiver_lower",
        "wpn_fps_snp_victor_body_receiver_lower_hera",
        "wpn_fps_ass_tecci_lower_reciever",

        "wpn_fps_m4_upper_reciever_round",
        "wpn_fps_m4_upper_reciever_edge",
        "wpn_fps_m4_uupg_upper_radian",
        "wpn_fps_upg_ass_m4_upper_reciever_ballos",
        "wpn_fps_upg_ass_m4_upper_reciever_core",
        "wpn_fps_amcar_uupg_body_upperreciever",
        "wpn_fps_snp_victor_body_receiver_upper",

        "wpn_fps_amcar_bolt_standard",
        "wpn_fps_m4_bolt_round",
        "wpn_fps_upg_ass_m4_bolt_ballos",
        "wpn_fps_upg_ass_m4_bolt_core",
        "wpn_fps_m4_bolt_edge",

        "wpn_fps_ass_m16_o_handle_sight",
        "wpn_fps_m4_uupg_fg_rail_ext",

        "wpn_fps_upg_ass_m4_b_beowulf",
        "wpn_fps_m4_uupg_b_sd",
        "wpn_fps_para_b_short",
        "wpn_fps_para_b_medium_os3",
        "wpn_fps_para_b_medium",
        "wpn_fps_m4_uupg_b_short_os3",
        "wpn_fps_m4_uupg_b_short",
        "wpn_fps_m4_uupg_b_medium_os2",
        "wpn_fps_m4_uupg_b_medium",
        "wpn_fps_m4_uupg_b_long",
        "wpn_fps_snp_victor_b_standard",

        "wpn_fps_upg_m4_g_hgrip",
        "wpn_fps_upg_m4_g_mgrip",
        "wpn_fps_upg_m4_g_standard",
        "wpn_fps_upg_m4_g_ergo",
        "wpn_fps_upg_m4_g_sniper",
        "wpn_fps_m4_uupg_g_billet",
        "wpn_fps_upg_g_m4_surgeon",
        "wpn_fps_snp_tti_g_grippy",
        "wpn_fps_snp_victor_g_mod3",
        "wpn_fps_ass_tecci_g_standard",
        "wpn_fps_smg_shepheard_g_standard",
        "wpn_fps_sho_m590_g_standard",
        "wpn_fps_sho_sko12_body_grip",

        "wpn_fps_upg_m4_s_adapter",
        "wpn_fps_snp_victor_s_adapter",

        "wpn_fps_upg_m4_s_ubr",
        "wpn_fps_m4_uupg_s_zulu",
        "wpn_fps_smg_olympic_s_adjust",
        "wpn_fps_smg_olympic_s_short",
        "wpn_fps_ass_tecci_s_standard",
        "wpn_fps_m16_s_solid",
        "wpn_fps_ass_contraband_s_standard",
        "wpn_fps_snp_victor_s_hera",

        "wpn_fps_upg_m4_s_standard",
        "wpn_fps_upg_m4_s_crane",
        "wpn_fps_upg_m4_s_mk46",
        "wpn_fps_upg_m4_s_pts",
        "wpn_fps_snp_victor_s_mod0",
        "wpn_fps_sho_sko12_stock",
        "wpn_fps_upg_m4_s_contender",
        "wpn_fps_lmg_hcar_stock",
        "wpn_fps_snp_tti_s_vltor",
        "wpn_fps_ass_flint_s_standard",
    }
    self.nqr.all_stock_adapters = {
        "wpn_fps_upg_m4_s_adapter",
        "wpn_fps_snp_victor_s_adapter",
        "wpn_fps_shot_r870_s_m4",
        "wpn_fps_ass_s552_s_m4",
        "wpn_fps_lmg_m249_s_modern",
        "wpn_upg_ak_s_adapter",
        "wpn_fps_snp_flint_s_adapter",
        "wpn_fps_gre_m32_stock_adapter",
        "wpn_fps_sho_sko12_s_adapter",
        "wpn_fps_smg_shepheard_s_adapter",
        "wpn_fps_sho_supernova_g_adapter",
        "wpn_fps_smg_polymer_s_adapter",
    } for i, k in pairs(self.nqr.all_stock_adapters) do self.parts[k].has_description = true self.parts[k].desc_id = "bm_wp_stock_adapter_desc" end
    self.nqr.all_tube_stocks = {
        "wpn_fps_upg_m4_s_standard",
        "wpn_fps_upg_m4_s_crane",
        "wpn_fps_upg_m4_s_mk46",
        "wpn_fps_upg_m4_s_pts",
        "wpn_fps_snp_victor_s_mod0",
        "wpn_fps_sho_sko12_stock",
        "wpn_fps_upg_m4_s_contender",
        "wpn_fps_lmg_hcar_stock",
        "wpn_fps_snp_tti_s_vltor",
        "wpn_fps_ass_flint_s_standard",
    } for i, k in pairs(self.nqr.all_tube_stocks) do self.parts[k].has_description = true self.parts[k].desc_id = "bm_wp_tube_stock_desc" end
    self.nqr.all_m4_stocks = {
        "wpn_fps_upg_m4_s_adapter",
        "wpn_fps_snp_victor_s_adapter",

        "wpn_fps_upg_m4_s_ubr",
        "wpn_fps_m4_uupg_s_zulu",
        "wpn_fps_smg_olympic_s_adjust",
        "wpn_fps_smg_olympic_s_short",
        "wpn_fps_ass_tecci_s_standard",
        "wpn_fps_m16_s_solid",
        "wpn_fps_ass_contraband_s_standard",
        "wpn_fps_snp_victor_s_hera",
    } table.addto(self.nqr.all_m4_stocks, self.nqr.all_tube_stocks)
    self.nqr.all_m4_foregrips = {
        "wpn_fps_amcar_uupg_fg_amcar",
        "wpn_fps_m4_uupg_fg_rail",
        "wpn_fps_m4_uupg_fg_lr300",
        "wpn_fps_upg_ass_m4_fg_moe",
        "wpn_fps_upg_ass_m4_fg_lvoa",
        "wpn_fps_upg_fg_jp",
        "wpn_fps_upg_fg_smr",
        "wpn_fps_uupg_fg_radian",
        "wpn_fps_m4_upg_fg_mk12",
        "wpn_fps_m16_fg_standard",
        "wpn_fps_m16_fg_vietnam",
        "wpn_fps_m16_fg_railed",
        "wpn_fps_upg_ass_m16_fg_stag",
        "wpn_fps_smg_olympic_fg_olympic",
        "wpn_fps_smg_olympic_fg_railed",
        "wpn_fps_upg_smg_olympic_fg_lr300",
        "wpn_fps_snp_victor_fg_standard",
        "wpn_fps_snp_victor_fg_hera",
        "wpn_fps_snp_victor_fg_hera_covers",
        "wpn_fps_snp_tti_fg_standard",

        "wpn_fps_addon_ris",
        "wpn_nqr_extra3_rail",
        "wpn_fps_gadgets_pos_a_fl2",
        "wpn_fps_gadgets_pos_a_fl3",
    }
    self.nqr.all_m4_lowers = {
        "wpn_fps_m4_lower_reciever",
        "wpn_fps_upg_ass_m4_lower_reciever_core",
        "wpn_fps_m4_uupg_lower_radian",
        "wpn_fps_snp_victor_body_receiver_lower",
        "wpn_fps_snp_victor_body_receiver_lower_hera",
        "wpn_fps_ass_tecci_lower_reciever",
    }
    self.nqr.all_m4_mags = {
        "wpn_fps_upg_m4_m_drum",
        "wpn_fps_upg_m4_m_l5",
        "wpn_fps_upg_m4_m_pmag",
        "wpn_fps_upg_m4_m_quad",
        "wpn_fps_upg_m4_m_straight",
        "wpn_fps_m4_uupg_m_std",
        "wpn_fps_m4_uupg_m_strike",
        "wpn_fps_m4_upg_m_quick",
        "wpn_fps_ass_l85a2_m_emag",
        "wpn_fps_ass_tecci_m_drum",
    }
    self.nqr.all_m4_grips = {
        "wpn_fps_upg_m4_g_hgrip",
        "wpn_fps_upg_m4_g_mgrip",
        "wpn_fps_upg_m4_g_standard",
        "wpn_fps_upg_m4_g_ergo",
        "wpn_fps_upg_m4_g_sniper",
        "wpn_fps_m4_uupg_g_billet",
        "wpn_fps_upg_g_m4_surgeon",
        "wpn_fps_snp_tti_g_grippy",
        "wpn_fps_snp_victor_g_mod3",
        "wpn_fps_ass_tecci_g_standard",
        "wpn_fps_smg_shepheard_g_standard",
        --"wpn_fps_sho_m590_g_standard",
        "wpn_fps_sho_sko12_body_grip",
    }
    self.nqr.all_m4_draghandles = {
        "wpn_fps_m4_uupg_draghandle",
        "wpn_fps_m4_uupg_draghandle_ballos",
        "wpn_fps_m4_uupg_draghandle_core",
        "wpn_fps_m4_uupg_draghandle_radian",
        "wpn_fps_ass_amcar_dh",
        "wpn_fps_snp_victor_dh_standard",
        "wpn_fps_snp_tti_dh_standard",
        "wpn_fps_ass_tecci_dh_standard",
    }
    local m4_collection = {
        "wpn_fps_m4_upper_reciever_round",
        "wpn_fps_m4_upper_reciever_edge",
        "wpn_fps_m4_uupg_upper_radian",
        "wpn_fps_upg_ass_m4_upper_reciever_ballos",
        "wpn_fps_upg_ass_m4_upper_reciever_core",
        "wpn_fps_amcar_uupg_body_upperreciever",
        "wpn_fps_snp_victor_body_receiver_upper",
        "wpn_fps_snp_victor_body_receiver_upper_hera",

        "wpn_fps_amcar_bolt_standard",
        "wpn_fps_m4_bolt_round",
        "wpn_fps_upg_ass_m4_bolt_ballos",
        "wpn_fps_upg_ass_m4_bolt_core",
        "wpn_fps_m4_bolt_edge",

        "wpn_fps_ass_m16_o_handle_sight",
        "wpn_fps_m4_uupg_fg_rail_ext",

        "wpn_fps_upg_ass_m4_b_beowulf",
        "wpn_fps_m4_uupg_b_sd",
        "wpn_fps_para_b_short",
        "wpn_fps_para_b_medium_os3",
        "wpn_fps_para_b_medium",
        "wpn_fps_m4_uupg_b_short_os3",
        "wpn_fps_m4_uupg_b_short",
        "wpn_fps_m4_uupg_b_medium_os2",
        "wpn_fps_m4_uupg_b_medium",
        "wpn_fps_m4_uupg_b_long",
        "wpn_fps_snp_victor_b_standard",

        "wpn_fps_upg_m4_s_adapter",
        "wpn_fps_snp_victor_s_adapter",

        "wpn_fps_upg_m4_s_ubr",
        "wpn_fps_m4_uupg_s_zulu",
        "wpn_fps_smg_olympic_s_adjust",
        "wpn_fps_smg_olympic_s_short",
        "wpn_fps_ass_tecci_s_standard",
        "wpn_fps_m16_s_solid",
        "wpn_fps_ass_contraband_s_standard",
        "wpn_fps_snp_victor_s_hera",

        "wpn_fps_upg_cal_300blk",
        "wpn_fps_upg_a_subfmj",
        "wpn_fps_upg_cal_50beo",
    }
    table.addto(m4_collection, self.nqr.all_m4_stocks)
    table.addto(m4_collection, self.nqr.all_m4_foregrips)
    table.addto(m4_collection, self.nqr.all_m4_lowers)
    table.addto(m4_collection, self.nqr.all_m4_mags)
    table.addto(m4_collection, self.nqr.all_m4_grips)
    table.addto(m4_collection, self.nqr.all_m4_draghandles)
    table.addto(self.wpn_fps_ass_m4.uses_parts, m4_collection)
    table.addto(self.wpn_fps_ass_amcar.uses_parts, m4_collection)
    table.addto(self.wpn_fps_ass_m16.uses_parts, m4_collection)
    table.addto(self.wpn_fps_smg_olympic.uses_parts, m4_collection)
    table.addto(self.wpn_fps_snp_victor.uses_parts, m4_collection)
    table.addto(self.wpn_fps_ass_tecci.uses_parts, self.nqr.all_m4_stocks)
    table.addto(self.wpn_fps_ass_tecci.uses_parts, self.nqr.all_m4_lowers)
    table.addto(self.wpn_fps_ass_tecci.uses_parts, self.nqr.all_m4_mags)
    table.addto(self.wpn_fps_ass_tecci.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_ass_tecci.uses_parts, self.nqr.all_m4_draghandles)
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_m4_stocks)
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_m4_foregrips)
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_m4_draghandles)
    table.addto(self.wpn_fps_ass_contraband.uses_parts, self.nqr.all_m4_stocks)
    table.addto(self.wpn_fps_ass_contraband.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_ass_contraband.uses_parts, self.nqr.all_m4_draghandles)
    self.wpn_fps_ass_m4.override = {
        wpn_fps_m16_fg_standard = { forbids = {
            "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short"
        } },
        wpn_fps_m16_fg_vietnam = { forbids = {
            "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd"
        } },

        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_upg_m4_g_standard") },
    }
    table.addto_dict(self.wpn_fps_ass_m4.override, overrides_gadget_foregrip_parent_thing)
    table.swap(self.wpn_fps_ass_m4.default_blueprint, "wpn_fps_m4_uupg_o_flipup", "wpn_fps_ass_m16_o_handle_sight")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, 1, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, "wpn_fps_ass_m16_os_frontsight")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_ass_m16_os_frontsight")
    table.insert(self.wpn_fps_ass_m4.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_remove_fg")
    table.insert(self.wpn_fps_ass_m4.uses_parts, "wpn_fps_remove_ironsight")

    self.parts.wpn_fps_amcar_uupg_fg_amcar.pcs = {}
    self.parts.wpn_fps_amcar_uupg_fg_amcar.name_id = "bm_wp_fps_amcar_uupg_fg_amcar"
    self.parts.wpn_fps_amcar_uupg_fg_amcar.adds = {}
    self.parts.wpn_fps_amcar_uupg_fg_amcar.forbids = { "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_m4_uupg_b_long", "wpn_fps_m4_uupg_b_medium_os2", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_amcar_uupg_fg_amcar.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.pcs = {}
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.name_id = "bm_wp_amcar_upper"
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.type = "upper_reciever"
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.sightpairs = self.parts.wpn_fps_ass_m16_o_handle_sight.sightpairs
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.adds = {}
    table.addto(self.parts.wpn_fps_amcar_uupg_body_upperreciever.forbids, table.without(self.nqr.all_sights, {"wpn_fps_o_blank"}))
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.visibility = { { objects = { g_draghandle = false } } }
    self.parts.wpn_fps_amcar_uupg_body_upperreciever.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_amcar_dh = deep_clone(self.parts.wpn_fps_amcar_uupg_body_upperreciever)
    self.parts.wpn_fps_ass_amcar_dh.name_id = "bm_wp_amcar_dg"
    self.parts.wpn_fps_ass_amcar_dh.type = "drag_handle"
    self.parts.wpn_fps_ass_amcar_dh.sightpairs = nil
    self.parts.wpn_fps_ass_amcar_dh.forbids = {}
    self.parts.wpn_fps_ass_amcar_dh.override = {}
    self.parts.wpn_fps_ass_amcar_dh.visibility = { { objects = { g_amcar = false } } }
    self.parts.wpn_fps_ass_amcar_dh.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_ass_amcar.regression = "amcar"
    self.wpn_fps_ass_amcar.unit = "units/payday2/weapons/wpn_fps_ass_m4/wpn_fps_ass_m4"
    self.wpn_fps_ass_amcar.animations = {
		reload = "reload",
		fire = "recoil",
		fire_steelsight = "recoil",
		reload_not_empty = "reload_not_empty",
		magazine_empty = "last_recoil",
	}
    self.wpn_fps_ass_amcar.override = {
        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_upg_m4_g_standard") },
        wpn_fps_ass_m16_o_handle_sight = { forbids = table.without(self.parts.wpn_fps_ass_m16_o_handle_sight.forbids, {"wpn_fps_amcar_uupg_body_upperreciever"}) },
        wpn_fps_amcar_uupg_body_upperreciever = { forbids = table.with(self.parts.wpn_fps_amcar_uupg_body_upperreciever.forbids, {"wpn_fps_ass_m16_o_handle_sight"}) },
    }
    --remove forbids of default fg (wpn_fps_amcar_uupg_fg_amcar) or else barrels delete it when returning fg to default
    local amcar_overrides = {
        "wpn_fps_m4_uupg_b_long",
        "wpn_fps_m4_uupg_b_medium",
        "wpn_fps_m4_uupg_b_medium_os2",
        "wpn_fps_m4_uupg_b_short",
        "wpn_fps_m4_uupg_b_short_os3",
        "wpn_fps_para_b_medium",
        "wpn_fps_para_b_medium_os3",
        "wpn_fps_para_b_short",
    }
    for i, k in pairs(amcar_overrides) do
        --self.wpn_fps_ass_amcar.override[k] = { forbids = deep_clone(self.parts[k] and (self.parts[k].forbids or {}) or {}) }
        --table.delete(self.wpn_fps_ass_amcar.override[k].forbids, "wpn_fps_amcar_uupg_fg_amcar")
        self.wpn_fps_ass_amcar.override[k] = { forbids = table.without(self.parts[k] and (self.parts[k].forbids or {}) or {}, {"wpn_fps_amcar_uupg_fg_amcar"}) }
    end
    table.addto_dict(self.wpn_fps_ass_amcar.override, overrides_gadget_foregrip_parent_thing)
    self.wpn_fps_ass_amcar.adds = {}
    table.swap(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_m4_uupg_b_medium", "wpn_fps_m4_uupg_b_short")
    table.swap(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_upg_m4_m_straight", "wpn_fps_m4_uupg_m_std")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_ass_m16_os_frontsight")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_ass_m16_os_frontsight")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_ass_amcar_dh")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, 1, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_amcar.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_amcar.uses_parts, "wpn_fps_upg_blankcal_556")

    self.parts.wpn_fps_ass_m16_b_legend.pcs = {}
    self.parts.wpn_fps_ass_m16_b_legend.type = "barrel_ext"
    self.parts.wpn_fps_ass_m16_b_legend.perks = { "silencer" }
    self.parts.wpn_fps_ass_m16_b_legend.sound_switch = { suppressed = "suppressed_c" }
    self.parts.wpn_fps_ass_m16_b_legend.override = { wpn_fps_ass_m16_os_frontsight = { unit = fantom_unit } }
    self.parts.wpn_fps_ass_m16_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 14.5 }
    self.parts.wpn_fps_m16_s_solid.pcs = {}
    self.parts.wpn_fps_m16_s_solid.name_id = "bm_wp_fps_m16_s_solid"
    self.parts.wpn_fps_m16_s_solid.stats = { concealment = 0, weight = 3, length = 9, shouldered = true }
    self.parts.wpn_fps_ass_m16_s_legend.pcs = {}
    self.parts.wpn_fps_ass_m16_s_legend.stats = { concealment = 0, weight = 0, length = 11.09, shouldered = true }
    self.parts.wpn_fps_m16_fg_standard.pcs = {}
    self.parts.wpn_fps_m16_fg_standard.adds = {}
    self.parts.wpn_fps_m16_fg_standard.forbids = { "wpn_fps_m4_uupg_b_medium", "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_m16_fg_standard.name_id = "bm_wp_fps_m16_fg_standard"
    self.parts.wpn_fps_m16_fg_standard.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_m16_fg_vietnam.adds = {}
    self.parts.wpn_fps_m16_fg_vietnam.forbids = { "wpn_fps_m4_uupg_b_medium", "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_m16_fg_vietnam.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_m16_fg_railed.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_m16_fg_railed.adds = {}
    self.parts.wpn_fps_m16_fg_railed.forbids = { "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short" }
    self.parts.wpn_fps_m16_fg_railed.override = {
        wpn_fps_fold_ironsight = {
            unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down_hera",
            third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
            stats = { concealment = 2, weight = 0 },
        },
        wpn_fps_snp_victor_o_standard = {
            unit = self.parts.wpn_fps_snp_victor_o_hera.unit,
            third_unit = self.parts.wpn_fps_snp_victor_o_hera.third_unit,
            stats = { concealment = 2, weight = 0 },
        },
    }
    self.parts.wpn_fps_m16_fg_railed.stats = { concealment = 0, weight = 5 }
    self.parts.wpn_fps_upg_ass_m16_fg_stag.rails = { "top" }
    self.parts.wpn_fps_upg_ass_m16_fg_stag.adds = {}
    self.parts.wpn_fps_upg_ass_m16_fg_stag.forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_upg_ass_m16_fg_stag.override = nil
    self.parts.wpn_fps_upg_ass_m16_fg_stag.stats = { concealment = 0, weight = 5 }
    self.parts.wpn_fps_ass_m16_fg_legend.pcs = {}
    self.parts.wpn_fps_ass_m16_fg_legend.type = "foregrip"
    self.parts.wpn_fps_ass_m16_fg_legend.stats = { concealment = 0, weight = 5 }
    self.wpn_fps_ass_m16.regression = "m16"
    self.wpn_fps_ass_m16.unit = "units/payday2/weapons/wpn_fps_ass_m4/wpn_fps_ass_m4"
    self.wpn_fps_ass_m16.animations = {
		reload = "reload",
		fire = "recoil",
		fire_steelsight = "recoil",
		reload_not_empty = "reload_not_empty",
		magazine_empty = "last_recoil",
	}
    self.wpn_fps_ass_m16.override = {
        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_upg_m4_g_standard") },
    }
    --remove forbids of default fg (wpn_fps_m16_fg_standard) or else barrels delete it when returning fg to default
    local m16_overrides = {
        "wpn_fps_m4_uupg_b_medium",
        "wpn_fps_m4_uupg_b_short",
        "wpn_fps_m4_uupg_b_short_os3",
        "wpn_fps_para_b_medium",
        "wpn_fps_para_b_medium_os3",
        "wpn_fps_para_b_short",
    }
    for i, k in pairs(m16_overrides) do
        --self.wpn_fps_ass_m16.override[k] = { forbids = deep_clone(self.parts[k] and (self.parts[k].forbids or {}) or {}) }
        --table.delete(self.wpn_fps_ass_m16.override[k].forbids, "wpn_fps_m16_fg_standard")
        self.wpn_fps_ass_m16.override[k] = { forbids = table.without(self.parts[k] and (self.parts[k].forbids or {}) or {}, {"wpn_fps_m16_fg_standard"}) }
    end
    table.addto_dict(self.wpn_fps_ass_m16.override, overrides_gadget_foregrip_parent_thing)
    self.parts.wpn_fps_ass_m16_os_frontsight2 = deep_clone(self.parts.wpn_fps_ass_m16_os_frontsight)
    for i, k in pairs(self.parts.wpn_fps_ass_m16_os_frontsight2.override) do table.insert(k.forbids, "wpn_fps_m4_uupg_b_medium") end
    table.swap(self.wpn_fps_ass_m16.default_blueprint, "wpn_fps_m4_uupg_b_medium", "wpn_fps_m4_uupg_b_long")
    table.swap(self.wpn_fps_ass_m16.default_blueprint, "wpn_fps_upg_m4_m_straight", "wpn_fps_m4_uupg_m_std")
    table.insert(self.wpn_fps_ass_m16.default_blueprint, "wpn_fps_ass_m16_os_frontsight2")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_ass_m16_os_frontsight2")
    table.insert(self.wpn_fps_ass_m16.default_blueprint, 1, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_ass_m16.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_m16.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m16.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_m16.uses_parts, "wpn_fps_remove_ironsight")

    self.parts.wpn_fps_smg_olympic_s_adjust.pcs = {}
    self.parts.wpn_fps_smg_olympic_s_adjust.name_id = "bm_wp_fps_smg_olympic_s_adjust"
    self.parts.wpn_fps_smg_olympic_s_adjust.stats = { concealment = 0, weight = 4, length = 7, shouldered = true }
    self.parts.wpn_fps_smg_olympic_s_short.has_description = true
    self.parts.wpn_fps_smg_olympic_s_short.desc_id = "bm_wp_not_a_stock_desc"
    self.parts.wpn_fps_smg_olympic_s_short.stats = { concealment = 0, weight = 2, length = 6 }
    self.parts.wpn_fps_smg_olympic_fg_olympic.pcs = {}
    self.parts.wpn_fps_smg_olympic_fg_olympic.adds = {}
    self.parts.wpn_fps_smg_olympic_fg_olympic.forbids = { "wpn_fps_gadgets_pos_a_fl2", "wpn_fps_gadgets_pos_a_fl3" }
    self.parts.wpn_fps_smg_olympic_fg_olympic.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_smg_olympic_fg_railed.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_smg_olympic_fg_railed.adds = {}
    self.parts.wpn_fps_smg_olympic_fg_railed.forbids = { "wpn_fps_gadgets_pos_a_fl2", "wpn_fps_gadgets_pos_a_fl3" }
    self.parts.wpn_fps_smg_olympic_fg_railed.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_smg_olympic_fg_lr300.rails = { "side" }
    self.parts.wpn_fps_upg_smg_olympic_fg_lr300.adds = {}
    self.parts.wpn_fps_upg_smg_olympic_fg_lr300.forbids = { "wpn_fps_gadgets_pos_a_fl2", "wpn_fps_gadgets_pos_a_fl3" }
    self.parts.wpn_fps_upg_smg_olympic_fg_lr300.stats = { concealment = 0, weight = 2 }
    self.wpn_fps_smg_olympic.regression = "olympic"
    self.wpn_fps_smg_olympic.unit = "units/payday2/weapons/wpn_fps_ass_m4/wpn_fps_ass_m4"
    self.wpn_fps_smg_olympic.animations = {
		reload = "reload",
		fire = "recoil",
		fire_steelsight = "recoil",
		reload_not_empty = "reload_not_empty",
		magazine_empty = "last_recoil",
	}
    self.wpn_fps_smg_olympic.override = {
        wpn_fps_amcar_uupg_fg_amcar = { forbids = { "wpn_fps_gadgets_pos_a_fl3" } },
        wpn_fps_m4_uupg_fg_rail = { forbids = { "wpn_fps_gadgets_pos_a_fl3" } },
        wpn_fps_m4_uupg_fg_lr300 = { forbids = { "wpn_fps_gadgets_pos_a_fl3" } },
        wpn_fps_upg_ass_m4_fg_moe = { forbids = { "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_gadgets_pos_a_fl3" } },
        wpn_fps_upg_ass_m4_fg_lvoa = { forbids = {} },
        wpn_fps_upg_fg_jp = { forbids = {} },
        wpn_fps_upg_fg_smr = { forbids = {} },
        wpn_fps_uupg_fg_radian = { forbids = {} },

        wpn_fps_para_b_short = { forbids = deep_clone(self.parts.wpn_fps_para_b_short.forbids) },

        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_upg_m4_g_standard") },
    }
    table.insert(self.wpn_fps_smg_olympic.override.wpn_fps_para_b_short.forbids, "wpn_fps_m4_uupg_fg_rail")
    table.addto_dict(self.wpn_fps_smg_olympic.override, overrides_gadget_foregrip_parent_thing)
    self.parts.wpn_fps_ass_m16_os_frontsight3 = deep_clone(self.parts.wpn_fps_ass_m16_os_frontsight)
    self.parts.wpn_fps_ass_m16_os_frontsight3.override.wpn_fps_m4_uupg_fg_rail = nil
    table.swap(self.wpn_fps_smg_olympic.default_blueprint, "wpn_fps_m4_uupg_b_short", "wpn_fps_para_b_short")
    table.swap(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_m4_uupg_b_short", "wpn_fps_para_b_short")
    table.insert(self.wpn_fps_smg_olympic.default_blueprint, "wpn_fps_ass_m16_os_frontsight3")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_ass_m16_os_frontsight3")
    table.insert(self.wpn_fps_smg_olympic.default_blueprint, 1, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_smg_olympic.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_olympic.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_olympic.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_smg_olympic.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_smg_olympic.uses_parts, self.nqr.all_angled_sights)

    --self.wpn_fps_snp_victor.sightheight_mod = self.wpn_fps_ass_m16.sightheight_mod --this has to be down below
    self.parts.wpn_fps_snp_victor_b_standard.stats = { concealment = 0, weight = 15, barrel_length = 14.5 }
    self.parts.wpn_fps_snp_victor_body_receiver_lower.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_body_receiver_lower.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_body_receiver_lower.pcs = {}
    self.parts.wpn_fps_snp_victor_body_receiver_lower.name_id = "bm_wp_fps_snp_victor_body_receiver_lower"
    self.parts.wpn_fps_snp_victor_body_receiver_lower.type = "lower_reciever"
    self.parts.wpn_fps_snp_victor_body_receiver_lower.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_snp_victor_body_receiver_upper.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_body_receiver_upper.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_body_receiver_upper.pcs = {}
    self.parts.wpn_fps_snp_victor_body_receiver_upper.name_id = "bm_wp_fps_snp_victor_body_receiver_upper"
    self.parts.wpn_fps_snp_victor_body_receiver_upper.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_snp_victor_body_receiver_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_victor_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_victor_bolt_standard.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_bolt_standard.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_bolt_standard.stats = { concealment = 0, weight = 0 } --todo
    self.parts.wpn_fps_snp_victor_dh_standard.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_dh_standard.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_dh_standard.pcs = {}
    self.parts.wpn_fps_snp_victor_dh_standard.name_id = "bm_wp_victor_dh_standard"
    self.parts.wpn_fps_snp_victor_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_victor_dhs_switch.a_obj = "a_dh"
    self.parts.wpn_fps_snp_victor_dhs_switch.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_victor_g_mod3.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_snp_victor_ns_standard.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_ns_standard.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_ns_standard.pcs = {}
    self.parts.wpn_fps_snp_victor_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,0,0,1,0} }
    self.parts.wpn_fps_snp_victor_ns_omega.stats = { concealment = 14, weight = 5, length = 7, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_snp_victor_o_down.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_victor_s_adapter.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_s_adapter.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_s_adapter.pcs = {}
    self.parts.wpn_fps_snp_victor_s_adapter.type = "stock"
    self.parts.wpn_fps_snp_victor_s_adapter.stats = { concealment = 0, weight = 2, length = 6 }
    self.parts.wpn_fps_snp_victor_s_mod0.type = "stock_addon"
    self.parts.wpn_fps_snp_victor_s_mod0.adds_type = nil
    self.parts.wpn_fps_snp_victor_s_mod0.stats = { concealment = 12, weight = 3, length = 9.07, shouldered = true }
    self.parts.wpn_fps_snp_victor_fg_standard.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_fg_standard.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_fg_standard.pcs = {}
    self.parts.wpn_fps_snp_victor_fg_standard.name_id = "bm_wp_fps_snp_victor_fg_standard"
    self.parts.wpn_fps_snp_victor_fg_standard.rails = { "top" }
    self.parts.wpn_fps_snp_victor_fg_standard.adds = {}
    self.parts.wpn_fps_snp_victor_fg_standard.forbids = { "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_snp_victor_fg_standard.stats = { concealment = 0, weight = 6 }
    self.parts.wpn_fps_snp_victor_vg_hera.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_vg_hera.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_vg_hera.pcs = {}
    self.parts.wpn_fps_snp_victor_vg_hera.name_id = "bm_wp_fps_snp_victor_vg_hera"
    self.parts.wpn_fps_snp_victor_vg_hera.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_snp_victor_m_1.texture_bundle_folder = "savi"
    self.parts.wpn_fps_snp_victor_m_1.dlc = "victor_mods_pack_1"
    self.parts.wpn_fps_snp_victor_m_1.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 20, [".300 BLK"] = 20, [".50 Beo"] = 7 } }
    self.parts.wpn_fps_snp_victor_m_2.stats = { concealment = 0, weight = 0 } --todo
    self.parts.wpn_fps_snp_victor_fg_hera = {
        texture_bundle_folder = "savi",
        dlc = "victor_mods_pack_2",
        a_obj = "a_fg",
        type = "foregrip",
        name_id = "bm_wp_victor_fg_hera",
        unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_fg_hera",
		third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_fg_hera",
        visibility = { { objects = { g_cover = false } } },
        pcs = {},
        rails = { "top", "side", "bottom" },
        adds = {},
        forbids = { "wpn_fps_gadgets_pos_a_fl3", "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" },
        override = {
            wpn_fps_fold_ironsight = {
                unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_o_down_hera",
                third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_o_hera",
                stats = { concealment = 2, weight = 0 },
            },
            wpn_fps_snp_victor_o_standard = {
                unit = self.parts.wpn_fps_snp_victor_o_hera.unit,
                third_unit = self.parts.wpn_fps_snp_victor_o_hera.third_unit,
                stats = { concealment = 2, weight = 0 },
            },
        },
        stats = { concealment = 0, weight = 6 },
    }
    self.parts.wpn_fps_snp_victor_fg_hera_covers = {
        texture_bundle_folder = "savi",
        dlc = "victor_mods_pack_2",
        a_obj = "a_fg",
        type = "wep_cos",
        name_id = "bm_wp_victor_fg_hera_covers",
        unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_fg_hera",
		third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_fg_hera",
        visibility = { { objects = { g_g = false } } },
        forbids = { "wpn_fps_gadgets_pos_a_fl2" },
        adds = {}, override = {}, stats = {},
        pcs = {},
    }
    self.parts.wpn_fps_snp_victor_b_sbr = deep_clone(self.parts.wpn_fps_snp_victor_b_standard)
    self.parts.wpn_fps_snp_victor_b_sbr.pcs = {}
    self.parts.wpn_fps_snp_victor_b_sbr.name_id = "bm_wp_victor_b_sbr"
    self.parts.wpn_fps_snp_victor_b_sbr.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_b_sbr"
    self.parts.wpn_fps_snp_victor_b_sbr.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_b_sbr"
    self.parts.wpn_fps_snp_victor_b_sbr.stats = { concealment = 0, weight = 15, barrel_length = 10.5 }
    self.parts.wpn_fps_snp_victor_ns_hera_supp = deep_clone(self.parts.wpn_fps_snp_victor_ns_omega)
    self.parts.wpn_fps_snp_victor_ns_hera_supp.name_id = "bm_wp_victor_ns_hera_supp"
    self.parts.wpn_fps_snp_victor_ns_hera_supp.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_ns_hera_supp"
    self.parts.wpn_fps_snp_victor_ns_hera_supp.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_ns_hera_supp"
    self.parts.wpn_fps_snp_victor_ns_hera_supp.stats = deep_clone(self.nqr.sps_stats.medium2)
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle = deep_clone(self.parts.wpn_fps_snp_victor_ns_standard)
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.pcs = {}
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.name_id = "bm_wp_victor_ns_hera_muzzle"
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_ns_hera_muzzle"
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_ns_hera_muzzle"
    self.parts.wpn_fps_snp_victor_ns_hera_muzzle.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_snp_victor_s_hera = deep_clone(self.parts.wpn_fps_snp_victor_s_mod0)
    self.parts.wpn_fps_snp_victor_s_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_s_hera.name_id = "bm_wp_victor_s_hera"
    self.parts.wpn_fps_snp_victor_s_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_s_hera"
    self.parts.wpn_fps_snp_victor_s_hera.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_s_hera"
    self.parts.wpn_fps_snp_victor_s_hera.type = "stock"
    self.parts.wpn_fps_snp_victor_s_hera.override = {
        wpn_fps_upg_m4_g_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } },
        wpn_fps_snp_victor_g_mod3 = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } },
        wpn_fps_ass_tecci_g_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } },
    }
    self.parts.wpn_fps_snp_victor_s_hera.stats = { concealment = 0, weight = 5, length = 11, shouldered = true }
    self.parts.wpn_fps_snp_victor_bolt_hera = deep_clone(self.parts.wpn_fps_snp_victor_bolt_standard)
    self.parts.wpn_fps_snp_victor_bolt_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_bolt_hera.pcs = {}
    self.parts.wpn_fps_snp_victor_bolt_hera.name_id = "bm_wp_victor_bolt_hera"
    self.parts.wpn_fps_snp_victor_bolt_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_bolt_hera"
    self.parts.wpn_fps_snp_victor_dh_hera = deep_clone(self.parts.wpn_fps_snp_victor_dh_standard)
    self.parts.wpn_fps_snp_victor_dh_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_dh_hera.name_id = "bm_wp_victor_dh_hera"
    self.parts.wpn_fps_snp_victor_dh_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_dh_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_upper_hera = deep_clone(self.parts.wpn_fps_snp_victor_body_receiver_upper)
    self.parts.wpn_fps_snp_victor_body_receiver_upper_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_body_receiver_upper_hera.name_id = "bm_wp_victor_upper_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_upper_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_body_receiver_upper_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_upper_hera.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_body_receiver_upper_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_lower_hera = deep_clone(self.parts.wpn_fps_snp_victor_body_receiver_lower)
    self.parts.wpn_fps_snp_victor_body_receiver_lower_hera.dlc = "victor_mods_pack_2"
    self.parts.wpn_fps_snp_victor_body_receiver_lower_hera.name_id = "bm_wp_victor_lower_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_lower_hera.unit = "units/pd2_dlc_savi/weapons/wpn_fps_snp_victor_pts/wpn_fps_snp_victor_body_receiver_lower_hera"
    self.parts.wpn_fps_snp_victor_body_receiver_lower_hera.third_unit = "units/pd2_dlc_savi/weapons/wpn_third_snp_victor_pts/wpn_third_snp_victor_body_receiver_lower_hera"
    self.wpn_fps_snp_victor.regression = "victor"
    self.wpn_fps_snp_victor.unit = "units/payday2/weapons/wpn_fps_ass_m4/wpn_fps_ass_m4"
    self.wpn_fps_snp_victor.animations = {
		reload = "reload",
		fire = "recoil",
		fire_steelsight = "recoil",
		reload_not_empty = "reload_not_empty",
		magazine_empty = "last_recoil",
	}
    self.wpn_fps_snp_victor.adds = {}
    self.wpn_fps_snp_victor.override = {
        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_snp_victor_g_mod3") },
        wpn_fps_fold_ironsight = {
            unit = self.parts.wpn_fps_snp_victor_o_down.unit,
            third_unit = self.parts.wpn_fps_snp_victor_o_down.third_unit,
            stats = { concealment = 2, weight = 0 },
        },
    }
    for i, k in pairs(self.nqr.all_sps) do self.wpn_fps_snp_victor.override[k] = { sound_switch = deep_clone(self.parts.wpn_fps_snp_victor_ns_hera_supp.sound_switch) } end
    table.addto_dict(self.wpn_fps_snp_victor.override, overrides_gadget_foregrip_parent_thing)
    table.delete(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_vg_hera") --todo
    table.delete(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_m_2")
    table.delete(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_o_down")
    table.swap(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_m_1", "wpn_fps_upg_m4_m_pmag")
    table.swap(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_bolt_standard", "wpn_fps_upg_ass_m4_bolt_ballos")
    table.swap(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_victor_o_standard")
    table.swap(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_upg_m4_s_standard", "wpn_fps_snp_victor_s_mod0")
    table.swap(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_upg_m4_g_standard", "wpn_fps_snp_victor_g_mod3")
    table.insert(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_snp_victor.default_blueprint, 1, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_upper_lock_sights")
    table.insert(self.wpn_fps_snp_victor.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_snp_victor.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_victor.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_b_sbr")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_ns_hera_supp")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_s_hera")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_bolt_hera")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_dh_hera")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_body_receiver_upper_hera")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_snp_victor_body_receiver_lower_hera")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_snp_victor.uses_parts, "wpn_fps_fold_ironsight")
    table.addto(self.wpn_fps_snp_victor.uses_parts, self.nqr.all_bxs_sbr)
--------

--------AK
    local ak_foregrips_full = {
        "wpn_fps_upg_fg_midwest",
        "wpn_fps_upg_ak_fg_krebs",
        "wpn_fps_upg_ak_fg_trax",
        "wpn_fps_upg_ak_fg_zenitco",
        "wpn_fps_lmg_rpk_fg_standard",
        "wpn_fps_smg_vityaz_fg_standard",
    }
    local ak_foregrips = {
        "wpn_upg_ak_fg_standard",
        "wpn_upg_ak_fg_standard_gold",
        "wpn_fps_upg_fg_midwest",
        "wpn_fps_upg_ak_fg_tapco",
        "wpn_fps_upg_ak_fg_krebs",
        "wpn_fps_upg_ak_fg_trax",
        "wpn_fps_upg_ak_fg_zenitco",
        "wpn_fps_lmg_rpk_fg_standard",
        "wpn_fps_lmg_rpk_fg_wood",
        "wpn_fps_smg_vityaz_fg_standard",
        "wpn_upg_saiga_fg_standard",
        "wpn_upg_saiga_fg_lowerrail",
        "wpn_upg_saiga_fg_lowerrail_short",
        "wpn_fps_sho_saiga_fg_holy",
        "wpn_upg_saiga_fg_octa",
    }
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_ass_74_b_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_ass_74_body_upperreceiver")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_upg_ak_ns_ak105")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_ass_74_b_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_ass_74_body_upperreceiver")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_upg_ak_ns_ak105")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ass_74_b_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_b_draco")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_b_ak105")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ass_ak_b_zastava")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_m_quad")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_m_quick")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_m_uspalm")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_s_skfoldable")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_s_psl")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_fg_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_fg_combo2")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_fg_midwest")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_fg_tapco")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_fg_krebs")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_fg_trax")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_fg_zenitco")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_body_upperreceiver_zenitco")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_ak_ns_ak105")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_o_ak_scopemount")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_upg_ak_ns_ak105")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_upg_ak_s_skfoldable")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_upg_ak_s_psl")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_upg_ak_s_folding")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_upg_ak_s_solidstock")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_upg_ak_g_standard")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_upg_o_ak_scopemount") --todo
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_upg_ak_g_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_upg_ak_g_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_upg_ak_g_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_upg_ak_m_quad")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_upg_ak_m_quick")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_upg_ak_m_uspalm")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_upg_ak_fg_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_upg_ak_fg_tapco")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_74_body_upperreceiver")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_upg_cal_762x39")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_upg_cal_9x39")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_upg_cal_762x39")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_upg_cal_762x39")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_upg_cal_762x39")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_upg_cal_545x39")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_upg_cal_545x39")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_upg_cal_545x39")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_upg_cal_545x39")
    self.parts.wpn_fps_ass_74_b_standard.pcs = {}
    self.parts.wpn_fps_ass_74_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.3, md_code = {0,1,0,1,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_upg_ak_b_draco.override = {}
    self.parts.wpn_fps_upg_ak_b_draco.stats = { concealment = 0, weight = 0, barrel_length = 12.2 }
    self.parts.wpn_fps_upg_ak_b_ak105.stats = { concealment = 0, weight = 0, barrel_length = 12.4, md_code = {0,1,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_upg_ass_ak_b_zastava.stats = { concealment = 0, weight = 0, barrel_length = 23.6, md_code = {0,3,0,0,0}, md_bulk = {2, 2} } --not_sure
    self.parts.wpn_fps_ass_74_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_upg_ak_ns_ak105.pcs = {}
    self.parts.wpn_fps_upg_ak_ns_ak105.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_upg_ak_ns_zenitco.forbids = {} --ovk_pls
    self.parts.wpn_fps_upg_ak_ns_zenitco.stats = { concealment = 3, weight = 2, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_ak_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ak_body_lowerreceiver.sub_type = "ironsight"
    self.parts.wpn_fps_ass_ak_body_lowerreceiver.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_ass_74_body_upperreceiver.pcs = {}
    self.parts.wpn_fps_ass_74_body_upperreceiver.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_ak_body_upperreceiver_zenitco.forbids = { "wpn_fps_upg_o_ak_scopemount", "wpn_fps_smg_coal_o_scopemount_standard" } --ovk_pls
    self.parts.wpn_fps_upg_ak_body_upperreceiver_zenitco.stats = { concealment = 0, weight = 3, sightheight = 0 } --0.3
    self.parts.wpn_fps_ass_74_m_standard.pcs = {}
    self.parts.wpn_fps_ass_74_m_standard.name_id = "bm_wp_fps_ass_74_m_standard"
    self.parts.wpn_fps_ass_74_m_standard.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.45x39"] = 30, ["7.62x39"] = 30 } }
    self.parts.wpn_fps_upg_ak_m_quad.override = { wpn_upg_ak_s_folding = { stats = table.copy_append(self.parts.wpn_upg_ak_s_folding.stats, { shoulderable = false }), desc_id = "bm_wp_stock_not_foldable_desc" } }
    self.parts.wpn_fps_upg_ak_m_quad.stats = { concealment = 17, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["5.45x39"] = 60, ["7.62x39"] = 60 }, retention = false }
    self.parts.wpn_fps_upg_ak_m_quick.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.45x39"] = 30, ["7.62x39"] = 30 } }
    self.parts.wpn_fps_upg_ak_m_uspalm.stats = { concealment = 9, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.45x39"] = 30, ["7.62x39"] = 30 } }
    self.parts.wpn_upg_ak_g_standard.pcs = {}
    self.parts.wpn_upg_ak_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_g_hgrip.forbids = {}
    self.parts.wpn_fps_upg_ak_g_hgrip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_g_pgrip.forbids = {}
    self.parts.wpn_fps_upg_ak_g_pgrip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_g_rk3.forbids = {}
    self.parts.wpn_fps_upg_ak_g_rk3.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_g_wgrip.forbids = {}
    self.parts.wpn_fps_upg_ak_g_wgrip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_upg_ak_g_legend.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_upg_ak_fg_standard.pcs = {}
    self.parts.wpn_upg_ak_fg_standard.override = {}
    self.parts.wpn_upg_ak_fg_standard.visibility = { { objects = { g_upperhandguard = false } } }
    self.parts.wpn_upg_ak_fg_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_upg_ak_gb_standard = deep_clone(self.parts.wpn_upg_ak_fg_standard)
    self.parts.wpn_upg_ak_gb_standard.name_id = "bm_wp_ak_gb_standard"
    self.parts.wpn_upg_ak_gb_standard.type = "f_gasblock"
    self.parts.wpn_upg_ak_gb_standard.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_upg_ak_gb_standard.visibility = { { objects = { g_lowerhandguard = false } } }
    self.parts.wpn_upg_ak_gb_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_upg_ak_fg_combo2.type = "f_gasblock"
    self.parts.wpn_upg_ak_fg_combo2.rails = { "top" }
    self.parts.wpn_upg_ak_fg_combo2.needs_sight_pos = true
    self.parts.wpn_upg_ak_fg_combo2.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_upg_ak_fg_combo2.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_upg_ak_fg_combo2.visibility = { { objects = { g_lowerhandguard = false } } }
    self.parts.wpn_upg_ak_fg_combo2.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_upg_ak_fg_combo3.pcs = nil
    self.parts.wpn_fps_upg_fg_midwest.rails = { "side", "bottom" }
    self.parts.wpn_fps_upg_fg_midwest.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_upg_ak_fg_legend.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_fg_tapco.visibility = { { objects = { g_upperrail = false } } }
    self.parts.wpn_fps_upg_ak_fg_tapco.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_ak_fg_krebs.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_upg_ak_fg_krebs.needs_sight_pos = true
    self.parts.wpn_fps_upg_ak_fg_krebs.forbids = {}
    self.parts.wpn_fps_upg_ak_fg_krebs.override = {} --todo a_o
    self.parts.wpn_fps_upg_ak_fg_krebs.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_upg_ak_fg_trax.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_upg_ak_fg_trax.needs_sight_pos = true
    self.parts.wpn_fps_upg_ak_fg_trax.forbids = {}
    self.parts.wpn_fps_upg_ak_fg_trax.override = {} --todo a_o
    self.parts.wpn_fps_upg_ak_fg_trax.stats = { concealment = 0, weight = 5 }
    self.parts.wpn_fps_upg_ak_fg_zenitco.rails = { "top" }
    self.parts.wpn_fps_upg_ak_fg_zenitco.needs_sight_pos = true
    self.parts.wpn_fps_upg_ak_fg_zenitco.adds = {}
    self.parts.wpn_fps_upg_ak_fg_zenitco.forbids = { "wpn_fps_upg_ak_b_draco" }
    self.parts.wpn_fps_upg_ak_fg_zenitco.override = { wpn_fps_upg_ak_body_upperreceiver_zenitco = { override = { wpn_fps_o_pos_zenitco = { adds = {} } } } }
    self.parts.wpn_fps_upg_ak_fg_zenitco.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_upg_ak_s_adapter.pcs = {}
    self.parts.wpn_upg_ak_s_adapter.type = "stock"
    self.parts.wpn_upg_ak_s_adapter.adds = {}
    self.parts.wpn_upg_ak_s_adapter.stats = { concealment = 0, weight = 2, length = 7 }
    self.parts.wpn_upg_ak_s_folding.pcs = {}
    self.parts.wpn_upg_ak_s_folding.name_id = "bm_wp_upg_ak_s_folding"
    self.parts.wpn_upg_ak_s_folding.adds = {}
    self.parts.wpn_upg_ak_s_folding.stats = { concealment = 0, weight = 4, length = 9, shouldered = true, shoulderable = true }
    self.parts.wpn_upg_ak_s_skfoldable.pcs = {}
    self.parts.wpn_upg_ak_s_skfoldable.name_id = "bm_wp_upg_ak_s_skfoldable"
    self.parts.wpn_upg_ak_s_skfoldable.adds = {}
    self.parts.wpn_upg_ak_s_skfoldable.stats = { concealment = 0, weight = 3, length = 8, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_upg_ak_s_solidstock.adds = {}
    self.parts.wpn_fps_upg_ak_s_solidstock.stats = { concealment = 0, weight = 4, length = 8, shouldered = true }
    self.parts.wpn_fps_upg_ak_s_zenitco.forbids = {} --ovk_pls
    self.parts.wpn_fps_upg_ak_s_zenitco.stats = { concealment = 0, weight = 5, length = 9, shouldered = true, shoulderable = true, cheek = 1 }
    self.parts.wpn_upg_ak_s_psl.forbids = {
        "wpn_fps_upg_ak_g_hgrip",
        "wpn_fps_upg_ak_g_wgrip",
        "wpn_fps_upg_ak_g_pgrip",
        "wpn_fps_upg_ak_g_rk3",
        "wpn_fps_ass_flint_g_standard",
        "wpn_fps_smg_coal_g_standard",
        "wpn_fps_smg_vityaz_g_standard",
        "wpn_fps_ass_groza_g_standard",
    }
    self.parts.wpn_upg_ak_s_psl.override = {}
    self.parts.wpn_upg_ak_s_psl.override.wpn_upg_ak_g_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } }
    self.parts.wpn_upg_ak_s_psl.override.wpn_fps_smg_coal_g_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } }
    self.parts.wpn_upg_ak_s_psl.stats = { concealment = 0, weight = 6, length = 8, shouldered = true }
    self.parts.wpn_upg_ak_s_legend.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_upg_ak_fl_legend.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_o_ak_scopemount.depends_on = nil
    self.parts.wpn_fps_upg_o_ak_scopemount.rails = { "top" }
    self.parts.wpn_fps_upg_o_ak_scopemount.forbids = { "wpn_fps_upg_ak_body_upperreceiver_zenitco" }
    self.parts.wpn_fps_upg_o_ak_scopemount.override = { wpn_fps_o_pos_a_o_sm = { adds = {} } }
    self.parts.wpn_fps_upg_o_ak_scopemount.stats = { concealment = 0, weight = 2, sightheight = 1.6 }
    self.parts.wpn_fps_ak_extra_ris.pcs = {}
    self.parts.wpn_fps_ak_extra_ris.name_id = "bm_wp_ak_extra_ris"
    self.parts.wpn_fps_ak_extra_ris.type = "extra4"
    self.parts.wpn_fps_ak_extra_ris.adds = {}
    self.parts.wpn_fps_ak_extra_ris.override = {
        --wpn_fps_o_pos_fg = { forbids = deep_clone(self.nqr.all_optics) },
        --wpn_fps_upg_fg_midwest = { override = { wpn_fps_extra_lock_sights = { forbids = {} } } },
        --wpn_fps_upg_fg_midwest = { forbids = {} },
        --wpn_fps_extra_lock_sights = { forbids = {} },
        --wpn_fps_o_pos_fg = { forbids = deep_clone(self.nqr.all_optics) },
        --wpn_fps_remove_gb = { forbids = {} },
    }
    self.parts.wpn_fps_ak_extra_ris.stats = { concealment = 1, weight = 1 }
    self.parts.wpn_fps_upg_ak_dh_zenitco.forbids = {} --ovk_pls
    self.parts.wpn_fps_upg_ak_dh_zenitco.stats = { concealment = 1, weight = 1 }
    self.wpn_fps_ass_74.adds = {}
    self.wpn_fps_ass_74.override = {
        --wpn_fps_o_pos_a_o_sm = { adds = { "wpn_fps_extra_lock_sights" } },
        --wpn_fps_o_pos_fg = { adds = { "wpn_fps_fg_lock_sights" } },
        --wpn_fps_o_pos_fg = { forbids = deep_clone(self.nqr.all_sights) },
        --wpn_fps_o_pos_zenitco = { adds = { "wpn_fps_upper_lock_sights" } },
        --wpn_fps_o_blank = { override = {} },
    }
    for i, k in pairs({} or self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.wpn_fps_ass_74.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.wpn_fps_ass_74.override[k] = { a_obj = "a_o_sm" }
        end
    end
    table.deletefrom(self.wpn_fps_ass_74.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_74.default_blueprint, "wpn_upg_ak_g_standard")
    table.insert(self.wpn_fps_ass_74.default_blueprint, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_ass_74.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_74.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_74.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ass_74_m_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_ak_s_skfoldable")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ak_extra_ris")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_o_pos_zenitco")
    table.addto(self.wpn_fps_ass_74.uses_parts, self.nqr.all_tube_stocks)

    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ass_akm_b_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_ak_m_akm")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ass_akm_b_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_m_akm")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ass_akm_body_upperreceiver")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_upg_ak_m_akm")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_upg_ak_m_akm")
    self.parts.wpn_fps_ass_akm_b_standard.pcs = {}
    self.parts.wpn_fps_ass_akm_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.3, md_code = {0,0,1,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_upg_ak_m_akm.pcs = {}
    self.parts.wpn_upg_ak_m_akm.name_id = "bm_wp_upg_ak_m_akm"
    self.parts.wpn_upg_ak_m_akm.stats = { concealment = 8, weight = 3, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.45x39"] = 30, ["7.62x39"] = 30 } }
    self.parts.wpn_fps_ass_akm_body_upperreceiver.pcs = {}
    self.parts.wpn_fps_ass_akm_body_upperreceiver.stats = { concealment = 0, weight = 1 }
    self.wpn_fps_ass_akm.regression = "akm"
    self.wpn_fps_ass_akm.unit = self.wpn_fps_ass_74.unit
    self.wpn_fps_ass_akm.adds = {}
    self.wpn_fps_ass_akm.override = {
        --wpn_fps_o_blank = { override = {} },
    }
    for i, k in pairs(self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.wpn_fps_ass_akm.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.wpn_fps_ass_akm.override[k] = { a_obj = "a_o_sm" }
        end
    end
    table.deletefrom(self.wpn_fps_ass_akm.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_akm.default_blueprint, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_ass_akm.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_akm.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_akm.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_ak_extra_ris")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_o_pos_zenitco")
    table.addto(self.wpn_fps_ass_akm.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_ass_akm.uses_parts, self.nqr.all_magnifiers)

    self.parts.wpn_fps_ass_akm_b_standard_gold.stats = self.parts.wpn_fps_ass_akm_b_standard.stats
    self.parts.wpn_fps_ass_ak_body_lowerreceiver_gold.sub_type = self.parts.wpn_fps_ass_ak_body_lowerreceiver.sub_type
    self.parts.wpn_fps_ass_ak_body_lowerreceiver_gold.stats = self.parts.wpn_fps_ass_ak_body_lowerreceiver.stats
    self.parts.wpn_fps_ass_akm_body_upperreceiver_gold.stats = self.parts.wpn_fps_ass_akm_body_upperreceiver.stats
    self.parts.wpn_upg_ak_fg_standard_gold.override = self.parts.wpn_upg_ak_fg_standard.override
    self.parts.wpn_upg_ak_fg_standard_gold.visibility = self.parts.wpn_upg_ak_fg_standard.visibility
    self.parts.wpn_upg_ak_fg_standard_gold.stats = self.parts.wpn_upg_ak_fg_standard.stats
    self.parts.wpn_upg_ak_gb_standard_gold = deep_clone(self.parts.wpn_upg_ak_fg_standard_gold)
    self.parts.wpn_upg_ak_gb_standard_gold.type = self.parts.wpn_upg_ak_gb_standard.type
    self.parts.wpn_upg_ak_gb_standard_gold.forbids = self.parts.wpn_upg_ak_gb_standard.forbids
    self.parts.wpn_upg_ak_gb_standard_gold.visibility = self.parts.wpn_upg_ak_gb_standard.visibility
    self.parts.wpn_upg_ak_gb_standard_gold.stats = self.parts.wpn_upg_ak_gb_standard.stats
    self.parts.wpn_upg_ak_s_folding_gold = self.parts.wpn_upg_ak_s_folding_vanilla_gold
    self.parts.wpn_upg_ak_s_folding_gold.stats = self.parts.wpn_upg_ak_s_folding.stats
    self.parts.wpn_upg_ak_m_akm_gold.pcs = {}
    self.parts.wpn_upg_ak_m_akm_gold.name_id = "bm_wp_upg_ak_m_akm_gold"
    self.parts.wpn_upg_ak_m_akm_gold.stats = self.parts.wpn_upg_ak_m_akm.stats
    self.wpn_fps_ass_akm_gold.regression = "akm_gold"
    self.wpn_fps_ass_akm_gold.unit = self.wpn_fps_ass_74.unit
    self.wpn_fps_ass_akm_gold.adds = {}
    self.wpn_fps_ass_akm_gold.override = {
        --wpn_fps_o_blank = { override = {} },
    }
    for i, k in pairs(self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.wpn_fps_ass_akm_gold.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.wpn_fps_ass_akm_gold.override[k] = { a_obj = "a_o_sm" }
        end
    end
    table.deletefrom(self.wpn_fps_ass_akm_gold.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_akm_gold.default_blueprint, "wpn_upg_ak_gb_standard_gold")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_upg_ak_gb_standard_gold")
    table.insert(self.wpn_fps_ass_akm_gold.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_akm_gold.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_akm_gold.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_ak_extra_ris")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_o_pos_zenitco")
    table.addto(self.wpn_fps_ass_akm_gold.uses_parts, self.nqr.all_vertical_grips)
    table.addto(self.wpn_fps_ass_akm_gold.uses_parts, self.nqr.all_magnifiers)
    table.addto(self.wpn_fps_ass_akm_gold.uses_parts, self.nqr.all_tube_stocks)

    local rpk_collection = {
        "wpn_lmg_rpk_m_drum",
        "wpn_lmg_rpk_m_standard",
        "wpn_fps_lmg_rpk_b_standard",
        "wpn_fps_lmg_rpk_fg_wood",
        "wpn_fps_lmg_rpk_fg_standard",
        "wpn_fps_lmg_rpk_s_standard",
        "wpn_fps_lmg_rpk_s_wood",
    }
    table.addto(self.wpn_fps_ass_74.uses_parts, rpk_collection)
    table.addto(self.wpn_fps_ass_akm.uses_parts, rpk_collection)
    table.addto(self.wpn_fps_ass_akm_gold.uses_parts, rpk_collection)
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_lmg_rpk_m_drum")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_lmg_rpk_m_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_lmg_rpk_s_wood")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_lmg_rpk_s_standard")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_lmg_rpk_s_wood")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_lmg_rpk_s_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_lmg_rpk_m_drum")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_lmg_rpk_m_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_lmg_rpk_m_drum")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_lmg_rpk_m_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_lmg_rpk_fg_wood")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_lmg_rpk_s_wood")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_lmg_rpk_s_standard")
    self.parts.wpn_fps_lmg_rpk_b_standard.texture_bundle_folder = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_b_standard.dlc = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_b_standard.pcs = {}
    self.parts.wpn_fps_lmg_rpk_b_standard.name_id = "bm_wp_fps_lmg_rpk_b_standard"
    self.parts.wpn_fps_lmg_rpk_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 23.2, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_lmg_rpk_m_drum.texture_bundle_folder = "gage_pack_lmg"
    self.parts.wpn_lmg_rpk_m_drum.dlc = "gage_pack_lmg"
    self.parts.wpn_lmg_rpk_m_drum.pcs = {}
    self.parts.wpn_lmg_rpk_m_drum.name_id = "bm_wp_lmg_rpk_m_drum"
    self.parts.wpn_lmg_rpk_m_drum.override = { wpn_upg_ak_s_folding = { stats = table.copy_append(self.parts.wpn_upg_ak_s_folding.stats, { shoulderable = false }), desc_id = "bm_wp_stock_not_foldable_desc" } }
    self.parts.wpn_lmg_rpk_m_drum.stats = { concealment = 39, weight = 9, mag_amount = { 1, 1, 2 }, CLIP_AMMO_MAX = { ["5.45x39"] = 75, ["7.62x39"] = 75 }, retention = false }
    self.parts.wpn_upg_ak_m_drum.stats = self.parts.wpn_lmg_rpk_m_drum.stats
    self.parts.wpn_lmg_rpk_m_standard = deep_clone(self.parts.wpn_lmg_rpk_m_drum)
    self.parts.wpn_lmg_rpk_m_standard.texture_bundle_folder = "nqr_dlc"
    self.parts.wpn_lmg_rpk_m_standard.dlc = "nqr_dlc"
    self.parts.wpn_lmg_rpk_m_standard.name_id = "bm_wp_rpk_m_standard"
    self.parts.wpn_lmg_rpk_m_standard.unit = "units/pd2_dlc_gage_lmg/weapons/wpn_fps_lmg_rpk_pts/wpn_fps_lmg_rpk_m_standard"
    self.parts.wpn_lmg_rpk_m_standard.stats = { concealment = 12, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = { ["5.45x39"] = 45, ["7.62x39"] = 45 } }
    self.parts.wpn_fps_lmg_rpk_body_lowerreceiver.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_rpk_body_lowerreceiver.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_lmg_rpk_fg_wood.texture_bundle_folder = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_fg_wood.dlc = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_fg_wood.unit = self.parts.wpn_upg_ak_fg_combo1.unit
    self.parts.wpn_fps_lmg_rpk_fg_wood.pcs = {}
    self.parts.wpn_fps_lmg_rpk_fg_wood.name_id = "bm_wp_fps_lmg_rpk_fg_wood"
    self.parts.wpn_fps_lmg_rpk_fg_wood.adds = {}
    self.parts.wpn_fps_lmg_rpk_fg_wood.forbids = { "wpn_nqr_extra3_rail" }
    self.parts.wpn_fps_lmg_rpk_fg_wood.visibility = { { objects = { g_upperrail_lod0 = false } } }
    self.parts.wpn_fps_lmg_rpk_fg_wood.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_lmg_rpk_fg_standard.pcs = {}
    self.parts.wpn_fps_lmg_rpk_fg_standard.name_id = "bm_wp_fps_lmg_rpk_fg_standard"
    self.parts.wpn_fps_lmg_rpk_fg_standard.adds = {}
    self.parts.wpn_fps_lmg_rpk_fg_standard.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_fps_lmg_rpk_fg_standard.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_lmg_rpk_s_standard.pcs = {}
    self.parts.wpn_fps_lmg_rpk_s_standard.name_id = "bm_wp_fps_lmg_rpk_s_standard"
    self.parts.wpn_fps_lmg_rpk_s_standard.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.parts.wpn_fps_lmg_rpk_s_wood.texture_bundle_folder = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_s_wood.dlc = "gage_pack_lmg"
    self.parts.wpn_fps_lmg_rpk_s_wood.pcs = {}
    self.parts.wpn_fps_lmg_rpk_s_wood.name_id = "bm_wp_fps_lmg_rpk_s_wood"
    self.parts.wpn_fps_lmg_rpk_s_wood.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.wpn_fps_lmg_rpk.regression = "rpk"
    self.wpn_fps_lmg_rpk.unit = self.wpn_fps_ass_74.unit
    self.wpn_fps_lmg_rpk.override = {
        --wpn_fps_o_blank = { override = {} },
    }
    for i, k in pairs(self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.wpn_fps_lmg_rpk.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.wpn_fps_lmg_rpk.override[k] = { a_obj = "a_o_sm" }
        end
    end
    table.addto(self.wpn_fps_lmg_rpk.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_rpk.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_lmg_rpk.default_blueprint, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_gb_standard")
    table.insert(self.wpn_fps_lmg_rpk.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_lmg_rpk.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_rpk.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ak_extra_ris")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_o_pos_zenitco")
    table.addto(self.wpn_fps_lmg_rpk.uses_parts, self.nqr.all_tube_stocks)

    local akmsu_foregrips_full = {
        "wpn_fps_smg_akmsu_fg_standard",
        "wpn_fps_smg_akmsu_fg_rail",
        "wpn_fps_upg_ak_fg_zenit",
    }
    self.parts.wpn_fps_smg_akmsu_b_standard.sub_type = "ironsight"
    self.parts.wpn_fps_smg_akmsu_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 8.1, md_code = {0,1,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_smg_akmsu_body_lowerreceiver.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_akmsu_fg_standard.adds = {}
    self.parts.wpn_fps_smg_akmsu_fg_standard.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_fps_smg_akmsu_fg_standard.override = {}
    self.parts.wpn_fps_smg_akmsu_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_akmsu_fg_rail.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_smg_akmsu_fg_rail.needs_sight_pos = true
    self.parts.wpn_fps_smg_akmsu_fg_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_ak_fg_zenit.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_upg_ak_fg_zenit.needs_sight_pos = true
    self.parts.wpn_fps_upg_ak_fg_zenit.override = {}
    self.parts.wpn_fps_upg_ak_fg_zenit.stats = { concealment = 0, weight = 0, sightheight = 0.1 }
    self.wpn_fps_smg_akmsu.regression = "akmsu"
    self.wpn_fps_smg_akmsu.unit = self.wpn_fps_ass_74.unit
    self.wpn_fps_smg_akmsu.adds = {}
    self.wpn_fps_smg_akmsu.override = {
        --wpn_fps_o_blank = { override = {} },
        wpn_fps_upg_o_ak_scopemount = { stats = table.copy_append(self.parts.wpn_fps_upg_o_ak_scopemount.stats, { sightheight = 1.36 }) },
        wpn_fps_smg_coal_o_scopemount_standard = { stats = table.copy_append(self.parts.wpn_fps_smg_coal_o_scopemount_standard.stats, { sightheight = 1.36 }) },
    }
    for i, k in pairs(self.nqr.all_second_sights) do
        if self.parts[k].parent then
            --self.wpn_fps_smg_akmsu.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_sm", parent = false }
        else
            --self.wpn_fps_smg_akmsu.override[k] = { a_obj = "a_o_sm" }
        end
    end
    table.deletefrom(self.wpn_fps_smg_akmsu.uses_parts, self.nqr.all_snoptics)
    table.delete(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_upg_ak_body_upperreceiver_zenitco")
    table.swap(self.wpn_fps_smg_akmsu.default_blueprint, "wpn_upg_ak_m_akm", "wpn_fps_ass_74_m_standard")
    table.swap(self.wpn_fps_smg_akmsu.default_blueprint, "wpn_upg_ak_s_folding", "wpn_upg_ak_s_skfoldable")
    table.insert(self.wpn_fps_smg_akmsu.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_smg_akmsu.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_akmsu.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_o_pos_fg")
    table.addto(self.wpn_fps_smg_akmsu.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_smg_akmsu.uses_parts, self.nqr.all_second_sights)
--------

--------REST
    local flint_collection = {
        "wpn_fps_ass_flint_g_standard",
        "wpn_fps_ass_flint_m_standard",
    }
    table.addto(self.wpn_fps_ass_74.uses_parts, flint_collection)
    table.addto(self.wpn_fps_ass_akm.uses_parts, flint_collection)
    table.addto(self.wpn_fps_ass_akm_gold.uses_parts, flint_collection)
    table.addto(self.wpn_fps_lmg_rpk.uses_parts, flint_collection)
    table.addto(self.wpn_fps_smg_akmsu.uses_parts, flint_collection)
    table.addto(self.wpn_fps_ass_groza.uses_parts, flint_collection)
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_flint_g_standard")
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_ass_flint_g_standard")
    self.parts.wpn_fps_ass_flint_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.3, md_code = {0,1,0,1,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_ass_flint_body_upperreceiver.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_ass_flint_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_flint_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_flint_g_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_ass_flint_g_standard.dlc = "grv"
    self.parts.wpn_fps_ass_flint_g_standard.pcs = {}
    self.parts.wpn_fps_ass_flint_g_standard.name_id = "bm_wp_fps_ass_flint_g_standard"
    self.parts.wpn_fps_ass_flint_g_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_flint_m_release_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_flint_m_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_ass_flint_m_standard.dlc = "grv"
    self.parts.wpn_fps_ass_flint_m_standard.pcs = {}
    self.parts.wpn_fps_ass_flint_m_standard.name_id = "bm_wp_fps_ass_flint_m_standard"
    self.parts.wpn_fps_ass_flint_m_standard.stats = { concealment = 0, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.45x39"] = 30, ["7.62x39"] = 30 } }
    self.parts.wpn_fps_ass_flint_ns_standard.stats = { concealment = 3, weight = 2, length = 2, md_code = {0,0,1,1,0} }
    self.parts.wpn_fps_ass_flint_o_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_ass_flint_o_standard.dlc = "grv"
    self.parts.wpn_fps_ass_flint_o_standard.forbids = {}
    self.parts.wpn_fps_ass_flint_o_standard.stats = { concealment = 0, weight = 0 } --todo sightheight
    self.parts.wpn_fps_ass_flint_s_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_ass_flint_s_standard.dlc = "grv"
    self.parts.wpn_fps_ass_flint_s_standard.pcs = {}
    self.parts.wpn_fps_ass_flint_s_standard.type = "stock_addon"
    self.parts.wpn_fps_ass_flint_s_standard.stats = { concealment = 0, weight = 3, length = 8.07, shouldered = true }
    self.parts.wpn_fps_snp_flint_s_adapter.desc_id = "bm_wp_stock_adapter_foldable_desc"
    self.parts.wpn_fps_snp_flint_s_adapter.type = "stock"
    self.parts.wpn_fps_snp_flint_s_adapter.stats = { concealment = 0, weight = 2, length = 6, shoulderable = true }
    table.deletefrom(self.wpn_fps_ass_flint.uses_parts, self.nqr.all_snoptics)
    table.delete(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_upg_ak_s_zenitco")
    table.insert(self.wpn_fps_ass_flint.default_blueprint, "wpn_fps_snp_flint_s_adapter")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_snp_flint_s_adapter")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_upg_ak_dh_zenitco")
    --table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_remove_s") --todo
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_remove_ns")
    table.addto(self.wpn_fps_ass_flint.uses_parts, self.nqr.all_tube_stocks)

    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_groza_m_speed")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_ass_groza_m_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_groza_g_standard")
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_ass_groza_g_standard")
    self.parts.wpn_fps_ass_groza_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 9.4 }
    self.parts.wpn_fps_ass_groza_b_supressor.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_groza_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_ass_groza_body_standard.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.parts.wpn_fps_ass_groza_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_groza_g_standard.pcs = {}
    self.parts.wpn_fps_ass_groza_g_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_groza_gl_gp25.perks = nil
    self.parts.wpn_fps_ass_groza_gl_gp25.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_groza_m_speed.stats = { concealment = 7, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x39"] = 20 } }
    self.parts.wpn_fps_ass_groza_m_standard.pcs = {}
    self.parts.wpn_fps_ass_groza_m_standard.name_id = "bm_wp_fps_ass_groza_m_standard"
    self.parts.wpn_fps_ass_groza_m_standard.stats = { concealment = 7, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x39"] = 20 } }
    self.parts.wpn_fps_ass_groza_o_adapter.pcs = {}
    self.parts.wpn_fps_ass_groza_o_adapter.name_id = "bm_wp_groza_sightrail"
    self.parts.wpn_fps_ass_groza_o_adapter.type = "extra"
    self.parts.wpn_fps_ass_groza_o_adapter.rails = { "top" }
    self.parts.wpn_fps_ass_groza_o_adapter.stats = { concealment = 2, weight = 1, sightheight = 0.15 }
    self.parts.wpn_fps_ass_groza_fl_adapter.pcs = {}
    self.parts.wpn_fps_ass_groza_fl_adapter.name_id = "bm_wp_groza_gadgetrail"
    self.parts.wpn_fps_ass_groza_fl_adapter.type = "extra2"
    self.parts.wpn_fps_ass_groza_fl_adapter.stats = { concealment = 1, weight = 1 }
    self.wpn_fps_ass_groza.adds = {}
    table.deletefrom(self.wpn_fps_ass_groza.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_ass_groza.uses_parts, self.nqr.all_bxs)
    table.delete(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_ass_groza_b_supressor")
    table.insert(self.wpn_fps_ass_groza.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_groza.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_ass_groza_o_adapter")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_ass_groza_fl_adapter")
    table.addto(self.wpn_fps_ass_groza.uses_parts, self.nqr.all_second_sights)

    self.wpn_fps_ass_asval.sightheight_mod = 0
    self.parts.wpn_fps_ass_asval_b_proto.sub_type = "ironsight"
    self.parts.wpn_fps_ass_asval_b_proto.stats = { concealment = 0, weight = -2, barrel_length = 7.9, md_code = {1,0,0,0,0} }
    self.parts.wpn_fps_ass_asval_b_standard.sub_type = "ironsight"
    self.parts.wpn_fps_ass_asval_b_standard.stats = { concealment = 0, weight = 0, length = 8, barrel_length = 7.9, md_code = {5,0,0,0,0} }
    self.parts.wpn_fps_ass_asval_body_standard.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_ass_asval_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_asval_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_asval_m_standard.stats = { concealment = 7, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_ass_asval_s_solid.stats = { concealment = 0, weight = 6, length = 11, shouldered = true }
    self.parts.wpn_fps_ass_asval_s_standard.stats = { concealment = 0, weight = 3, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_asval_scopemount.pcs = {} --todo a_o
    self.parts.wpn_fps_ass_asval_scopemount.name_id = "bm_wp_asval_sightrail"
    self.parts.wpn_fps_ass_asval_scopemount.type = "extra"
    self.parts.wpn_fps_ass_asval_scopemount.rails = { "top" }
    self.parts.wpn_fps_ass_asval_scopemount.stats = { concealment = 0, weight = 2, sightheight = 2.68 }
    self.parts.wpn_fps_ass_asval_scopemount2 = deep_clone(self.parts.wpn_fps_ass_asval_scopemount)
    self.parts.wpn_fps_ass_asval_scopemount2.name_id = "bm_wp_asval_sightrail2"
    self.parts.wpn_fps_ass_asval_scopemount2.unit = "units/pd2_dlc_character_sokol/weapons/wpn_fps_ass_asval_pts/wpn_fps_ass_asval_scopemount_2"
    self.parts.wpn_fps_ass_asval_scopemount2.stats = { concealment = 0, weight = 2, sightheight = 2.68 }
    self.wpn_fps_ass_asval.adds = {}
    table.deletefrom(self.wpn_fps_ass_asval.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_asval.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_asval.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_asval.uses_parts, "wpn_fps_ass_asval_scopemount")
    table.insert(self.wpn_fps_ass_asval.uses_parts, "wpn_fps_ass_asval_scopemount2")
    table.addto(self.wpn_fps_ass_asval.uses_parts, self.nqr.all_magnifiers)
    --table.insert(self.wpn_fps_ass_asval.uses_parts, "wpn_fps_remove_s") --todo

    self.wpn_fps_ass_tkb.sightheight_mod = 1.2
    self.parts.wpn_fps_ass_tkb_barrels.stats = { concealment = 0, weight = 0, barrel_length = 16.9 }
    self.parts.wpn_fps_ass_tkb_o_irons.type = "ironsight"
    self.parts.wpn_fps_ass_tkb_o_irons.adds = {}
    self.parts.wpn_fps_ass_tkb_o_irons.stats = { concealment = 0, weight = 0, sightheight = 1.05 }
    self.parts.wpn_fps_ass_tkb_o_tritium.type = "ironsight"
    self.parts.wpn_fps_ass_tkb_o_tritium.adds = { "wpn_fps_ass_tkb_o_tritium_add" }
    self.parts.wpn_fps_ass_tkb_o_tritium.stats = { concealment = 0, weight = 0, sightheight = 1.05 }
    self.parts.wpn_fps_ass_tkb_o_tritium_add.type = "ironsight"
    self.parts.wpn_fps_ass_tkb_o_tt01.type = "ironsight"
    self.parts.wpn_fps_ass_tkb_o_tt01.rails = { "top" }
    self.parts.wpn_fps_ass_tkb_o_tt01.adds = {}
    --self.parts.wpn_fps_ass_tkb_o_tt01.override = { wpn_fps_ironsight_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_ass_tkb_o_tt01.stats = { concealment = 0, weight = 0, sightheight = 0.95 }
    self.parts.wpn_fps_ass_tkb_body_rear.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_ass_tkb_m_standard.stats = { concealment = 18, weight = 5, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 45, retention = false }
    self.parts.wpn_fps_ass_tkb_m_bakelite.stats = { concealment = 18, weight = 5, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 45, retention = false }
    self.wpn_fps_ass_tkb.adds = {}
    self.wpn_fps_ass_tkb.override.wpn_fps_o_blank = { override = {} }
    for i, k in pairs(self.nqr.all_angled_sights) do self.wpn_fps_ass_tkb.override.wpn_fps_o_blank.override[k] = { a_obj = "a_o_2", parent = false } end
    table.deletefrom(self.wpn_fps_ass_tkb.uses_parts, self.nqr.all_big_reddots)
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_upg_o_cmore")
    table.deletefrom(self.wpn_fps_ass_tkb.uses_parts, self.nqr.all_bxs)
    table.delete(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_upg_ak_ns_tgp")
    table.delete(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_upg_ak_ns_jmac")
    table.delete(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_ass_tkb_body_pouch")
    table.insert(self.wpn_fps_ass_tkb.default_blueprint, 1, "wpn_fps_ironsight_lock_sights")
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_ironsight_lock_sights")
    table.addto(self.wpn_fps_ass_tkb.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_ass_ak5_b_short.stats = { concealment = 0, weight = 0, barrel_length = 13.8, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_ak5_b_std.stats = { concealment = 0, weight = 0, barrel_length = 17.7, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_ak5_body_ak5.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_ass_ak5_body_rail.pcs = {}
    self.parts.wpn_fps_ass_ak5_body_rail.name_id = "bm_wp_ak5_sightrail"
    self.parts.wpn_fps_ass_ak5_body_rail.type = "extra"
    self.parts.wpn_fps_ass_ak5_body_rail.rails = { "top" }
    self.parts.wpn_fps_ass_ak5_body_rail.stats = { concealment = 4, weight = 2 }
    self.parts.wpn_fps_ass_ak5_fg_ak5a.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ak5_fg_ak5c.rails = { "side", "bottom" }
    self.parts.wpn_fps_ass_ak5_fg_ak5c.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ak5_fg_fnc.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ak5_s_ak5a.stats = { concealment = 0, weight = 4, length = 9, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_ak5_s_ak5b.type = "stock_addon"
    self.parts.wpn_fps_ass_ak5_s_ak5b.stats = { concealment = 0, weight = 1, length = 9, cheek = 2 }
    self.parts.wpn_fps_ass_ak5_s_ak5c.forbids = { "wpn_fps_ass_ak5_s_ak5b" }
    self.parts.wpn_fps_ass_ak5_s_ak5c.stats = { concealment = 0, weight = 3, length = 9.06, shouldered = true, shoulderable = true }
    self.wpn_fps_ass_ak5.adds = {}
    self.wpn_fps_ass_ak5.override = {
        wpn_fps_remove_s = { forbids = { "wpn_fps_ass_ak5_s_ak5b" } },
    }
    table.addto(self.wpn_fps_ass_ak5.override.wpn_fps_remove_s.forbids, deep_clone(self.parts.wpn_fps_remove_s.forbids))
    table.deletefrom(self.wpn_fps_ass_ak5.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_ak5.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_ak5.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_ak5.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_ass_ak5_body_rail")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_ak5.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_ass_ak5.uses_parts, self.nqr.all_m4_mags)

    self.parts.wpn_fps_aug_b_long.stats = { concealment = 0, weight = 3, barrel_length = 24.4, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_aug_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 19, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_aug_b_short.stats = { concealment = 0, weight = -3, barrel_length = 13.8, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_aug_body_aug.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_aug_body_f90.stats = { concealment = 0, weight = 1, length = 10, shouldered = true }
    self.parts.wpn_fps_aug_fg_a3.type = "foregrip"
    self.parts.wpn_fps_aug_fg_a3.forbids = { "wpn_fps_aug_b_short" }
    self.parts.wpn_fps_aug_fg_a3.override = { wpn_fps_foregrip_lock_gadgets = { forbids = {} } }
    self.parts.wpn_fps_aug_fg_a3.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_aug_m_pmag.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_ass_aug_m_quick.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_aug_ris_special.pcs = {}
    self.parts.wpn_fps_aug_ris_special.name_id = "bm_wp_aug_gadgetrail"
    self.parts.wpn_fps_aug_ris_special.type = "extra2"
    self.parts.wpn_fps_aug_ris_special.stats = { concealment = 1, weight = 1 }
    self.wpn_fps_ass_aug.adds = {}
    table.swap(self.wpn_fps_ass_aug.default_blueprint, "wpn_upg_o_marksmansight_rear", "wpn_fps_gre_arbiter_o_standard")
    table.insert(self.wpn_fps_ass_aug.uses_parts, "wpn_fps_gre_arbiter_o_standard")
    table.insert(self.wpn_fps_ass_aug.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_aug.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_aug.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_ass_aug.uses_parts, table.without(self.nqr.all_m4_mags, {"wpn_fps_upg_m4_m_drum", "wpn_fps_ass_tecci_m_drum"}))

    self.parts.wpn_fps_ass_corgi_b_long.stats = { concealment = 0, weight = 3, barrel_length = 20 } --roughly
    self.parts.wpn_fps_ass_corgi_b_short.texture_bundle_folder = "rvd"
    self.parts.wpn_fps_ass_corgi_b_short.dlc = "rvd"
    self.parts.wpn_fps_ass_corgi_b_short.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_ass_corgi_body_lower_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_ass_corgi_body_lower_strap.visibility = { { objects = { g_straps = false } } }
    self.parts.wpn_fps_ass_corgi_body_lower_strap.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_ass_corgi_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_corgi_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_corgi_ejector_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_corgi_fg_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_corgi_ns_standard.name_id = "bm_wp_corgi_ns_standard"
    self.parts.wpn_fps_ass_corgi_ns_standard.texture_bundle_folder = "rvd"
    self.parts.wpn_fps_ass_corgi_ns_standard.dlc = "rvd"
    self.parts.wpn_fps_ass_corgi_ns_standard.pcs = {}
    self.parts.wpn_fps_ass_corgi_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_corgi_cos_strap = deep_clone(self.parts.wpn_fps_ass_corgi_body_lower_strap)
    self.parts.wpn_fps_ass_corgi_cos_strap.name_id = "bm_wp_corgi_cos_strap"
    self.parts.wpn_fps_ass_corgi_cos_strap.type = "wep_cos"
    self.parts.wpn_fps_ass_corgi_cos_strap.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_fps_ass_corgi_cos_strap.stats = { concealment = 2, weight = 0 }
    table.delete(self.wpn_fps_ass_corgi.uses_parts, "wpn_fps_upg_m4_m_drum")
    table.insert(self.wpn_fps_ass_corgi.uses_parts, "wpn_fps_ass_corgi_cos_strap")
    table.insert(self.wpn_fps_ass_corgi.uses_parts, "wpn_fps_remove_ns")
    table.addto(self.wpn_fps_ass_aug.uses_parts, table.without(self.nqr.all_m4_mags, {"wpn_fps_upg_m4_m_drum", "wpn_fps_ass_tecci_m_drum"}))
    table.insert(self.wpn_fps_ass_corgi.uses_parts, "wpn_fps_m4_uupg_m_strike")

    for i, k in pairs(self.nqr.all_bxs_sbr) do
        self.parts.wpn_fps_ass_famas_b_short.override[k] = { a_obj = "a_ns_s" }
        self.parts.wpn_fps_ass_famas_b_standard.override[k] = { a_obj = "a_ns_s" }
        self.parts.wpn_fps_ass_famas_b_long.override[k] = { a_obj = "a_ns_s" }
    end
    self.parts.wpn_fps_ass_famas_b_short.override.wpn_fps_ass_famas_b_suppressed = { a_obj = "a_b", parent = false }
    self.parts.wpn_fps_ass_famas_b_short.stats = { concealment = 0, weight = -1, barrel_length = 17.7, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_famas_b_standard.override.wpn_fps_ass_famas_b_suppressed = { a_obj = "a_ns_n" }
    self.parts.wpn_fps_ass_famas_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 19.2, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_famas_b_long.override.wpn_fps_ass_famas_b_suppressed = { a_obj = "a_ns_n" }
    self.parts.wpn_fps_ass_famas_b_long.stats = { concealment = 0, weight = 3, barrel_length = 23.6, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_famas_b_sniper.override.wpn_fps_ass_famas_b_suppressed = { a_obj = "a_ns_n" }
    self.parts.wpn_fps_ass_famas_b_sniper.override = {}
    self.parts.wpn_fps_ass_famas_b_sniper.stats = { concealment = 0, weight = 4, barrel_length = 25.6 }
    self.parts.wpn_fps_ass_famas_b_suppressed.type = "barrel_ext"
    self.parts.wpn_fps_ass_famas_b_suppressed.a_obj = "a_ns"
    self.parts.wpn_fps_ass_famas_b_suppressed.parent = "barrel"
    self.parts.wpn_fps_ass_famas_b_suppressed.forbids = {}
    self.parts.wpn_fps_ass_famas_b_suppressed.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_ass_famas_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_ass_famas_body_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_ass_famas_g_retro.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_ass_famas_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_famas_m_standard.animations = nil
    self.parts.wpn_fps_ass_famas_m_standard.stats = { concealment = 7, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 25, [".300 BLK"] = 0, [".50 Beo"] = 0 } }
    self.parts.wpn_fps_ass_famas_o_adapter.pcs = {}
    self.parts.wpn_fps_ass_famas_o_adapter.name_id = "bm_wp_famas_sightrail"
    self.parts.wpn_fps_ass_famas_o_adapter.type = "extra"
    self.parts.wpn_fps_ass_famas_o_adapter.rails = { "top" }
    self.parts.wpn_fps_ass_famas_o_adapter.stats = { concealment = 3, weight = 2 }
    self.wpn_fps_ass_famas.adds = {}
    self.wpn_fps_ass_famas.override = {}
    table.deletefrom(self.wpn_fps_ass_famas.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_ass_famas.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_famas.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_famas.default_blueprint, 1, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_fps_ass_famas_o_adapter")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_famas.uses_parts, "wpn_nqr_extra3_rail")
    table.addto(self.wpn_fps_ass_famas.uses_parts, self.nqr.all_m4_mags)
    table.addto(self.wpn_fps_ass_famas.uses_parts, self.nqr.all_vertical_grips)

    self.parts.wpn_fps_ass_g36_body_sl8.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g36_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g36_b_short.pcs = {}
    self.parts.wpn_fps_ass_g36_b_short.forbids = { "wpn_fps_ass_g36_fg_ksk" }
    self.parts.wpn_fps_ass_g36_b_short.stats = { concealment = 0, weight = -2, barrel_length = 9, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_g36_b_long.stats = { concealment = 0, weight = 0, barrel_length = 12.5, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_upg_g36_b_ultra.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g36_fg_c.rails = { "side", "bottom" }
    self.parts.wpn_fps_ass_g36_fg_c.adds = {}
    self.parts.wpn_fps_ass_g36_fg_c.forbids = {}
    self.parts.wpn_fps_ass_g36_fg_c.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_g36_fg_k.rails = { "side", "bottom" }
    self.parts.wpn_fps_ass_g36_fg_k.adds = {}
    self.parts.wpn_fps_ass_g36_fg_k.forbids = { "wpn_fps_ass_g36_b_short" }
    self.parts.wpn_fps_ass_g36_fg_k.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_ass_g36_fg_ksk.rails = { "side", "bottom" }
    self.parts.wpn_fps_ass_g36_fg_ksk.adds = {}
    self.parts.wpn_fps_ass_g36_fg_ksk.forbids = { "wpn_fps_ass_g36_b_short" }
    self.parts.wpn_fps_ass_g36_fg_ksk.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_upg_g36_fg_long.rails = { "side" }
    self.parts.wpn_fps_upg_g36_fg_long.type = "exclusive_set"
    self.parts.wpn_fps_upg_g36_fg_long.adds = {}
    self.parts.wpn_fps_upg_g36_fg_long.forbids = { "wpn_fps_ass_g36_b_short", "wpn_fps_ass_g36_fg_c", "wpn_fps_ass_g36_fg_ksk", }
    self.parts.wpn_fps_upg_g36_fg_long.override = {
        --wpn_fps_ass_g36_b_long = { unit = "units/pd2_dlc_tng/weapons/wpn_fps_ass_g36_fg_long/wpn_fps_upg_g36_b_ultra", },
        --wpn_fps_ass_g36_b_long = { unit = self.parts.wpn_fps_upg_g36_b_ultra.unit, stats = { concealment = 0, weight = 0 } },
        wpn_fps_ass_g36_b_long = { unit = self.parts.wpn_fps_upg_g36_b_ultra.unit, a_obj = "a_fg", stats = { barrel_length = 0 } },
        --wpn_fps_ass_g36_b_short = { unit = fantom_unit, },

        --wpn_fps_ass_g36_fg_k = { unit = "units/pd2_dlc_tng/weapons/wpn_fps_ass_g36_fg_long/wpn_fps_upg_g36_b_ultra", },
        --wpn_fps_ass_g36_fg_k = { unit = fantom_unit, stats = {} },
    }
    self.parts.wpn_fps_upg_g36_fg_long.override.wpn_fps_ass_g36_fg_c = { override = {}, }
    self.parts.wpn_fps_upg_g36_fg_long.override.wpn_fps_ass_g36_fg_k = { forbids = {}, override = {}, unit = fantom_unit, stats = {}, }
    self.parts.wpn_fps_upg_g36_fg_long.override.wpn_fps_ass_g36_fg_ksk = { override = {}, }
    self.parts.wpn_fps_upg_g36_fg_long.stats = { concealment = 0, weight = 3+3+2, barrel_length = 18.9, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_g36_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g36_body_dummy = deep_clone(self.parts.wpn_fps_ass_g36_g_standard)
    self.parts.wpn_fps_ass_g36_body_dummy.type = "body_dummy"
    self.parts.wpn_fps_ass_g36_body_dummy.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_ass_g36_m_standard.pcs = {}
    self.parts.wpn_fps_ass_g36_m_standard.animations = nil
    self.parts.wpn_fps_ass_g36_m_standard.stats = { concealment = 9, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 0, [".50 Beo"] = 0 } }
    self.parts.wpn_fps_ass_g36_m_quick.stats = { concealment = 9, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 0, [".50 Beo"] = 0 } }
    --self.parts.wpn_fps_ass_g36_o_vintage.override = {}
    for i, k in pairs(self.nqr.all_angled_sights) do
        if self.parts[k].parent then self.parts.wpn_fps_ass_g36_o_vintage.override[k] = { parent = false, a_obj = "a_o" } end
    end
    self.parts.wpn_fps_ass_g36_o_vintage.stats = { concealment = 0, weight = 3, sightheight = 3.15 }
    self.parts.wpn_fps_ass_g36_s_kv.stats = { concealment = 0, weight = 4, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_g36_s_sl8.stats = { concealment = 0, weight = 6, length = 11, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_ass_g36_s_standard.stats = { concealment = 0, weight = 3, length = 10, shouldered = true, shoulderable = true }
    self.wpn_fps_ass_g36.override = {}
    self.wpn_fps_ass_g36.override.wpn_fps_remove_s = { adds = deep_clone(self.parts.wpn_fps_ass_g36_s_kv.adds) }
    table.insert(self.wpn_fps_ass_g36.default_blueprint, "wpn_fps_ass_g36_body_dummy")
    table.insert(self.wpn_fps_ass_g36.uses_parts, "wpn_fps_ass_g36_body_dummy")
    table.insert(self.wpn_fps_ass_g36.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_g36.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_g36.default_blueprint, 1, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_g36.uses_parts, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_g36.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_g36.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_ass_g36.uses_parts, self.nqr.all_m4_mags)

    self.parts.wpn_fps_ass_komodo_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 13 }
    self.parts.wpn_fps_ass_komodo_body.stats = { concealment = 0, weight = 0, length = 9, shouldered = true } --todo a_o
    self.parts.wpn_fps_ass_komodo_dh.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_komodo_grip_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_komodo_ns.pcs = {}
    self.parts.wpn_fps_ass_komodo_ns.texture_bundle_folder = "tar"
    self.parts.wpn_fps_ass_komodo_ns.dlc = "tar"
    self.parts.wpn_fps_ass_komodo_ns.parent = "barrel"
    self.parts.wpn_fps_ass_komodo_ns.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_komodo_o_flipups_up.a_obj = "a_oi"
    self.parts.wpn_fps_ass_komodo_o_flipups_up.type = "ironsight"
    self.parts.wpn_fps_ass_komodo_o_flipups_up.forbids = {}
    table.addto(self.parts.wpn_fps_ass_komodo_o_flipups_up.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_c96))
    self.parts.wpn_fps_ass_komodo_o_flipups_up.stats = { concealment = 2, weight = 0 }
    self.parts.wpn_fps_ass_komodo_o_flipups_down.stats = {}
    self.wpn_fps_ass_komodo.adds = {}
    self.wpn_fps_ass_komodo.override = {
        wpn_fps_ass_komodo_ns = { parent = false },
        wpn_fps_fold_ironsight = {
            unit = self.parts.wpn_fps_ass_komodo_o_flipups_down.unit,
            third_unit = self.parts.wpn_fps_ass_komodo_o_flipups_down.third_unit,
            stats = {},
            a_obj = "a_oi",
        },
    }
    table.delete(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_upg_m4_m_drum")
    table.insert(self.wpn_fps_ass_komodo.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_fold_ironsight")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_upg_cal_300blk")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_upg_a_subfmj")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_upg_cal_545x39")
    table.insert(self.wpn_fps_ass_komodo.default_blueprint, "wpn_fps_upg_blankcal_556")
    table.insert(self.wpn_fps_ass_komodo.uses_parts, "wpn_fps_upg_blankcal_556")
    table.addto(self.wpn_fps_ass_komodo.uses_parts, table.without(self.nqr.all_m4_mags, {"wpn_fps_upg_m4_m_drum", "wpn_fps_ass_tecci_m_drum"}))

    self.parts.wpn_fps_ass_l85a2_b_long.stats = { concealment = 0, weight = 2, barrel_length = 23 } --roughly
    self.parts.wpn_fps_ass_l85a2_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 20.4 }
    self.parts.wpn_fps_ass_l85a2_b_short.stats = { concealment = 0, weight = 1, barrel_length = 18 } --not_sure
    self.parts.wpn_fps_ass_l85a2_body_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_ass_l85a2_fg_medium.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_l85a2_fg_short.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_ass_l85a2_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_l85a2_g_worn.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_l85a2_m_emag.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 30, [".50 Beo"] = 10 } }
    self.parts.wpn_fps_ass_l85a2_ns_standard.name_id = "bm_wp_l85a2_ns_standard"
    self.parts.wpn_fps_ass_l85a2_ns_standard.pcs = {}
    self.parts.wpn_fps_ass_l85a2_ns_standard.stats = { concealment = 3, weight = 2, length = 3, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_l85a2_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_ass_l85a2_o_standard.forbids, self.nqr.all_second_sights)
    self.parts.wpn_fps_ass_l85a2_o_standard.stats = { concealment = 5, weight = 2 }
    --table.deletefrom(self.wpn_fps_ass_l85a2.uses_parts, self.nqr.all_snoptics)
    table.addto(self.wpn_fps_ass_l85a2.uses_parts, self.nqr.all_m4_mags)
    table.delete(self.wpn_fps_ass_l85a2.uses_parts, "wpn_fps_upg_m4_m_drum")
    table.delete(self.wpn_fps_ass_l85a2.uses_parts, "wpn_fps_upg_m4_m_drum")
    table.delete(self.wpn_fps_ass_l85a2.uses_parts, "wpn_fps_ass_tecci_m_drum")
    table.insert(self.wpn_fps_ass_l85a2.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_l85a2.uses_parts, "wpn_fps_remove_o")

    self.parts.wpn_fps_ass_s552_ns_standard = deep_clone(self.parts.wpn_fps_ass_s552_b_standard)
    self.parts.wpn_fps_ass_s552_ns_standard.type = "barrel_ext"
    self.parts.wpn_fps_ass_s552_ns_standard.visibility = { { objects = { g_barrel = false, g_no_blurr = false } } }
    self.parts.wpn_fps_ass_s552_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_s552_b_standard.visibility = { { objects = { g_flashhider = false } } }
    self.parts.wpn_fps_ass_s552_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 8.9 }
    self.parts.wpn_fps_ass_s552_b_long.override = { wpn_fps_ass_s552_ns_standard = { unit = self.parts.wpn_fps_ass_s552_b_long.unit } }
    self.parts.wpn_fps_ass_s552_b_long.visibility = { { objects = { g_flashhider = false } } }
    self.parts.wpn_fps_ass_s552_b_long.stats = { concealment = 0, weight = 3, barrel_length = 14.3 }
    self.parts.wpn_fps_ass_s552_body_standard.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_ass_s552_body_standard_black.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_ass_s552_fg_railed.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_s552_fg_railed.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_ass_s552_fg_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_s552_fg_standard_green.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_s552_g_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_s552_g_standard_green.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_s552_m_standard.bullet_objects.amount = 27
    self.parts.wpn_fps_ass_s552_m_standard.stats = { concealment = 8, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_ass_s552_o_flipup.forbids = {}
    table.addto(self.parts.wpn_fps_ass_s552_o_flipup.forbids, self.nqr.all_snoptics)
    self.parts.wpn_fps_ass_s552_o_flipup.stats = { concealment = 1, weight = 0 }
    self.parts.wpn_fps_ass_s552_s_m4.pcs = {}
    self.parts.wpn_fps_ass_s552_s_m4.type = "stock"
    self.parts.wpn_fps_ass_s552_s_m4.desc_id = "bm_wp_stock_adapter_foldable_desc"
    self.parts.wpn_fps_ass_s552_s_m4.stats = { concealment = 0, weight = 2, length = 7, shouldered = false, shoulderable = true }
    self.parts.wpn_fps_ass_s552_s_standard.stats = { concealment = 0, weight = 3, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_s552_s_standard_green.stats = { concealment = 0, weight = 3, length = 10, shouldered = true, shoulderable = true }
    self.wpn_fps_ass_s552.override = {
        wpn_fps_fold_ironsight = {
            unit = fantom_unit,
            third_unit = fantom_unit,
            stats = { concealment = 0, weight = 0 },
        },
    }
    table.insert(self.wpn_fps_ass_s552.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_s552.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_s552.default_blueprint, "wpn_fps_ass_s552_ns_standard")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_ass_s552_ns_standard")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_s552.uses_parts, "wpn_fps_fold_ironsight")
    table.addto(self.wpn_fps_ass_s552.uses_parts, self.nqr.all_tube_stocks)

    self.parts.wpn_fps_ass_tecci_b_long.stats = { concealment = 0, weight = 4, barrel_length = 14.5 }
    self.parts.wpn_fps_ass_tecci_b_standard.forbids = { "wpn_fps_ass_contraband_fg_standard" }
    self.parts.wpn_fps_ass_tecci_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 9 }
    self.parts.wpn_fps_ass_tecci_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 9, md_code = {0,0,0,1,0} }
    self.parts.wpn_fps_ass_tecci_dh_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_dh_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_dh_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_tecci_fg_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_fg_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_fg_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_fg_standard.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_ass_tecci_fg_legend.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_tecci_g_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_g_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_g_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_g_standard.name_id = "bm_wp_fps_ass_tecci_g_standard"
    self.parts.wpn_fps_ass_tecci_g_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_tecci_lower_reciever.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_lower_reciever.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_lower_reciever.pcs = {}
    self.parts.wpn_fps_ass_tecci_lower_reciever.name_id = "bm_wp_fps_ass_tecci_lower_reciever"
    self.parts.wpn_fps_ass_tecci_lower_reciever.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_ass_tecci_m_drum.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_m_drum.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_m_drum.pcs = {}
    self.parts.wpn_fps_ass_tecci_m_drum.name_id = "bm_wp_fps_ass_tecci_m_drum"
    self.parts.wpn_fps_ass_tecci_m_drum.animations = nil
    self.parts.wpn_fps_ass_tecci_m_drum.stats = { concealment = 48, weight = 10, mag_amount = { 1, 1, 2 }, CLIP_AMMO_MAX = { ["5.56x45"] = 100, [".300 BLK"] = 100, [".50 Beo"] = 8 }, retention = false }
    self.parts.wpn_fps_ass_tecci_ns_standard.name_id = "bm_wp_tecci_ns_standard"
    self.parts.wpn_fps_ass_tecci_ns_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_ns_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_ns_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_tecci_ns_special.stats = { concealment = 4, weight = 2, length = 2, md_code = {0,0,0,3,0} }
    self.parts.wpn_fps_ass_tecci_o_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_o_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_ass_tecci_o_standard.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_acog, self.nqr.i_f_spot, self.nqr.i_f_c96))
    self.parts.wpn_fps_ass_tecci_o_standard.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_ass_tecci_s_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_s_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_s_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_s_standard.name_id = "bm_wp_fps_ass_tecci_s_standard"
    self.parts.wpn_fps_ass_tecci_s_standard.stats = { concealment = 0, weight = 4, length = 5.049, shouldered = true }
    self.parts.wpn_fps_ass_tecci_s_legend.stats = { concealment = 0, weight = 0, length = 5 }
    self.parts.wpn_fps_ass_tecci_upper_reciever.override = { wpn_fps_upper_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_ass_tecci_upper_reciever.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_tecci_vg_standard.texture_bundle_folder = "opera"
    self.parts.wpn_fps_ass_tecci_vg_standard.dlc = "opera"
    self.parts.wpn_fps_ass_tecci_vg_standard.pcs = {}
    self.parts.wpn_fps_ass_tecci_vg_standard.name_id = "bm_wp_fps_ass_tecci_vg_standard"
    self.parts.wpn_fps_ass_tecci_vg_standard.stats = { concealment = 0, weight = 1 }
    self.wpn_fps_ass_tecci.regression = "tecci"
    self.wpn_fps_ass_tecci.unit = "units/payday2/weapons/wpn_fps_ass_m4/wpn_fps_ass_m4"
    self.wpn_fps_ass_tecci.animations = {
		reload = "reload",
		fire = "recoil",
		fire_steelsight = "recoil",
		reload_not_empty = "reload_not_empty",
		magazine_empty = "last_recoil",
	}
    self.wpn_fps_ass_tecci.override = {
        wpn_fps_snp_victor_s_hera = { forbids = table.without(self.nqr.all_m4_grips, "wpn_fps_ass_tecci_g_standard") },
        --wpn_fps_ass_tecci_m_drum = { animations = { reload_not_empty = "reload_not_empty", reload = "reload" } },
    }
    table.insert(self.wpn_fps_ass_tecci.uses_parts, "wpn_fps_ass_contraband_fg_standard")
    table.insert(self.wpn_fps_ass_tecci.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_tecci.uses_parts, "wpn_fps_remove_ironsight")

    self.parts.wpn_fps_ass_vhs_b_short.override = { wpn_fps_ass_vhs_b_silenced = { a_obj = "a_b", parent = false } }
    self.parts.wpn_fps_ass_vhs_b_short.stats = { concealment = 0, weight = -2, barrel_length = 16.1 }
    self.parts.wpn_fps_ass_vhs_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 19.7 }
    self.parts.wpn_fps_ass_vhs_b_sniper.override = {}
    self.parts.wpn_fps_ass_vhs_b_sniper.stats = { concealment = 0, weight = 3, barrel_length = 24 } --roughly
    self.parts.wpn_fps_ass_vhs_body.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_ass_vhs_m.animations = nil
    self.parts.wpn_fps_ass_vhs_m.stats = { concealment = 9, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["5.56x45"] = 30, [".300 BLK"] = 0, [".50 Beo"] = 0 } }
    self.parts.wpn_fps_ass_vhs_ns_vhs.pcs = {}
    self.parts.wpn_fps_ass_vhs_ns_vhs.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_vhs_ns_vhs_no.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_vhs_b_silenced.type = "barrel_ext"
    self.parts.wpn_fps_ass_vhs_b_silenced.a_obj = "a_ns"
    self.parts.wpn_fps_ass_vhs_b_silenced.parent = "barrel"
    self.parts.wpn_fps_ass_vhs_b_silenced.forbids = {}
    self.parts.wpn_fps_ass_vhs_b_silenced.stats = deep_clone(self.nqr.sps_stats.medium2)
    self.parts.wpn_fps_ass_vhs_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_ass_vhs_o_standard.forbids, table.with(self.nqr.all_snoptics, {"wpn_fps_upg_o_acog"}))
    self.parts.wpn_fps_ass_vhs_o_standard.stats = { concealment = 0, weight = 1 }
    table.insert(self.wpn_fps_ass_vhs.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_vhs.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_ass_vhs.uses_parts, "wpn_fps_ass_g36_m_standard")
    table.addto(self.wpn_fps_ass_vhs.uses_parts, table.without(self.nqr.all_m4_mags, {"wpn_fps_upg_m4_m_drum", "wpn_fps_ass_tecci_m_drum"}))
    table.addto(self.wpn_fps_ass_vhs.uses_parts, self.nqr.all_vertical_grips)

    self.parts.wpn_fps_smg_hajk_b_short.stats = { concealment = 0, weight = -1, barrel_length = 10.9 }
    self.parts.wpn_fps_smg_hajk_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 12.5 }
    self.parts.wpn_fps_smg_hajk_b_standard.stats = { concealment = 0, weight = 1, barrel_length = 14 } --roughly
    self.parts.wpn_fps_smg_hajk_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_smg_hajk_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_hajk_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_hajk_ns_standard.pcs = {}
	self.parts.wpn_fps_smg_hajk_ns_standard.dlc = "born"
    self.parts.wpn_fps_smg_hajk_ns_standard.texture_bundle_folder = "born"
    self.parts.wpn_fps_smg_hajk_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_smg_hajk_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_smg_hajk_o_standard.forbids, self.nqr.all_snoptics)
    self.parts.wpn_fps_smg_hajk_o_standard.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_smg_hajk_s_standard.stats = { concealment = 0, weight = 4, length = 9, shouldered = true, shoulderable = true, cheek = 1 }
    self.parts.wpn_fps_smg_hajk_vg_moe.texture_bundle_folder = "born"
    self.parts.wpn_fps_smg_hajk_vg_moe.dlc = "born"
    self.parts.wpn_fps_smg_hajk_vg_moe.pcs = {}
    self.parts.wpn_fps_smg_hajk_vg_moe.name_id = "bm_wp_fps_smg_hajk_vg_moe"
    self.parts.wpn_fps_smg_hajk_vg_moe.stats = { concealment = 0, weight = 1 }
    table.insert(self.wpn_fps_smg_hajk.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_hajk.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_smg_hajk.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_smg_hajk.uses_parts, self.nqr.all_m4_mags)
    table.addto(self.wpn_fps_smg_hajk.uses_parts, self.nqr.all_angled_sights)
--------

----DMR
    self.parts.wpn_fps_ass_scar_b_long.stats = { concealment = 4, weight = 3, barrel_length = 20 }
    self.parts.wpn_fps_ass_scar_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_ass_scar_b_short.override = { wpn_fps_ass_scar_fg_railext = { forbids = { "wpn_fps_remove_ns" } } }
    local scar_fg_bxs = {
        "wpn_fps_ass_scar_ns_standard",
        "wpn_fps_upg_ns_ass_smg_small",
        "wpn_fps_upg_ns_pis_small",
        "wpn_fps_upg_ns_pis_medium_slim",
        "wpn_fps_ass_l85a2_ns_standard",
        "wpn_fps_upg_ns_pis_medium_gem",
    }
    table.addto(self.parts.wpn_fps_ass_scar_b_short.override.wpn_fps_ass_scar_fg_railext.forbids, table.without(self.nqr.all_bxs, scar_fg_bxs))
    self.parts.wpn_fps_ass_scar_b_short.stats = { concealment = -2, weight = -2, barrel_length = 13 }
    self.parts.wpn_fps_ass_scar_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_ass_scar_fg_railext.stats = { concealment = 5, weight = 2 }
    self.parts.wpn_fps_ass_scar_m_standard.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    --self.parts.wpn_fps_ass_scar_ns_short.stats = { concealment = 3, weight = 2, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_scar_ns_standard.pcs = {}
    self.parts.wpn_fps_ass_scar_ns_standard.texture_bundle_folder = "gage_pack"
    self.parts.wpn_fps_ass_scar_ns_standard.dlc = "gage_pack"
    self.parts.wpn_fps_ass_scar_ns_standard.stats = { concealment = 3, weight = 2, length = 3, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_scar_o_flipups_down.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_scar_o_flipups_up.forbids = {}
    table.addto(self.parts.wpn_fps_ass_scar_o_flipups_up.forbids, self.nqr.i_f_base)
    self.parts.wpn_fps_ass_scar_o_flipups_up.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_ass_scar_s_sniper.stats = { concealment = 3, weight = 8, length = 11, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_ass_scar_s_standard.stats = { concealment = 0, weight = 3, length = 9.08, shouldered = true, shoulderable = true, cheek = 1.5 }
    self.wpn_fps_ass_scar.adds = {}
    self.wpn_fps_ass_scar.override = {
        wpn_fps_fold_ironsight = {
            unit = self.parts.wpn_fps_ass_scar_o_flipups_down.unit,
            third_unit = self.parts.wpn_fps_ass_scar_o_flipups_down.third_unit,
            stats = { concealment = 2, weight = 1 },
        },
    }
    table.delete(self.wpn_fps_ass_scar.default_blueprint, "wpn_fps_upg_vg_ass_smg_afg")
    table.swap(self.wpn_fps_ass_scar.default_blueprint, "wpn_fps_upg_m4_g_hgrip", "wpn_fps_upg_m4_g_standard")
    table.insert(self.wpn_fps_ass_scar.uses_parts, "wpn_fps_upg_m4_g_standard")
    table.insert(self.wpn_fps_ass_scar.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_scar.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_scar.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_ass_scar.uses_parts, "wpn_fps_fold_ironsight")
    table.addto(self.wpn_fps_ass_scar.uses_parts, self.nqr.all_m4_grips)

    self.parts.wpn_fps_ass_shak12_b_dummy.stats = { concealment = 0, weight = 0, barrel_length = 14.7 } --roughly
    self.parts.wpn_fps_ass_shak12_body_lower.stats = { concealment = 0, weight = 0, length = 12, shouldered = true }
    self.parts.wpn_fps_ass_shak12_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_body_vks.pcs = nil --todo
    self.parts.wpn_fps_ass_shak12_body_vks.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_dh_standard2.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_dh_vks.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_ejector_standard.type = "ejector"
    self.parts.wpn_fps_ass_shak12_ejector_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_fg_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_m_magazine25.bullet_objects = { amount = 1, prefix = "g_bullet" }
    self.parts.wpn_fps_ass_shak12_m_magazine25.stats = { concealment = 14, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = 20, retention = false }
    self.parts.wpn_fps_ass_shak12_ns_muzzle.stats = { concealment = 3, weight = 2, length = 2, md_code = {0,0,0,3,0} }
    self.parts.wpn_fps_ass_shak12_ns_suppressor.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_ass_shak12_ns_suppressor.stats = { concealment = 60, weight = 16, length = 20, md_code = {6,0,0,0,0} }
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.name_id = self.parts.wpn_fps_remove_extra.name_id
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.unit = fantom_unit
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.dlc = "nqr_dlc"
    --self.parts.wpn_fps_ass_shak12_o_carry_dummy.is_a_unlockable = true
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.depends_on = nil
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.adds = {}
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.forbids = {}
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.override = { wpn_fps_ass_shak12_o_carry_sight = { stats = {} } }
    self.parts.wpn_fps_ass_shak12_o_carry_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_shak12_o_carry_sight.unit = fantom_unit
    self.parts.wpn_fps_ass_shak12_o_carry_sight.type = "ironsight"
    self.parts.wpn_fps_ass_shak12_o_carry_sight.sub_type = "ironsight_extrable"
    self.parts.wpn_fps_ass_shak12_o_carry_sight.stats = { concealment = 0, weight = 0, sightheight = 0.6 }
    self.parts.wpn_fps_ass_shak12_o_sight.type = "extra"
    self.parts.wpn_fps_ass_shak12_o_sight.sub_type = "ironsight"
    --self.parts.wpn_fps_ass_shak12_o_sight.adds = { "wpn_fps_ass_shak12_o_carry_sight" }
    self.parts.wpn_fps_ass_shak12_o_sight.forbids = {}
    self.parts.wpn_fps_ass_shak12_o_sight.override = { wpn_fps_o_blank = { a_obj = "a_or" } }
    self.parts.wpn_fps_ass_shak12_o_sight.stats = { concealment = 0, weight = 4, sightheight = 4.7 }--
    self.wpn_fps_ass_shak12.forbids = {}
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.parts.wpn_fps_ass_shak12_o_sight.override[k] = { a_obj = "a_or" } end end
    --table.insert(self.wpn_fps_ass_shak12.default_blueprint, "wpn_fps_ass_shak12_o_carry_sight") moved to dflt_default_blueprints
    --table.delete(self.wpn_fps_ass_shak12.uses_parts, "wpn_fps_ass_shak12_o_carry_dummy")
    --table.delete(self.wpn_fps_ass_shak12.default_blueprint, "wpn_fps_ass_shak12_o_carry_sight")
    table.deletefrom(self.wpn_fps_ass_shak12.uses_parts, self.nqr.all_bxs)
    table.insert(self.wpn_fps_ass_shak12.uses_parts, "wpn_fps_ass_shak12_o_carry_sight")
    table.insert(self.wpn_fps_ass_shak12.uses_parts, "wpn_fps_upg_a_subfmj")
    table.addto(self.wpn_fps_ass_shak12.uses_parts, self.nqr.all_bxs_bbr)
    table.addto(self.wpn_fps_ass_shak12.uses_parts, self.nqr.all_vertical_grips)

    self.parts.wpn_fps_upg_o_m14_scopemount.depends_on = nil
    self.parts.wpn_fps_upg_o_m14_scopemount.rails = { "top" }
    --self.parts.wpn_fps_upg_o_m14_scopemount.override = {}
    --for i, k in pairs(self.nqr.all_sights) do self.parts.wpn_fps_upg_o_m14_scopemount.override[k] = { a_obj = "a_o_sm" } end
    self.parts.wpn_fps_upg_o_m14_scopemount.override = { wpn_fps_o_pos_a_o_sm = { adds = {} } }
    self.parts.wpn_fps_upg_o_m14_scopemount.stats = { concealment = 0, weight = 2, sightpos = {-0.03, -1.34, 0} } ---5.21+3.87
    self.parts.wpn_fps_ass_m14_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.3, md_code = {0,1,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_m14_b_ruger.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_m14_b_legendary.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_ass_m14_m_standard.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_ass_m14_body_dmr.rails = { "top" }
    self.parts.wpn_fps_ass_m14_body_dmr.needs_sight_pos = true
    self.parts.wpn_fps_ass_m14_body_dmr.forbids = { "wpn_fps_ass_m14_body_ruger_rail" }
    self.parts.wpn_fps_ass_m14_body_dmr.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_fps_ass_m14_body_dmr.stats = { concealment = 0, weight = 0, length = 20, shouldered = true }
    self.parts.wpn_fps_ass_m14_body_ebr.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_ass_m14_body_ebr.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_m14_body_ebr.needs_sight_pos = true
    self.parts.wpn_fps_ass_m14_body_ebr.forbids = { "wpn_fps_ass_m14_body_ruger_rail", "wpn_fps_ass_m14_body_ruger_rail2" }
    self.parts.wpn_fps_ass_m14_body_ebr.override = { wpn_fps_o_pos_fg = { adds = {} }, wpn_fps_extra2_lock_gadgets = { forbids = {} } }
    self.parts.wpn_fps_ass_m14_body_ebr.stats = { concealment = 0, weight = 15, length = 20.014, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_m14_body_jae.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_m14_body_jae.needs_sight_pos = true
    self.parts.wpn_fps_ass_m14_body_jae.forbids = { "wpn_fps_ass_m14_body_ruger_rail", "wpn_fps_ass_m14_body_ruger_rail2" }
    self.parts.wpn_fps_ass_m14_body_jae.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_fps_ass_m14_body_jae.stats = { concealment = 0, weight = 3, length = 21, shouldered = true }
    self.parts.wpn_fps_ass_m14_body_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_m14_body_ruger.type = "exclusive_set"
    self.parts.wpn_fps_ass_m14_body_ruger.forbids = { "wpn_fps_ass_m14_body_ebr", "wpn_fps_ass_m14_body_jae" }
    self.parts.wpn_fps_ass_m14_body_ruger.override.wpn_fps_ass_m14_body_dmr = { unit = fantom_unit, forbids = {}, override = {} }
    self.parts.wpn_fps_ass_m14_body_ruger.override.wpn_fps_ass_m14_body_ebr = { override = {}, }
    self.parts.wpn_fps_ass_m14_body_ruger.override.wpn_fps_ass_m14_body_jae = { override = {}, }
    self.parts.wpn_fps_ass_m14_body_ruger.override.wpn_fps_ass_m14_b_standard.stats = {}
    self.parts.wpn_fps_ass_m14_body_ruger.visibility = { { objects = { g_side_rail = false } } }
    self.parts.wpn_fps_ass_m14_body_ruger.stats = { concealment = 0, weight = -15, length = 20.010, shouldered = true, shoulderable = true, barrel_length = 13 }
    self.parts.wpn_fps_ass_m14_body_ruger_rail.name_id = "bm_wp_m14_body_ruger_rail"
    self.parts.wpn_fps_ass_m14_body_ruger_rail.pcs = {}
    self.parts.wpn_fps_ass_m14_body_ruger_rail.type = "extra4"
    self.parts.wpn_fps_ass_m14_body_ruger_rail.rails = { "top" }
    self.parts.wpn_fps_ass_m14_body_ruger_rail.needs_sight_pos = "wpn_fps_o_pos_fg"
    self.parts.wpn_fps_ass_m14_body_ruger_rail.forbids = {}
    self.parts.wpn_fps_ass_m14_body_ruger_rail.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_fps_ass_m14_body_ruger_rail.visibility = { { objects = { g_ruger = false, g_side_rail = false } } }
    self.parts.wpn_fps_ass_m14_body_ruger_rail.stats = { concealment = 3, weight = 1 }
    self.parts.wpn_fps_ass_m14_body_ruger_rail2 = deep_clone(self.parts.wpn_fps_ass_m14_body_ruger)
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.name_id = "bm_wp_m14_body_ruger_rail2"
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.type = "extra2"
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.forbids = {}
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.override = {}
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.visibility = { { objects = { g_ruger = false } } }
    self.parts.wpn_fps_ass_m14_body_ruger_rail2.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_ass_m14_body_lower.sub_type = "ironsight"
    self.parts.wpn_fps_ass_m14_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_m14_body_lower_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_m14_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_m14_body_upper_legendary.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_ass_m14.override = {
        wpn_fps_o_pos_fg = { override = { wpn_fps_upg_o_m14_scopemount = { stats = table.copy_append(self.parts.wpn_fps_upg_o_m14_scopemount.stats, {sightpos = false}) }, } },
    }
    table.insert(self.wpn_fps_ass_m14.default_blueprint, 1, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_ass_m14.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_m14.default_blueprint, 1, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_extra3_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_ass_m14_body_ruger_rail")
    table.insert(self.wpn_fps_ass_m14.uses_parts, "wpn_fps_ass_m14_body_ruger_rail2")

    self.parts.wpn_fps_ass_g3_b_short.custom_stats = nil
    self.parts.wpn_fps_ass_g3_b_short.stats = { concealment = 0, weight = -3, barrel_length = 12.4, md_code = {0,2,0,0,0}, md_bulk = {1,1} }
    self.parts.wpn_fps_ass_g3_b_long.stats = { concealment = 0, weight = 0, barrel_length = 17.7, md_code = {0,2,0,0,0}, md_bulk = {1,1} }
    self.parts.wpn_fps_ass_g3_b_sniper.adds = {}
    self.parts.wpn_fps_ass_g3_b_sniper.override = nil
    self.parts.wpn_fps_ass_g3_b_sniper.stats = { concealment = 0, weight = 5, barrel_length = 25.6 }
    self.parts.wpn_fps_ass_g3_body_lower.stats = { concealment = 0, weight = 0, length = 11 }
    self.parts.wpn_fps_ass_g3_body_rail.pcs = {}
    self.parts.wpn_fps_ass_g3_body_rail.name_id = "bm_wp_hk_sightrail"
    self.parts.wpn_fps_ass_g3_body_rail.type = "extra"
    self.parts.wpn_fps_ass_g3_body_rail.rails = { "top" }
    self.parts.wpn_fps_ass_g3_body_rail.stats = { concealment = 3, weight = 1 }
    self.parts.wpn_fps_ass_g3_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g3_fg_bipod.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g3_fg_psg.stats = { concealment = 0, weight = -1 }
    self.parts.wpn_fps_ass_g3_fg_railed.rails = { "side", "bottom" }
    self.parts.wpn_fps_ass_g3_fg_railed.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_g3_fg_retro.visibility = { { objects = { g_belt_lod0 = false, g_buckle_lod0 = false } } }
    self.parts.wpn_fps_ass_g3_fg_retro.stats = { concealment = 0, weight = -1 }
    self.parts.wpn_fps_ass_g3_fg_retro_sling = deep_clone(self.parts.wpn_fps_ass_g3_fg_retro)
    self.parts.wpn_fps_ass_g3_fg_retro_sling.visibility = { { objects = { g_fg_lod0 = false, g_bolt_lod0 = false } } }
    self.parts.wpn_fps_ass_g3_fg_retro_sling.name_id = "bm_wp_g3_fg_retro_sling"
    self.parts.wpn_fps_ass_g3_fg_retro_sling.type = "wep_cos"
    self.parts.wpn_fps_ass_g3_fg_retro_sling.stats = { concealment = 2, weight = 0 }
    self.parts.wpn_fps_ass_g3_fg_retro_plastic.visibility = { { objects = { g_belt_lod0 = false, g_buckle_lod0 = false } } }
    self.parts.wpn_fps_ass_g3_fg_retro_plastic.stats = { concealment = 0, weight = -2 }
    self.parts.wpn_fps_ass_g3_fg_retro_plastic_sling = deep_clone(self.parts.wpn_fps_ass_g3_fg_retro_plastic)
    self.parts.wpn_fps_ass_g3_fg_retro_plastic_sling.visibility = { { objects = { g_fg_lod0 = false, g_bolt_lod0 = false } } }
    self.parts.wpn_fps_ass_g3_fg_retro_plastic_sling.name_id = "bm_wp_g3_fg_retro_plastic_sling"
    self.parts.wpn_fps_ass_g3_fg_retro_plastic_sling.type = "wep_cos"
    self.parts.wpn_fps_ass_g3_fg_retro_plastic_sling.stats = { concealment = 2, weight = 0 }
    self.parts.wpn_fps_ass_g3_g_retro.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_g3_g_sniper.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_g3_m_mag.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_g3_m_short = deep_clone(self.parts.wpn_fps_ass_g3_m_mag)
    self.parts.wpn_fps_g3_m_short.unit = "units/pd2_dlc_gage_assault/weapons/wpn_fps_ass_g3_pts/wpn_fps_ass_g3_m_mag_psg"
    self.parts.wpn_fps_g3_m_short.third_unit = "units/pd2_dlc_gage_assault/weapons/wpn_fps_ass_g3_pts/wpn_third_ass_g3_m_mag_psg"
    self.parts.wpn_fps_g3_m_short.is_a_unlockable = true
    self.parts.wpn_fps_g3_m_short.texture_bundle_folder = "gage_pack_assault"
    self.parts.wpn_fps_g3_m_short.dlc = "gage_pack_assault"
    self.parts.wpn_fps_g3_m_short.pcs = {}
    self.parts.wpn_fps_g3_m_short.stats = { concealment = 5, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 }
    self.parts.wpn_fps_ass_g3_s_sniper.stats = { concealment = 0, weight = 2, length = 12, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_ass_g3_s_wood.stats = { concealment = 0, weight = 1, length = 10, shouldered = true }
    self.wpn_fps_ass_g3.adds = {}
    table.insert(self.wpn_fps_ass_g3.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_g3.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_g3.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_ass_g3_body_rail")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_smg_mp5_body_rail")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_g3_m_short")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_ass_g3_fg_retro_sling")
    table.insert(self.wpn_fps_ass_g3.uses_parts, "wpn_fps_ass_g3_fg_retro_plastic_sling")

    self.parts.wpn_fps_ass_galil_sightrail = deep_clone(self.parts.wpn_fps_shot_r870_ris_special)
    self.parts.wpn_fps_ass_galil_sightrail.pcs = {}
    self.parts.wpn_fps_ass_galil_sightrail.name_id = "bm_wp_galil_sightrail"
    self.parts.wpn_fps_ass_galil_sightrail.rails = { "top" }
    self.parts.wpn_fps_ass_galil_sightrail.forbids = { "wpn_fps_ass_galil_fg_fab" }
    self.parts.wpn_fps_ass_galil_sightrail.override = { wpn_fps_o_pos_extra = { adds = {} } }
    self.parts.wpn_fps_ass_galil_sightrail.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_ass_galil_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_ass_galil_body_standard.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_ass_galil_fg_standard.type = "foregrip"
    self.parts.wpn_fps_ass_galil_fg_standard.forbids = {}
    self.parts.wpn_fps_ass_galil_fg_standard.override = {} --a_ns_s
    self.parts.wpn_fps_ass_galil_fg_standard.visibility = { { objects = { g_b_lod0 = false, g_bipod_lod0 = false, g_carryhandle_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_galil_b_standard = deep_clone(self.parts.wpn_fps_ass_galil_fg_standard)
    self.parts.wpn_fps_ass_galil_b_standard.type = "barrel"
    self.parts.wpn_fps_ass_galil_b_standard.unit = self.parts.wpn_fps_ass_galil_fg_fab.unit
    self.parts.wpn_fps_ass_galil_b_standard.override = {}
    self.parts.wpn_fps_ass_galil_b_standard.visibility = { { objects = { g_fg4_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.1, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_galil_bipod = deep_clone(self.parts.wpn_fps_ass_galil_fg_standard)
    self.parts.wpn_fps_ass_galil_bipod.type = "bipod"
    self.parts.wpn_fps_ass_galil_bipod.visibility = { { objects = { g_b_lod0 = false, g_fg1_lod0 = false, g_carryhandle_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_bipod.stats = { concealment = 0, weight = 5 }
    self.parts.wpn_fps_ass_galil_carryhandle = deep_clone(self.parts.wpn_fps_ass_galil_fg_standard)
    self.parts.wpn_fps_ass_galil_carryhandle.type = "wep_cos"
    self.parts.wpn_fps_ass_galil_carryhandle.visibility = { { objects = { g_b_lod0 = false, g_fg1_lod0 = false, g_bipod_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_carryhandle.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_ass_galil_fg_fab.type = "foregrip"
    self.parts.wpn_fps_ass_galil_fg_fab.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_galil_fg_fab.needs_sight_pos = true
    self.parts.wpn_fps_ass_galil_fg_fab.forbids = { "wpn_fps_ass_galil_sightrail" }
    self.parts.wpn_fps_ass_galil_fg_fab.override = {}
    self.parts.wpn_fps_ass_galil_fg_fab.override.wpn_fps_ass_galil_bipod = { unit = fantom_unit, stats = {}, } --todo stats_override
    self.parts.wpn_fps_ass_galil_fg_fab.override.wpn_fps_ass_galil_carryhandle = { unit = fantom_unit, stats = {}, }
    self.parts.wpn_fps_ass_galil_fg_fab.override.wpn_fps_o_pos_fg = { adds = {}, override = { wpn_fps_o_blank = { a_obj = "a_os_fab" } } }
    for i, k in pairs(self.nqr.all_sights_no_optics) do
        if not self.parts[k].parent then self.parts.wpn_fps_ass_galil_fg_fab.override.wpn_fps_o_pos_fg.override[k] = { a_obj = "a_os_fab" } end
    end
    self.parts.wpn_fps_ass_galil_fg_fab.visibility = { { objects = { g_b_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_fab.stats = { concealment = 0, weight = 0, sightheight = 0.3 }
    self.parts.wpn_fps_ass_galil_fg_mar.type = "exclusive_set"
    self.parts.wpn_fps_ass_galil_fg_mar.rails = { "top" }
    self.parts.wpn_fps_ass_galil_fg_mar.needs_sight_pos = true
    --self.parts.wpn_fps_ass_galil_fg_mar.adds = { "wpn_fps_ass_galil_b_mar" }
    self.parts.wpn_fps_ass_galil_fg_mar.forbids = { "wpn_fps_ass_galil_b_sar", "wpn_fps_ass_galil_b_sniper", "wpn_fps_ass_galil_fg_fab", "wpn_fps_ass_galil_fg_sar", "wpn_fps_ass_galil_fg_sniper", }
    self.parts.wpn_fps_ass_galil_fg_mar.override = {}
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_fg_standard = { unit = fantom_unit, stats = {}, }
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_fg_fab = { override = {}, }
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_b_standard = {}
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_b_standard.unit = self.parts.wpn_fps_ass_galil_fg_mar.unit
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_b_standard.visibility = { { objects = { g_fg3_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_b_standard.stats = {}
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_bipod = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_ass_galil_carryhandle = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_o_pos_fg = { adds = {}, override = {
        wpn_fps_o_blank = { a_obj = "a_os_mar" },
        wpn_fps_ass_galil_sightrail = { stats = table.copy_append(self.parts.wpn_fps_ass_galil_sightrail.stats, {sightheight = 0}) },
    } }
    for i, k in pairs(self.nqr.all_sights_no_optics) do
        if not self.parts[k].parent then self.parts.wpn_fps_ass_galil_fg_mar.override.wpn_fps_o_pos_fg.override[k] = { a_obj = "a_os_mar" } end
    end
    self.parts.wpn_fps_ass_galil_fg_mar.visibility = { { objects = { g_b_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_mar.stats = { concealment = 0, weight = 0, sightheight = -1, barrel_length = 8.26, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_galil_b_mar = deep_clone(self.parts.wpn_fps_ass_galil_fg_mar)
    self.parts.wpn_fps_ass_galil_b_mar.type = "barrel"
    self.parts.wpn_fps_ass_galil_b_mar.adds = {}
    self.parts.wpn_fps_ass_galil_b_mar.forbids = {}
    self.parts.wpn_fps_ass_galil_b_mar.override = {}
    self.parts.wpn_fps_ass_galil_b_mar.visibility = { { objects = { g_fg3_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_b_mar.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_galil_fg_sar.type = "foregrip"
    self.parts.wpn_fps_ass_galil_fg_sar.forbids = {}
    self.parts.wpn_fps_ass_galil_fg_sar.override = {}
    self.parts.wpn_fps_ass_galil_fg_sar.override.wpn_fps_ass_galil_bipod = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_sar.override.wpn_fps_ass_galil_carryhandle = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_sar.visibility = { { objects = { g_b_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_sar.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_galil_b_sar = deep_clone(self.parts.wpn_fps_ass_galil_fg_sar)
    self.parts.wpn_fps_ass_galil_b_sar.type = "barrel"
    --self.parts.wpn_fps_ass_galil_b_sar.forbids = { "wpn_fps_ass_galil_b_mar" }
    --self.parts.wpn_fps_ass_galil_b_sar.override = { wpn_fps_ass_galil_b_mar = { unit = self.parts.wpn_fps_ass_galil_b_sar.unit } }
    --self.parts.wpn_fps_ass_galil_b_sar.override = { wpn_fps_ass_galil_fg_mar = { stats = { concealment = 0, weight = 0, barrel_length = 13.1, md_code = {0,2,0,0,0}, md_bulk = {1, 1} } } }
    self.parts.wpn_fps_ass_galil_b_sar.override = {}
    self.parts.wpn_fps_ass_galil_b_sar.visibility = { { objects = { g_fg2_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_b_sar.stats = { concealment = 0, weight = 0, barrel_length = 13.1, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_galil_fg_sniper.type = "foregrip"
    self.parts.wpn_fps_ass_galil_fg_sniper.override = {}
    self.parts.wpn_fps_ass_galil_fg_sniper.override.wpn_fps_ass_galil_bipod = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_sniper.override.wpn_fps_ass_galil_carryhandle = { unit = fantom_unit, stats = {} }
    self.parts.wpn_fps_ass_galil_fg_sniper.visibility = { { objects = { g_b2_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_fg_sniper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_galil_b_sniper_dummy = deep_clone(self.parts.wpn_fps_ass_galil_b_standard) --todo
    self.parts.wpn_fps_ass_galil_b_sniper_dummy.unit = self.parts.wpn_fps_lmg_hk51b_b_standard.unit
    self.parts.wpn_fps_ass_galil_b_sniper_dummy.adds = {}
    self.parts.wpn_fps_ass_galil_b_sniper_dummy.forbids = {}
    self.parts.wpn_fps_ass_galil_b_sniper_dummy.override = {}
    self.parts.wpn_fps_ass_galil_b_sniper_dummy.stats = {}
    self.parts.wpn_fps_ass_galil_b_sniper = deep_clone(self.parts.wpn_fps_ass_galil_fg_sniper)
    self.parts.wpn_fps_ass_galil_b_sniper.type = "barrel"
    self.parts.wpn_fps_ass_galil_b_sniper.adds = { "wpn_fps_ass_galil_b_sniper_dummy" }
    self.parts.wpn_fps_ass_galil_b_sniper.forbids = {}
    self.parts.wpn_fps_ass_galil_b_sniper.override = {}
    self.parts.wpn_fps_ass_galil_b_sniper.visibility = { { objects = { g_fg5_lod0 = false } } }
    self.parts.wpn_fps_ass_galil_b_sniper.stats = { concealment = 0, weight = 0, barrel_length = 18.1, md_code = {0,1,2,0,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_ass_galil_g_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_ass_galil_g_sniper.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_ass_galil_m_standard.stats = { concealment = 10, weight = 3, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 25 }
    self.parts.wpn_fps_ass_galil_s_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_galil_s_fab.forbids = { "wpn_fps_ass_galil_s_wood", "wpn_fps_ass_galil_s_plastic" }
    self.parts.wpn_fps_ass_galil_s_fab.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true, cheek = 1.5 }
    self.parts.wpn_fps_ass_galil_s_light.forbids = { "wpn_fps_ass_galil_s_wood", "wpn_fps_ass_galil_s_plastic" }
    self.parts.wpn_fps_ass_galil_s_light.stats = { concealment = 0, weight = 0, length = 11, shouldered = true, shoulderable = true, cheek = 1 }
    self.parts.wpn_fps_ass_galil_s_skeletal.forbids = { "wpn_fps_ass_galil_s_wood", "wpn_fps_ass_galil_s_plastic" }
    self.parts.wpn_fps_ass_galil_s_skeletal.stats = { concealment = 0, weight = 0, length = 11, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_galil_s_sniper.forbids = { "wpn_fps_ass_galil_s_wood", "wpn_fps_ass_galil_s_plastic" }
    self.parts.wpn_fps_ass_galil_s_sniper.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true, cheek = 1 }
    self.parts.wpn_fps_ass_galil_s_wood.type = "stock_addon" --todo
    self.parts.wpn_fps_ass_galil_s_wood.stats = { concealment = 0, weight = 0, cheek = 1 }
    self.parts.wpn_fps_ass_galil_s_plastic.type = "stock_addon" --todo
    self.parts.wpn_fps_ass_galil_s_plastic.stats = { concealment = 0, weight = 0, cheek = 1 }
    self.wpn_fps_ass_galil.adds = {}
    self.wpn_fps_ass_galil.override = {
        wpn_fps_remove_s = { forbids = { "wpn_fps_ass_galil_s_wood", "wpn_fps_ass_galil_s_plastic" } },
        wpn_fps_o_blank = { override = {} },
        wpn_fps_o_pos_extra = { override = { wpn_fps_ass_galil_fg_mar = { stats = table.copy_append(self.parts.wpn_fps_ass_galil_fg_mar.stats, {sightheight = 0}) } } },
    }
    table.deletefrom(self.wpn_fps_ass_galil.uses_parts, self.nqr.all_snoptics)
    --table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_b_mar")
    --table.delete(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_fg_mar")
    --table.insert(self.wpn_fps_ass_galil.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    --table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, 1, "wpn_fps_o_pos_extra")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_o_pos_extra")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, "wpn_fps_ass_galil_b_standard")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_b_standard")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, "wpn_fps_ass_galil_bipod")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_bipod")
    table.insert(self.wpn_fps_ass_galil.default_blueprint, "wpn_fps_ass_galil_carryhandle")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_carryhandle")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_b_sar")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_b_sniper")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_ass_galil_sightrail")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_remove_bipod")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_remove_cos")
    table.insert(self.wpn_fps_ass_galil.uses_parts, "wpn_fps_o_pos_fg")

    self.parts.wpn_fps_ass_fal_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_ass_fal_fg_standard.type = "foregrip"
    self.parts.wpn_fps_ass_fal_fg_standard.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_b_standard = deep_clone(self.parts.wpn_fps_ass_fal_fg_standard)
    self.parts.wpn_fps_ass_fal_b_standard.type = "barrel"
    --self.parts.wpn_fps_ass_fal_b_standard.unit = self.parts.wpn_fps_ass_galil_fg_fab.unit
    self.parts.wpn_fps_ass_fal_b_standard.visibility = { { objects = { g_frontgrip02_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18, md_code = {0,2,0,0,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_ass_fal_fg_01.type = "exclusive_set"
    self.parts.wpn_fps_ass_fal_fg_01.name_id = "bm_wp_fal_fg_01"
    self.parts.wpn_fps_ass_fal_fg_01.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_fal_fg_01.forbids = { "wpn_fps_ass_fal_b_03", "wpn_fps_ass_fal_fg_03", "wpn_fps_ass_fal_fg_04", "wpn_fps_ass_fal_fg_wood" }
    self.parts.wpn_fps_ass_fal_fg_01.override = {
        wpn_fps_ass_fal_fg_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 }, },
        wpn_fps_ass_fal_b_standard = {
            unit = self.parts.wpn_fps_ass_fal_fg_01.unit,
            visibility = { { objects = { g_frontgrip02_lod0 = false } } },
            stats = { concealment = 0, weight = 0 },
        },
    }
    self.parts.wpn_fps_ass_fal_fg_01.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_fg_01.stats = { concealment = 0, weight = 0, barrel_length = 11, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_fal_b_01 = deep_clone(self.parts.wpn_fps_ass_fal_fg_01)
    self.parts.wpn_fps_ass_fal_b_01.type = "barrel"
    self.parts.wpn_fps_ass_fal_b_01.visibility = { { objects = { g_frontgrip_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_b_01.stats = { concealment = 0, weight = 0, barrel_length = 11, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_ass_fal_fg_03.type = "foregrip"
    --self.parts.wpn_fps_ass_fal_fg_03.adds = { "wpn_fps_ass_fal_b_03_dummy" }
    self.parts.wpn_fps_ass_fal_fg_03.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_fg_03.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_b_03_dummy = deep_clone(self.parts.wpn_fps_ass_fal_b_standard)
    self.parts.wpn_fps_ass_fal_b_03_dummy.type = "dummy"
    self.parts.wpn_fps_ass_fal_b_03_dummy.unit = self.parts.wpn_fps_lmg_hk51b_b_fluted.unit
    self.parts.wpn_fps_ass_fal_b_03_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_b_03 = deep_clone(self.parts.wpn_fps_ass_fal_fg_03)
    self.parts.wpn_fps_ass_fal_b_03.type = "barrel"
    self.parts.wpn_fps_ass_fal_b_03.visibility = { { objects = { g_frontgrip03_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_b_03.stats = { concealment = 0, weight = 0, barrel_length = 21, md_code = {0,2,0,0,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_ass_fal_fg_04.type = "foregrip"
    self.parts.wpn_fps_ass_fal_fg_04.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_ass_fal_fg_04.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_fg_wood.type = "foregrip"
    self.parts.wpn_fps_ass_fal_fg_wood.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_ass_fal_fg_wood.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_g_01.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_fal_m_01.stats = { concealment = 13, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_ass_fal_m_standard.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_ass_fal_s_01.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_ass_fal_s_03.stats = { concealment = 0, weight = 0, length = 11.010, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_ass_fal_s_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_ass_fal_s_wood.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    table.insert(self.wpn_fps_ass_fal.default_blueprint, "wpn_fps_ass_fal_b_standard")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_ass_fal_b_standard")
    --table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_ass_fal_b_01")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_ass_fal_b_03")
    table.insert(self.wpn_fps_ass_fal.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_fal.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_fal.uses_parts, "wpn_fps_remove_s")

    self.parts.wpn_fps_ass_contraband_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.5 }
    self.parts.wpn_fps_ass_contraband_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_ass_contraband_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_contraband_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_contraband_fg_standard.pcs = {}
    self.parts.wpn_fps_ass_contraband_fg_standard.stats = { concealment = 0, weight = 5 }
    self.parts.wpn_fps_ass_contraband_g_standard.pcs = {}
    self.parts.wpn_fps_ass_contraband_g_standard.name_id = "bm_wp_fps_ass_contraband_g_standard"
    self.parts.wpn_fps_ass_contraband_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_contraband_gl_m203.stats = { concealment = 0, weight = 1.3 }
    self.parts.wpn_fps_ass_contraband_m_standard.stats = { concealment = 9, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_ass_contraband_ns_standard.stats = { concealment = 1, weight = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_ass_contraband_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_ass_contraband_o_standard.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_acog, self.nqr.i_f_spot, self.nqr.i_f_c96))
    self.parts.wpn_fps_ass_contraband_o_standard.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_ass_contraband_s_standard.stats = { concealment = 0, weight = 3, shouldered = true }
    self.wpn_fps_ass_contraband.override = {}
    table.delete(self.wpn_fps_ass_contraband.default_blueprint, "wpn_fps_ass_contraband_gl_m203")
    table.swap(self.wpn_fps_ass_contraband.default_blueprint, "wpn_fps_ass_contraband_s_standard", "wpn_fps_snp_tti_s_vltor")
    table.swap(self.wpn_fps_ass_contraband.default_blueprint, "wpn_fps_ass_contraband_ns_standard", "wpn_fps_ass_tecci_ns_standard")
    table.insert(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_ass_tecci_ns_standard")
    table.insert(self.wpn_fps_ass_contraband.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_ass_tecci_fg_standard")
    table.delete(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_ass_tecci_g_standard")
    table.delete(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_snp_victor_s_hera")
    table.insert(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_ass_contraband.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_ass_contraband.uses_parts, self.nqr.all_vertical_grips)

    self.parts.wpn_fps_ass_ching_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 24 }
    self.parts.wpn_fps_ass_ching_b_short.stats = { concealment = 0, weight = 0, barrel_length = 18 }
    self.parts.wpn_fps_ass_ching_body_standard.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_fps_ass_ching_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_extra1_swiwel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_extra_swiwel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_extra_swiwel_empty.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_fg_railed.rails = { "top" }
    self.parts.wpn_fps_ass_ching_fg_railed.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_ching_m_standard.stats = { concealment = 5, weight = 1, mag_amount = { 3, 6, 9 }, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_ass_ching_s_pouch.type = "stock_addon"
    self.parts.wpn_fps_ass_ching_s_pouch.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_fps_ass_ching_s_pouch.stats = { concealment = 0, weight = 2, totalammo = 16 }
    self.parts.wpn_fps_ass_ching_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_ass_ching_strip_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_ass_ching.adds = {}
    table.deletefrom(self.wpn_fps_ass_ching.uses_parts, self.nqr.all_optics)
    table.insert(self.wpn_fps_ass_ching.default_blueprint, 1, "wpn_fps_fg_lock_sights")
    table.insert(self.wpn_fps_ass_ching.uses_parts, "wpn_fps_fg_lock_sights")
    table.insert(self.wpn_fps_ass_ching.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_ching.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_ass_ching.uses_parts, "wpn_fps_addon_ris")

    self.parts.wpn_fps_snp_siltstone_b_silenced.type = "exclusive_set"
    self.parts.wpn_fps_snp_siltstone_b_silenced.forbids = { "wpn_fps_snp_siltstone_ns_variation_a", "wpn_fps_snp_siltstone_ns_variation_b" }
    table.addto(self.parts.wpn_fps_snp_siltstone_b_silenced.forbids, self.nqr.all_bxs)
    self.parts.wpn_fps_snp_siltstone_b_silenced.override = {
        wpn_fps_snp_siltstone_b_standard = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } },
        wpn_fps_snp_siltstone_ns_variation_a = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } },
    }
    self.parts.wpn_fps_snp_siltstone_b_silenced.stats = { concealment = 0, weight = 0, barrel_length = 20.4, md_code = {3,0,0,0,0} } --todo conc and weight instead of md_bulk
    self.parts.wpn_fps_snp_siltstone_b_standard.visibility = { { objects = { g_muzzle = false } } }
    self.parts.wpn_fps_snp_siltstone_b_standard.override = deep_clone(overrides_barrelexts_noparent_thing)
    self.parts.wpn_fps_snp_siltstone_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 24.4 }
    self.parts.wpn_fps_snp_siltstone_body_receiver.sub_type = "ironsight"
    self.parts.wpn_fps_snp_siltstone_body_receiver.stats = { concealment = 0, weight = 0, length = 23 }
    self.parts.wpn_fps_snp_siltstone_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_ejector.type = "ejector"
    self.parts.wpn_fps_snp_siltstone_ejector.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_fg_polymer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_fg_wood.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_iron_sight.pcs = nil
    self.parts.wpn_fps_snp_siltstone_iron_sight.type = "ironsight"
    self.parts.wpn_fps_snp_siltstone_iron_sight.sub_type = "ironsight"
    self.parts.wpn_fps_snp_siltstone_iron_sight.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 }
    self.parts.wpn_fps_snp_siltstone_o_scopemount.pcs = {}
    self.parts.wpn_fps_snp_siltstone_o_scopemount.name_id = "bm_wp_siltstone_sightrail"
    self.parts.wpn_fps_snp_siltstone_o_scopemount.type = "extra"
    self.parts.wpn_fps_snp_siltstone_o_scopemount.rails = { "top" }
    self.parts.wpn_fps_snp_siltstone_o_scopemount.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_siltstone_s_polymer.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_snp_siltstone_s_wood.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_snp_siltstone_ns_variation_b.type = "barrel_ext"
    self.parts.wpn_fps_snp_siltstone_ns_variation_b.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_snp_siltstone_ns_variation_b.stats = { concealment = 2, weight = 2, length = 2, md_code = {0,3,0,0,0} }
    self.parts.wpn_fps_snp_siltstone_ns_variation_a = deep_clone(self.parts.wpn_fps_snp_siltstone_ns_variation_b)
    self.parts.wpn_fps_snp_siltstone_ns_variation_a.pcs = {}
    self.parts.wpn_fps_snp_siltstone_ns_variation_a.name_id = "bm_wp_siltstone_ns_variation_a"
    self.parts.wpn_fps_snp_siltstone_ns_variation_a.unit = self.parts.wpn_fps_snp_siltstone_b_standard.unit
    self.parts.wpn_fps_snp_siltstone_ns_variation_a.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_snp_siltstone_ns_variation_a.stats = { concealment = 2, weight = 2, length = 2, md_code = {0,2,0,0,0} }
    self.wpn_fps_snp_siltstone.adds = {}
    --table.swap(self.wpn_fps_snp_siltstone.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_siltstone_iron_sight")
    table.delete(self.wpn_fps_snp_siltstone.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_siltstone.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_siltstone.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_siltstone.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_siltstone.default_blueprint, "wpn_fps_snp_siltstone_ns_variation_a")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_snp_siltstone_ns_variation_a")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_snp_siltstone.uses_parts, "wpn_fps_remove_ns")
    table.addto(self.wpn_fps_snp_siltstone.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_tti_b_standard.override = { wpn_fps_snp_tti_ns_hex = { parent = false } }
    table.addto(self.parts.wpn_fps_snp_tti_b_standard.override, deep_clone(overrides_barrelexts_noparent_thing))
    self.parts.wpn_fps_snp_tti_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 14.5 }
    self.parts.wpn_fps_snp_tti_body_receiverlower.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_snp_tti_body_receiverupper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_tti_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_tti_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_tti_dh_standard.texture_bundle_folder = "spa"
    self.parts.wpn_fps_snp_tti_dh_standard.dlc = "spa"
    self.parts.wpn_fps_snp_tti_dh_standard.pcs = {}
    self.parts.wpn_fps_snp_tti_dh_standard.name_id = "bm_wp_fps_snp_tti_dh_standard"
    self.parts.wpn_fps_snp_tti_dh_standard.adds = { "wpn_fps_snp_tti_dhs_switch" }
    self.parts.wpn_fps_snp_tti_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_tti_dhs_switch.a_obj = "a_dh"
    self.parts.wpn_fps_snp_tti_fg_standard.texture_bundle_folder = "spa"
    self.parts.wpn_fps_snp_tti_fg_standard.dlc = "spa"
    self.parts.wpn_fps_snp_tti_fg_standard.pcs = {}
    self.parts.wpn_fps_snp_tti_fg_standard.name_id = "bm_wp_fps_snp_tti_fg_standard"
    self.parts.wpn_fps_snp_tti_fg_standard.rails = { "top", "side" }
    self.parts.wpn_fps_snp_tti_fg_standard.adds = {}
    self.parts.wpn_fps_snp_tti_fg_standard.forbids = { "wpn_fps_m4_uupg_b_short", "wpn_fps_m4_uupg_b_short_os3", "wpn_fps_para_b_medium", "wpn_fps_para_b_medium_os3", "wpn_fps_para_b_short", "wpn_fps_m4_uupg_b_sd" }
    self.parts.wpn_fps_snp_tti_fg_standard.override = {}
    self.parts.wpn_fps_snp_tti_fg_standard.stats = { concealment = 0, weight = 7 }
    self.parts.wpn_fps_snp_tti_g_grippy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_tti_m_standard.stats = { concealment = 8, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["7.62x51"] = 20, ["12 gauge"] = 0 } }
    self.parts.wpn_fps_snp_tti_ns_hex.texture_bundle_folder = "spa"
    self.parts.wpn_fps_snp_tti_ns_hex.dlc = "spa"
    self.parts.wpn_fps_snp_tti_ns_hex.parent = "barrel"
    self.parts.wpn_fps_snp_tti_ns_hex.stats = { concealment = 16, weight = 5, length = 5, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_snp_tti_ns_standard.name_id = "bm_wp_tti_ns_standard"
    self.parts.wpn_fps_snp_tti_ns_standard.texture_bundle_folder = "spa"
    self.parts.wpn_fps_snp_tti_ns_standard.dlc = "spa"
    self.parts.wpn_fps_snp_tti_ns_standard.pcs = {}
    self.parts.wpn_fps_snp_tti_ns_standard.dlc = self.parts.wpn_fps_snp_tti_ns_hex.dlc
    self.parts.wpn_fps_snp_tti_ns_standard.parent = "barrel"
    self.parts.wpn_fps_snp_tti_ns_standard.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_snp_tti_s_vltor.type = "stock_addon"
    self.parts.wpn_fps_snp_tti_s_vltor.adds_type = nil
    self.parts.wpn_fps_snp_tti_s_vltor.stats = { concealment = 18, weight = 4, length = 10.07, shouldered = true }
    self.parts.wpn_fps_snp_tti_vg_standard.texture_bundle_folder = "spa"
    self.parts.wpn_fps_snp_tti_vg_standard.dlc = "spa"
    self.parts.wpn_fps_snp_tti_vg_standard.pcs = {}
    self.parts.wpn_fps_snp_tti_vg_standard.name_id = "bm_wp_fps_snp_tti_vg_standard"
    self.parts.wpn_fps_snp_tti_vg_standard.forbids = { "wpn_fps_smg_schakal_vg_extra" }
    self.parts.wpn_fps_snp_tti_vg_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_upg_blankcal_762x51 = deep_clone(self.parts.wpn_fps_upg_cal_9x19)
    self.parts.wpn_fps_upg_blankcal_762x51.pcs = nil
    self.parts.wpn_fps_upg_blankcal_762x51.forbids = {}
    table.addto(self.parts.wpn_fps_upg_blankcal_762x51.forbids, self.nqr.all_shotgun_ammotypes)
    self.parts.wpn_fps_upg_blankcal_762x51.stats = {}
    self.wpn_fps_snp_tti.override = {}
    self.wpn_fps_snp_tti.override.wpn_fps_sho_sko12_m_stick = { a_obj = "a_m2", animations = false }
    self.wpn_fps_snp_tti.override.wpn_fps_sho_sko12_m_drum = { a_obj = "a_m2", animations = false }
    for i, k in pairs(self.nqr.all_sps) do self.wpn_fps_snp_tti.override[k] = { sound_switch = { suppressed = "suppressed_a" } } end
    table.addto_dict(self.wpn_fps_snp_tti.override, overrides_gadget_foregrip_parent_thing)
    table.delete(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_snp_tti_dhs_switch")
    table.delete(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_snp_tti_vg_standard")
    table.swap(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_ass_contraband_s_standard", "wpn_fps_snp_tti_s_vltor")
    table.swap(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_upg_m4_g_standard", "wpn_fps_upg_m4_g_hgrip")
    table.swap(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_m4_uupg_o_flipup")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_m4_uupg_o_flipup")
    table.insert(self.wpn_fps_snp_tti.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_snp_tti.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_upg_blankcal_762x51")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_upg_blankcal_762x51")
    table.insert(self.wpn_fps_snp_tti.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_remove_s_addon")
    --table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_tube_stocks)
    --table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_m4_grips)
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_remove_ironsight")
    table.delete(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_snp_victor_s_hera")
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_bxs_sbr)
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_sho_sko12_m_stick")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_sho_sko12_m_drum")
    table.insert(self.wpn_fps_snp_tti.uses_parts, "wpn_fps_upg_cal_12g")
    table.addto(self.wpn_fps_snp_tti.uses_parts, self.nqr.all_shotgun_ammotypes)

    self.parts.wpn_fps_snp_qbu88_b_long.stats = { concealment = 0, weight = 0, barrel_length = 32 } --roughly
    self.parts.wpn_fps_snp_qbu88_b_short.stats = { concealment = 0, weight = 0, barrel_length = 20 } --roughly
    self.parts.wpn_fps_snp_qbu88_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 25.2 }
    self.parts.wpn_fps_snp_qbu88_body_standard.stats = { concealment = 0, weight = 0, length = 11, shouldered = true } --todo a_o
    self.parts.wpn_fps_snp_qbu88_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_qbu88_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_qbu88_m_extended.stats = { concealment = 9, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_snp_qbu88_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 }
    self.parts.wpn_fps_snp_qbu88_o_standard.pcs = nil
    self.parts.wpn_fps_snp_qbu88_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_snp_qbu88_o_standard.forbids, self.nqr.all_big_snoptics)
    self.parts.wpn_fps_snp_qbu88_o_standard.stats = { concealment = 0, weight = 1, sightheight = height_dflt+0.5 } --0.75
    table.swap(self.wpn_fps_snp_qbu88.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_qbu88_o_standard")
    table.insert(self.wpn_fps_snp_qbu88.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_qbu88.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_upg_o_45rds")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_upg_o_45steel")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_snp_qbu88.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_snp_qbu88.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_winchester_b_long.stats = { concealment = 5, weight = 2, barrel_length = 24, CLIP_AMMO_MAX = 14 } --not_sure
    self.parts.wpn_fps_snp_winchester_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20, CLIP_AMMO_MAX = 10 } --not_sure
    self.parts.wpn_fps_snp_winchester_b_suppressed.stats = { concealment = 8, weight = 4, length = 5, barrel_length = 20, CLIP_AMMO_MAX = 10, md_code = {1,0,0,0,0} }
    self.parts.wpn_fps_snp_winchester_body_standard.stats = { concealment = 0, weight = 0, length = 20, shouldered = true }
    self.parts.wpn_fps_snp_winchester_m_standard.stats = { concealment = 0, weight = 0, mag_amount = { 48, 72, 96 } }
    self.parts.wpn_fps_snp_winchester_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_upg_winchester_o_classic.stats = { concealment = 0, weight = 4, zoom = 3, sightheight = 1.2 } --not_sure
    table.insert(self.wpn_fps_snp_winchester.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_winchester.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_winchester.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_winchester.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_winchester.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_winchester.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")

    self.parts.wpn_fps_snp_sbl_b_long.type = "exclusive_set"
    self.parts.wpn_fps_snp_sbl_b_long.forbids = deep_clone(self.nqr.all_bxs)
    self.parts.wpn_fps_snp_sbl_b_long.override = { wpn_fps_snp_sbl_b_standard = { unit = self.parts.wpn_fps_snp_sbl_b_long.unit, stats = { concealment = 0, weight = 0 } } }
    self.parts.wpn_fps_snp_sbl_b_long.visibility = { { objects = { g_b_long = false } } }
    --self.parts.wpn_fps_snp_sbl_b_long.stats = { concealment = 0, weight = 0, barrel_length = 23, md_code = {0,0,0,3,0}, CLIP_AMMO_MAX = { [".45-70"] = 5, [".410 bore"] = 5 } } --roughly
    self.parts.wpn_fps_snp_sbl_b_long.stats = { concealment = 0, weight = 0, barrel_length = 23, md_code = {0,0,0,3,0}, CLIP_AMMO_MAX = 5 } --roughly
    --self.parts.wpn_fps_snp_sbl_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 19.1, CLIP_AMMO_MAX = { [".45-70"] = 6, [".410 bore"] = 6 } }
    self.parts.wpn_fps_snp_sbl_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 19.1, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_snp_sbl_b_short.type = "exclusive_set"
    self.parts.wpn_fps_snp_sbl_b_short.forbids = deep_clone(self.nqr.all_bxs)
    self.parts.wpn_fps_snp_sbl_b_short.override = { wpn_fps_snp_sbl_b_standard = { unit = self.parts.wpn_fps_snp_sbl_b_short.unit, stats = { concealment = 0, weight = 0 } } }
    self.parts.wpn_fps_snp_sbl_b_short.visibility = { { objects = { g_b_short = false } } }
    --self.parts.wpn_fps_snp_sbl_b_short.stats = { concealment = 0, weight = 0, length = 10, barrel_length = 13, md_code = {3,0,0,0,0}, CLIP_AMMO_MAX = { [".45-70"] = 5, [".410 bore"] = 5 } } --roughly
    self.parts.wpn_fps_snp_sbl_b_short.stats = { concealment = 0, weight = 0, length = 10, barrel_length = 13, md_code = {3,0,0,0,0}, CLIP_AMMO_MAX = 5 } --roughly
    self.parts.wpn_fps_snp_sbl_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_snp_sbl_body_standard.stats = { concealment = 0, weight = 0, length = 17 }
    self.parts.wpn_fps_snp_sbl_m_standard.stats = { concealment = 0, weight = 0, mag_amount = { 24, 48, 72 } }
    self.parts.wpn_fps_snp_sbl_o_standard.pcs = nil
    self.parts.wpn_fps_snp_sbl_o_standard.type = "ironsight"
    self.parts.wpn_fps_snp_sbl_o_standard.sub_type = "ironsight"
    self.parts.wpn_fps_snp_sbl_o_standard.forbids = {}
    self.parts.wpn_fps_snp_sbl_o_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_sbl_rack = deep_clone(self.parts.wpn_fps_snp_sbl_s_saddle)
    self.parts.wpn_fps_snp_sbl_rack.name_id = "bm_wp_r870_body_rack"
    self.parts.wpn_fps_snp_sbl_rack.type = "upper_reciever"
    self.parts.wpn_fps_snp_sbl_rack.visibility = { { objects = { g_s = false, g_saddle = false } } }
    self.parts.wpn_fps_snp_sbl_rack.stats = { concealment = 0, weight = 1, totalammo = 5 }
    self.parts.wpn_fps_snp_sbl_s_saddle.type = "stock_addon"
    self.parts.wpn_fps_snp_sbl_s_saddle.visibility = { { objects = { g_s = false, g_rack = false, g_rack_bullets = false } } }
    self.parts.wpn_fps_snp_sbl_s_saddle.stats = { concealment = 0, weight = 1, cheek = 1 }
    self.parts.wpn_fps_snp_sbl_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_snp_sbl.override = {
        wpn_fps_addon_ris = { a_obj = "a_fl_2" }, --todo
        wpn_fps_gadgets_pos_a_fl_2 = { depends_on = "extra2", },
    }
    for i, k in pairs(table.combine(self.nqr.all_sps3, self.nqr.all_sps4)) do
        self.wpn_fps_snp_sbl.override[k] = { sound_switch = { suppressed = "suppressed_a" } }
    end
    table.swap(self.wpn_fps_snp_sbl.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_sbl_o_standard")
    table.insert(self.wpn_fps_snp_sbl.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_snp_sbl.default_blueprint, 1, "wpn_fps_gadgets_lock_secondsights")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_gadgets_lock_secondsights")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_snp_sbl_rack")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_upg_fl_ass_utg")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_gadgets_pos_a_fl_2")
    table.insert(self.wpn_fps_snp_sbl.uses_parts, "wpn_fps_upg_cal_410")
    table.addto(self.wpn_fps_snp_sbl.uses_parts, self.nqr.all_shotgun_ammotypes)
    table.addto(self.wpn_fps_snp_sbl.uses_parts, self.nqr.all_bxs_bbr)

    self.parts.wpn_fps_lmg_hcar_barrel_short.stats = { concealment = 0, weight = 0, barrel_length = 13 }
    self.parts.wpn_fps_lmg_hcar_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_lmg_hcar_barrel_dmr.stats = { concealment = 0, weight = 0, barrel_length = 24 }
    self.parts.wpn_fps_lmg_hcar_body_standard.stats = { concealment = 0, weight = 0, length = 12 }
    self.parts.wpn_fps_lmg_hcar_suppressor.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_lmg_hcar_sight.a_obj = "a_o_r"
    self.parts.wpn_fps_lmg_hcar_sight.forbids = {}
    table.addto(self.parts.wpn_fps_lmg_hcar_sight.forbids, table.without(self.nqr.all_sights, self.nqr.all_angled_sights))
    table.deletefrom(self.parts.wpn_fps_lmg_hcar_sight.forbids, table.with(self.nqr.all_piggyback_sights, {"wpn_fps_upg_o_docter", "wpn_fps_upg_o_fc1", "wpn_fps_upg_o_t1micro"}))
    self.parts.wpn_fps_lmg_hcar_sight.stats = { concealment = 2, weight = 0, sightheight = height_dflt }
    self.parts.wpn_fps_lmg_hcar_stock.texture_bundle_folder = "pxp3"
    self.parts.wpn_fps_lmg_hcar_stock.dlc = "pxp3"
    self.parts.wpn_fps_lmg_hcar_stock.pcs = {}
    self.parts.wpn_fps_lmg_hcar_stock.type = "stock_addon"
    self.parts.wpn_fps_lmg_hcar_stock.adds_type = nil
    self.parts.wpn_fps_lmg_hcar_stock.stats = { concealment = 0, weight = 4, length = 6, shouldered = true, cheek = 1.5 }
    self.parts.wpn_fps_lmg_hcar_m_standard.stats = { concealment = 9, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_lmg_hcar_m_stick.stats = { concealment = 16, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_lmg_hcar_m_drum.stats = { concealment = 45, weight = 11, mag_amount = { 1, 1, 2 }, CLIP_AMMO_MAX = 50 }
    self.wpn_fps_lmg_hcar.override = {
        wpn_fps_o_pos_fg = { adds = {}, override = { wpn_fps_o_blank = { a_obj = "a_o_f" } } },
    }
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.wpn_fps_lmg_hcar.override.wpn_fps_o_pos_fg.override[k] = { a_obj = "a_o_f" } end end
    table.insert(self.wpn_fps_lmg_hcar.default_blueprint, "wpn_fps_snp_victor_s_adapter")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_upg_o_poe")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_upg_o_spot")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_upg_o_atibal_reddot")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_remove_ironsight")
    --table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_extra_placing_sights_to_a_o_f")
    table.insert(self.wpn_fps_lmg_hcar.uses_parts, "wpn_fps_o_pos_fg")
    table.addto(self.wpn_fps_lmg_hcar.uses_parts, self.nqr.all_second_sights)
    table.addto(self.wpn_fps_lmg_hcar.uses_parts, self.nqr.all_m4_stocks)



----SNIPER RIFLE
    self.parts.wpn_fps_snp_desertfox_b_long.visibility = { { objects = { g_comp = false, g_rail_long = false } } }
    self.parts.wpn_fps_snp_desertfox_b_long.stats = { concealment = 0, weight = 0, barrel_length = 22 }
    self.parts.wpn_fps_snp_desertfox_b_short.visibility = { { objects = { g_rail_short = false } } }
    self.parts.wpn_fps_snp_desertfox_b_short.forbids = { "wpn_fps_snp_desertfox_fg_long" }
    self.parts.wpn_fps_snp_desertfox_b_short.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_snp_desertfox_b_silencer.type = "barrel_ext"
    self.parts.wpn_fps_snp_desertfox_b_silencer.a_obj = "a_ns"
    self.parts.wpn_fps_snp_desertfox_b_silencer.parent = "barrel"
    self.parts.wpn_fps_snp_desertfox_b_silencer.sound_switch.suppressed = "suppressed_b"
    self.parts.wpn_fps_snp_desertfox_b_silencer.visibility = { { objects = { g_rail_short = false, g_barrel_short = false } } }
    self.parts.wpn_fps_snp_desertfox_b_silencer.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_snp_desertfox_body.stats = { concealment = 0, weight = 0, length = 12, shouldered = true }
    self.parts.wpn_fps_snp_desertfox_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_desertfox_mag.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5, retention = false }
    self.parts.wpn_fps_snp_desertfox_fg_short = {
        a_obj = "a_b",
		type = "foregrip",
		name_id = "bm_wp_desertfox_fg_short",
		unit = "units/pd2_dlc_pim/weapons/wpn_fps_snp_desertfox_pts/wpn_fps_snp_desertfox_b_short",
        visibility = { { objects = { g_barrel_short = false } } },
		stats = { concealment = 0, weight = 0 },
    }
    self.parts.wpn_fps_snp_desertfox_fg_long = {
        a_obj = "a_b",
		type = "foregrip",
		name_id = "bm_wp_desertfox_fg_long",
		unit = "units/pd2_dlc_pim/weapons/wpn_fps_snp_desertfox_pts/wpn_fps_snp_desertfox_b_long",
        pcs = {},
        visibility = { { objects = { g_barrel_long = false, g_comp = false } } },
		stats = { concealment = 0, weight = 0 },
    }
    self.parts.wpn_fps_snp_desertfox_ns_comp = {
        a_obj = "a_ns",
        parent = "barrel",
		type = "barrel_ext",
		name_id = "bm_wp_desertfox_ns_comp",
		unit = "units/pd2_dlc_pim/weapons/wpn_fps_snp_desertfox_pts/wpn_fps_snp_desertfox_ns_comp",
        pcs = {},
		stats = { concealment = 3, weight = 1, length = 2, md_code = {0,0,1,2,0} },
    }
    table.delete(self.wpn_fps_snp_desertfox.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_desertfox.default_blueprint, "wpn_fps_snp_desertfox_fg_short")
    table.insert(self.wpn_fps_snp_desertfox.uses_parts, "wpn_fps_snp_desertfox_fg_short")
    table.insert(self.wpn_fps_snp_desertfox.uses_parts, "wpn_fps_snp_desertfox_fg_long")
    table.insert(self.wpn_fps_snp_desertfox.uses_parts, "wpn_fps_snp_desertfox_ns_comp")
    table.addto(self.wpn_fps_snp_desertfox.uses_parts, self.nqr.all_bxs_bbr)

    self.parts.wpn_fps_snp_m95_barrel_short.stats = { concealment = 0, weight = -18, barrel_length = 16, md_code = {0,0,0,4,0}, length = 2, md_bulk = {2,2} } --roughly
    self.parts.wpn_fps_snp_m95_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 29, md_code = {0,0,0,4,0}, length = 2, md_bulk = {2,2} }
    self.parts.wpn_fps_snp_m95_barrel_suppressed.stats = { concealment = 60, weight = 20, barrel_length = 29, length = 4, md_code = {5,0,0,0,0} }
    self.parts.wpn_fps_snp_m95_barrel_long.stats = { concealment = 0, weight = 22, barrel_length = 40, md_code = {0,0,0,4,0}, length = 2, md_bulk = {2,2} } --roughly
    self.parts.wpn_fps_snp_m95_bipod.type = "bipod"
    self.parts.wpn_fps_snp_m95_bipod.stats = { concealment = 0, weight = 10 } --roughly
    self.parts.wpn_fps_snp_m95_lower_reciever.stats = { concealment = 0, weight = 0, length = 13, shouldered = true }
    self.parts.wpn_fps_snp_m95_magazine.bullet_objects = { amount = 1, prefix = "g_bullet" }
    self.parts.wpn_fps_snp_m95_magazine.stats = { concealment = 15, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 5, retention = false }
    self.parts.wpn_fps_snp_m95_upper_reciever.stats = { concealment = 0, weight = 0 }
    table.delete(self.wpn_fps_snp_m95.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_m95.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_m95.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_m95.uses_parts, "wpn_fps_remove_bipod")
    table.insert(self.wpn_fps_snp_m95.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_snp_m95.uses_parts, self.nqr.all_m4_grips)

    self.parts.wpn_fps_snp_model70_sights = deep_clone(self.parts.wpn_fps_snp_model70_b_standard)
    self.parts.wpn_fps_snp_model70_sights.sightpairs = { "wpn_fps_snp_model70_b_standard" }
    self.parts.wpn_fps_snp_model70_sights.type = "ironsight"
    self.parts.wpn_fps_snp_model70_sights.visibility = { { objects = { g_b = false } } }
    self.parts.wpn_fps_snp_model70_sights.stats = { concealment = 1, weight = 1, sightheight = -0.25 }
    self.parts.wpn_fps_snp_model70_b_standard.visibility = { { objects = { g_sights = false } } }
    self.parts.wpn_fps_snp_model70_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 22 }
    self.parts.wpn_fps_snp_model70_b_short = deep_clone(self.parts.wpn_fps_snp_model70_b_legend)
    self.parts.wpn_fps_snp_model70_b_short.pcs = {}
    self.parts.wpn_fps_snp_model70_b_short.override = { wpn_fps_snp_model70_sights = { unit = fantom_unit, stats = {} } }
    self.parts.wpn_fps_snp_model70_b_short.visibility = { { objects = { g_head = false } } }
    self.parts.wpn_fps_snp_model70_b_short.stats = { concealment = 0, weight = 0, barrel_length = 12 }
    self.parts.wpn_fps_snp_model70_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 12 }
    self.parts.wpn_fps_snp_model70_body_standard.stats = { concealment = 0, weight = 0, length = 20 }
    self.parts.wpn_fps_snp_model70_fl_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_model70_iron_sight.pcs = nil
    self.parts.wpn_fps_snp_model70_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_snp_model70_ns_suppressor.dlc = nil
    self.parts.wpn_fps_snp_model70_ns_suppressor.stats = { concealment = 12, weight = 6, length = 14, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_snp_model70_o_rail.pcs = {}
    self.parts.wpn_fps_snp_model70_o_rail.name_id = "bm_wp_model70_sightrail"
    self.parts.wpn_fps_snp_model70_o_rail.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_snp_model70_o_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_model70_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_snp_model70_s_legend.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_snp_model70.adds = {}
    self.wpn_fps_snp_model70.override = {
        wpn_fps_addon_ris = { a_obj = "a_fl_2" },
    }
    for i, k in pairs(self.nqr.all_gadgets) do self.wpn_fps_snp_model70.override[k] = { a_obj = "a_fl_2" } end
    table.delete(self.wpn_fps_snp_model70.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_model70.default_blueprint, "wpn_fps_snp_model70_sights")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_snp_model70_sights")
    table.insert(self.wpn_fps_snp_model70.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_model70.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_snp_model70_b_short")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_snp_model70.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_snp_model70.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_mosin_b_short.stats = { concealment = 0, weight = 0, barrel_length = 20 }
    self.parts.wpn_fps_snp_mosin_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 28.7 }
    self.parts.wpn_fps_snp_mosin_b_sniper.forbids = deep_clone(self.nqr.all_bxs_sbr)
    self.parts.wpn_fps_snp_mosin_b_sniper.stats = { concealment = 0, weight = 5, barrel_length = 28.7, length = 8, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_snp_mosin_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 31.5 }
    self.parts.wpn_fps_snp_mosin_body_black.sub_type = "ironsight"
    self.parts.wpn_fps_snp_mosin_body_black.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_fps_snp_mosin_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_snp_mosin_body_standard.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_fps_snp_mosin_iron_sight.pcs = nil
    self.parts.wpn_fps_snp_mosin_iron_sight.forbids = {}
    self.parts.wpn_fps_snp_mosin_iron_sight.type = "ironsight"
    self.parts.wpn_fps_snp_mosin_iron_sight.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_mosin_m_standard.bullet_objects = { amount = 1, prefix = "g_bullet" }
    self.parts.wpn_fps_snp_mosin_m_standard.stats = { concealment = 3, weight = 0, mag_amount = { 3, 6, 9 }, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_snp_mosin_ns_bayonet.stats = { concealment = 6, weight = 3 }
    self.parts.wpn_fps_snp_mosin_rail.pcs = {} --todo a_o
    self.parts.wpn_fps_snp_mosin_rail.name_id = "bm_wp_mosin_sightrail"
    self.parts.wpn_fps_snp_mosin_rail.type = "ironsight"
    self.parts.wpn_fps_snp_mosin_rail.override = { wpn_fps_ironsight_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_snp_mosin_rail.stats = { concealment = 0, weight = 0, sightheight = 0.5 }
    self.wpn_fps_snp_mosin.adds = {}
    self.wpn_fps_snp_mosin.override = {}
    for i, k in pairs(self.nqr.all_sps) do self.wpn_fps_snp_mosin.override[k] = { sound_switch = deep_clone(self.parts.wpn_fps_snp_mosin_b_sniper.sound_switch) } end
    table.deletefrom(self.wpn_fps_snp_mosin.uses_parts, self.nqr.all_optics)
    table.swap(self.wpn_fps_snp_mosin.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_mosin_iron_sight")
    table.insert(self.wpn_fps_snp_mosin.default_blueprint, 1, "wpn_fps_ironsight_lock_sights")
    table.insert(self.wpn_fps_snp_mosin.uses_parts, "wpn_fps_ironsight_lock_sights")
    table.insert(self.wpn_fps_snp_mosin.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_mosin.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_mosin.uses_parts, "wpn_fps_snp_mosin_rail")
    table.insert(self.wpn_fps_snp_mosin.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_snp_mosin.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_msr_b_long.override = {}
    self.parts.wpn_fps_snp_msr_b_long.stats = { concealment = 0, weight = 0, barrel_length = 27, md_code = {0,0,0,2,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_snp_msr_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20, md_code = {0,0,0,2,0}, md_bulk = {2, 2} }
    self.parts.wpn_fps_snp_msr_body_msr.stats = { concealment = 0, weight = 0, length = 21, shouldered = true, shoulderable = true } --todo a_o
    self.parts.wpn_fps_snp_msr_body_wood.stats = { concealment = 0, weight = 0, length = 21, shouldered = true }
    self.parts.wpn_fps_snp_msr_m_standard.bullet_objects = { amount = 1, prefix = "g_bullet" }
    self.parts.wpn_fps_snp_msr_m_standard.stats = { concealment = 11, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 10, retention = false }
    self.parts.wpn_fps_snp_msr_ns_suppressor.stats = deep_clone(self.nqr.sps_stats.giant)
    table.delete(self.wpn_fps_snp_msr.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.addto(self.wpn_fps_snp_msr.uses_parts, self.nqr.all_bxs_bbr)

    self.parts.wpn_fps_snp_r700_b_short.stats = { concealment = 0, weight = 0, barrel_length = 16 } --roughly
    self.parts.wpn_fps_snp_r700_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 24 }
    self.parts.wpn_fps_snp_r700_b_medium.type = "exclusive_set"
    self.parts.wpn_fps_snp_r700_b_medium.forbids = { "wpn_fps_snp_r700_b_short" }
    table.addto(self.parts.wpn_fps_snp_r700_b_medium.forbids, deep_clone(self.nqr.all_bxs_sbr))
    self.parts.wpn_fps_snp_r700_b_medium.override = { wpn_fps_snp_r700_b_standard = { unit = fantom_unit } }
    self.parts.wpn_fps_snp_r700_b_medium.stats = { concealment = 0, weight = 0, barrel_length = 16, length = 11, md_code = {5,0,0,0,0} } --roughly
    self.parts.wpn_fps_snp_r700_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_r700_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_r700_fl_rail.pcs = {}
    self.parts.wpn_fps_snp_r700_fl_rail.type = "extra2"
    self.parts.wpn_fps_snp_r700_fl_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_r700_m_standard.stats = { concealment = 5, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5, retention = false }
    --self.parts.wpn_fps_snp_r700_o_rail.a_obj = "a_o"
    self.parts.wpn_fps_snp_r700_o_rail.rails = { "top" }
    --self.parts.wpn_fps_snp_r700_o_rail.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_snp_r700_o_rail.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_snp_r700_s_standard.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_fps_snp_r700_rack = deep_clone(self.parts.wpn_fps_snp_r700_s_military)
    self.parts.wpn_fps_snp_r700_rack.name_id = "bm_wp_r870_body_rack"
    self.parts.wpn_fps_snp_r700_rack.type = "upper_reciever"
    self.parts.wpn_fps_snp_r700_rack.visibility = { { objects = { g_s = false } } }
    self.parts.wpn_fps_snp_r700_rack.stats = { concealment = 0, weight = 1, totalammo = 5 }
    self.parts.wpn_fps_snp_r700_s_military.visibility = { { objects = { g_rack = false } } }
    self.parts.wpn_fps_snp_r700_s_military.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_fps_snp_r700_s_tactical_tacrail = deep_clone(self.parts.wpn_fps_snp_r700_s_tactical)
    self.parts.wpn_fps_snp_r700_s_tactical_tacrail.type = "extra2"
    self.parts.wpn_fps_snp_r700_s_tactical_tacrail.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_snp_r700_s_tactical_tacrail.visibility = { { objects = { g_s = false } } }
    self.parts.wpn_fps_snp_r700_s_tactical_tacrail.stats = { concealment = 0, weight = 4 } --todo: a_fl, a_o_f
    self.parts.wpn_fps_snp_r700_s_tactical.visibility = { { objects = { g_rail = false, g_tacrail = false } } }
    self.parts.wpn_fps_snp_r700_s_tactical.stats = { concealment = 0, weight = 0, length = 19, shouldered = true, cheek = 1 }
    self.wpn_fps_snp_r700.adds = {}
    --self.wpn_fps_snp_r700.override = { wpn_fps_remove_extra = { forbids = deep_clone(self.nqr.all_sights) }, }
    table.swap(self.wpn_fps_snp_r700.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_snp_r700_o_rail")
    table.insert(self.wpn_fps_snp_r700.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_r700.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_r700.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_r700.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_r700.uses_parts, "wpn_fps_snp_r700_rack")
    table.insert(self.wpn_fps_snp_r700.uses_parts, "wpn_fps_snp_r700_s_tactical_tacrail")
    table.insert(self.wpn_fps_snp_r700.uses_parts, "wpn_fps_remove_extra")
    table.addto(self.wpn_fps_snp_r700.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_r93_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 26.3, md_code = {0,1,0,1,0}, md_bulk = {2,2} }
    self.parts.wpn_fps_snp_r93_b_short.forbids = { "wpn_fps_snp_r93_b_suppressed" }
    self.parts.wpn_fps_snp_r93_b_short.stats = { concealment = 0, weight = 0, barrel_length = 20, md_code = {0,1,0,1,0}, md_bulk = {2,2} } --roughly
    self.parts.wpn_fps_snp_r93_b_suppressed.type = "barrel_ext"
    self.parts.wpn_fps_snp_r93_b_suppressed.stats = table.copy_append(self.nqr.sps_stats.giant, { md_code = {4,0,1,0,0} })
    self.parts.wpn_fps_snp_r93_body_standard.stats = { concealment = 0, weight = 0, length = 20, shouldered = true, cheek = 1.5 }
    self.parts.wpn_fps_snp_r93_rack = deep_clone(self.parts.wpn_fps_snp_r93_body_wood)
    self.parts.wpn_fps_snp_r93_rack.name_id = "bm_wp_r870_body_rack"
    self.parts.wpn_fps_snp_r93_rack.type = "upper_reciever"
    self.parts.wpn_fps_snp_r93_rack.visibility = { { objects = { g_bolt = false, g_upper = false, g_base = false } } }
    self.parts.wpn_fps_snp_r93_rack.stats = { concealment = 0, weight = 1, totalammo = 5 }
    self.parts.wpn_fps_snp_r93_body_wood.visibility = { { objects = { g_pouch = false } } }
    self.parts.wpn_fps_snp_r93_body_wood.stats = { concealment = 0, weight = 0, length = 20, shouldered = true }
    self.parts.wpn_fps_snp_r93_m_std.bullet_objects = { amount = 1, prefix = "g_bullet" }
    self.parts.wpn_fps_snp_r93_m_std.stats = { concealment = 7, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5, retention = false }
    table.insert(self.wpn_fps_snp_r93.uses_parts, "wpn_fps_snp_r93_rack")
    table.delete(self.wpn_fps_snp_r93.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_r93.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_r93.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_r93.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_snp_r93.uses_parts, self.nqr.all_sps4)

    self.wpn_fps_snp_scout.sightheight_mod = 0.3
    self.parts.wpn_fps_snp_scout_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 19 }
    self.parts.wpn_fps_snp_scout_body_standard.adds = {}
    self.parts.wpn_fps_snp_scout_body_standard.stats = { concealment = 0, weight = 0, length = 19 }
    self.parts.wpn_fps_snp_scout_bolt_speed.custom_stats = nil
    self.parts.wpn_fps_snp_scout_bolt_speed.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_scout_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_scout_conversion.pcs = {}
    self.parts.wpn_fps_snp_scout_conversion.has_description = nil
    self.parts.wpn_fps_snp_scout_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_scout_m_extended.stats = { concealment = 5, weight = 1, mag_amount = { 3, 5, 7 }, CLIP_AMMO_MAX = 7, retention = false }
    self.parts.wpn_fps_snp_scout_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 3, 5, 7 }, CLIP_AMMO_MAX = 5, retention = false }
    self.parts.wpn_fps_snp_scout_ns_suppressor.type = "barrel_ext"
    self.parts.wpn_fps_snp_scout_ns_suppressor.stats = { concealment = 10, weight = 4, md_code = {3,0,0,0,0}, length = 2 }
    self.parts.wpn_fps_snp_scout_o_iron_up.pcs = nil
    self.parts.wpn_fps_snp_scout_o_iron_up.stance_mod = nil
    self.parts.wpn_fps_snp_scout_o_iron_up.stats = { concealment = 1, weight = 0, sightheight = 0.3 }
    self.parts.wpn_fps_snp_scout_o_iron_down.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_scout_o_rail.pcs = {}
    self.parts.wpn_fps_snp_scout_o_rail.name_id = "bm_wp_scout_o_sightrail"
    self.parts.wpn_fps_snp_scout_o_rail.type = "extra"
    self.parts.wpn_fps_snp_scout_o_rail.rails = { "top" }
    self.parts.wpn_fps_snp_scout_o_rail.stats = { concealment = 0, weight = 0 }
    local scout_stock_unit = self.parts.wpn_fps_snp_scout_s_pads_full.unit
    self.parts.wpn_fps_snp_scout_s_pads_full.unit = self.parts.wpn_fps_snp_scout_s_pads_none.unit
    self.parts.wpn_fps_snp_scout_s_pads_full.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_scout_s_pads_none.unit = self.parts.wpn_fps_snp_scout_s_pads_one.unit
    self.parts.wpn_fps_snp_scout_s_pads_none.stats = { concealment = 3, weight = 0, length = 1 }
    self.parts.wpn_fps_snp_scout_s_pads_one.unit = scout_stock_unit
    self.parts.wpn_fps_snp_scout_s_pads_one.stats = { concealment = 6, weight = 0, length = 2 }
    self.parts.wpn_fps_snp_scout_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_snp_scout.override = {
        wpn_fps_fold_ironsight = {
            unit = self.parts.wpn_fps_snp_scout_o_iron_down.unit,
            third_unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_conversion_dummy",
            stats = { concealment = 0, weight = 0 },
        },
    }
    table.deletefrom(self.wpn_fps_snp_scout.uses_parts, self.nqr.all_optics)
    table.delete(self.wpn_fps_snp_scout.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.swap(self.wpn_fps_snp_scout.default_blueprint, "wpn_fps_snp_scout_o_iron_down", "wpn_fps_snp_scout_o_iron_up")
    table.insert(self.wpn_fps_snp_scout.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_scout.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_snp_scout.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_scout.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_scout.uses_parts, "wpn_fps_snp_scout_o_rail")
    table.insert(self.wpn_fps_snp_scout.uses_parts, "wpn_fps_fold_ironsight")
    table.insert(self.wpn_fps_snp_scout.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_snp_scout.uses_parts, self.nqr.all_piggyback_sights)
    table.addto(self.wpn_fps_snp_scout.uses_parts, self.nqr.all_bxs_sbr)

    self.parts.wpn_fps_snp_wa2000_b_long.stats = { concealment = 0, weight = 0, barrel_length = 30 } --roughly
    self.parts.wpn_fps_snp_wa2000_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 26 }
    self.parts.wpn_fps_snp_wa2000_b_suppressed.stats = { concealment = 30, weight = 14, barrel_length = 26, length = 11, md_code = {5,0,0,0,0} }
    self.parts.wpn_nqr_wa2000_bipod = deep_clone(self.parts.wpn_fps_snp_wa2000_body_standard)
    self.parts.wpn_nqr_wa2000_bipod.visibility = { { objects = { g_body = false, g_bolt = false } } }
    self.parts.wpn_nqr_wa2000_bipod.name_id = "bm_wp_wa2000_bipod"
    self.parts.wpn_nqr_wa2000_bipod.type = "bipod"
    self.parts.wpn_nqr_wa2000_bipod.stats = { concealment = 0, weight = 6 }
    self.parts.wpn_fps_snp_wa2000_body_standard.visibility = { { objects = { g_bipod = false } } }
    self.parts.wpn_fps_snp_wa2000_body_standard.stats = { concealment = 0, weight = 0, length = 11 }
    self.parts.wpn_fps_snp_wa2000_g_light.stats = { concealment = 0, weight = -3 }
    self.parts.wpn_fps_snp_wa2000_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_wa2000_g_stealth.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_wa2000_g_walnut.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_wa2000_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5, retention = false }
    self.parts.wpn_fps_snp_wa2000_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    table.delete(self.wpn_fps_snp_wa2000.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_wa2000.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_wa2000.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_wa2000.default_blueprint, "wpn_nqr_wa2000_bipod")
    table.insert(self.wpn_fps_snp_wa2000.uses_parts, "wpn_nqr_wa2000_bipod")
    table.insert(self.wpn_fps_snp_wa2000.uses_parts, "wpn_fps_remove_bipod")
    table.insert(self.wpn_fps_snp_wa2000.uses_parts, "wpn_fps_addon_ris")
    --table.addto(self.wpn_fps_snp_wa2000.uses_parts, self.nqr.all_sps4)

    self.parts.wpn_fps_snp_awp_b_long.override = {}
    self.parts.wpn_fps_snp_awp_b_long.stats = { concealment = 0, weight = 0, barrel_length = 24 }
    self.parts.wpn_fps_snp_awp_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20 }
    self.parts.wpn_fps_snp_awp_b_short.override = {}
    self.parts.wpn_fps_snp_awp_b_short.stats = { concealment = 0, weight = 0, barrel_length = 16 } --roughly
    self.parts.wpn_fps_snp_awp_ns_muzzle.stats = { concealment = 0, weight = 3, length = 3 }
    self.parts.wpn_fps_snp_awp_ns_suppressor.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_snp_awp_reciever.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_snp_awp_ext_shellrack.type = "stock_addon"
    self.parts.wpn_fps_snp_awp_ext_shellrack.stats = { concealment = 0, weight = 0, totalammo = 6 }
    self.parts.wpn_fps_snp_awp_m_standard.stats = { concealment = 5, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["7.62x51"] = 10, [".338 LM"] = 5, }, retention = false }
    self.parts.wpn_fps_snp_awp_m_speed.stats = { concealment = 5, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["7.62x51"] = 8, [".338 LM"] = 4, }, retention = false }
    self.parts.wpn_fps_snp_awp_g_solid.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_snp_awp_g_standard.pcs = {}
    self.parts.wpn_fps_snp_awp_g_standard.name_id = "bm_wp_awp_g_standard"
    self.parts.wpn_fps_snp_awp_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_awp_g_granulated.forbids = {}
    self.parts.wpn_fps_snp_awp_g_granulated.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_awp_g_grainy.forbids = {}
    self.parts.wpn_fps_snp_awp_g_grainy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_awp_g_perforated.forbids = {}
    self.parts.wpn_fps_snp_awp_g_perforated.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_awp_ext_bipod.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_snp_awp_o_irons.forbids = {}
    table.addto(self.parts.wpn_fps_snp_awp_o_irons.forbids, table.combine(self.nqr.all_optics))
    self.parts.wpn_fps_snp_awp_o_irons.stats = { concealment = 2, weight = 0 }
    self.parts.wpn_fps_snp_awp_stock_solid.adds = {}
    self.parts.wpn_fps_snp_awp_stock_solid.forbids = {}
    self.parts.wpn_fps_snp_awp_stock_solid.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_snp_awp_stock_lightweight.adds = {}
    self.parts.wpn_fps_snp_awp_stock_lightweight.forbids = {}
    self.parts.wpn_fps_snp_awp_stock_lightweight.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_snp_awp_conversion_dragonlore.custom_stats = nil
    table.delete(self.wpn_fps_snp_awp.default_blueprint, "wpn_fps_upg_o_shortdot")
    table.insert(self.wpn_fps_snp_awp.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_snp_awp.default_blueprint, "wpn_fps_snp_awp_g_solid")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_snp_awp_g_solid")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_snp_awp_g_standard")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_remove_bipod")
    table.insert(self.wpn_fps_snp_awp.uses_parts, "wpn_fps_upg_cal_338lm")
    table.addto(self.wpn_fps_snp_awp.uses_parts, self.nqr.all_bxs_bbr)



----LMG
    self.wpn_fps_lmg_hk21.sightheight_mod = 0.5
    self.parts.wpn_fps_lmg_hk21_b_long.pcs = {}
    self.parts.wpn_fps_lmg_hk21_b_long.stats = { concealment = 0, weight = 0, barrel_length = 22, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_hk21_b_short.stats = { concealment = 0, weight = 0, barrel_length = 17.7, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_hk21_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk21_body_upper.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_hk21_body_upper.stats = { concealment = 0, weight = 0, length = 13, sightheight = self.wpn_fps_lmg_hk21.sightheight_mod } --todo a_o
    self.parts.wpn_fps_lmg_hk21_fg_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk21_fg_short.type = "exclusive_set"
    self.parts.wpn_fps_lmg_hk21_fg_short.forbids = { "wpn_fps_lmg_hk21_b_long" }
    self.parts.wpn_fps_lmg_hk21_fg_short.override = { wpn_fps_lmg_hk21_fg_long = { unit = fantom_unit },  wpn_fps_lmg_hk21_b_short = { parent = "exclusive_set" } }
    self.parts.wpn_fps_lmg_hk21_fg_short.stats = { concealment = 0, weight = 0, barrel_length = 12, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_hk21_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk21_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk21_m_standard.stats = { concealment = 48, weight = 12, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = { ["7.62x51"]=100, ["5.56x45"]=150 } }
    self.parts.wpn_fps_lmg_hk21_s_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_lmg_hk21_sightrail = {
		a_obj = "a_o",
		type = "extra",
		name_id = "bm_wp_lmg_hk21_sightrail",
		unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_o_rail", --units/pd2_dlc_gage_lmg/weapons/wpn_fps_lmg_hk21_pts/wpn_fps_lmg_hk21_body_rail
        rails = { "top" },
        adds = {},
        forbids = {},
        override = {},
        stats = { concealment = 4, weight = 2 },
        pcs = {},
	}
    self.wpn_fps_lmg_hk21.adds = {}
    table.addto(self.wpn_fps_lmg_hk21.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_hk21.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_lmg_hk21.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_hk21.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_lmg_hk21_sightrail")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_ass_g3_s_sniper")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_ass_g3_s_wood")
    table.insert(self.wpn_fps_lmg_hk21.uses_parts, "wpn_fps_upg_cal_556x45")

    self.parts.wpn_fps_lmg_hk51b_b_fluted.stats = { concealment = 0, weight = 0, barrel_length = 13 } --roughly
    self.parts.wpn_fps_lmg_hk51b_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 8.9 }
    self.parts.wpn_fps_lmg_hk51b_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_body_upper.stats = { concealment = 0, weight = 0, length = 11 }
    self.parts.wpn_fps_lmg_hk51b_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_fg_railed.rails = { "side", "bottom" }
    self.parts.wpn_fps_lmg_hk51b_fg_railed.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt.stats = { concealment = 15, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 30 } --roughly concealment
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_1.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_2.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_3.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_4.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_5.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_6.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_7.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_belt_belt_8.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_loader_reload.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_m_loader_reload_not_empty.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_hk51b_s_collapsed.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_lmg_hk51b_s_collapsed.unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_lmg_hk51b_pts/wpn_fps_lmg_hk51b_s_extended"
    self.parts.wpn_fps_lmg_hk51b_s_collapsed.stats = { concealment = 0, weight = 0, length = 5, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_lmg_hk51b_s_extended.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_lmg_hk51b_s_extended.unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_lmg_hk51b_pts/wpn_fps_lmg_hk51b_s_collapsed"
    self.parts.wpn_fps_lmg_hk51b_s_extended.stats = { concealment = 0, weight = 0, length = 1, shouldered = false, shoulderable = true }
    self.wpn_fps_lmg_hk51b.adds = {}
    table.deletefrom(self.wpn_fps_lmg_hk51b.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_lmg_hk51b.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_hk51b.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_hk51b.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_smg_mp5_body_rail")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_upg_o_poe") --ovkpls
    table.insert(self.wpn_fps_lmg_hk51b.uses_parts, "wpn_fps_upg_o_spot") --ovkpls
    table.addto(self.wpn_fps_lmg_hk51b.uses_parts, self.nqr.all_second_sights)

    self.wpn_fps_lmg_m249.sightheight_mod = 0.5
    self.parts.wpn_fps_lmg_m249_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16.1, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_m249_b_short.stats = { concealment = 0, weight = 0, barrel_length = 13.7, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_m249_body_standard.stats = { concealment = 0, weight = 0, length = 12 }
    self.parts.wpn_fps_lmg_m249_fg_mk46.rails = { "side", "bottom" }
    self.parts.wpn_fps_lmg_m249_fg_mk46.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m249_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m249_m_standard.stats = { concealment = 52, weight = 10, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 200 }
    self.parts.wpn_fps_lmg_m249_s_modern.pcs = {}
    self.parts.wpn_fps_lmg_m249_s_modern.stats = { concealment = 0, weight = 0, length = 7, shouldered = true }
    self.parts.wpn_fps_lmg_m249_s_para.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_lmg_m249_s_para.stats = { concealment = 0, weight = 0, length = 10.04, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_lmg_m249_s_solid.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_lmg_m249_upper_reciever.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_m249_upper_reciever.stats = { concealment = 0, weight = 0, sightheight = self.wpn_fps_lmg_m249.sightheight_mod }
    self.wpn_fps_lmg_m249.override = deep_clone(overrides_beltfed_sights)
    table.addto(self.wpn_fps_lmg_m249.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_m249.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_lmg_m249.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_lmg_m249.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_m249.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_lmg_m249.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_m249.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_m249.uses_parts, "wpn_fps_lmg_m249_s_modern")
    table.insert(self.wpn_fps_lmg_m249.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_lmg_m249.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_lmg_m249.uses_parts, self.nqr.all_tube_stocks)

    self.wpn_fps_lmg_m60.sightheight_mod = 2.35
    self.parts.wpn_fps_lmg_m60_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_m60_body_standard.sightpairs = { "wpn_fps_lmg_m60_o_sight" }
    self.parts.wpn_fps_lmg_m60_body_standard.visibility = { { objects = { g_sight = false } } }
    self.parts.wpn_fps_lmg_m60_body_standard.stats = { concealment = 0, weight = 0, length = 18, shouldered = true, sightheight = self.wpn_fps_lmg_m60.sightheight_mod }
    self.parts.wpn_fps_lmg_m60_b_short.stats = { concealment = 0, weight = -3, barrel_length = 17.3 }
    self.parts.wpn_fps_lmg_m60_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 22 }
    --self.parts.wpn_fps_lmg_m60_carry_standard.adds = { "wpn_fps_lmg_m60_o_sight" } --todo
    self.parts.wpn_fps_lmg_m60_carry_standard.type = "wep_cos"
    self.parts.wpn_fps_lmg_m60_carry_standard.stats = { concealment = 3, weight = 2 }
    self.parts.wpn_fps_lmg_m60_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m60_fg_keymod.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_lmg_m60_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m60_fg_tactical.stats = { concealment = 0, weight = 4 }
    self.parts.wpn_fps_lmg_m60_fg_tropical.stats = { concealment = 0, weight = 0 } --todo model
    self.parts.wpn_fps_lmg_m60_m_standard.stats = { concealment = 36, weight = 10, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 100 }
    self.parts.wpn_fps_lmg_m60_ns_standard.pcs = {}
    self.parts.wpn_fps_lmg_m60_ns_standard.texture_bundle_folder = "atw"
    self.parts.wpn_fps_lmg_m60_ns_standard.dlc = "atw"
    self.parts.wpn_fps_lmg_m60_ns_standard.stats = { concealment = 2, weight = 1, length = 2, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_lmg_m60_upper_reciever.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m60_o_sight = deep_clone(self.parts.wpn_fps_lmg_m60_body_standard)
    self.parts.wpn_fps_lmg_m60_o_sight.name_id = "bm_wp_m60_o_sight"
    self.parts.wpn_fps_lmg_m60_o_sight.type = "ironsight"
    self.parts.wpn_fps_lmg_m60_o_sight.sub_type = nil
    self.parts.wpn_fps_lmg_m60_o_sight.sightpairs = nil
    self.parts.wpn_fps_lmg_m60_o_sight.forbids = {}
    table.addto(self.parts.wpn_fps_lmg_m60_o_sight.forbids, self.nqr.all_sights)
    self.parts.wpn_fps_lmg_m60_o_sight.visibility = { { objects = { g_grip = false, g_lower = false, g_stock = false } } }
    self.parts.wpn_fps_lmg_m60_o_sight.stats = { concealment = 1, weight = 1 }
    self.parts.wpn_fps_m60_rail = {
        parent = "upper_reciever",
		a_obj = "a_o_parented",
		type = "extra",
		name_id = "bm_wp_m60_rail",
		unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_o_rail",
        pcs = {},
        rails = { "top" },
        adds = {}, forbids = {}, override = {},
        stats = { concealment = 3, weight = 2 },
	}
    self.wpn_fps_lmg_m60.override = deep_clone(overrides_beltfed_sights)
    table.addto(self.wpn_fps_lmg_m60.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_m60.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_lmg_m60.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_lmg_m60.default_blueprint, "wpn_fps_lmg_m60_o_sight")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_lmg_m60_o_sight")
    table.insert(self.wpn_fps_lmg_m60.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_m60.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_m60.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_m60_rail")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_remove_cos")
    table.insert(self.wpn_fps_lmg_m60.uses_parts, "wpn_fps_remove_ironsight")

    self.wpn_fps_lmg_mg42.sightheight_mod = 2.2
    self.parts.wpn_fps_lmg_mg42_b_mg42.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_mg42_b_mg42.stats = { concealment = 0, weight = 0, barrel_length = 20.9, sightheight = self.wpn_fps_lmg_mg42.sightheight_mod }
    self.parts.wpn_fps_lmg_mg42_b_mg34.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_mg42_b_mg34.stats = { concealment = 0, weight = 0, barrel_length = 20.9, sightheight = self.wpn_fps_lmg_mg42.sightheight_mod } --todo sight
    self.parts.wpn_fps_lmg_mg42_b_vg38.perks = nil
    self.parts.wpn_fps_lmg_mg42_b_vg38.override = self.parts.wpn_fps_lmg_mg42_b_mg34.override
    self.parts.wpn_fps_lmg_mg42_b_vg38.stats = { concealment = 0, weight = 0, barrel_length = 20.9 }
    self.parts.wpn_fps_lmg_mg42_n34.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_mg42_n42.stats = { concealment = 0, weight = 0, md_code = {0,1,0,0,1} }
    self.parts.wpn_fps_lmg_mg42_n38.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_mg42_reciever.visibility = { { objects = {
        --g_mag = false, g_mag_handle = false, g_lock = true, g_lid = true, g_handle_loose = true, g_base = true, g_handle = true,
    } } }
    self.parts.wpn_fps_lmg_mg42_reciever.stats = { concealment = 0, weight = 0, length = 27, shouldered = true } --todo a_fl
    self.parts.wpn_fps_mg42_rail = {
        parent = "lower_reciever",
		a_obj = "a_o_parented",
		type = "extra",
		name_id = "bm_wp_mg42_rail",
		unit = "units/pd2_dlc_pxp1/weapons/wpn_fps_snp_scout_pts/wpn_fps_snp_scout_o_rail",
        rails = { "top" },
        adds = {}, forbids = {}, override = {}, stats = {},
        pcs = {},
	}
    self.parts.wpn_fps_lmg_mg42_m_standard = {
		a_obj = "a_body",
		type = "magazine",
		name_id = "bm_wp_mg42_m_standard",
		--unit = "units/pd2_dlc_gage_historical/weapons/wpn_fps_lmg_mg42_pts/wpn_fps_lmg_mg42_reciever",
		unit = fantom_unit,
        --visibility = { { objects = { g_mag = true, g_mag_handle = true, g_lock = false, g_lid = false, g_handle_loose = false, g_base = false, g_handle = false, } } },
        adds = {}, forbids = {}, override = {},
		stats = { concealment = 28, weight = 8, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["7.92x57"]=50, ["7.62x51"]=50 } }, --roughly concealment
	}
    self.wpn_fps_lmg_mg42.override = {}
    for i, k in pairs(self.nqr.all_sights) do self.wpn_fps_lmg_mg42.override[k] = { a_obj = "a_o_parented", parent = "lower_reciever" } end
    table.addto(self.wpn_fps_lmg_mg42.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_mg42.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_lmg_mg42.uses_parts, self.nqr.all_magnifiers)
    table.deletefrom(self.wpn_fps_lmg_mg42.uses_parts, self.nqr.all_bxs)
    table.insert(self.wpn_fps_lmg_mg42.default_blueprint, "wpn_fps_lmg_mg42_m_standard")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_lmg_mg42_m_standard")
    table.insert(self.wpn_fps_lmg_mg42.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_lmg_mg42.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_mg42.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_mg42_rail")
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_addon_ris") --todo
    table.insert(self.wpn_fps_lmg_mg42.uses_parts, "wpn_fps_upg_cal_762x51")

    self.wpn_fps_lmg_par.sightheight_mod = 0.65
    self.parts.wpn_fps_lmg_par_b_short.stats = { concealment = 0, weight = 0, barrel_length = 15, md_code = {0,2,0,0,0}, md_bulk = {1, 1} } --roughly
    self.parts.wpn_fps_lmg_par_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 21.7, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_lmg_par_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_lmg_par_body_standard.stats = { concealment = 0, weight = 0, length = 23, sightheight = self.wpn_fps_lmg_par.sightheight_mod }
    self.parts.wpn_fps_lmg_par_m_standard.bullet_objects = { amount = 5, prefix = "g_bullet_" }
    self.parts.wpn_fps_lmg_par_m_standard.stats = { concealment = 32, weight = 6, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 75 }
    self.parts.wpn_fps_lmg_par_s_plastic.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_lmg_par_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_lmg_par_upper_reciever.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_svinet_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_svinet_s_legend.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_lmg_par.override = deep_clone(overrides_beltfed_sights)
    table.addto(self.wpn_fps_lmg_par.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_lmg_par.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_lmg_par.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_lmg_par.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_par.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_lmg_par.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_par.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_lmg_par.uses_parts, "wpn_fps_addon_ris")

    self.parts.wpn_fps_lmg_shuno_b_dummy_long.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_b_dummy_short.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_b_heat_long.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_b_heat_short.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_b_short.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_lmg_shuno_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_shuno_m_standard.stats = { concealment = 0, weight = 0, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 1000 }
    self.parts.wpn_fps_lmg_shuno_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }

	self.parts.wpn_fps_lmg_kacchainsaw_b_short.unit = "units/pd2_dlc_pxp4/weapons/wpn_fps_lmg_kacchainsaw_pts/wpn_fps_lmg_kacchainsaw_b_standard" --short
	self.parts.wpn_fps_lmg_kacchainsaw_b_short.stats = { concealment = 0, weight = 0, barrel_length = 15 }
	self.parts.wpn_fps_lmg_kacchainsaw_barrel_standard.unit = "units/pd2_dlc_pxp4/weapons/wpn_fps_lmg_kacchainsaw_pts/wpn_fps_lmg_kacchainsaw_b_short" --standard
	self.parts.wpn_fps_lmg_kacchainsaw_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 12.5 }
	self.parts.wpn_fps_lmg_kacchainsaw_b_long.stats = { concealment = 0, weight = 0, barrel_length = 20 }
	self.parts.wpn_fps_lmg_kacchainsaw_body.stats = { concealment = 0, weight = 0 }
	self.parts.wpn_fps_lmg_kacchainsaw_upperreceiver.stats = { concealment = 0, weight = 0, length = 13 }
	self.parts.wpn_fps_lmg_kacchainsaw_sling.type = "wep_cos"
	self.parts.wpn_fps_lmg_kacchainsaw_sling.stats = { concealment = 0, weight = 1 }
	self.parts.wpn_fps_lmg_kacchainsaw_grip.stats = { concealment = 0, weight = 0 }
	self.parts.wpn_fps_lmg_kacchainsaw_mag_a.stats = self.parts.wpn_fps_lmg_m249_m_standard.stats
	self.parts.wpn_fps_lmg_kacchainsaw_mag_b.stats = self.parts.wpn_fps_lmg_kacchainsaw_mag_a.stats
	self.parts.wpn_fps_lmg_kacchainsaw_flamethrower.stats = { concealment = 0, weight = 8 }



----SMG
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_smg_coal_g_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    self.parts.wpn_fps_smg_coal_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 9.1 }
    self.parts.wpn_fps_smg_coal_body_standard.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_coal_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_coal_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_coal_g_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_smg_coal_g_standard.dlc = "grv"
    self.parts.wpn_fps_smg_coal_g_standard.pcs = {}
    self.parts.wpn_fps_smg_coal_g_standard.name_id = "bm_wp_fps_smg_coal_g_standard"
    self.parts.wpn_fps_smg_coal_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_coal_m_standard.stats = { concealment = 12, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = { ["9x18"] = 64, ["9x19"] = 53 }, retention = false } --roughly
    self.parts.wpn_fps_smg_coal_mr_standard.type = "ejector"
    self.parts.wpn_fps_smg_coal_mr_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_coal_ns_standard.pcs = {}
    self.parts.wpn_fps_smg_coal_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.pcs = {}
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.name_id = "bm_wp_coal_sightrail"
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.texture_bundle_folder = "grv"
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.dlc = "grv"
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.a_obj = "a_o_sm"
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.rails = { "top" }
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.forbids = { "wpn_fps_upg_ak_body_upperreceiver_zenitco" }
    --table.addto(self.parts.wpn_fps_smg_coal_o_scopemount_standard.forbids, deep_clone(self.nqr.all_magnifiers))
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.override = { wpn_fps_o_pos_a_o_sm = { adds = {} } }
    --for i, k in pairs(self.nqr.all_sights) do self.parts.wpn_fps_smg_coal_o_scopemount_standard.override[k] = nil end
    --table.addto_dict(self.parts.wpn_fps_smg_coal_o_scopemount_standard.override, self.parts.wpn_fps_o_pos_a_o_sm.override)
    self.parts.wpn_fps_smg_coal_o_scopemount_standard.stats = { concealment = 0, weight = 2, sightheight = 1.6 }
    self.parts.wpn_fps_smg_coal_s_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true }
    self.wpn_fps_smg_coal.adds = {}
    self.wpn_fps_smg_coal.override = {
        wpn_fps_smg_coal_s_standard = {},
        wpn_upg_ak_s_folding = { stats = table.copy_append(self.parts.wpn_upg_ak_s_folding.stats, { shoulderable = false }) },
        wpn_upg_ak_s_adapter = { a_obj = "a_s2" },
        wpn_upg_ak_s_psl = { forbids = {
            "wpn_fps_upg_ak_g_hgrip",
            "wpn_fps_upg_ak_g_wgrip",
            "wpn_fps_upg_ak_g_pgrip",
            "wpn_fps_upg_ak_g_rk3",
            "wpn_fps_ass_flint_g_standard",
            "wpn_upg_ak_g_standard",
            "wpn_fps_smg_vityaz_g_standard",
            "wpn_fps_ass_groza_g_standard",
        } },

        wpn_fps_upg_o_ak_scopemount = { a_obj = "a_g2", stats = table.copy_append(self.parts.wpn_fps_upg_o_ak_scopemount.stats, { sightheight = 0.1 }) },
        wpn_fps_smg_coal_o_scopemount_standard = { a_obj = "a_o", stats = table.copy_append(self.parts.wpn_fps_smg_coal_o_scopemount_standard.stats, { sightheight = 0.1 }) },
    }
    for i, k in pairs(self.wpn_fps_ass_74.uses_parts) do
        if self.parts[k] and (self.parts[k].type=="stock" or self.parts[k].type=="stock_addon") then self.wpn_fps_smg_coal.override[k] = self.wpn_fps_smg_coal.override[k] or { a_obj = "a_s2" } end
    end
    table.deletefrom(self.wpn_fps_smg_coal.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_smg_coal.default_blueprint, 1, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_o_pos_a_o_sm")
    table.insert(self.wpn_fps_smg_coal.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_smg_coal.uses_parts, "wpn_fps_upg_cal_9x19")
    table.addto(self.wpn_fps_smg_coal.uses_parts, self.nqr.all_angled_sights)
    table.addto(self.wpn_fps_smg_coal.uses_parts, self.nqr.all_tube_stocks)

    self.parts.wpn_fps_smg_erma_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 9.9 }
    self.parts.wpn_fps_smg_erma_body_standard.stats = { concealment = 0, weight = 0, length = 17 }
    self.parts.wpn_fps_smg_erma_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_erma_extra_rail.pcs = {}
    self.parts.wpn_fps_smg_erma_extra_rail.name_id = "bm_wp_erma_sightrail"
    self.parts.wpn_fps_smg_erma_extra_rail.type = "extra"
    self.parts.wpn_fps_smg_erma_extra_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_erma_mag_standard.stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 32, retention = false }
    self.parts.wpn_fps_smg_erma_ns_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_erma_o_ironsight_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_erma_s_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_erma_s_unfolded.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true }
    self.wpn_fps_smg_erma.adds = {}
    table.deletefrom(self.wpn_fps_smg_erma.uses_parts, self.nqr.all_optics)
    table.insert(self.wpn_fps_smg_erma.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_erma.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_smg_erma_extra_rail")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_erma.uses_parts, "wpn_fps_remove_ns")
    table.addto(self.wpn_fps_smg_erma.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_smg_m45_b_green.stats = { concealment = 0, weight = 0, barrel_length = 8.3 }
    self.parts.wpn_fps_smg_m45_b_small.stats = { concealment = 0, weight = 0, barrel_length = 4.5 } --roughly
    self.parts.wpn_fps_smg_m45_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 8.3 }
    self.parts.wpn_fps_smg_m45_body_green.stats = { concealment = 0, weight = 0, length = 13 }
    self.parts.wpn_fps_smg_m45_body_standard.stats = { concealment = 0, weight = 0, length = 13 }
    self.parts.wpn_fps_smg_m45_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_m45_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_m45_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_m45_m_extended.stats = { concealment = 9, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 50 }
    self.parts.wpn_fps_smg_m45_m_mag.stats = { concealment = 6, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 36 }
    self.parts.wpn_fps_smg_m45_s_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_m45_s_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_nqr_m45_sightrail = {
		a_obj = "a_o",
		type = "extra",
		name_id = "bm_wp_m45_sightrail",
		unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_ris_special",
        pcs = {},
        adds = {},
        forbids = {},
        override = {
            wpn_fps_extra_lock_sights = { forbids = {} },
        },
        stats = { concealment = 0, weight = 2 },
	}
    self.wpn_fps_smg_m45.adds = {}
    self.wpn_fps_smg_m45.override = {
        wpn_fps_addon_ris = { unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_gadget_rail" },
    }
    table.deletefrom(self.wpn_fps_smg_m45.uses_parts, self.nqr.all_optics)
    table.insert(self.wpn_fps_smg_m45.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_m45.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_m45.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_m45.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_m45.uses_parts, "wpn_nqr_m45_sightrail")
    table.insert(self.wpn_fps_smg_m45.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_m45.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_smg_m45.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_smg_mp5_b_m5k.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_smg_mp5_b_mp5a4.stats = { concealment = 0, weight = 0, barrel_length = 8.9 }
    self.parts.wpn_fps_smg_mp5_b_mp5a5.stats = { concealment = 0, weight = 0, barrel_length = 8.9 }
    self.parts.wpn_fps_smg_mp5_b_mp5sd.stats = { concealment = 0, weight = 0, barrel_length = 5.7, length = 3, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_smg_mp5_body_mp5.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_mp5_body_rail.pcs = {}
    self.parts.wpn_fps_smg_mp5_body_rail.name_id = "bm_wp_hk_sightrail"
    self.parts.wpn_fps_smg_mp5_body_rail.type = "extra"
    self.parts.wpn_fps_smg_mp5_body_rail.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_smg_mp5_body_rail.stats = { concealment = 0, weight = 0 }
    --self.parts.wpn_fps_smg_mp5_fg_flash.adds = { "wpn_fps_smg_mp5_b_mp5a5" }
    self.parts.wpn_fps_smg_mp5_fg_flash.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_mp5_fg_m5k.type = "exclusive_set"
    self.parts.wpn_fps_smg_mp5_fg_m5k.rails = { "side", "bottom" }
    self.parts.wpn_fps_smg_mp5_fg_m5k.forbids = { "wpn_fps_smg_mp5_fg_mp5a5", "wpn_fps_smg_mp5_fg_flash", "wpn_fps_smg_mp5_b_mp5a5" }
    self.parts.wpn_fps_smg_mp5_fg_m5k.override = { wpn_fps_smg_mp5_fg_mp5a4 = { unit = fantom_unit } }
    self.parts.wpn_fps_smg_mp5_fg_m5k.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_smg_mp5_fg_mp5a4.adds = { "wpn_fps_smg_mp5_b_mp5a5" }
    self.parts.wpn_fps_smg_mp5_fg_mp5a4.stats = { concealment = 0, weight = 0, barrel_length = 8.9 }
    self.parts.wpn_fps_smg_mp5_fg_mp5a5.rails = { "side", "bottom" }
    self.parts.wpn_fps_smg_mp5_fg_mp5a5.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.type = "exclusive_set"
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.adds = { "wpn_fps_smg_mp5_b_mp5sd" }
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.forbids = { "wpn_fps_smg_mp5_fg_mp5a5", "wpn_fps_smg_mp5_fg_flash", "wpn_fps_smg_mp5_b_mp5a5" }
    table.addto(self.parts.wpn_fps_smg_mp5_fg_mp5sd.forbids, deep_clone(self.nqr.all_bxs))
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.override = { wpn_fps_smg_mp5_fg_mp5a4 = { unit = fantom_unit } }
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.override.wpn_fps_smg_mp5_fg_mp5a5 = { override = {}, }
    self.parts.wpn_fps_smg_mp5_fg_mp5sd.stats = { concealment = 0, weight = 0, barrel_length = 5.7, bleedoff_barrel = true, length = 3, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_smg_mp5_m_drum.pcs = {}
    self.parts.wpn_fps_smg_mp5_m_drum.name_id = "bm_wp_mp5_m_drum"
    self.parts.wpn_fps_smg_mp5_m_drum.stats = { concealment = 18, weight = 5, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 70, retention = false } --roughly
    self.parts.wpn_fps_smg_mp5_m_std.stats = { concealment = 6, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_mp5_m_straight.pcs = nil
    self.parts.wpn_fps_smg_mp5_m_straight.stats = {}
    self.parts.wpn_fps_smg_mp5_s_adjust.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_smg_mp5_s_adjust.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_mp5_s_folding.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_mp5_s_ring.stats = { concealment = 0, weight = 0, shouldered = false }
    self.parts.wpn_fps_smg_mp5_s_solid.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.wpn_fps_smg_mp5.adds = {}
    self.wpn_fps_smg_mp5.override.wpn_fps_upg_cal_40sw = { override = { wpn_fps_smg_mp5_m_std = { unit = self.parts.wpn_fps_smg_mp5_m_straight.unit, forbids = { "wpn_fps_smg_mp5_m_drum" } } } }
    table.deletefrom(self.wpn_fps_smg_mp5.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_smg_mp5.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_mp5.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_mp5.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_smg_mp5_body_rail")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_smg_mp5_m_drum")
    table.insert(self.wpn_fps_smg_mp5.uses_parts, "wpn_fps_upg_cal_40sw")
    table.addto(self.wpn_fps_smg_mp5.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_smg_mp7_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 7.1, md_code = {0,2,0,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_smg_mp7_b_suppressed.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_smg_mp7_b_suppressed.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_smg_mp7_body_ironsights = deep_clone(self.parts.wpn_fps_smg_mp7_body_standard)
    self.parts.wpn_fps_smg_mp7_body_ironsights.type = "ironsight"
    self.parts.wpn_fps_smg_mp7_body_ironsights.adds = {}
    self.parts.wpn_fps_smg_mp7_body_ironsights.visibility = { { objects = { g_charging_handle_lod0 = false, g_body_lod0 = false, g_bolt = false } } }
    self.parts.wpn_fps_smg_mp7_body_ironsights.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_mp7_body_standard.adds = {}
    self.parts.wpn_fps_smg_mp7_body_standard.visibility = { { objects = { g_sights_lod0 = false } } }
    self.parts.wpn_fps_smg_mp7_body_standard.stats = { concealment = 0, weight = 0, length = 7 }
    self.parts.wpn_fps_smg_mp7_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 40 }
    self.parts.wpn_fps_smg_mp7_m_short.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_smg_mp7_s_long.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_smg_mp7_s_long.stats = { concealment = 0, weight = 0, length = 10.01, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_mp7_s_standard.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_smg_mp7_s_standard.stats = { concealment = 0, weight = 0, length = 1, shoulderable = true }
    table.deletefrom(self.wpn_fps_smg_mp7.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_smg_mp7.default_blueprint, "wpn_fps_smg_mp7_body_ironsights")
    table.insert(self.wpn_fps_smg_mp7.uses_parts, "wpn_fps_smg_mp7_body_ironsights")
    table.insert(self.wpn_fps_smg_mp7.default_blueprint, "wpn_fps_upg_vg_ass_smg_stubby")
    table.insert(self.wpn_fps_smg_mp7.uses_parts, "wpn_fps_upg_o_bmg")
    table.insert(self.wpn_fps_smg_mp7.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_mp7.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_smg_mp7.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_smg_p90_b_short.stats = { concealment = 0, weight = 0, barrel_length = 10.4, md_code = {0,0,1,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_smg_p90_b_civilian.forbids = { "wpn_fps_smg_p90_b_ninja" }
    table.addto(self.parts.wpn_fps_smg_p90_b_civilian.forbids, self.nqr.all_bxs)
    self.parts.wpn_fps_smg_p90_b_civilian.stats = { concealment = 0, weight = 0, barrel_length = 18.5 }
    self.parts.wpn_fps_smg_p90_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_smg_p90_b_long.forbids = { "wpn_fps_smg_p90_b_ninja" }
    self.parts.wpn_fps_smg_p90_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16, md_code = {0,0,1,0,0}, md_bulk = {1, 1} }
    self.parts.wpn_fps_smg_p90_b_ninja.type = "barrel_ext"
    self.parts.wpn_fps_smg_p90_b_ninja.forbids = {}
    self.parts.wpn_fps_smg_p90_b_ninja.override = { wpn_fps_smg_p90_b_short = { unit = fantom_unit } }
    self.parts.wpn_fps_smg_p90_b_ninja.stats = { concealment = 0, weight = 8, length = 9, md_code = {5,0,0,0,0} }
    self.parts.wpn_fps_smg_p90_body_boxy.stats = { concealment = 0, weight = 0, length = 12, shouldered = true }
    self.parts.wpn_fps_smg_p90_body_p90.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_smg_p90_m_std.stats = { concealment = 11, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 50 }
    self.parts.wpn_fps_smg_p90_m_strap.stats = { concealment = 11, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 50 }
    table.swap(self.wpn_fps_smg_p90.default_blueprint, "wpn_upg_o_marksmansight_rear", "wpn_fps_gre_arbiter_o_standard")
    table.insert(self.wpn_fps_smg_p90.uses_parts, "wpn_fps_gre_arbiter_o_standard")
    table.insert(self.wpn_fps_smg_p90.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_smg_p90.uses_parts, self.nqr.all_second_sights)

    self.parts.wpn_fps_smg_polymer_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 5.5 }
    self.parts.wpn_fps_smg_polymer_barrel_dummy = deep_clone(self.parts.wpn_fps_smg_polymer_barrel_standard)
    self.parts.wpn_fps_smg_polymer_barrel_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_smg_polymer_barrel_dummy.stats = {}
    self.parts.wpn_fps_smg_polymer_barrel_precision.type = "barrel"
    self.parts.wpn_fps_smg_polymer_barrel_precision.adds = { "wpn_fps_smg_polymer_barrel_dummy" }
    self.parts.wpn_fps_smg_polymer_barrel_precision.forbids = {}
    table.addto(self.parts.wpn_fps_smg_polymer_barrel_precision.forbids, self.nqr.all_bxs)
    self.parts.wpn_fps_smg_polymer_barrel_precision.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_smg_polymer_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_smg_polymer_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_polymer_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_polymer_extra_sling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_polymer_fg_standard.texture_bundle_folder = "turtles"
    self.parts.wpn_fps_smg_polymer_fg_standard.dlc = "turtles"
    self.parts.wpn_fps_smg_polymer_fg_standard.pcs = {}
    self.parts.wpn_fps_smg_polymer_fg_standard.name_id = "bm_wp_polymer_vg"
    self.parts.wpn_fps_smg_polymer_fg_standard.a_obj = "a_vg"
    self.parts.wpn_fps_smg_polymer_fg_standard.type = "vertical_grip"
    self.parts.wpn_fps_smg_polymer_fg_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_smg_polymer_m_standard.stats = { concealment = 7, weight = 3, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = { [".45 ACP"] = 25, ["9x19"] = 30 }, retention = false }
    self.parts.wpn_fps_smg_polymer_ns_silencer.stats = { concealment = 15, weight = 6, length = 7, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_smg_polymer_o_iron.forbids = {}
    table.addto(self.parts.wpn_fps_smg_polymer_o_iron.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_spot, self.nqr.i_f_c96, self.nqr.i_f_acog))
    self.parts.wpn_fps_smg_polymer_o_iron.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_smg_polymer_s_adapter.pcs = {}
    self.parts.wpn_fps_smg_polymer_s_adapter.type = "stock"
    self.parts.wpn_fps_smg_polymer_s_adapter.stats = { concealment = 0, weight = 0, legnth = 7, shoulderable = true }
    self.parts.wpn_fps_smg_polymer_s_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true, cheek = -1 }
    self.wpn_fps_smg_polymer.override = {
        wpn_fps_addon_ris = { unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_gadget_rail" },
        wpn_fps_smg_schakal_vg_surefire_flashlight = { a_obj = "a_fg" },
    }
    for i, k in pairs (self.nqr.all_vertical_grips) do self.wpn_fps_smg_polymer.override[k] = { a_obj = "a_fg" } end
    table.addto(self.wpn_fps_smg_polymer.uses_parts, self.nqr.all_angled_sights)
    table.insert(self.wpn_fps_smg_polymer.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_polymer.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_polymer.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_polymer.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_polymer.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_smg_polymer.uses_parts, "wpn_fps_upg_cal_9x19")
    table.addto(self.wpn_fps_smg_polymer.uses_parts, self.nqr.all_tube_stocks)

    table.addto(self.wpn_fps_smg_schakal.uses_parts, self.nqr.all_angled_sights)
    self.parts.wpn_fps_smg_schakal_b_civil.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_smg_schakal_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 7.9 }
    self.parts.wpn_fps_smg_schakal_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_schakal_body_upper.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_smg_schakal_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_schakal_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_schakal_extra_magrelease.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_schakal_m_short.stats = { concealment = 4, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = { [".45 ACP"] = 15, ["9x19"] = 20 } }
    self.parts.wpn_fps_smg_schakal_m_standard.stats = { concealment = 7, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = { [".45 ACP"] = 25, ["9x19"] = 30 } }
    self.parts.wpn_fps_smg_schakal_m_long.stats = { concealment = 12, weight = 3, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 40, ["9x19"] = 50 } }
    self.parts.wpn_fps_smg_schakal_ns_silencer.sound_switch.suppressed = "suppressed_b"
    self.parts.wpn_fps_smg_schakal_ns_silencer.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_smg_schakal_s_civil.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_smg_schakal_s_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_schakal_s_standard.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_schakal_vg_extra.stats = { concealment = 0, weight = 0 }
    --self.parts.wpn_fps_smg_schakal_vg_surefire.adds = {}
    --self.parts.wpn_fps_smg_schakal_vg_surefire.a_obj = "a_fl"
    self.parts.wpn_fps_smg_schakal_vg_surefire.sub_type = nil --"flashlight"
    self.parts.wpn_fps_smg_schakal_vg_surefire.perks = nil --"flashlight"
    self.parts.wpn_fps_smg_schakal_vg_surefire.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_smg_schakal_vg_surefire_flashlight.type = "gadget_extra"
    table.insert(self.wpn_fps_smg_schakal.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_schakal.uses_parts, "wpn_fps_upg_cal_9x19")

    self.parts.wpn_fps_smg_shepheard_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 8 }
    self.parts.wpn_fps_smg_shepheard_body.forbids = { "wpn_fps_shepheard_b_short" }
    self.parts.wpn_fps_smg_shepheard_body.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_shepheard_body_short.override.wpn_fps_smg_shepheard_b_standard = nil
    self.parts.wpn_fps_smg_shepheard_body_short.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_g_standard.pcs = {}
    self.parts.wpn_fps_smg_shepheard_g_standard.name_id = "bm_wp_fps_smg_shepheard_g_standard"
    self.parts.wpn_fps_smg_shepheard_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_mag_extended.stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_shepheard_mag_standard.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_smg_shepheard_ns_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_smg_shepheard_o_standard.forbids, table.combine(self.nqr.i_f_base_lpvo, self.nqr.i_f_spot, self.nqr.i_f_c96, self.nqr.i_f_acog))
    self.parts.wpn_fps_smg_shepheard_o_standard.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_smg_shepheard_s_adapter.pcs = {}
    self.parts.wpn_fps_smg_shepheard_s_adapter.type = "stock"
    self.parts.wpn_fps_smg_shepheard_s_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_s_no.name_id = "bm_wp_remove_s"
    self.parts.wpn_fps_smg_shepheard_s_no.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_shepheard_s_standard.desc_id = "bm_wp_stock_collapsable_desc"
    self.parts.wpn_fps_smg_shepheard_s_standard.stats = { concealment = 0, weight = 0, length = 7.03, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_shepheard_b_short = {
		a_obj = "a_b",
		type = "barrel",
		name_id = "bm_wp_shepard_b_short",
		unit = "units/pd2_dlc_joy/weapons/wpn_fps_smg_shepheard_pts/wpn_fps_smg_shepheard_b_short",
        third_unit = "units/pd2_dlc_joy/weapons/wpn_fps_smg_shepheard_pts/wpn_third_smg_shepheard_b_short",
        pcs = {},
		adds = {}, forbids = {}, override = {}, stats = {},
	}
    self.wpn_fps_smg_shepheard.override = {
        wpn_fps_smg_shepheard_o_standard = { forbids = {} } --todo
    }
    table.swap(self.wpn_fps_smg_shepheard.default_blueprint, "wpn_fps_smg_shepheard_ns_standard", "wpn_fps_ass_komodo_ns")
    table.insert(self.wpn_fps_smg_shepheard.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_shepheard.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_shepheard_b_short")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_smg_shepheard.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_smg_shepheard.uses_parts, self.nqr.all_angled_sights)
    table.addto(self.wpn_fps_smg_shepheard.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_smg_shepheard.uses_parts, self.nqr.all_m4_grips)

    table.deletefrom(self.wpn_fps_smg_sterling.uses_parts, self.nqr.all_optics)
    table.addto(self.wpn_fps_smg_sterling.uses_parts, self.nqr.all_angled_sights)
    self.parts.wpn_fps_smg_sterling_o_adapter.pcs = {}
    self.parts.wpn_fps_smg_sterling_o_adapter.name_id = "bm_wp_sterling_sightrail"
    self.parts.wpn_fps_smg_sterling_o_adapter.type = "extra"
    self.wpn_fps_smg_sterling.adds = {}
    table.insert(self.wpn_fps_smg_sterling.uses_parts, "wpn_fps_smg_sterling_o_adapter")
    table.insert(self.wpn_fps_smg_sterling.uses_parts, "wpn_fps_addon_ris")
    self.parts.wpn_fps_smg_sterling_b_e11.stats = { concealment = 0, weight = 0, barrel_length = 7.7 }
    self.parts.wpn_fps_smg_sterling_b_short.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_smg_sterling_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 7.7 }
    self.parts.wpn_fps_smg_sterling_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16.3 }
    self.parts.wpn_fps_smg_sterling_b_suppressed.stats = { concealment = 0, weight = 0, barrel_length = 7.8, length = 5, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_smg_sterling_body_standard.stats = { concealment = 0, weight = 0, length = 11 }
    self.parts.wpn_fps_smg_sterling_m_long.stats = { concealment = 7, weight = 3, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 34, retention = false }
    self.parts.wpn_fps_smg_sterling_m_medium.stats = { concealment = 4, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 20, retention = false }
    self.parts.wpn_fps_smg_sterling_m_short.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 10, retention = false }
    self.parts.wpn_fps_smg_sterling_o_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_sterling_s_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_sterling_s_nostock.name_id = "bm_wp_remove_s"
    self.parts.wpn_fps_smg_sterling_s_nostock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_sterling_s_solid.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    self.parts.wpn_fps_smg_sterling_s_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true }
    table.insert(self.wpn_fps_smg_sterling.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_sterling.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_sterling.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_sterling.uses_parts, "wpn_fps_extra2_lock_gadgets")

    table.deletefrom(self.wpn_fps_smg_thompson.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_smg_thompson.uses_parts, self.nqr.all_gadgets)
    self.parts.wpn_fps_smg_thompson_barrel.stats = { concealment = 0, weight = 0, barrel_length = 10.5 }
    self.parts.wpn_fps_smg_thompson_barrel_long.stats = { concealment = 0, weight = 0, barrel_length = 16.5 }
    self.parts.wpn_fps_smg_thompson_barrel_short.override = {}
    self.parts.wpn_fps_smg_thompson_barrel_short.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_smg_thompson_body.stats = { concealment = 0, weight = 0, length = 12 }
    self.parts.wpn_fps_smg_thompson_drummag.stats = { concealment = 17, weight = 13, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 50, retention = false } --not_sure
    self.parts.wpn_fps_smg_thompson_fl_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_foregrip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_foregrip_discrete.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_grip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_grip_discrete.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_smg_thompson_o_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_thompson_stock.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_smg_thompson_stock_discrete.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_smg_thompson_stock_nostock.stats = { concealment = 0, weight = 0, shouldered = false }
    table.insert(self.wpn_fps_smg_thompson.uses_parts, "wpn_fps_remove_ns")

    self.parts.wpn_fps_smg_uzi_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 10.2 }
    for i, k in pairs(self.nqr.all_mds) do self.parts.wpn_fps_smg_uzi_b_standard.override[k] = { a_obj = "a_ns_1" } end
    self.parts.wpn_fps_smg_uzi_b_suppressed.has_description = true
    self.parts.wpn_fps_smg_uzi_b_suppressed.desc_id = "bm_wp_also_foregrip"
    self.parts.wpn_fps_smg_uzi_b_suppressed.a_obj = "a_ns"
    self.parts.wpn_fps_smg_uzi_b_suppressed.parent = "barrel"
    self.parts.wpn_fps_smg_uzi_b_suppressed.stats = { concealment = 14, weight = 6, length = 10, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_smg_uzi_body_standard.stats = { concealment = 0, weight = 0, barrel_length = 7 }
    self.parts.wpn_fps_smg_uzi_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_uzi_fg_rail.rails = { "side", "bottom" }
    self.parts.wpn_fps_smg_uzi_fg_rail.adds = { "wpn_fps_upg_vg_ass_smg_verticalgrip" }
    self.parts.wpn_fps_smg_uzi_fg_rail.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_smg_uzi_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_uzi_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_uzi_s_leather.stats = { concealment = 0, weight = 3, length = 7, shouldered = true, cheek = 1 }
    self.parts.wpn_fps_smg_uzi_s_solid.stats = { concealment = 0, weight = 4, length = 9, shouldered = true }
    self.parts.wpn_fps_smg_uzi_s_standard.stats = { concealment = 0, weight = 4, length = 1, shoulderable = true }
    self.parts.wpn_fps_smg_uzi_s_unfolded.stats = { concealment = 0, weight = 4, length = 9.01, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_uzi_sightrail = deep_clone(self.parts.wpn_fps_shot_r870_ris_special)
    self.parts.wpn_fps_smg_uzi_sightrail.pcs = {}
    self.parts.wpn_fps_smg_uzi_sightrail.name_id = "bm_wp_uzi_sightrail"
    self.parts.wpn_fps_smg_uzi_sightrail.rails = { "top" }
    self.parts.wpn_fps_smg_uzi_sightrail.stats = { concealment = 0, weight = 2 }
    self.wpn_fps_smg_uzi.adds = {}
    self.wpn_fps_smg_uzi.override = {
        wpn_fps_smg_uzi_b_suppressed = { a_obj = "a_b", parent = false }
    }
    for i, k in pairs(self.nqr.all_vertical_grips) do
        self.wpn_fps_smg_uzi.override[k] = {
            forbids = { "wpn_fps_upg_vg_ass_smg_verticalgrip" },
            stats = table.copy_append(self.parts[k].stats, { weight = self.parts[k].stats.weight-1 })
        }
    end
    self.wpn_fps_smg_uzi.override.wpn_fps_upg_vg_ass_smg_verticalgrip = nil
    table.deletefrom(self.wpn_fps_smg_uzi.uses_parts, self.nqr.all_optics)
    table.delete(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_upg_vg_ass_smg_verticalgrip")
    table.insert(self.wpn_fps_smg_uzi.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_uzi.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_uzi.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_smg_uzi_sightrail")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_uzi.uses_parts, "wpn_fps_upg_cal_45acp")
    table.addto(self.wpn_fps_smg_uzi.uses_parts, self.nqr.all_angled_sights)

    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_smg_vityaz_fg_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_smg_vityaz_fg_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_smg_vityaz_fg_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_smg_vityaz_fg_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_smg_vityaz_fg_standard")
    table.insert(self.wpn_fps_smg_akmsu.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_flint.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_groza.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    table.insert(self.wpn_fps_ass_tkb.uses_parts, "wpn_fps_smg_vityaz_g_standard")
    self.parts.wpn_fps_smg_vityaz_b_long.adds = {}
    self.parts.wpn_fps_smg_vityaz_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_smg_vityaz_b_standard.adds = {}
    self.parts.wpn_fps_smg_vityaz_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 9.4 }
    self.parts.wpn_fps_smg_vityaz_body_standard.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_vityaz_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_vityaz_fg_standard.pcs = {}
    self.parts.wpn_fps_smg_vityaz_fg_standard.name_id = "bm_wp_fps_smg_vityaz_fg_standard"
    self.parts.wpn_fps_smg_vityaz_fg_standard.dlc = "fawp"
    self.parts.wpn_fps_smg_vityaz_fg_standard.texture_bundle_folder = "fawp"
    self.parts.wpn_fps_smg_vityaz_fg_standard.rails = { "side", "bottom" }
    self.parts.wpn_fps_smg_vityaz_fg_standard.adds = {}
    self.parts.wpn_fps_smg_vityaz_fg_standard.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_fps_smg_vityaz_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_vityaz_g_standard.pcs = {}
    self.parts.wpn_fps_smg_vityaz_g_standard.name_id = "bm_wp_fps_smg_vityaz_g_standard"
    self.parts.wpn_fps_smg_vityaz_g_standard.dlc = "fawp"
    self.parts.wpn_fps_smg_vityaz_g_standard.texture_bundle_folder = "fawp"
    self.parts.wpn_fps_smg_vityaz_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_vityaz_m_standard.stats = { concealment = 7, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_vityaz_ns_standard.name_id = "bm_wp_vityaz_ns_standard"
    self.parts.wpn_fps_smg_vityaz_ns_standard.pcs = {}
    self.parts.wpn_fps_smg_vityaz_ns_standard.dlc = "fawp"
    self.parts.wpn_fps_smg_vityaz_ns_standard.texture_bundle_folder = "fawp"
    self.parts.wpn_fps_smg_vityaz_ns_standard.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,1,1,0,0} }
    --self.parts.wpn_fps_smg_vityaz_b_supressed.parent = "barrel"
    --self.parts.wpn_fps_smg_vityaz_b_supressed.a_obj = "a_fg"
    --self.parts.wpn_fps_smg_vityaz_b_supressed.type = "barrel_ext"
    --self.parts.wpn_fps_smg_vityaz_b_supressed.forbids = {}
    self.parts.wpn_fps_smg_vityaz_b_supressed.sound_switch.suppressed = "suppressed_a"
    self.parts.wpn_fps_smg_vityaz_b_supressed.stats = { concealment = 8, weight = 3, md_code = {1,1,0,0,0} }
    self.parts.wpn_fps_smg_vityaz_s_short.stats = { concealment = 0, weight = 0, length = 1, shouldered = false }
    self.parts.wpn_fps_smg_vityaz_s_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true, shoulderable = true }
    table.deletefrom(self.wpn_fps_smg_vityaz.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_smg_vityaz.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_smg_vityaz.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    --table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_upg_ak_s_adapter") --todo
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_vityaz.uses_parts, "wpn_fps_remove_ns")
    table.addto(self.wpn_fps_smg_vityaz.uses_parts, self.nqr.all_second_sights)

    self.wpn_fps_ass_sub2000.sightheight_mod = 1.8
    self.parts.wpn_fps_ass_sub2000_b_std.adds = {}
    self.parts.wpn_fps_ass_sub2000_b_std.stats = { concealment = 0, weight = 0, barrel_length = 16.3 }
    self.parts.wpn_fps_ass_sub2000_body_gen1.adds = { "wpn_fps_ass_sub2000_fg_gen1" }
    self.parts.wpn_fps_ass_sub2000_body_gen1.forbids = { "wpn_fps_ass_sub2000_fg_suppressed" }
    self.parts.wpn_fps_ass_sub2000_body_gen1.stats = { concealment = 0, weight = 0, length = 14, shouldered = true, foldable = true }
    self.parts.wpn_fps_ass_sub2000_body_gen2.stats = {}
    self.parts.wpn_fps_ass_sub2000_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_sub2000_fg_gen1.adds = {}
    self.parts.wpn_fps_ass_sub2000_fg_gen1.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_sub2000_fg_gen2_orig = deep_clone(self.parts.wpn_fps_ass_sub2000_fg_gen2)
    self.parts.wpn_fps_ass_sub2000_fg_gen2_orig.adds = {}
    self.parts.wpn_fps_ass_sub2000_fg_gen2_orig.override = {}
    self.parts.wpn_fps_ass_sub2000_fg_gen2.unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_body_gen2"
    self.parts.wpn_fps_ass_sub2000_fg_gen2.a_obj = "a_body"
    self.parts.wpn_fps_ass_sub2000_fg_gen2.type = "upper_reciever"
    self.parts.wpn_fps_ass_sub2000_fg_gen2.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_ass_sub2000_fg_gen2.adds = { "wpn_fps_ass_sub2000_fg_gen2_orig" }
    self.parts.wpn_fps_ass_sub2000_fg_gen2.forbids = { "wpn_fps_ass_sub2000_o_adapter", "wpn_fps_ass_sub2000_fg_railed" }
    self.parts.wpn_fps_ass_sub2000_fg_gen2.override = {
        --[[wpn_fps_ass_sub2000_fg_suppressed = { override = {
            wpn_fps_ass_sub2000_fg_gen2_orig = {
                third_unit = "units/pd2_dlc_casino/weapons/wpn_third_ass_sub2000_pts/wpn_third_ass_sub2000_fg_suppressed",
                unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_fg_suppressed",
            }
        } },]]
    }
    self.parts.wpn_fps_ass_sub2000_fg_gen2.stats = { concealment = 0, weight = 0, length = 14, sightheight = -1.2, shouldered = true, foldable = true }
    --self.parts.wpn_fps_ass_sub2000_fg_railed.unit = fantom_unit
    self.parts.wpn_fps_ass_sub2000_fg_railed.rails = { "top", "bottom" }
    self.parts.wpn_fps_ass_sub2000_fg_railed.forbids = { "wpn_fps_ass_sub2000_o_adapter", "wpn_fps_ass_sub2000_fg_gen1" }
    self.parts.wpn_fps_ass_sub2000_fg_railed.stats = { concealment = 0, weight = 0, sightheight = -0.9 }
    self.parts.wpn_fps_ass_sub2000_ns_supp = deep_clone(self.parts.wpn_fps_ass_sub2000_fg_suppressed)
    self.parts.wpn_fps_ass_sub2000_ns_supp.name_id = "bm_wp_sub2000_ns_supp"
    self.parts.wpn_fps_ass_sub2000_ns_supp.unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_ns_supp"
    self.parts.wpn_fps_ass_sub2000_ns_supp.type = "barrel_ext"
    self.parts.wpn_fps_ass_sub2000_ns_supp.a_obj = "a_ns"
    self.parts.wpn_fps_ass_sub2000_ns_supp.parent = "barrel"
    self.parts.wpn_fps_ass_sub2000_ns_supp.forbids = {}
    self.parts.wpn_fps_ass_sub2000_ns_supp.override = {}
    self.parts.wpn_fps_ass_sub2000_ns_supp.animations = nil
    self.parts.wpn_fps_ass_sub2000_ns_supp.stats = deep_clone(self.nqr.sps_stats.medium)
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.is_a_unlockable = nil
    --self.parts.wpn_fps_ass_sub2000_fg_suppressed.unit = fantom_unit
    --self.parts.wpn_fps_ass_sub2000_fg_suppressed.type = "exclusive_set"
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.perks = nil
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.sound_switch = nil
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.forbids = { "wpn_fps_ass_sub2000_fg_gen2_orig", "wpn_fps_ass_sub2000_o_front" }
    --table.addto(self.parts.wpn_fps_ass_sub2000_fg_suppressed.forbids, self.nqr.all_bxs)
    --self.parts.wpn_fps_ass_sub2000_fg_suppressed.override = {
    --    wpn_fps_ass_sub2000_fg_gen2_orig = {
    --        third_unit = "units/pd2_dlc_casino/weapons/wpn_third_ass_sub2000_pts/wpn_third_ass_sub2000_fg_suppressed",
    --        unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_fg_suppressed",
    --    },
    --}
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.override = {
        wpn_fps_ass_sub2000_b_std = { stats = {} },
        --wpn_fps_ass_sub2000_fg_gen2_orig = {
        --    third_unit = "units/pd2_dlc_casino/weapons/wpn_third_ass_sub2000_pts/wpn_third_ass_sub2000_fg_suppressed",
        ---    unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_fg_suppressed",
        --},
    }
    self.parts.wpn_fps_ass_sub2000_fg_suppressed.stats = { concealment = 0, weight = 0, barrel_length = 9, sightheight = -0.15 }
    --self.parts.wpn_fps_ass_sub2000_m_standard.stats = { concealment = 5, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = { ["9x19"] = 33, [".40 S&W"] = 29 } }
    self.parts.wpn_fps_ass_sub2000_o_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_ass_sub2000_o_back.type = "ironsight"
    self.parts.wpn_fps_ass_sub2000_o_back.adds = { "wpn_fps_ass_sub2000_o_front" }
    self.parts.wpn_fps_ass_sub2000_o_back.stats = { concealment = 0, weight = 0, sightheight = self.wpn_fps_ass_sub2000.sightheight_mod }
    self.parts.wpn_fps_ass_sub2000_o_back_down.stats = {}
    self.parts.wpn_fps_ass_sub2000_o_adapter.pcs = {}
    self.parts.wpn_fps_ass_sub2000_o_adapter.name_id = "bm_wp_sub2000_sightrail"
    self.parts.wpn_fps_ass_sub2000_o_adapter.unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_ris_special"
    self.parts.wpn_fps_ass_sub2000_o_adapter.type = "extra"
    self.parts.wpn_fps_ass_sub2000_o_adapter.rails = { "top" }
    self.parts.wpn_fps_ass_sub2000_o_adapter.override = {}
    for i, k in pairs(self.nqr.all_sights_no_optics) do if not self.parts[k].parent then self.parts.wpn_fps_ass_sub2000_o_adapter.override[k] = { a_obj = "a_o_adapter" } end end
    self.parts.wpn_fps_ass_sub2000_o_adapter.stats = { concealment = 4, weight = 2, sightheight = 0 }
    self.wpn_fps_ass_sub2000.adds = {}
    self.wpn_fps_ass_sub2000.override = {
        wpn_fps_addon_ris = { parent = "foregrip" },
        wpn_nqr_extra3_rail = { parent = "foregrip" },
        wpn_fps_pis_g18c_m_mag_17rnd = {
            unit = "units/pd2_dlc_casino/weapons/wpn_fps_ass_sub2000_pts/wpn_fps_ass_sub2000_m_short",
            stats = { concealment = 3, weight = 1, mag_amount = { 6, 9, 12 }, CLIP_AMMO_MAX = { ["9x19"] = 19, [".40 S&W"] = 16 } },
        },
        wpn_fps_pis_g18c_m_mag_33rnd = {
            unit = self.parts.wpn_fps_ass_sub2000_m_standard.unit,
            stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = { ["9x19"] = 33, [".40 S&W"] = 29 } },
        },
        wpn_fps_fold_ironsight = {
            unit = self.parts.wpn_fps_ass_sub2000_o_back_down.unit,
            a_obj = self.parts.wpn_fps_ass_sub2000_o_back_down.a_obj,
            adds = { "wpn_fps_ass_sub2000_o_front" },
        },
    }
    for i, k in pairs(self.nqr.all_sights_no_optics) do
        if not self.parts[k].parent then
            self.wpn_fps_ass_sub2000.override[k] = { parent = "foregrip", override = {
                wpn_fps_ass_sub2000_body_gen1 = { stats = table.copy_append(self.parts.wpn_fps_ass_sub2000_body_gen1.stats, {foldable = false}) },
                wpn_fps_ass_sub2000_fg_gen2 = { stats = table.copy_append(self.parts.wpn_fps_ass_sub2000_fg_gen2.stats, {foldable = false}) },
            } }
        end
    end
    for i, k in pairs(table.with(self.nqr.all_vertical_grips, self.nqr.all_bxs_sbr)) do self.wpn_fps_ass_sub2000.override[k] = { parent = "foregrip" } end
    for i, k in pairs(self.nqr.all_gadgets) do self.wpn_fps_ass_sub2000.override[k] = { parent = "foregrip" } end
    table.deletefrom(self.wpn_fps_ass_sub2000.uses_parts, self.nqr.all_optics)
    table.delete(self.wpn_fps_ass_sub2000.default_blueprint, "wpn_fps_ass_sub2000_o_front")
    table.delete(self.wpn_fps_ass_sub2000.default_blueprint, "wpn_fps_ass_sub2000_fg_gen1")
    table.swap(self.wpn_fps_ass_sub2000.default_blueprint, "wpn_fps_ass_sub2000_m_standard", "wpn_fps_pis_g18c_m_mag_17rnd")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_pis_g18c_m_mag_17rnd")
    table.insert(self.wpn_fps_ass_sub2000.default_blueprint, 1, "wpn_fps_fg_lock_sights")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_fg_lock_sights")
    table.insert(self.wpn_fps_ass_sub2000.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_ass_sub2000.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_pis_g18c_m_mag_33rnd")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_ass_sub2000_o_adapter")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_upg_cal_40sw")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_ass_sub2000.uses_parts, "wpn_fps_fold_ironsight")
    table.addto(self.wpn_fps_ass_sub2000.uses_parts, self.nqr.all_vertical_grips)



----MACHINE PISTOL
    self.wpn_fps_smg_fmg9.sightheight_mod = height_dflt+0.8
    self.parts.wpn_fps_smg_fmg9_b_dummy.stats = { concealment = 0, weight = 0, barrel_length = 6.6 } --not_sure
    self.parts.wpn_fps_smg_fmg9_body.adds = {}
    self.parts.wpn_fps_smg_fmg9_body.stats = { concealment = 0, weight = 0, length = 4 }
    self.parts.wpn_fps_smg_fmg9_body_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_conversion_display_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_conversion_laser_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_dh.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_dh_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_fg.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_grip.type = "grip_base"
    self.parts.wpn_fps_smg_fmg9_grip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_grip_tape.type = "grip"
    self.parts.wpn_fps_smg_fmg9_grip_tape.parent = "grip_base"
    self.parts.wpn_fps_smg_fmg9_grip_tape.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_fmg9_m_speed.parent = "grip_base"
    self.parts.wpn_fps_smg_fmg9_m_speed.stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 27 }
    self.parts.wpn_fps_smg_fmg9_m_standard.parent = "grip_base"
    self.parts.wpn_fps_smg_fmg9_m_standard.stats = { concealment = 6, weight = 2, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 27 }
    self.parts.wpn_fps_smg_fmg9_o_sight.sub_type = "ironsight"
    self.parts.wpn_fps_smg_fmg9_o_sight.forbids = { "wpn_fps_upg_fl_pis_x400v" }
    table.addto(self.parts.wpn_fps_smg_fmg9_o_sight.forbids, self.nqr.all_second_sights)
    self.parts.wpn_fps_smg_fmg9_o_sight.stats = { concealment = 0, weight = 1, sightheight = self.wpn_fps_smg_fmg9.sightheight_mod }
    self.parts.wpn_fps_smg_fmg9_stock.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, foldable = true }
    self.parts.wpn_fps_smg_fmg9_stock_padded.stats = { concealment = 0, weight = 1, length = 10, shouldered = true, foldable = true }
    self.wpn_fps_smg_fmg9.override.wpn_fps_pis_c96_sight = { forbids = table.with(self.nqr.all_magnifiers, self.nqr.all_gadgets) }
    self.wpn_fps_smg_fmg9.override.wpn_fps_upg_o_tf90 = { forbids = table.with(self.nqr.all_magnifiers, self.nqr.all_gadgets) }
    self.wpn_fps_smg_fmg9.override.wpn_fps_upg_o_spot = { forbids = table.with(self.nqr.all_magnifiers, self.nqr.all_gadgets) }
    for i, k in pairs(self.nqr.all_bxs_sbp) do self.wpn_fps_smg_fmg9.override[k] = { parent = "reciever" } end
    table.addto(self.wpn_fps_smg_fmg9.uses_parts, self.nqr.all_sights_no_snoptics)
    table.deletefrom(self.wpn_fps_smg_fmg9.uses_parts, self.nqr.all_bxs)
    table.insert(self.wpn_fps_smg_fmg9.default_blueprint, "wpn_fps_smg_fmg9_b_dummy")
    table.insert(self.wpn_fps_smg_fmg9.uses_parts, "wpn_fps_smg_fmg9_b_dummy")
    table.addto(self.wpn_fps_smg_fmg9.uses_parts, self.nqr.all_bxs_sbp)
    table.addto(self.wpn_fps_smg_fmg9.uses_parts, self.nqr.all_pistol_gadgets)
    --table.insert(self.wpn_fps_smg_fmg9.uses_parts, "wpn_fps_remove_o")

    self.parts.wpn_fps_smg_baka_b_dummy = deep_clone(self.parts.wpn_fps_smg_baka_b_standard)
    self.parts.wpn_fps_smg_baka_b_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_smg_baka_b_dummy.a_obj = "a_ns"
    self.parts.wpn_fps_smg_baka_b_dummy.parent = "barrel"
    self.parts.wpn_fps_smg_baka_b_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_baka_b_dummy2 = deep_clone(self.parts.wpn_fps_smg_baka_b_comp)
    self.parts.wpn_fps_smg_baka_b_dummy2.type = "barrel_dummy2"
    self.parts.wpn_fps_smg_baka_b_dummy2.a_obj = "a_ns"
    self.parts.wpn_fps_smg_baka_b_dummy2.parent = "barrel"
    self.parts.wpn_fps_smg_baka_b_dummy2.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_baka_b_standard.unit = self.parts.wpn_fps_smg_baka_b_comp.unit
    self.parts.wpn_fps_smg_baka_b_standard.adds = { "wpn_fps_smg_baka_b_dummy" }
    self.parts.wpn_fps_smg_baka_b_standard.visibility = { { objects = { g_b = false } } }
    self.parts.wpn_fps_smg_baka_b_standard.stats = { concealment = 1, weight = 1, barrel_length = 4.6 }
    self.parts.wpn_fps_smg_baka_b_comp.forbids = { "wpn_fps_smg_baka_b_dummy" }
    self.parts.wpn_fps_smg_baka_b_comp.stats = { concealment = 0, weight = 0, barrel_length = 4.6, md_code = {0,0,1,0,0}, md_bulk = {1,1} }
    self.parts.wpn_fps_smg_baka_b_smallsupp.a_obj = "a_ns"
    self.parts.wpn_fps_smg_baka_b_smallsupp.parent = "barrel"
    self.parts.wpn_fps_smg_baka_b_smallsupp.adds = { "wpn_fps_smg_baka_b_dummy2" }
    self.parts.wpn_fps_smg_baka_b_smallsupp.sound_switch.suppressed = "suppressed_a"
    self.parts.wpn_fps_smg_baka_b_smallsupp.visibility = { { objects = { g_b = false } } }
    self.parts.wpn_fps_smg_baka_b_smallsupp.stats = deep_clone(self.nqr.sps_stats.small)
    self.parts.wpn_fps_smg_baka_b_midsupp.a_obj = "a_ns"
    self.parts.wpn_fps_smg_baka_b_midsupp.parent = "barrel"
    self.parts.wpn_fps_smg_baka_b_midsupp.adds = { "wpn_fps_smg_baka_b_dummy2" }
    self.parts.wpn_fps_smg_baka_b_midsupp.visibility = { { objects = { g_b = false } } }
    self.parts.wpn_fps_smg_baka_b_midsupp.stats = deep_clone(self.nqr.sps_stats.thicc)
    self.parts.wpn_fps_smg_baka_b_longsupp.a_obj = "a_ns"
    self.parts.wpn_fps_smg_baka_b_longsupp.parent = "barrel"
    self.parts.wpn_fps_smg_baka_b_longsupp.adds = { "wpn_fps_smg_baka_b_dummy2" }
    self.parts.wpn_fps_smg_baka_b_longsupp.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_smg_baka_b_longsupp.visibility = { { objects = { g_b = false } } }
    self.parts.wpn_fps_smg_baka_b_longsupp.stats = deep_clone(self.nqr.sps_stats.giant)
    self.parts.wpn_fps_smg_baka_body_standard.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_smg_baka_fl_adapter.pcs = {}
    self.parts.wpn_fps_smg_baka_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_smg_baka_fl_adapter.type = "extra3"
    self.parts.wpn_fps_smg_baka_fl_adapter.override = { wpn_fps_extra2_lock_gadgets_and_vertical_grips = { forbids = {} } }
    self.parts.wpn_fps_smg_baka_fl_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_baka_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_baka_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_baka_o_adapter.pcs = {}
    self.parts.wpn_fps_smg_baka_o_adapter.rails = { "top" }
    self.parts.wpn_fps_smg_baka_o_adapter.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_smg_baka_o_adapter.stats = { concealment = 0, weight = 0, sightheight = 2.55 }
    self.parts.wpn_fps_smg_baka_s_folded.stats = { concealment = 0, weight = 0, shouldered = false, shoulderable = true }
    self.parts.wpn_fps_smg_baka_s_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_baka_s_unfolded.stats = { concealment = 0, weight = 0, length = 9, shouldered = true, shoulderable = true }
    self.wpn_fps_smg_baka.adds = {}
    self.wpn_fps_smg_baka.override = {
        wpn_fps_smg_baka_b_midsupp = { a_obj = "a_b", parent = false, adds = {} },
        wpn_fps_smg_baka_b_smallsupp = { a_obj = "a_b", parent = false, adds = {} },
        wpn_fps_smg_baka_b_longsupp = { a_obj = "a_b", parent = false, adds = {} },
        wpn_fps_smg_baka_b_dummy = { a_obj = "a_b", parent = false },
        wpn_fps_smg_baka_b_dummy2 = { a_obj = "a_b", parent = false },
    }
    table.addto_dict(self.wpn_fps_smg_baka.override, overrides_vertical_grip_and_gadget_thing)
    table.addto(self.wpn_fps_smg_baka.uses_parts, self.nqr.all_light_reddots)
    table.deletefrom(self.wpn_fps_smg_baka.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_baka.uses_parts, self.nqr.all_bxs_mbp)
    table.insert(self.wpn_fps_smg_baka.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_baka.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_baka.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_baka.uses_parts, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_baka.uses_parts, "wpn_fps_smg_baka_o_adapter")
    table.insert(self.wpn_fps_smg_baka.uses_parts, "wpn_fps_smg_baka_fl_adapter")
    table.insert(self.wpn_fps_smg_baka.uses_parts, "wpn_fps_smg_cobray_ns_barrelextension")

    self.parts.wpn_fps_smg_tec9_b_long.stats = { concealment = 0, weight = 0, barrel_length = 5 }
    self.parts.wpn_fps_smg_tec9_b_standard.forbids = { "wpn_fps_smg_tec9_ns_ext" }
    self.parts.wpn_fps_smg_tec9_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 3 }
    self.parts.wpn_fps_smg_tec9_body_standard.stats = { concealment = 0, weight = 0, length = 7 }
    self.parts.wpn_fps_smg_tec9_m_extended.stats = { concealment = 9, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 50 }
    self.parts.wpn_fps_smg_tec9_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_tec9_ns_ext.has_description = true
    self.parts.wpn_fps_smg_tec9_ns_ext.desc_id = "bm_wp_also_foregrip"
    self.parts.wpn_fps_smg_tec9_ns_ext.type = "barrel_ext"
    self.parts.wpn_fps_smg_tec9_ns_ext.forbids = {}
    self.parts.wpn_fps_smg_tec9_ns_ext.visibility = { { objects = { g_ur_lod0 = false, g_draghandle_lod0 = false } } }
    self.parts.wpn_fps_smg_tec9_ns_ext.stats = { concealment = 10, weight = 3, length = 7 }
    self.parts.wpn_fps_smg_tec9_s_unfolded.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_smg_tec9_sightrail = deep_clone(self.parts.wpn_fps_shot_r870_ris_special)
    self.parts.wpn_fps_smg_tec9_sightrail.pcs = {}
    self.parts.wpn_fps_smg_tec9_sightrail.name_id = "bm_wp_tec9_sightrail"
    self.parts.wpn_fps_smg_tec9_sightrail.rails = { "top" }
    self.parts.wpn_fps_smg_tec9_sightrail.stats = { concealment = 0, weight = 2 }
    self.wpn_fps_smg_tec9.adds = {}
    self.wpn_fps_smg_tec9.override = {}
    table.deletefrom(self.wpn_fps_smg_tec9.uses_parts, table.without(self.nqr.all_sights, self.nqr.all_light_reddots))
    table.deletefrom(self.wpn_fps_smg_tec9.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_tec9.uses_parts, self.nqr.all_bxs_mbp)
    table.insert(self.wpn_fps_smg_tec9.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_tec9.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_tec9.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_tec9.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_tec9.uses_parts, "wpn_fps_smg_tec9_sightrail")
    table.insert(self.wpn_fps_smg_tec9.uses_parts, "wpn_fps_addon_ris")

    self.parts.wpn_fps_smg_sr2_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6.9 }
    self.parts.wpn_fps_smg_sr2_body_lower.stats = { concealment = 0, weight = 0, length = 8 }
    self.parts.wpn_fps_smg_sr2_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_sr2_m_mag.stats = { concealment = 6, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_sr2_m_quick.stats = { concealment = 6, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_sr2_ns_silencer.stats = { concealment = 16, weight = 6, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_smg_sr2_o_rail.pcs = {}
    self.parts.wpn_fps_smg_sr2_o_rail.name_id = "bm_wp_sr2_sightrail"
    self.parts.wpn_fps_smg_sr2_o_rail.type = "extra"
    self.parts.wpn_fps_smg_sr2_o_rail.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_smg_sr2_o_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_sr2_s_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_sr2_s_unfolded.stats = { concealment = 0, weight = 0, length = 9, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_sr2_vg_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_smg_sr2.adds = {}
    table.deletefrom(self.wpn_fps_smg_sr2.uses_parts, self.nqr.all_vertical_grips)
    table.deletefrom(self.wpn_fps_smg_sr2.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_smg_sr2.uses_parts, self.nqr.all_big_reddots)
    table.deletefrom(self.wpn_fps_smg_sr2.uses_parts, self.nqr.all_bxs)
    table.insert(self.wpn_fps_smg_sr2.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_sr2.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_smg_sr2_o_rail")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_upg_o_cmore")
    table.insert(self.wpn_fps_smg_sr2.uses_parts, "wpn_fps_remove_s")

    self.parts.wpn_fps_smg_scorpion_gadgetrail = deep_clone(self.parts.wpn_fps_smg_scorpion_body_standard)
    self.parts.wpn_fps_smg_scorpion_gadgetrail.visibility = { { objects = { g_bolt_lod0 = false, g_body_lod0 = false } } }
    self.parts.wpn_fps_smg_scorpion_gadgetrail.name_id = "bm_wp_scorpion_gadgetrail"
    self.parts.wpn_fps_smg_scorpion_gadgetrail.pcs = {}
    self.parts.wpn_fps_smg_scorpion_gadgetrail.type = "extra3"
    self.parts.wpn_fps_smg_scorpion_gadgetrail.rails = { "bottom" }
    self.parts.wpn_fps_smg_scorpion_gadgetrail.adds = { "wpn_fps_smg_scorpion_extra_rail_gadget" }
    self.parts.wpn_fps_smg_scorpion_gadgetrail.override = { wpn_fps_extra2_lock_gadgets_and_vertical_grips = { frobids = {} } }
    self.parts.wpn_fps_smg_scorpion_gadgetrail.stats = { concealment = 3, weight = 2 }
    self.parts.wpn_fps_smg_scorpion_extra_rail_gadget.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_scorpion_body_standard.visibility = { { objects = { g_rail_lod0 = false } } }
    self.parts.wpn_fps_smg_scorpion_body_standard.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_smg_scorpion_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    --self.parts.wpn_fps_smg_scorpion_b_suppressed.a_obj = "a_ns"
    --self.parts.wpn_fps_smg_scorpion_b_suppressed.parent = "barrel"
    self.parts.wpn_fps_smg_scorpion_b_suppressed.stats = { concealment = 14, weight = 5, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_smg_scorpion_extra_rail.pcs = {}
    self.parts.wpn_fps_smg_scorpion_extra_rail.name_id = "bm_wp_scorpion_sightrail"
    self.parts.wpn_fps_smg_scorpion_extra_rail.override = { wpn_fps_extra_lock_sights = { frobids = {} } }
    self.parts.wpn_fps_smg_scorpion_extra_rail.type = "extra"
    self.parts.wpn_fps_smg_scorpion_extra_rail.rails = { "top" }
    self.parts.wpn_fps_smg_scorpion_extra_rail.stats = { concealment = 0, weight = 0 }
    local g_std_unit = self.parts.wpn_fps_smg_scorpion_g_standard.unit
    self.parts.wpn_fps_smg_scorpion_g_standard.unit = self.parts.wpn_fps_smg_scorpion_g_wood.unit
    self.parts.wpn_fps_smg_scorpion_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_scorpion_g_wood.unit = g_std_unit
    self.parts.wpn_fps_smg_scorpion_g_wood.name_id = "bm_wp_fal_g_01"
    self.parts.wpn_fps_smg_scorpion_g_wood.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_scorpion_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_scorpion_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_smg_scorpion_m_extended.pcs = nil
    self.parts.wpn_fps_smg_scorpion_m_extended.stats = { concealment = 7, weight = 3, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_smg_scorpion_s_nostock.name_id = "bm_wp_remove_s"
    self.parts.wpn_fps_smg_scorpion_s_nostock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_scorpion_s_standard.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_smg_scorpion_s_unfolded.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    self.wpn_fps_smg_scorpion.adds = {}
    self.wpn_fps_smg_scorpion.override = deep_clone(overrides_vertical_grip_and_gadget_thing)
    table.deletefrom(self.wpn_fps_smg_scorpion.uses_parts, self.nqr.all_sights)
    table.addto(self.wpn_fps_smg_scorpion.uses_parts, self.nqr.all_light_reddots)
    table.deletefrom(self.wpn_fps_smg_scorpion.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_scorpion.uses_parts, self.nqr.all_bxs_sbp)
    table.insert(self.wpn_fps_smg_scorpion.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_scorpion.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_scorpion.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_scorpion.uses_parts, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_scorpion.uses_parts, "wpn_fps_smg_scorpion_gadgetrail")
    self.parts.wpn_fps_smg_mp5_m_straight.pcs = {}
    table.insert(self.wpn_fps_smg_scorpion.uses_parts, "wpn_fps_smg_mp5_m_straight")

    self.wpn_fps_smg_pm9.sightheight_mod = -1.65
    self.parts.wpn_fps_smg_pm9_b_short.pcs = nil
    self.parts.wpn_fps_smg_pm9_b_short.stats = { concealment = 0, weight = 0, barrel_length = 4.7 }
    self.parts.wpn_fps_smg_pm9_b_standard.name_id = "bm_wp_pm9_ns_standard"
    self.parts.wpn_fps_smg_pm9_b_standard.pcs = {}
    self.parts.wpn_fps_smg_pm9_b_standard.type = "barrel_ext"
    self.parts.wpn_fps_smg_pm9_b_standard.stats = { concealment = 5, weight = 2, length = 4, md_code = {0,2,1,0,0}  }
    self.parts.wpn_fps_smg_pm9_body_standard.stats = { concealment = 0, weight = 0, length = 7 }
    self.parts.wpn_fps_smg_pm9_fl_adapter.pcs = {}
    self.parts.wpn_fps_smg_pm9_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_smg_pm9_fl_adapter.type = "extra3"
    self.parts.wpn_fps_smg_pm9_fl_adapter.override = { wpn_fps_extra3_lock_gadgets_and_vertical_grips = { forbids = {} } }
    self.parts.wpn_fps_smg_pm9_fl_adapter.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_smg_pm9_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_pm9_g_wood.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_pm9_m_quick.stats = { concealment = 5, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 25 }
    self.parts.wpn_fps_smg_pm9_m_standard.stats = { concealment = 5, weight = 1, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 25 }
    self.parts.wpn_fps_smg_pm9_o_adapter.pcs = {}
    self.parts.wpn_fps_smg_pm9_o_adapter.name_id = "bm_wp_pm9_sightrail"
    self.parts.wpn_fps_smg_pm9_o_adapter.override = { wpn_fps_extra_lock_sights = { forbids = {} } }
    self.parts.wpn_fps_smg_pm9_o_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_pm9_s_tactical.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.wpn_fps_smg_pm9.adds = {}
    self.wpn_fps_smg_pm9.override = deep_clone(overrides_vertical_grip_and_gadget_thing)
    table.deletefrom(self.wpn_fps_smg_pm9.uses_parts, self.nqr.all_sights)
    table.delete(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_smg_pm9_s_tactical")
    table.addto(self.wpn_fps_smg_pm9.uses_parts, self.nqr.all_light_reddots)
    table.deletefrom(self.wpn_fps_smg_pm9.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_pm9.uses_parts, table.combine(self.nqr.all_mds1, self.nqr.all_sps1, {"wpn_fps_snp_victor_ns_hera_supp","wpn_fps_upg_ak_ns_tgp"}))
    table.insert(self.wpn_fps_smg_pm9.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_pm9.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_extra3_lock_gadgets_and_vertical_grips")
    table.insert(self.wpn_fps_smg_pm9.default_blueprint, "wpn_fps_smg_pm9_b_short")
    table.insert(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_smg_pm9_o_adapter")
    table.insert(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_smg_pm9_fl_adapter")
    table.insert(self.wpn_fps_smg_pm9.uses_parts, "wpn_fps_remove_ns")

    self.parts.wpn_fps_smg_mp9_b_dummy.stats = { concealment = 0, weight = 0, barrel_length = 5.1 }
    self.parts.wpn_fps_smg_mp9_b_suppressed.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_smg_mp9_b_suppressed.stats = { concealment = 8, weight = 5, length = 8, md_code = {3,0,0,0,0} }
    self.parts.wpn_fps_smg_mp9_body_mp9.visibility = { { objects = { g_stubby_lod0 = false } } }
    self.parts.wpn_fps_smg_mp9_body_mp9.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_smg_mp9_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_smg_mp9_m_short.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 15 }
    self.parts.wpn_fps_smg_mp9_s_fold.stats = { concealment = 0, weight = 0, length = 9, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_mp9_s_skel.stats = { concealment = 0, weight = 0, shouldered = true }
    table.deletefrom(self.wpn_fps_smg_mp9.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_smg_mp9.uses_parts, self.nqr.all_big_reddots)
    table.deletefrom(self.wpn_fps_smg_mp9.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_mp9.uses_parts, self.nqr.all_bxs_bbp)
    table.delete(self.wpn_fps_smg_mp9.uses_parts, "wpn_fps_smg_mp9_s_skel")
    table.insert(self.wpn_fps_smg_mp9.default_blueprint, "wpn_fps_upg_vg_ass_smg_stubby")
    table.insert(self.wpn_fps_smg_mp9.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_smg_mp9.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_smg_mac10_b_dummy.stats = { concealment = 0, weight = 0, barrel_length = 5.1 }
    self.parts.wpn_fps_smg_mac10_body_mac10.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_mac10_body_modern.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_mac10_body_ris.rails = { "top", "side", "bottom" }
    self.parts.wpn_fps_smg_mac10_body_ris.stance_mod = nil
    self.parts.wpn_fps_smg_mac10_body_ris.adds = {}
    self.parts.wpn_fps_smg_mac10_body_ris.forbids = {}
    self.parts.wpn_fps_smg_mac10_body_ris.stats = { concealment = 0, weight = 0, length = 4, sightheight = 1.8 }
    self.parts.wpn_fps_smg_mac10_body_ris_special.pcs = {}
    self.parts.wpn_fps_smg_mac10_body_ris_special.rails = { "top" }
    self.parts.wpn_fps_smg_mac10_body_ris_special.stance_mod = nil
    self.parts.wpn_fps_smg_mac10_body_ris_special.stats = { concealment = 0, weight = 2, sightheight = 1.8 }
    self.parts.wpn_fps_smg_mac10_m_extended.stats = { concealment = 5, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_mac10_m_quick.stats = { concealment = 5, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_mac10_m_short.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 16 }
    self.parts.wpn_fps_smg_mac10_s_fold.stats = { concealment = 0, weight = 0, length = 10.01, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_smg_mac10_s_skel.pcs = nil
    self.parts.wpn_fps_smg_mac10_s_skel.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_smg_mac10.adds = {}
    self.wpn_fps_smg_mac10.override.wpn_fps_addon_ris = { override = { wpn_fps_extra_lock_gadgets = { forbids = deep_clone(self.nqr.all_vertical_grips) } } }
    table.addto(self.wpn_fps_smg_mac10.override.wpn_fps_addon_ris.override.wpn_fps_extra_lock_gadgets.forbids, self.nqr.all_pistol_gadgets)
    table.addto_dict(self.wpn_fps_smg_mac10.override, overrides_pistol_gadgets_to_vertical_grips_thing)
    table.deletefrom(self.wpn_fps_smg_mac10.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_smg_mac10.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_mac10.uses_parts, self.nqr.all_bxs_mbp)
    table.delete(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_smg_mac10_s_skel")
    table.insert(self.wpn_fps_smg_mac10.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_mac10.default_blueprint, 1, "wpn_fps_extra_lock_gadgets")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_extra_lock_gadgets")
    table.insert(self.wpn_fps_smg_mac10.default_blueprint, 1, "wpn_fps_extra_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_extra_lock_vertical_grips")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_smg_mac10_body_ris_special")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_mac10.uses_parts, "wpn_fps_smg_cobray_ns_barrelextension")
    table.addto(self.wpn_fps_smg_mac10.uses_parts, self.nqr.all_angled_sights)
    table.addto(self.wpn_fps_smg_mac10.uses_parts, self.nqr.all_pistol_gadgets)

    self.parts.wpn_fps_smg_cobray_barrel.stats = { concealment = 0, weight = 0, barrel_length = 5.5 }
    self.parts.wpn_fps_smg_cobray_body_lower.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_smg_cobray_body_lower_jacket.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_smg_cobray_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_cobray_body_upper_jacket.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_cobray_bolt.type = "bolt"
    self.parts.wpn_fps_smg_cobray_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_cobray_m_standard.stats = { concealment = 6, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 32 }
    self.parts.wpn_fps_smg_cobray_ns_barrelextension.has_description = true
    self.parts.wpn_fps_smg_cobray_ns_barrelextension.desc_id = "bm_wp_also_foregrip"
    self.parts.wpn_fps_smg_cobray_ns_barrelextension.stats = { concealment = 15, weight = 4, length = 7 }
    self.parts.wpn_fps_smg_cobray_ns_silencer.has_description = true
    self.parts.wpn_fps_smg_cobray_ns_silencer.desc_id = "bm_wp_also_foregrip"
    self.parts.wpn_fps_smg_cobray_ns_silencer.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_smg_cobray_o_adapter.pcs = {}
    self.parts.wpn_fps_smg_cobray_o_adapter.name_id = "bm_wp_cobray_sightrail"
    self.parts.wpn_fps_smg_cobray_o_adapter.type = "extra"
    self.parts.wpn_fps_smg_cobray_o_adapter.rails = { "top" }
    self.parts.wpn_fps_smg_cobray_o_adapter.stats = { concealment = 0, weight = 0, sightheight = 1 }
    self.parts.wpn_fps_smg_cobray_s_m4adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_smg_cobray_s_standard.stats = { concealment = 0, weight = 0, length = 9.010, shouldered = true }
    self.wpn_fps_smg_cobray.adds = {}
    table.deletefrom(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_m4_stocks)
    table.delete(self.wpn_fps_smg_cobray.uses_parts, "wpn_fps_smg_cobray_s_m4adapter")
    table.deletefrom(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_sights)
    table.addto(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_light_reddots)
    table.deletefrom(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_vertical_grips)
    table.deletefrom(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_smg_cobray.uses_parts, self.nqr.all_bxs_mbp)
    table.insert(self.wpn_fps_smg_cobray.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_cobray.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_smg_cobray.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_cobray.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_smg_cobray.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_smg_cobray.uses_parts, "wpn_fps_remove_s")



----SHOTGUN
    self.parts.wpn_fps_shot_r870_b_long.pcs = {}
    self.parts.wpn_fps_shot_r870_b_long.stats = { concealment = 0, weight = 0, barrel_length = 21, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_shot_r870_b_short.pcs = {}
    self.parts.wpn_fps_shot_r870_b_short.forbids = { "wpn_fps_shot_r870_s_nostock_big" }
    self.parts.wpn_fps_shot_r870_b_short.override = {
        wpn_fps_shot_r870_m_extended = {
            stats = table.copy_append(self.parts.wpn_fps_shot_r870_m_extended.stats, { overlength = { barrel = { 2, self.parts.wpn_fps_shot_r870_b_short.stats.barrel_length } } })
        }
    }
    self.parts.wpn_fps_shot_r870_b_short.stats = { concealment = 0, weight = 0, barrel_length = 9, CLIP_AMMO_MAX = 3 }
    self.parts.wpn_fps_shot_r870_b_legendary.stats = { concealment = 0, weight = 0, barrel_length = 14, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_shot_r870_body_rack.stats = { concealment = 0, weight = 1, totalammo = 6, }
    self.parts.wpn_fps_shot_r870_body_standard.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_shot_r870_fg_big.pcs = {}
    self.parts.wpn_fps_shot_r870_fg_big.forbids = { "wpn_fps_shot_r870_b_short" }
    self.parts.wpn_fps_shot_r870_fg_big.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_shot_r870_fg_railed.pcs = {}
    self.parts.wpn_fps_shot_r870_fg_railed.rails = { "bottom", "side" }
    self.parts.wpn_fps_shot_r870_fg_railed.override = {}
    for i, k in pairs(self.nqr.all_gadgets) do self.parts.wpn_fps_shot_r870_fg_railed.override[k] = { parent = "foregrip" } end --todo fl_pos
    self.parts.wpn_fps_shot_r870_fg_railed.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_shot_r870_fg_small.pcs = {}
    self.parts.wpn_fps_shot_r870_fg_small.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_shot_r870_fg_wood.forbids = { "wpn_fps_shot_r870_b_short" }
    self.parts.wpn_fps_shot_r870_fg_wood.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_shot_r870_fg_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_r870_gadget_rail.pcs = {} --todo wtf is this
    self.parts.wpn_fps_shot_r870_gadget_rail.name_id = "bm_wp_generic_gadgetrail"
    self.parts.wpn_fps_shot_r870_gadget_rail.type = "extra2"
    self.parts.wpn_fps_shot_r870_gadget_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_r870_m_extended.type = "magazine_ext"
    self.parts.wpn_fps_shot_r870_m_extended.forbids = {}
    table.addto(self.parts.wpn_fps_shot_r870_m_extended.forbids, self.nqr.all_bxs_magext)
    self.parts.wpn_fps_shot_r870_m_extended.stats = { concealment = 2, weight = 1, overlength = { barrel = { 2, self.parts.wpn_fps_shot_r870_b_long.stats.barrel_length } }, CLIP_AMMO_MAX = 1, } --todo parented a_m
    self.parts.wpn_fps_shot_r870_ris_special.pcs = {}
    self.parts.wpn_fps_shot_r870_ris_special.name_id = "bm_wp_r870_sightrail" --fix
    self.parts.wpn_fps_shot_r870_ris_special.rails = { "top" }
    self.parts.wpn_fps_shot_r870_ris_special.forbids = { "wpn_fps_shot_r870_s_folding" }
    self.parts.wpn_fps_shot_r870_ris_special.stats = { concealment = 0, weight = 2, sightheight = 1 }
    self.parts.wpn_fps_shot_r870_s_folding.forbids = nil
    self.parts.wpn_fps_shot_r870_s_folding.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_shot_r870_s_m4.pcs = {}
    self.parts.wpn_fps_shot_r870_s_m4.type = "stock"
    self.parts.wpn_fps_shot_r870_s_m4.rails = { "top" }
    self.parts.wpn_fps_shot_r870_s_m4.forbids = { "wpn_fps_shot_shorty_s_nostock_short", "wpn_fps_shot_r870_s_nostock_big", "wpn_fps_shot_r870_s_nostock_single" }
    self.parts.wpn_fps_shot_r870_s_m4.override = { wpn_fps_shot_r870_ris_special = { override = {} } }
    self.parts.wpn_fps_shot_r870_s_m4.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_shot_r870_s_nostock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_r870_s_nostock_big.type = "extra"
    self.parts.wpn_fps_shot_r870_s_nostock_big.rails = { "top" }
    self.parts.wpn_fps_shot_r870_s_nostock_big.forbids = { "wpn_fps_shot_r870_s_folding" }
    self.parts.wpn_fps_shot_r870_s_nostock_big.visibility = { { objects = { g_folding = false } } }
    self.parts.wpn_fps_shot_r870_s_nostock_big.stats = { concealment = 0, weight = 0, sightheight = 1 }
    self.parts.wpn_fps_shot_r870_s_nostock_single.pcs = {}
    self.parts.wpn_fps_shot_r870_s_nostock_single.type = "extra"
    self.parts.wpn_fps_shot_r870_s_nostock_single.rails = { "top" }
    self.parts.wpn_fps_shot_r870_s_nostock_single.forbids = { "wpn_fps_shot_r870_s_folding" }
    self.parts.wpn_fps_shot_r870_s_nostock_single.visibility = { { objects = { g_folding = false } } }
    self.parts.wpn_fps_shot_r870_s_nostock_single.stats = { concealment = 0, weight = 0, sightheight = 1 }
    self.parts.wpn_fps_shot_r870_s_solid.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    self.parts.wpn_fps_shot_r870_s_solid_big.pcs = nil
    self.parts.wpn_fps_shot_r870_s_solid_big.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    self.parts.wpn_fps_shot_r870_s_solid_single.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    self.parts.wpn_fps_shot_r870_s_legendary.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_shot_r870.adds = {}
    self.wpn_fps_shot_r870.override = {
        --wpn_fps_shot_r870_s_nostock_big = table.addto(self.parts.wpn_fps_shot_r870_s_nostock_big.forbids, { "wpn_fps_shot_r870_b_short" }),
        wpn_nqr_extra3_rail = { parent = "foregrip" },
        wpn_fps_addon_ris = { unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_gadget_rail" },
    }
    for i, k in pairs(self.nqr.all_vertical_grips) do self.wpn_fps_shot_r870.override[k] = { parent = "foregrip" } end --todo models properly
    table.addto_dict(self.wpn_fps_shot_r870.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_shot_r870.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_shot_r870.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_r870.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_r870.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_shot_r870_ris_special")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_shot_shorty_s_nostock_short")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_shot_r870_b_short")
    table.insert(self.wpn_fps_shot_r870.uses_parts, "wpn_fps_shot_r870_fg_small")
    table.addto(self.wpn_fps_shot_r870.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_shot_r870.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_shot_r870.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_shot_shorty_b_legendary.stats = { concealment = 0, weight = 0, barrel_length = 11, CLIP_AMMO_MAX = 4 }
    self.parts.wpn_fps_shot_shorty_fg_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_shorty_m_extended_short.unit = self.parts.wpn_fps_shot_r870_m_extended.unit
    self.parts.wpn_fps_shot_shorty_m_extended_short.type = "magazine_ext"
    self.parts.wpn_fps_shot_shorty_m_extended_short.stats = { concealment = 2, weight = 1, overlength = { barrel = { 2, self.parts.wpn_fps_shot_r870_b_short.stats.barrel_length } }, CLIP_AMMO_MAX = 1, }
    self.parts.wpn_fps_shot_shorty_s_nostock_short.type = "extra"
    self.parts.wpn_fps_shot_shorty_s_nostock_short.rails = { "top" }
    self.parts.wpn_fps_shot_shorty_s_nostock_short.forbids = { "wpn_fps_shot_r870_s_folding" }
    self.parts.wpn_fps_shot_shorty_s_nostock_short.visibility = { { objects = { g_folding = false } } }
    self.parts.wpn_fps_shot_shorty_s_nostock_short.stats = { concealment = 0, weight = 0, sightheight = 1 }
    self.parts.wpn_fps_shot_shorty_s_solid_short.pcs = nil
    self.parts.wpn_fps_shot_shorty_s_solid_short.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.parts.wpn_fps_shot_shorty_s_legendary.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_shot_serbu.adds = {}
    self.wpn_fps_shot_serbu.override = {
        wpn_fps_shot_r870_b_short = { forbids = table.addto(self.parts.wpn_fps_shot_r870_b_short.forbids, { "wpn_fps_shot_r870_fg_big", "wpn_fps_shot_r870_fg_wood" }) },
        wpn_fps_shot_r870_fg_wood = { forbids = {} },
        wpn_fps_shot_r870_fg_big = { forbids = {} },

        wpn_nqr_extra3_rail = { parent = "foregrip" },
    }
    table.addto_dict(self.wpn_fps_shot_serbu.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_shot_serbu.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_shot_serbu.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_serbu.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_serbu.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_shot_r870_b_long")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_shot_r870_fg_big")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_shot_r870_fg_wood")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_shot_r870_s_nostock_big")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_fps_shot_r870_ris_special")
    table.insert(self.wpn_fps_shot_serbu.uses_parts, "wpn_nqr_extra3_rail")
    table.addto(self.wpn_fps_shot_serbu.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_shot_serbu.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_shot_serbu.uses_parts, self.nqr.all_angled_sights)

    self.wpn_fps_sho_aa12.sightheight_mod = 3.1
    self.parts.wpn_fps_sho_aa12_barrel.stats = { concealment = 0, weight = 0, barrel_length = 13 }
    self.parts.wpn_fps_sho_aa12_barrel_long.stats = { concealment = 0, weight = 0, barrel_length = 18 }
    self.parts.wpn_fps_sho_aa12_barrel_silenced.type = "barrel_ext"
    self.parts.wpn_fps_sho_aa12_barrel_silenced.forbids = { "wpn_fps_sho_aa12_barrel_long" }
    self.parts.wpn_fps_sho_aa12_barrel_silenced.stats = { concealment = 22, weight = 16, length = 5, md_code = {5,0,0,0,0} }
    self.parts.wpn_fps_sho_aa12_body.stats = { concealment = 0, weight = 0, length = 18, shouldered = true }
    self.parts.wpn_fps_sho_aa12_body_rail.pcs = {}
    self.parts.wpn_fps_sho_aa12_body_rail.name_id = "bm_wp_aa12_sightrail"
    self.parts.wpn_fps_sho_aa12_body_rail.type = "ironsight"
    self.parts.wpn_fps_sho_aa12_body_rail.forbids = {}
    self.parts.wpn_fps_sho_aa12_body_rail.stats = { concealment = 7, weight = 4 }
    self.parts.wpn_fps_sho_aa12_body_rear_sight.type = "ironsight"
    self.parts.wpn_fps_sho_aa12_body_rear_sight.forbids = deep_clone(self.nqr.all_sights)
    self.parts.wpn_fps_sho_aa12_body_rear_sight.stats = { concealment = 0, weight = 0, sightheight = 3.1 }
    self.parts.wpn_fps_sho_aa12_bolt.type = "bolt"
    self.parts.wpn_fps_sho_aa12_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_aa12_dh.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_aa12_mag_drum.stats = { concealment = 38, weight = 10, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 20, retention = false }
    self.parts.wpn_fps_sho_aa12_mag_straight.stats = { concealment = 10, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = 8 }
    self.wpn_fps_sho_aa12.adds = {}
    table.addto_dict(self.wpn_fps_sho_aa12.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_sho_aa12.uses_parts, self.nqr.all_sights)
    table.insert(self.wpn_fps_sho_aa12.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_aa12.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_aa12.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_aa12.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_aa12.uses_parts, "wpn_fps_sho_aa12_body_rail")
    table.insert(self.wpn_fps_sho_aa12.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_sho_aa12.uses_parts, self.nqr.all_light_reddots)
    table.addto(self.wpn_fps_sho_aa12.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_basset_b_short.pcs = {}
	self.parts.wpn_fps_sho_basset_b_short.name = "bm_wp_basset_b_short"
    self.parts.wpn_fps_sho_basset_b_short.stats = { concealment = 0, weight = 0, barrel_length = 9.2 } --not_sure
    self.parts.wpn_fps_sho_basset_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.3 }
    self.parts.wpn_fps_sho_basset_body_standard.stats = { concealment = 0, weight = 0, length = 11, shouldered = true, cheek = 2 }
    self.parts.wpn_fps_sho_basset_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_basset_fg_short.override.wpn_fps_sho_basset_b_standard = nil
    self.parts.wpn_fps_sho_basset_fg_short.stats = { concealment = -16, weight = -4 }
    self.parts.wpn_fps_sho_basset_fg_standard.forbids = { "wpn_fps_sho_basset_b_short" }
    self.parts.wpn_fps_sho_basset_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_basset_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_basset_m_extended.stats = { concealment = 12, weight = 2, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = { ["12 gauge"] = 9, [".410 bore"] = 14 } }
    self.parts.wpn_fps_sho_basset_o_short.stats = {}
    self.parts.wpn_fps_sho_basset_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_sho_basset_o_standard.forbids, table.without(self.nqr.all_sights, table.combine(self.nqr.all_angled_sights, self.nqr.all_piggyback_sights, self.nqr.all_light_reddots)))
    self.parts.wpn_fps_sho_basset_o_standard.stats = { concealment = 2, weight = 0, sightheight = height_dflt-0.68 }
    table.addto_dict(self.wpn_fps_sho_basset.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_sho_basset.uses_parts, "wpn_nqr_saiga_m_drum")
    table.insert(self.wpn_fps_sho_basset.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_sho_basset.uses_parts, "wpn_fps_upg_cal_410")
    table.addto(self.wpn_fps_sho_basset.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_ben_b_short.stats = { concealment = 0, weight = 0, barrel_length = 14, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_sho_ben_b_long.unit = "units/pd2_dlc_gage_shot/weapons/wpn_fps_sho_ben_pts/wpn_fps_sho_ben_b_standard"
    self.parts.wpn_fps_sho_ben_b_long.name_id = self.parts.wpn_fps_m4_uupg_b_medium.name_id
    self.parts.wpn_fps_sho_ben_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16.5, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_sho_ben_b_standard.unit = "units/pd2_dlc_gage_shot/weapons/wpn_fps_sho_ben_pts/wpn_fps_sho_ben_b_long"
    self.parts.wpn_fps_sho_ben_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.5, CLIP_AMMO_MAX = 7 }
    self.parts.wpn_fps_sho_ben_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_sho_ben_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ben_s_collapsable.stats = { concealment = 0, weight = 0, length = 11, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_sho_ben_s_collapsed.stats = { concealment = 0, weight = 0, length = 6, shoulderable = true }
    self.parts.wpn_fps_sho_ben_s_solid.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    table.addto_dict(self.wpn_fps_sho_ben.override, overrides_shotgun_sps_sound)
    --table.swap(self.wpn_fps_sho_ben.default_blueprint, "wpn_fps_sho_ben_b_standard", "wpn_fps_sho_ben_b_long")
    table.insert(self.wpn_fps_sho_ben.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_ben.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_ben.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ben.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ben.uses_parts, "wpn_fps_addon_ris")
    table.addto(self.wpn_fps_sho_ben.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_boot_b_legendary.stats = { concealment = 0, weight = 0, barrel_length = 11, length = 3 }
    self.parts.wpn_fps_sho_boot_b_long.stats = { concealment = 0, weight = 0, barrel_length = 22, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_sho_boot_b_short.stats = { concealment = 0, weight = 0, barrel_length = 11, CLIP_AMMO_MAX = 4 } --roughly
    self.parts.wpn_fps_sho_boot_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.5, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_sho_boot_body_exotic.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_sho_boot_body_standard.stats = { concealment = 0, weight = 0, length = 9 }
    self.parts.wpn_fps_sho_boot_em_extra.type = "casing"
    self.parts.wpn_fps_sho_boot_em_extra.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_fg_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_o_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_s_legendary.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_sho_boot_s_long.stats = { concealment = 0, weight = 0, length = 9, shouldered = true }
    self.parts.wpn_fps_sho_boot_s_short.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_boot_o_adapter = {
        texture_bundle_folder = "wild",
		dlc = "wild",
		a_obj = "a_rds",
		type = "extra",
		name_id = "bm_wp_boot_o_adapter",
		unit = "units/pd2_dlc_wild/weapons/wpn_fps_sho_boot_pts/wpn_fps_sho_boot_o_adapter",
        pcs = {},
        forbids = deep_clone(self.nqr.all_sights),
		stats = { concealment = 0, weight = 1, sightheight = 0.2 } --sightheight = 0.37
	}
    self.wpn_fps_sho_boot.override = {
        wpn_fps_ak_extra_ris = { a_obj = "a_o",
            override = { wpn_fps_sho_boot_o_adapter = { forbids = {} }, wpn_fps_extra4_lock_sights = { forbids = {} } },
            stats = table.copy_append(self.parts.wpn_fps_ak_extra_ris.stats, { sightheight = 0.17 }),
        },
    }
    for i, k in pairs(self.nqr.all_pistol_reddots) do
        self.wpn_fps_sho_boot.override[k] = {
            depends_on = "extra", forbids = { "wpn_fps_ak_extra_ris" }, stats = table.without(self.parts[k].stats, {"use_stance_mod"}),
        }
    end
    table.addto_dict(self.wpn_fps_sho_boot.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_sho_boot.default_blueprint, 1, "wpn_fps_extra_lock_sights_boot")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_extra_lock_sights_boot")
    table.insert(self.wpn_fps_sho_boot.default_blueprint, 1, "wpn_fps_extra4_lock_sights")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_extra4_lock_sights")
    table.insert(self.wpn_fps_sho_boot.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_sho_boot_o_adapter")
    table.insert(self.wpn_fps_sho_boot.uses_parts, "wpn_fps_ak_extra_ris")
    table.addto(self.wpn_fps_sho_boot.uses_parts, self.nqr.all_light_reddots)
    table.addto(self.wpn_fps_sho_boot.uses_parts, self.nqr.all_pistol_reddots)

    self.parts.wpn_fps_sho_coach_b_short.stats = { concealment = 0, weight = -6, barrel_length = 8 } --roughly
    self.parts.wpn_fps_sho_coach_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16 } --roughy
    self.parts.wpn_fps_sho_coach_barrel_lock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_right_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_left_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_right_slug.type = "magazine"
    self.parts.wpn_fps_sho_coach_right_slug.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_left_slug.type = "magazine2"
    self.parts.wpn_fps_sho_coach_left_slug.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_coach_s_long.stats = { concealment = 0, weight = 0, length = 15, shouldered = true }
    self.parts.wpn_fps_sho_coach_s_short.stats = { concealment = 0, weight = 0, length = 6 }

    self.parts.wpn_fps_sho_b_spas12_short_dummy = deep_clone(self.parts.wpn_fps_sho_b_spas12_short)
    self.parts.wpn_fps_sho_b_spas12_short_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_sho_b_spas12_short_dummy.stats = {}
    self.parts.wpn_fps_sho_b_spas12_short.adds = { "wpn_fps_sho_b_spas12_short_dummy" }
    self.parts.wpn_fps_sho_b_spas12_short.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_sho_b_spas12_short.stats = { concealment = 0, weight = 0, barrel_length = 21.5 }
    self.parts.wpn_fps_sho_b_spas12_long_dummy = deep_clone(self.parts.wpn_fps_sho_b_spas12_long)
    self.parts.wpn_fps_sho_b_spas12_long_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_sho_b_spas12_long_dummy.stats = {}
    self.parts.wpn_fps_sho_b_spas12_long.unit = fantom_unit
    self.parts.wpn_fps_sho_b_spas12_long.type = "magazine"
    self.parts.wpn_fps_sho_b_spas12_long.override = { wpn_fps_sho_b_spas12_short = { adds = { "wpn_fps_sho_b_spas12_long_dummy" } } }
    self.parts.wpn_fps_sho_b_spas12_long.stats = { concealment = 0, weight = 2, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_sho_fg_spas12_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_s_spas12_folded.stats = { concealment = 0, weight = 0, shoulderable = true }
    self.parts.wpn_fps_sho_s_spas12_nostock.name_id = "bm_wp_remove_s"
    self.parts.wpn_fps_sho_s_spas12_nostock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_s_spas12_solid.stats = { concealment = 0, weight = 0, length = 10, shouldered = true }
    self.parts.wpn_fps_sho_s_spas12_unfolded.stats = { concealment = 0, weight = 0, length = 10, shouldered = true, shoulderable = true }
    --self.parts.wpn_fps_sho_body_spas12_standard.animations = { fire = "recoil", reload = "reload", fire_steelsight = "recoil" }
    self.parts.wpn_fps_sho_body_spas12_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_sho_spas12_rail = {
        name_id = "bm_wp_sho_spas12_rail",
		unit = "units/payday2/weapons/wpn_fps_shot_r870_pts/wpn_fps_shot_r870_ris_special",
		a_obj = "a_o",
		type = "extra",
        pcs = {},
        rails = { "top" },
        adds = {}, stats = {},
        forbids = { "wpn_fps_sho_s_spas12_folded" },
        override = { wpn_fps_sho_s_spas12_unfolded = { stats = { concealment = 0, weight = 0, shouldered = true } } },
        stats = { concealment = 4, weight = 2, sightpos = {-0.2, 0, 0} },
	}
    self.wpn_fps_sho_spas12.adds = {}
    table.addto_dict(self.wpn_fps_sho_spas12.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_sho_spas12.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_sho_spas12.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_sho_spas12.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_spas12.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_spas12.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_spas12.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_spas12.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_spas12.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_spas12.uses_parts, "wpn_fps_sho_spas12_rail")
    table.insert(self.wpn_fps_sho_spas12.uses_parts, "wpn_fps_addon_ris") --todo
    table.addto(self.wpn_fps_sho_spas12.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_ksg_b_long.adds = {}
    self.parts.wpn_fps_sho_ksg_b_long.forbids = { "wpn_fps_sight_pos_a_o_f_short" }
    self.parts.wpn_fps_sho_ksg_b_long.stats = { concealment = 0, weight = 0, barrel_length = 22, CLIP_AMMO_MAX = 20 } --roughly
    self.parts.wpn_fps_sho_ksg_b_short.adds = {}
    self.parts.wpn_fps_sho_ksg_b_short.forbids = { "wpn_fps_sight_pos_a_o_f_2", "wpn_fps_sight_pos_a_o_f" }
    self.parts.wpn_fps_sho_ksg_b_short.stats = { concealment = 0, weight = 0, barrel_length = 15, CLIP_AMMO_MAX = 8 } --roughly
    self.parts.wpn_fps_sho_ksg_b_standard.adds = {}
    self.parts.wpn_fps_sho_ksg_b_standard.forbids = { "wpn_fps_sight_pos_a_o_f_short" }
    self.parts.wpn_fps_sho_ksg_b_standard.override.wpn_fps_upg_o_mbus_front = { a_obj = "a_o_f_2" }
    self.parts.wpn_fps_sho_ksg_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.5, CLIP_AMMO_MAX = 14 }
    self.parts.wpn_fps_sho_ksg_b_legendary.stats = { concealment = 0, weight = 0, barrel_length = 22, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_sho_ksg_body_standard.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_sho_ksg_fg_short.pcs = {}
    self.parts.wpn_fps_sho_ksg_fg_short.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ksg_fg_standard.forbids = { "wpn_fps_sho_ksg_b_short" }
    self.parts.wpn_fps_sho_ksg_fg_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_sho_ksg.override = {
        wpn_fps_gadgets_pos_a_fl2 = { override = { wpn_fps_extra2_lock_gadgets = { forbids = {} } } }
    }
    for i, k in pairs(self.nqr.all_gadgets) do
        self.wpn_fps_sho_ksg.override.wpn_fps_gadgets_pos_a_fl2.override[k] = { a_obj = "a_fl_2", forbids = { "wpn_fps_pis_c96_sight" } }
    end
    table.addto_dict(self.wpn_fps_sho_ksg.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_sho_ksg.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_ksg.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ksg.default_blueprint, "wpn_fps_sight_pos_default")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sight_pos_default")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sight_pos_a_o_f")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sight_pos_a_o_f_short")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sight_pos_a_o_f_2")
    --table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_gadgets_pos_a_fl_2")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_gadgets_pos_a_fl2")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sho_ksg_fg_standard")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_sho_ksg_fg_short")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_ksg.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_sho_ksg.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_m590_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.5, CLIP_AMMO_MAX = 6 } --not_sure
    self.parts.wpn_fps_sho_m590_b_long.type = "exclusive_set"
    self.parts.wpn_fps_sho_m590_b_long.forbids = {}
    table.addto(self.parts.wpn_fps_sho_m590_b_long.forbids, self.nqr.all_bxs_bbr)
    --self.parts.wpn_fps_sho_m590_b_long.visibility = { { objects = { g_b = false, g_bits = true, g_mag = false } } } --todo
    --self.parts.wpn_fps_sho_m590_b_long.stats = { concealment = 0, weight = 0, barrel_length = 20, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_sho_m590_b_long.stats = { concealment = 4, weight = 2, length = 2, CLIP_AMMO_MAX = 2, md_code = {0,1,1,0,0}, md_bulk = {0,1} }
    self.parts.wpn_fps_sho_m590_b_suppressor.type = "barrel_ext"
    self.parts.wpn_fps_sho_m590_b_suppressor.override = { stats = table.copy_append(self.parts.wpn_fps_sho_m590_b_long.stats, {length = 0}) }
    --self.parts.wpn_fps_sho_m590_b_suppressor.stats = { concealment = 0, weight = 0, barrel_length = 18.5, length = 8 } --not_sure
    self.parts.wpn_fps_sho_m590_b_suppressor.stats = { concealment = 0, weight = 8, length = 8 }
    self.parts.wpn_fps_sho_m590_body_rail.type = "extra"
    self.parts.wpn_fps_sho_m590_body_rail.rails = { "top", "side" }
    self.parts.wpn_fps_sho_m590_body_rail.adds = {}
    self.parts.wpn_fps_sho_m590_body_rail.forbids = {}
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.parts.wpn_fps_sho_m590_body_rail.override[k] = { a_obj = "a_of" } end end
    self.parts.wpn_fps_sho_m590_body_rail.visibility = { { objects = { g_slug = false, g_body = false, g_bolt = false, g_hatch = false } } }
    self.parts.wpn_fps_sho_m590_body_rail.stats = { concealment = 0, weight = 4, sightheight = 0.82 }
    self.parts.wpn_fps_sho_m590_ris_special = deep_clone(self.parts.wpn_fps_shot_r870_ris_special)
    self.parts.wpn_fps_sho_m590_ris_special.name_id = "bm_wp_m590_sightrail"
    self.parts.wpn_fps_sho_m590_ris_special.dlc = "fawp"
    --self.parts.wpn_fps_sho_m590_ris_special.a_obj = "a_of"
    self.parts.wpn_fps_sho_m590_ris_special.rails = { "top" }
    for i, k in pairs(self.nqr.all_sights) do if not self.parts[k].parent then self.parts.wpn_fps_sho_m590_body_rail.override[k] = { a_obj = "a_of" } end end
    self.parts.wpn_fps_sho_m590_ris_special.stats.sightheight = nil
    self.parts.wpn_fps_sho_m590_ris_special.stats.sightpos = {-0.25, -0.82, 0}
    self.parts.wpn_fps_sho_m590_body_standard.stats = { concealment = 0, weight = 0, length = 18 }
    self.parts.wpn_fps_sho_m590_fg_standard.stats = { concealment = 0, weight = 0 }
    --self.parts.wpn_fps_sho_m590_g_standard.pcs = {}
    self.parts.wpn_fps_sho_m590_g_standard.texture_bundle_folder = "fawp"
    self.parts.wpn_fps_sho_m590_g_standard.dlc = "fawp"
    self.parts.wpn_fps_sho_m590_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_m590_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_sho_m590.adds = {}
    table.addto_dict(self.wpn_fps_sho_m590.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_sho_m590.uses_parts, self.nqr.all_snoptics)
    table.swap(self.wpn_fps_sho_m590.default_blueprint, "wpn_fps_sho_m590_g_standard", "wpn_fps_upg_m4_g_standard")
    table.insert(self.wpn_fps_sho_m590.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_m590.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_m590.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_sho_m590_ris_special")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_m590.uses_parts, "wpn_fps_shot_r870_body_rack")
    --table.addto(self.wpn_fps_sho_m590.uses_parts, self.nqr.all_tube_stocks) --todo
    table.addto(self.wpn_fps_sho_m590.uses_parts, self.nqr.all_m4_grips)
    table.addto(self.wpn_fps_sho_m590.uses_parts, self.nqr.all_second_sights)

    self.parts.wpn_fps_sho_rota_b_long.stats = { concealment = 0, weight = 0, barrel_length = 22 }
    self.parts.wpn_fps_sho_rota_b_short.stats = { concealment = 0, weight = 0, barrel_length = 18 }
    self.parts.wpn_fps_sho_rota_b_salvo = deep_clone(self.parts.wpn_fps_sho_rota_b_silencer)
    self.parts.wpn_fps_sho_rota_b_salvo.name_id = "bm_wp_rota_b_salvo"
    self.parts.wpn_fps_sho_rota_b_salvo.unit = self.parts.wpn_fps_upg_ns_sho_salvo_large.unit
    table.addto(self.parts.wpn_fps_sho_rota_b_salvo.forbids, {"wpn_fps_upg_ns_sho_salvo_small", "wpn_fps_sho_ultima_ns_comp"})
    table.addto(self.parts.wpn_fps_sho_rota_b_salvo.forbids, table.without(self.nqr.all_vertical_grips, {"wpn_fps_smg_hajk_vg_moe"}))
    self.parts.wpn_fps_sho_rota_b_salvo.override = { wpn_fps_smg_hajk_vg_moe = { unit = fantom_unit, stats = { concealment = 0, weight = 0 } } }
    self.parts.wpn_fps_sho_rota_b_salvo.sound_switch.suppressed = "suppressed_c"
    self.parts.wpn_fps_sho_rota_b_salvo.stats = { concealment = 0, weight = 0, barrel_length = 12.5, length = 8, md_code = self.parts.wpn_fps_upg_ns_sho_salvo_large.stats.md_code }
    self.parts.wpn_fps_sho_rota_b_silencer.stats = { concealment = 0, weight = 0, barrel_length = 12.5 }
    self.parts.wpn_fps_sho_rota_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_rota_body_upper.stats = { concealment = 0, weight = 0, length = 4, shouldered = true }
    self.parts.wpn_fps_sho_rota_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_rota_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_rota_m_standard.stats = { concealment = 9, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_sho_rota_mag_realese.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_rota_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_sho_rota_o_standard.forbids, table.without(self.nqr.all_sights, table.combine(self.nqr.all_angled_sights, self.nqr.all_piggyback_sights, self.nqr.all_light_reddots)))
    self.parts.wpn_fps_sho_rota_o_standard.stats = { concealment = 2, weight = 0 }
    table.addto_dict(self.wpn_fps_sho_rota.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_sho_rota.uses_parts, "wpn_fps_sho_rota_b_salvo")
    table.insert(self.wpn_fps_sho_rota.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_rota.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_rota.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_rota.uses_parts, "wpn_fps_remove_ironsight")
    table.addto(self.wpn_fps_sho_rota.uses_parts, self.nqr.all_angled_sights)

    local saiga_foregrips_full = {
        "wpn_upg_saiga_fg_standard",
        "wpn_fps_sho_saiga_fg_holy",
    }
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_saiga_fg_standard")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_saiga_fg_lowerrail")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_upg_saiga_fg_lowerrail_short")
    table.insert(self.wpn_fps_ass_74.uses_parts, "wpn_fps_sho_saiga_fg_holy")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_upg_saiga_fg_standard")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_upg_saiga_fg_lowerrail")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_upg_saiga_fg_lowerrail_short")
    table.insert(self.wpn_fps_ass_akm.uses_parts, "wpn_fps_sho_saiga_fg_holy")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_upg_saiga_fg_standard")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_upg_saiga_fg_lowerrail")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_upg_saiga_fg_lowerrail_short")
    table.insert(self.wpn_fps_ass_akm_gold.uses_parts, "wpn_fps_sho_saiga_fg_holy")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_saiga_fg_standard")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_saiga_fg_lowerrail")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_upg_saiga_fg_lowerrail_short")
    table.insert(self.wpn_fps_lmg_rpk.uses_parts, "wpn_fps_sho_saiga_fg_holy")
    self.parts.wpn_fps_sho_saiga_b_short.rails = { "top" }
    self.parts.wpn_fps_sho_saiga_b_short.sub_type = "ironsight"
	self.parts.wpn_fps_sho_saiga_b_short.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_fps_sho_saiga_b_short.stats = { concealment = 0, weight = 0, barrel_length = 9.2 }
    self.parts.wpn_fps_shot_saiga_b_standard.rails = { "top" }
    self.parts.wpn_fps_shot_saiga_b_standard.sub_type = "ironsight"
	self.parts.wpn_fps_shot_saiga_b_standard.override = { wpn_fps_o_pos_fg = { adds = {} } }
    self.parts.wpn_fps_shot_saiga_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16.9 }
    self.parts.wpn_upg_saiga_fg_standard.pcs = {}
    self.parts.wpn_upg_saiga_fg_standard.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_upg_saiga_fg_standard.override = {}
    self.parts.wpn_upg_saiga_fg_standard.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_upg_saiga_fg_lowerrail.rails = { "side", "bottom" }
    self.parts.wpn_upg_saiga_fg_lowerrail.forbids = { "wpn_fps_sho_saiga_b_short" }
    self.parts.wpn_upg_saiga_fg_lowerrail.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_upg_saiga_fg_lowerrail_short = deep_clone(self.parts.wpn_upg_saiga_fg_lowerrail)
    self.parts.wpn_upg_saiga_fg_lowerrail_short.unit = "units/payday2/weapons/wpn_fps_upg_ak_reusable/wpn_upg_ak_fg_combo3_slavic"
    self.parts.wpn_upg_saiga_fg_lowerrail_short.name_id = "bm_wp_saiga_fg_lowerrail_short"
    self.parts.wpn_upg_saiga_fg_lowerrail_short.forbids = {}
    self.parts.wpn_upg_saiga_fg_lowerrail_short.visibility = { { objects = { g_upperrail_lod0 = false } } }
    self.parts.wpn_upg_saiga_fg_lowerrail_short.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_sho_saiga_fg_holy.forbids = { "wpn_fps_ak_extra_ris" }
    self.parts.wpn_fps_sho_saiga_fg_holy.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_upg_saiga_fg_octa = deep_clone(self.parts.wpn_upg_saiga_fg_standard)
    self.parts.wpn_upg_saiga_fg_octa.unit = self.parts.wpn_fps_snp_victor_fg_standard.unit
    self.parts.wpn_upg_saiga_fg_octa.name_id = "bm_wp_saiga_fg_octa"
    self.parts.wpn_upg_saiga_fg_octa.forbids = { "wpn_fps_ak_extra_ris", "wpn_fps_sho_saiga_b_short" }
    self.parts.wpn_upg_saiga_fg_octa.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_shot_saiga_m_5rnd.stats = { concealment = 7, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["12 gauge"] = 5, [".410 bore"] = 8 } }
    self.parts.wpn_nqr_saiga_m_drum = deep_clone(self.parts.wpn_fps_shot_saiga_m_5rnd)
    self.parts.wpn_nqr_saiga_m_drum.name_id = "bm_wp_saiga_m_drum"
    self.parts.wpn_nqr_saiga_m_drum.unit = "units/payday2/weapons/wpn_fps_shot_saiga_pts/wpn_upg_saiga_m_20rnd"
    self.parts.wpn_nqr_saiga_m_drum.pcs = {}
    self.parts.wpn_nqr_saiga_m_drum.animations = nil
    self.parts.wpn_nqr_saiga_m_drum.stats = { concealment = 28, weight = 10, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["12 gauge"] = 12, [".410 bore"] = 18 } }
    self.wpn_fps_shot_saiga.adds = {}
    self.wpn_fps_shot_saiga.animations.reload = nil
    self.wpn_fps_shot_saiga.animations.reload_not_empty = nil
    table.addto_dict(self.wpn_fps_shot_saiga.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_shot_saiga.uses_parts, self.nqr.all_snoptics)
    table.delete(self.wpn_fps_shot_saiga.default_blueprint, "wpn_upg_o_marksmansight_rear")
    table.delete(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_upg_ak_body_upperreceiver_zenitco")
    table.delete(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_akm_body_upperreceiver")
    table.swap(self.wpn_fps_shot_saiga.default_blueprint, "wpn_fps_ass_akm_body_upperreceiver", "wpn_fps_ass_74_body_upperreceiver")
    table.insert(self.wpn_fps_shot_saiga.default_blueprint, 1, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_o_pos_fg")
    table.insert(self.wpn_fps_shot_saiga.default_blueprint, 1, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_foregrip_lock_gadgets")
    table.insert(self.wpn_fps_shot_saiga.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_o_pos_a_o_sm")
    --table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_sight_pos_a_of")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_upg_saiga_fg_lowerrail_short")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_upg_saiga_fg_octa")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_nqr_saiga_m_drum")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_nqr_extra3_rail")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_upg_ak_s_adapter")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_remove_upper")
    table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_upg_cal_410")
    --table.insert(self.wpn_fps_shot_saiga.uses_parts, "wpn_fps_ass_galil_s_standard")
    table.addto(self.wpn_fps_shot_saiga.uses_parts, self.nqr.all_second_sights)
    table.addto(self.wpn_fps_shot_saiga.uses_parts, self.nqr.all_tube_stocks)

    self.parts.wpn_fps_sho_sko12_b_long.stats = { concealment = 0, weight = 0, barrel_length = 21 } --roughly
    self.parts.wpn_fps_sho_sko12_b_short.stats = { concealment = 0, weight = 0, barrel_length = 14.7 }
    self.parts.wpn_fps_sho_sko12_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.9 }
    self.parts.wpn_fps_sho_sko12_body_grip.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_body_lower.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_sho_sko12_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_drag_handle.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_fg_railed.unit = fantom_unit
    self.parts.wpn_fps_sho_sko12_fg_railed.type = "extra2"
    self.parts.wpn_fps_sho_sko12_fg_railed.rails = { "side", "bottom" }
    self.parts.wpn_fps_sho_sko12_fg_railed.visibility = { { objects = { g_fg_rail = false } } }
    self.parts.wpn_fps_sho_sko12_fg_railed.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_sho_sko12_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_m_stick.pcs = {}
    self.parts.wpn_fps_sho_sko12_m_stick.name_id = "bm_wp_sko12_m_stick"
    self.parts.wpn_fps_sho_sko12_m_stick.stats = { concealment = 16, weight = 3, mag_amount = { 2, 3, 4 }, CLIP_AMMO_MAX = { ["12 gauge"] = 9, ["7.62x51"] = 0 } }
    self.parts.wpn_fps_sho_sko12_m_drum.pcs = {}
    self.parts.wpn_fps_sho_sko12_m_drum.stats = { concealment = 54, weight = 8, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = { ["12 gauge"] = 25, ["7.62x51"] = 0 }, retention = false }
    self.parts.wpn_fps_sho_sko12_ns_default.pcs = {}
    self.parts.wpn_fps_sho_sko12_ns_default.dlc = "pxp2"
    self.parts.wpn_fps_sho_sko12_ns_default.texture_bundle_folder = "pxp2"
    self.parts.wpn_fps_sho_sko12_ns_default.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,1,0,1,0} }
    self.parts.wpn_fps_sho_sko12_ns_stiletto.unit = "units/pd2_dlc_pxp2/weapons/wpn_fps_sho_sko12_pts/wpn_fps_sho_sko12_ns_stiletto_conversion"
    self.parts.wpn_fps_sho_sko12_ns_stiletto.name_id = "bm_wp_sko12_ns_stiletto"
    self.parts.wpn_fps_sho_sko12_ns_stiletto.pcs = {}
    self.parts.wpn_fps_sho_sko12_ns_stiletto.is_a_unlockable = true
    self.parts.wpn_fps_sho_sko12_ns_stiletto.dlc = "pxp2"
    self.parts.wpn_fps_sho_sko12_ns_stiletto.texture_bundle_folder = "pxp2"
    self.parts.wpn_fps_sho_sko12_ns_stiletto.stats = { concealment = 1, weight = 1, length = 1, md_code = {0,1,0,1,0} }
    self.parts.wpn_fps_sho_sko12_s_adapter.pcs = {}
    self.parts.wpn_fps_sho_sko12_s_adapter.type = "stock"
    self.parts.wpn_fps_sho_sko12_s_adapter.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_sho_sko12_s_adapter_short.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_sko12_stock.type = "stock_addon"
    self.parts.wpn_fps_sho_sko12_stock.adds_type = nil
    self.parts.wpn_fps_sho_sko12_stock.stats = { concealment = 11, weight = 3, length = 7, shouldered = true }
    self.parts.wpn_fps_sho_sko12_stock_conversion.stats = { concealment = 0, weight = 0, shouldered = true }
    self.wpn_fps_sho_sko12.override.wpn_fps_remove_s = { unit = self.parts.wpn_fps_sho_sko12_s_adapter_short.unit }
    table.addto_dict(self.wpn_fps_sho_sko12.override, overrides_shotgun_sps_sound)
    table.delete(self.wpn_fps_sho_sko12.default_blueprint, "wpn_upg_o_marksmansight_rear")
    table.delete(self.wpn_fps_sho_sko12.uses_parts, "wpn_upg_o_marksmansight_rear")
    table.swap(self.wpn_fps_sho_sko12.default_blueprint, "wpn_fps_upg_m4_g_standard", "wpn_fps_sho_sko12_body_grip")
    table.swap(self.wpn_fps_sho_sko12.default_blueprint, "wpn_fps_upg_m4_s_standard", "wpn_fps_sho_sko12_stock")
    table.insert(self.wpn_fps_sho_sko12.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_sko12.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_sko12.default_blueprint, "wpn_fps_sho_sko12_s_adapter")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_sho_sko12_s_adapter")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_sho_sko12_m_stick")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_remove_ns")
    table.insert(self.wpn_fps_sho_sko12.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_sho_sko12.uses_parts, self.nqr.all_angled_sights)
    table.addto(self.wpn_fps_sho_sko12.uses_parts, self.nqr.all_tube_stocks)
    table.addto(self.wpn_fps_sho_sko12.uses_parts, self.nqr.all_m4_grips)

    self.wpn_fps_sho_striker.sightheight_mod = 2
    self.parts.wpn_fps_sho_striker_rail = deep_clone(self.parts.wpn_fps_sho_striker_body_standard)
    self.parts.wpn_fps_sho_striker_rail.pcs = {}
    self.parts.wpn_fps_sho_striker_rail.name_id = "bm_wp_striker_rail"
    self.parts.wpn_fps_sho_striker_rail.type = "extra"
    self.parts.wpn_fps_sho_striker_rail.rails = { "top", "side" }
    self.parts.wpn_fps_sho_striker_rail.visibility = { { objects = { g_sling = false, g_switch = false, g_body = false } } }
    self.parts.wpn_fps_sho_striker_rail.animations = nil
    self.parts.wpn_fps_sho_striker_rail.stats = { concealment = 0, weight = 4, sightheight = self.wpn_fps_sho_striker.sightheight_mod }
    self.parts.wpn_fps_sho_striker_sling = deep_clone(self.parts.wpn_fps_sho_striker_body_standard)
    self.parts.wpn_fps_sho_striker_sling.name_id = "bm_wp_striker_sling"
    self.parts.wpn_fps_sho_striker_sling.type = "wep_cos"
    self.parts.wpn_fps_sho_striker_sling.visibility = { { objects = { g_body = false, g_switch = false, g_rail = false } } }
    self.parts.wpn_fps_sho_striker_sling.animations = nil
    self.parts.wpn_fps_sho_striker_sling.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_sho_striker_body_standard.visibility = { { objects = { g_sling = false, g_rail = false } } }
    self.parts.wpn_fps_sho_striker_body_standard.stats = { concealment = 0, weight = 0, length = 9, CLIP_AMMO_MAX = 12 }
    self.parts.wpn_fps_sho_striker_b_long.stats = { concealment = 0, weight = 0, barrel_length = 18.5 }
    self.parts.wpn_fps_sho_striker_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 12 }
    --self.parts.wpn_fps_sho_striker_b_suppressed.a_obj = "a_ns"
    --self.parts.wpn_fps_sho_striker_b_suppressed.type = "barrel_ext"
    --self.parts.wpn_fps_sho_striker_b_suppressed.parent = "barrel"
    self.parts.wpn_fps_sho_striker_b_suppressed.stats = { concealment = 14, weight = 5, barrel_length = 12, length = 7, md_code = {3,0,0,0,0} } --todo
    table.addto_dict(self.wpn_fps_sho_striker.override, overrides_shotgun_sps_sound)
    table.deletefrom(self.wpn_fps_sho_striker.uses_parts, self.nqr.all_optics)
    table.delete(self.wpn_fps_sho_striker.default_blueprint, "wpn_upg_o_marksmansight_rear")
    table.delete(self.wpn_fps_sho_striker.uses_parts, "wpn_upg_o_marksmansight_rear")
    table.insert(self.wpn_fps_sho_striker.default_blueprint, "wpn_fps_sho_striker_sling")
    table.insert(self.wpn_fps_sho_striker.uses_parts, "wpn_fps_sho_striker_sling")
    table.insert(self.wpn_fps_sho_striker.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_striker.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_sho_striker.default_blueprint, 1, "wpn_fps_extra_lock_gadgets")
    table.insert(self.wpn_fps_sho_striker.uses_parts, "wpn_fps_extra_lock_gadgets")
    table.insert(self.wpn_fps_sho_striker.uses_parts, "wpn_fps_sho_striker_rail")
    table.insert(self.wpn_fps_sho_striker.uses_parts, "wpn_fps_remove_cos")
    table.addto(self.wpn_fps_sho_striker.uses_parts, self.nqr.all_angled_sights)

    self.parts.wpn_fps_sho_ultima_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20.1 }
    self.parts.wpn_fps_sho_ultima_b_kit.pcs = {}
    self.parts.wpn_fps_sho_ultima_b_kit.stats = { concealment = 0, weight = 0, barrel_length = 20.1 }
    self.parts.wpn_fps_sho_ultima_body_kit_body = deep_clone(self.parts.wpn_fps_sho_ultima_body_kit)
    self.parts.wpn_fps_sho_ultima_body_kit_body.pcs = {}
    self.parts.wpn_fps_sho_ultima_body_kit_body.type = "lower_reciever"
    self.parts.wpn_fps_sho_ultima_body_kit_body.adds = {}
    self.parts.wpn_fps_sho_ultima_body_kit_body.forbids = {}
    self.parts.wpn_fps_sho_ultima_body_kit_body.override = {}
    self.parts.wpn_fps_sho_ultima_body_kit_body.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ultima_body_kit.pcs = {}
    self.parts.wpn_fps_sho_ultima_body_kit.sort_number = -1000
    self.parts.wpn_fps_sho_ultima_body_kit.type = "gadget"
    self.parts.wpn_fps_sho_ultima_body_kit.unit = fantom_unit
    self.parts.wpn_fps_sho_ultima_body_kit.animations = nil
    self.parts.wpn_fps_sho_ultima_body_kit.override = {}
    self.parts.wpn_fps_sho_ultima_body_kit.stats = { concealment = 18, weight = 6 }
    self.parts.wpn_fps_sho_ultima_body_rack.type = "upper_reciever"
    self.parts.wpn_fps_sho_ultima_body_rack.stats = { concealment = 0, weight = 0, totalammo = 6 }
    self.parts.wpn_fps_sho_ultima_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ultima_fg_kit.pcs = {}
    self.parts.wpn_fps_sho_ultima_fg_kit.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ultima_fg_camera = deep_clone(self.parts.wpn_fps_sho_ultima_fg_standard)
    self.parts.wpn_fps_sho_ultima_fg_camera.type = "wep_cos"
    self.parts.wpn_fps_sho_ultima_fg_camera.forbids = { "wpn_fps_sho_ultima_body_kit" }
    self.parts.wpn_fps_sho_ultima_fg_camera.visibility = { { objects = { g_foregrip = false } } }
    self.parts.wpn_fps_sho_ultima_fg_camera.stats = { concealment = 6, weight = 2 }
    self.parts.wpn_fps_sho_ultima_fg_standard.visibility = { { objects = { g_camera = false } } }
    self.parts.wpn_fps_sho_ultima_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ultima_fl_kit.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_ultima_m_standard.stats = { concealment = 0, weight = 0, CLIP_AMMO_MAX = 7 }
    self.parts.wpn_fps_sho_ultima_ns_comp.stats = { concealment = 8, weight = 4, length = 3, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_sho_ultima_s_light.pcs = nil
    self.parts.wpn_fps_sho_ultima_s_light.stats = { concealment = 0, weight = 0, length = 22, shouldered = true }
    self.parts.wpn_fps_sho_ultima_s_standard.stats = { concealment = 0, weight = 0, length = 14 }
    self.wpn_fps_sho_ultima.override = {
        wpn_fps_remove_s = {
            unit = self.parts.wpn_fps_sho_ultima_s_standard.unit,
            stats = deep_clone(self.parts.wpn_fps_sho_ultima_s_standard.stats),
        },
    }
    table.addto_dict(self.wpn_fps_sho_ultima.override, overrides_shotgun_sps_sound)
    table.swap(self.wpn_fps_sho_ultima.default_blueprint, "wpn_fps_sho_ultima_s_standard", "wpn_fps_sho_ultima_s_light")
    table.insert(self.wpn_fps_sho_ultima.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_ultima.default_blueprint, "wpn_fps_sho_ultima_fg_camera")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_sho_ultima_fg_camera")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_acog")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_uh")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_fc1")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_spot")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_tf90")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_upg_o_poe")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_remove_cos")
    table.insert(self.wpn_fps_sho_ultima.uses_parts, "wpn_fps_sho_ultima_body_kit_body")
    table.addto(self.wpn_fps_sho_ultima.uses_parts, self.nqr.all_second_sights)

    self.parts.wpn_fps_shot_b682_m = deep_clone(self.parts.wpn_fps_shot_b682_b_long)
    self.parts.wpn_fps_shot_b682_m.type = "magazine"
    self.parts.wpn_fps_shot_b682_m.visibility = { { objects = { g_fg_lod0 = false, g_ejector_lod0 = false, g_barrel_lod0 = false } } }
    self.parts.wpn_fps_shot_b682_m.stats = {}
    self.parts.wpn_fps_shot_b682_b_short.visibility = { { objects = { g_slug_lower_lod0 = false, g_slug_upper_lod0 = false } } }
    self.parts.wpn_fps_shot_b682_b_short.stats = { concealment = 0, weight = -10, barrel_length = 13 } --roughly
    self.parts.wpn_fps_shot_b682_b_long.visibility = { { objects = { g_slug_lower_lod0 = false, g_slug_upper_lod0 = false } } }
    self.parts.wpn_fps_shot_b682_b_long.stats = { concealment = 0, weight = 0, barrel_length = 28 } --not_sure
    self.parts.wpn_fps_shot_b682_body_standard.adds = { "wpn_fps_shot_b682_m" }
    self.parts.wpn_fps_shot_b682_body_standard.stats = { concealment = 0, weight = 0, length = 7 }
    self.parts.wpn_fps_shot_b682_s_ammopouch.type = "stock_addon"
    self.parts.wpn_fps_shot_b682_s_ammopouch.visibility = { { objects = { g_stock_lod0 = false } } }
    self.parts.wpn_fps_shot_b682_s_ammopouch.stats = { concealment = 0, weight = 0, totalammo = 6 }
    self.parts.wpn_fps_shot_b682_s_long.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_shot_b682_s_short.forbids = { "wpn_fps_shot_b682_s_ammopouch" }
    self.parts.wpn_fps_shot_b682_s_short.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_shot_huntsman_m = deep_clone(self.parts.wpn_fps_shot_huntsman_b_long)
    self.parts.wpn_fps_shot_huntsman_m.type = "magazine"
    self.parts.wpn_fps_shot_huntsman_m.visibility = { { objects = { g_short_barrel = false } } }
    self.parts.wpn_fps_shot_huntsman_m.stats = {}
    self.parts.wpn_fps_shot_huntsman_b_short.visibility = { { objects = { g_slug_left = false, g_slug_right = false } } }
    self.parts.wpn_fps_shot_huntsman_b_short.stats = { concealment = 0, weight = -6, barrel_length = 8 } --roughly
    self.parts.wpn_fps_shot_huntsman_b_long.visibility = { { objects = { g_slug_left = false, g_slug_right = false } } }
    self.parts.wpn_fps_shot_huntsman_b_long.stats = { concealment = 0, weight = 0, barrel_length = 16 } --roughy
    self.parts.wpn_fps_shot_huntsman_body_standard.adds = { "wpn_fps_shot_huntsman_m" }
    self.parts.wpn_fps_shot_huntsman_body_standard.stats = { concealment = 0, weight = 0, length = 7 }
    self.parts.wpn_fps_shot_huntsman_s_long.stats = { concealment = 0, weight = 0, length = 8, shouldered = true }
    self.parts.wpn_fps_shot_huntsman_s_short.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_shot_m1897_b_long.stats = { concealment = 0, weight = 0, barrel_length = 28 } --not_sure
    self.parts.wpn_fps_shot_m1897_b_short.stats = { concealment = 0, weight = 0, barrel_length = 18 } --roughly
    self.parts.wpn_fps_shot_m1897_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20 }
    self.parts.wpn_fps_shot_m1897_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_m1897_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_m1897_m_standard.stats = { concealment = 0, weight = 0, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_shot_m1897_s_short.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_shot_m1897_s_standard.stats = { concealment = 0, weight = 0, length = 19, shouldered = true }
    self.parts.wpn_nqr_m1897_heatshield = {
		a_obj = "a_b",
		type = "extra",
		name_id = "bm_wp_m1897_heatshield",
		unit = "units/pd2_dlc_mxw/weapons/wpn_fps_shot_m1897_pts/wpn_fps_shot_m1897_b_short",
		adds = {},
        forbids = {},
        override = {},
        stats = {},
	}
    self.parts.wpn_nqr_m1897_b_standard_heatshield = {
		texture_bundle_folder = "mxw",
		dlc = "mxw",
		type = "barrel",
		name_id = "bm_wp_m1897_b_standard_heatshield",
		unit = "units/pd2_dlc_mxw/weapons/wpn_fps_shot_m1897_pts/wpn_fps_shot_m1897_b_standard",
		a_obj = "a_b",
		pcs = { 10, 20, 30, 40 },
        adds = { "wpn_nqr_m1897_heatshield" },
		forbids = {},
        override = {},
        stats = { concealment = 0, weight = 0, barrel_length = 20 },
	}
    table.addto_dict(self.wpn_fps_shot_m1897.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_shot_m1897.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_m1897.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_m1897.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_m1897.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_m1897.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_shot_m1897.uses_parts, "wpn_nqr_m1897_b_standard_heatshield")

    self.wpn_fps_shot_m37.sightheight_mod = 0.1
    self.parts.wpn_fps_shot_m37_b_short.stats = { concealment = 0, weight = 0, barrel_length = 13 }
    self.parts.wpn_fps_shot_m37_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 20 }
    self.parts.wpn_fps_shot_m37_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_m37_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_shot_m37_m_standard.stats = { concealment = 0, weight = 0, CLIP_AMMO_MAX = 4 }
    self.parts.wpn_fps_shot_m37_s_short.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_shot_m37_s_standard.stats = { concealment = 0, weight = 0, length = 20, shouldered = true }
    self.parts.wpn_fps_m37_rail = {
		a_obj = "a_o",
		type = "extra",
		name_id = "bm_wp_m37_rail",
		unit = "units/pd2_dlc_berry/weapons/wpn_fps_snp_model70_pts/wpn_fps_snp_model70_o_rail",
		rails = { "top" },
        pcs = {},
		adds = {},
        forbids = {},
        override = {},
        stats = { concealment = 2, weight = 1 },
	}
    table.addto_dict(self.wpn_fps_shot_m37.override, overrides_shotgun_sps_sound)
    table.addto(self.wpn_fps_shot_m37.uses_parts, table.without(self.nqr.all_sights, self.nqr.all_snoptics))
    table.insert(self.wpn_fps_shot_m37.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_m37.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_shot_m37.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_m37.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_shot_m37.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_m37.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_shot_m37.uses_parts, "wpn_fps_m37_rail")
    table.insert(self.wpn_fps_shot_m37.uses_parts, "wpn_fps_addon_ris")

    self.parts.wpn_fps_sho_supernova_b_short.stats = { concealment = 0, weight = 0, barrel_length = 14 }
    self.parts.wpn_fps_sho_supernova_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 18.5 }
    self.parts.wpn_fps_sho_supernova_b_long.stats = { concealment = 0, weight = 0, barrel_length = 24 }
    self.parts.wpn_fps_sho_supernova_body_standard.stats = { concealment = 0, weight = 0, length = 10 }
    self.parts.wpn_fps_sho_supernova_m_extender.override.wpn_fps_sho_supernova_b_standard = nil
    table.addto(self.parts.wpn_fps_sho_supernova_m_extender.override.wpn_fps_sho_supernova_b_short.forbids, self.nqr.all_bxs_magext)
    self.parts.wpn_fps_sho_supernova_m_extender.stats = { concealment = 0, weight = 0, overlength = { barrel = { 4, 14 } }, CLIP_AMMO_MAX = 7 }
    self.parts.wpn_fps_sho_supernova_g_standard.adds = {}
    self.parts.wpn_fps_sho_supernova_g_standard.forbids = {}
    self.parts.wpn_fps_sho_supernova_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_supernova_g_raven.adds = {}
    self.parts.wpn_fps_sho_supernova_g_raven.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_sho_supernova_g_adapter.type = "stock"
    self.parts.wpn_fps_sho_supernova_g_adapter.adds = {}
    self.parts.wpn_fps_sho_supernova_g_adapter.forbids = { "wpn_fps_sho_supernova_g_stakeout", "wpn_fps_sho_supernova_g_raven" }
    self.parts.wpn_fps_sho_supernova_g_adapter.override = { wpn_fps_sho_supernova_g_standard = { unit = fantom_unit } }
    self.parts.wpn_fps_sho_supernova_g_adapter.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_sho_supernova_s_standard.forbids = { "wpn_fps_sho_supernova_g_stakeout" }
    self.parts.wpn_fps_sho_supernova_s_standard.stats = { concealment = 0, weight = 0, length = 11, shouldered = true }
    self.parts.wpn_fps_sho_supernova_s_collapsed.forbids = { "wpn_fps_sho_supernova_g_stakeout" }
    self.parts.wpn_fps_sho_supernova_s_collapsed.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_sho_supernova_s_raven.forbids = { "wpn_fps_sho_supernova_g_stakeout" }
    self.parts.wpn_fps_sho_supernova_s_raven.stats = { concealment = 0, weight = 0, length = 7 }
    table.addto_dict(self.wpn_fps_sho_supernova.override, overrides_shotgun_sps_sound)
    table.insert(self.wpn_fps_sho_supernova.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_supernova.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_sho_supernova.default_blueprint, 1, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_supernova.uses_parts, "wpn_fps_foregrip_lock_vertical_grips")
    table.insert(self.wpn_fps_sho_supernova.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_sho_supernova.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_sho_supernova.uses_parts, self.nqr.all_tube_stocks)



----PISTOL
	self.parts.wpn_fps_pis_g17_b_dummy = {
		unit = self.parts.wpn_fps_pis_g17_body_standard.unit,
		a_obj = "a_body",
		type = "barrel_dummy",
        visibility = { { objects = { g_body = false } } },
		stats = {},
	}
    self.parts.wpn_fps_pis_g17_bb_standard = deep_clone(self.parts.wpn_fps_pis_g17_b_standard)
    self.parts.wpn_fps_pis_g17_bb_standard.unit = "units/payday2/weapons/wpn_fps_pis_g22c_pts/wpn_fps_pis_g22c_b_standard"
    self.parts.wpn_fps_pis_g17_bb_standard.name_id = "bm_wp_g17_bb_standard"
    self.parts.wpn_fps_pis_g17_bb_standard.a_obj = "a_b"
    self.parts.wpn_fps_pis_g17_bb_standard.pcs = {}
    self.parts.wpn_fps_pis_g17_bb_standard.type = "barrel"
    self.parts.wpn_fps_pis_g17_bb_standard.adds = { "wpn_fps_pis_g17_b_dummy" }
    self.parts.wpn_fps_pis_g17_bb_standard.forbids = { "wpn_fps_pis_g22c_b_long" }
    self.parts.wpn_fps_pis_g17_bb_standard.visibility = { { objects = { g_no_blurr = false, g_slide = false, g_sights = false, g_barrel = false } } }
    self.parts.wpn_fps_pis_g17_bb_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_pis_g17_body_standard.pcs = {}
    self.parts.wpn_fps_pis_g17_body_standard.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_g17_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_g17_b_standard.pcs = {}
    --self.parts.wpn_fps_pis_g17_b_standard.forbids = { "wpn_fps_pis_g22c_bb_vented", "wpn_fps_pis_g22c_bb_long_vented" }
    self.parts.wpn_fps_pis_g17_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g17_m_standard.unit = self.parts.wpn_fps_pis_g18c_m_mag_17rnd.unit
    self.parts.wpn_fps_pis_g17_m_standard.pcs = {}
    self.parts.wpn_fps_pis_g17_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 19, [".40 S&W"] = 16 } }
    self.wpn_fps_pis_g17.override.wpn_fps_pis_g26_g_gripforce = { a_obj = "a_g_2" }
    self.wpn_fps_pis_g17.override.wpn_fps_pis_g26_g_laser = { a_obj = "a_g_2" }
    table.insert(self.wpn_fps_pis_g17.default_blueprint, "wpn_fps_pis_g17_bb_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g17_bb_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_bb_vented")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_bb_long_vented")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_bb_long")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_o_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_body_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_magwell")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_b_long")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g22c_b_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_co_1")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_co_comp_2")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_g_ergo")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_b_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_bb_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_body_frame")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_pis_g18c_b_standard")
    table.insert(self.wpn_fps_pis_g17.uses_parts, "wpn_fps_upg_cal_40sw")
    table.addto(self.wpn_fps_pis_g17.uses_parts, self.nqr.all_bxs_sbp)

    self.parts.wpn_fps_pis_g18c_b_dummy = {
		unit = self.parts.wpn_fps_pis_g18c_body_frame.unit,
		a_obj = "a_body",
		type = "barrel_dummy",
        visibility = { { objects = { g_glock_frame_lod0 = false } } },
		stats = {},
	}
    self.parts.wpn_fps_pis_g18c_bb_standard = deep_clone(self.parts.wpn_fps_pis_g18c_b_standard)
    self.parts.wpn_fps_pis_g18c_bb_standard.pcs = {}
    self.parts.wpn_fps_pis_g18c_bb_standard.name_id = "bm_wp_g18c_bb_standard"
    self.parts.wpn_fps_pis_g18c_bb_standard.type = "barrel"
    self.parts.wpn_fps_pis_g18c_bb_standard.adds = { "wpn_fps_pis_g18c_b_dummy" }
    self.parts.wpn_fps_pis_g18c_bb_standard.override = { wpn_fps_pis_g18c_co_1 = { parent = "slide" }, wpn_fps_pis_g18c_co_comp_2 = { parent = "slide" } }
    self.parts.wpn_fps_pis_g18c_bb_standard.visibility = { { objects = { g_slide_lod0 = false } } }
    self.parts.wpn_fps_pis_g18c_bb_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.5, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_g18c_b_standard.pcs = {}
    self.parts.wpn_fps_pis_g18c_b_standard.animations.fire_steelsight = "recoil"
    self.parts.wpn_fps_pis_g18c_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g18c_body_frame.pcs = {}
    self.parts.wpn_fps_pis_g18c_body_frame.visibility = { { objects = { g_barrel_18c = false } } }
    self.parts.wpn_fps_pis_g18c_body_frame.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_g18c_co_1.parent = "barrel"
    self.parts.wpn_fps_pis_g18c_co_1.stats = { concealment = 3, weight = 2, length = 1, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_g18c_co_comp_2.parent = "barrel"
    self.parts.wpn_fps_pis_g18c_co_comp_2.stats = { concealment = 2, weight = 2, length = 1, md_code = {0,0,1,2,0} }
    self.parts.wpn_fps_pis_g18c_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g18c_m_mag_17rnd.pcs = {}
    self.parts.wpn_fps_pis_g18c_m_mag_17rnd.bullet_objects = { amount = 1, prefix = "g_bullet_" }
    self.parts.wpn_fps_pis_g18c_m_mag_17rnd.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 19, [".40 S&W"] = 16 } }
    self.parts.wpn_fps_pis_g18c_m_mag_33rnd.bullet_objects = { amount = 1, prefix = "g_bullet_" }
    self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["9x19"] = 33, [".40 S&W"] = 29 } }
    self.parts.wpn_fps_pis_g18c_s_stock.stats = { concealment = 0, weight = 0, shouldered = true }
    table.delete(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g18c_s_stock")
    table.swap(self.wpn_fps_pis_g18c.default_blueprint, "wpn_fps_pis_g18c_b_standrd")
    table.insert(self.wpn_fps_pis_g18c.default_blueprint, "wpn_fps_pis_g18c_bb_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g18c_bb_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_upg_cal_40sw")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g17_b_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g17_bb_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g17_body_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_bb_vented")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_bb_long_vented")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_bb_long")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_o_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_body_standard")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_magwell")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_b_long")
    table.insert(self.wpn_fps_pis_g18c.uses_parts, "wpn_fps_pis_g22c_b_standard")

    self.parts.wpn_fps_pis_g22c_bb_vented = deep_clone(self.parts.wpn_fps_pis_g22c_b_standard)
    self.parts.wpn_fps_pis_g22c_bb_vented.name_id = "bm_wp_g22c_bb_vented"
    self.parts.wpn_fps_pis_g22c_bb_vented.type = "barrel"
    self.parts.wpn_fps_pis_g22c_bb_vented.pcs = {}
    self.parts.wpn_fps_pis_g22c_bb_vented.forbids = { "wpn_fps_pis_g22c_b_long" }
    self.parts.wpn_fps_pis_g22c_bb_vented.visibility = { { objects = { g_slide = false, g_sights = false } } }
    self.parts.wpn_fps_pis_g22c_bb_vented.stats = { concealment = 0, weight = 0, barrel_length = 4.5, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_g22c_bb_long_vented = deep_clone(self.parts.wpn_fps_pis_g22c_b_long)
    self.parts.wpn_fps_pis_g22c_bb_long_vented.name_id = "bm_wp_g22c_bb_long_vented"
    self.parts.wpn_fps_pis_g22c_bb_long_vented.a_obj = "a_b"
    self.parts.wpn_fps_pis_g22c_bb_long_vented.type = "barrel"
    self.parts.wpn_fps_pis_g22c_bb_long_vented.pcs = {}
    self.parts.wpn_fps_pis_g22c_bb_long_vented.forbids = { "wpn_fps_pis_g18c_co_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_g22c_bb_long_vented.visibility = { { objects = { g_slide = false, g_sights_long = false } } }
    self.parts.wpn_fps_pis_g22c_bb_long_vented.stats = { concealment = 0, weight = 0, barrel_length = 5.3, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_g22c_bb_long = deep_clone(self.parts.wpn_fps_pis_g22c_bb_long_vented)
    self.parts.wpn_fps_pis_g22c_bb_long.name_id = "bm_wp_g22c_bb_long"
    self.parts.wpn_fps_pis_g22c_bb_long.forbids = { "wpn_fps_pis_g18c_co_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_g22c_bb_long.stats = { concealment = 0, weight = 0, barrel_length = 5.3, }
    self.parts.wpn_fps_pis_g22c_o_standard = deep_clone(self.parts.wpn_fps_pis_g22c_b_standard)
    self.parts.wpn_fps_pis_g22c_o_standard.name_id = "bm_wp_g22c_o_standard"
    self.parts.wpn_fps_pis_g22c_o_standard.type = "ironsight"
    self.parts.wpn_fps_pis_g22c_o_standard.pcs = {}
    self.parts.wpn_fps_pis_g22c_o_standard.visibility = { { objects = { g_slide = false, g_barrel = false } } }
    self.parts.wpn_fps_pis_g22c_o_standard.stats = { concealment = 0, weight = 0, sightheight = 0.2 }
    self.parts.wpn_fps_pis_g22c_o_long = deep_clone(self.parts.wpn_fps_pis_g22c_b_long)
    self.parts.wpn_fps_pis_g22c_o_long.name_id = "bm_wp_g22c_o_long"
    self.parts.wpn_fps_pis_g22c_o_long.a_obj = "a_b"
    self.parts.wpn_fps_pis_g22c_o_long.type = "ironsight"
    self.parts.wpn_fps_pis_g22c_o_long.visibility = { { objects = { g_slide = false, g_barrel = false } } }
    self.parts.wpn_fps_pis_g22c_o_long.stats = { concealment = 0, weight = 0, sightheight = self.parts.wpn_fps_pis_g22c_o_standard.sightheight }
    self.parts.wpn_fps_pis_g22c_magwell = deep_clone(self.parts.wpn_fps_pis_g22c_body_standard)
    self.parts.wpn_fps_pis_g22c_magwell.name_id = "bm_wp_g22c_magwell"
    self.parts.wpn_fps_pis_g22c_magwell.type = "stock"
    self.parts.wpn_fps_pis_g22c_magwell.pcs = {}
    self.parts.wpn_fps_pis_g22c_magwell.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_fps_pis_g22c_magwell.stats = { concealment = 3, weight = 1 }
    self.parts.wpn_fps_pis_g22c_b_long.sub_type = "ironsight"
    self.parts.wpn_fps_pis_g22c_b_long.a_obj = "a_b"
    self.parts.wpn_fps_pis_g22c_b_long.forbids = { "wpn_fps_pis_g22c_o_standard" }
    self.parts.wpn_fps_pis_g22c_b_long.override = { wpn_fps_pis_g22c_bb_long = { forbids = {} },  wpn_fps_pis_g22c_bb_long_vented = { forbids = {} } }
    self.parts.wpn_fps_pis_g22c_b_long.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_g22c_b_long.stats = { concealment = 0, weight = 0, sightheight = self.parts.wpn_fps_pis_g22c_o_standard.sightheight }
    self.parts.wpn_fps_pis_g22c_b_standard.pcs = {}
    self.parts.wpn_fps_pis_g22c_b_standard.sub_type = "ironsight"
    self.parts.wpn_fps_pis_g22c_b_standard.forbids = { "wpn_fps_pis_g22c_o_standard" }
    self.parts.wpn_fps_pis_g22c_b_standard.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_g22c_b_standard.stats = { concealment = 0, weight = 0, sightheight = self.parts.wpn_fps_pis_g22c_o_standard.sightheight }
    self.parts.wpn_fps_pis_g22c_body_standard.pcs = {}
    self.parts.wpn_fps_pis_g22c_body_standard.visibility = { { objects = { g_magwell = false } } }
    self.parts.wpn_fps_pis_g22c_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.wpn_fps_pis_g22c.animations = nil
    table.insert(self.wpn_fps_pis_g22c.default_blueprint, "wpn_fps_pis_g22c_bb_vented")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g22c_bb_vented")
    table.insert(self.wpn_fps_pis_g22c.default_blueprint, "wpn_fps_pis_g22c_magwell")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g22c_magwell")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g22c_o_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g22c_bb_long_vented")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g22c_bb_long")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g17_body_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g17_b_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g17_bb_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g18c_bb_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g18c_body_frame")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_pis_g18c_b_standard")
    table.insert(self.wpn_fps_pis_g22c.uses_parts, "wpn_fps_upg_cal_9x19")

    self.parts.wpn_fps_pis_g26_bb_standard = deep_clone(self.parts.wpn_fps_pis_g26_b_standard)
    self.parts.wpn_fps_pis_g26_bb_standard.name_id = "bm_wp_g26_bb_standard"
    self.parts.wpn_fps_pis_g26_bb_standard.type = "barrel"
    self.parts.wpn_fps_pis_g26_bb_standard.pcs = {}
    self.parts.wpn_fps_pis_g26_bb_standard.forbids = {}
    self.parts.wpn_fps_pis_g26_bb_standard.visibility = { { objects = { g_slide_lod0 = false } } }
    self.parts.wpn_fps_pis_g26_bb_standard.stats = { concealment = 0, weight = 0, barrel_length = 3.4 }
    self.parts.wpn_fps_pis_g26_bb_custom = deep_clone(self.parts.wpn_fps_pis_g26_b_custom)
    self.parts.wpn_fps_pis_g26_bb_custom.name_id = "bm_wp_g26_bb_custom"
    self.parts.wpn_fps_pis_g26_bb_custom.type = "barrel"
    self.parts.wpn_fps_pis_g26_bb_custom.pcs = {}
    self.parts.wpn_fps_pis_g26_bb_custom.forbids = {}
    self.parts.wpn_fps_pis_g26_bb_custom.visibility = { { objects = { g_slide_lod0 = false } } }
    self.parts.wpn_fps_pis_g26_bb_custom.stats = { concealment = 0, weight = 0, barrel_length = 3.4 }
    self.parts.wpn_fps_pis_g26_b_standard.visibility = { { objects = { g_barrel_lod0 = false} } }
    self.parts.wpn_fps_pis_g26_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 3.4 }
    self.parts.wpn_fps_pis_g26_b_custom.visibility = { { objects = { g_barrel_lod0 = false} } }
    self.parts.wpn_fps_pis_g26_b_custom.stats = { concealment = 0, weight = 0, barrel_length = 3.4 }
    self.parts.wpn_fps_pis_g26_body_custom.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g26_body_stardard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_g26_fl_adapter.name_id = "bm_wp_legacy_gadgetrail"
    self.parts.wpn_fps_pis_g26_fl_adapter.type = "extra3"
    self.parts.wpn_fps_pis_g26_fl_adapter.pcs = {}
    self.parts.wpn_fps_pis_g26_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_pis_g26_fl_adapter.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_pis_g26_g_gripforce.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g26_g_laser.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_g26_m_contour.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 10, [".40 S&W"] = 9 } }
    self.parts.wpn_fps_pis_g26_m_standard.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 10, [".40 S&W"] = 9 } }
    self.wpn_fps_pis_g26.adds = {}
    table.insert(self.wpn_fps_pis_g26.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_g26.default_blueprint, "wpn_fps_pis_g26_bb_standard")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g26_bb_standard")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g26_bb_custom")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g26_fl_adapter")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g18c_co_1")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g18c_co_comp_2")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_pis_g17_m_standard")
    table.insert(self.wpn_fps_pis_g26.uses_parts, "wpn_fps_upg_cal_40sw")

    self.wpn_fps_pis_maxim9.sightheight_mod = 0.23
    self.parts.wpn_fps_pis_maxim9_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.4, length = 1, md_code = {2,0,0,0,0} }
    self.parts.wpn_fps_pis_maxim9_b_long.stats = { concealment = 16, weight = 5, barrel_length = 4.4, length = 4, md_code = {4,0,0,0,0} }
    self.parts.wpn_fps_pis_maxim9_b_marksman.stats = { concealment = 6, weight = 3, barrel_length = 4.4, length = 3, md_code = {2,0,0,0,0} }
    self.parts.wpn_fps_pis_maxim9_body_lower.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_maxim9_body_upper.sub_type = "ironsight"
    self.parts.wpn_fps_pis_maxim9_body_upper.stats = { concealment = 0, weight = 0, sightheight = self.wpn_fps_pis_maxim9.sightheight_mod }
    self.parts.wpn_fps_pis_maxim9_m_standard.stats = self.parts.wpn_fps_pis_g17_m_standard.stats
    self.parts.wpn_fps_pis_maxim9_m_ext.stats = self.parts.wpn_fps_pis_g18c_m_mag_33rnd.stats
    self.wpn_fps_pis_maxim9.override = {
        wpn_fps_pis_g18c_m_mag_33rnd = { unit = self.parts.wpn_fps_pis_maxim9_m_ext.unit, third_unit = self.parts.wpn_fps_pis_maxim9_m_ext.third_unit },
        wpn_fps_upg_o_t1micro = { a_obj = "a_rds", parent = "barrel" },
        wpn_fps_upg_o_docter = { a_obj = "a_rds", parent = "barrel" },
        wpn_fps_upg_o_atibal_reddot = { a_obj = "a_rds", parent = "barrel" },
        wpn_fps_upg_o_northtac_reddot = { a_obj = "a_rds", parent = "barrel" },
    }
    table.delete(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_upg_pis_ns_flash")
    table.delete(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_upg_ns_pis_meatgrinder")
    table.delete(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_upg_ns_pis_ipsccomp")
    table.delete(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_pis_maxim9_m_ext")
    table.insert(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_pis_g18c_m_mag_33rnd")
    table.insert(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_upg_o_t1micro")
    table.insert(self.wpn_fps_pis_maxim9.uses_parts, "wpn_fps_upg_o_docter")

    self.parts.wpn_fps_pis_beretta_b_std.type = "barrel"
    self.parts.wpn_fps_pis_beretta_b_std.stats = { concealment = 0, weight = 0, barrel_length = 4.9 }
    self.parts.wpn_fps_pis_beretta_hm_standard = deep_clone(self.parts.wpn_fps_pis_beretta_body_beretta)
    self.parts.wpn_fps_pis_beretta_hm_standard.name_id = "bm_wp_beretta_hm_modern"
    self.parts.wpn_fps_pis_beretta_hm_standard.type = "hammer"
    self.parts.wpn_fps_pis_beretta_hm_standard.pcs = {}
    self.parts.wpn_fps_pis_beretta_hm_standard.forbids = {}
    self.parts.wpn_fps_pis_beretta_hm_standard.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_fps_pis_beretta_hm_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_hm_modern = deep_clone(self.parts.wpn_fps_pis_beretta_body_modern) --todo challenge lock
    self.parts.wpn_fps_pis_beretta_hm_modern.name_id = "bm_wp_beretta_hm_modern"
    self.parts.wpn_fps_pis_beretta_hm_modern.type = "hammer"
    self.parts.wpn_fps_pis_beretta_hm_modern.pcs = {}
    self.parts.wpn_fps_pis_beretta_hm_modern.forbids = {}
    self.parts.wpn_fps_pis_beretta_hm_modern.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_fps_pis_beretta_hm_modern.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_body_beretta.visibility = { { objects = { g_hammer = false } } }
    self.parts.wpn_fps_pis_beretta_body_beretta.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_beretta_body_modern.rails = { "bottom" }
    self.parts.wpn_fps_pis_beretta_body_modern.override = { wpn_fps_extra_lock_gadgets = { forbids = {} } }
    self.parts.wpn_fps_pis_beretta_body_modern.visibility = { { objects = { g_hammer = false } } }
    self.parts.wpn_fps_pis_beretta_body_modern.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_beretta_body_rail.type = "extra3"
    self.parts.wpn_fps_pis_beretta_body_rail.pcs = {}
    self.parts.wpn_fps_pis_beretta_body_rail.name_id = "bm_wp_usp_gadgetrail"
    self.parts.wpn_fps_pis_beretta_body_rail.rails = { "bottom" }
    self.parts.wpn_fps_pis_beretta_body_rail.stats = { concealment = 1, weight = 1 }
    self.parts.wpn_fps_pis_beretta_co_co1.type = "upper_reciever"
    self.parts.wpn_fps_pis_beretta_co_co1.parent = "barrel"
    self.parts.wpn_fps_pis_beretta_co_co1.forbids = { "wpn_fps_pis_beretta_co_co2" }
    table.addto(self.parts.wpn_fps_pis_beretta_co_co1.forbids, self.nqr.all_mds1)
    self.parts.wpn_fps_pis_beretta_co_co1.override = {}
    for i, k in pairs(self.nqr.all_sps) do self.parts.wpn_fps_pis_beretta_co_co1.override[k] = { parent = "upper_reciever" } end
    self.parts.wpn_fps_pis_beretta_co_co1.stats = { concealment = 0, weight = 3, length = 2, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_beretta_co_co2.parent = "barrel"
    self.parts.wpn_fps_pis_beretta_co_co2.stats = { concealment = 0, weight = 3, length = 3 } --not_sure
    self.parts.wpn_fps_pis_beretta_g_engraved.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_g_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_m_std.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 15 }
    self.parts.wpn_fps_pis_beretta_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_pis_beretta_o_std.type = "ironsight"
    self.parts.wpn_fps_pis_beretta_o_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_sl_std.type = "slide"
    self.parts.wpn_fps_pis_beretta_sl_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beretta_sl_brigadier.type = "slide"
    self.parts.wpn_fps_pis_beretta_sl_brigadier.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_beretta.adds = {}
    self.wpn_fps_pis_beretta.override = { wpn_upg_o_marksmansight_front = { a_obj = "a_os" }, }
    for i, k in pairs(self.nqr.all_pistol_reddots) do self.wpn_fps_pis_beretta.override[k] = { parent = "slide" } end
    table.insert(self.wpn_fps_pis_beretta.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_beretta.default_blueprint, "wpn_fps_pis_beretta_hm_standard")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_pis_beretta_hm_standard")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_pis_beer_b_std")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_pis_beretta_body_rail")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_pis_beer_m_extended")
    table.insert(self.wpn_fps_pis_beretta.uses_parts, "wpn_fps_pis_beretta_hm_modern")

    self.parts.wpn_fps_pis_beer_b_std.stats = { concealment = 0, weight = 0, barrel_length = 4.9, md_code = {0,0,1,0,0}, md_bulk = {1,1} }
    self.parts.wpn_fps_pis_beer_b_robo.unit = fantom_unit
    self.parts.wpn_fps_pis_beer_b_robo.type = "exclusive_set" --todo vg
    self.parts.wpn_fps_pis_beer_b_robo.rails = { "bottom" }
    self.parts.wpn_fps_pis_beer_b_robo.forbids = {}
    table.addto(self.parts.wpn_fps_pis_beer_b_robo.forbids, deep_clone(self.nqr.all_pistol_reddots))
    table.addto(self.parts.wpn_fps_pis_beer_b_robo.forbids, deep_clone(self.nqr.all_bxs_sbp))
    self.parts.wpn_fps_pis_beer_b_robo.override.wpn_fps_pis_beer_body_modern = nil
    self.parts.wpn_fps_pis_beer_b_robo.override.wpn_fps_pis_beer_b_std = {
        unit = "units/pd2_dlc_afp/weapons/wpn_fps_pis_beer_pts/wpn_fps_pis_beer_b_robo",
        stats = { concealment = 0, weight = 0 },
    }
    self.parts.wpn_fps_pis_beer_b_robo.override.wpn_fps_extra_lock_gadgets = { forbids = {} }
    self.parts.wpn_fps_pis_beer_b_robo.stats = { concealment = 18, weight = 6, barrel_length = 10, md_code = {0,0,0,1,0}, sightheight = 1.5 }
    self.parts.wpn_fps_pis_beer_body_rail = deep_clone(self.parts.wpn_fps_pis_beer_body_modern)
    self.parts.wpn_fps_pis_beer_body_rail.texture_bundle_folder = "afp"
    self.parts.wpn_fps_pis_beer_body_rail.dlc = "afp"
    self.parts.wpn_fps_pis_beer_body_rail.name_id = "bm_wp_beer_gadgetrail"
    self.parts.wpn_fps_pis_beer_body_rail.pcs = {}
    self.parts.wpn_fps_pis_beer_body_rail.type = "extra3"
    self.parts.wpn_fps_pis_beer_body_rail.rails = { "bottom" }
    self.parts.wpn_fps_pis_beer_body_rail.forbids = { "wpn_fps_pis_beer_b_robo" }
    self.parts.wpn_fps_pis_beer_body_rail.visibility = { { objects = { g_body = false, g_vg = false } } }
    self.parts.wpn_fps_pis_beer_body_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_body_vg = deep_clone(self.parts.wpn_fps_pis_beer_body_modern)
    self.parts.wpn_fps_pis_beer_body_vg.type = "vertical_grip"
    self.parts.wpn_fps_pis_beer_body_vg.forbids = { "wpn_fps_pis_beer_body_rail", "wpn_fps_pis_beer_b_robo" }
    self.parts.wpn_fps_pis_beer_body_vg.visibility = { { objects = { g_body = false, g_rail = false } } }
    self.parts.wpn_fps_pis_beer_body_vg.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_pis_beer_body_modern.unit = "units/pd2_dlc_afp/weapons/wpn_fps_pis_beer_pts/wpn_fps_pis_beer_body_robo"
    self.parts.wpn_fps_pis_beer_body_modern.visibility = { { objects = { g_vg = false, g_rail = false } } }
    self.parts.wpn_fps_pis_beer_body_modern.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_beer_body_robo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_dh_hammer.type = "hammer"
    self.parts.wpn_fps_pis_beer_dh_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_g_lux.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_g_robo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_g_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_m_extended.animations = deep_clone(self.parts.wpn_fps_pis_beretta_m_extended.animations)
    self.parts.wpn_fps_pis_beer_m_extended.stats = { concealment = 4, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_pis_beer_m_std.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 15 }
    self.parts.wpn_fps_pis_beer_o_robo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_o_std.type = "ironsight"
    self.parts.wpn_fps_pis_beer_o_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_s_std.forbids = { "wpn_fps_pis_beretta_m_extended", "wpn_fps_pis_beer_m_extended" }
    self.parts.wpn_fps_pis_beer_s_std.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_pis_beer_sl_std.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_beer_ext_lock = {
		a_obj = "a_fl_2",
		type = "barrel_ext_lock",
		name_id = "bm_wp_pis_beer_ext_lock",
        unit = fantom_unit,
        adds = {}, forbids = {}, override = {}, stats = {},
		forbids = deep_clone(self.nqr.all_gadgets),
    }
    --self.wpn_fps_pis_beer.animations = nil
    table.delete(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_pis_beer_s_std")
    table.insert(self.wpn_fps_pis_beer.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_beer.default_blueprint, "wpn_fps_pis_beer_body_vg")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_pis_beer_body_vg")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_pis_beretta_m_extended")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_pis_beretta_hm_modern")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_pis_beer_body_rail")
    table.insert(self.wpn_fps_pis_beer.uses_parts, "wpn_fps_remove_vg")

    self.parts.wpn_fps_pis_holt_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.3 }
    self.parts.wpn_fps_pis_holt_body_lower.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_holt_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_holt_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_holt_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_holt_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_holt_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 25 } --roughly
    self.parts.wpn_fps_pis_holt_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 15 }

    self.parts.wpn_fps_pis_p226_b_barrel_standard.forbids = { "wpn_fps_pis_p226_b_long" }
    self.parts.wpn_fps_pis_p226_b_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.4 }
    self.parts.wpn_fps_pis_p226_b_barrel_equinox.pcs = {}
    self.parts.wpn_fps_pis_p226_b_barrel_equinox.forbids = { "wpn_fps_pis_p226_b_long" }
    self.parts.wpn_fps_pis_p226_b_barrel_equinox.stats = { concealment = 0, weight = 0, barrel_length = 4.4 }
    self.parts.wpn_fps_pis_p226_b_barrel_long.pcs = {}
    self.parts.wpn_fps_pis_p226_b_barrel_long.forbids = { "wpn_fps_pis_p226_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_p226_b_barrel_long.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_p226_b_equinox.adds = { "wpn_fps_pis_p226_o_standard" }
    self.parts.wpn_fps_pis_p226_b_equinox.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_b_long.adds = { "wpn_fps_pis_p226_o_long" }
    self.parts.wpn_fps_pis_p226_b_long.override = { wpn_fps_pis_p226_b_barrel_long = { forbids = {} } }
    self.parts.wpn_fps_pis_p226_b_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_b_standard.adds = { "wpn_fps_pis_p226_o_standard" }
    self.parts.wpn_fps_pis_p226_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_p226_co_comp_1.parent = "barrel"
    self.parts.wpn_fps_pis_p226_co_comp_1.unit = self.parts.wpn_fps_pis_g18c_co_1.unit
    self.parts.wpn_fps_pis_p226_co_comp_1.third_unit = self.parts.wpn_fps_pis_g18c_co_1.third_unit
    self.parts.wpn_fps_pis_p226_co_comp_1.stats = { concealment = 3, weight = 2, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_p226_co_comp_2.parent = "barrel"
    self.parts.wpn_fps_pis_p226_co_comp_2.unit = self.parts.wpn_fps_pis_g18c_co_comp_2.unit
    self.parts.wpn_fps_pis_p226_co_comp_2.third_unit = self.parts.wpn_fps_pis_g18c_co_comp_2.third_unit
    self.parts.wpn_fps_pis_p226_co_comp_2.stats = { concealment = 2, weight = 2, md_code = {0,0,1,1,0} }
    self.parts.wpn_fps_pis_p226_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".40 S&W"] = 13, ["9x19"] = 15 } }
    self.parts.wpn_fps_pis_p226_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { [".40 S&W"] = 22, ["9x19"] = 32 } }
    self.parts.wpn_fps_pis_p226_o_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_p226_o_standard.stats = { concealment = 0, weight = 0 }
    table.insert(self.wpn_fps_pis_p226.default_blueprint, "wpn_fps_pis_p226_b_barrel_standard")
    table.insert(self.wpn_fps_pis_p226.uses_parts, "wpn_fps_pis_p226_b_barrel_standard")
    table.insert(self.wpn_fps_pis_p226.uses_parts, "wpn_fps_upg_cal_9x19")

    self.parts.wpn_fps_pis_hs2000_b_standard_dummy = deep_clone(self.parts.wpn_fps_pis_hs2000_b_standard)
    self.parts.wpn_fps_pis_hs2000_b_standard_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_pis_hs2000_b_standard_dummy.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_standard_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_hs2000_b_custom_dummy = deep_clone(self.parts.wpn_fps_pis_hs2000_b_custom)
    self.parts.wpn_fps_pis_hs2000_b_custom_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_pis_hs2000_b_custom_dummy.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_custom_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_hs2000_b_long_dummy = deep_clone(self.parts.wpn_fps_pis_hs2000_b_long)
    self.parts.wpn_fps_pis_hs2000_b_long_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_pis_hs2000_b_long_dummy.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_long_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_hs2000_b_standard.forbids = { "wpn_fps_pis_hs2000_sl_long", "wpn_fps_pis_p226_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_hs2000_b_standard.visibility = { { objects = { g_static_barrel_piece_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_pis_hs2000_b_custom.pcs = {}
    self.parts.wpn_fps_pis_hs2000_b_custom.forbids = { "wpn_fps_pis_hs2000_sl_long" }
    self.parts.wpn_fps_pis_hs2000_b_custom.visibility = { { objects = { g_static_barrel_piece_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_custom.stats = { concealment = 0, weight = 0, barrel_length = 4, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_hs2000_b_long.pcs = {}
    self.parts.wpn_fps_pis_hs2000_b_long.forbids = { "wpn_fps_pis_p226_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_hs2000_b_long.visibility = { { objects = { g_static_barrel_piece_lod0 = false } } }
    self.parts.wpn_fps_pis_hs2000_b_long.stats = { concealment = 0, weight = 0, barrel_length = 5.2 }
    self.parts.wpn_fps_pis_hs2000_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_hs2000_sl_standard.adds = { "wpn_fps_pis_hs2000_b_standard_dummy" }
    self.parts.wpn_fps_pis_hs2000_sl_standard.forbids = { "wpn_fps_pis_hs2000_b_custom" }
    self.parts.wpn_fps_pis_hs2000_sl_standard.override = { wpn_fps_pis_hs2000_b_standard = { forbids = { "wpn_fps_pis_hs2000_sl_long" } } }
    self.parts.wpn_fps_pis_hs2000_sl_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_hs2000_sl_custom.adds = { "wpn_fps_pis_hs2000_b_custom_dummy" }
    self.parts.wpn_fps_pis_hs2000_sl_custom.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_hs2000_sl_long.adds = { "wpn_fps_pis_hs2000_b_long_dummy" }
    self.parts.wpn_fps_pis_hs2000_sl_long.override = { wpn_fps_pis_hs2000_b_long = { forbids = {} } }
    self.parts.wpn_fps_pis_hs2000_sl_long.stats = { concealment = 0, weight = 0, sightheight = 0.25 }
    self.parts.wpn_fps_pis_hs2000_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { [".45 ACP"] = 25, [".40 S&W"] = 28, ["9x19"] = 32 } }
    self.parts.wpn_fps_pis_hs2000_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 13, [".40 S&W"] = 16, ["9x19"] = 19 } }
    table.insert(self.wpn_fps_pis_hs2000.default_blueprint, "wpn_fps_pis_hs2000_b_standard")
    table.insert(self.wpn_fps_pis_hs2000.uses_parts, "wpn_fps_pis_p226_co_comp_1")
    table.insert(self.wpn_fps_pis_hs2000.uses_parts, "wpn_fps_pis_p226_co_comp_2")
    table.insert(self.wpn_fps_pis_hs2000.uses_parts, "wpn_fps_upg_cal_9x19")
    table.insert(self.wpn_fps_pis_hs2000.uses_parts, "wpn_fps_upg_cal_45acp")

    self.parts.wpn_fps_pis_legacy_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.1 }
    self.parts.wpn_fps_pis_legacy_b_threaded.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_pis_legacy_body_standard.stats = { concealment = 0, weight = 0, length = 2 }
    self.parts.wpn_fps_pis_legacy_firepin_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_legacy_fl_mount.type = "extra3"
    self.parts.wpn_fps_pis_legacy_fl_mount.pcs = {}
    self.parts.wpn_fps_pis_legacy_fl_mount.name_id = "bm_wp_legacy_gadgetrail"
    self.parts.wpn_fps_pis_legacy_fl_mount.rails = { "bottom" }
    self.parts.wpn_fps_pis_legacy_fl_mount.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_legacy_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_legacy_g_wood.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_legacy_m_standard.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 13 }
    self.parts.wpn_fps_pis_legacy_safety_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_legacy_sl_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_legacy.adds = {}
    table.insert(self.wpn_fps_pis_legacy.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_legacy.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_legacy.uses_parts, "wpn_fps_pis_legacy_fl_mount")

    self.parts.wpn_fps_pis_packrat_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.6 }
    self.parts.wpn_fps_pis_packrat_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_packrat_bolt_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_packrat_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 15, [".40 S&W"] = 13 } }
    self.parts.wpn_fps_pis_packrat_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { ["9x19"] = 30, [".40 S&W"] = 28 } }
    self.parts.wpn_fps_pis_packrat_ns_wick.stats = { concealment = 8, weight = 3, length = 2, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_packrat_o_expert.type = "ironsight"
    self.parts.wpn_fps_pis_packrat_o_expert.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_packrat_o_standard.type = "ironsight"
    self.parts.wpn_fps_pis_packrat_o_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_packrat_sl_standard.stats = { concealment = 0, weight = 0 }
    table.insert(self.wpn_fps_pis_packrat.uses_parts, "wpn_fps_upg_cal_40sw")

    self.parts.wpn_fps_pis_pl14_b_comp.type = "barrel_ext"
    self.parts.wpn_fps_pis_pl14_b_comp.stats = { concealment = 0, weight = 0, barrel_length = 4.4, length = 2, md_code = {0,0,0,2,0} }
    self.parts.wpn_fps_pis_pl14_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.4 }
    self.parts.wpn_fps_pis_pl14_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_pl14_m_extended.stats = { concealment = 4, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 18 } --roughly
    self.parts.wpn_fps_pis_pl14_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 16 }
    self.parts.wpn_fps_pis_pl14_sl_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_pl14.override.wpn_fps_pis_g18c_co_1 = { a_obj = "a_ns" }
    self.wpn_fps_pis_pl14.override.wpn_fps_pis_g18c_co_comp_2 = { a_obj = "a_ns" }
    table.insert(self.wpn_fps_pis_pl14.uses_parts, "wpn_fps_pis_g18c_co_1")
    table.insert(self.wpn_fps_pis_pl14.uses_parts, "wpn_fps_pis_g18c_co_comp_2")

    self.parts.wpn_fps_pis_ppk_b_barrel_long.texture_bundle_folder = "dlc1"
    self.parts.wpn_fps_pis_ppk_b_barrel_long.dlc = "armored_transport"
    self.parts.wpn_fps_pis_ppk_b_barrel_long.name_id = "bm_wp_ppk_b_barrel_long"
    self.parts.wpn_fps_pis_ppk_b_barrel_long.pcs = {}
    self.parts.wpn_fps_pis_ppk_b_barrel_long.stats = { concealment = 0, weight = 0, barrel_length = 3.9 }
    self.parts.wpn_fps_pis_ppk_b_barrel_standard.forbids = { "wpn_fps_pis_ppk_b_long" }
    self.parts.wpn_fps_pis_ppk_b_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 3.3 }
    self.parts.wpn_fps_pis_ppk_b_long.adds = {}
    self.parts.wpn_fps_pis_ppk_b_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_b_standard.adds = {}
    self.parts.wpn_fps_pis_ppk_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_ppk_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_fl_mount.type = "extra3"
    self.parts.wpn_fps_pis_ppk_fl_mount.pcs = {}
    self.parts.wpn_fps_pis_ppk_fl_mount.name_id = "bm_wp_legacy_gadgetrail"
    self.parts.wpn_fps_pis_ppk_fl_mount.rails = { "bottom" }
    self.parts.wpn_fps_pis_ppk_fl_mount.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_g_laser.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_ppk_m_standard.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 7 }
    self.wpn_fps_pis_ppk.adds = {}
    table.insert(self.wpn_fps_pis_ppk.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_ppk.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_ppk.default_blueprint, "wpn_fps_pis_ppk_b_barrel_standard")
    table.insert(self.wpn_fps_pis_ppk.uses_parts, "wpn_fps_pis_ppk_fl_mount")

    self.parts.wpn_fps_pis_shrew_b_barrel.stats = { concealment = 0, weight = 0, barrel_length = 3 }
    self.parts.wpn_fps_pis_shrew_body_frame.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_shrew_fl_adapter.pcs = {}
    self.parts.wpn_fps_pis_shrew_fl_adapter.type = "extra3"
    self.parts.wpn_fps_pis_shrew_fl_adapter.name_id = "bm_wp_shrew_gadgetrail"
    self.parts.wpn_fps_pis_shrew_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_pis_shrew_fl_adapter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_h_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_m_extended.stats = { concealment = 3, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 } --roughly
    self.parts.wpn_fps_pis_shrew_m_standard.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_pis_shrew_sl_milled.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_shrew_sl_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_shrew.adds = {}
    table.insert(self.wpn_fps_pis_shrew.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_shrew.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_shrew.uses_parts, "wpn_fps_pis_shrew_fl_adapter")
    table.insert(self.wpn_fps_pis_shrew.uses_parts, "wpn_fps_pis_1911_co_1")
    table.insert(self.wpn_fps_pis_shrew.uses_parts, "wpn_fps_pis_1911_co_2")

    self.parts.wpn_fps_pis_sparrow_b_rpl.type = "barrel_ext"
    self.parts.wpn_fps_pis_sparrow_b_rpl.unit = fantom_unit
    self.parts.wpn_fps_pis_sparrow_b_rpl.override = {
        wpn_fps_pis_sparrow_b_threaded = {
            third_unit = "units/pd2_dlc_rip/weapons/wpn_third_pis_sparrow_pts/wpn_third_pis_sparrow_b_threaded",
            unit = "units/pd2_dlc_rip/weapons/wpn_fps_pis_sparrow_pts/wpn_fps_pis_sparrow_b_threaded"
        },
    }
    self.parts.wpn_fps_pis_sparrow_b_rpl.stats = { concealment = 0, weight = 0 } --thread protector
    self.parts.wpn_fps_pis_sparrow_b_941.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_pis_sparrow_b_comp.type = "barrel_ext"
    self.parts.wpn_fps_pis_sparrow_b_comp.forbids = {}
    self.parts.wpn_fps_pis_sparrow_b_comp.unit = fantom_unit
    self.parts.wpn_fps_pis_sparrow_b_comp.override = {
        wpn_fps_pis_sparrow_b_threaded = {
            third_unit = "units/pd2_dlc_rip/weapons/wpn_third_pis_sparrow_pts/wpn_third_pis_sparrow_b_comp",
            unit = "units/pd2_dlc_rip/weapons/wpn_fps_pis_sparrow_pts/wpn_fps_pis_sparrow_b_comp"
        },
    }
    self.parts.wpn_fps_pis_sparrow_b_comp.stats = { concealment = 0, weight = 0, md_code = {0,2,0,0,0} }
    self.parts.wpn_fps_pis_sparrow_b_threaded.unit = "units/pd2_dlc_rip/weapons/wpn_fps_pis_sparrow_pts/wpn_fps_pis_sparrow_b_rpl"
    self.parts.wpn_fps_pis_sparrow_b_threaded.third_unit = "units/pd2_dlc_rip/weapons/wpn_third_pis_sparrow_pts/wpn_third_pis_sparrow_b_rpl"
    self.parts.wpn_fps_pis_sparrow_b_threaded.stats = { concealment = 0, weight = 0, barrel_length = 4.5 }
    self.parts.wpn_fps_pis_sparrow_body_941.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_sparrow_body_941.override.wpn_fps_pis_sparrow_b_rpl = nil
    self.parts.wpn_fps_pis_sparrow_body_rpl.rails = { "bottom" }
    self.parts.wpn_fps_pis_sparrow_body_rpl.forbids = { "wpn_fps_pis_sparrow_fl_rail", "wpn_fps_pis_sparrow_g_cowboy" }
    self.parts.wpn_fps_pis_sparrow_body_rpl.override.wpn_fps_pis_sparrow_b_941 = nil
    self.parts.wpn_fps_pis_sparrow_body_rpl.override.wpn_fps_pis_sparrow_b_rpl = nil
    self.parts.wpn_fps_pis_sparrow_body_rpl.override.wpn_fps_extra_lock_gadgets = { forbids = {} }
    self.parts.wpn_fps_pis_sparrow_body_rpl.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_sparrow_fl_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_fl_rail.type = "extra3"
    self.parts.wpn_fps_pis_sparrow_fl_rail.pcs = {}
    self.parts.wpn_fps_pis_sparrow_fl_rail.name_id = "bm_wp_sparrow_gadgetrail"
    self.parts.wpn_fps_pis_sparrow_fl_rail.rails = { "bottom" }
    self.parts.wpn_fps_pis_sparrow_fl_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_g_941.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_g_cowboy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_g_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { ["9x19"] = 15, [".40 S&W"] = 12 } }
    self.parts.wpn_fps_pis_sparrow_sl_941.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_sparrow_sl_rpl.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_sparrow.adds = {}
    table.insert(self.wpn_fps_pis_sparrow.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_sparrow.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_sparrow.default_blueprint, "wpn_fps_pis_sparrow_b_941" )
    table.insert(self.wpn_fps_pis_sparrow.uses_parts, "wpn_fps_pis_sparrow_fl_rail")
    table.insert(self.wpn_fps_pis_sparrow.uses_parts, "wpn_fps_upg_cal_40sw")

    self.parts.wpn_fps_pis_1911_bb_standard = deep_clone(self.parts.wpn_fps_pis_1911_b_standard)
    self.parts.wpn_fps_pis_1911_bb_standard.name_id = "bm_wp_1911_bb_standard"
    self.parts.wpn_fps_pis_1911_bb_standard.pcs = {}
    self.parts.wpn_fps_pis_1911_bb_standard.type = "barrel"
    self.parts.wpn_fps_pis_1911_bb_standard.adds = {}
    self.parts.wpn_fps_pis_1911_bb_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_bb_standard.forbids = { "wpn_fps_pis_1911_b_long" }
    self.parts.wpn_fps_pis_1911_bb_standard.visibility = { { objects = { g_slide = false } } }
    self.parts.wpn_fps_pis_1911_bb_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_bb_vented = deep_clone(self.parts.wpn_fps_pis_1911_bb_standard)
    self.parts.wpn_fps_pis_1911_bb_vented.unit = self.parts.wpn_fps_pis_1911_b_vented.unit
    self.parts.wpn_fps_pis_1911_bb_vented.third_unit = self.parts.wpn_fps_pis_1911_b_vented.third_unit
    self.parts.wpn_fps_pis_1911_bb_vented.name_id = "bm_wp_1911_bb_vented"
    self.parts.wpn_fps_pis_1911_bb_vented.stats = { concealment = 0, weight = 0, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_1911_bb_long = deep_clone(self.parts.wpn_fps_pis_1911_b_long)
    self.parts.wpn_fps_pis_1911_bb_long.name_id = "bm_wp_1911_bb_long"
    self.parts.wpn_fps_pis_1911_bb_long.pcs = {}
    self.parts.wpn_fps_pis_1911_bb_long.type = "barrel"
    self.parts.wpn_fps_pis_1911_bb_long.adds = {}
    self.parts.wpn_fps_pis_1911_bb_long.forbids = { "wpn_fps_pis_1911_co_1", "wpn_fps_pis_1911_co_2", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_1911_bb_long.override = {}
    self.parts.wpn_fps_pis_1911_bb_long.visibility = { { objects = { g_slide_long = false } } }
    self.parts.wpn_fps_pis_1911_bb_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_bb_long_vented = deep_clone(self.parts.wpn_fps_pis_1911_bb_long)
    self.parts.wpn_fps_pis_1911_bb_long_vented.name_id = "bm_wp_1911_bb_long_vented"
    self.parts.wpn_fps_pis_1911_bb_long_vented.stats = { concealment = 0, weight = 0, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_1911_b_standard.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_1911_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 5 }
    self.parts.wpn_fps_pis_1911_b_vented.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_1911_b_vented.stats = { concealment = 0, weight = 0, barrel_length = 5 }
    self.parts.wpn_fps_pis_1911_b_long.override.wpn_fps_pis_1911_bb_long = { forbids = {} }
    self.parts.wpn_fps_pis_1911_b_long.override.wpn_fps_pis_1911_bb_long_vented = { forbids = {} }
    self.parts.wpn_fps_pis_1911_b_long.override.wpn_fps_pis_1911_co_1 = { a_obj = "a_nl" }
    self.parts.wpn_fps_pis_1911_b_long.override.wpn_fps_pis_1911_co_2 = { a_obj = "a_nl" }
    self.parts.wpn_fps_pis_1911_b_long.visibility = { { objects = { g_barrel_long = false } } }
    self.parts.wpn_fps_pis_1911_b_long.stats = { concealment = 0, weight = 0, barrel_length = 7 } --roughly
    self.parts.wpn_fps_pis_1911_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_1911_co_1.a_obj = "a_ns"
    self.parts.wpn_fps_pis_1911_co_1.parent = nil
    self.parts.wpn_fps_pis_1911_co_1.stats = { concealment = 4, weight = 2, md_code = {0,0,2,0,0} } --todo parent
    self.parts.wpn_fps_pis_1911_co_2.a_obj = "a_ns"
    self.parts.wpn_fps_pis_1911_co_2.parent = nil
    self.parts.wpn_fps_pis_1911_co_2.stats = { concealment = 3, weight = 2, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_1911_fl_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_g_engraved.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_g_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 8, [".40 S&W"] = 9, ["9x19"] = 10 } }
    self.parts.wpn_fps_pis_1911_m_extended.stats = { concealment = 5, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 12, [".40 S&W"] = 14, ["9x19"] = 16 } }
    self.parts.wpn_fps_pis_1911_m_big.stats = { concealment = 8, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { [".45 ACP"] = 13, [".40 S&W"] = 15, ["9x19"] = 17 } }
    self.parts.wpn_fps_pis_1911_o_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_1911_o_long.stats = { concealment = 0, weight = 0 }
    table.insert(self.wpn_fps_pis_1911.default_blueprint, "wpn_fps_pis_1911_bb_standard")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_bb_standard")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_bb_vented")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_bb_long")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_pis_1911_bb_long_vented")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_upg_cal_9x19")
    table.insert(self.wpn_fps_pis_1911.uses_parts, "wpn_fps_upg_cal_40sw")

    self.parts.wpn_fps_pis_m1911_gadgetrail = deep_clone(self.parts.wpn_fps_pis_m1911_body_standard)
    self.parts.wpn_fps_pis_m1911_gadgetrail.name_id = "bm_wp_m1911_gadgetrail"
    self.parts.wpn_fps_pis_m1911_gadgetrail.pcs = {}
    self.parts.wpn_fps_pis_m1911_gadgetrail.type = "extra3"
    self.parts.wpn_fps_pis_m1911_gadgetrail.rails = { "bottom" }
    self.parts.wpn_fps_pis_m1911_gadgetrail.visibility = { { objects = { g_body = false, g_hammer = false } } }
    self.parts.wpn_fps_pis_m1911_gadgetrail.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_pis_m1911_body_standard.visibility = { { objects = { g_rail = false } } }
    self.parts.wpn_fps_pis_m1911_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_m1911_b_hardballer_dummy = deep_clone(self.parts.wpn_fps_pis_m1911_b_hardballer)
    self.parts.wpn_fps_pis_m1911_b_hardballer_dummy.type = "barrel_dummy"
    self.parts.wpn_fps_pis_m1911_b_hardballer_dummy.visibility = { { objects = { g_barrel = false } } }
    self.parts.wpn_fps_pis_m1911_b_hardballer_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_m1911_b_standard.pcs = {}
    self.parts.wpn_fps_pis_m1911_b_standard.forbids = { "wpn_fps_pis_m1911_sl_hardballer" }
    self.parts.wpn_fps_pis_m1911_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 5 }
    self.parts.wpn_fps_pis_m1911_b_hardballer.pcs = {}
    self.parts.wpn_fps_pis_m1911_b_hardballer.forbids = { "wpn_fps_pis_usp_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_m1911_b_hardballer.visibility = { { objects = { g_rod = false } } }
    self.parts.wpn_fps_pis_m1911_b_hardballer.stats = { concealment = 0, weight = 0, barrel_length = 7 }
    self.parts.wpn_fps_pis_m1911_sl_standard.sub_type = "ironsight"
    self.parts.wpn_fps_pis_m1911_sl_standard.adds = {}
    self.parts.wpn_fps_pis_m1911_sl_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_m1911_sl_hardballer.adds = { "wpn_fps_pis_m1911_b_hardballer_dummy" }
    self.parts.wpn_fps_pis_m1911_sl_hardballer.sub_type = "ironsight"
    self.parts.wpn_fps_pis_m1911_sl_hardballer.forbids = {}
    self.parts.wpn_fps_pis_m1911_sl_hardballer.override = { wpn_fps_pis_m1911_b_hardballer = { forbids = {} } }
    self.parts.wpn_fps_pis_m1911_sl_hardballer.stats = { concealment = 0, weight = 0, sightheight = 0.4 }
    self.parts.wpn_fps_pis_m1911_sl_match.adds = {}
    self.parts.wpn_fps_pis_m1911_sl_match.sub_type = "ironsight"
    self.parts.wpn_fps_pis_m1911_sl_match.stats = { concealment = 0, weight = 0, sightheight = 1.1 }
    self.parts.wpn_fps_pis_m1911_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_m1911_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 8, [".40 S&W"] = 9, ["9x19"] = 10 } }
    self.parts.wpn_fps_pis_m1911_m_extended.stats = { concealment = 4, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 10, [".40 S&W"] = 11, ["9x19"] = 13 } }
    self.wpn_fps_pis_m1911.override.wpn_fps_pis_usp_co_comp_1 = { a_obj = "a_ns" }
    self.wpn_fps_pis_m1911.override.wpn_fps_pis_usp_co_comp_2 = { a_obj = "a_ns" }
    self.wpn_fps_pis_m1911.override.wpn_fps_upg_ns_pis_meatgrinder = { a_obj = "a_ns" }
    self.wpn_fps_pis_m1911.override.wpn_fps_upg_ns_pis_ipsccomp = { a_obj = "a_ns" }
    table.insert(self.wpn_fps_pis_m1911.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_pis_m1911_gadgetrail")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_pis_usp_co_comp_1")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_pis_usp_co_comp_2")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_upg_cal_9x19")
    table.insert(self.wpn_fps_pis_m1911.uses_parts, "wpn_fps_upg_cal_40sw")

    self.parts.wpn_fps_pis_usp_bb_tactical = deep_clone(self.parts.wpn_fps_pis_usp_b_tactical)
    self.parts.wpn_fps_pis_usp_bb_tactical.name_id = "bm_wp_usp_bb_tactical"
    self.parts.wpn_fps_pis_usp_bb_tactical.type = "barrel"
    self.parts.wpn_fps_pis_usp_bb_tactical.forbids = { "wpn_fps_pis_usp_b_expert" }
    self.parts.wpn_fps_pis_usp_bb_tactical.visibility = { { objects = { g_slide_lod0 = false, g_sights_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_bb_tactical.stats = { concealment = 0, weight = 0, barrel_length = 4.4 }
    self.parts.wpn_fps_pis_usp_b_tactical.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_b_tactical.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_usp_bb_expert = deep_clone(self.parts.wpn_fps_pis_usp_b_expert)
    self.parts.wpn_fps_pis_usp_bb_expert.name_id = "bm_wp_usp_bb_expert"
    self.parts.wpn_fps_pis_usp_bb_expert.type = "barrel"
    self.parts.wpn_fps_pis_usp_bb_expert.pcs = {}
    self.parts.wpn_fps_pis_usp_bb_expert.forbids = { "wpn_fps_pis_usp_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_usp_bb_expert.visibility = { { objects = { g_slide_lod0 = false, g_sights_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_bb_expert.stats = { concealment = 0, weight = 0, barrel_length = 5.1 }
    self.parts.wpn_fps_pis_usp_b_expert.override = { wpn_fps_pis_usp_bb_expert = { forbids = {} } }
    self.parts.wpn_fps_pis_usp_b_expert.visibility = { { objects = { g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_b_expert.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_usp_sl_match = deep_clone(self.parts.wpn_fps_pis_usp_b_match)
    self.parts.wpn_fps_pis_usp_sl_match.name_id = "bm_wp_usp_sl_match"
    self.parts.wpn_fps_pis_usp_sl_match.pcs = {}
    self.parts.wpn_fps_pis_usp_sl_match.visibility = { { objects = { g_barrel_lod0 = false, g_comp_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_sl_match.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_usp_bb_match = deep_clone(self.parts.wpn_fps_pis_usp_b_match)
    self.parts.wpn_fps_pis_usp_bb_match.name_id = "bm_wp_usp_bb_match"
    self.parts.wpn_fps_pis_usp_bb_match.type = "barrel"
    self.parts.wpn_fps_pis_usp_bb_match.pcs = {}
    self.parts.wpn_fps_pis_usp_bb_match.forbids = { "wpn_fps_pis_usp_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    self.parts.wpn_fps_pis_usp_bb_match.visibility = { { objects = { g_slide_lod0 = false, g_sights_lod0 = false, g_comp_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_bb_match.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_usp_b_match.name_id = "bm_wp_usp_extra_match"
    self.parts.wpn_fps_pis_usp_b_match.type = "extra3"
    self.parts.wpn_fps_pis_usp_b_match.forbids = { "wpn_fps_pis_usp_b_expert", "wpn_fps_pis_usp_co_comp_1", "wpn_fps_upg_ns_pis_meatgrinder", "wpn_fps_upg_ns_pis_ipsccomp" }
    table.addto(self.parts.wpn_fps_pis_usp_b_match.forbids, deep_clone(self.nqr.all_gadgets))
    self.parts.wpn_fps_pis_usp_b_match.override = { wpn_fps_pis_usp_bb_tactical = { forbids = { "wpn_fps_pis_usp_co_comp_2" } } }
    table.addto(self.parts.wpn_fps_pis_usp_b_match.override.wpn_fps_pis_usp_bb_tactical.forbids, deep_clone(self.nqr.all_bxs))
    self.parts.wpn_fps_pis_usp_b_match.override.wpn_fps_pis_usp_bb_expert = self.parts.wpn_fps_pis_usp_b_match.override.wpn_fps_pis_usp_bb_tactical
    self.parts.wpn_fps_pis_usp_b_match.visibility = { { objects = { g_slide_lod0 = false, g_sights_lod0 = false, g_barrel_lod0 = false } } }
    self.parts.wpn_fps_pis_usp_b_match.stats = { concealment = 0, weight = 3, overlength = { barrel = { 2, 4.4 } } }
    self.parts.wpn_fps_pis_usp_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_usp_co_comp_1.parent = "barrel"
    self.parts.wpn_fps_pis_usp_co_comp_1.unit = self.parts.wpn_fps_pis_g18c_co_1.unit
    self.parts.wpn_fps_pis_usp_co_comp_1.third_unit = self.parts.wpn_fps_pis_g18c_co_1.third_unit
    self.parts.wpn_fps_pis_usp_co_comp_1.stats = { concealment = 3, weight = 2, length = 1, md_code = {0,0,2,0,0} }
    self.parts.wpn_fps_pis_usp_co_comp_2.parent = "barrel"
    self.parts.wpn_fps_pis_usp_co_comp_2.unit = self.parts.wpn_fps_pis_g18c_co_comp_2.unit
    self.parts.wpn_fps_pis_usp_co_comp_2.third_unit = self.parts.wpn_fps_pis_g18c_co_comp_2.third_unit
    self.parts.wpn_fps_pis_usp_co_comp_2.stats = { concealment = 2, weight = 2, length = 1, md_code = {0,0,1,1,0} }
    self.parts.wpn_fps_pis_usp_fl_adapter.type = "extra3"
    self.parts.wpn_fps_pis_usp_fl_adapter.pcs = {}
    self.parts.wpn_fps_pis_usp_fl_adapter.name_id = "bm_wp_usp_gadgetrail"
    self.parts.wpn_fps_pis_usp_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_pis_usp_fl_adapter.stats = { concealment = 1, weight = 1 }
    self.parts.wpn_fps_pis_usp_m_big.stats = { concealment = 9, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 22 }
    self.parts.wpn_fps_pis_usp_m_extended.stats = { concealment = 7, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = { [".45 ACP"] = 20, [".40 S&W"] = 25, ["9x19"] = 30 } }
    self.parts.wpn_fps_pis_usp_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".45 ACP"] = 13, [".40 S&W"] = 16, ["9x19"] = 19 } }
    self.wpn_fps_pis_usp.adds = {}
    table.insert(self.wpn_fps_pis_usp.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_usp.default_blueprint, "wpn_fps_pis_usp_bb_tactical")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_pis_usp_bb_tactical")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_pis_usp_bb_expert")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_pis_usp_sl_match")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_pis_usp_bb_match")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_pis_usp_fl_adapter")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_upg_cal_40sw")
    table.insert(self.wpn_fps_pis_usp.uses_parts, "wpn_fps_upg_cal_9x19")

    self.parts.wpn_fps_pis_breech_b_reinforced.stats = { concealment = 0, weight = 0, barrel_length = 4.7 }
    self.parts.wpn_fps_pis_breech_b_short.stats = { concealment = 0, weight = 0, barrel_length = 2.5 }
    self.parts.wpn_fps_pis_breech_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 3.9 }
    self.parts.wpn_fps_pis_breech_body.stats = { concealment = 0, weight = 0, length = 4 }
    self.parts.wpn_fps_pis_breech_dh.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_breech_g_custom.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_breech_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_breech_mag.stats = { concealment = 2, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 8 }

    self.parts.wpn_fps_pis_c96_b_long.type = "barrel"
    self.parts.wpn_fps_pis_c96_b_long.forbids = { "wpn_fps_pis_c96_nozzle" }
    table.addto(self.parts.wpn_fps_pis_c96_b_long.forbids, self.nqr.all_sps)
    self.parts.wpn_fps_pis_c96_b_long.stats = { concealment = 0, weight = 0, barrel_length = 15 }
    self.parts.wpn_fps_pis_c96_b_standard.type = "barrel"
    self.parts.wpn_fps_pis_c96_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 5.5 }
    self.parts.wpn_fps_pis_c96_body_standard.stats = { concealment = 0, weight = 0, length = 5 }
    self.parts.wpn_fps_pis_c96_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_c96_m_extended.stats = { concealment = 2, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 }
    self.parts.wpn_fps_pis_c96_m_standard.stats = { concealment = 2, weight = 0, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 10 }
    self.parts.wpn_fps_pis_c96_nozzle.parent = "barrel"
    self.parts.wpn_fps_pis_c96_nozzle.stats = { concealment = 4, weight = 2, length = 1 }
    self.parts.wpn_fps_pis_c96_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_c96_s_solid.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_pis_c96_sight.forbids = {}
    table.addto(self.parts.wpn_fps_pis_c96_sight.forbids, self.nqr.all_magnifiers)
    self.parts.wpn_fps_pis_c96_sight.override = {}
    self.parts.wpn_fps_pis_c96_sight.visibility = { { objects = { g_inside_lod0 = false, } } }
    self.parts.wpn_fps_pis_c96_sight.stats = { concealment = 7, weight = 4, sightheight = 3, zoom = 2 }
    self.wpn_fps_pis_c96.override = {}
    table.deletefrom(self.wpn_fps_pis_c96.uses_parts, self.nqr.all_pistol_gadgets)
    table.deletefrom(self.wpn_fps_pis_c96.uses_parts, self.nqr.all_bxs)
    table.delete(self.wpn_fps_pis_c96.uses_parts, "wpn_fps_pis_c96_s_solid")
    table.delete(self.wpn_fps_pis_c96.uses_parts, "wpn_fps_pis_c96_sight")
    table.delete(self.wpn_fps_pis_c96.uses_parts, "wpn_fps_pis_c96_m_extended")

    self.parts.wpn_fps_pis_type54_b_long.type = "barrel_ext"
    self.parts.wpn_fps_pis_type54_b_long.stats = { concealment = 3, weight = 2, length = 1 }
    self.parts.wpn_fps_pis_type54_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.6 }
    self.parts.wpn_fps_pis_type54_body.stats = { concealment = 0, weight = 0, length = 3 }
    --table.insert(self.wpn_fps_pis_type54.uses_parts, "wpn_fps_pis_type54_body_akimbo")
    --self.parts.wpn_fps_pis_type54_body_akimbo.pcs = {}
    self.parts.wpn_fps_pis_type54_body_akimbo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_type54_fl_rail.type = "extra3"
    self.parts.wpn_fps_pis_type54_fl_rail.pcs = {}
    self.parts.wpn_fps_pis_type54_fl_rail.name_id = "bm_wp_legacy_gadgetrail"
    self.parts.wpn_fps_pis_type54_fl_rail.rails = { "bottom" }
    self.parts.wpn_fps_pis_type54_fl_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_type54_m_ext.stats = { concealment = 5, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 11 }
    self.parts.wpn_fps_pis_type54_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_pis_type54_sl_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_type54_underbarrel.pcs = nil
    self.parts.wpn_fps_pis_type54_underbarrel_piercing.pcs = nil
    self.parts.wpn_fps_pis_type54_underbarrel_slug.pcs = nil
    --table.insert(self.parts.wpn_fps_pis_type54_underbarrel.forbids, "wpn_fps_pis_type54_fl_rail")
    --[[self.parts.wpn_fps_pis_type54_underbarrel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_type54_underbarrel_piercing.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_type54_underbarrel_slug.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_x_type54_underbarrel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_x_type54_underbarrel_piercing.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_x_type54_underbarrel_slug.stats = { concealment = 0, weight = 0 }]]
    self.wpn_fps_pis_type54.adds = {}
    self.wpn_fps_pis_type54.override.wpn_fps_pis_g18c_co_1 = { a_obj = "a_ns", parent = "barrel" }
    self.wpn_fps_pis_type54.override.wpn_fps_pis_g18c_co_comp_2 = { a_obj = "a_ns", parent = "barrel" }
    table.insert(self.wpn_fps_pis_type54.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_type54.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_type54.uses_parts, "wpn_fps_pis_type54_fl_rail")
    table.insert(self.wpn_fps_pis_type54.uses_parts, "wpn_fps_pis_g18c_co_1")
    table.insert(self.wpn_fps_pis_type54.uses_parts, "wpn_fps_pis_g18c_co_comp_2")

    self.parts.wpn_fps_pis_lemming_b_nitride.stats = { concealment = 0, weight = 0, barrel_length = 4.8 }
    self.parts.wpn_fps_pis_lemming_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.8 }
    self.parts.wpn_fps_pis_lemming_body.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_lemming_m_ext.stats = { concealment = 7, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 30 }
    self.parts.wpn_fps_pis_lemming_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20 }
    self.parts.wpn_fps_pis_lemming_mag_release.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_lemming_sl_standard.stats = { concealment = 0, weight = 0 }

    self.wpn_fps_pis_deagle.sightheight_mod = 1.35
    self.parts.wpn_fps_pis_deagle_b_standard.type = "barrel"
    self.parts.wpn_fps_pis_deagle_b_standard.stats = { concealment = 0, weight = 4, barrel_length = 6 }
    self.parts.wpn_fps_pis_deagle_b_modern.type = "barrel"
    self.parts.wpn_fps_pis_deagle_b_modern.forbids = { "wpn_fps_pis_deagle_co_long", "wpn_fps_pis_deagle_co_short" }
    self.parts.wpn_fps_pis_deagle_b_modern.stats = { concealment = 0, weight = 3, md_code = {0,0,0,2,0}, barrel_length = 5.5, length = 0.5 } --roughly
    self.parts.wpn_fps_pis_deagle_b_long.type = "barrel"
    self.parts.wpn_fps_pis_deagle_b_long.stats = { concealment = 5, weight = 7, barrel_length = 10 }
    self.parts.wpn_fps_pis_deagle_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_deagle_extra.unit = "units/payday2/weapons/wpn_fps_pis_rage_pts/wpn_fps_pis_rage_o_adapter"
    self.parts.wpn_fps_pis_deagle_extra.internal_part = nil
    self.parts.wpn_fps_pis_deagle_extra.override = {}
    for i, k in pairs(table.with(self.nqr.all_reddots, self.nqr.all_piggyback_sights)) do self.parts.wpn_fps_pis_deagle_extra.override[k] = { a_obj = "a_quite" } end
    self.parts.wpn_fps_pis_deagle_extra.stats = { concealment = 4, weight = 2, sightheight = 1.9 }
    self.parts.wpn_fps_pis_deagle_body_standard.adds = {}
    self.parts.wpn_fps_pis_deagle_body_standard.stats = { concealment = 0, weight = 0, length = 4 }
    self.parts.wpn_fps_pis_deagle_co_short.stats = { concealment = 4, weight = 2, length = 2, md_code = {0,0,0,2,0} }
    self.parts.wpn_fps_pis_deagle_co_long.override = { wpn_upg_o_marksmansight_front = { a_obj = "a_ol" }, wpn_fps_pis_deagle_o_standard_front = { a_obj = "a_ol" }, }
    self.parts.wpn_fps_pis_deagle_co_long.stats = { concealment = 12, weight = 6, length = 5 }
    self.parts.wpn_fps_pis_deagle_fg_rail.pcs = {}
    self.parts.wpn_fps_pis_deagle_fg_rail.type = "extra3"
    self.parts.wpn_fps_pis_deagle_fg_rail.rails = { "bottom" }
    self.parts.wpn_fps_pis_deagle_fg_rail.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_pis_deagle_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".50 AE"] = 7, [".44 Mag"] = 8, [".357 Mag"] = 9 } }
    self.parts.wpn_fps_pis_deagle_m_extended.stats = { concealment = 7, weight = 2, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = { [".50 AE"] = 10, [".44 Mag"] = 11, [".357 Mag"] = 12 } }
    self.parts.wpn_fps_pis_deagle_o_standard_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_o_standard_front_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_o_standard_rear.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_deagle_lock.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_deagle.adds = {
        wpn_fps_pis_deagle_b_standard = { "wpn_fps_pis_deagle_o_standard_rear", "wpn_fps_pis_deagle_o_standard_front" },
        wpn_fps_pis_deagle_b_modern = { "wpn_fps_pis_deagle_o_standard_rear", "wpn_fps_pis_deagle_o_standard_front" },
        wpn_fps_pis_deagle_b_long = { "wpn_fps_pis_deagle_o_standard_rear", "wpn_fps_pis_deagle_o_standard_front_long" },
    }
    self.wpn_fps_pis_deagle.override = {
        wpn_upg_o_marksmansight_front = { a_obj = "a_os" },
        wpn_upg_o_marksmansight_rear = { a_obj = "a_o",
            forbids = table.list_add(self.parts.wpn_upg_o_marksmansight_rear.forbids, {
                "wpn_fps_pis_deagle_o_standard_front",
                "wpn_fps_pis_deagle_o_standard_front_long",
                "wpn_fps_pis_deagle_o_standard_rear"
            })
        },

        --wpn_fps_upg_o_rmr = { parent = false, a_obj = "a_os" },
        wpn_fps_upg_o_rmr = { parent = "lower_reciever" }, --override = { wpn_fps_extra_sightheightmod = { stats = { sightheight = -1.2 } } } },
        wpn_fps_upg_o_rms = { parent = "lower_reciever" }, --override = { wpn_fps_extra_sightheightmod = { stats = { sightheight = -1.2 } } } },
        wpn_fps_upg_o_rikt = { parent = "lower_reciever" }, --override = { wpn_fps_extra_sightheightmod = { stats = { sightheight = -1.2 } } } },
    }
    for i, k in pairs(table.combine(self.nqr.all_reddots, self.nqr.all_piggyback_sights)) do self.wpn_fps_pis_deagle.override[k] = { a_obj = "a_os" } end
    table.addto_dict(self.wpn_fps_pis_deagle.override, overrides_vertical_grip_and_gadget_thing)
    table.deletefrom(self.wpn_fps_pis_deagle.uses_parts, self.nqr.all_bxs)
    table.deletefrom(self.wpn_fps_pis_deagle.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_pis_deagle.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_pis_deagle.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_deagle.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_deagle.default_blueprint, "wpn_fps_extra_sightheightmod")
    table.insert(self.wpn_fps_pis_deagle.uses_parts, "wpn_fps_extra_sightheightmod")
    table.insert(self.wpn_fps_pis_deagle.uses_parts, "wpn_fps_pis_deagle_fg_rail")
    table.insert(self.wpn_fps_pis_deagle.uses_parts, "wpn_fps_upg_cal_44mag")
    table.insert(self.wpn_fps_pis_deagle.uses_parts, "wpn_fps_upg_cal_357mag")

    self.parts.wpn_nqr_stech_gadgetrail = deep_clone(self.parts.wpn_fps_pis_stech_body_standard)
    self.parts.wpn_nqr_stech_gadgetrail.name_id = "bm_wp_stech_gadgetrail"
    self.parts.wpn_nqr_stech_gadgetrail.pcs = {}
    self.parts.wpn_nqr_stech_gadgetrail.type = "extra3"
    self.parts.wpn_nqr_stech_gadgetrail.rails = { "bottom" }
    self.parts.wpn_nqr_stech_gadgetrail.visibility = { { objects = { g_body = false } } }
    self.parts.wpn_nqr_stech_gadgetrail.stats = { concealment = 1, weight = 1 }
    self.parts.wpn_fps_pis_stech_body_standard.visibility = { { objects = { g_body_rail = false } } }
    table.insert(self.wpn_fps_pis_stech.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_stech.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_stech.uses_parts, "wpn_nqr_stech_gadgetrail")
    self.parts.wpn_fps_pis_stech_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_stech_b_long.type = "barrel_ext"
    self.parts.wpn_fps_pis_stech_b_long.stats = { concealment = 3, weight = 2, length = 2 }
    self.parts.wpn_fps_pis_stech_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 5.7 }
    self.parts.wpn_fps_pis_stech_g_luxury.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_stech_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_stech_g_tactical.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_stech_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 40, retention = false } --roughly
    self.parts.wpn_fps_pis_stech_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 20, retention = false }
    self.parts.wpn_fps_pis_stech_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_pis_stech_sl_standard.stats = { concealment = 0, weight = 0 }
    table.delete(self.wpn_fps_pis_stech.uses_parts, "wpn_fps_pis_stech_s_standard")

    self.parts.wpn_fps_pis_czech_b_standard.adds = {}
    self.parts.wpn_fps_pis_czech_b_standard.forbids = {}
    self.parts.wpn_fps_pis_czech_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 4.7 }
    self.parts.wpn_fps_pis_czech_body_standard.visibility = { { objects = { g_vertical = false, } } }
    self.parts.wpn_fps_pis_czech_body_standard.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_pis_czech_g_luxury.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_czech_g_sport.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_czech_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_czech_m_standard.animations = { reload_not_empty = "reload_not_empty", reload = "reload" }
    self.parts.wpn_fps_pis_czech_m_standard.stats = { concealment = 4, weight = 1, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 19 }
    self.parts.wpn_fps_pis_czech_m_extended.stats = { concealment = 6, weight = 2, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 25 }
    self.parts.wpn_fps_pis_czech_ns_standard.name_id = "bm_wp_czech_ns_standard"
    self.parts.wpn_fps_pis_czech_ns_standard.pcs = {}
    self.parts.wpn_fps_pis_czech_ns_standard.stats = { concealment = 1, weight = 1, length = 2, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_czech_b_long.type = "barrel_ext"
    self.parts.wpn_fps_pis_czech_b_long.forbids = {}
    self.parts.wpn_fps_pis_czech_b_long.stats = { concealment = 10, weight = 4, length = 3, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_czech_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_pis_czech_sl_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_czech.override.wpn_fps_pis_g18c_co_1 = { a_obj = "a_ns", parent = "barrel" }
    self.wpn_fps_pis_czech.override.wpn_fps_pis_g18c_co_comp_2 = { a_obj = "a_ns", parent = "barrel" }
    table.delete(self.wpn_fps_pis_czech.uses_parts, "wpn_fps_pis_czech_s_standard")
    table.insert(self.wpn_fps_pis_czech.default_blueprint, "wpn_fps_pis_czech_ns_standard")
    table.insert(self.wpn_fps_pis_czech.uses_parts, "wpn_fps_pis_g18c_co_1")
    table.insert(self.wpn_fps_pis_czech.uses_parts, "wpn_fps_pis_g18c_co_comp_2")
    table.insert(self.wpn_fps_pis_czech.uses_parts, "wpn_fps_remove_ns")

    self.parts.wpn_fps_snp_contender_barrel_long.forbids = {}
    table.addto(self.parts.wpn_fps_snp_contender_barrel_long.forbids, self.nqr.all_sps)
    self.parts.wpn_fps_snp_contender_barrel_long.stats = { concealment = 0, weight = 1, barrel_length = 17 }
    self.parts.wpn_fps_snp_contender_barrel_standard.forbids = {}
    table.addto(self.parts.wpn_fps_snp_contender_barrel_standard.forbids, table.without(self.nqr.all_sps, {"wpn_fps_upg_ns_pis_putnik", "wpn_fps_smg_baka_b_midsupp"}))
    self.parts.wpn_fps_snp_contender_barrel_standard.stats = { concealment = 0, weight = 0, barrel_length = 14 }
    self.parts.wpn_fps_snp_contender_barrel_short.stats = { concealment = 0, weight = -2, barrel_length = 10 }
    --self.parts.wpn_fps_snp_contender_barrel_conversion.stats = { concealment = 0, weight = 0, barrel_length = 17, md_flash = 2 }
    --self.parts.wpn_fps_snp_contender_suppressor.sound_switch = { suppressed = "suppressed_c" }
    self.parts.wpn_fps_snp_contender_suppressor.stats = deep_clone(self.nqr.sps_stats.big)
    self.parts.wpn_fps_snp_contender_receiver.stats = { concealment = 0, weight = 0, length = 3 }
    self.parts.wpn_fps_snp_contender_triggerguard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_contender_bullet.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_contender_grip_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_m4_g_contender.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_m4_s_contender.type = "stock_addon"
    self.parts.wpn_fps_upg_m4_s_contender.adds_type = nil
    self.parts.wpn_fps_upg_m4_s_contender.forbids = {}
    self.parts.wpn_fps_upg_m4_s_contender.stats = { concealment = 0, weight = 4, length = 7, shouldered = true }
    self.parts.wpn_fps_snp_contender_frontgrip_short.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_contender_frontgrip_long.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_contender_o_ironsight.pcs = nil
    self.parts.wpn_fps_upg_contender_o_ironsight.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_snp_contender_conversion.stats = { concealment = 0, weight = 0 }
    --self.wpn_fps_snp_contender.override = {}
    --for i, k in pairs(self.nqr.all_reddots) do self.wpn_fps_snp_contender.override[k] = { parent = "barrel" } end
    table.deletefrom(self.wpn_fps_snp_contender.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_snp_contender.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_snp_contender.uses_parts, self.nqr.all_m4_stocks)
    table.deletefrom(self.wpn_fps_snp_contender.uses_parts, self.nqr.all_tube_stocks)
    table.delete(self.wpn_fps_snp_contender.uses_parts, "wpn_fps_upg_m4_g_contender")
    table.swap(self.wpn_fps_snp_contender.default_blueprint, "wpn_fps_upg_o_shortdot", "wpn_fps_upg_contender_o_ironsight")
    table.addto(self.wpn_fps_snp_contender.uses_parts, self.nqr.all_bxs_bbp)
    table.delete(self.wpn_fps_snp_contender.uses_parts, "wpn_fps_snp_tti_ns_hex")



----REVOLVER
    self.parts.wpn_fps_pis_judge_b_standard.type = "barrel"
    self.parts.wpn_fps_pis_judge_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 2.5 }
    self.parts.wpn_fps_pis_judge_b_legend.type = "barrel"
    self.parts.wpn_fps_pis_judge_b_legend.stats = { concealment = 0, weight = 0, barrel_length = 2.5 }
    self.parts.wpn_fps_pis_judge_g_modern = deep_clone(self.parts.wpn_fps_pis_judge_g_standard)
	self.parts.wpn_fps_pis_judge_g_modern.texture_bundle_folder = "icc"
    self.parts.wpn_fps_pis_judge_g_modern.unit = "units/pd2_dlc_icc/weapons/wpn_fps_pis_judge_body_modern/wpn_fps_pis_judge_g_modern"
    self.parts.wpn_fps_pis_judge_g_modern.third_unit = "units/pd2_dlc_icc/weapons/wpn_fps_pis_judge_body_modern/wpn_third_pis_judge_g_modern"
    self.parts.wpn_fps_pis_judge_g_modern.name_id = "bm_wp_judge_g_modern"
    self.parts.wpn_fps_pis_judge_g_modern.pcs = {}
    self.parts.wpn_fps_pis_judge_g_modern.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_judge_m_body = deep_clone(self.parts.wpn_fps_pis_judge_body_standard)
    self.parts.wpn_fps_pis_judge_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_judge_m_body.visibility = { { objects = { g_bullet_1 = false, g_bullet_2 = false, g_bullet_3 = false, g_bullet_4 = false, g_bullet_5 = false } } }
    self.parts.wpn_fps_pis_judge_m_body.stats = {}
    self.parts.wpn_fps_pis_judge_body_standard.type = "magazine"
    self.parts.wpn_fps_pis_judge_body_standard.adds = { "wpn_fps_pis_judge_m_body" }
    self.parts.wpn_fps_pis_judge_body_standard.visibility = { { objects = { g_hammer = false, g_lock = false, g_cylinder = false, g_frame = false } } }
    self.parts.wpn_fps_pis_judge_body_standard.stats = { concealment = 4, weight = 1, length = 6, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_pis_judge_body_modern.unit = fantom_unit
    self.parts.wpn_fps_pis_judge_body_modern.type = "exclusive_set"
    self.parts.wpn_fps_pis_judge_body_modern.rails = { "bottom" }
    self.parts.wpn_fps_pis_judge_body_modern.forbids = { "wpn_fps_pis_judge_fl_adapter" }
    self.parts.wpn_fps_pis_judge_body_modern.override = {
        wpn_fps_pis_judge_m_body = { unit = "units/pd2_dlc_icc/weapons/wpn_fps_pis_judge_body_modern/wpn_fps_pis_judge_body_modern" },
    }
    self.parts.wpn_fps_pis_judge_body_modern.stats = {} --todo mag
    self.parts.wpn_fps_pis_judge_fl_adapter.pcs = {}
    self.parts.wpn_fps_pis_judge_fl_adapter.type = "extra3"
    self.parts.wpn_fps_pis_judge_fl_adapter.name_id = "bm_wp_judge_gadgetrail"
    self.parts.wpn_fps_pis_judge_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_pis_judge_fl_adapter.stats = { concealment = 0, weight = 1 }
    self.parts.wpn_fps_pis_judge_g_legend.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_judge_g_standard.pcs = {}
    self.parts.wpn_fps_pis_judge_g_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_judge.adds = {}
    self.wpn_fps_pis_judge.override = {}
    table.deletefrom(self.wpn_fps_pis_judge.uses_parts, self.nqr.all_sights)
    table.deletefrom(self.wpn_fps_pis_judge.uses_parts, self.nqr.all_magnifiers)
    table.deletefrom(self.wpn_fps_pis_judge.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_pis_judge.uses_parts, self.nqr.all_mds1)
    table.insert(self.wpn_fps_pis_judge.default_blueprint, 1, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_extra3_lock_gadgets")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_judge_fl_adapter")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_judge_g_modern")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_korth_g_standard")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_korth_g_ergo")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_korth_g_houge")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_rage_g_standard")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_rage_g_ergo")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_rsh12_g_standard")
    table.insert(self.wpn_fps_pis_judge.uses_parts, "wpn_fps_pis_rsh12_g_wood")
    --table.addto(self.wpn_fps_pis_judge.uses_parts, self.nqr.all_pistol_gadgets)

    self.parts.wpn_fps_pis_chinchilla_b_standard.sub_type = "ironsight"
    self.parts.wpn_fps_pis_chinchilla_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_chinchilla_b_satan.sub_type = "ironsight"
    self.parts.wpn_fps_pis_chinchilla_b_satan.stats = { concealment = 0, weight = 3, barrel_length = 8.4, sightheight = 0.58 }
    self.parts.wpn_fps_pis_chinchilla_body.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_pis_chinchilla_dh_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_ejector.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_ejectorpin.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_g_black.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_g_death.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_g_standard.pcs = {}
    self.parts.wpn_fps_pis_chinchilla_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_lock_arm.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_chinchilla_m_loader = deep_clone(self.parts.wpn_fps_pis_chinchilla_m_bullets)
    self.parts.wpn_fps_pis_chinchilla_m_loader.type = "loader"
    self.parts.wpn_fps_pis_chinchilla_m_loader.visibility = { { objects = { g_cartridge_1 = false, g_cartridge_2 = false, g_cartridge_3 = false, g_cartridge_4 = false, g_cartridge_5 = false, g_cartridge_6 = false, g_bullet_1 = false, g_bullet_2 = false, g_bullet_3 = false, g_bullet_4 = false, g_bullet_5 = false, g_bullet_6 = false } } }
    self.parts.wpn_fps_pis_chinchilla_m_loader.stats = {}
    self.parts.wpn_fps_pis_chinchilla_m_bullets.reload_objects = nil
    self.parts.wpn_fps_pis_chinchilla_m_bullets.visibility = { { objects = { g_speedloader = false } } }
    self.parts.wpn_fps_pis_chinchilla_m_bullets.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_pis_chinchilla_cylinder.type = "upper_reciever2"
    self.parts.wpn_fps_pis_chinchilla_cylinder.adds = { "wpn_fps_pis_chinchilla_m_loader" }
    self.parts.wpn_fps_pis_chinchilla_cylinder.stats = {}
    --[[table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_judge_g_modern")
    table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_korth_g_standard")
    table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_korth_g_ergo")
    table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_korth_g_houge")
    table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_rage_g_standard")
    table.insert(self.wpn_fps_pis_chinchilla.uses_parts, "wpn_fps_pis_rage_g_ergo")]]

    --self.parts.wpn_fps_pis_korth_b_railed.forbids = deep_clone(self.nqr.all_pistol_gadgets)
    self.parts.wpn_fps_pis_korth_b_railed.override = {}
    self.parts.wpn_fps_pis_korth_b_railed.override.wpn_fps_pis_c96_sight = { a_obj = "a_o_2" }
    self.parts.wpn_fps_pis_korth_b_railed.override.wpn_fps_upg_o_cmore = { a_obj = "a_o_2" }
    self.parts.wpn_fps_pis_korth_b_railed.override.wpn_fps_upg_o_rx01 = { a_obj = "a_o_2" }
    self.parts.wpn_fps_pis_korth_b_railed.override.wpn_fps_upg_o_rx30 = { a_obj = "a_o_2" }
    self.parts.wpn_fps_pis_korth_b_railed.stats = { concealment = 0, weight = 1, barrel_length = 6 }
    self.parts.wpn_fps_pis_korth_b_standard.override = {
        wpn_fps_upg_o_cmore = { a_obj = "a_o_2" }, --todo custom_a_o
        wpn_fps_upg_o_rx01 = { a_obj = "a_o_2" },
        wpn_fps_upg_o_rx30 = { a_obj = "a_o_2" },
    }
    self.parts.wpn_fps_pis_korth_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_korth_body.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_pis_korth_conversionkit.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_fl_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_g_houge.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_g_standard.pcs = {}
    self.parts.wpn_fps_pis_korth_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_m_loader = deep_clone(self.parts.wpn_fps_pis_korth_m_8)
    self.parts.wpn_fps_pis_korth_m_loader.type = "loader"
    self.parts.wpn_fps_pis_korth_m_loader.visibility = { { objects = { g_rod = false, g_cylinder = false, g_lock = false, g_bullets_1 = false } } }
    self.parts.wpn_fps_pis_korth_m_loader.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_korth_m_body = deep_clone(self.parts.wpn_fps_pis_korth_m_6)
    self.parts.wpn_fps_pis_korth_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_korth_m_body.reload_objects = nil
    self.parts.wpn_fps_pis_korth_m_body.visibility = { { objects = { g_bullets_1 = false, g_speedloader = false } } }
    self.parts.wpn_fps_pis_korth_m_body.stats = {}
    self.parts.wpn_fps_pis_korth_m_6.unit = self.parts.wpn_fps_pis_korth_m_8.unit
    self.parts.wpn_fps_pis_korth_m_6.reload_objects = nil
    self.parts.wpn_fps_pis_korth_m_6.adds = { "wpn_fps_pis_korth_m_body", "wpn_fps_pis_korth_m_loader" }
    self.parts.wpn_fps_pis_korth_m_6.override = { wpn_fps_pis_korth_m_body = { unit = self.parts.wpn_fps_pis_korth_m_8.unit } }
    self.parts.wpn_fps_pis_korth_m_6.visibility = { { objects = { g_rod = false, g_cylinder = false, g_lock = false, g_speedloader = false } } }
    self.parts.wpn_fps_pis_korth_m_6.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 8 }
    self.parts.wpn_fps_pis_korth_m_8.unit = "units/pd2_dlc_pxp2/weapons/wpn_fps_pis_korth_pts/wpn_fps_pis_korth_m_6"
    self.parts.wpn_fps_pis_korth_m_8.reload_objects = nil
    self.parts.wpn_fps_pis_korth_m_8.adds = { "wpn_fps_pis_korth_m_body", "wpn_fps_pis_korth_m_loader" }
    self.parts.wpn_fps_pis_korth_m_8.forbids = { "wpn_fps_upg_cal_44mag" }
    self.parts.wpn_fps_pis_korth_m_8.visibility = { { objects = { g_rod = false, g_cylinder = false, g_lock = false, g_speedloader = false } } }
    self.parts.wpn_fps_pis_korth_m_8.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.wpn_fps_pis_korth.override.wpn_fps_upg_o_eotech = { a_obj = "a_o_2" }
    self.wpn_fps_pis_korth.override.wpn_fps_upg_o_tf90 = { a_obj = "a_o_2" }
    self.wpn_fps_pis_korth.override.wpn_fps_upg_o_uh = { a_obj = "a_o_2" }
    table.deletefrom(self.wpn_fps_pis_korth.uses_parts, self.nqr.all_optics)
    table.deletefrom(self.wpn_fps_pis_korth.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_pis_korth.uses_parts, self.nqr.all_mds1)
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_o_cmore")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_o_eotech")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_o_rx01")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_o_rx30")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_o_tf90")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_pis_rage_g_standard")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_pis_judge_g_standard")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_pis_judge_g_modern")
    table.insert(self.wpn_fps_pis_korth.uses_parts, "wpn_fps_upg_cal_44mag")

    self.parts.wpn_fps_pis_2006m_b_long.stats = { concealment = 0, weight = 2, barrel_length = 7 } --roughly
    self.parts.wpn_fps_pis_2006m_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6 }
    self.parts.wpn_fps_pis_2006m_b_medium.stats = { concealment = 0, weight = -1, barrel_length = 4 }
    self.parts.wpn_fps_pis_2006m_b_short.stats = { concealment = 0, weight = -2, barrel_length = 2 }
    self.parts.wpn_fps_pis_2006m_b_short.forbids = { "wpn_fps_pis_2006m_fl_adapter" }
    self.parts.wpn_fps_pis_2006m_body_standard.stats = { concealment = 0, weight = 0, length = 5 }
    self.parts.wpn_fps_pis_2006m_fl_adapter.pcs = {}
    self.parts.wpn_fps_pis_2006m_fl_adapter.name_id = "bm_wp_2006m_gadgetrail"
    self.parts.wpn_fps_pis_2006m_fl_adapter.rails = { "bottom" }
    self.parts.wpn_fps_pis_2006m_fl_adapter.stats = { concealment = 4, weight = 2 }
    self.parts.wpn_fps_pis_2006m_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_2006m_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_2006m_m_loader = deep_clone(self.parts.wpn_fps_pis_2006m_m_standard)
    self.parts.wpn_fps_pis_2006m_m_loader.type = "loader"
    self.parts.wpn_fps_pis_2006m_m_loader.reload_objects = { reload_not_empty = "g_loader_lod0", reload = "g_loader_lod0" }
    self.parts.wpn_fps_pis_2006m_m_loader.visibility = { { objects = { g_bullets = false, g_hinge_lod0 = false, g_mag_lod0 = false, g_ejector_lod0 = false } } }
    self.parts.wpn_fps_pis_2006m_m_loader.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_2006m_m_body = deep_clone(self.parts.wpn_fps_pis_2006m_m_standard)
    self.parts.wpn_fps_pis_2006m_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_2006m_m_body.visibility = { { objects = { g_bullets = false, g_loader_lod0 = false } } }
    self.parts.wpn_fps_pis_2006m_m_body.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_2006m_m_standard.type = "magazine"
    self.parts.wpn_fps_pis_2006m_m_standard.adds = { "wpn_fps_pis_2006m_m_body", "wpn_fps_pis_2006m_m_loader" }
    self.parts.wpn_fps_pis_2006m_m_standard.visibility = { { objects = { g_hinge_lod0 = false, g_mag_lod0 = false, g_ejector_lod0 = false, g_loader_lod0 = false } } }
    self.parts.wpn_fps_pis_2006m_m_standard.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.wpn_fps_pis_2006m.adds = {}
    table.deletefrom(self.wpn_fps_pis_2006m.uses_parts, self.nqr.all_bxs)
    table.addto(self.wpn_fps_pis_2006m.uses_parts, self.nqr.all_mds1)
    table.insert(self.wpn_fps_pis_2006m.default_blueprint, 1, "wpn_fps_extra_lock_gadgets")
    table.insert(self.wpn_fps_pis_2006m.uses_parts, "wpn_fps_extra_lock_gadgets")

    self.parts.wpn_fps_pis_rage_b_short.type = "barrel"
    self.parts.wpn_fps_pis_rage_b_short.forbids = { "wpn_fps_pis_rage_extra" }
    self.parts.wpn_fps_pis_rage_b_short.stats = { concealment = 0, weight = 0, barrel_length = 4, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_rage_b_comp1.type = "barrel"
    self.parts.wpn_fps_pis_rage_b_comp1.stats = { concealment = 0, weight = 1, barrel_length = 6, md_code = {0,0,2,0,0}, md_bulk = {2,1} }
    self.parts.wpn_fps_pis_rage_b_comp2.type = "barrel"
    self.parts.wpn_fps_pis_rage_b_comp2.stats = { concealment = 0, weight = 0, barrel_length = 5, md_code = {0,0,0,2,0} }
    self.parts.wpn_fps_pis_rage_b_long.type = "barrel"
    self.parts.wpn_fps_pis_rage_b_long.stats = { concealment = 0, weight = 0, barrel_length = 10, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_rage_b_standard.type = "barrel"
    self.parts.wpn_fps_pis_rage_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6, md_code = {0,0,1,0,0} }
    self.parts.wpn_fps_pis_rage_m_body = deep_clone(self.parts.wpn_fps_pis_rage_body_standard)
    self.parts.wpn_fps_pis_rage_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_rage_m_body.adds = {}
    self.parts.wpn_fps_pis_rage_m_body.visibility = { { objects = { g_bullets = false } } }
    self.parts.wpn_fps_pis_rage_m_body.stats = {}
    self.parts.wpn_fps_pis_rage_body_standard.type = "magazine"
    self.parts.wpn_fps_pis_rage_body_standard.adds = { "wpn_fps_pis_rage_m_body" }
    self.parts.wpn_fps_pis_rage_body_standard.visibility = { { objects = { g_hammer = false, g_lock = false, g_cylinder = false, g_cylinder_smooth = false, g_body = false, g_sight = false } } }
    self.parts.wpn_fps_pis_rage_body_standard.stats = { concealment = 3, weight = 1, length = 6, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_pis_rage_body_smooth.type = "magazine"
    self.parts.wpn_fps_pis_rage_body_smooth.adds = { "wpn_fps_pis_rage_m_body" }
    self.parts.wpn_fps_pis_rage_body_smooth.override = { wpn_fps_pis_rage_m_body = { unit = self.parts.wpn_fps_pis_rage_body_smooth.unit } }
    self.parts.wpn_fps_pis_rage_body_smooth.visibility = { { objects = { g_hammer = false, g_lock = false, g_cylinder = false, g_cylinder_smooth = false, g_body = false, g_sight = false } } }
    self.parts.wpn_fps_pis_rage_body_smooth.stats = { concealment = 3, weight = 1, length = 6, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_pis_rage_extra.internal_part = nil
    self.parts.wpn_fps_pis_rage_extra.unit = self.parts.wpn_fps_pis_rage_o_adapter.unit
    self.parts.wpn_fps_pis_rage_extra.rails = { "top" }
    self.parts.wpn_fps_pis_rage_extra.override = {}
    self.parts.wpn_fps_pis_rage_extra.stats = { concealment = 5, weight = 2, sightheight = 0.8 }
    self.parts.wpn_fps_pis_rage_g_ergo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_rage_g_standard.pcs = {}
    self.parts.wpn_fps_pis_rage_g_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_pis_rage.adds = {}
    table.deletefrom(self.wpn_fps_pis_rage.uses_parts, self.nqr.all_bxs)
    table.deletefrom(self.wpn_fps_pis_rage.uses_parts, self.nqr.all_magnifiers)
    table.deletefrom(self.wpn_fps_pis_rage.uses_parts, self.nqr.all_optics)
    table.insert(self.wpn_fps_pis_rage.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_upg_cal_454csl")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_korth_g_standard")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_korth_g_ergo")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_korth_g_houge")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_judge_g_standard")
    table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_judge_g_modern")
    --table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_rsh12_g_standard")
    --table.insert(self.wpn_fps_pis_rage.uses_parts, "wpn_fps_pis_rsh12_g_wood")

    self.parts.wpn_fps_pis_rsh12_b_comp.type = "barrel_ext"
    self.parts.wpn_fps_pis_rsh12_b_comp.forbids = {}
    self.parts.wpn_fps_pis_rsh12_b_comp.stats = { concealment = 4, weight = 3, md_code = {0,0,0,3,0} }
    self.parts.wpn_fps_pis_rsh12_b_short.stats = { concealment = 0, weight = 0, barrel_length = 5 }
    self.parts.wpn_fps_pis_rsh12_b_short.forbids = { "wpn_fps_pis_rsh12_b_comp" }
    self.parts.wpn_fps_pis_rsh12_b_standard.forbids = {}
    table.addto(self.parts.wpn_fps_pis_rsh12_b_standard.forbids, table.without(self.nqr.all_sps, {"wpn_fps_upg_ns_pis_putnik", "wpn_fps_smg_baka_b_midsupp"}))
    self.parts.wpn_fps_pis_rsh12_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 7.5 }
    self.parts.wpn_fps_pis_rsh12_m_body = deep_clone(self.parts.wpn_fps_pis_rsh12_body_standard)
    self.parts.wpn_fps_pis_rsh12_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_rsh12_m_body.visibility = { { objects = { g_bullet_1 = false, g_bullet_2 = false, g_bullet_3 = false, g_bullet_4 = false, g_bullet_5 = false, g_tip_1 = false, g_tip_2 = false, g_tip_3 = false, g_tip_4 = false, g_tip_5 = false } } }
    self.parts.wpn_fps_pis_rsh12_m_body.stats = {}
    self.parts.wpn_fps_pis_rsh12_body_standard.type = "magazine"
    self.parts.wpn_fps_pis_rsh12_body_standard.adds = { "wpn_fps_pis_rsh12_m_body" }
    self.parts.wpn_fps_pis_rsh12_body_standard.bullet_objects = { prefix = "g_tip_", amount = 5 }
    self.parts.wpn_fps_pis_rsh12_body_standard.visibility = { { objects = { g_hammer = false, g_lock = false, g_cylinder = false, g_frame = false } } }
    self.parts.wpn_fps_pis_rsh12_body_standard.stats = { concealment = 0, weight = 0, length = 6, mag_amount = { 2, 4, 6 }, CLIP_AMMO_MAX = 5 } --todo a_fl
    self.parts.wpn_fps_pis_rsh12_g_standard.pcs = {}
    self.parts.wpn_fps_pis_rsh12_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_rsh12_g_wood.stats = { concealment = 0, weight = 0 }
    table.deletefrom(self.wpn_fps_pis_rsh12.uses_parts, self.nqr.all_optics)
    table.addto(self.wpn_fps_pis_rsh12.uses_parts, self.nqr.all_bxs_bbp)

    self.parts.wpn_fps_pis_model3_b_long.stats = { concealment = 0, weight = 0, barrel_length = 9 } --roughly
    self.parts.wpn_fps_pis_model3_b_short.stats = { concealment = 0, weight = 0, barrel_length = 4 } --roughly
    self.parts.wpn_fps_pis_model3_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 6.5 }
    self.parts.wpn_fps_pis_model3_body_standard.stats = { concealment = 0, length = 6, weight = 0 }
    self.parts.wpn_fps_pis_model3_m_body = deep_clone(self.parts.wpn_fps_pis_model3_cylinder)
    self.parts.wpn_fps_pis_model3_m_body.type = "upper_reciever2"
    self.parts.wpn_fps_pis_model3_m_body.stats = {}
    self.parts.wpn_fps_pis_model3_cylinder.adds = { "wpn_fps_pis_model3_m_body" }
    self.parts.wpn_fps_pis_model3_cylinder.stats = { concealment = 3, weight = 1, mag_amount = { 4, 6, 8 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_pis_model3_m_bullets.stats = {}
    self.parts.wpn_fps_pis_model3_dh_hammer.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_model3_ejector.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_model3_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_model3_g_standard.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_pis_peacemaker_b_standard.type = "barrel"
    self.parts.wpn_fps_pis_peacemaker_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 7 } --roughly
    self.parts.wpn_fps_pis_peacemaker_b_short.type = "barrel"
    self.parts.wpn_fps_pis_peacemaker_b_short.stats = { concealment = 0, weight = 0, barrel_length = 4.6 }
    self.parts.wpn_fps_pis_peacemaker_b_long.type = "barrel"
    self.parts.wpn_fps_pis_peacemaker_b_long.stats = { concealment = 0, weight = 0, barrel_length = 12 }
    self.parts.wpn_fps_pis_peacemaker_body_standard.stats = { concealment = 0, weight = 0, length = 6 }
    self.parts.wpn_fps_pis_peacemaker_g_bling.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_peacemaker_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_pis_peacemaker_m_standard.stats = { concealment = 0, weight = 0, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_pis_peacemaker_s_skeletal.stats = { concealment = 0, weight = 0, shouldered = true }
    table.delete(self.wpn_fps_pis_peacemaker.uses_parts, "wpn_fps_pis_peacemaker_s_skeletal")
    table.addto(self.wpn_fps_pis_peacemaker.uses_parts, self.nqr.all_mds1)



----AKIMBO
    self.wpn_fps_pis_x_g17.adds = deep_clone(self.wpn_fps_pis_g17.adds or {})
    self.wpn_fps_pis_x_g17.default_blueprint = deep_clone(self.wpn_fps_pis_g17.default_blueprint)
    self.wpn_fps_pis_x_g17.uses_parts = deep_clone(self.wpn_fps_pis_g17.uses_parts)

    self.wpn_fps_pis_x_g18c.adds = deep_clone(self.wpn_fps_pis_g18c.adds or {})
    self.wpn_fps_pis_x_g18c.default_blueprint = deep_clone(self.wpn_fps_pis_g18c.default_blueprint)
    self.wpn_fps_pis_x_g18c.uses_parts = deep_clone(self.wpn_fps_pis_g18c.uses_parts)

    self.wpn_fps_pis_x_g22c.adds = deep_clone(self.wpn_fps_pis_g22c.adds or {})
    self.wpn_fps_pis_x_g22c.default_blueprint = deep_clone(self.wpn_fps_pis_g22c.default_blueprint)
    self.wpn_fps_pis_x_g22c.uses_parts = deep_clone(self.wpn_fps_pis_g22c.uses_parts)

    self.wpn_fps_jowi.adds = deep_clone(self.wpn_fps_pis_g26.adds or {})
    self.wpn_fps_jowi.default_blueprint = deep_clone(self.wpn_fps_pis_g26.default_blueprint)
    self.wpn_fps_jowi.uses_parts = deep_clone(self.wpn_fps_pis_g26.uses_parts)

    self.wpn_fps_x_1911.adds = deep_clone(self.wpn_fps_pis_1911.adds or {})
    self.wpn_fps_x_1911.default_blueprint = deep_clone(self.wpn_fps_pis_1911.default_blueprint)
    self.wpn_fps_x_1911.uses_parts = deep_clone(self.wpn_fps_pis_1911.uses_parts)

    self.wpn_fps_pis_x_beer.adds = deep_clone(self.wpn_fps_pis_beer.adds or {})
    self.wpn_fps_pis_x_beer.default_blueprint = deep_clone(self.wpn_fps_pis_beer.default_blueprint)
    self.wpn_fps_pis_x_beer.uses_parts = deep_clone(self.wpn_fps_pis_beer.uses_parts)

    self.wpn_fps_x_b92fs.adds = deep_clone(self.wpn_fps_pis_beretta.adds or {})
    self.wpn_fps_x_b92fs.default_blueprint = deep_clone(self.wpn_fps_pis_beretta.default_blueprint)
    self.wpn_fps_x_b92fs.uses_parts = deep_clone(self.wpn_fps_pis_beretta.uses_parts)

    self.wpn_fps_pis_x_breech.adds = deep_clone(self.wpn_fps_pis_breech.adds or {})
    self.wpn_fps_pis_x_breech.default_blueprint = deep_clone(self.wpn_fps_pis_breech.default_blueprint)
    self.wpn_fps_pis_x_breech.uses_parts = deep_clone(self.wpn_fps_pis_breech.uses_parts)

    self.wpn_fps_pis_x_c96.adds = deep_clone(self.wpn_fps_pis_c96.adds or {})
    self.wpn_fps_pis_x_c96.default_blueprint = deep_clone(self.wpn_fps_pis_c96.default_blueprint)
    self.wpn_fps_pis_x_c96.uses_parts = deep_clone(self.wpn_fps_pis_c96.uses_parts)

    self.wpn_fps_pis_x_czech.adds = deep_clone(self.wpn_fps_pis_czech.adds or {})
    self.wpn_fps_pis_x_czech.default_blueprint = deep_clone(self.wpn_fps_pis_czech.default_blueprint)
    self.wpn_fps_pis_x_czech.uses_parts = deep_clone(self.wpn_fps_pis_czech.uses_parts)

    self.wpn_fps_x_deagle.override = {
        wpn_fps_pis_deagle_m_standard = {
            animations = {
                reload_not_empty = "reload_not_empty_right",
                reload = "reload_right",
                reload_left = "reload_left",
                reload_not_empty_left = "reload_not_empty_left"
            }
        },
        wpn_fps_pis_deagle_m_extended = {
            animations = {
                reload_not_empty = "reload_not_empty_right",
                reload = "reload_right",
                reload_left = "reload_left",
                reload_not_empty_left = "reload_not_empty_left"
            }
        },
        wpn_fps_pis_deagle_body_standard = {
            animations = {
                reload_left = "reload_left",
                fire = "recoil",
                fire_steelsight = "recoil",
                reload = "reload_right",
                --magazine_empty = "last_recoil"
            }
        },



        wpn_upg_o_marksmansight_rear = { a_obj = "a_o",
            forbids = table.list_add(self.parts.wpn_upg_o_marksmansight_rear.forbids, {
                "wpn_fps_pis_deagle_o_standard_front", "wpn_fps_pis_deagle_o_standard_front_long", "wpn_fps_pis_deagle_o_standard_rear"
            })
        },
        wpn_upg_o_marksmansight_front = { a_obj = "a_os" },

        wpn_fps_upg_o_rmr = { parent = "lower_reciever" },
        wpn_fps_upg_o_rms = { parent = "lower_reciever" },
        wpn_fps_upg_o_rikt = { parent = "lower_reciever" },

        wpn_fps_upg_o_aimpoint = { a_obj = "a_os" },
        wpn_fps_upg_o_aimpoint_2 = { a_obj = "a_os" },
        wpn_fps_upg_o_docter = { a_obj = "a_os" },
        wpn_fps_upg_o_eotech = { a_obj = "a_os" },
        wpn_fps_upg_o_eotech_xps = { a_obj = "a_os" },
        wpn_fps_upg_o_t1micro = { a_obj = "a_os" },
        wpn_fps_upg_o_rx30 = { a_obj = "a_os" },
        wpn_fps_upg_o_rx01 = { a_obj = "a_os" },
        wpn_fps_upg_o_reflex = { a_obj = "a_os" },
        wpn_fps_upg_o_cmore = { a_obj = "a_os" },
        wpn_fps_upg_o_tf90 = { a_obj = "a_os" },
        wpn_fps_upg_o_cs = { a_obj = "a_os" },
        wpn_fps_upg_o_uh = { a_obj = "a_os" },
        wpn_fps_upg_o_fc1 = { a_obj = "a_os" },
        wpn_fps_pis_c96_sight = { a_obj = "a_os" },

        wpn_fps_smg_hajk_vg_moe = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_smg_schakal_vg_surefire = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets", "wpn_fps_smg_schakal_vg_surefire_flashlight" } },
        wpn_fps_upg_vg_ass_smg_verticalgrip = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_upg_vg_ass_smg_stubby = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_upg_vg_ass_smg_afg = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_snp_tti_vg_standard = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_ass_tecci_vg_standard = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },
        wpn_fps_smg_polymer_fg_standard = { a_obj = "a_fl", adds = { "wpn_fps_vertical_grip_lock_gadgets" } },

        wpn_fps_upg_fl_pis_laser = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_pis_tlr1 = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_pis_perst = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_pis_crimson = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_pis_x400v = { adds = { "wpn_fps_gadgets_lock_vertical_grip", "wpn_fps_upg_fl_ass_peq15_flashlight" } },
        wpn_fps_upg_fl_pis_m3x = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },

        wpn_fps_upg_fl_ass_smg_sho_peqbox = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_ass_smg_sho_surefire = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_ass_peq15 = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_ass_laser = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_dbal_laser = { adds = { "wpn_fps_gadgets_lock_vertical_grip" } },
        wpn_fps_upg_fl_ass_utg = { adds = { "wpn_fps_gadgets_lock_vertical_grip", "wpn_fps_upg_fl_ass_peq15_flashlight" } },
    }
    self.wpn_fps_x_deagle.adds = deep_clone(self.wpn_fps_pis_deagle.adds or {})
    self.wpn_fps_x_deagle.default_blueprint = deep_clone(self.wpn_fps_pis_deagle.default_blueprint)
    self.wpn_fps_x_deagle.uses_parts = deep_clone(self.wpn_fps_pis_deagle.uses_parts)

    self.wpn_fps_pis_x_holt.adds = deep_clone(self.wpn_fps_pis_holt.adds or {})
    self.wpn_fps_pis_x_holt.default_blueprint = deep_clone(self.wpn_fps_pis_holt.default_blueprint)
    self.wpn_fps_pis_x_holt.uses_parts = deep_clone(self.wpn_fps_pis_holt.uses_parts)

    self.wpn_fps_pis_x_hs2000.adds = deep_clone(self.wpn_fps_pis_hs2000.adds or {})
    self.wpn_fps_pis_x_hs2000.default_blueprint = deep_clone(self.wpn_fps_pis_hs2000.default_blueprint)
    self.wpn_fps_pis_x_hs2000.uses_parts = deep_clone(self.wpn_fps_pis_hs2000.uses_parts)

    self.wpn_fps_pis_x_legacy.adds = deep_clone(self.wpn_fps_pis_legacy.adds or {})
    self.wpn_fps_pis_x_legacy.default_blueprint = deep_clone(self.wpn_fps_pis_legacy.default_blueprint)
    self.wpn_fps_pis_x_legacy.uses_parts = deep_clone(self.wpn_fps_pis_legacy.uses_parts)

    self.wpn_fps_pis_x_m1911.adds = deep_clone(self.wpn_fps_pis_m1911.adds or {})
    self.wpn_fps_pis_x_m1911.default_blueprint = deep_clone(self.wpn_fps_pis_m1911.default_blueprint)
    self.wpn_fps_pis_x_m1911.uses_parts = deep_clone(self.wpn_fps_pis_m1911.uses_parts)

    self.wpn_fps_pis_x_maxim9.adds = deep_clone(self.wpn_fps_pis_maxim9.adds or {})
    self.wpn_fps_pis_x_maxim9.default_blueprint = deep_clone(self.wpn_fps_pis_maxim9.default_blueprint)
    self.wpn_fps_pis_x_maxim9.uses_parts = deep_clone(self.wpn_fps_pis_maxim9.uses_parts)

    self.wpn_fps_pis_x_p226.adds = deep_clone(self.wpn_fps_pis_p226.adds or {})
    self.wpn_fps_pis_x_p226.default_blueprint = deep_clone(self.wpn_fps_pis_p226.default_blueprint)
    self.wpn_fps_pis_x_p226.uses_parts = deep_clone(self.wpn_fps_pis_p226.uses_parts)

    self.wpn_fps_x_packrat.adds = deep_clone(self.wpn_fps_pis_packrat.adds or {})
    self.wpn_fps_x_packrat.default_blueprint = deep_clone(self.wpn_fps_pis_packrat.default_blueprint)
    self.wpn_fps_x_packrat.uses_parts = deep_clone(self.wpn_fps_pis_packrat.uses_parts)

    self.wpn_fps_pis_x_pl14.adds = deep_clone(self.wpn_fps_pis_pl14.adds or {})
    self.wpn_fps_pis_x_pl14.default_blueprint = deep_clone(self.wpn_fps_pis_pl14.default_blueprint)
    self.wpn_fps_pis_x_pl14.uses_parts = deep_clone(self.wpn_fps_pis_pl14.uses_parts)

    self.wpn_fps_pis_x_ppk.adds = deep_clone(self.wpn_fps_pis_ppk.adds or {})
    self.wpn_fps_pis_x_ppk.default_blueprint = deep_clone(self.wpn_fps_pis_ppk.default_blueprint)
    self.wpn_fps_pis_x_ppk.uses_parts = deep_clone(self.wpn_fps_pis_ppk.uses_parts)

    self.wpn_fps_pis_x_shrew.adds = deep_clone(self.wpn_fps_pis_shrew.adds or {})
    self.wpn_fps_pis_x_shrew.default_blueprint = deep_clone(self.wpn_fps_pis_shrew.default_blueprint)
    self.wpn_fps_pis_x_shrew.uses_parts = deep_clone(self.wpn_fps_pis_shrew.uses_parts)

    self.wpn_fps_pis_x_sparrow.adds = deep_clone(self.wpn_fps_pis_sparrow.adds or {})
    self.wpn_fps_pis_x_sparrow.default_blueprint = deep_clone(self.wpn_fps_pis_sparrow.default_blueprint)
    self.wpn_fps_pis_x_sparrow.uses_parts = deep_clone(self.wpn_fps_pis_sparrow.uses_parts)

    self.wpn_fps_pis_x_stech.adds = deep_clone(self.wpn_fps_pis_stech.adds or {})
    self.wpn_fps_pis_x_stech.default_blueprint = deep_clone(self.wpn_fps_pis_stech.default_blueprint)
    self.wpn_fps_pis_x_stech.uses_parts = deep_clone(self.wpn_fps_pis_stech.uses_parts)

    self.wpn_fps_pis_x_type54.adds = deep_clone(self.wpn_fps_pis_type54.adds or {})
    self.wpn_fps_pis_x_type54.default_blueprint = deep_clone(self.wpn_fps_pis_type54.default_blueprint)
    self.wpn_fps_pis_x_type54.uses_parts = deep_clone(self.wpn_fps_pis_type54.uses_parts)

    self.wpn_fps_pis_x_usp.adds = deep_clone(self.wpn_fps_pis_usp.adds or {})
    self.wpn_fps_pis_x_usp.default_blueprint = deep_clone(self.wpn_fps_pis_usp.default_blueprint)
    self.wpn_fps_pis_x_usp.uses_parts = deep_clone(self.wpn_fps_pis_usp.uses_parts)

    self.wpn_fps_smg_x_mac10.adds = deep_clone(self.wpn_fps_smg_mac10.adds or {})
    self.wpn_fps_smg_x_mac10.default_blueprint = deep_clone(self.wpn_fps_smg_mac10.default_blueprint)
    self.wpn_fps_smg_x_mac10.uses_parts = deep_clone(self.wpn_fps_smg_mac10.uses_parts)
    table.swap(self.wpn_fps_smg_x_mac10.default_blueprint, "wpn_fps_smg_mac10_s_fold", "wpn_fps_remove_s")

    self.wpn_fps_smg_x_pm9.adds = deep_clone(self.wpn_fps_smg_pm9.adds or {})
    self.wpn_fps_smg_x_pm9.default_blueprint = deep_clone(self.wpn_fps_smg_pm9.default_blueprint)
    self.wpn_fps_smg_x_pm9.uses_parts = deep_clone(self.wpn_fps_smg_pm9.uses_parts)

    self.wpn_fps_smg_x_scorpion.adds = deep_clone(self.wpn_fps_smg_scorpion.adds or {})
    self.wpn_fps_smg_x_scorpion.default_blueprint = deep_clone(self.wpn_fps_smg_scorpion.default_blueprint)
    self.wpn_fps_smg_x_scorpion.uses_parts = deep_clone(self.wpn_fps_smg_scorpion.uses_parts)
    table.delete(self.wpn_fps_smg_x_scorpion.uses_parts, "wpn_fps_smg_scorpion_s_unfolded")

    self.wpn_fps_smg_x_baka.adds = deep_clone(self.wpn_fps_smg_baka.adds or {})
    self.wpn_fps_smg_x_baka.default_blueprint = deep_clone(self.wpn_fps_smg_baka.default_blueprint)
    self.wpn_fps_smg_x_baka.uses_parts = deep_clone(self.wpn_fps_smg_baka.uses_parts)
    table.delete(self.wpn_fps_smg_x_baka.uses_parts, "wpn_fps_smg_baka_s_unfolded")

    self.wpn_fps_smg_x_mp9.adds = deep_clone(self.wpn_fps_smg_mp9.adds or {})
    self.wpn_fps_smg_x_mp9.default_blueprint = deep_clone(self.wpn_fps_smg_mp9.default_blueprint)
    self.wpn_fps_smg_x_mp9.uses_parts = deep_clone(self.wpn_fps_smg_mp9.uses_parts)
    table.swap(self.wpn_fps_smg_x_mp9.default_blueprint, "wpn_fps_smg_mp9_s_fold", "wpn_fps_remove_s")
    table.insert(self.wpn_fps_smg_x_mp9.uses_parts, "wpn_fps_remove_vg")

    self.wpn_fps_smg_x_tec9.adds = deep_clone(self.wpn_fps_smg_tec9.adds or {})
    self.wpn_fps_smg_x_tec9.default_blueprint = deep_clone(self.wpn_fps_smg_tec9.default_blueprint)
    self.wpn_fps_smg_x_tec9.uses_parts = deep_clone(self.wpn_fps_smg_tec9.uses_parts)
    table.delete(self.wpn_fps_smg_x_tec9.uses_parts, "wpn_fps_smg_tec9_s_unfolded")

    self.wpn_fps_smg_x_cobray.adds = deep_clone(self.wpn_fps_smg_cobray.adds or {})
    self.wpn_fps_smg_x_cobray.default_blueprint = deep_clone(self.wpn_fps_smg_cobray.default_blueprint)
    self.wpn_fps_smg_x_cobray.uses_parts = deep_clone(self.wpn_fps_smg_cobray.uses_parts)
    table.swap(self.wpn_fps_smg_x_cobray.default_blueprint, "wpn_fps_smg_cobray_s_standard", "wpn_fps_remove_s")

    self.wpn_fps_smg_x_sr2.adds = deep_clone(self.wpn_fps_smg_sr2.adds or {})
    self.wpn_fps_smg_x_sr2.default_blueprint = deep_clone(self.wpn_fps_smg_sr2.default_blueprint)
    self.wpn_fps_smg_x_sr2.uses_parts = deep_clone(self.wpn_fps_smg_sr2.uses_parts)
    table.delete(self.wpn_fps_smg_x_sr2.uses_parts, "wpn_fps_smg_sr2_s_unfolded")
    table.insert(self.wpn_fps_smg_x_sr2.uses_parts, "wpn_fps_remove_vg")

    self.wpn_fps_pis_x_rage.adds = deep_clone(self.wpn_fps_pis_rage.adds or {})
    self.wpn_fps_pis_x_rage.default_blueprint = deep_clone(self.wpn_fps_pis_rage.default_blueprint)
    self.wpn_fps_pis_x_rage.uses_parts = deep_clone(self.wpn_fps_pis_rage.uses_parts)

    self.wpn_fps_pis_x_korth.adds = deep_clone(self.wpn_fps_pis_korth.adds or {})
    self.wpn_fps_pis_x_korth.default_blueprint = deep_clone(self.wpn_fps_pis_korth.default_blueprint)
    self.wpn_fps_pis_x_korth.uses_parts = deep_clone(self.wpn_fps_pis_korth.uses_parts)

    self.wpn_fps_pis_x_chinchilla.adds = deep_clone(self.wpn_fps_pis_chinchilla.adds or {})
    self.wpn_fps_pis_x_chinchilla.default_blueprint = deep_clone(self.wpn_fps_pis_chinchilla.default_blueprint)
    self.wpn_fps_pis_x_chinchilla.uses_parts = deep_clone(self.wpn_fps_pis_chinchilla.uses_parts)

    self.wpn_fps_pis_x_model3.adds = deep_clone(self.wpn_fps_pis_model3.adds or {})
    self.wpn_fps_pis_x_model3.default_blueprint = deep_clone(self.wpn_fps_pis_model3.default_blueprint)
    self.wpn_fps_pis_x_model3.uses_parts = deep_clone(self.wpn_fps_pis_model3.uses_parts)

    self.wpn_fps_pis_x_2006m.adds = deep_clone(self.wpn_fps_pis_2006m.adds or {})
	self.wpn_fps_pis_x_2006m.override  = deep_clone(self.wpn_fps_pis_2006m.override or {})
    self.wpn_fps_pis_x_2006m.default_blueprint = deep_clone(self.wpn_fps_pis_2006m.default_blueprint)
    self.wpn_fps_pis_x_2006m.uses_parts = deep_clone(self.wpn_fps_pis_2006m.uses_parts)

    self.wpn_fps_pis_x_judge.adds = deep_clone(self.wpn_fps_pis_judge.adds or {})
	self.wpn_fps_pis_x_judge.override  = deep_clone(self.wpn_fps_pis_judge.override or {})
    self.wpn_fps_pis_x_judge.default_blueprint = deep_clone(self.wpn_fps_pis_judge.default_blueprint)
    self.wpn_fps_pis_x_judge.uses_parts = deep_clone(self.wpn_fps_pis_judge.uses_parts)

    local custom_weps = {
        rsh12 = { "wpn_fps_pis_x_rsh12", "wpn_fps_pis_rsh12" },
        lemming = { "wpn_fps_pis_x_lemming", "wpn_fps_pis_lemming" },
        fmg9 = { "wpn_fps_smg_x_fmg9", "wpn_fps_smg_fmg9" },
    }
    for i, k in pairs(custom_weps) do
        if self[ k[1] ] then
            self[ k[1] ].adds = deep_clone(self[ k[2] ].adds or {})
            self[ k[1] ].default_blueprint = deep_clone(self[ k[2] ].default_blueprint)
            self[ k[1] ].uses_parts = deep_clone(self[ k[2] ].uses_parts)
        end
    end

    for i, k in pairs(self) do
        if k.override then
            for o, l in pairs(k.override) do
                if l.stats and l.stats.extra_ammo then self[i].override[o].stats = nil end
            end
        end
    end
    --



----SPECIAL
    --table.remove(self.wpn_fps_lmg_m134.default_blueprint, "wpn_fps_lmg_m134_body_upper") --todo
    self.parts.wpn_fps_lmg_m134_barrel_short.stats = { concealment = 0, weight = 18, barrel_length = 7 }
    self.parts.wpn_fps_lmg_m134_barrel.stats = { concealment = 0, weight = 66, barrel_length = 22 }
    self.parts.wpn_fps_lmg_m134_barrel_extreme.stats = { concealment = 0, weight = 0, barrel_length = 22 }
    self.parts.wpn_fps_lmg_m134_barrel_legendary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m134_body.stats = { concealment = 0, weight = 0, length = 12 }
    self.parts.wpn_fps_lmg_m134_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m134_body_upper_light.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m134_body_upper_spikey.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_lmg_m134_m_standard.stats = { concealment = 0, weight = 0, mag_amount = { 1, 1, 1 }, CLIP_AMMO_MAX = 1000 }

    self.parts.wpn_fps_bow_arblast_b_steel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_arblast_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_arblast_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_arblast_m_explosive.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_arblast_m_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_arblast_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_b_dummy.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_body_lower.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_bow_ecp_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_ejector_left.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_ejector_right.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_m_arrows.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_m_arrows_explosive.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_m_arrows_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_m_arrows_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_m_casing.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_meter_left.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_meter_right.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_o_iron.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_ecp_s_bare.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_bow_ecp_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_bow_elastic_body_regular.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_body_tactic.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_bow.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_g_1.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_g_2.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_g_3.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_m_explosive.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_m_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_pin.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_rail.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_sight.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_elastic_whisker.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_b_steel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_m_explosive.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_m_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_frankish_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_b_carbon.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_b_skeletal.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_body_standard.stats = { concealment = 0, weight = 0, length = 12 }
    self.parts.wpn_fps_bow_hunter_g_camo.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_g_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_g_walnut.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_hunter_o_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_long_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_long_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_long_m_explosive.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_long_m_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_long_m_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_plainsrider_b_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_plainsrider_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_bow_plainsrider_m_standard.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_fla_mk2_body.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_fla_mk2_body_fierybeast.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_fla_mk2_empty.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_fla_mk2_mag.stats = { concealment = 35, weight = 20, mag_amount = { 1, 1, 1 } }
    self.parts.wpn_fps_fla_mk2_mag_rare.stats = { concealment = 35, weight = 20, mag_amount = { 1, 1, 1 } }
    self.parts.wpn_fps_fla_mk2_mag_welldone.stats = { concealment = 35, weight = 20, mag_amount = { 1, 1, 1 } }

    self.parts.wpn_fps_fla_system_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_fla_system_b_wtf.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_fla_system_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_fla_system_body_upper.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_fla_system_dh_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_fla_system_m_high.stats = { concealment = 27, weight = 15, mag_amount = { 1, 1, 1 } }
    self.parts.wpn_fps_fla_system_m_low.stats = { concealment = 27, weight = 15, mag_amount = { 1, 1, 1 } }
    self.parts.wpn_fps_fla_system_m_standard.stats = { concealment = 27, weight = 15, mag_amount = { 1, 1, 1 } }

    self.parts.wpn_fps_gre_arbiter_b_comp.stats = { concealment = 0, weight = 0, barrel_length = 0, md_code = {0,0,0,3,0} }
    self.parts.wpn_fps_gre_arbiter_b_long.stats = { concealment = 0, weight = 0, barrel_length = 0 }
    self.parts.wpn_fps_gre_arbiter_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 16 }
    self.parts.wpn_fps_gre_arbiter_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_arbiter_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_arbiter_charginghandle.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_arbiter_ejector.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_arbiter_m_standard.stats = { concealment = 12, weight = 3, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 5 }
    self.parts.wpn_fps_gre_arbiter_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_gre_arbiter_o_standard.forbids, table.without(self.nqr.all_sights, self.nqr.all_angled_sights))
    self.parts.wpn_fps_gre_arbiter_o_standard.stats = { concealment = 2, weight = 1 }
    self.parts.wpn_fps_gre_arbiter_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }
    table.swap(self.wpn_fps_gre_arbiter.default_blueprint, "wpn_fps_gre_arbiter_o_standard", "wpn_fps_gre_ms3gl_o_standard")
    table.insert(self.wpn_fps_gre_arbiter.uses_parts, "wpn_fps_gre_ms3gl_o_standard")

    self.parts.wpn_fps_gre_china_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 14.5 }
    self.parts.wpn_fps_gre_china_casing = deep_clone(self.parts.wpn_fps_gre_china_body_standard)
    self.parts.wpn_fps_gre_china_casing.type = "casing"
    self.parts.wpn_fps_gre_china_casing.visibility = { { objects = { g_carrier = false, g_feed = false, g_bolt = false, g_lower = false, g_upper = false } } }
    self.parts.wpn_fps_gre_china_casing.stats = {}
    self.parts.wpn_fps_gre_china_body_standard.adds = { "wpn_fps_gre_china_casing" }
    self.parts.wpn_fps_gre_china_body_standard.visibility = { { objects = { g_nade_empty = false } } }
    self.parts.wpn_fps_gre_china_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_china_fg_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_china_m_standard.stats = { concealment = 0, weight = 0, mag_amount = { 6, 9, 12 } }
    self.parts.wpn_fps_gre_china_s_short.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_gre_china_s_standard.stats = { concealment = 0, weight = 0, shouldered = true }

    self.parts.wpn_fps_gre_m32_barrel.stats = { concealment = 0, weight = 0, barrel_length = 11.8 }
    self.parts.wpn_fps_gre_m32_barrel_short.stats = { concealment = 0, weight = 0, barrel_length = 7.9 }
    self.parts.wpn_fps_gre_m32_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_m32_lower_reciever.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_m32_mag.stats = { concealment = 0, weight = 0, mag_amount = { 6, 9, 12 }, CLIP_AMMO_MAX = 6 }
    self.parts.wpn_fps_gre_m32_no_stock.pcs = nil
    --self.parts.wpn_fps_gre_m32_no_stock.name_id = self.parts.wpn_fps_remove_s.name_id
    --self.parts.wpn_fps_gre_m32_no_stock.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_m32_stock_adapter.type = "stock"
    self.parts.wpn_fps_gre_m32_stock_adapter.stats = { concealment = 0, weight = 3 }
    self.parts.wpn_fps_gre_m32_upper_reciever.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_gre_m32.override = {
        wpn_fps_remove_s = {
            has_description = true, --todo
            desc_id = "bm_wp_stock_adapter_remove_desc",
        },
    }
    table.deletefrom(self.wpn_fps_gre_m32.uses_parts, self.nqr.all_snoptics)
    table.insert(self.wpn_fps_gre_m32.default_blueprint, "wpn_fps_gre_ms3gl_o_standard")
    table.insert(self.wpn_fps_gre_m32.uses_parts, "wpn_fps_gre_ms3gl_o_standard")
    table.insert(self.wpn_fps_gre_m32.default_blueprint, "wpn_fps_gre_m32_stock_adapter")
    table.insert(self.wpn_fps_gre_m32.uses_parts, "wpn_fps_remove_s_addon")
    table.insert(self.wpn_fps_gre_m32.uses_parts, "wpn_fps_remove_s")
    table.addto(self.wpn_fps_gre_m32.uses_parts, self.nqr.all_angled_sights)
    table.addto(self.wpn_fps_gre_m32.uses_parts, self.nqr.all_tube_stocks)

    self.parts.wpn_fps_gre_m79_barrel.stats = { concealment = 0, weight = 0, barrel_length = 14.5 }
    self.parts.wpn_fps_gre_m79_barrel_short.stats = { concealment = 0, weight = 0, barrel_length = 8 }
    self.parts.wpn_fps_gre_m79_barrelcatch.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_m79_grenade.stats = { concealment = 0, weight = 0, mag_amount = { 6, 9, 12 } }
    self.parts.wpn_fps_gre_m79_grenade_whole.stats = { concealment = 0, weight = 0, mag_amount = { 6, 9, 12 } }
    self.parts.wpn_fps_gre_m79_sight_up.stats = { concealment = 0, weight = 0, zoom = 1 }
    self.parts.wpn_fps_gre_m79_stock.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_gre_m79_stock_short.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_gre_ms3gl_b_long.stats = { concealment = 0, weight = 0, barrel_length = 14 }--roughly
    self.parts.wpn_fps_gre_ms3gl_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 10 }
    self.parts.wpn_fps_gre_ms3gl_body_modern.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ms3gl_conversion.stats = { concealment = 0, weight = 0 }
    --self.parts.wpn_fps_gre_ms3gl_conversion_grenade_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ms3gl_grenade.stats = { concealment = 0, weight = 0, mag_amount = { 6, 9, 12 } }
    self.parts.wpn_fps_gre_ms3gl_lower_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ms3gl_o_standard.parent = nil
    self.parts.wpn_fps_gre_ms3gl_o_standard.forbids = {}
    table.addto(self.parts.wpn_fps_gre_ms3gl_o_standard.forbids, self.nqr.all_second_sights)
    self.parts.wpn_fps_gre_ms3gl_o_standard.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_gre_ms3gl_s_modern.stats = { concealment = 0, weight = 2, shouldered = true }
    self.parts.wpn_fps_gre_ms3gl_s_standard.stats = { concealment = 0, weight = 2, shouldered = true }
    self.parts.wpn_fps_gre_ms3gl_upper_standard.stats = { concealment = 0, weight = 0 }
    self.wpn_fps_gre_ms3gl.override = { wpn_fps_gre_ms3gl_o_standard = { parent = "upper_reciever" }, }
    table.addto(self.wpn_fps_gre_ms3gl.uses_parts, self.nqr.all_second_sights)
    table.insert(self.wpn_fps_gre_ms3gl.uses_parts, "wpn_fps_remove_s")

    self.parts.wpn_fps_gre_ray_barrel.stats = { concealment = 0, weight = 0, barrel_length = 27 } --roughly
    self.parts.wpn_fps_gre_ray_body.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_gre_ray_bolt.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ray_magazine.stats = { concealment = 120, weight = 69, mag_amount = { 1, 1, 1 } }
    self.parts.wpn_fps_gre_ray_magazine_handle.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ray_ring_back.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ray_ring_front.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_ray_sight.stats = { concealment = 0, weight = 0, sightpos = {5,0,0} }
    self.parts.wpn_fps_gre_ray_sight_lid.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_gre_slap_b_standard.stats = { concealment = 0, weight = 0, barrel_length = 11, mag_amount = { 6, 9, 12 } }
    self.parts.wpn_fps_gre_slap_body_lower.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_gre_slap_o_adapter.pcs = {}
    self.parts.wpn_fps_gre_slap_o_adapter.type = "extra"
    self.parts.wpn_fps_gre_slap_o_adapter.rails = { "top" }
    self.parts.wpn_fps_gre_slap_o_adapter.override = { wpn_fps_gre_slap_o_iron = { unit = fantom_unit, stats = {} } }
    self.parts.wpn_fps_gre_slap_o_adapter.stats = { concealment = 0, weight = 2, sightpos = {4.3, 3, 3} }
    self.parts.wpn_fps_gre_slap_o_iron.type = "ironsight"
    self.parts.wpn_fps_gre_slap_o_iron.stats = { concealment = 0, weight = 2, sightpos = {4.3, 1.1, 0} }
    self.parts.wpn_fps_gre_slap_s_standard.stats = { concealment = 0, weight = 3, shouldered = true, shoulderable = true }
    self.parts.wpn_fps_gre_slap_vg_standard.stats = { concealment = 0, weight = 1 }
    self.wpn_fps_gre_slap.adds = {}
    table.deletefrom(self.wpn_fps_gre_slap.uses_parts, self.nqr.all_optics)
    table.insert(self.wpn_fps_gre_slap.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_gre_slap.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_gre_slap.default_blueprint, 1, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_gre_slap.uses_parts, "wpn_fps_extra2_lock_gadgets")
    table.insert(self.wpn_fps_gre_slap.uses_parts, "wpn_fps_addon_ris")
    table.insert(self.wpn_fps_gre_slap.uses_parts, "wpn_fps_remove_s")
    table.insert(self.wpn_fps_gre_slap.uses_parts, "wpn_fps_remove_ironsight")

    self.parts.wpn_fps_hailstorm_b_ext_suppressed.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_hailstorm_b_extended.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_hailstorm_b_std.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_hailstorm_b_suppressed.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_hailstorm_body.stats = { concealment = 0, weight = 0, shouldered = true }
    self.parts.wpn_fps_hailstorm_conv_fl.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_conv_fl_2.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_conversion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_fl_flash.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_g_bubble.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_g_crystal.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_g_noise.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_m_std.stats = { concealment = 24, weight = 6, mag_amount = { 1, 2, 3 }, CLIP_AMMO_MAX = 120 }
    self.parts.wpn_fps_hailstorm_o_claymore.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_hailstorm_o_irons.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_rpg7_barrel.stats = { concealment = 0, weight = 0, barrel_length = 1 }
    self.parts.wpn_fps_rpg7_body.stats = { concealment = 0, weight = 0, length = 32, shouldered = true }
    self.parts.wpn_fps_rpg7_m_grinclown.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_rpg7_m_rocket.stats = { concealment = 60, weight = 26, mag_amount = { 1, 2, 3 } }
    self.parts.wpn_fps_rpg7_sight.type = "ironsight"
    self.parts.wpn_fps_rpg7_sight.forbids = { "wpn_fps_smg_coal_o_scopemount_standard" }
    self.parts.wpn_fps_rpg7_sight.stats = { concealment = 0, weight = 2 }
    self.parts.wpn_fps_rpg7_sight_adapter.type = "ironsight"
    self.parts.wpn_fps_rpg7_sight_adapter.pcs = {}
    self.parts.wpn_fps_rpg7_sight_adapter.forbids = { "wpn_fps_smg_coal_o_scopemount_standard" }
    self.parts.wpn_fps_rpg7_sight_adapter.override = { wpn_fps_extra_lock_sights = { forbids = deep_clone(self.nqr.all_optics) } }
    self.parts.wpn_fps_rpg7_sight_adapter.stats = { concealment = 0, weight = 2 }
    self.wpn_fps_rpg7.adds = {}
    self.wpn_fps_rpg7.override = { wpn_fps_smg_coal_o_scopemount_standard = { a_obj = "a_o" }, }
    table.deletefrom(self.wpn_fps_rpg7.uses_parts, self.nqr.all_snoptics)
    table.deletefrom(self.wpn_fps_rpg7.uses_parts, self.nqr.all_magnifiers)
    table.insert(self.wpn_fps_rpg7.default_blueprint, 1, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_rpg7.uses_parts, "wpn_fps_extra_lock_sights")
    table.insert(self.wpn_fps_rpg7.uses_parts, "wpn_fps_rpg7_sight_adapter")
    table.insert(self.wpn_fps_rpg7.uses_parts, "wpn_fps_remove_ironsight")
    table.insert(self.wpn_fps_rpg7.uses_parts, "wpn_fps_smg_coal_o_scopemount_standard")

    self.parts.wpn_fps_saw_b_normal.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_saw_body_silent.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_saw_body_speed.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_saw_body_standard.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_saw_m_blade.stats = { concealment = 0, weight = 0, mag_amount = { 1, 2, 3 } }
    self.parts.wpn_fps_saw_m_blade_durable.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_saw_m_blade_sharp.stats = { concealment = 0, weight = 0 }



----UNSORTED
    self.parts.wpn_fps_upg_a_bow_explosion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_bow_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_crossbow_explosion.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_crossbow_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_explosive.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_electric.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_electric.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_electric_arbiter.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_electric_arbiter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_electric_ms3gl.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_electric_ms3gl.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_incendiary.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_incendiary_arbiter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_incendiary_ms3gl.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_poison.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_poison_arbiter.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_poison_arbiter.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_poison_ms3gl.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_poison_ms3gl.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_piercing_underbarrel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_rip.pcs = nil
    self.parts.wpn_fps_upg_a_slug_underbarrel.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_underbarrel_frag_groza.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_underbarrel_electric.pcs = nil
    self.parts.wpn_fps_upg_a_underbarrel_electric.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_underbarrel_poison.pcs = nil
    self.parts.wpn_fps_upg_a_underbarrel_poison.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_pis_adam.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_grenade_launcher_hornet.pcs = nil
    self.parts.wpn_fps_upg_a_grenade_launcher_hornet.stats = { concealment = 0, weight = 0 }
    self.parts.wpn_fps_upg_a_underbarrel_hornet.pcs = nil
    self.parts.wpn_fps_upg_a_underbarrel_hornet.stats = { concealment = 0, weight = 0 }

    self.parts.wpn_fps_extra_sightheightmod = {
        unit = fantom_unit,
        a_obj = "a_body",
        type = "extra_lock",
        name_id = "bm_wp_extra_sightheightmod",
        adds = {}, forbids = {}, stats = {},
        override = {},
    } for i, k in pairs(self.nqr.all_big_reddots) do
        --self.parts.wpn_fps_extra_sightheightmod.override[k] = { stats = deep_clone(self.parts[k].stats) }
        --self.parts.wpn_fps_extra_sightheightmod.override[k].stats.sightheight = self.parts.wpn_fps_extra_sightheightmod.override[k].stats.sightheight-1.2
    end
----



    local sort_number = 100000
    for i, k in pairs(self.nqr.all_mds) do
        self.parts[k].sort_number = self.parts[k].sort_number or sort_number
        sort_number = sort_number + 1000
    end

    local sort_number = 200000
    for i, k in pairs(self.nqr.all_sps) do
        self.parts[k].sort_number = self.parts[k].sort_number or sort_number
        sort_number = sort_number + 1000
    end

    local sort_number = 10000
    local value = 1
    for i, k in pairs(self.nqr.all_sights) do
        self.parts[k].sort_number = self.parts[k].sort_number or sort_number
        sort_number = sort_number + 1000

        self.parts[k].stats.value = value
        value = value + 1
    end



    for i, k in pairs(self.parts) do
        k.forbids = k.forbids or {}
        k.adds = k.adds or {}
        k.override = k.override or {}
        k.stats = k.stats or {}

        if k.rails then
            local orig_overrides = deep_clone(k.override)

            if table.contains(k.rails, "top") then
                --table.insert(k.forbids, "wpn_fps_ak_extra_ris")

                local is_fg = k.type=="foregrip" or k.type=="f_gasblock"

                for u, j in pairs(self.parts) do
                    if string.find(j.type, "_lock") --[[or string.find(j.type, "_pos")]] then
                        if (string.find(u, "_lock_sights") and not k.needs_sight_pos) --[[or string.find(u, "_o_pos")]] then
                            orig_overrides[u] = orig_overrides[u] or {}
                            orig_overrides[u].forbids = orig_overrides[u].forbids or deep_clone(j.forbids or {})
                            table.deletefrom(orig_overrides[u].forbids, (is_fg and string.find(u, "pos_fg")) and self.nqr.all_optics or self.nqr.all_sights)
                        end
                    end
                end

                --[[for u, j in pairs(self.nqr.all_sightmounts) do
                    self.parts[j].override[i] = self.parts[j].override[i] or {}
                    self.parts[j].override[i].forbids = self.parts[j].override[i].forbids or table.without(k.forbids, { "wpn_fps_extra_lock_sights" })
                end]]

                --if table.contains(self.wpn_fps_ass_74.uses_parts, i) and k.type=="foregrip" then orig_overrides.wpn_fps_remove_gb = { forbids = {} } end
            end

            if table.contains(k.rails, "side") then
                table.addto(k.forbids, self.nqr.all_gadgetrails)

                for u, j in pairs(self.parts) do
                    if string.find(j.type, "_lock") then
                        if string.find(u, "_lock_gadgets") then
                            orig_overrides[u] = orig_overrides[u] or {}
                            orig_overrides[u].forbids = orig_overrides[u].forbids or deep_clone(j.forbids or {})
                            table.deletefrom(orig_overrides[u].forbids, self.nqr.all_gadgets)
                        end
                    end
                end
            end

            if table.contains(k.rails, "bottom") then
                table.addto(k.forbids, {"wpn_nqr_extra3_rail"})

                for u, j in pairs(self.parts) do
                    if string.find(j.type, "_lock") then
                        if string.find(u, "_lock_vertical_grips") then
                            orig_overrides[u] = orig_overrides[u] or {}
                            orig_overrides[u].forbids = orig_overrides[u].forbids or deep_clone(j.forbids)
                            table.deletefrom(orig_overrides[u].forbids, self.nqr.all_vertical_grips)
                        end
                        if string.find(u, "_lock_gadgets") then
                            orig_overrides[u] = orig_overrides[u] or {}
                            orig_overrides[u].forbids = orig_overrides[u].forbids or deep_clone(j.forbids)
                            table.deletefrom(orig_overrides[u].forbids, self.nqr.all_gadgets)
                        end
                        if string.find(u, "_lock_gadgets_and_vertical_grips") then
                            orig_overrides[u] = orig_overrides[u] or {}
                            orig_overrides[u].forbids = orig_overrides[u].forbids or deep_clone(j.forbids)
                            table.deletefrom(orig_overrides[u].forbids, self.nqr.all_gadgets)
                            table.deletefrom(orig_overrides[u].forbids, self.nqr.all_vertical_grips)
                        end
                    end
                end
            end

            k.override = deep_clone(orig_overrides)
        end

        if k.sightpairs then
            for u, j in pairs(k.sightpairs) do
                if self.parts[j] then
                    self.parts[j].sightpairs = self.parts[j].sightpairs or {}
                    table.insert(self.parts[j].sightpairs, i)
                end
            end
        end
    end
    self.parts.wpn_fps_gadgets_pos_a_fl2.override.wpn_fps_snp_tti_fg_standard = {
        forbids = table.without(self.parts.wpn_fps_snp_tti_fg_standard.forbids, { "wpn_fps_addon_ris" }),
        override = table.without(self.parts.wpn_fps_snp_tti_fg_standard.override, { "wpn_fps_foregrip_lock_gadgets" }),
    }
    self.parts.wpn_fps_gadgets_pos_a_fl3.override.wpn_fps_snp_tti_fg_standard = {
        forbids = table.without(self.parts.wpn_fps_snp_tti_fg_standard.forbids, { "wpn_fps_addon_ris" }),
        override = table.without(self.parts.wpn_fps_snp_tti_fg_standard.override, { "wpn_fps_foregrip_lock_gadgets" }),
    }
    self.parts.wpn_fps_gadgets_pos_a_fl2.override.wpn_fps_m4_upg_fg_mk12 = {
        forbids = table.without(self.parts.wpn_fps_m4_upg_fg_mk12.forbids, { "wpn_fps_addon_ris" }),
        override = table.without(self.parts.wpn_fps_m4_upg_fg_mk12.override, { "wpn_fps_foregrip_lock_gadgets" }),
    }
    self.parts.wpn_fps_gadgets_pos_a_fl3.override.wpn_fps_m4_upg_fg_mk12 = {
        forbids = table.without(self.parts.wpn_fps_m4_upg_fg_mk12.forbids, { "wpn_fps_addon_ris" }),
        override = table.without(self.parts.wpn_fps_m4_upg_fg_mk12.override, { "wpn_fps_foregrip_lock_gadgets" }),
    }
    for i, k in pairs(self.parts.wpn_fps_ass_m16_os_frontsight.override) do table.addto(k.forbids, self.parts[i].forbids) end
    for i, k in pairs(self.nqr.all_sightmounts) do
        --self.parts[k].override.wpn_nqr_mngr_o_extra = { adds = {} }
        --self.parts[k].override.wpn_fps_ak_extra_ris = self.parts[k].override.wpn_fps_ak_extra_ris or {}
        --self.parts[k].override.wpn_fps_ak_extra_ris.override = table.without(self.parts.wpn_fps_ak_extra_ris.override, { "wpn_fps_extra_lock_sights" })

        --self.parts[k].override.wpn_fps_extra_lock_sights = { forbids = {} }

        --self.parts[k].override.wpn_fps_ak_extra_ris = self.parts[k].override.wpn_fps_ak_extra_ris or {}
        --self.parts[k].override.wpn_fps_ak_extra_ris.override = table.without(self.parts.wpn_fps_ak_extra_ris.override, { "wpn_fps_extra_lock_sights" })
    end



    local dflt_sights = {}
    for i, k in pairs(self.parts.wpn_fps_upg_o_specter.stance_mod) do
        self[i].sightheight_mod = self[i].sightheight_mod or (height_dflt + k.translation.z)

        local has_sight = nil
        for o, l in pairs(dflt_default_blueprints[i].default_blueprint) do
            if self.parts[l].type=="sight"
            or self.parts[l].type=="ironsight"
            --or self.parts[l].type=="sight_special"
            or self.parts[l].sub_type=="ironsight"
            then
                has_sight = true
                if not (self.parts[l].stats and self.parts[l].stats.zoom) then
                    local stance_mod_crap = 0
                    if self.parts[l].stance_mod and self.parts[l].stance_mod[i] then
                        stance_mod_crap = self.parts[l].stance_mod[i].translation.z or 0
                        self.parts[l].stance_mod = nil
                    end
                    dflt_sights[l] = { stats = { sightheight = self[i].sightheight_mod - stance_mod_crap } }
                end
            end
        end
        if not has_sight then
            local has_upper_reciever = nil
            for o, l in pairs(dflt_default_blueprints[i].default_blueprint) do
                if self.parts[l].type=="upper_reciever" then
                    has_upper_reciever = true
                    dflt_sights[l] = { stats = { sightheight = self[i].sightheight_mod } }
                end
            end
            if not has_upper_reciever then
                for o, l in pairs(dflt_default_blueprints[i].default_blueprint) do
                    if self.parts[l].type=="lower_reciever"
                    or self.parts[l].type=="lower_receiver"
                    or (self.parts[l].type=="stock" and self.parts[l].a_obj=="a_body") then
                        dflt_sights[l] = { stats = { sightheight = self[i].sightheight_mod } }
                    end
                end
            end
        end
    end
    self.wpn_fps_snp_victor.sightheight_mod = self.wpn_fps_ass_m16.sightheight_mod

    for i, k in pairs(self.parts.wpn_fps_upg_o_45rds.stance_mod) do self.parts.wpn_fps_upg_o_45rds.stance_mod[i].translation = Vector3(0, 0, 0) end

    for i, k in pairs(dflt_sights) do
        self.parts[i].stats.sightheight = self.parts[i].stats.sightheight or dflt_sights[i].stats.sightheight
        self.parts[i].sub_type = self.parts[i].sub_type or "ironsight"
    end
    self.parts.wpn_fps_ass_g36_body_standard.stats.sightheight = height_dflt + self.parts.wpn_fps_upg_o_specter.stance_mod.wpn_fps_ass_g36.translation.z
    self.parts.wpn_fps_ass_g36_body_standard.sub_type = "ironsight"
    self.parts.wpn_fps_snp_sbl_body_standard.stats.sightheight = self.parts.wpn_fps_snp_sbl_body_standard.stats.sightheight - self.parts.wpn_fps_snp_sbl_o_standard.stance_mod.wpn_fps_snp_sbl.translation.z
    self.parts.wpn_fps_snp_sbl_o_standard.stance_mod = nil
    self.parts.wpn_fps_sho_saiga_b_short.stats.sightheight = 0
    self.parts.wpn_fps_shot_saiga_b_standard.stats.sightheight = 0



    self.nqr.all_stocks = {}
    self.nqr.all_stock_addons = {}
    for i, k in pairs(self.parts) do
        if k.type=="stock" and not table.contains(self.nqr.all_stock_adapters, i) then
            table.insert(self.nqr.all_stocks, i)
        elseif k.type=="stock_addon" and i~="wpn_fps_remove_s_addon" then
            table.insert(self.nqr.all_stock_addons, i)
        end
    end

    self.nqr.all_piggyback_irons = {}
    for i, k in pairs(table.without(self.nqr.all_sights, {"wpn_fps_o_blank"})) do
        for u, j in pairs(self.parts[k].adds or {}) do
            if self.parts[j].type=="piggyback_iron" then
                table.insert(self.nqr.all_piggyback_irons, j)

                for y, h in pairs(table.with(self.nqr.all_second_sights, self.nqr.all_piggyback_sights)) do
                    table.insert(self.parts[h].forbids, j)
                end
            end
        end
    end

    --TO ALL PARTS
    for i, k in pairs(self.parts) do
        k.forbids = k.forbids or {}
        k.adds = k.adds or {}
        k.override = k.override or {}

        if k.material_parameters and k.material_parameters.gfx_reddot and k.material_parameters.gfx_reddot[1] then
            k.material_parameters.gfx_reddot[1].value = Vector3(0.2, 2, 15)
            table.insert(k.material_parameters.gfx_reddot, { id = Idstring("holo_target_offset"), value = Vector3(0, 1000, 0) })
            k.material_parameters.gfx_reddot1 = deep_clone(k.material_parameters.gfx_reddot)
            k.material_parameters.sight = deep_clone(k.material_parameters.gfx_reddot)
        end

        if k.type=="sight" and not k.blank_sight then
            if not k.piggyback_height then
                table.addto(k.forbids, self.nqr.all_piggyback_sights)
            elseif k.stats.sightheight then
                for u, j in pairs(self.nqr.all_piggyback_sights) do
                    k.override[j] = { parent = "sight", stats = table.copy_append(self.parts[j].stats, { sightheight = k.piggyback_height + self.parts[j].stats.sightheight }) }
                end
            end
        end
        if k.type=="sight" and i~="wpn_fps_upg_o_spot" then table.insert(k.forbids, "wpn_fps_upg_o_spot_rangefinder") end

        if table.contains(self.nqr.all_stocks, i) then
            table.addto(self.parts[i].forbids, self.nqr.all_tube_stocks)
        end

        --if string.find(k.type, "extra") then k.type = "g_"..(string.sub(k.type, 2)) end

        if k.is_a_unlockable then k.stats.value = 0 end

        if k.stats.shoulderable then k.has_description = true k.desc_id = k.desc_id or "bm_wp_stock_foldable_desc" end
    end

    for i, k in pairs(self) do
        if k.default_blueprint then
            k.override = k.override or {}

            for o, l in pairs(k.default_blueprint) do
                --if self.parts[l].type=="ironsight" then table.insert(k.uses_parts, "wpn_fps_remove_ironsight") break end
            end

            local has_default_buffer_tube = nil
            for u, j in pairs(k.default_blueprint) do
                if table.contains(self.nqr.all_stock_adapters, j) then has_default_buffer_tube = true break end
            end
            if has_default_buffer_tube then
                for u, j in pairs(self.nqr.all_tube_stocks) do
                    --k.override[u] = { forbids = deep_clone(self.parts[u] and self.parts[u].forbids or {}) }
                    local stock_forbids = deep_clone(self.parts[j] and self.parts[j].forbids or {})
                    table.addto(stock_forbids, self.nqr.all_stocks)
                    k.override[j] = { forbids = stock_forbids }
                end

                for u, j in pairs(self.nqr.all_stocks) do
                    local stock_forbids = deep_clone(self.parts[j] and self.parts[j].forbids or {})
                    table.deletefrom(stock_forbids, self.nqr.all_tube_stocks)
                    k.override[j] = { forbids = stock_forbids }
                end
            end

            if table.contains(k.uses_parts, "wpn_fps_upg_o_atibal") and not table.contains(k.uses_parts, "wpn_fps_upg_o_atibal_reddot") then
                table.insert(k.uses_parts, "wpn_fps_upg_o_atibal_reddot")
            end
            if table.contains(k.uses_parts, "wpn_fps_upg_o_northtac") and not table.contains(k.uses_parts, "wpn_fps_upg_o_northtac_reddot") then
                table.insert(k.uses_parts, "wpn_fps_upg_o_northtac_reddot")
            end
            if table.contains(k.uses_parts, "wpn_fps_upg_o_spot") and not table.contains(k.uses_parts, "wpn_fps_upg_o_spot_rangefinder") then
                table.insert(k.uses_parts, "wpn_fps_upg_o_spot_rangefinder")
            end
            if table.contains(k.uses_parts, "wpn_fps_upg_o_t1micro") and not table.contains(k.uses_parts, "wpn_fps_upg_o_northtac_reddot") then
                table.addto(k.uses_parts, self.nqr.all_piggyback_sights)
            end
        end
    end



    for i, k in pairs(ak_foregrips) do
        if k~="wpn_fps_upg_ak_fg_zenitco" then table.addto(self.parts[k].forbids, { "wpn_fps_upg_ak_body_upperreceiver_zenitco" }) end
    end
    for i, k in pairs(table.combine(ak_foregrips_full, saiga_foregrips_full, akmsu_foregrips_full)) do
        self.parts[k].override.wpn_upg_ak_gb_standard = { unit = fantom_unit, forbids = {}, stats = {}, } --every full ak/saiga foregrip "removes" default ak gasblock
        if not table.contains(saiga_foregrips_full, k) then table.insert(self.parts[k].forbids, "wpn_upg_ak_fg_combo2") end

        if not table.contains(self.parts[k].rails or {}, "top") then
            --table.addto(self.parts[k].forbids, {"wpn_fps_o_pos_fg"})
            self.parts.wpn_fps_ak_extra_ris.override[k] = { override = table.with(self.parts[k].override, { wpn_fps_o_pos_fg = { adds = {} } }) }
        else
            --self.parts.wpn_fps_o_pos_fg.override[k] = { override = table.with(self.parts[k].override, { wpn_fps_extra_lock_sights = { forbids = {} } }) }
            table.insert(self.parts[k].forbids, "wpn_fps_ak_extra_ris")
            self.parts[k].override.wpn_fps_o_pos_fg = { adds = {} }
        end
    end
    for i, k in pairs(self.nqr.all_sights) do
        --self.wpn_fps_smg_coal.override[k] = { override = table.without(self.parts[k].override, { "wpn_fps_smg_coal_o_scopemount_standard" }) or {} }
    end



    for i, k in pairs(self) do
        if table.contains(k.uses_parts or {}, "wpn_fps_upg_o_45rds") then
            table.insert(k.uses_parts, "wpn_fps_o_blank")

            local has_sight = nil
            for u, j in pairs(k.default_blueprint) do if self.parts[j].type=="sight" then has_sight = true break end end
            if not has_sight then
                table.insert(k.default_blueprint, 1, "wpn_fps_o_blank")
            else
                --k.override = k.override or {}
                --k.override.wpn_fps_o_blank = { pcs = {}, inaccessible = false }
            end
        end
    end
    for i, k in pairs(self.parts) do
        if table.contains(k.forbids or {}, "wpn_fps_o_blank") then
            table.delete(k.forbids, "wpn_fps_o_blank")
        end
    end



    for part_id, part_data in pairs(self.parts) do
        if not part_data.pcs and not part_data.pc then
            part_data.inaccessible = true
        end
    end



    --jesus fucking christ this one single line solved such a headache
    for i, k in pairs(self) do if self[i.."_npc"] then self[i.."_npc"].uses_parts = deep_clone(self[i].uses_parts) end end

end)



Hooks:PostHook( WeaponFactoryTweakData, "_init_contraband", "nqr_contraband", function(self)

end)



function WeaponFactoryTweakData:_add_charms_to_all_weapons(tweak_data, weapon_charms, weapon_overrides, part_overrides, weapon_exclude_list)
    --for i, k in pairs(weapon_charms) do if k.type then k.type = "w_charm" end end
    for i, k in pairs(weapon_charms) do k.is_a_unlockable = nil end

	local charm_list = table.map_keys(weapon_charms)

	table.map_append(self.parts, weapon_charms)

	for id, data in pairs(tweak_data.upgrades.definitions) do
		if tweak_data.weapon[data.weapon_id] and data.factory_id and self[data.factory_id] and not table.contains(weapon_exclude_list, data.factory_id) then
			table.list_append(self[data.factory_id].uses_parts, charm_list)
			table.list_append(self[data.factory_id .. "_npc"].uses_parts, charm_list)
		end
	end

	for weapon_id, override in pairs(weapon_overrides) do
		if self[weapon_id] then
			self[weapon_id].override = self[weapon_id].override or {}

			for _, charm_id in ipairs(charm_list) do
				self[weapon_id].override[charm_id] = override
			end
		end
	end

	for part_id, override in pairs(part_overrides) do
		if self.parts[part_id] then
			self.parts[part_id].override = self.parts[part_id].override or {}

			for _, charm_id in ipairs(charm_list) do
				self.parts[part_id].override[charm_id] = override
			end
		end
	end

	return charm_list
end



function WeaponFactoryTweakData:create_bonuses(tweak_data, weapon_skins)
	self.parts.wpn_fps_upg_bonus_concealment_p1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_concealment",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			concealment = 1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_concealment_p2 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_concealment",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			concealment = 2
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_concealment_p3 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_concealment",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			concealment = 3
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_spread_p1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_spread",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			spread = 1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_spread_n1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_spread",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			spread = -1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_recoil_p1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_recoil",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			recoil = 1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_damage_p1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_damage",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			damage = 1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_damage_p2 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_damage",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			damage = 2
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_total_ammo_p1 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_total_ammo",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			total_ammo_mod = 1
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_total_ammo_p3 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		a_obj = "a_body",
		type = "bonus",
		name_id = "bm_menu_bonus_total_ammo",
		sub_type = "bonus_stats",
		internal_part = true,
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1,
			total_ammo_mod = 3
		},
		perks = {
			"bonus"
		}
	}
	self.parts.wpn_fps_upg_bonus_team_exp_money_p3 = {
		exclude_from_challenge = true,
		texture_bundle_folder = "boost_in_lootdrop",
		internal_part = true,
		a_obj = "a_body",
		third_unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		desc_id = "bm_wp_upg_bonus_team_exp_money_p3_desc",
		type = "bonus",
		sub_type = "bonus_team",
		name_id = "bm_wp_upg_bonus_team_exp_money_p3",
		unit = "units/payday2/weapons/wpn_upg_dummy/wpn_upg_dummy",
		has_description = true,
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			value = 1
		},
		custom_stats = {
			exp_multiplier = 1.03,
			money_multiplier = 1.03
		},
		perks = {
			"bonus"
		}
	}

	if weapon_skins then
		local uses_parts = {
			wpn_fps_upg_bonus_team_exp_money_p3 = {},
			wpn_fps_upg_bonus_concealment_p1 = {},
			wpn_fps_upg_bonus_recoil_p1 = {},
			wpn_fps_upg_bonus_spread_p1 = {},
			wpn_fps_upg_bonus_spread_n1 = {
				category = {
					"shotgun"
				}
			},
			wpn_fps_upg_bonus_damage_p1 = {
				weapon = {
					"flamethrower_mk2"
				}
			},
			wpn_fps_upg_bonus_total_ammo_p1 = {
				category = {
					"saw",
					"minigun",
					"flamethrower",
					"bow",
					"crossbow",
					"snp"
				}
			},
			wpn_fps_upg_bonus_concealment_p2 = {
				weapon = {
					"p90"
				}
			},
			wpn_fps_upg_bonus_concealment_p3 = {
				weapon = {
					"b92fs",
					"famas",
					"g26",
					"jowi",
					"new_raging_bull",
					"ppk"
				}
			},
			wpn_fps_upg_bonus_damage_p2 = {
				weapon = {
					"famas"
				}
			},
			wpn_fps_upg_bonus_total_ammo_p3 = {
				weapon = {
					"plainsrider"
				}
			}
		}
		local all_pass, weapon_pass, exclude_weapon_pass, category_pass, exclude_category_pass = nil

		--[[for id, data in pairs(tweak_data.upgrades.definitions) do
			local weapon_tweak = tweak_data.weapon[data.weapon_id]
			local primary_category = weapon_tweak and weapon_tweak.categories and weapon_tweak.categories[1]

			if data.weapon_id and weapon_tweak and data.factory_id and self[data.factory_id] then
				for part_id, params in pairs(uses_parts) do
					weapon_pass = not params.weapon or table.contains(params.weapon, data.weapon_id)
					exclude_weapon_pass = not params.exclude_weapon or not table.contains(params.exclude_weapon, data.weapon_id)
					category_pass = not params.category or table.contains(params.category, primary_category)
					exclude_category_pass = not params.exclude_category or not table.contains(params.exclude_category, primary_category)
					all_pass = weapon_pass and exclude_weapon_pass and category_pass and exclude_category_pass

					if all_pass then
						table.insert(self[data.factory_id].uses_parts, part_id)
						table.insert(self[data.factory_id .. "_npc"].uses_parts, part_id)
					end
				end
			end
		end]]
	end
end

function WeaponFactoryTweakData:_set_inaccessibles()
end
