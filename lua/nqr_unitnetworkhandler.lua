--RECOVER UNIT FROM UNIT_ID IF ITS DEAD WHEN NQR_CORPSE_LOOT
function UnitNetworkHandler:sync_interacted(unit, unit_id, tweak_setting, status, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then return end
	local peer = self._verify_sender(sender)
	if not peer then return end

	local unit = unit
	if tweak_setting=="nqr_corpse_loot" and not unit then
		unit = managers.enemy:get_corpse_unit_data_from_id(unit_id) and managers.enemy:get_corpse_unit_data_from_id(unit_id).unit or unit
	end

	if Network:is_server() and unit_id ~= -2 then
		if alive(unit) and unit:interaction() and unit:interaction().tweak_data == tweak_setting and unit:interaction():active() then
			sender:sync_interaction_reply(true)
		else
			sender:sync_interaction_reply(false)

			return
		end
	end

	if alive(unit) and unit:interaction() then
		if unit:interaction()._special_equipment and unit:interaction().apply_item_pickup then
			managers.network:session():send_to_peer(peer, "special_eq_response", unit)

			if unit:interaction():can_remove_item() then
				unit:set_slot(0)
			end
		end

		local char_unit = managers.criminals:character_unit_by_peer_id(peer:id())

		unit:interaction():sync_interacted(peer, char_unit, status)
	end
end