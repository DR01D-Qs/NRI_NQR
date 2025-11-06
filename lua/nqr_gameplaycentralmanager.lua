local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_vec4 = Vector3()
local empty_idstr = Idstring("")
local idstr_concrete = Idstring("concrete")
local idstr_blood_spatter = Idstring("blood_spatter")
local idstr_blood_screen = Idstring("effects/particles/character/player/blood_screen")
local idstr_bullet_hit_blood = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a")
local idstr_fallback = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
local idstr_no_material = Idstring("no_material")
local idstr_bullet_hit = Idstring("bullet_hit")
local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add
local mvec3_neg = mvector3.negate
local mvec3_lerp = mvector3.lerp
local mvec3_spread = mvector3.spread
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dist = mvector3.distance
local mvec3_dot = mvector3.dot
GamePlayCentralManager = GamePlayCentralManager or class()



function GamePlayCentralManager:_do_shotgun_push(unit, hit_pos, dir, distance, attacker)
end



function GamePlayCentralManager:play_impact_sound_and_effects(params)
	if params.immediate then
		self:_play_bullet_hit(params)
	elseif #self._bullet_hits<20 then
		table.insert(self._bullet_hits, params)
	end
end

function GamePlayCentralManager:_flush_bullet_hits()
	if #self._bullet_hits > 0 then
		for i, k in pairs(self._bullet_hits) do
			self:_play_bullet_hit(table.remove(self._bullet_hits, 1))
		end
	end
end

