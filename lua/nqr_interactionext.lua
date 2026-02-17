--NQR_CORPSE_LOOT FULL AMMO CHECK
function IntimitateInteractionExt:_interact_blocked(player)
	if self.tweak_data == "corpse_dispose" then
		if managers.player:is_carrying() then
			return true
		end

		if managers.player:chk_body_bags_depleted() then
			return true, nil, "body_bag_limit_reached"
		end

		local has_upgrade = managers.player:has_category_upgrade("player", "corpse_dispose")

		if not has_upgrade then
			return true
		end

		return not managers.player:can_carry("person")
	elseif self.tweak_data == "nqr_corpse_loot" then
		local loot_ammo = self._unit:base().lootable_ammo or {}
		local full_ammo = not player:inventory():need_ammo()
		local could_pick = nil
		local want_to_pick = nil
		local ammo_type = {}
		for id, weapon in pairs(player:inventory():available_selections()) do
			--for i, k in pairs(self._unit:base().lootable_ammo or { rifle = 1, pistol = 3 }) do
			for i, k in pairs(loot_ammo) do
				if not table.contains(ammo_type, i) then table.insert(ammo_type, i) end

				if tweak_data.weapon.calibers[weapon.unit:base()._current_stats.caliber].class==i then
					could_pick = true
					if not weapon.unit:base():ammo_full() then want_to_pick = true end
				end
			end
		end

		local loc = managers.localization
		local string = not ammo_type[1] and loc:text("hint_nqr_loot_noammo") or (loc:text("hint_nqr_loot_found")
			..loc:text("hint_nqr_loot_"..ammo_type[1])
			..(ammo_type[2] and (loc:text("hint_nqr_loot_and")..loc:text("hint_nqr_loot_"..ammo_type[2])) or "")
			..loc:text("hint_nqr_loot_ammo")
			..(ammo_type[1] and ((not could_pick) and loc:text("hint_nqr_loot_noneed") or not want_to_pick and loc:text("hint_nqr_loot_butfull") or "") or "")
		)
		--[[managers.hud:show_hint({
			text = (
				"FOUND "
				..(ammo_type[1] or "NO")
				..(ammo_type[2] and (" AND "..ammo_type[2]) or "")
				.." AMMO"
				..(ammo_type[1] and ((not could_pick) and ", WHICH YOU DON'T NEED" or not want_to_pick and ", BUT YOU ARE FULL" or "") or "")
			), --managers.localization:text(hint.text_id, params),
			event = "stinger_feedback_"..((not ((ammo_type[1]) or (could_pick) or (want_to_pick))) and "positive" or "negative"), --hint.event,
			time = 2,
			cd_start = not ammo_type[1] and (Application:time() + 2),
		})]]
		managers.hud:show_hint({
			text = string,
			event = "stinger_feedback_"..((not ((ammo_type[1]) or (could_pick) or (want_to_pick))) and "positive" or "negative"), --hint.event,
			time = 2,
			cd_start = not ammo_type[1] and (Application:time() + 2),
		})
		if not want_to_pick or not ammo_type[1] then return true, true end
	elseif self.tweak_data == "hostage_convert" then
		return not managers.player:has_category_upgrade("player", "convert_enemies") or managers.player:chk_minion_limit_reached() or managers.groupai:state():whisper_mode()
	elseif self.tweak_data == "hostage_move" then
		if not self._unit:anim_data().tied then
			return true
		end

		local following_hostages = managers.groupai:state():get_following_hostages(player)

		if following_hostages and tweak_data.player.max_nr_following_hostages <= table.size(following_hostages) then
			return true, nil, "hint_hostage_follow_limit"
		end
	elseif self.tweak_data == "hostage_stay" then
		return not self._unit:anim_data().stand or self._unit:anim_data().to_idle
	end
end

