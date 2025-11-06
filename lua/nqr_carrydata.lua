local ids_g_bag = Idstring("g_bag")
local ids_g_canvasbag = Idstring("g_canvasbag")
local ids_g_g = Idstring("g_g")
local ids_g_goat = Idstring("g_goat")
local ids_g_bodybag = Idstring("g_bodybag")

function CarryData:_update_throw_link(unit, t, dt)
	if self._linked_to or not self._spawn_time or t > self._spawn_time + 1 or not self._link_obj or not self._link_obj:visibility() then
		return false
	end

	local bag_center = self._link_obj:oobb():center()
	local links = CarryData.carry_links
	local oobb_mod = self._oobb_mod

	for u_key, entry in pairs(managers.groupai:state():all_AI_criminals()) do
		if not links[u_key] then
			local mov_ext = entry.unit:movement()

			if not mov_ext.vehicle_unit and not mov_ext:cool() and not mov_ext:downed() then
				local body_oobb = entry.unit:oobb()

				body_oobb:grow(oobb_mod)

				if body_oobb:point_inside(bag_center) then
					body_oobb:shrink(oobb_mod)
					entry.unit:sound():say("r03x_sin", true)
					self:link_to(entry.unit)

					return false
				end

				body_oobb:shrink(oobb_mod)
			end
		end
	end

	for u_key, entry in pairs(managers.enemy:all_enemies()) do
		if not links[u_key] then
			local mov_ext = entry.unit:movement()

			if not mov_ext.vehicle_unit then
				local body_oobb = entry.unit:oobb()
				--body_oobb:grow(oobb_mod)
				if body_oobb:point_inside(bag_center) then
					--body_oobb:shrink(oobb_mod)
					local action_data = {
						damage_effect = 1,
						damage = 1,
						variant = "knock_down",
						attacker_unit = nil,
						col_ray = {
							body = entry.unit:body("body"),
							position = entry.unit:position() + math.UP * 100
						},
						attack_dir = entry.unit:rotation():y() -- -1 * target_vec:normalized(),
					}
					entry.unit:character_damage():damage_melee(action_data)

					return false
				end
				--body_oobb:shrink(oobb_mod)
			end
		end
	end

	return true
end