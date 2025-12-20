function GenericDLCManager:has_nqr_dlc() return true end

Hooks:PostHook( DLCTweakData, "init", "nqr_DLCTweakData_init", function(self)
	for i, k in pairs(self) do
		for u, j in pairs(k.content and k.content.loot_drops or {}) do
			if j.type_items=="weapon_mods" then
				self[i].content.loot_drops[u].amount = 0

				if k.dlc=="has_achievement" then
					self[i].content.loot_drops[u] = nil
				end
			end

			for o, l in pairs(j) do
				if type(l)=="table" then
					if l.type_items=="weapon_mods" then self[i].content.loot_drops[u][o].amount = 0 end
				end
			end
		end
	end



	self.pd2_clan2.content.upgrades = nil
	self.pd2_clan_lgl.content.upgrades = nil
	self.armored_transport.content.upgrades = nil
	self.gage_pack.content.upgrades = nil
	self.gage_pack_lmg.content.upgrades = nil



	self.nqr_dlc = {
		free = true,
		content = {}
	}
	--[[self.nqr_dlc2 = {
		content = {},
		dlc = "has_nqr_dlc"
	}]]
	self.nqr_dlc.content.loot_global_value = "nqr_dlc"
	self.nqr_dlc.content.loot_drops = {
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_vg", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_fg", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_s", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_s_addon", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_o", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_o_blank", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_gb", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_extra", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_ass_shak12_o_carry_dummy", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_extra2", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_bipod", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_cos", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_ns", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_upper", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_remove_ironsight", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_fold_ironsight", },

		{ type_items = "weapon_mods", item_entry = "wpn_fps_ironsight_fantom_folded", },

		{ type_items = "weapon_mods", item_entry = "wpn_fps_gadgets_pos_a_fl2", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_gadgets_pos_a_fl3", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_o_pos_fg", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_o_pos_zenitco", },
		{ type_items = "weapon_mods", item_entry = "wpn_fps_o_pos_a_o_sm", },
	}
end)
