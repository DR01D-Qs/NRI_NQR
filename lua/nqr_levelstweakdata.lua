Hooks:PostHook( LevelsTweakData, "init", "nqr_LevelsTweakData:init", function(self)

	self.short1_stage1.force_equipment.primary = "wpn_fps_sho_coach"
	self.short1_stage1.force_equipment.primary_mods = nil
	self.short1_stage1.force_equipment.secondary = "wpn_fps_pis_peacemaker"
	self.short1_stage1.force_equipment.secondary_mods = nil
	self.short1_stage2.force_equipment.primary = self.short1_stage1.force_equipment.primary
	self.short1_stage2.force_equipment.primary_mods = self.short1_stage1.force_equipment.primary_mods
	self.short1_stage2.force_equipment.secondary = self.short1_stage1.force_equipment.secondary
	self.short1_stage2.force_equipment.secondary_mods = self.short1_stage1.force_equipment.secondary_mods
	self.short2_stage1.force_equipment.primary = self.short1_stage1.force_equipment.primary
	self.short2_stage1.force_equipment.secondary = self.short1_stage1.force_equipment.secondary
	self.short2_stage1.force_equipment.armor = "level_1"
	self.short2_stage2b.force_equipment.primary = self.short1_stage1.force_equipment.primary
	self.short2_stage2b.force_equipment.secondary = self.short1_stage1.force_equipment.secondary
	self.short2_stage2b.force_equipment.armor = "level_1"

end)