_G.NQR = _G.NQR or {}
NQR._path = ModPath
NQR._loc_path = ModPath .. "loc/"
NQR._settings_path = SavePath .. "NQR_Savefile.txt"



Hooks:PostHook(MenuManager, "init", "nqr_MenuManager:init", function(self, is_start_menu)
	if not (managers.menu and managers.menu._registered_menus.menu_main) then return end

	for i, k in pairs(managers.menu._registered_menus.menu_main.logic._data._nodes.main._items) do
		if k._parameters.name=="story_missions" then
			k._enabled = false
			k._parameters.help_id = "menu_wip"
			break
		end
	end
	for i, k in pairs(managers.menu._registered_menus.menu_main.logic._data._nodes.lobby._items) do
		if k._parameters.name=="story_missions" then
			k._enabled = false
			k._parameters.help_id = "menu_wip"
			break
		end
	end
end)



function MenuCrimeNetFiltersInitiator:modify_node(original_node, data)
	local node = original_node

	node:item("toggle_friends_only"):set_value(Global.game_settings.search_friends_only and "on" or "off")

	if MenuCallbackHandler:is_win32() then
		local matchmake_filters = managers.network.matchmake:lobby_filters()

		node:item("toggle_new_servers_only"):set_value(matchmake_filters.num_players and matchmake_filters.num_players.value or -1)
		node:item("toggle_server_state_lobby"):set_value(matchmake_filters.state and matchmake_filters.state.value or -1)
		node:item("toggle_job_appropriate_lobby"):set_value(Global.game_settings.search_appropriate_jobs and "on" or "off")
		node:item("toggle_allow_safehouses"):set_value(Global.game_settings.allow_search_safehouses and "on" or "off")
		node:item("toggle_mutated_lobby"):set_value(Global.game_settings.search_mutated_lobbies and "on" or "off")
		node:item("toggle_modded_lobby"):set_value(Global.game_settings.search_modded_lobbies and "on" or "off")
		node:item("toggle_one_down_lobby"):set_value(Global.game_settings.search_one_down_lobbies and "on" or "off")
		node:item("max_lobbies_filter"):set_value(managers.network.matchmake:get_lobby_return_count())
		node:item("server_filter"):set_value(managers.network.matchmake:distance_filter())
		node:item("difficulty_filter"):set_value(matchmake_filters.difficulty and matchmake_filters.difficulty.value or -1)
		node:item("job_plan_filter"):set_value(matchmake_filters.job_plan and matchmake_filters.job_plan.value or -1)
		node:item("gamemode_filter"):set_value(Global.game_settings.gamemode_filter or GamemodeStandard.id)
		node:item("max_spree_difference_filter"):set_value(Global.game_settings.crime_spree_max_lobby_diff or -1)
		node:item("skirmish_wave_filter"):set_value(Global.game_settings.skirmish_wave_filter or 99)

		local job_id_filter = node:item("job_id_filter")

		if job_id_filter then
			job_id_filter:set_value(managers.network.matchmake:get_lobby_filter("job_id") or -1)
			managers.network.matchmake:add_lobby_filter("job_id", job_id_filter:value(), "equal")
			managers.user:set_setting("crimenet_filter_contract", job_id_filter:value())
		end

		local kick_option_filter = node:item("kick_option_filter")

		if kick_option_filter then
			kick_option_filter:set_value(managers.network.matchmake:get_lobby_filter("kick_option") or -1)
		end

		self:add_filters(node)
	elseif MenuCallbackHandler:is_xb1() then
		node:item("difficulty_filter"):set_value(managers.network.matchmake:difficulty_filter() and "on" or "off")
		node:item("toggle_mutated_lobby"):set_value(Global.game_settings.search_mutated_lobbies and "on" or "off")
		node:item("toggle_crimespree_lobby"):set_value(Global.game_settings.search_crimespree_lobbies and "on" or "off")
		node:item("max_spree_difference_filter"):set_value(Global.game_settings.crime_spree_max_lobby_diff or -1)
	end

	self:update_node(node)

	if data and data.back_callback then
		table.insert(node:parameters().back_callback, data.back_callback)
	end

	node:parameters().menu_component_data = data

	local nodee = node:item("difficulty_filter")
	if nodee then
		if nodee._all_options then
			nodee._all_options[6] = nil
			nodee._all_options[2]._parameters.text_id = "menu_difficulty_easy"
			nodee._all_options[3]._parameters.text_id = "menu_difficulty_normal"
			nodee._all_options[4]._parameters.text_id = "menu_difficulty_hard"
		end
		if nodee._options then
			nodee._options[6] = nil
			nodee._options[2]._parameters.text_id = "menu_difficulty_easy"
			nodee._options[3]._parameters.text_id = "menu_difficulty_normal"
			nodee._options[4]._parameters.text_id = "menu_difficulty_hard"
		end
	end

	return node
