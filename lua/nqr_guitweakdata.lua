Hooks:PostHook( GuiTweakData, "init", "nqr_guitweakdata", function(self)

	--BLACKMARKET CATEGORIES
	self.buy_weapon_categories = {
		primaries = {
			{"assault_rifle"},
			{"dmr"},
			{"snp"},
			{"lmg"},
			{"shotgun"},
			{"smg"},
			{"machine_pistol"},
			{"akimbo","machine_pistol"},
			{"wpn_special"},
		},
		secondaries = {
			{"pistol"},
			{"revolver"},
			{"machine_pistol"},
			{"wpn_special"},
			{"akimbo","pistol"},
			{"akimbo","revolver"},
			{"akimbo","machine_pistol"},
		}
	}

	self.stats_present_multiplier = 1

	--self.mod_preview_min_fov = -30
	--self.mod_preview_max_fov = 10

end)