local zero_vector = Vector3()
function GamePlayCentralManager:_play_bullet_hit(params)
	local unit = params.col_ray.unit

	if not alive(unit) then
		return
	end

	local unit_key = unit:key()
	local overrides = self._impact_override[unit_key]
	local hit_pos = params.col_ray.position
	local need_sound = not params.no_sound and World:in_view_with_options(hit_pos, 4000, 0, 0)
	local need_effect = World:in_view_with_options(hit_pos, 20, 100, 5000)
	local need_decal = not self._block_bullet_decals and not params.no_decal and (not overrides or not overrides.no_decal) and need_effect and World:in_view_with_options(hit_pos, 3000, 0, 0)

	if not need_sound and not need_effect and not need_decal then
		return
	end

	if alive(self._decal_unit_redirect[unit_key]) then
		unit = self._decal_unit_redirect[unit_key]
	end

	local col_ray = params.col_ray
	local event = params.event or "bullet_hit"
	local decal = overrides and overrides.decal and Idstring(overrides.decal) or params.decal and Idstring(params.decal) or idstr_bullet_hit
	local slot_mask = params.slot_mask or self._slotmask_bullet_impact_targets
	local sound_switch_name = overrides and overrides.sound_switch_name or nil
	local decal_ray_from = tmp_vec1
	local decal_ray_to = tmp_vec2

	mvec3_set(decal_ray_from, col_ray.ray)
	mvec3_set(decal_ray_to, hit_pos)
	mvec3_mul(decal_ray_from, 25)
	mvec3_add(decal_ray_to, decal_ray_from)
	mvec3_neg(decal_ray_from)
	mvec3_add(decal_ray_from, hit_pos)
	mvec3_set(tmp_vec4, col_ray.ray)
	mvec3_neg(tmp_vec4)

	local effect_normal = tmp_vec3

	mvec3_set(effect_normal, col_ray.normal)
	mvec3_lerp(effect_normal, col_ray.normal, tmp_vec4, math.random())
	mvec3_spread(effect_normal, 10)

	local material_name, pos, norm = World:pick_decal_material(unit, decal_ray_from, decal_ray_to, slot_mask)
	material_name = material_name ~= empty_idstr and material_name
	local effect = overrides 
	and overrides.effect_name 
	and Idstring(overrides.effect_name) 
	or params.effect
	material_name = params.switch or material_name

	if material_name then
		local offset = col_ray.sphere_cast_radius and col_ray.ray * col_ray.sphere_cast_radius or zero_vector
		local redir_name = nil

		if need_decal then
			redir_name, pos, norm = World:project_decal(decal, hit_pos + offset, col_ray.ray, unit, math.UP, col_ray.normal)
		elseif need_effect then
			redir_name, pos, norm = World:pick_decal_effect(decal, unit, decal_ray_from, decal_ray_to, slot_mask)
		end

		if redir_name == empty_idstr then
			redir_name = idstr_fallback
		end

		if need_effect then
			effect = {
				effect = (
					effect
					or (params.switch==Idstring("flesh") and Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"))
					or (params.switch==Idstring("steel") and Idstring("effects/payday2/particles/impacts/steel_no_decal_impact_pd2"))
					or (params.switch==Idstring("concrete") and Idstring("effects/payday2/particles/impacts/concrete_impact_pd2"))
					or (params.switch==Idstring("glass_breakable") and Idstring("effects/payday2/particles/impacts/glass_impact_pd2"))
					or redir_name
				),
				position = hit_pos + offset,
				normal = effect_normal
			}
		end

		sound_switch_name = need_sound and (sound_switch_name or params.sound_switch_name or material_name)
	else
		if need_effect then
			local generic_effect = effect or idstr_fallback
			effect = {
				effect = generic_effect,
				position = hit_pos,
				normal = effect_normal
			}
		end

		sound_switch_name = need_sound and (sound_switch_name or params.sound_switch_name or idstr_no_material)
	end

	if effect and effect.effect then
		table.insert(self._play_effects, effect)
	end

	if need_sound then
		table.insert(self._play_sounds, {
			sound_switch_name = sound_switch_name,
			position = hit_pos,
			event = event
		})
	end

	local materials = {
		[Idstring("concrete")] = "concrete",
		[Idstring("ceramic")] = "ceramic",
		[Idstring("marble")] = "marble",
		[Idstring("flesh")] = "flesh",
		[Idstring("parket")] = "parket",
		[Idstring("sheet_metal")] = "sheet_metal",
		[Idstring("iron")] = "iron",
		[Idstring("wood")] = "wood",
		[Idstring("gravel")] = "gravel",
		[Idstring("cloth")] = "cloth",
		[Idstring("cloth_no_decal")] = "cloth2",
		[Idstring("cloth_stuffed")] = "cloth_stuffed",
		[Idstring("dirt")] = "dirt",
		[Idstring("grass")] = "grass",
		[Idstring("carpet")] = "carpet",
		[Idstring("metal")] = "metal",
		[Idstring("glass_breakable")] = "glass_breakable",
		[Idstring("glass_unbreakable")] = "glass_unbreakable",
		[Idstring("glass_no_decal")] = "glass_unbreakable",
		[Idstring("rubber")] = "rubber",
		[Idstring("plastic")] = "plastic",
		[Idstring("asphalt")] = "asphalt",
		[Idstring("foliage")] = "foliage",
		[Idstring("stone")] = "stone",
		[Idstring("sand")] = "sand",
		[Idstring("thin_layer")] = "thin_layer",
		[Idstring("no_decal")] = "silent_material",
		[Idstring("plaster")] = "plaster",
		[Idstring("no_material")] = "no_material",
		[Idstring("paper")] = "paper",
		[Idstring("metal_hollow")] = "metal_hollow",
		[Idstring("metal_chassis")] = "metal_chassis",
		[Idstring("metal_catwalk")] = "metal_catwalk",
		[Idstring("hardwood")] = "hardwood",
		[Idstring("fence")] = "fence",
		[Idstring("steel")] = "steel",
		[Idstring("steel_no_decal")] = "steel",
		[Idstring("tile")] = "tile",
		[Idstring("water_deep")] = "water_deep",
		[Idstring("water_puddle")] = "water_puddle",
		[Idstring("water_shallow")] = "water_puddle",
		[Idstring("shield")] = "shield",
		[Idstring("heavy_swat_steel_no_decal")] = "shield",
		[Idstring("snow")] = "snow",
		[Idstring("ice")] = "ice_thick",
		[Idstring("aim_debug")] = "aim_debug",
		[Idstring("flesh_devil")] = "flesh",
		[Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")] = "fallback",
		[Idstring("bullet_hit")] = "default_blood",
		[Idstring("")] = "puff",
	}
	local idstring_id = nil
	for i, k in pairs(materials) do if material_name==i then idstring_id = k end end
end



function GamePlayCentralManager:auto_highlight_enemy(unit, use_player_upgrades, csc)
	if not csc then return end

	self._auto_highlighted_enemies = self._auto_highlighted_enemies or {}

	if self._auto_highlighted_enemies[unit:key()] and Application:time() < self._auto_highlighted_enemies[unit:key()] then
		return false
	end

	self._auto_highlighted_enemies[unit:key()] = Application:time() + (managers.groupai:state():whisper_mode() and 9 or 4)*0.05

	if not unit:contour() then
		debug_pause_unit(unit, "[GamePlayCentralManager:auto_highlight_enemy]: Unit doesn't have Contour Extension")
	end

	local time_multiplier = 1
	local contour_type = "mark_enemy"

	if unit:base() and unit:base().is_security_camera then
		contour_type = "mark_unit"
		time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
	elseif use_player_upgrades then
		contour_type = managers.player:get_contour_for_marked_enemy(unit:base().get_type and unit:base():get_type()) or contour_type
		time_multiplier = managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1)
	end

	unit:contour():add(contour_type, false, 0.05)

	return true
end