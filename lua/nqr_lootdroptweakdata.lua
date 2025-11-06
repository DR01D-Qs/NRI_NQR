Hooks:PostHook(LootDropTweakData, "init", "nqr_LootDropTweakData_init", function(self)
self.global_values.nqr_dlc = {
name_id = "bm_global_value_nqr_dlc",
desc_id = "menu_l_global_value_nqr_dlc",
unlock_id = "bm_global_value_nqr_dlc_unlock",
color = Color(255, 59, 174, 254) / 255,
dlc = true,
chance = 1,
value_multiplier = 1,
durability_multiplier = 1,
drops = false,
--track = true,
sort_number = 0,
category = "dlc",
}
end)