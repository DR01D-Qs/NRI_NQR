local ids_unit = Idstring("unit")
local ids_NORMAL = Idstring("NORMAL")
NetworkPeer = NetworkPeer or class()
NetworkPeer.PRE_HANDSHAKE_CHK_TIME = 8
local IDS_STEAM = Idstring("STEAM")
local IDS_EPIC = Idstring("EPIC")



function NetworkPeer:melee_id()
	local outfit_string = self:profile("outfit_string")
	local data = string.split(outfit_string, " ")

	return data[managers.blackmarket:outfit_string_index("melee_weapon")] or "fists"
end



function NetworkPeer:_reload_outfit()
	if self._profile.outfit_string == "" then
		return
	end

	self._loading_outfit_assets = true
	local is_local_peer = self == managers.network:session():local_peer()
	local new_outfit_assets = {
		unit = {},
		texture = {}
	}
	local old_outfit_assets = self._outfit_assets

	print("[NetworkPeer:_reload_outfit]", is_local_peer and "local_peer" or self._id, self._profile.outfit_string)

	local asset_load_result_clbk = callback(self, self, "clbk_outfit_asset_loaded", new_outfit_assets)
	local texture_load_result_clbk = callback(self, self, "clbk_outfit_texture_loaded", new_outfit_assets)
	local complete_outfit = self:blackmarket_outfit()
	local mask_id = complete_outfit.mask.mask_id
	local mask_u_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id, self._id)
	local mask_asset_data = {
		name = Idstring(mask_u_name)
	}
	new_outfit_assets.unit.mask = mask_asset_data
	local mask_blueprint = self:mask_blueprint()
	local mask_pattern_id = mask_blueprint.pattern.id
	local mask_pattern_texture = tweak_data.blackmarket.textures[mask_pattern_id].texture
	local mask_pattern_texture_asset_data = {
		name = Idstring(mask_pattern_texture)
	}
	new_outfit_assets.texture.mask_pattern = mask_pattern_texture_asset_data
	local mask_material_id = mask_blueprint.material.id
	local mask_reflection_texture = tweak_data.blackmarket.materials[mask_material_id].texture
	local mask_reflection_texture_asset_data = {
		name = Idstring(mask_reflection_texture)
	}
	new_outfit_assets.texture.mask_reflection = mask_reflection_texture_asset_data

	if is_local_peer then
		local mask_backstraps_asset_data = {
			name = Idstring("units/payday2/masks/msk_fps_back_straps/msk_fps_back_straps")
		}
		new_outfit_assets.unit.mask_backstraps = mask_backstraps_asset_data
	end

	local factory_id = complete_outfit.primary.factory_id .. (is_local_peer and "" or "_npc")
	local ids_primary_u_name = Idstring(managers.weapon_factory:get_weapon_unit(factory_id, complete_outfit.primary.blueprint))
	new_outfit_assets.unit.primary_w = {
		name = ids_primary_u_name
	}
	local use_fps_parts = is_local_peer or managers.weapon_factory:use_thq_weapon_parts() and not tweak_data.weapon.factory[factory_id].skip_thq_parts
	local primary_w_parts = managers.weapon_factory:preload_blueprint(complete_outfit.primary.factory_id, complete_outfit.primary.blueprint, not use_fps_parts, not is_local_peer, function ()
	end, true)

	for part_id, part in pairs(primary_w_parts) do
		new_outfit_assets.unit["prim_w_part_" .. tostring(part_id)] = {
			name = part.name
		}
	end

	local factory_id = complete_outfit.secondary.factory_id .. (is_local_peer and "" or "_npc")
	local ids_secondary_u_name = Idstring(managers.weapon_factory:get_weapon_unit(factory_id, complete_outfit.secondary.blueprint))
	new_outfit_assets.unit.secondary_w = {
		name = ids_secondary_u_name
	}
	local use_fps_parts = is_local_peer or managers.weapon_factory:use_thq_weapon_parts() and not tweak_data.weapon.factory[factory_id].skip_thq_parts
	local secondary_w_parts = managers.weapon_factory:preload_blueprint(complete_outfit.secondary.factory_id, complete_outfit.secondary.blueprint, not use_fps_parts, not is_local_peer, function ()
	end, true)

	for part_id, part in pairs(secondary_w_parts) do
		new_outfit_assets.unit["sec_w_part_" .. tostring(part_id)] = {
			name = part.name
		}
	end

	if complete_outfit.melee_weapon then
		local melee_tweak_data = tweak_data.blackmarket.melee_weapons[complete_outfit.melee_weapon]
		local melee_u_name = is_local_peer and melee_tweak_data.unit or melee_tweak_data.third_unit

		if melee_u_name then
			new_outfit_assets.unit.melee_w = {
				name = Idstring(melee_u_name)
			}
		end
	end

	local grenade_tweak_data = tweak_data.blackmarket.projectiles[complete_outfit.grenade]
	local grenade_u_name = grenade_tweak_data.unit

	if grenade_u_name then
		new_outfit_assets.unit.grenade_w = {
			name = Idstring(grenade_u_name)
		}
	end

	local grenade_sprint_u_name = grenade_tweak_data.sprint_unit

	if grenade_sprint_u_name then
		new_outfit_assets.unit.grenade_sprint_w = {
			name = Idstring(grenade_sprint_u_name)
		}
	end

	if is_local_peer then
		local grenade_dummy_u_name = grenade_tweak_data.unit_dummy

		if grenade_dummy_u_name then
			new_outfit_assets.unit.grenade_dummy_w = {
				name = Idstring(grenade_dummy_u_name)
			}
		end
	end

	local player_style_u_name = tweak_data.blackmarket:get_player_style_value(complete_outfit.player_style, self._character, is_local_peer and "unit" or "third_unit")

	if player_style_u_name then
		new_outfit_assets.unit.player_style_w = {
			name = Idstring(player_style_u_name)
		}
	end

	local glove_u_name = tweak_data.blackmarket:get_glove_value(complete_outfit.glove_id, self._character, "unit", complete_outfit.player_style, complete_outfit.suit_variation)

	if glove_u_name then
		new_outfit_assets.unit.gloves_w = {
			name = Idstring(glove_u_name)
		}
	end

	if complete_outfit.deployable and not is_local_peer then
		local deployable_tweak_data = tweak_data.equipments[complete_outfit.deployable]

		if deployable_tweak_data.visual_style then
			local deployable_style_u_name = tweak_data.blackmarket:get_player_style_value(deployable_tweak_data.visual_style, self._character, "third_unit")

			if deployable_style_u_name then
				new_outfit_assets.unit.deployable_style_w = {
					name = Idstring(deployable_style_u_name)
				}
			end
		end
	end

	self._outfit_assets = new_outfit_assets

	for asset_id, asset_data in pairs(new_outfit_assets.unit) do
		asset_data.is_streaming = true

		managers.dyn_resource:load(ids_unit, asset_data.name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, asset_load_result_clbk)
	end

	for asset_id, asset_data in pairs(new_outfit_assets.texture) do
		asset_data.is_streaming = true

		TextureCache:request(asset_data.name, ids_NORMAL, texture_load_result_clbk, 90)
	end

	self._all_outfit_load_requests_sent = true
	self._outfit_assets = old_outfit_assets

	self:_unload_outfit()

	self._outfit_assets = new_outfit_assets

	self:_chk_outfit_loading_complete()

	if self._all_outfit_load_requests_sent and alive(self._unit) then
		local character = managers.criminals and managers.criminals:character_by_name(self._character)

		if character and character.visual_state then
			local default_while_loading_state = {}

			if character.visual_state.player_style ~= complete_outfit.player_style then
				default_while_loading_state.player_style = "none"
				default_while_loading_state.suit_variation = "default"
			end

			if character.visual_state.glove_id ~= complete_outfit.glove_id then
				default_while_loading_state.glove_id = managers.blackmarket:get_default_glove_id()
			end

			if table.size(default_while_loading_state) > 0 then
				self:update_character_visual_state(default_while_loading_state)
			end
		end
	end
end
