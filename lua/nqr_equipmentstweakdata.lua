EquipmentsTweakData = EquipmentsTweakData or class()

Hooks:PostHook(EquipmentsTweakData, "init", "nqr_EquipmentsTweakData:init", function(self)
	local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		pbr = { c4 = { quantity = 2, max_quantity = 6, transfer_quantity = 6 } },
		bph = { thermite_paste = { quantity = 1, max_quantity = 2, transfer_quantity = 2 } },
	}

	for i, k in pairs(lookup[job] or {}) do
		for u, j in pairs(k or {}) do
			if self.specials[i] then self.specials[i][u] = j end
		end
	end



	self.specials.cable_tie.quantity = 95
	self.specials.cable_tie.max_quantity = 95
end)