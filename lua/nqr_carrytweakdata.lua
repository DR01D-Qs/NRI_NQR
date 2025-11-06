Hooks:PostHook( CarryTweakData, "init", "nqr_carrytweakdata", function(self)

    self.ammo_backpack = {
		type = "heavy",
		name_id = "hud_carry_ammo",
		unit = "units/payday2/pickups/gen_pku_cage_bag/gen_pku_cage_bag",
		visual_unit_name = "units/payday2/characters/npc_acc_cage_bag_1/npc_acc_cage_bag_1",
		AI_carry = {
			SO_category = "enemies"
		},
        default_value = 1,
		is_unique_loot = true,
		skip_exit_secure = true,
		no_area_trigger_detection = true
	}

	self.winch_part.type = "medium"
	self.winch_part_2.type = "medium"
	self.winch_part_3.type = "medium"

	self.person.type = "very_heavy"

	self.weapon.AI_carry = { SO_category = "enemies" }
	self.weapons.AI_carry = { SO_category = "enemies" }

	self.nail_euphadrine_pills.AI_carry = nil
	self.nail_muriatic_acid.AI_carry = nil
	self.nail_caustic_soda.AI_carry = nil
	self.nail_hydrogen_chloride.AI_carry = nil

end)