end
function MenuQuickplaySettingsInitiator:modify_node(node)
	local stealth_item = node:item("quickplay_settings_stealth")
	local loud_item = node:item("quickplay_settings_loud")
	local stealth_on = managers.user:get_setting("quickplay_stealth")
	local loud_on = managers.user:get_setting("quickplay_loud")

	stealth_item:set_value(stealth_on and "on" or "off")
	loud_item:set_value(loud_on and "on" or "off")
	stealth_item:set_parameter("loud", loud_item)
	loud_item:set_parameter("stealth", stealth_item)
	node:item("quickplay_settings_level_min"):set_max(tweak_data.quickplay.max_level_diff[1])
	node:item("quickplay_settings_level_min"):set_value(Global.crimenet and Global.crimenet.quickplay and Global.crimenet.quickplay.level_diff_min or tweak_data.quickplay.default_level_diff[1])
	node:item("quickplay_settings_level_max"):set_max(tweak_data.quickplay.max_level_diff[2])
	node:item("quickplay_settings_level_max"):set_value(Global.crimenet and Global.crimenet.quickplay and Global.crimenet.quickplay.level_diff_max or tweak_data.quickplay.default_level_diff[2])

	local mutators_item = node:item("quickplay_settings_mutators")
	local mutators_on = managers.user:get_setting("quickplay_mutators")

	mutators_item:set_value(mutators_on and "on" or "off")

	local difficulty_item = node:item("quickplay_settings_difficulty")

	if not difficulty_item then
		local options = {
			{
				value = "any",
				text_id = "menu_any",
				_meta = "option"
			}
		}

		for _, difficulty in ipairs(tweak_data.difficulties) do
			if difficulty ~= "easy" then
				table.insert(options, {
					_meta = "option",
					text_id = tweak_data.difficulty_name_ids[difficulty],
					value = difficulty
				})
			end
		end

		difficulty_item = self:create_multichoice(node, options, {
			callback = "quickplay_difficulty",
			name = "quickplay_settings_difficulty",
			help_id = "menu_quickplay_settings_difficulty",
			text_id = "menu_quickplay_settings_difficulty"
		}, 1)
	end

	if Global.crimenet and Global.crimenet.quickplay and Global.crimenet.quickplay.difficulty then
		difficulty_item:set_value(Global.crimenet.quickplay.difficulty)
	else
		difficulty_item:set_value("any")
	end

	local nodee = difficulty_item
	if nodee then
		if nodee._all_options then
			nodee._all_options[6] = nil
			nodee._all_options[2]._parameters.text_id = "menu_difficulty_easy"
			nodee._all_options[3]._parameters.text_id = "menu_difficulty_normal"
			nodee._all_options[4]._parameters.text_id = "menu_difficulty_hard"
		end
		if nodee._options then
			nodee._options[6] = nil
			nodee._options[2]._parameters.text_id = "menu_difficulty_easy"
			nodee._options[3]._parameters.text_id = "menu_difficulty_normal"
			nodee._options[4]._parameters.text_id = "menu_difficulty_hard"
		end
	end

	return node