--NQR_CORPSE_LOOT INTERACTION
function IntimitateInteractionExt:interact(player)
	if not self:can_interact(player) then return end

	local player_manager = managers.player
	local has_equipment = managers.player:has_special_equipment(self._tweak_data.special_equipment)

	if self._tweak_data.equipment_consume and has_equipment then
		managers.player:remove_special(self._tweak_data.special_equipment)
	end

	if self._tweak_data.sound_event then
		player:sound():play(self._tweak_data.sound_event)
	end

	if self._unit:damage() and self._unit:damage():has_sequence("interact") then
		self._unit:damage():run_sequence_simple("interact")
	end

	if self.tweak_data == "corpse_alarm_pager" then
		if Network:is_server() then
			self._nbr_interactions = 0

			if self._unit:character_damage():dead() then
				local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

				managers.network:session():send_to_peers_synched("alarm_pager_interaction", u_id, self.tweak_data, 3)
			else
				managers.network:session():send_to_peers_synched("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
			end

			self._unit:brain():on_alarm_pager_interaction("complete", player)

			if alive(managers.interaction:active_unit()) then
				managers.interaction:active_unit():interaction():selected()
			end
		else
			managers.groupai:state():sync_alarm_pager_bluff()

			if managers.enemy:get_corpse_unit_data_from_key(self._unit:key()) then
				local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

				managers.network:session():send_to_host("alarm_pager_interaction", u_id, self.tweak_data, 3)
			else
				managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
			end
		end

		if tweak_data.achievement.nothing_to_see_here and managers.player:local_player() == player then
			local achievement_data = tweak_data.achievement.nothing_to_see_here
			local achievement = "nothing_to_see_here"
			local memory = managers.job:get_memory(achievement, true)
			local t = Application:time()
			local new_memory = {
				value = 1,
				time = t
			}

			if memory then
				table.insert(memory, new_memory)

				for i = #memory, 1, -1 do
					if achievement_data.timer <= t - memory[i].time then
						table.remove(memory, i)
					end
				end
			else
				memory = {
					new_memory
				}
			end

			managers.job:set_memory(achievement, memory, true)

			local total_memory_value = 0

			for _, m_data in ipairs(memory) do
				total_memory_value = total_memory_value + m_data.value
			end

			if achievement_data.total_value <= total_memory_value then
				managers.achievment:award(achievement_data.award)
			end
		end

		self:remove_interact()
	elseif self.tweak_data == "corpse_dispose" then
		managers.player:set_carry("person", 0)
		managers.player:on_used_body_bag()

		local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id
		if Network:is_server() then
			self:remove_interact()
			self:set_active(false, true)
			self._unit:set_slot(0)
			managers.network:session():send_to_peers_synched("remove_corpse_by_id", u_id, true, managers.network:session():local_peer():id())
			managers.player:register_carry(managers.network:session():local_peer(), "person")
		else
			managers.network:session():send_to_host("sync_interacted_by_id", u_id, self.tweak_data)
			player:movement():set_carry_restriction(true)
		end

		managers.mission:call_global_event("player_pickup_bodybag")
		managers.custom_safehouse:award("corpse_dispose")
	elseif self.tweak_data == "nqr_corpse_loot" then
		local loot_ammo = self._unit:base().lootable_ammo or {}
		local looted = nil

		for id, weapon in pairs(player:inventory():available_selections()) do
			for i, k in pairs(loot_ammo) do
				if tweak_data.weapon.calibers[weapon.unit:base()._current_stats.caliber].class==i and not weapon.unit:base():ammo_full() then
					k = k - 1

					local ammo_type_codes = {
						pistol = 10,
						rifle = 20,
						shotgun = 30,
					}
					local ammo_type = ammo_type_codes[i]
					managers.network:session():send_to_peers_synched("sync_interacted", self._unit, managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id, self.tweak_data, 100+ammo_type+k)

					if k<=0 then k = nil end
					loot_ammo[i] = k
					weapon.unit:base():add_ammo(1, nil)
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
					looted = true
				end
			end
		end

		if looted then player:sound():play("pickup_ammo") end
	elseif self._tweak_data.dont_need_equipment and not has_equipment then
		self:set_active(false)
		self._unit:brain():on_tied(player, true)
	elseif self.tweak_data == "hostage_trade" then
		self._unit:brain():on_trade(player:position(), player:rotation(), true)

		if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.relation_with_bulldozer.mask then
			managers.achievment:award_progress(tweak_data.achievement.relation_with_bulldozer.stat)
		end

		managers.statistics:trade({
			name = self._unit:base()._tweak_table
		})
	elseif self.tweak_data == "hostage_convert" then
		if Network:is_server() then
			self:remove_interact()
			self:set_active(false, true)
			managers.groupai:state():convert_hostage_to_criminal(self._unit)
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	elseif self.tweak_data == "hostage_move" then
		if Network:is_server() then
			if self._unit:brain():on_hostage_move_interaction(player, "move") then
				self:remove_interact()
			end
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	elseif self.tweak_data == "hostage_stay" then
		if Network:is_server() then
			if self._unit:brain():on_hostage_move_interaction(player, "stay") then
				self:remove_interact()
			end
		else
			managers.network:session():send_to_host("sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
		end
	else
		self:remove_interact()
		self:set_active(false)
		player:sound():play("cable_tie_apply")
		self._unit:brain():on_tied(player, false, not managers.player:has_category_upgrade("player", "super_syndrome"))
	end
end

function IntimitateInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	local function _get_unit()
		local unit = player

		if not unit then
			unit = peer and peer:unit()

			if not unit then
				-- Nothing
			end
		end

		return unit
	end

	if self.tweak_data == "corpse_alarm_pager" then
		if status == 1 then
			status = "started"
		elseif status == 2 then
			status = "interrupted"
		elseif status == 3 then
			status = "complete"
		end

		if Network:is_server() then
			self._interacting_unit_destroy_listener_key = "IntimitateInteractionExt_" .. tostring(self._unit:key())

			if status == "started" then
				local husk_unit = _get_unit()

				if husk_unit then
					husk_unit:base():add_destroy_listener(self._interacting_unit_destroy_listener_key, callback(self, self, "on_interacting_unit_destroyed", peer))

					self._interacting_units = self._interacting_units or {}
					self._interacting_units[husk_unit:key()] = husk_unit
				end

				self._nbr_interactions = self._nbr_interactions + 1

				if self._in_progress then
					return
				end

				self._in_progress = true

				if managers.enemy:get_corpse_unit_data_from_key(self._unit:key()) then
					local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

					managers.network:session():send_to_peers_synched_except(peer:id(), "alarm_pager_interaction", u_id, self.tweak_data, 1)
				else
					managers.network:session():send_to_peers_synched_except(peer:id(), "sync_interacted", self._unit, self._unit:id(), self.tweak_data, 1)
				end

				self._unit:brain():on_alarm_pager_interaction(status, _get_unit())
			else
				if not self._in_progress then
					return
				end

				local husk_unit = _get_unit()

				if husk_unit then
					husk_unit:base():remove_destroy_listener(self._interacting_unit_destroy_listener_key)

					self._interacting_units[husk_unit:key()] = nil

					if not next(self._interacting_units) then
						self._interacting_units = nil
					end
				end

				if status == "complete" then
					self._nbr_interactions = 0

					if managers.enemy:get_corpse_unit_data_from_key(self._unit:key()) then
						local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

						managers.network:session():send_to_peers_synched_except(peer:id(), "alarm_pager_interaction", u_id, self.tweak_data, 3)
					else
						managers.network:session():send_to_peers_synched_except(peer:id(), "sync_interacted", self._unit, self._unit:id(), self.tweak_data, 3)
					end
				else
					self._nbr_interactions = self._nbr_interactions - 1
				end

				if self._nbr_interactions == 0 then
					self._in_progress = nil

					self:remove_interact()
					self._unit:brain():on_alarm_pager_interaction(status, _get_unit())
				end
			end
		elseif status == "started" then
			self._unit:sound():stop()
		elseif status == "complete" then
			managers.groupai:state():sync_alarm_pager_bluff()
		end
	elseif self.tweak_data == "corpse_dispose" then
		if peer then
			managers.player:register_carry(peer, "person")
		end

		self:remove_interact()
		self:set_active(false, true)

		local u_id = managers.enemy:get_corpse_unit_data_from_key(self._unit:key()).u_id

		if Network:is_server() or self._unit:id() == -1 then
			self._unit:set_slot(0)
		end

		managers.network:session():send_to_peers_synched("remove_corpse_by_id", u_id, true, peer:id())

		if Network:is_server() and peer then
			peer:on_used_body_bags()
		end
	elseif self.tweak_data == "nqr_corpse_loot" then
		--managers.mission._fading_debug_output:script().log(tostring("sync_interacted, status: ")..tostring(status), Color.red)
		self._unit:base().lootable_ammo = self._unit:base().lootable_ammo or {}
		if not status or status<100 then return end
		local ammo_type_codes = {
			[10] = "pistol",
			[20] = "rifle",
			[30] = "shotgun",
		}
		local ammo_amount = (status-100)%10
		local ammo_type = ammo_type_codes[(status-100) - ammo_amount]
		self._unit:base().lootable_ammo[ammo_type] = ammo_amount>0 and ammo_amount or nil
	elseif self.tweak_data == "hostage_convert" then
		self:remove_interact()
		self:set_active(false, true)
		managers.groupai:state():convert_hostage_to_criminal(self._unit, _get_unit())
	elseif self.tweak_data == "hostage_move" then
		if Network:is_server() and self._unit:brain():on_hostage_move_interaction(_get_unit(), "move") then
			self:remove_interact()
		end
	elseif self.tweak_data == "hostage_stay" and Network:is_server() and self._unit:brain():on_hostage_move_interaction(_get_unit(), "stay") then
		self:remove_interact()
	end
end



function DrivingInteractionExt:can_interact(player)
	local can_interact = DrivingInteractionExt.super.can_interact(self, player)

	if can_interact and managers.player:is_berserker() and self._action ~= VehicleDrivingExt.INTERACT_LOOT and self._action ~= VehicleDrivingExt.INTERACT_TRUNK then
		can_interact = false

		managers.hud:show_hint({
			time = 2,
			text = managers.localization:text("hud_vehicle_no_enter_berserker")
		})
	elseif can_interact and managers.player:is_carrying() then
		if self._action == VehicleDrivingExt.INTERACT_ENTER or self._action == VehicleDrivingExt.INTERACT_DRIVE then

		elseif self._action == VehicleDrivingExt.INTERACT_LOOT then
			can_interact = false
		end
	end

	return can_interact
end



AmmoBagInteractionExt = AmmoBagInteractionExt or class(UseInteractionExt)

function AmmoBagInteractionExt:_interact_blocked(player)
	local need, skip_hint, custom_hint = player:inventory():need_ammo()
	return not need, skip_hint, custom_hint
end



GrenadeCrateInteractionExt = GrenadeCrateInteractionExt or class(UseInteractionExt)

function GrenadeCrateInteractionExt:_interact_blocked(player)
	if not managers.blackmarket:equipped_grenade_allows_pickups() and not player:inventory():need_special_ammo() then
		return true, false, "ability_no_grenade_pickup" --todo
	end

	return managers.player:got_max_grenades() and not player:inventory():need_special_ammo()
end
