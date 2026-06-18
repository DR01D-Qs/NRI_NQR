HuskPlayerInventory = HuskPlayerInventory or class(PlayerInventory)
local ids_unit = Idstring("unit")



function HuskPlayerInventory:synch_equipped_weapon(weap_index, blueprint_string, cosmetics_string, peer)
	if blueprint_string=="gadget" and cosmetics_string then
		if self:equipped_unit():base().set_gadget_color then
			local a, r, g, b = cosmetics_string:match("(..)(..)(..)(..)")
			local color = Color(tonumber(a, 16)/100, tonumber(r, 16)/100, tonumber(g, 16)/100, tonumber(b, 16)/100)
			log("synch_equipped_weapon", color)
			self:equipped_unit():base():set_gadget_color(tostring(color))
		end

		return
	end



	self:_perform_switch_equipped_weapon(weap_index, blueprint_string, cosmetics_string, peer)

	if self._unit:movement().sync_equip_weapon then
		self._unit:movement():sync_equip_weapon()
	end
end