end
function MenuCrimeNetContactChillInitiator:modify_node(original_node, data)
	local node = original_node

	node:clean_items()

	local params = {
		callback = "_on_chill_change_difficulty",
		name = "difficulty",
		text_id = "menu_lobby_difficulty_title",
		help_id = "menu_diff_help",
		filter = true
	}
	local data_node = {
		{
			value = "normal",
			text_id = "menu_difficulty_easy",
			_meta = "option"
		},
		{
			value = "hard",
			text_id = "menu_difficulty_normal",
			_meta = "option"
		},
		{
			value = "overkill",
			text_id = "menu_difficulty_hard",
			_meta = "option"
		},
		{
			value = "overkill_145",
			text_id = "menu_difficulty_overkill",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(true)
	node:add_item(new_item)

	params = {
		callback = "_on_chill_change_one_down",
		name = "toggle_one_down",
		text_id = "menu_toggle_one_down"
	}
	data_node = {
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "on",
			s_w = "24",
			s_h = "24",
			s_x = "24",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "24",
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "off",
			s_w = "24",
			s_h = "24",
			s_x = "0",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "0",
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	new_item = node:create_item(data_node, params)

	new_item:set_value("off")
	new_item:set_enabled(true)
	node:add_item(new_item)

	params = {
		callback = "play_chill_combat",
		name = "CustomSafeHouseDefendBtn",
		align = "left",
		text_id = "menu_cn_chill_combat_defend"
	}
	data_node = {}
	new_item = node:create_item(data_node, params)

	new_item:set_enabled(true)
	node:add_item(new_item)

	params = {
		callback = "ignore_chill_combat",
		name = "CustomSafeHouseIgnoreBtn",
		align = "left",
		text_id = "menu_cn_chill_combat_ignore_defend"
	}
	data_node = {}
	new_item = node:create_item(data_node, params)

	new_item:set_enabled(true)
	node:add_item(new_item)

	params = {
		visible_callback = "is_pc_controller",
		name = "back",
		last_item = "true",
		text_id = "menu_back",
		align = "left",
		previous_node = "true"
	}
	data_node = {}
	new_item = node:create_item(data_node, params)

	node:add_item(new_item)
	node:set_default_item_name(self.DEFAULT_ITEM)
	node:select_item(self.DEFAULT_ITEM)

	return node
end

--SET SENSITIVITY: FIX FOV BASED SENS
local temp_vec1 = Vector3()
function MenuManager:set_mouse_sensitivity(zoomed)
	local zoom_sense = zoomed
	local sense_x, sense_y = nil

	if zoom_sense then
		sense_x = managers.user:get_setting("camera_zoom_sensitivity_x")
		sense_y = managers.user:get_setting("camera_zoom_sensitivity_y")
	else
		sense_x = managers.user:get_setting("camera_sensitivity_x")
		sense_y = managers.user:get_setting("camera_sensitivity_y")
	end

	if zoomed and managers.user:get_setting("enable_fov_based_sensitivity") and alive(managers.player:player_unit()) then
		local state = managers.player:player_unit():movement():current_state()

		if alive(state._equipped_unit) then
			local fov = managers.user:get_setting("fov_multiplier")
			local scale = math.max(state._equipped_unit:base():zoom() or 1, 1.1)
			sense_x = sense_x / scale
			sense_y = sense_y / scale
		end
	end

	local multiplier = temp_vec1

	mvector3.set_static(multiplier, sense_x * self._look_multiplier.x, sense_y * self._look_multiplier.y, 0)
	self._controller:get_setup():get_connection("look"):set_multiplier(multiplier)
	managers.controller:request_rebind_connections()
end



--SWAP THE STRING FOR BUYING A WEP PART
function MenuManager:show_confirm_blackmarket_weapon_mod_purchase(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_bm_purchase_mod", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_bm_purchase_coins_nqr", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

--REMOVE STRING WITH PART COST
function MenuManager:show_confirm_blackmarket_mod(params)
	local l_local = managers.localization
	local dialog_data = {
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_blackmarket_mod_" .. (params.add and "add" or "remove"), {
			mod = params.name
		}) .. "\n"
	}
	local warn_lost_mods = false

	if params.add and params.replaces and #params.replaces > 0 then
		dialog_data.text = dialog_data.text .. l_local:text("dialog_blackmarket_mod_replace", {
			mod = managers.weapon_factory:get_part_name_by_part_id(params.replaces[1])
		}) .. "\n"
		warn_lost_mods = true
	end

	if params.removes and #params.removes > 0 then
		local mods = ""

		for _, mod_name in ipairs(params.removes) do
			if Application:production_build() and managers.weapon_factory:is_part_standard_issue(params.factory_id, mod_name) then
				Application:error("[MenuManager:show_confirm_blackmarket_mod] Standard Issuse Part Detected!", inspect(params))
			end

			mods = mods .. "\n" .. managers.weapon_factory:get_part_name_by_part_id(mod_name)
		end

		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_conflict", {
			mods = mods
		}) .. "\n"
		warn_lost_mods = true
	end

	if not params.ignore_lost_mods and (warn_lost_mods or not params.add) then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_lost_mods_warning")
	end

	--[[if params.add and params.money then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_cost", {
			money = params.money
		})
	end]]

	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuCustomizeGadgetInitiator:setup_node(node, data)
	node:clean_items()

	data = data or node:parameters().menu_component_data
	local part_id = data.name
	local slot = data.slot
	local category = data.category
	local mod_td = tweak_data.weapon.factory.parts[part_id]
	local show_laser = mod_td.sub_type == "laser"
	local show_flashlight = mod_td.sub_type == "flashlight"

	if mod_td.adds then
		for _, part_id in ipairs(mod_td.adds) do
			local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type
			show_laser = sub_type == "laser" or show_laser
			show_flashlight = sub_type == "flashlight" or show_flashlight
		end
	end

	if not node:item("divider_end") then
		if show_laser then
			self:create_slider(node, {
				max = 360,
				name = "laser_hue",
				min = 0,
				callback = "set_gadget_laser_hue",
				step = 5,
				text_id = "bm_menu_laser_hue",
				show_value = true
			})
			self:create_slider(node, {
				min = 0,
				name = "laser_sat",
				max = 1,
				callback = "set_gadget_laser_sat",
				step = 0.02,
				text_id = "bm_menu_laser_sat",
				default_value = 1,
				show_value = true
			})
			self:create_slider(node, {
				name = "laser_val",
				max = 1,
				callback = "set_gadget_laser_val",
				step = 0.02,
				text_id = "bm_menu_laser_val",
				default_value = 1,
				show_value = true,
				min = tweak_data.custom_colors.defaults.laser_alpha
			})
			self:create_divider(node, "laser_divider", nil, 64)
		end

		if show_flashlight then
			self:create_slider(node, {
				max = 360,
				name = "flashlight_hue",
				min = 0,
				callback = "set_gadget_flashlight_hue",
				step = 5,
				text_id = "bm_menu_flashlight_hue",
				show_value = true
			})
			self:create_slider(node, {
				min = 0,
				name = "flashlight_sat",
				max = 1,
				callback = "set_gadget_flashlight_sat",
				step = 0.02,
				text_id = "bm_menu_flashlight_sat",
				default_value = 1,
				show_value = true
			})
			self:create_slider(node, {
				min = 0,
				name = "flashlight_val",
				max = 1,
				callback = "set_gadget_flashlight_val",
				step = 0.02,
				text_id = "bm_menu_flashlight_val",
				default_value = 1,
				show_value = true
			})
			self:create_divider(node, "flashlight_divider", nil, 64)
		end
	end

	local enabled = false
	local params = {
		callback = "set_gadget_customize_params",
		name = "confirm",
		text_id = "dialog_apply",
		align = "right",
		enabled = enabled,
		disabled_color = tweak_data.screen_colors.important_1
	}
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	local params = {
		last_item = "true",
		name = "back",
		text_id = "dialog_cancel",
		align = "right",
		previous_node = "true"
	}
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)

	if show_laser then
		node:set_default_item_name("laser_hue")
		node:select_item("laser_hue")
	elseif show_flashlight then
		node:set_default_item_name("flashlight_hue")
		node:select_item("flashlight_hue")
	end

	node:parameters().menu_component_data = data
	node:parameters().set_blackmarket_enabled = false
	local l_hue = node:item("laser_hue")
	local l_sat = node:item("laser_sat")
	local l_val = node:item("laser_val")
	local f_hue = node:item("flashlight_hue")
	local f_sat = node:item("flashlight_sat")
	local f_val = node:item("flashlight_val")
	local part_id = data.name
	local colors = managers.blackmarket:get_part_custom_colors(data.category, data.slot, data.name)

	if colors and colors.laser and l_hue and l_sat and l_val then
		local h, s, v = rgb_to_hsv(colors.laser.r, colors.laser.g, colors.laser.b)

		l_hue:set_value(h)
		l_sat:set_value(s)
		l_val:set_value(v)
	end

	if colors and colors.flashlight and f_hue and f_sat and f_val then
		local h, s, v = rgb_to_hsv(colors.flashlight.r, colors.flashlight.g, colors.flashlight.b)

		f_hue:set_value(h)
		f_sat:set_value(s)
		f_val:set_value(v)
	end

	return node
