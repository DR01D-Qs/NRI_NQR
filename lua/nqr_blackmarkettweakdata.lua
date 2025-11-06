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
	for i, k in pairs(self.weapon_skins) do k.default_blueprint = nil end
end )