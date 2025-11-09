function CopBase:default_weapon_name(selection_name)
    

	local weap_ids = tweak_data.character.weap_ids
	local weap_unit_names = tweak_data.character.weap_unit_names

	if selection_name and self._default_weapons then
        --for i, k in pairs(self._default_weapons) do
        --    managers.mission._fading_debug_output:script().log(tostring(i)..": "..tostring(k),  Color.white)
        --end
		local weapon_id = self._default_weapons[selection_name]

		if weapon_id then
			for i_weap_id, weap_id in ipairs(weap_ids) do
				if weapon_id == weap_id then
					return weap_unit_names[i_weap_id]
				end
			end

		end
	end

	local default_weapon_id = self._default_weapon_id

	--if self._unit:name()=="medic" then
	--	return Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
	--end
	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
            --for i, k in pairs(default_weapon_id) do
            --    if managers.mission._fading_debug_output then managers.mission._fading_debug_output:script().log(tostring(self._unit:name()),  Color.white) end
            --end
            --if managers.mission._fading_debug_output then managers.mission._fading_debug_output:script().log(tostring("csc"),  Color.red) end
			return weap_unit_names[i_weap_id]
		end
	end

end

--[[self.weap_ids = {
	"beretta92",
	"c45",
	"raging_bull",
	"m4",
	"m4_yellow",
	"ak47",
	"r870",
	"mossberg",
	"mp5",
	"mp5_tactical",
	"mp9",
	"mac11",
	"m14_sniper_npc",
	"saiga",
	"m249",
	"benelli",
	"g36",
	"ump",
	"scar_murky",
	"rpk_lmg",
	"svd_snp",
	"akmsu_smg",
	"asval_smg",
	"sr2_smg",
	"ak47_ass",
	"x_c45",
	"sg417",
	"svdsil_snp",
	"mini",
	"heavy_zeal_sniper",
	"smoke",
	"flamethrower",
	"dmr",
	"deagle",
	"sko12_conc",
	"snowthrower"
}]]
--{2, 0}
local enemy_mapping = {
  --REGULAR
  	[Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"):key()] = {
		armor = { body=1, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=1 },
		weapon = { {8, { {10,"r870"} }} },
	},
	[Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"):key()] = {
		weapon = { {8, { {10,"mp5"} }} },
	},

	[Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"):key()] = {
		weapon = { {8, { {10,"mp5"} }} },
	},
	[Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 1.0}, face={2, 0.7}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=1 },
		weapon = { {3, { {10,"c45"} }}, {8, { {7,"mp9"}, {10,"c45"} }} },
	},

	[Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"):key()] = {
		weapon = { {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"):key()] = {
		weapon = { {8, { {3,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"):key()] = {
		weapon = { {4, { {3,"mp9"}, {10,"c45"} }}, {8, { {3,"c45"}, {10,"mp9"} }} },
	},
	[Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"):key()] = {
		weapon = { {4, { {7,"mp5"}, {10,"m4"} }}, {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"):key()] = {
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"):key()] = {
		weapon = { {8, { {10,"sko12_conc"} }} },
	},
	[Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"):key()] = {
		weapon = { {8, { {10,"rpk_lmg"} }} },
	},

	[Idstring("units/payday2/characters/ene_city_swat_r870/ene_city_swat_r870"):key()] = {
		weapon = { {8, { {3,"r870"}, {10,"benelli"} }} },
	},
	[Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"):key()] = {
		weapon = { {8, { {3,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"):key()] = {
		--weapon = { {8, { {3,"r870"}, {10,"benelli"} }} },
	},
  --

  --ZOMBIES
	[Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"):key()] = {
		weapon = { {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1"):key()] = {
		weapon = { {8, { {3,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2"):key()] = {
		--weapon = { {8, { {3,"r870"}, {10,"benelli"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870"):key()] = {
		--weapon = { {8, { {3,"r870"}, {10,"benelli"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2"):key()] = {
		weapon = { {8, { {10,"c45"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 1.0}, face={2, 0.7}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=2 },
		weapon = { {8, { {7,"c45"}, {10,"mp9"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4"):key()] = {
		weapon = { {4, { {7,"mp5"}, {10,"m4"} }}, {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"):key()] = {
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"):key()] = {
		weapon = { {8, { {10,"sko12_conc"} }} },
	},
	[Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"):key()] = {
		weapon = { {8, { {10,"rpk_lmg"} }} },
	},
  --

  --MURKY
	[Idstring("units/pd2_dlc_vit/characters/ene_murkywater_secret_service/ene_murkywater_secret_service"):key()] = {
		ammo = { 2, 0 },
		armor = { body=2, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/payday2/characters/ene_murkywater_1/ene_murkywater_1"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/payday2/characters/ene_murkywater_2/ene_murkywater_2"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_1/ene_murkywater_not_security_1"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"}, }} },
	},
	[Idstring("units/pd2_dlc_des/characters/ene_murkywater_not_security_2/ene_murkywater_not_security_2"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"}, }} },
	},
	[Idstring("units/pd2_dlc_des/characters/ene_murkywater_no_light_not_security/ene_murkywater_no_light_not_security"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_berry/characters/ene_murkywater_no_light/ene_murkywater_no_light"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"}, }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {3, { {10,"ump"} }}, {8, { {7,"ump"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {4, { {7,"ump"}, {10,"m4"} }}, {8, { {7,"ump"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi_r870/ene_murkywater_light_fbi_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_city/ene_murkywater_light_city"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {4, { {7,"ump"}, {10,"m4"} }}, {8, { {7,"ump"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_city_r870/ene_murkywater_light_city_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {3, { {10,"ump"} }}, {8, { {3,"ump"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_mcmansion/characters/ene_hoxton_breakout_guard_2/ene_hoxton_breakout_guard_2"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_shotgun/ene_murkywater_heavy_shotgun"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy_g36/ene_murkywater_heavy_g36"):key()] = {
		ammo = { 2, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {3, { {10,"ump"} }}, {8, { {3,"ump"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_sniper/ene_murkywater_sniper"):key()] = {
		armor = { body=1, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={3, 0.3, 0.9}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {3, { {10,"c45"} }}, {8, { {3,"c45"}, {10,"mp9"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer"):key()] = {
		armor = { body=3, back=3, head={3, 0.7, 0.9}, face={2, 0.2}, lower_legs=2, upper_legs=2, lower_arm=2, upper_arm=2 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker"):key()] = {
		--armor = { body=2, back=2, head={0, 0.0, 0.0}, face={1, 0.8}, lower_legs=2, upper_legs=1, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"):key()] = {
		--ammo = { 1, 1 },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"):key()] = {
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"):key()] = {
		weapon = { {8, { {10,"sko12_conc"} }} },
	},
	[Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"):key()] = {
		weapon = { {8, { {10,"rpk_lmg"} }} },
	},
  --

  --AKAN
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"mp5"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"mp5"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {7,"mp5"}, {10,"ak47_ass"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=2, back=1, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {7,"mp5"}, {10,"ak47_ass"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"):key()] = {
		ammo = { 2, 2 },
		armor = { body=3, back=2, head={3, 0.4, 0.8}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=2 },
		weapon = { {8, { {3,"mp5"}, {10,"ak47_ass"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870"):key()] = {
		ammo = { 2, 2 },
		armor = { body=3, back=2, head={3, 0.4, 0.8}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=2 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"c45"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {3,"c45"}, {10,"sr2_smg"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={0, 0.0}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {3,"c45"}, {10,"sr2_smg"} }} },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"):key()] = {
		ammo = {2, 2},
		armor = { body=3, back=2, head={0, 0.0, 0.0}, face={2, 0.9}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=2 },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass"):key()] = {
		weapon = { {8, { {3,"mp5"}, {10,"ak47_ass"} }} },
	},
	--[Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870"):key()] = { {8, { {3,"asval_smg"}, {10,"ak47_ass"} }} },

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg"):key()] = {
		weapon = { {8, { {4,"mp5_tactical"}, {6,"akmsu_smg"}, {10,"asval_smg"} }} },
	},

	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"):key()] = {
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"):key()] = {
		weapon = { {8, { {10,"sko12_conc"} }} },
	},
  --

  --POLICIA FEDERALE
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {3, { {10,"mp5"} }}, {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870/ene_swat_policia_federale_r870"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_city/ene_swat_policia_federale_city"):key()] = {
		weapon = { {4, { {7,"mp5"}, {10,"m4"} }}, {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_city_r870/ene_swat_policia_federale_city_r870"):key()] = {
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"):key()] = {
		weapon = { {4, { {7,"mp5"}, {10,"m4"} }}, {8, { {7,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=2, upper_legs=0, lower_arm=2, upper_arm=0 },
		weapon = { {3, { {10,"mp5"} }}, {8, { {3,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_r870/ene_swat_heavy_policia_federale_r870"):key()] = {
		ammo = { 1, 0 },
		armor = { body=3, back=2, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=2, upper_legs=0, lower_arm=2, upper_arm=0 },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_g36/ene_swat_heavy_policia_federale_fbi_g36"):key()] = {
		weapon = { {8, { {3,"mp5"}, {10,"m4"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870/ene_swat_heavy_policia_federale_fbi_r870"):key()] = {
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {10,"c45"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"):key()] = {
		armor = { body=2, back=1, head={2, 0.3, 0.9}, face={1, 0.4}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
		weapon = { {8, { {3,"c45"}, {10,"mp9"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale"):key()] = {
		armor = { body=3, back=3, head={1, 0.3, 0.7}, face={1, 0.5}, lower_legs=0, upper_legs=0, lower_arm=0, upper_arm=0 },
	},

	[Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"):key()] = {
		weapon = { {8, { {10,"ump"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"):key()] = {
		weapon = { {8, { {10,"sko12_conc"} }} },
	},
	[Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"):key()] = {
		weapon = { {8, { {10,"rpk_lmg"} }} },
	},
  --

  --MISC
	[Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_1/ene_male_marshal_shield_1"):key()] = {
		weapon = { {8, { {10,"r870"} }} },
	},
	[Idstring("units/pd2_dlc_usm2/characters/ene_male_marshal_shield_2/ene_male_marshal_shield_2"):key()] = {
		weapon = { {8, { {10,"r870"} }} },
	},

	[Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"):key()] = {
		weapon = { {8, { {10,"mini"} }} },
	},
  --
}

Hooks:PostHook(CopBase, "init", "nqr_CopBase:init", function(self, unit)
	--if not Network:is_server() then return end
end)
Hooks:PreHook(CopBase, "post_init", "nqr_CopBase:post_init", function(self)
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	self._char_tweak = char_tweak

	local has_map = enemy_mapping[self._unit:name():key()] or {}

	if has_map.weapon then
		local dif_id = tweak_data:difficulty_to_index(Global and Global.game_settings and Global.game_settings.difficulty or "overkill")
		local wep_roll = math.random(10)
		for i, k in pairs(has_map.weapon) do
			if dif_id<=k[1] then
				for o, l in pairs(k[2]) do
					if wep_roll<=l[1] then
						if self._default_weapons then
							self._default_weapons.primary = l[2]
						elseif self._default_weapon_id then
							self._default_weapon_id = l[2]
						end
						break
					end
				end
				break
			end
		end
	end
	if has_map.ammo then self._char_tweak.ammo = has_map.ammo end
	if has_map.armor then self._char_tweak.armor = has_map.armor end



	self.lootable_ammo = {}
	local wep_id = ""
	if self._default_weapons then
		wep_id = self._default_weapons.primary
	elseif self._default_weapon_id then
		wep_id = self._default_weapon_id
	end

	local ammo_class = (
		tweak_data.weapon[wep_id.."_npc"]
		and tweak_data.weapon[wep_id.."_npc"].caliber
		and tweak_data.weapon.calibers[tweak_data.weapon[wep_id.."_npc"].caliber]
		and tweak_data.weapon.calibers[tweak_data.weapon[wep_id.."_npc"].caliber].class
		or "pistol"
	)

	local mag_amount1 = {1,2}
	local mag_amount2 = {0,0}
	if tweak_data.weapon[wep_id.."_npc"] and tweak_data.weapon[wep_id.."_npc"].mag_amount then
		mag_amount1 = tweak_data.weapon[wep_id.."_npc"].mag_amount[ self._char_tweak.ammo[1] ]
		mag_amount2 = tweak_data.weapon["c45_npc"].mag_amount[ self._char_tweak.ammo[2] ]
	end
	self.lootable_ammo[ammo_class] = (self.lootable_ammo[ammo_class] or 0) + math.random(mag_amount1[1], mag_amount1[2])
	if mag_amount2[1]~=0 then self.lootable_ammo.pistol = (self.lootable_ammo.pistol or 0) + math.random(mag_amount2[1], mag_amount2[2]) end

	if Network:is_server() then
		for i, k in pairs(self.lootable_ammo or {}) do
			managers.network:session():send_to_peers_synched("sync_enemy_buff", self._unit, i, k)
		end
	end
end)

--GET LOOTABLE AMMO ON COP SPAWN
function CopBase:_sync_buff_total(name, total)
	if name=="rifle" or name=="shotgun" or name=="pistol" then
		self.lootable_ammo = self.lootable_ammo or {}
		self.lootable_ammo[name] = total

		return
	end

	self._buffs[name] = self._buffs[name] or {}
	self._buffs[name]._total = total * 0.001
end