end



function MenuManager:show_new_player_popup(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_skip_progression_title"),
		text = managers.localization:text("dialog_skip_progression")
	}

	local function yes_func()
		managers.experience:add_points(100000000, nil, true)
		managers.money:_set_total(100000000)
		managers.money:_set_offshore(100000000)
	end

	local no_button = {
		text = managers.localization:text("dialog_skip_progression_no")
	}
	local yes_button = {
		text = managers.localization:text("dialog_skip_progression_yes"),
		callback_func = yes_func,
	}
	dialog_data.button_list = {
		no_button,
		yes_button,
	}

	managers.system_menu:show(dialog_data)
end



function NQR:Reset()
	NQR.settings = {
        nqr_wanted_sight = 2,
		nqr_retention_time = 0.2,
		nqr_secondsightangle_value = 45,
	}
end
function NQR:Save()
	local file = io.open( NQR._settings_path, "w+" )
	if file then
		file:write( json.encode( NQR.settings ) )
		file:close()
	end
end
function NQR:Load()
	local file = io.open( NQR._settings_path, "r" )
	if file then
		NQR.settings = json.decode( file:read("*all") )
		file:close()
	else
		NQR:Reset()
		NQR:Save()
	end
end
NQR:Load()

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NQR", function( loc )
	for i, k in pairs(file.GetFiles(NQR._loc_path)) do
		if Idstring(k:match('^(.*).txt$') or ""):key()==SystemInfo:language():key() then
			loc:load_localization_file(NQR._loc_path .. k)
			break
		end
	end
	loc:load_localization_file(NQR._loc_path .. "english.txt", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_NQR", function( menu_manager )

	MenuCallbackHandler.nqr_wanted_sight_choice_callback = function(self, item)
		NQR.settings.nqr_wanted_sight = item:value()
		NQR:Save()
	end

	MenuCallbackHandler.nqr_retention_callback = function(self, item)
		NQR.settings.nqr_retention_time = item:value()
		NQR:Save()
	end

	MenuCallbackHandler.nqr_secondsightangle_callback = function(self, item)
		NQR.settings.nqr_secondsightangle_value = item:value()
		NQR:Save()
	end

	MenuCallbackHandler.nqr_reset_callback = function(self, item)
		NQR:Reset()
		MenuHelper:ResetItemsToDefaultValue(item, {["nqr_wanted_sight_choice"] = true}, NQR.settings.nqr_wanted_sight)
		MenuHelper:ResetItemsToDefaultValue(item, {["nqr_retention_slider"] = true}, NQR.settings.nqr_retention_time)
		MenuHelper:ResetItemsToDefaultValue(item, {["nqr_secondsightangle_slider"] = true}, NQR.settings.nqr_secondsightangle_value)
		NQR:Save()
	end

	NQR:Load()
	MenuHelper:LoadFromJsonFile( NQR._path .. "nqr_modoptions.json", NQR, NQR.settings )

end)

