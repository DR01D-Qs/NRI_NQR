require("lib/managers/menu/WalletGuiObject")
require("lib/utils/InventoryDescription")
require("lib/utils/accelbyte/TelemetryConst")
require("lib/managers/menu/ExtendedPanel")
require("lib/utils/gui/FineText")
require("lib/managers/menu/UiPlacer")

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 6.9 or 6.95) / 8
local ITEMS_PER_ROW = 3
local ITEMS_PER_COLUMN = 3
local BUY_MASK_SLOTS = {
	7,
	4
}
local WEAPON_MODS_SLOTS = {
	6,
	1
}
local WEAPON_MODS_GRID_H_MUL = 0.126
local DEFAULT_LOCKED_BLEND_MODE = "normal"
local DEFAULT_LOCKED_BLEND_ALPHA = 0.35
local DEFAULT_LOCKED_COLOR = Color(1, 1, 1)
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

local function format_round(num, round_value)
	if type(num)=="number" then
		return round_value=="hunds" and string.format("%.2f", num) or round_value and ""..math.round(num) or string.format("%.1f", num):gsub("%.?0+$", "")
	else
		return num
	end
end

BlackMarketGuiItem = BlackMarketGuiItem or class()

function BlackMarketGuiItem:init(main_panel, data, x, y, w, h)
	self._main_panel = main_panel
	self._panel = main_panel:panel({
		name = tostring(data.name),
		x = x,
		y = y,
		w = w,
		h = h
	})
	self._data = data or {}
	self._name = data.name
	self._child_panel = nil
	self._alpha = 1
end

function BlackMarketGuiItem:inside(x, y)
	return self._panel:inside(x, y)
end

function BlackMarketGuiItem:select(instant, no_sound)
	if not self._selected then
		self._selected = true

		self:refresh()

		if not instant and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function BlackMarketGuiItem:deselect(instant)
	if self._selected then
		self._selected = false
	end

	self:refresh()
end

function BlackMarketGuiItem:set_highlight(highlight, no_sound)
	if self._highlighted ~= highlight then
		self._highlighted = highlight

		self:refresh()

		if highlight and not no_sound then
			managers.menu_component:post_event("highlight")
		end
	end
end

function BlackMarketGuiItem:refresh()
	self._alpha = self._selected and 1 or self._highlighted and 0.85 or 0.7

	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end
end

function BlackMarketGuiItem:mouse_pressed(button, x, y)
	return self._panel:inside(x, y)
end

function BlackMarketGuiItem:mouse_moved(x, y)
	return false, "arrow"
end

function BlackMarketGuiItem:mouse_released(button, x, y)
end

function BlackMarketGuiItem:destroy()
end

function BlackMarketGuiItem:is_inside_scrollbar(x, y)
	return false
end

BlackMarketGuiTabItem = BlackMarketGuiTabItem or class(BlackMarketGuiItem)

function BlackMarketGuiTabItem:init(main_panel, data, node, size_data, hide_select_rect, scroll_tab_table, parent)
	BlackMarketGuiTabItem.super.init(self, main_panel, data, 0, 0, main_panel:w(), main_panel:h())

	local grid_panel_w = size_data.grid_w
	local grid_panel_h = size_data.grid_h
	local square_w = size_data.square_w
	local square_h = size_data.square_h
	local padding_w = size_data.padding_w
	local padding_h = size_data.padding_h
	local left_padding = size_data.left_padding
	local top_padding = size_data.top_padding
	self._size_data = size_data
	self._node = node

	self._data.on_create_func(self._data, parent)

	local slots = data.override_slots or {
		size_data.items_per_row,
		size_data.items_per_column
	}
	slots[1] = math.max(1, slots[1])
	slots[2] = math.max(1, slots[2])
	self.my_slots_dimensions = slots
	square_w = square_w * size_data.items_per_row / slots[1]
	square_h = square_h * size_data.items_per_column / slots[2]

	if slots[2] == 1 then
		square_h = grid_panel_h
	end

	self._square_w = square_w
	self._square_h = square_h
	self._tab_panel = scroll_tab_table.panel:panel({
		name = "tab_panel"
	})
	self._tab_text_string = utf8.to_upper(data.name_localized or managers.localization:text(data.name))
	local text = self._tab_panel:text({
		vertical = "center",
		name = "tab_text",
		align = "center",
		blend_mode = "add",
		layer = 1,
		text = self._tab_text_string,
		font_size = medium_font_size,
		font = medium_font,
		color = tweak_data.screen_colors.button_stage_3,
		visible = not hide_select_rect
	})

	BlackMarketGui.make_fine_text(self, text)

	local _, _, tw, th = text:text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	self._tab_panel:child("tab_text"):set_size(self._tab_panel:size())
	self._tab_panel:set_center_x(self._panel:w() / 2)
	self._tab_panel:set_y(0)
	self._tab_panel:bitmap({
		texture = "guis/textures/pd2/shared_tab_box",
		name = "tab_select_rect",
		visible = false,
		layer = 0,
		w = self._tab_panel:w(),
		h = self._tab_panel:h(),
		color = tweak_data.screen_colors.text:with_alpha(hide_select_rect and 0 or 1)
	})
	table.insert(scroll_tab_table, self._tab_panel)

	self._child_panel = self._panel:panel()
	self._grid_panel = self._child_panel:panel({
		name = "grid_panel",
		layer = 1,
		w = grid_panel_w,
		h = grid_panel_h
	})

	self._grid_panel:set_left(0)
	self._grid_panel:set_top(self._tab_panel:bottom() - 2 + top_padding)
	self._grid_panel:rect({
		layer = -10,
		color = Color.white:with_alpha(0)
	})

	self._grid_scroll_panel = self._grid_panel:panel({
		halign = "grow",
		name = "grid_scroll_panel"
	})
	self._node:parameters().menu_component_tabs = self._node:parameters().menu_component_tabs or {}
	self._node:parameters().menu_component_tabs[data.name] = self._node:parameters().menu_component_tabs[data.name] or {}
	self._my_node_data = self._node:parameters().menu_component_tabs[data.name]

	if slots[2] ~= 1 then
		self._grid_scroll_panel:set_h(grid_panel_h / slots[2] * #self._data / slots[1])
	else
		self._grid_scroll_panel:set_w(grid_panel_w * math.ceil(#self._data / slots[1]))
	end

	local y_scrolling = slots[2] ~= 1 and self._grid_panel:h() < self._grid_scroll_panel:h()

	if y_scrolling then
		-- Nothing
	end

	local x_scrolling = slots[2] == 1 and self._grid_panel:w() < self._grid_scroll_panel:w()

	if x_scrolling then
		self._tab_pages_panel = self._panel:panel({
			w = self._grid_panel:w(),
			h = medium_font_size
		})

		self._tab_pages_panel:set_top(self._grid_panel:bottom() + 2)

		local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
		local tab_pages = math.ceil(#self._data / slots[1])
		local previous_page = self._tab_pages_panel:bitmap({
			name = "previous_page",
			blend_mode = "add",
			layer = 1,
			rotation = -90,
			texture = texture,
			texture_rect = rect,
			color = tweak_data.screen_colors.button_stage_3
		})

		previous_page:set_center_y(self._tab_pages_panel:h() / 2)

		local prev_item = previous_page
		local tab_string, tab_text = nil
		local tab_page_strings = self._data.tab_page_strings or {}

		for i = 1, tab_pages do
			tab_string = tab_page_strings[i] or tostring(i)
			tab_text = self._tab_pages_panel:text({
				blend_mode = "add",
				layer = 1,
				name = tostring(i),
				text = tab_string,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})

			BlackMarketGui.make_fine_text(self, tab_text)
			tab_text:set_left(prev_item:right() + 6)

			prev_item = tab_text
		end

		local next_page = self._tab_pages_panel:bitmap({
			name = "next_page",
			blend_mode = "add",
			layer = 1,
			rotation = 90,
			texture = texture,
			texture_rect = rect,
			color = tweak_data.screen_colors.button_stage_3
		})

		next_page:set_center_y(self._tab_pages_panel:h() / 2)
		next_page:set_left(prev_item:right() + 6)
		self._tab_pages_panel:set_w(next_page:right())
		self._tab_pages_panel:set_right(self._grid_panel:right())
	end

	self._slots = {}
	local slot_equipped = 1

	for index, data in ipairs(self._data) do
		local new_slot_class = BlackMarketGuiSlotItem

		if data.unique_slot_class then
			new_slot_class = _G[data.unique_slot_class]
		end

		local x_index = slots[2] == 1 and index - 1 or (index - 1) % slots[1]
		local y_index = slots[2] == 1 and 0 or math.floor((index - 1) / slots[1])
		local x = math.floor(padding_w + x_index * (square_w + padding_w))
		local y = math.floor(padding_h + y_index * (square_h + padding_h))
		local new_slot = new_slot_class:new(self._grid_scroll_panel, data, x, y, square_w, square_h)

		new_slot.rect_bg:set_alpha(y_scrolling and y_index % 2 == 1 and 0.1 or 0)
		table.insert(self._slots, new_slot)

		if data.equipped then
			slot_equipped = index
		end

		if self._init_slot then
			self:_init_slot(data, new_slot)
		end
	end

	self._max_y_index = slots[2] == 1 and 0 or math.ceil(#self._data / slots[1])
	self.my_scroll_slots_y = slots[2] == 1 and 1 or math.max(self.my_slots_dimensions[2], math.ceil(#self._data / self.my_slots_dimensions[1]))
	self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index or 1

	self:check_new_drop()

	self._scroll_bar_panel = self._child_panel:panel({
		name = "scroll_bar_panel",
		w = BOX_GAP + 0,
		h = self._grid_panel:h()
	})

	self._scroll_bar_panel:set_left(self._grid_panel:right())
	self._scroll_bar_panel:set_top(self._grid_panel:top())

	self._scroll_indicator_box_class = BoxGuiObject:new(self._grid_panel, {
		sides = {
			0,
			0,
			0,
			0
		}
	})
	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_up_indicator_arrow = self._scroll_bar_panel:bitmap({
		name = "scroll_up_indicator_arrow",
		layer = 2,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_up_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

	local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:bitmap({
		name = "scroll_down_indicator_arrow",
		layer = 2,
		rotation = 180,
		texture = texture,
		texture_rect = rect,
		color = Color.white
	})

	scroll_down_indicator_arrow:set_bottom(self._scroll_bar_panel:h())
	scroll_down_indicator_arrow:set_center_x(self._scroll_bar_panel:w() / 2)

	local bar_h = scroll_down_indicator_arrow:top() - scroll_up_indicator_arrow:bottom()

	self._scroll_bar_panel:rect({
		alpha = 0.05,
		w = 4,
		x = 4,
		color = Color.black,
		y = scroll_up_indicator_arrow:bottom(),
		h = bar_h
	})

	bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
	local scroll_bar = self._scroll_bar_panel:panel({
		name = "scroll_bar",
		layer = 2,
		h = bar_h,
		w = self._scroll_bar_panel:w()
	})
	local scroll_bar_box_panel = scroll_bar:panel({
		w = 4,
		name = "scroll_bar_box_panel",
		valign = "scale",
		halign = "scale"
	})

	scroll_bar_box_panel:set_center_x(scroll_bar:w() / 2)

	self._scroll_bar_box_class = BoxGuiObject:new(scroll_bar_box_panel, {
		sides = {
			2,
			2,
			0,
			0
		}
	})

	self._scroll_bar_box_class:set_aligns("scale", "scale")
	scroll_bar:set_top(scroll_up_indicator_arrow:bottom())
	scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())
	scroll_bar_box_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		layer = -1,
		halign = "scale",
		render_template = "VertexColorTexturedBlur3D",
		valign = "scale",
		w = scroll_bar_box_panel:w(),
		h = scroll_bar_box_panel:h()
	})

	self._slot_selected = #self._slots > 0 and (self._my_node_data.selected or slot_equipped)
	self._slot_highlighted = nil

	self:set_scroll_y(self._slot_selected)
	self:deselect(true)
	self:set_highlight(false)
end

function BlackMarketGuiTabItem:has_scroll_bar(button)
	if alive(self._scroll_bar_panel) and self._scroll_bar_panel:visible() then
		return true
	end

	if alive(self._tab_pages_panel) and self._tab_pages_panel:visible() then
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local slot_selected = self._slot_selected or 1
		local i = math.ceil(slot_selected / num_per_page)
		local pages = math.ceil(#self._slots / num_per_page)

		if button == Idstring("mouse wheel down") then
			return i ~= pages
		elseif button == Idstring("mouse wheel up") then
			return i ~= 1
		end

		return true
	end

	return false
end

function BlackMarketGuiTabItem:is_inside_scrollbar(x, y)
	if self._scroll_bar_panel:visible() and self._scroll_bar_panel:inside(x, y) then
		return true
	end

	return false
end

function BlackMarketGuiTabItem:destroy()
	for i, slot in ipairs(self._slots) do
		slot:destroy()
	end
end

function BlackMarketGuiTabItem:deselect(instant)
	self:release_scroll_bar()
	BlackMarketGuiTabItem.super.deselect(self, instant)
end

function BlackMarketGuiTabItem:set_tab_text(new_text)
	local text = self._tab_panel:child("tab_text")

	text:set_text(new_text)
	BlackMarketGui.make_fine_text(self, text)

	local _, _, tw, th = text:text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	text:set_size(self._tab_panel:size())
	self._tab_panel:child("tab_select_rect"):set_size(self._tab_panel:size())
end

function BlackMarketGuiTabItem:check_new_drop(first_time)
	local got_new_drop = false

	for _, slot in pairs(self._slots) do
		if slot._data.new_drop_data and slot._data.new_drop_data.icon then
			got_new_drop = true

			break
		end
	end

	local tab_text_string = self._tab_text_string

	if got_new_drop then
		tab_text_string = tab_text_string .. "" .. managers.localization:get_default_macro("BTN_INV_NEW")
	end

	self:set_tab_text(tab_text_string)
end

function BlackMarketGuiTabItem:refresh()
	self._alpha = 1

	if self._selected then
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_1)
		self._tab_panel:child("tab_text"):set_blend_mode("normal")
		self._tab_panel:child("tab_select_rect"):show()
	elseif self._highlighted then
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_2)
		self._tab_panel:child("tab_text"):set_blend_mode("add")
		self._tab_panel:child("tab_select_rect"):hide()
	else
		self._tab_panel:child("tab_text"):set_color(tweak_data.screen_colors.button_stage_3)
		self._tab_panel:child("tab_text"):set_blend_mode("add")
		self._tab_panel:child("tab_select_rect"):hide()
	end

	if self._child_panel and alive(self._child_panel) then
		self._child_panel:set_visible(self._selected)
	end

	if alive(self._tab_pages_panel) then
		self._tab_pages_panel:set_visible(self._selected)
	end
end

function BlackMarketGuiTabItem:set_tab_position(x)
	self._tab_panel:set_x(x)

	local _, _, tw, th = self._tab_panel:child("tab_text"):text_rect()

	self._tab_panel:set_size(tw + 15, th + 10)
	self._tab_panel:child("tab_text"):set_size(self._tab_panel:size())

	if self._new_drop_icon then
		self._new_drop_icon:set_leftbottom(0, 0)
	end

	return math.round(x + tw + 15 + 5)
end

function BlackMarketGuiTabItem:get_slot_by_mouse_position(x, y)
	if not self._selected then
		return
	end

	if not self._grid_panel:inside(x, y) then
		return
	end

	for i, slot in ipairs(self._slots) do
		if slot._name ~= "empty" and slot:inside(x, y) then
			return i
		end
	end
end

function BlackMarketGuiTabItem:inside_tab(x, y)
	return self._tab_panel:inside(x, y)
end

function BlackMarketGuiTabItem:inside(x, y)
	if self._tab_panel:inside(x, y) then
		return true
	end

	if not self._selected then
		return
	end

	if alive(self._tab_pages_panel) and self._tab_pages_panel:inside(x, y) then
		for _, child in ipairs(self._tab_pages_panel:children()) do
			if child:inside(x, y) then
				return 1
			end
		end
	end

	if not self._grid_panel:inside(x, y) then
		return
	end

	local update_select = false
	local result = not self._is_empty_slot_highlighted and 1 or false

	if not self._slot_highlighted then
		update_select = true
		result = false
	elseif self._slots[self._slot_highlighted] and not self._slots[self._slot_highlighted]:inside(x, y) then
		self._slots[self._slot_highlighted]:set_highlight(false)

		self._slot_highlighted = nil
		update_select = true
		result = false
	end

	if update_select then
		for i, slot in ipairs(self._slots) do
			if slot:inside(x, y) then
				self._slot_highlighted = i

				self._slots[self._slot_highlighted]:set_highlight(true)

				self._is_empty_slot_highlighted = self._slots[self._slot_highlighted]._name == "empty"

				return not self._is_empty_slot_highlighted and 1 or false
			end
		end
	end

	return result
end

function BlackMarketGuiTabItem:mouse_pressed(button, x, y)
	if alive(self._scroll_bar_panel) and self._scroll_bar_panel:visible() then
		if button == Idstring("mouse wheel down") then
			local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1

			if self._max_y_index <= self._my_node_data.scroll_y_index + max_view_y then
				self._my_node_data.scroll_y_index = self._max_y_index - max_view_y
			else
				self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index + 1
			end

			self:set_scroll_y()

			return self._slots[self._slot_selected]
		elseif button == Idstring("mouse wheel up") then
			local max_view_y = self.my_slots_dimensions[2] or ITEMS_PER_COLUMN

			if self._my_node_data.scroll_y_index <= 1 then
				self._my_node_data.scroll_y_index = 1
			else
				self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index - 1
			end

			self:set_scroll_y()

			return self._slots[self._slot_selected]
		end
	end

	if self:check_grab_scroll_bar(x, y) then
		return self._slots[self._slot_selected]
	end

	if alive(self._tab_pages_panel) then
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local slot_selected = self._slot_selected

		if button == Idstring("mouse wheel down") then
			slot_selected = math.min(slot_selected + num_per_page, #self._slots)

			return self:select_slot(slot_selected)
		elseif button == Idstring("mouse wheel up") then
			slot_selected = math.max(slot_selected - num_per_page, 1)

			return self:select_slot(slot_selected)
		elseif button == Idstring("0") then
			local child_name = nil

			for _, child in ipairs(self._tab_pages_panel:children()) do
				if child:inside(x, y) then
					child_name = child:name()

					if child_name == "previous_page" then
						slot_selected = math.max(slot_selected - num_per_page, 1)

						return self:select_slot(slot_selected)
					elseif child_name == "next_page" then
						slot_selected = math.min(slot_selected + num_per_page, #self._slots)

						return self:select_slot(slot_selected)
					else
						local current_page = math.ceil(slot_selected / num_per_page)
						local wanted_page = tonumber(child_name)

						if current_page ~= wanted_page then
							local diff_page = wanted_page - current_page
							slot_selected = math.clamp(slot_selected + diff_page * num_per_page, 1, #self._slots)

							return self:select_slot(slot_selected)
						end
					end
				end
			end
		end
	end

	if button ~= Idstring("0") or button == Idstring("1") then
		return
	end

	if not self._slots[self._slot_highlighted] then
		return
	end

	if self._slots[self._slot_selected] == self._slots[self._slot_highlighted] then
		return
	end

	if self._slots[self._slot_highlighted] and self._slots[self._slot_highlighted]:inside(x, y) then
		if self._slots[self._slot_selected] then
			self._slots[self._slot_selected]:deselect(false)
		end

		return self:select_slot(self._slot_highlighted)
	end
end

function BlackMarketGuiTabItem:mouse_moved(x, y)
	if alive(self._tab_pages_panel) then
		self._tab_pages_highlighted = self._tab_pages_highlighted or {}
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local used = false
		local pointer = "arrow"

		for _, child in ipairs(self._tab_pages_panel:children()) do
			if tonumber(child:name()) == math.ceil(self._slot_selected / num_per_page) then
				child:set_color(tweak_data.screen_colors.button_stage_2)
			elseif child:inside(x, y) then
				if not self._tab_pages_highlighted[_] then
					self._tab_pages_highlighted[_] = true

					child:set_color(tweak_data.screen_colors.button_stage_2)
					managers.menu_component:post_event("highlight")
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._tab_pages_highlighted[_] then
				self._tab_pages_highlighted[_] = false

				child:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end

		if used then
			return used, pointer
		end
	end

	return self:moved_scroll_bar(x, y)
end

function BlackMarketGuiTabItem:mouse_released(button, x, y)
	self:release_scroll_bar()
end

function BlackMarketGuiTabItem:check_grab_scroll_bar(x, y)
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

	if self._scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		self._grabbed_scroll_bar = true
		self._current_scroll_bar_y = y

		return true
	end

	local height = self._square_h + self._size_data.padding_h

	if self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		self._my_node_data.scroll_y_index = math.max(self._my_node_data.scroll_y_index - 1, 1)
		self._pressing_arrow_up = true

		self:set_scroll_y()

		return true
	end

	if self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		self._my_node_data.scroll_y_index = math.min(self._my_node_data.scroll_y_index + 1, self._max_y_index)
		self._pressing_arrow_down = true

		self:set_scroll_y()

		return true
	end

	return false
end

function BlackMarketGuiTabItem:release_scroll_bar()
	self._pressing_arrow_up = nil
	self._pressing_arrow_down = nil

	if self._grabbed_scroll_bar then
		self._grabbed_scroll_bar = nil

		return true
	end

	return false
end

function BlackMarketGuiTabItem:moved_scroll_bar(x, y)
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")

	if self._grabbed_scroll_bar then
		self._current_scroll_bar_y = self:scroll_with_bar(y, self._current_scroll_bar_y or 0)

		return true, "grab"
	elseif self._scroll_bar_panel:visible() and scroll_bar:inside(x, y) then
		return true, "hand"
	elseif self._scroll_bar_panel:child("scroll_up_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_up_indicator_arrow"):inside(x, y) then
		return true, "link"
	elseif self._scroll_bar_panel:child("scroll_down_indicator_arrow"):visible() and self._scroll_bar_panel:child("scroll_down_indicator_arrow"):inside(x, y) then
		return true, "link"
	end

	return false, "arrow"
end

function BlackMarketGuiTabItem:scroll_with_bar(target_y, current_y)
	local scroll_up_indicator_arrow = self._scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")
	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel
	local mul = grid_scroll_panel:h() / grid_panel:h()
	local height = self._square_h + self._size_data.padding_h
	local diff = current_y - target_y

	if diff == 0 then
		return current_y
	end

	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel
	local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1
	local dir = diff / math.abs(diff)

	while math.abs(current_y - target_y) >= height / mul do
		if dir > 0 and self._my_node_data.scroll_y_index <= 1 then
			self._my_node_data.scroll_y_index = 1

			break
		elseif dir < 0 and self._max_y_index <= self._my_node_data.scroll_y_index + max_view_y then
			self._my_node_data.scroll_y_index = self._max_y_index - max_view_y

			break
		end

		current_y = current_y - height / mul * dir
		self._my_node_data.scroll_y_index = self._my_node_data.scroll_y_index - 1 * dir
	end

	self:set_scroll_y()

	return current_y
end

function BlackMarketGuiTabItem:set_scroll_indicators()
	local new_y_index = self._my_node_data.scroll_y_index
	local max_view_y = (self.my_slots_dimensions[2] or ITEMS_PER_COLUMN) - 1
	local scroll_up_indicator_arrow = self._scroll_bar_panel:child("scroll_up_indicator_arrow")
	local scroll_down_indicator_arrow = self._scroll_bar_panel:child("scroll_down_indicator_arrow")
	local scroll_bar = self._scroll_bar_panel:child("scroll_bar")
	local grid_panel = self._grid_panel
	local grid_scroll_panel = self._grid_scroll_panel

	if grid_scroll_panel:h() == 0 then
		Application:error("[BlackMarketGuiTabItem:set_scroll_indicators] Dodging division by zero.", "grid_scroll_panel", inspect(self._data), inspect(self))

		return
	end

	local bar_h = scroll_down_indicator_arrow:bottom() - scroll_up_indicator_arrow:top()
	local scroll_diff = grid_panel:h() / grid_scroll_panel:h()

	if scroll_diff ~= 1 then
		local old_h = scroll_bar:h()

		scroll_bar:set_h(bar_h * scroll_diff)

		if old_h ~= scroll_bar:h() then
			-- Nothing
		end
	end

	local sh = grid_scroll_panel:h()

	scroll_bar:set_y(-grid_scroll_panel:y() * grid_panel:h() / sh)
	scroll_bar:set_center_x(scroll_up_indicator_arrow:center_x())
	scroll_bar:set_x(math.round(scroll_bar:x()) - 1)

	local visible = grid_panel:h() < grid_scroll_panel:h()
	local scroll_up_visible = new_y_index > 1
	local scroll_dn_visible = new_y_index + max_view_y < self._max_y_index

	scroll_up_indicator_arrow:set_visible(scroll_up_visible)
	scroll_down_indicator_arrow:set_visible(scroll_dn_visible)

	if self._scroll_up_visible ~= scroll_up_visible or self._scroll_dn_visible ~= scroll_dn_visible then
		self._scroll_up_visible = scroll_up_visible
		self._scroll_dn_visible = scroll_dn_visible

		self._scroll_indicator_box_class:create_sides(self._grid_panel, {
			sides = {
				0,
				0,
				scroll_up_visible and 2 or 0,
				scroll_dn_visible and 2 or 0
			}
		})
	end

	self._scroll_bar_panel:set_visible(visible)
end

function BlackMarketGuiTabItem:update_slots_visibility()
	for index, slot in pairs(self._slots) do
		slot._panel:set_visible(self._grid_panel:inside(slot._panel:world_center_x(), slot._panel:world_center_y()))
	end
end

function BlackMarketGuiTabItem:selected_slot_center()
	if not self._slots[self._slot_selected] then
		return 0, 0
	end

	local x = self._slots[self._slot_selected]._panel:world_center_x()
	local y = self._slots[self._slot_selected]._panel:world_center_y()

	return x, y
end

function BlackMarketGuiTabItem:set_scroll_y(slot)
	if self.my_slots_dimensions[2] == 1 then
		self._scroll_bar_panel:set_visible(false)

		return
	end

	local max_view_x = self.my_slots_dimensions[1] or self._size_data.items_per_row
	local max_view_y = self.my_slots_dimensions[2] or self._size_data.items_per_column
	local y_index = slot and math.ceil(slot / max_view_x)
	local top = self._my_node_data.scroll_y_index or 1
	local bottom = top + max_view_y - 1
	local height = self._square_h + self._size_data.padding_h
	local new_y_index = self._my_node_data.scroll_y_index

	if y_index and y_index < top then
		new_y_index = y_index
	end

	if y_index and bottom < y_index then
		new_y_index = y_index - max_view_y + 1
	end

	self._grid_scroll_panel:set_y(-(new_y_index - 1) * height)

	self._my_node_data.scroll_y_index = new_y_index

	self:set_scroll_indicators()
	self:update_slots_visibility()
end

function BlackMarketGuiTabItem:select_slot(slot, instant)
	slot = not slot and self._slot_selected or self._slots[slot] and slot

	if not slot then
		slot = self._slot_selected or 1

		for i, d in pairs(self._slots) do
			if d._data and d._data.equipped then
				slot = i
			end
		end
	end

	local no_sound = false

	if slot ~= 1 and self._slots[self._slot_selected] and self._slots[self._slot_selected]._name == "empty" then
		return self:select_slot(1, instant)
	end

	if self._slots[slot] and self._slots[slot]._name == "empty" then
		if self._slot_selected < slot then
			return self:select_slot(slot - 1, instant)
		end

		slot = self._slot_selected
		no_sound = true
	end

	if self._slots[self._slot_selected] then
		self._slots[self._slot_selected]:deselect(instant)
	end

	local old_slot = self._slot_selected
	self._slot_selected = slot
	self._my_node_data.selected = self._slot_selected

	if old_slot ~= slot then
		self:set_scroll_y(slot)
	end

	local selected_slot = self._slots[self._slot_selected]:select(instant, no_sound)

	self:check_new_drop()
	managers.menu_component:set_blackmarket_tab_positions()

	if alive(self._tab_pages_panel) then
		local child = nil
		local num_per_page = self.my_slots_dimensions and self.my_slots_dimensions[1] or 6
		local page_selected = math.ceil(self._slot_selected / num_per_page)
		local offset = 0

		self._grid_scroll_panel:set_left(-(self._grid_panel:w() - offset) * (page_selected - 1))

		self._tab_pages_highlighted = self._tab_pages_highlighted or {}
		local page_num = nil

		for _, child in ipairs(self._tab_pages_panel:children()) do
			page_num = tonumber(child:name())

			if type(page_num) == "number" then
				if page_num == page_selected then
					child:set_color(tweak_data.screen_colors.button_stage_2)
				elseif self._tab_pages_highlighted[_] then
					child:set_color(tweak_data.screen_colors.button_stage_2)
				else
					child:set_color(tweak_data.screen_colors.button_stage_3)
				end
			end
		end

		for idx, slot in ipairs(self._slots) do
			slot:set_visible(math.ceil(idx / num_per_page) == math.ceil(self._slot_selected / num_per_page))
		end
	end

	return selected_slot
end

function BlackMarketGuiTabItem:slots()
	return self._slots
end

BlackMarketGuiSlotItem = BlackMarketGuiSlotItem or class(BlackMarketGuiItem)

function BlackMarketGuiSlotItem:init(main_panel, data, x, y, w, h)
	BlackMarketGuiSlotItem.super.init(self, main_panel, data, x, y, w, h)

	self.rect_bg = self._panel:rect({
		alpha = 0,
		color = Color.black
	})

	if data.holding then
		self._post_load_alpha = 0.2
		data.equipped_text = managers.localization:to_upper_text("bm_menu_holding_item")
	end

	if data.custom_name_text then
		local custom_name_text = self._panel:text({
			vertical = "top",
			name = "custom_name_text",
			align = "right",
			layer = 2,
			text = data.custom_name_text,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		})

		custom_name_text:move((data.custom_name_text_right or 0) - 5, 5)

		local right = custom_name_text:right()

		custom_name_text:grow(-(custom_name_text:w() * (data.custom_name_text_width or 0.5)), 0)

		local _, _, w, h = custom_name_text:text_rect()

		if custom_name_text:w() < w then
			custom_name_text:set_font_scale(custom_name_text:font_scale() * custom_name_text:w() / w)
		end

		custom_name_text:set_right(right)
	end

	if data.hide_bg then
		-- Nothing
	end

	if data.mid_text and type(data.mid_text) == "table" then
		local text = self._panel:text({
			name = "text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.mid_text.no_upper and data.mid_text.noselected_text or utf8.to_upper(data.mid_text.noselected_text),
			align = data.mid_text.align or "center",
			vertical = data.mid_text.vertical or "center",
			font_size = data.mid_text.font_size or medium_font_size,
			font = data.mid_text.font or medium_font,
			color = data.mid_text.noselected_color,
			blend_mode = data.mid_text.blend_mode or "add"
		})

		text:grow(-10, -10)
		text:move(5, 5)
		text:move(0, text:h() / 2 - text:font_size() / 2)
		text:set_vertical("top")

		self._text_in_mid = true
	elseif data.corner_text and type(data.corner_text) == "table" then
		self._panel:text({
			name = "corner_text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.corner_text.no_upper and data.corner_text.noselected_text or utf8.to_upper(data.corner_text.noselected_text),
			align = data.corner_text.align or "center",
			vertical = data.corner_text.vertical or "bottom",
			font_size = data.corner_text.font_size or tiny_font_size,
			font = data.corner_text.font or small_font,
			color = data.corner_text.noselected_color or Color.red,
			blend_mode = data.corner_text.blend_mode or "add"
		})
	end

	local function animate_loading_texture(o)
		o:set_render_template(Idstring("VertexColorTexturedRadial"))
		o:set_color(Color(0, 0, 1, 1))

		local time = coroutine.yield()
		local tw = o:texture_width()
		local th = o:texture_height()
		local old_alpha = 0
		local flip = false
		local delta, alpha = nil

		o:set_color(Color(1, 0, 1, 1))

		while true do
			delta = time % 2
			alpha = math.sin(delta * 90)

			o:set_color(Color(1, alpha, 1, 1))

			if flip and old_alpha < alpha then
				o:set_texture_rect(0, 0, tw, th)

				flip = false
			elseif not flip and alpha < old_alpha then
				o:set_texture_rect(tw, 0, -tw, th)

				flip = true
			end

			old_alpha = alpha
			time = time + coroutine.yield() * 2
		end
	end

	self._mini_panel = self._panel:panel()
	self._extra_textures = {}

	if data.extra_bitmaps then
		local color, shape = nil

		for i, bitmap in ipairs(data.extra_bitmaps) do
			if DB:has(Idstring("texture"), bitmap) then
				color = data.extra_bitmaps_colors and data.extra_bitmaps_colors[i] or Color.white
				shape = data.extra_bitmaps_shape and data.extra_bitmaps_shape[i] or {
					x = 0,
					y = 0
				}

				table.insert(self._extra_textures, self._panel:bitmap({
					h = 32,
					w = 32,
					layer = 0,
					texture = bitmap,
					color = color,
					x = self._panel:w() * shape.x,
					y = self._panel:h() * shape.y
				}))
			else
				Application:error("[BlackMarketGuiSlotItem] Texture not found in DB: ", tostring(bitmap))
			end
		end
	end

	local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk")

	if data.mini_icons then
		local padding = data.mini_icons.borders and 14 or 5

		for k, icon_data in ipairs(data.mini_icons) do
			icon_data.padding = padding

			if not icon_data.texture then
				local new_icon = nil

				if icon_data.text then
					new_icon = self._mini_panel:text({
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_font_size,
						text = icon_data.text,
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode
					})
				else
					new_icon = self._mini_panel:rect({
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode,
						alpha = icon_data.alpha
					})
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end
			elseif icon_data.stream then
				if DB:has(Idstring("texture"), icon_data.texture) then
					icon_data.request_index = managers.menu_component:request_texture(icon_data.texture, callback(self, self, "icon_loaded_clbk", icon_data)) or false
				end
			else
				local new_icon = self._mini_panel:bitmap({
					texture = icon_data.texture,
					color = icon_data.color or Color.white,
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1,
					alpha = icon_data.alpha,
					blend_mode = icon_data.blend_mode
				})

				if icon_data.render_template then
					new_icon:set_render_template(icon_data.render_template)
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end

				if icon_data.spin then
					local function spin_animation(o)
						local dt = nil

						while true do
							dt = coroutine.yield()

							o:rotate(dt * 180)
						end
					end

					new_icon:animate(spin_animation)

					self._loading_icon = new_icon
				end
			end

			if icon_data.borders then
				local icon_border_panel = self._mini_panel:panel({
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1
				})

				if icon_data.visible == false then
					icon_border_panel:set_visible(false)
				end

				if icon_data.left then
					icon_border_panel:set_left(padding + icon_data.left)
				elseif icon_data.right then
					icon_border_panel:set_right(self._mini_panel:w() - padding - icon_data.right)
				end

				if icon_data.top then
					icon_border_panel:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					icon_border_panel:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				end

				BoxGuiObject:new(icon_border_panel, {
					sides = {
						1,
						1,
						1,
						1
					}
				})
			end
		end

		if data.mini_icons.borders then
			local tl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local tr_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tr_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local bl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local bl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local br_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local br_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})

			tl_side:set_lefttop(self._mini_panel:w() - 54, 8)
			tl_down:set_lefttop(self._mini_panel:w() - 54, 8)
			tr_side:set_righttop(self._mini_panel:w() - 8, 8)
			tr_down:set_righttop(self._mini_panel:w() - 8, 8)
			bl_side:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			bl_down:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			br_side:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
			br_down:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
		end
	end

	if data.mini_colors then
		local panel_size = 32
		local padding = data.mini_icons and data.mini_icons.borders and 14 or 5
		local color_panel = self._mini_panel:panel({
			layer = 1,
			w = panel_size,
			h = panel_size
		})

		color_panel:set_right(self._mini_panel:w() - padding)
		color_panel:set_bottom(self._mini_panel:h() - padding)
		BoxGuiObject:new(color_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		if #data.mini_colors == 1 then
			color_panel:rect({
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend
			})
		elseif #data.mini_colors == 2 then
			color_panel:polygon({
				triangles = {
					Vector3(0, 0, 0),
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0)
				},
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend,
				w = panel_size,
				h = panel_size
			})
			color_panel:polygon({
				triangles = {
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0),
					Vector3(panel_size, panel_size, 0)
				},
				color = data.mini_colors[2].color or Color.red,
				alpha = data.mini_colors[2].alpha or 1,
				blend_mode = data.mini_colors[2].blend,
				w = panel_size,
				h = panel_size
			})
		end
	end

	if data.bitmap_texture then
		local texture = data.bitmap_texture[1] or data.bitmap_texture
		self._bitmap_panel = self._panel:panel()
		local text_callback = callback(self, self, "texture_loaded_clbk", data.bitmap_texture)

		if DB:has(Idstring("texture"), texture) then
			self._loading_texture = true

			if data.stream then
				self._requested_texture = texture
				self._request_index = managers.menu_component:request_texture(self._requested_texture, text_callback)
			else
				text_callback(data.bitmap_texture, Idstring(texture))
			end
		end

		if not self._bitmap then
			local min = math.min(self._bitmap_panel:w(), self._bitmap_panel:h())

			self._bitmap_panel:set_size(min, min)
			self._bitmap_panel:set_center(self._panel:w() / 2, self._panel:h() / 2)

			self._bitmap = self._bitmap_panel:bitmap({
				texture = "guis/textures/pd2/endscreen/exp_ring",
				name = "item_texture",
				h = 32,
				valign = "scale",
				w = 32,
				halign = "scale",
				render_template = "VertexColorTexturedRadial",
				color = Color(0.2, 1, 1),
				layer = #self._extra_textures + 1
			})

			self._bitmap:set_center(self._bitmap_panel:w() / 2, self._bitmap_panel:h() / 2)
			self._bitmap:animate(animate_loading_texture)
		end
	end

	local bg_image = data.button_text and self._panel:text({
		vertical = "center",
		wrap = true,
		align = "center",
		wrap_word = true,
		valign = "center",
		text = data.button_text,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	if data.bg_texture and DB:has(Idstring("texture"), data.bg_texture) then
		local bg_image = self._panel:bitmap({
			name = "bg_texture",
			halign = "scale",
			valign = "scale",
			layer = 0,
			texture = data.bg_texture,
			color = data.bg_texture_color or Color.white,
			blend_mode = data.bg_texture_blend_mode or "add",
			alpha = data.bg_alpha ~= nil and data.bg_alpha or 1
		})
		local texture_width = bg_image:texture_width()
		local texture_height = bg_image:texture_height()
		local panel_width = self._panel:w()
		local panel_height = self._panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height

		if tw == 0 or th == 0 then
			Application:error("[BlackMarketGuiSlotItem] BG Texture size error!:", "width", tw, "height", th)

			tw = 1
			th = 1
		end

		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		bg_image:set_size(math.round(sw), math.round(sh))
		bg_image:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
	end

	local equipped_text = self._panel:text({
		text = "",
		vertical = "top",
		name = "equipped_text",
		align = "left",
		layer = 2,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})

	equipped_text:move(5, 5)

	if data.equipped then
		local equipped_string = data.equipped_text or managers.localization:text("bm_menu_equipped")

		equipped_text:set_text(utf8.to_upper(equipped_string))

		self._equipped_box = BoxGuiObject:new(self._panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local red_box = false
	local number_text = false
	self._conflict = data.conflict
	self._level_req = data.level

	if data.lock_texture then
		red_box = true
	end

	if type(data.unlocked) == "number" then
		number_text = math.abs(data.unlocked)

		if data.unlocked < 0 then
			red_box = true
			self._item_req = true
		end
	end

	if data.mid_text and not data.mid_text_no_change_alpha then
		if self._bitmap then
			self._bitmap:set_color(self._bitmap:color():with_alpha(0.6))

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
			end
		end

		if self._loading_texture then
			self._post_load_alpha = 0.4
		end
	end

	if red_box then
		if self._bitmap then
			self._bitmap:set_color((data.bitmap_locked_color or DEFAULT_LOCKED_COLOR):with_alpha(data.bitmap_locked_alpha or DEFAULT_LOCKED_BLEND_ALPHA))

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:set_color(bitmap:color():with_alpha(DEFAULT_LOCKED_BLEND_ALPHA))
			end

			self._bitmap:set_blend_mode(data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE)

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
				self._akimbo_bitmap:set_blend_mode(data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE)
			end
		end

		if self._loading_texture then
			self._post_load_color = data.bitmap_locked_color or DEFAULT_LOCKED_COLOR
			self._post_load_alpha = data.bitmap_locked_alpha or DEFAULT_LOCKED_BLEND_ALPHA
			self._post_load_blend_mode = data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE
		end

		if (not data.unlocked or data.can_afford ~= false) and data.lock_texture ~= true then
			self._lock_bitmap = self._panel:bitmap({
				name = "lock",
				h = 32,
				w = 32,
				texture = data.lock_texture or "guis/textures/pd2/skilltree/padlock",
				texture_rect = data.lock_rect or nil,
				color = data.lock_color or tweak_data.screen_colors.important_1,
				layer = #self._extra_textures + 2
			})

			if data.lock_shape then
				local w = data.lock_shape.w or 32
				local h = data.lock_shape.h or 32

				self._lock_bitmap:set_size(w, h)
			end

			self._lock_bitmap:set_center(self._panel:w() / 2, self._panel:h() / 2)

			if data.lock_shape then
				local x = data.lock_shape.x or 0
				local y = data.lock_shape.y or 0

				self._lock_bitmap:move(x, y)
			end
		end
	end

	if number_text then
		-- Nothing
	end

	self:deselect(true)
	self:set_highlight(false, true)
end

function BlackMarketGuiSlotItem:get_texure_size(debug)
	if self._bitmap then
		local texture_width = self._bitmap:texture_width()
		local texture_height = self._bitmap:texture_height()
		local panel_width, panel_height = self._panel:size()

		if texture_width == 0 or texture_height == 0 or panel_width == 0 or panel_height == 0 then
			return 0, 0
		end

		local aspect = panel_width / panel_height
		local sw = math.max(texture_width, texture_height * aspect)
		local sh = math.max(texture_height, texture_width / aspect)
		local dw = texture_width / sw
		local dh = texture_height / sh

		return math.round(dw * panel_width), math.round(dh * panel_height)
	end

	return 0, 0
end

function BlackMarketGuiSlotItem:rescale_texture_aspect(bitmap, width, height)
	if not alive(bitmap) then
		return
	end

	width = width or bitmap:width()
	height = height or bitmap:height()
	local texture_width = bitmap:texture_width()
	local texture_height = bitmap:texture_height()
	local aspect = width / height
	local sw = math.max(texture_width, texture_height * aspect)
	local sh = math.max(texture_height, texture_width / aspect)
	local dw = texture_width / sw
	local dh = texture_height / sh

	bitmap:set_size(math.round(dw * width), math.round(dh * height))
end

function BlackMarketGuiSlotItem:icon_loaded_clbk(icon_data, texture_idstring, ...)
	if not alive(self._mini_panel) then
		Application:error("[BlackMarketGuiSlotItem] icon_loaded_clbk(): This code should no longer occur!!")

		return
	end

	local padding = icon_data.padding or 5
	local new_icon = self._mini_panel:bitmap({
		texture = texture_idstring,
		color = icon_data.color or Color.white,
		w = icon_data.w or 32,
		h = icon_data.h or 32,
		layer = icon_data.layer or 1,
		alpha = icon_data.alpha,
		blend_mode = icon_data.blend_mode
	})

	if icon_data.render_template then
		new_icon:set_render_template(icon_data.render_template)
	end

	if icon_data.visible == false then
		new_icon:set_visible(false)
	end

	if icon_data.left then
		new_icon:set_left(padding + icon_data.left)
	elseif icon_data.right then
		new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
	else
		new_icon:set_center_x(self._mini_panel:w() / 2)
	end

	if icon_data.top then
		new_icon:set_top(padding + icon_data.top)
	elseif icon_data.bottom then
		new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
	else
		new_icon:set_center_y(self._mini_panel:h() / 2)
	end

	if icon_data.name == "new_drop" and self._data.new_drop_data then
		self._data.new_drop_data.icon = new_icon
	end
end

function BlackMarketGuiSlotItem:destroy()
	if self._data and self._data.mini_icons then
		for i, icon_data in ipairs(self._data.mini_icons) do
			if icon_data.stream then
				managers.menu_component:unretrieve_texture(icon_data.texture, icon_data.request_index)
			end
		end
	end

	if self._requested_texture then
		managers.menu_component:unretrieve_texture(self._requested_texture, self._request_index)
	end
end

function BlackMarketGuiSlotItem:texture_loaded_clbk(texture_data)
	local texture = texture_data[1] or texture_data
	local text_rect = texture_data[2]

	if not alive(self._bitmap_panel) then
		Application:error("[BlackMarketGuiSlotItem] texture_loaded_clbk(): This code should no longer occur!!")

		return
	end

	local bitmap_color = (self._post_load_color or self._data.bitmap_color or Color.white):with_alpha(self._post_load_alpha or self._data.bitmap_alpha or 1)
	local bitmap_blend_mode = self._post_load_alpha and self._post_load_blend_mode or self._data.bitmap_blend_mode or "normal"

	if self._bitmap then
		self._bitmap:stop()
		self._bitmap:set_rotation(0)
		self._bitmap:set_color(bitmap_color)

		local _ = text_rect and self._bitmap:set_image(texture, unpack(text_rect)) or self._bitmap:set_image(texture)

		self._bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
		self._bitmap:set_blend_mode(bitmap_blend_mode)

		for _, bitmap in pairs(self._extra_textures) do
			bitmap:set_color(bitmap_color)
			bitmap:set_blend_mode(bitmap_blend_mode)
		end
	else
		self._bitmap = self._bitmap_panel:bitmap({
			name = "item_texture",
			texture = texture,
			texture_rect = text_rect,
			blend_mode = bitmap_blend_mode,
			layer = #self._extra_textures + 1,
			color = bitmap_color
		})

		self._bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
	end

	self._bitmap:set_valign("scale")
	self._bitmap:set_halign("scale")

	local size_w, size_h = self:get_texure_size(true)

	self._bitmap_panel:set_size(size_w, size_h)
	self._bitmap_panel:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)

	if self._data.akimbo_gui_data then
		self._akimbo_bitmap = self._bitmap_panel:bitmap({
			name = "akimbo_texture",
			texture = texture,
			texture_rect = text_rect,
			blend_mode = bitmap_blend_mode,
			color = bitmap_color,
			layer = #self._extra_textures + 1
		})

		self._akimbo_bitmap:set_render_template(self._data.render_template or Idstring("VertexColorTextured"))
		self._akimbo_bitmap:set_valign("scale")
		self._akimbo_bitmap:set_halign("scale")

		local scale = self._data.akimbo_gui_data.scale or 0.75
		local offset = self._data.akimbo_gui_data.offset or 0.1

		self._bitmap:set_size(size_w * scale, size_h * scale)
		self._akimbo_bitmap:set_size(size_w * scale, size_h * scale)
		self._bitmap:set_center(self._bitmap_panel:w() * (0.5 - offset), self._bitmap_panel:h() * 0.5)
		self._akimbo_bitmap:set_center(self._bitmap_panel:w() * (0.5 + offset), self._bitmap_panel:h() * 0.5)
	else
		self._bitmap:set_size(size_w, size_h)
		self._bitmap:set_center(self._bitmap_panel:w() * 0.5, self._bitmap_panel:h() * 0.5)
	end

	local shape = nil

	for i, bitmap in ipairs(self._extra_textures) do
		shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
			w = 1,
			h = 1,
			x = 0,
			y = 0
		}

		bitmap:set_size(self._bitmap_panel:size())
		bitmap:grow(bitmap:w() * shape.w, bitmap:h() * shape.h)
		bitmap:set_center(self._bitmap_panel:center())
		bitmap:move(self._bitmap_panel:w() * shape.x, self._bitmap_panel:h() * shape.y)
	end

	if self._data.akimbo_gui_data then
		local rotation = self._data.akimbo_gui_data.rotation or 45

		self._bitmap:rotate(rotation)
		self._akimbo_bitmap:rotate(rotation)
	end

	self._post_load_color = nil
	self._post_load_alpha = nil
	self._post_load_blend_mode = nil
	self._loading_texture = nil

	self:set_highlight(self._highlighted, true)

	if self._selected then
		self:select(true)
	else
		self:deselect(true)
	end

	self:refresh()
end

function BlackMarketGuiSlotItem:set_btn_text(text)
end

function BlackMarketGuiSlotItem:set_highlight(highlight, instant)
	if self._bitmap and not self._loading_texture then
		if highlight then
			local function animate_select(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.85
				local end_h = height * 0.85
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_select, self._panel, instant, w, h)

			local shape = nil

			for i, bitmap in pairs(self._extra_textures) do
				shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
					w = 1,
					h = 1,
					x = 0,
					y = 0
				}

				bitmap:stop()
				bitmap:animate(animate_select, self._panel, instant, w * shape.w, h * shape.h)
			end
		else
			local function animate_deselect(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.65
				local end_h = height * 0.65
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_deselect, self._panel, instant, w, h)

			local shape = nil

			for i, bitmap in pairs(self._extra_textures) do
				shape = self._data.extra_bitmaps_shape and self._data.extra_bitmaps_shape[i] or {
					w = 1,
					h = 1,
					x = 0,
					y = 0
				}

				bitmap:stop()
				bitmap:animate(animate_deselect, self._panel, instant, w * shape.w, h * shape.h)
			end
		end
	end
end

function BlackMarketGuiSlotItem:select(instant, no_sound)
	BlackMarketGuiSlotItem.super.select(self, instant, no_sound)

	if not managers.menu:is_pc_controller() then
		self:set_highlight(true, instant)
	end

	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(self._data.mid_text.selected_color or Color.white)
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.selected_text or utf8.to_upper(self._data.mid_text.selected_text or ""))

		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end

	if self._data.new_drop_data then
		local newdrop = self._data.new_drop_data

		if newdrop[1] and newdrop[2] and newdrop[3] then
			managers.blackmarket:remove_new_drop(newdrop[1], newdrop[2], newdrop[3])

			if newdrop.icon then
				newdrop.icon:parent():remove(newdrop.icon)
			end

			self._data.new_drop_data = nil
		end
	end

	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text(self._data.selected_text)
	end

	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:show()
	end

	return self
end

function BlackMarketGuiSlotItem:deselect(instant)
	BlackMarketGuiSlotItem.super.deselect(self, instant)

	if not managers.menu:is_pc_controller() then
		self:set_highlight(false, instant)
	end

	if self._text_in_mid and alive(self._panel:child("text")) then
		self._panel:child("text"):set_color(self._data.mid_text.noselected_color or Color.white)
		self._panel:child("text"):set_text(self._data.mid_text.no_upper and self._data.mid_text.noselected_text or utf8.to_upper(self._data.mid_text.noselected_text or ""))

		if alive(self._lock_bitmap) and self._data.mid_text.is_lock_same_color then
			self._lock_bitmap:set_color(self._panel:child("text"):color())
		end
	end

	if self._panel:child("equipped_text") and self._data.selected_text and not self._data.equipped then
		self._panel:child("equipped_text"):set_text("")
	end

	if self._mini_panel and self._data.hide_unselected_mini_icons then
		self._mini_panel:hide()
	end
end

function BlackMarketGuiSlotItem:refresh()
	BlackMarketGuiSlotItem.super.refresh(self)

	if self._bitmap then
		self._bitmap:set_alpha(1)

		if self._akimbo_bitmap then
			self._akimbo_bitmap:set_alpha(1)
		end

		for _, bitmap in pairs(self._extra_textures) do
			bitmap:set_alpha(1)
		end
	end
end

function BlackMarketGuiSlotItem:set_visible(visible)
	self._panel:set_visible(visible)
end

BlackMarketGuiMaskSlotItem = BlackMarketGuiMaskSlotItem or class(BlackMarketGuiSlotItem)

function BlackMarketGuiMaskSlotItem:init(main_panel, data, x, y, w, h)
	BlackMarketGuiMaskSlotItem.super.init(self, main_panel, data, x, y, w, h)

	local cx = self._panel:w() / 2
	local cy = self._panel:h() / 2
	self._box_panel = self._panel:panel({
		w = self._panel:w() * 0.5,
		h = self._panel:w() * 0.5
	})

	self._box_panel:set_center(cx, cy)

	if not data.my_part_data.is_good then
		BoxGuiObject:new(self._box_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	self._mask_text = self._panel:text({
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	self._mask_text:set_position(self._box_panel:left(), self._box_panel:bottom() + 10)
	self._mask_text:set_text(utf8.to_upper(data.name_localized .. ": "))
	BlackMarketGui.make_fine_text(self, self._mask_text)

	self._mask_name_text = self._panel:text({
		word_wrap = true,
		wrap = true,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size
	})

	self._mask_name_text:set_position(self._mask_text:right(), self._mask_text:top())
	self._mask_name_text:set_text(data.my_part_data.is_good and managers.localization:text(data.my_part_data.text) or "NOT SELECTED")
	self._mask_name_text:set_blend_mode(data.my_part_data.is_good and "normal" or "add")
	self._mask_name_text:set_color(data.my_part_data.is_good and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
	self._mask_name_text:grow(-self._mask_name_text:x() - 5, 0)

	local _, _, _, texth = self._mask_name_text:text_rect()

	if data.my_part_data.override then
		self._mask_error_text = self._panel:text({
			blend_mode = "add",
			wrap = true,
			word_wrap = true,
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = tweak_data.screen_colors.important_1
		})

		self._mask_error_text:set_position(self._mask_text:left(), self._mask_text:top() + texth)
		self._mask_error_text:set_text(managers.localization:to_upper_text("menu_bm_overwrite", {
			category = managers.localization:text("bm_menu_" .. data.my_part_data.override)
		}))
	end

	local current_match_with_true = true

	if data.my_part_data.is_good and data.my_true_part_data then
		current_match_with_true = data.my_part_data.id == data.my_true_part_data.id
	end

	if not current_match_with_true then
		if self._bitmap then
			self._bitmap:set_color(Color.white:with_alpha(0.3))

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
			end

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:set_color(bitmap:color():with_alpha(0.3))
			end
		end

		if self._loading_texture then
			self._post_load_alpha = 0.3
		end

		self._mask_text:set_color(self._mask_text:color():with_alpha(0.5))
		self._mask_name_text:set_color(self._mask_name_text:color():with_alpha(0.5))

		if self._mask_error_text then
			self._mask_error_text:set_color(self._mask_error_text:color():with_alpha(0.5))
		end
	end

	self:deselect(true)
	self:set_highlight(false, true)
end

function BlackMarketGuiMaskSlotItem:set_highlight(highlight, instant)
	if self._bitmap and not self._loading_texture then
		if highlight then
			local function animate_select(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.55
				local end_h = height * 0.55
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_select, self._panel, instant, w, h)

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:stop()
				bitmap:animate(animate_select, self._panel, instant, w, h)
			end
		else
			local function animate_deselect(o, panel, instant, width, height)
				local w = o:w()
				local h = o:h()
				local end_w = width * 0.45
				local end_h = height * 0.45
				local center_x, center_y = o:center()

				if w == end_w or instant then
					o:set_size(end_w, end_h)
					o:set_center(center_x, center_y)

					return
				end

				over(math.abs(end_w - w) / end_w, function (p)
					o:set_size(math.lerp(w, end_w, p), math.lerp(h, end_h, p))
					o:set_center(center_x, center_y)
				end)
			end

			local w, h = self:get_texure_size()

			self._bitmap_panel:stop()
			self._bitmap_panel:animate(animate_deselect, self._panel, instant, w, h)

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:stop()
				bitmap:animate(animate_deselect, self._panel, instant, w, h)
			end
		end
	end
end

BlackMarketGuiButtonItem = BlackMarketGuiButtonItem or class(BlackMarketGuiItem)

function BlackMarketGuiButtonItem:init(main_panel, data, x)
	BlackMarketGuiButtonItem.super.init(self, main_panel, data, 0, 0, 10, 10)

	self._highlighted_color = data.highlighted_color or tweak_data.screen_colors.button_stage_2
	self._color = data.color or tweak_data.screen_colors.button_stage_3
	local up_font_size = NOT_WIN_32 and RenderSettings.resolution.y < 720 and self._data.btn == "BTN_STICK_R" and 2 or 0
	self._btn_text = self._panel:text({
		text = "",
		name = "text",
		align = "left",
		blend_mode = "add",
		x = 10,
		layer = 1,
		font_size = small_font_size + up_font_size,
		font = small_font,
		color = self._color
	})
	self._btn_text_id = data.name
	self._btn_text_legends = data.legends
	self._pc_btn = data.pc_btn

	BlackMarketGui.make_fine_text(self, self._btn_text)
	self._panel:set_size(main_panel:w() - x * 2, medium_font_size)
	self._panel:rect({
		blend_mode = "add",
		name = "select_rect",
		halign = "scale",
		alpha = 0.3,
		valign = "scale",
		color = tweak_data.screen_colors.button_stage_3
	})

	if not managers.menu:is_pc_controller() then
		self._btn_text:set_color(tweak_data.screen_colors.text)
	end

	self._panel:set_left(x)
	self._panel:hide()
	self:set_order(data.prio)
	self._btn_text:set_right(self._panel:w())
	self:deselect(true)
	self:set_highlight(false)
end

function BlackMarketGuiButtonItem:hide()
	self._panel:hide()
end

function BlackMarketGuiButtonItem:show()
	self._panel:show()
end

function BlackMarketGuiButtonItem:refresh()
	if managers.menu:is_pc_controller() then
		self._btn_text:set_color(self._highlighted and self._highlighted_color or self._color)
	end

	self._panel:child("select_rect"):set_visible(self._highlighted)
end

function BlackMarketGuiButtonItem:visible()
	return self._panel:visible()
end

function BlackMarketGuiButtonItem:set_order(prio)
	self._panel:set_y((prio - 1) * small_font_size)
end

function BlackMarketGuiButtonItem:set_text_btn_prefix(prefix)
	self._btn_prefix = prefix
end

function BlackMarketGuiButtonItem:set_text_params(params)
	local prefix = self._btn_prefix and managers.localization:get_default_macro(self._btn_prefix) or ""
	local btn_text = prefix

	if managers.menu:is_steam_controller() then
		prefix = self._pc_btn or "skip_cutscene"
		btn_text = managers.localization:btn_macro(prefix)
	end

	if self._btn_text_id then
		btn_text = btn_text .. utf8.to_upper(managers.localization:text(self._btn_text_id, params))
	end

	if self._btn_text_legends then
		local legend_string = ""

		for i, legend in ipairs(self._btn_text_legends) do
			if i > 1 then
				legend_string = legend_string .. " | "
			end

			legend_string = legend_string .. managers.localization:text(legend)
		end

		btn_text = btn_text .. utf8.to_upper(legend_string)
	end

	self._btn_text:set_text(btn_text)
	BlackMarketGui.make_fine_text(self, self._btn_text)

	local _, _, w, h = self._btn_text:text_rect()

	self._panel:set_h(h)
	self._btn_text:set_size(w, h)
	self._btn_text:set_right(self._panel:w())
end

function BlackMarketGuiButtonItem:btn_text()
	return self._btn_text:text()
end

BlackMarketGui = BlackMarketGui or class()
BlackMarketGui.identifiers = {
	weapon = Idstring("weapon"),
	armor = Idstring("armor"),
	melee_weapon = Idstring("melee_weapon"),
	grenade = Idstring("grenade"),
	mask = Idstring("mask"),
	weapon_mod = Idstring("weapon_mod"),
	mask_mod = Idstring("mask_mod"),
	deployable = Idstring("deployable"),
	character = Idstring("character"),
	weapon_cosmetic = Idstring("weapon_cosmetic"),
	inventory_tradable = Idstring("inventory_tradable"),
	armor_skins = Idstring("armor_skins"),
	player_style = Idstring("player_style"),
	suit_variation = Idstring("suit_variation"),
	glove = Idstring("glove")
}

function BlackMarketGui:init(ws, fullscreen_ws, node)
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._init_layer = self._ws:panel():layer()
	self._preloading_list = {}
	self._preloading_index = 0
	self._node = node
	local component_data = self._node:parameters().menu_component_data
	local do_animation = not component_data and not self._data
	local is_start_page = not component_data and true or false

	self:_setup(is_start_page, component_data)

	if do_animation then
		local function fade_me_in_scotty(o)
			over(0.1, function (p)
				o:set_alpha(p)
			end)
		end

		self._panel:animate(fade_me_in_scotty)
		self._fullscreen_panel:animate(fade_me_in_scotty)
	end

	self:set_enabled(true)
end

function BlackMarketGui:set_layer(layer)
	self._panel:set_layer(self._init_layer + layer)
end

function BlackMarketGui:set_enabled(enabled)
	self._enabled = enabled

	if not self._enabled then
		local blur = self._disabled_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			w = self._disabled_panel:panel():w(),
			h = self._disabled_panel:panel():h()
		})

		local function func(o)
			local start_blur = 0

			over(0.6, function (p)
				o:set_alpha(math.lerp(start_blur, 1, p))
			end)
		end

		blur:animate(func)
	else
		self._disabled_panel:clear()
	end
end

function BlackMarketGui:make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

function BlackMarketGui:calc_max_items(items, override_slots)
	local items_per_row = override_slots and override_slots[1] or ITEMS_PER_ROW
	local max_rows_on_screen = override_slots and override_slots[2] or ITEMS_PER_COLUMN

	return math.max(math.ceil(items / items_per_row), max_rows_on_screen) * items_per_row
end

function BlackMarketGui:in_setup()
	return not not self._in_setup
end



function BlackMarketGui:_update_borders()
	local wh = self._weapon_info_panel:h()
	local dy = self._detection_panel:visible() and self._detection_panel:y()
	local dh = self._detection_panel:visible() and self._detection_panel:h()
	local by = self._btn_panel:y()
	local bh = self._btn_panel:h()

	self._btn_panel:set_visible(self._button_count > 0 and true or false)
	self._btn_panel:set_h(20 * self._button_count + 16)

	local info_box_panel = self._panel:child("info_box_panel")
	local weapon_info_height = info_box_panel:h() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - (self._detection_panel:visible() and self._detection_panel:h() + 8 or 0)

	if self._node:parameters() and self._node:parameters().scene_state == "blackmarket_crafting" then
		weapon_info_height = weapon_info_height + self._info_box_panel_y

		self._weapon_info_panel:set_y(0)
	else
		self._weapon_info_panel:set_y(self._info_box_panel_y)
	end

	self._weapon_info_panel:set_h(weapon_info_height)
	self._info_texts_panel:set_h(weapon_info_height - 10)

	if self._detection_panel:visible() then
		self._detection_panel:set_top(self._weapon_info_panel:bottom() + 8)

		if dh ~= self._detection_panel:h() or dy ~= self._detection_panel:y() then
			self._detection_border:create_sides(self._detection_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
		end
	end

	self._btn_panel:set_top((self._detection_panel:visible() and self._detection_panel:bottom() or self._weapon_info_panel:bottom()) + 8)

	if wh ~= self._weapon_info_panel:h() then
		self._weapon_info_border:create_sides(self._weapon_info_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	if bh ~= self._btn_panel:h() or by ~= self._btn_panel:y() then
		self._button_border:create_sides(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end
end

function BlackMarketGui:_set_detection(value, maxed_reached, min_reached)
	local detection_value = self._detection_panel:child("detection_value")

	detection_value:set_text(math.round(value * 100))

	local detection_ring_left_bg = self._detection_panel:child("detection_left_bg")
	local _, _, w, _ = detection_value:text_rect()

	detection_value:set_x(detection_ring_left_bg:x() + detection_ring_left_bg:w() / 2 - w / 2)
	self._detection_panel:child("detection_left"):set_color(Color(0.5 + value * 0.5, 1, 1))
	self._detection_panel:child("detection_right"):set_color(Color(0.5 + value * 0.5, 1, 1))

	local detection_text = self._detection_panel:child("detection_text")

	if maxed_reached then
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_max_detection")))
		detection_text:set_color(Color(255, 255, 42, 0) / 255)
		detection_value:set_color(Color(255, 255, 42, 0) / 255)
	elseif min_reached then
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_min_detection")))
		detection_text:set_color(tweak_data.screen_colors.ghost_color)
		detection_value:set_color(tweak_data.screen_colors.text)
	else
		detection_text:set_text(utf8.to_upper(managers.localization:text("bm_menu_stats_detection")))
		detection_text:set_color(tweak_data.screen_colors.text)
		detection_value:set_color(tweak_data.screen_colors.text)
	end
end

function BlackMarketGui:_get_melee_weapon_stats(name)
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local stats_data = managers.blackmarket:get_melee_weapon_stats(name)
	local multiple_of = {}
	local has_non_special = managers.player:has_category_upgrade("player", "non_special_melee_multiplier")
	local has_special = managers.player:has_category_upgrade("player", "melee_damage_multiplier")
	local non_special = managers.player:upgrade_value("player", "non_special_melee_multiplier", 1) - 1
	local special = managers.player:upgrade_value("player", "melee_damage_multiplier", 1) - 1

	for i, stat in ipairs(self._mweapon_stats_shown) do
		local skip_rounding = stat.num_decimals
		base_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		mods_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}
		skill_stats[stat.name] = {
			value = 0,
			max_value = 0,
			min_value = 0
		}

		if stat.name == "damage" then
			local base_min = stats_data.min_damage --* tweak_data.gui.stats_present_multiplier
			local base_max = stats_data.max_damage --* tweak_data.gui.stats_present_multiplier
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1)
			local skill_mul = dmg_mul * ((has_non_special and has_special and math.max(non_special, special) or 0) + 1) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			skill_stats[stat.name] = {
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "damage_effect" then
			local base_min = stats_data.min_damage_effect
			local base_max = stats_data.max_damage_effect
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
			local dmg_mul = managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[name].stats.weapon_type) .. "_damage_multiplier", 1) - 1
			local gst_skill = managers.player:upgrade_value("player", "melee_knockdown_mul", 1) - 1
			local skill_mul = (1 + dmg_mul) * (1 + gst_skill) - 1
			local skill_min = skill_mul
			local skill_max = skill_mul
			skill_stats[stat.name] = {
				skill_min = skill_min,
				skill_max = skill_max,
				min_value = skill_min,
				max_value = skill_max,
				value = (skill_min + skill_max) / 2,
				skill_in_effect = skill_min > 0 or skill_max > 0
			}
		elseif stat.name == "charge_time" then
			local base = stats_data.charge_time
			base_stats[stat.name] = {
				value = base,
				min_value = base,
				max_value = base
			}
		elseif stat.name == "range" then
			local base_min = stats_data.range
			local base_max = stats_data.range
			base_stats[stat.name] = {
				min_value = base_min,
				max_value = base_max,
				value = (base_min + base_max) / 2
			}
		elseif stat.name == "concealment" then
			local base = managers.blackmarket:_calculate_melee_weapon_concealment(name)
			local skill = managers.blackmarket:concealment_modifier("melee_weapons")
			base_stats[stat.name] = {
				min_value = base,
				max_value = base,
				value = base
			}
			skill_stats[stat.name] = {
				min_value = skill,
				max_value = skill,
				value = skill,
				skill_in_effect = skill > 0
			}
		end

		if stat.multiple_of then
			table.insert(multiple_of, {
				stat.name,
				stat.multiple_of
			})
		end

		base_stats[stat.name].real_value = base_stats[stat.name].value
		mods_stats[stat.name].real_value = mods_stats[stat.name].value
		skill_stats[stat.name].real_value = skill_stats[stat.name].value
		base_stats[stat.name].real_min_value = base_stats[stat.name].min_value
		mods_stats[stat.name].real_min_value = mods_stats[stat.name].min_value
		skill_stats[stat.name].real_min_value = skill_stats[stat.name].min_value
		base_stats[stat.name].real_max_value = base_stats[stat.name].max_value
		mods_stats[stat.name].real_max_value = mods_stats[stat.name].max_value
		skill_stats[stat.name].real_max_value = skill_stats[stat.name].max_value
	end

	for i, data in ipairs(multiple_of) do
		local multiplier = data[1]
		local stat = data[2]
		base_stats[multiplier].min_value = base_stats[stat].real_min_value * base_stats[multiplier].real_min_value
		base_stats[multiplier].max_value = base_stats[stat].real_max_value * base_stats[multiplier].real_max_value
		base_stats[multiplier].value = (base_stats[multiplier].min_value + base_stats[multiplier].max_value) / 2
	end

	for i, stat in ipairs(self._mweapon_stats_shown) do
		if not stat.index then
			if skill_stats[stat.name].value and base_stats[stat.name].value then
				skill_stats[stat.name].value = base_stats[stat.name].value * skill_stats[stat.name].value
				base_stats[stat.name].value = base_stats[stat.name].value
			end

			if skill_stats[stat.name].min_value and base_stats[stat.name].min_value then
				skill_stats[stat.name].min_value = base_stats[stat.name].min_value * skill_stats[stat.name].min_value
				base_stats[stat.name].min_value = base_stats[stat.name].min_value
			end

			if skill_stats[stat.name].max_value and base_stats[stat.name].max_value then
				skill_stats[stat.name].max_value = base_stats[stat.name].max_value * skill_stats[stat.name].max_value
				base_stats[stat.name].max_value = base_stats[stat.name].max_value
			end
		end
	end

	return base_stats, mods_stats, skill_stats
end

function BlackMarketGui:_get_armor_stats(name)
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data({
		armors = name
	}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
	detection_risk = math.round(detection_risk * 100)
	local bm_armor_tweak = tweak_data.blackmarket.armors[name]
	local upgrade_level = bm_armor_tweak.upgrade_level

	for i, stat in ipairs(self._armor_stats_shown) do
		base_stats[stat.name] = {
			value = 0
		}
		mods_stats[stat.name] = {
			value = 0
		}
		skill_stats[stat.name] = {
			value = 0
		}

		if stat.name == "weight" then
			local base = 0 --tweak_data.player.damage.ARMOR_INIT
			local mod = managers.player:body_armor_value("armor", upgrade_level)*50
			base_stats[stat.name] = {
				value = (base + mod) --* tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = (base_stats[stat.name].value + managers.player:body_armor_skill_addend(name) --[[* tweak_data.gui.stats_present_multiplier]]) * managers.player:body_armor_skill_multiplier(name) - base_stats[stat.name].value
			}
		elseif stat.name == "health" then
			local base = tweak_data.player.damage.HEALTH_INIT
			local mod = managers.player:health_skill_addend()
			base_stats[stat.name] = {
				value = (base + mod) --* tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = base_stats[stat.name].value * managers.player:health_skill_multiplier() - base_stats[stat.name].value
			}
		elseif stat.name == "concealment" then
			base_stats[stat.name] = {
				value = managers.player:body_armor_value("concealment", upgrade_level)
			}
			skill_stats[stat.name] = {
				value = managers.blackmarket:concealment_modifier("armors", upgrade_level)
			}
		elseif stat.name == "movement" then
			local base = 1 --tweak_data.player.movement_state.standard.movement.speed.STANDARD_MAX / 100 * tweak_data.gui.stats_present_multiplier
			local movement_penalty = managers.player:body_armor_value("movement", upgrade_level)
			local base_value = movement_penalty * base
			base_stats[stat.name] = {
				value = base_value
			}
			local skill_mod = managers.player:movement_speed_multiplier(false, false, upgrade_level, 1)
			local skill_value = skill_mod * base - base_value
			skill_stats[stat.name] = {
				value = skill_value,
				skill_in_effect = skill_value > 0
			}
		elseif stat.name == "dodge" then
			local base = 0
			local mod = managers.player:body_armor_value("dodge", upgrade_level)
			base_stats[stat.name] = {
				value = (base + mod) * 100
			}
			skill_stats[stat.name] = {
				value = managers.player:skill_dodge_chance(false, false, false, name, detection_risk) * 100
			}
		elseif stat.name == "damage_shake" then
			local base = tweak_data.gui.armor_damage_shake_base
			local mod = math.max(managers.player:body_armor_value("damage_shake", upgrade_level, nil, 1), 0.01)
			local skill = math.max(managers.player:upgrade_value("player", "damage_shake_multiplier", 1), 0.01)
			local base_value = base
			local mod_value = base / mod - base_value
			local skill_value = base / mod / skill - base_value - mod_value + managers.player:upgrade_value("player", "damage_shake_addend", 0)
			base_stats[stat.name] = {
				value = (base_value + mod_value) --* tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = skill_value --* tweak_data.gui.stats_present_multiplier
			}
		elseif stat.name == "stamina_drain" then
			local stamina_data = tweak_data.player.movement_state.stamina
			local base = stamina_data.STAMINA_INIT
			local mod = managers.player:body_armor_value("stamina", upgrade_level)
			local skill = managers.player:stamina_multiplier()
			local base_value = base
			local mod_value = base * mod - base_value
			local skill_value = base * mod * skill - base_value - mod_value
			base_stats[stat.name] = {
				value = base_value + mod_value
			}
			skill_stats[stat.name] = {
				value = skill_value
			}
			base_stats[stat.name].value = 1/mod
		end

		skill_stats[stat.name].skill_in_effect = skill_stats[stat.name].skill_in_effect or skill_stats[stat.name].value ~= 0
	end

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_ratio = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		local converted_armor = (base_stats.armor.value + skill_stats.armor.value) * conversion_ratio
		local skill_in_effect = converted_armor ~= 0
		skill_stats.armor.value = skill_stats.armor.value - converted_armor
		skill_stats.health.value = skill_stats.health.value + converted_armor
		skill_stats.armor.skill_in_effect = skill_in_effect
		skill_stats.health.skill_in_effect = skill_in_effect
	end

	return base_stats, mods_stats, skill_stats
end

function BlackMarketGui:hide_melee_weapon_stats()
	for _, stat in ipairs(self._mweapon_stats_shown) do
		self._mweapon_stats_texts[stat.name].name:set_text("")
		self._mweapon_stats_texts[stat.name].equip:set_text("")
		self._mweapon_stats_texts[stat.name].base:set_text("")
		self._mweapon_stats_texts[stat.name].skill:set_text("")
		self._mweapon_stats_texts[stat.name].total:set_text("")
	end
end

function BlackMarketGui:hide_armor_stats()
	for _, stat in ipairs(self._armor_stats_shown) do
		self._armor_stats_texts[stat.name].name:set_text("")
		self._armor_stats_texts[stat.name].equip:set_text("")
		self._armor_stats_texts[stat.name].base:set_text("")
		self._armor_stats_texts[stat.name].skill:set_text("")
		self._armor_stats_texts[stat.name].total:set_text("")
	end
end

function BlackMarketGui:hide_weapon_stats()
	for _, stat in ipairs(self._stats_shown) do
		self._stats_texts[stat.name].name:set_text("")
		self._stats_texts[stat.name].equip:set_text("")
		self._stats_texts[stat.name].base:set_text("")
		self._stats_texts[stat.name].mods:set_text("")
		self._stats_texts[stat.name].skill:set_text("")
		self._stats_texts[stat.name].total:set_text("")
		self._stats_texts[stat.name].removed:set_text("")
	end
end

function BlackMarketGui:set_stats_titles(...)
	local stat_title_changes = {
		...
	}

	for i, stat_title in ipairs(stat_title_changes) do
		local name = stat_title.name
		local text = stat_title.text or stat_title.text_id and managers.localization:to_upper_text(stat_title.text_id) or false
		local color = stat_title.color or false
		local alpha = stat_title.alpha or false
		local visible = stat_title.show or stat_title.visible or not stat_title.hide or false
		local x = stat_title.x or false
		local y = stat_title.y or false

		if self._stats_titles[name] then
			if text then
				self._stats_titles[name]:set_text(text)
			end

			if color then
				self._stats_titles[name]:set_color(color)
			end

			if alpha then
				self._stats_titles[name]:set_alpha(alpha)
			end

			if x then
				self._stats_titles[name]:set_x(x)
			end

			if y then
				self._stats_titles[name]:set_y(y)
			end

			self._stats_titles[name]:set_visible(visible)
		end
	end
end

function BlackMarketGui:set_weapons_stats_columns()
	local text_panel = nil
	local text_columns = {
		{ name = "name", size = 85, },
		{ name = "equip", size = 75, align = "right", blend = "add", alpha = 0.75, },
		{ name = "base", size = 75, align = "right", blend = "add", alpha = 0.75, },
		{ name = "mods", size = 75, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.stats_mods, },
		{ name = "skill", size = 75, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.resource, },
		{ name = "total", size = 75, align = "right", }
	}

	local x = 0
	for i, stat in ipairs(self._stats_shown) do
		x = 2

		for _, column in ipairs(text_columns) do
			text_panel = self._stats_texts[stat.name][column.name]:parent()

			text_panel:set_width(column.size)
			text_panel:set_x(x)

			x = x + column.size

			if column.name == "total" then
				text_panel:set_x(190)
			end
		end
	end
end

function BlackMarketGui:set_weapon_mods_stats_columns()
	local x = 0
	local text_panel = nil
	local text_columns = {
		{ name = "name", size = 85, },
		{ name = "equip", size = 75, align = "right", blend = "add", alpha = 0.75, },
		{ name = "base", size = 75, align = "right", blend = "add", alpha = 0.75, },
		{ name = "mods", size = 0.075, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.resource,}, --tweak_data.screen_colors.stats_mods 
		{ name = "skill", size = 75, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.resource, },
		{ name = "total", size = 75, align = "right", }
	}

	for i, stat in ipairs(self._stats_shown) do
		x = 2

		for _, column in ipairs(text_columns) do
			text_panel = self._stats_texts[stat.name][column.name]:parent()

			text_panel:set_width(column.size)
			text_panel:set_x(x)

			x = x + column.size

			if column.name == "total" then
				--text_panel:set_x(190)
			end
		end
	end
end

function BlackMarketGui:damage_falloff_to_string(damage_falloff)
	local optimal_range_distance = damage_falloff and damage_falloff.optimal_distance + damage_falloff.optimal_range

	if optimal_range_distance then
		if damage_falloff.far_multiplier > 1 then
			optimal_range_distance = optimal_range_distance + damage_falloff.far_falloff
		end

		local range_empty = managers.localization:get_default_macro("BTN_RANGE_EMPTY")
		local range_filled = managers.localization:get_default_macro("BTN_RANGE_FILLED")
		local range_bonus = managers.localization:get_default_macro("BTN_RANGE_BONUS")

		if optimal_range_distance < 1500 then
			if damage_falloff.far_multiplier > 1 then
				return range_bonus .. range_empty .. range_empty
			end

			return range_filled .. range_empty .. range_empty
		elseif optimal_range_distance < 3000 then
			if damage_falloff.far_multiplier > 1 then
				return range_filled .. range_bonus .. range_empty
			end

			return range_filled .. range_filled .. range_empty
		else
			if damage_falloff.far_multiplier > 1 then
				return range_filled .. range_filled .. range_bonus
			end

			return range_filled .. range_filled .. range_filled
		end
	end

	return managers.localization:to_upper_text("bm_menu_damage_falloff_no_data")
end

function BlackMarketGui:get_damage_falloff_from_weapon(weapon_id, blueprint)
	local damage_falloff = tweak_data.weapon[weapon_id] and tweak_data.weapon[weapon_id].damage_falloff

	if damage_falloff and blueprint then
		damage_falloff = clone(damage_falloff)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(factory_id, blueprint)

		managers.blackmarket:modify_damage_falloff(damage_falloff, custom_stats)
	end

	return damage_falloff
end

function BlackMarketGui:update_info_text()
	local slot_data = self._slot_data
	local tab_data = self._tabs[self._selected]._data
	local prev_data = tab_data.prev_node_data
	local ids_category = Idstring(slot_data.category)
	local identifier = tab_data.identifier
	local updated_texts = {
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		},
		{
			text = ""
		}
	}
	local ignore_lock = false

	self._stats_text_modslist:set_text("")

	local suspicion, max_reached, min_reached = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)

	self:_set_detection(suspicion, max_reached, min_reached)
	self:_set_rename_info_text(nil)

	local is_renaming_this = self._renaming_item and not self._data.is_loadout and self._renaming_item.category == slot_data.category and self._renaming_item.slot == slot_data.slot

	self._armor_info_panel:set_visible(identifier == self.identifiers.armor)

	if identifier == self.identifiers.weapon then
		local price = slot_data.price or 0

		if slot_data.ignore_slot then
			-- Nothing
		elseif not slot_data.empty_slot then
			updated_texts[1].text = slot_data.name_localized

			if slot_data.name_color then
				updated_texts[1].text = "##" .. updated_texts[1].text .. "##"
				updated_texts[1].resource_color = {
					slot_data.name_color
				}
			end

			local resource_color = {}
			updated_texts[2].resource_color = resource_color

			if price > 0 then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text(slot_data.not_moddable and "st_menu_cost" or "st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##"
				.."   "..(string.match(managers.localization:to_upper_text("menu_st_req_level_skill_switch"), "(.*) ") or managers.localization:to_upper_text("menu_st_req_level_skill_switch"))..": "..(slot_data.level or 0)

				table.insert(resource_color, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			if not slot_data.not_moddable and not self._data.is_loadout then
				self:_set_rename_info_text(1)
			end

			if not slot_data.unlocked then
				if slot_data.lock_text then
					updated_texts[3].text = slot_data.lock_text
					updated_texts[3].below_stats = true
				else
					local skill_based = slot_data.skill_based
					local func_based = slot_data.func_based
					local level_based = slot_data.level and slot_data.level > 0
					local dlc_based = tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
					local part_dlc_locked = slot_data.part_dlc_lock
					local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
					local level_text_id = level_based and "bm_menu_level_req" or false
					local dlc_text_id = dlc_based and slot_data.dlc_locked or false
					local part_dlc_text_id = part_dlc_locked and "bm_menu_part_dlc_locked"
					local funclock_text_id = false

					if func_based then
						local unlocked, text_id = BlackMarketGui.get_func_based(func_based)

						if not unlocked then
							funclock_text_id = text_id
						end
					end

					local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"
					local text = ""

					if slot_data.install_lock then
						text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
					elseif vr_lock_text then
						text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
					elseif dlc_text_id then
						text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
					elseif part_dlc_text_id then
						text = text .. managers.localization:to_upper_text(part_dlc_text_id, {}) .. "\n"
					elseif funclock_text_id then
						text = text .. managers.localization:to_upper_text(funclock_text_id, {
							slot_data.name_localized
						}) .. "\n"
					elseif skill_text_id then
						text = text .. managers.localization:to_upper_text(skill_text_id, {
							slot_data.name_localized
						}) .. "\n"
					end

					if slot_data.level and (slot_data.level > managers.experience:current_level()) then
						text = text .. managers.localization:to_upper_text(level_text_id, {
							level = slot_data.level
						}) .. "\n"
					end

					updated_texts[3].text = text
					updated_texts[3].below_stats = true
				end
			elseif self._slot_data.can_afford == false then
				-- Nothing
			end

			if slot_data.last_weapon then
				updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_last_weapon_warning") .. "\n"
			end

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
				updated_texts[4].resource_color = tweak_data.lootdrop.global_values[slot_data.global_value].color
				updated_texts[4].below_stats = true
			end

			local weapon_id = slot_data.name
			local weapon_tweak = weapon_id and tweak_data.weapon[weapon_id]

			if weapon_tweak and weapon_tweak.has_description then
				updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:to_upper_text(tweak_data.weapon[slot_data.name].desc_id)
				updated_texts[4].below_stats = true
			end

			if slot_data.not_moddable then
				local movement_penalty = weapon_tweak and tweak_data.upgrades.weapon_movement_penalty[weapon_tweak.categories[1] ] or 1

				if movement_penalty < 1 then
					local penalty_as_string = string.format("%d%%", math.round((1 - movement_penalty) * 100))
					updated_texts[5].text = updated_texts[5].text .. managers.localization:to_upper_text("bm_menu_weapon_movement_penalty_info", {
						penalty = penalty_as_string
					})
				end
			end

			updated_texts[5].below_stats = true
		elseif slot_data.locked_slot then
			ignore_lock = true
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_weapon_slot")

			if slot_data.cannot_buy then
				updated_texts[3].text = slot_data.dlc_locked
			else
				updated_texts[2].text = slot_data.dlc_locked
			end

			updated_texts[4].text = managers.localization:text("bm_menu_locked_weapon_slot_desc")
		elseif not slot_data.is_loadout then
			local prefix = ""

			if not managers.menu:is_pc_controller() then
				prefix = managers.localization:get_default_macro("BTN_A")
			end

			updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_weapon")
			updated_texts[4].text = managers.localization:text("bm_menu_empty_weapon_slot_buy_info")
		end
	elseif identifier == self.identifiers.melee_weapon then
		updated_texts[1].text = self._slot_data.name_localized

		if tweak_data.blackmarket.melee_weapons[slot_data.name].info_id then
			updated_texts[2].text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].info_id)
			updated_texts[2].below_stats = true
		end

		if not slot_data.unlocked then
			local skill_based = slot_data.skill_based
			local level_based = slot_data.level and slot_data.level > 0
			local dlc_based = slot_data.dlc_based or tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
			local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
			local level_text_id = level_based and "bm_menu_level_req" or false
			local dlc_text_id = dlc_based and slot_data.dlc_locked or false
			local text = ""
			local vr_lock_text = slot_data.vr_locked and "bm_menu_vr_locked"

			if slot_data.install_lock then
				text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
			elseif vr_lock_text then
				text = text .. managers.localization:to_upper_text(vr_lock_text) .. "\n"
			elseif skill_text_id then
				text = text .. managers.localization:to_upper_text(skill_text_id, {
					slot_data.name_localized
				}) .. "\n"
			elseif dlc_text_id then
				text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
			elseif level_text_id then
				text = text .. managers.localization:to_upper_text(level_text_id, {
					level = slot_data.level
				}) .. "\n"
			end

			updated_texts[3].text = text
			updated_texts[3].below_stats = true
		end

		updated_texts[4].resource_color = {}
		local desc_text = managers.localization:text(tweak_data.blackmarket.melee_weapons[slot_data.name].desc_id)

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.grenade then
		updated_texts[1].text = self._slot_data.name_localized

		if not slot_data.unlocked then
			local grenade_tweak = tweak_data.blackmarket.projectiles[slot_data.name]

			if grenade_tweak and grenade_tweak.unlock_id then
				updated_texts[3].text = managers.localization:to_upper_text(grenade_tweak.unlock_id)
			else
				local skill_based = slot_data.skill_based
				local level_based = slot_data.level and slot_data.level > 0
				local dlc_based = false

				if slot_data.dlc_based then
					local dlc = tweak_data.lootdrop.global_values[slot_data.global_value] and tweak_data.lootdrop.global_values[slot_data.global_value].dlc or grenade_tweak.dlc
					dlc_based = dlc and not managers.dlc:is_dlc_unlocked(slot_data.global_value)
				end

				local skill_text_id = skill_based and (slot_data.skill_name or "bm_menu_skilltree_locked") or false
				local level_text_id = level_based and "bm_menu_level_req" or false
				local dlc_text_id = slot_data.dlc_locked or false
				local text = ""

				if slot_data.install_lock then
					text = text .. managers.localization:to_upper_text(slot_data.install_lock, {}) .. "\n"
				elseif skill_text_id then
					text = text .. managers.localization:to_upper_text(skill_text_id, {
						slot_data.name_localized
					}) .. "\n"
				elseif level_text_id then
					text = text .. managers.localization:to_upper_text(level_text_id, {
						level = slot_data.level
					}) .. "\n"
				elseif dlc_text_id then
					text = text .. managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
				end

				updated_texts[3].text = text
			end
		end

		updated_texts[4].resource_color = {}
		local desc_text = managers.localization:text(tweak_data.blackmarket.projectiles[slot_data.name].desc_id)
		updated_texts[4].text = desc_text .. "\n"

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.armor then
		local armor_name_text = self._armor_info_panel:child("armor_name_text")
		local armor_image = self._armor_info_panel:child("armor_image")
		local armor_equipped = self._armor_info_panel:child("armor_equipped")

		armor_name_text:set_text(self._slot_data.name_localized)
		armor_name_text:set_w(self._armor_info_panel:w() - armor_image:right() - 20)
		self:make_fine_text(armor_name_text)
		armor_name_text:grow(2, 0)
		armor_equipped:set_visible(self._slot_data.equipped)
		armor_equipped:set_top(armor_name_text:bottom())
		armor_image:set_image(self._slot_data.bitmap_texture)
		self._armor_info_panel:set_h(armor_image:bottom())

		if not self._slot_data.unlocked then
			updated_texts[3].text = utf8.to_upper(managers.localization:text(slot_data.level == 0 and (slot_data.skill_name or "bm_menu_skilltree_locked") or "bm_menu_level_req", {
				level = slot_data.level,
				SKILL = slot_data.name
			}))
			updated_texts[3].below_stats = true
		elseif managers.player:has_category_upgrade("player", "damage_to_hot") and not table.contains(tweak_data:get_raw_value("upgrades", "damage_to_hot_data", "armors_allowed") or {}, self._slot_data.name) then
			updated_texts[3].text = managers.localization:to_upper_text("bm_menu_disables_damage_to_hot")
			updated_texts[3].below_stats = true
		elseif managers.player:has_category_upgrade("player", "armor_health_store_amount") then
			local bm_armor_tweak = tweak_data.blackmarket.armors[slot_data.name]
			local upgrade_level = bm_armor_tweak.upgrade_level
			local amount = managers.player:body_armor_value("skill_max_health_store", upgrade_level, 1)
			local multiplier = managers.player:upgrade_value("player", "armor_max_health_store_multiplier", 1)
			updated_texts[2].text = managers.localization:to_upper_text("bm_menu_armor_max_health_store", {
				amount = format_round(amount * multiplier --[[* tweak_data.gui.stats_present_multiplier]])
			})
			updated_texts[2].below_stats = true
		end
	elseif identifier == self.identifiers.armor_skins then
		local skin_tweak = tweak_data.economy.armor_skins[self._slot_data.name]
		updated_texts[1].text = self._slot_data.name_localized
		local desc = ""
		local desc_colors = {}

		if self._slot_data.equipped then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_equipped") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.text
		elseif not self._slot_data.cosmetic_unlocked then
			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			else
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
				updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			end
		end

		if self._slot_data.cosmetic_rarity then
			local rarity_color = tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
			updated_texts[1].text = "##" .. self._slot_data.name_localized .. "##"
			updated_texts[1].resource_color = rarity_color
			local rarity = managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
				rarity = managers.localization:text(tweak_data.economy.rarities[self._slot_data.cosmetic_rarity].name_id)
			})
			desc = desc .. rarity .. "\n\n"

			table.insert(desc_colors, rarity_color)
		end

		if skin_tweak.desc_id then
			local desc_text = managers.localization:text(skin_tweak.desc_id)

			if desc_text ~= " " then
				desc = desc .. desc_text
				desc = desc .. "\n\n"
			end
		end

		if skin_tweak.challenge_id then
			desc = desc .. "##" .. managers.localization:to_upper_text("menu_unlock_condition") .. "##\n"

			table.insert(desc_colors, tweak_data.screen_colors.challenge_title)

			desc = desc .. managers.localization:text(skin_tweak.challenge_id)
		elseif not skin_tweak.free then
			if skin_tweak.unlock_id then
				desc = desc .. managers.localization:text(skin_tweak.unlock_id) .. "\n"

				table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
			else
				local safe = self:get_safe_for_economy_item(slot_data.name)
				safe = safe and safe.name_id and managers.localization:text(safe.name_id) or "invalid skin"
				desc = desc .. managers.localization:text("bm_menu_purchase_steam", {
					safe = safe
				}) .. "\n"

				table.insert(desc_colors, tweak_data.screen_colors.challenge_title)
			end
		end

		updated_texts[4].text = desc
		updated_texts[4].resource_color = desc_colors
		updated_texts[4].below_stats = true

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end
	elseif identifier == self.identifiers.player_style then
		local player_style = slot_data.name
		local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end

		local desc_id = player_style_tweak.desc_id
		local desc_colors = {}
		updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

			if gvalue_tweak.desc_id then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

				table.insert(desc_colors, gvalue_tweak.color)
			end
		end

		if #desc_colors == 1 then
			updated_texts[4].resource_color = desc_colors[1]
		else
			updated_texts[4].resource_color = desc_colors
		end
	elseif identifier == self.identifiers.suit_variation then
		local player_style = self._data.prev_node_data.name
		local player_style_tweak = tweak_data.blackmarket.player_styles[player_style]
		local suit_variation = slot_data.name
		local suit_variation_tweak = player_style_tweak.material_variations[suit_variation]
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end

		local desc_id = suit_variation_tweak and suit_variation_tweak.desc_id or "menu_default"
		local desc_colors = {}
		updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

			if gvalue_tweak.desc_id then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

				table.insert(desc_colors, gvalue_tweak.color)
			end
		end

		if #desc_colors == 1 then
			updated_texts[4].resource_color = desc_colors[1]
		else
			updated_texts[4].resource_color = desc_colors
		end
	elseif identifier == self.identifiers.glove then
		local glove_id = slot_data.name
		local glove_tweak = tweak_data.blackmarket.gloves[glove_id]
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("bm_menu_item_locked") .. "##"
			updated_texts[2].resource_color = tweak_data.screen_colors.important_1
			updated_texts[3].text = slot_data.dlc_locked and managers.localization:to_upper_text(slot_data.dlc_locked) or managers.localization:to_upper_text("bm_menu_dlc_locked")
		end

		local desc_id = glove_tweak.desc_id
		local desc_colors = {}
		updated_texts[4].text = desc_id and managers.localization:text(desc_id) or ""

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

			if gvalue_tweak.desc_id then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"

				table.insert(desc_colors, gvalue_tweak.color)
			end
		end

		if #desc_colors == 1 then
			updated_texts[4].resource_color = desc_colors[1]
		else
			updated_texts[4].resource_color = desc_colors
		end
	elseif identifier == self.identifiers.mask then
		local price = slot_data.price
		price = price or (type(slot_data.unlocked) == "number" or managers.money:get_mask_slot_sell_value(slot_data.slot)) and managers.money:get_mask_sell_value(slot_data.name, slot_data.global_value)

		if not slot_data.empty_slot then
			updated_texts[1].text = slot_data.name_localized

			if not self._data.is_loadout and slot_data.slot ~= 1 and slot_data.unlocked == true then
				self:_set_rename_info_text(1)
			end

			local resource_colors = {}

			if price > 0 and slot_data.slot ~= 1 then
				updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_value") .. " " .. managers.experience:cash_string(price) .. "##" .. "   "

				table.insert(resource_colors, slot_data.can_afford ~= false and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
			end

			if slot_data.num_backs then
				updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
					amount = math.abs(slot_data.unlocked)
				}) .. "##"

				table.insert(resource_colors, tweak_data.screen_colors.text)
			end

			if #resource_colors == 1 then
				updated_texts[2].resource_color = resource_colors[1]
			else
				updated_texts[2].resource_color = resource_colors
			end

			local achievement_tracker = tweak_data.achievement.mask_tracker
			local mask_id = slot_data.name
			local achievement_lock_id = managers.dlc:is_mask_achievement_locked(mask_id)
			local achievement_milestone_lock_id = managers.dlc:is_mask_achievement_milestone_locked(mask_id)

			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			elseif slot_data.infamy_lock then
				updated_texts[3].text = managers.localization:to_upper_text("menu_infamy_lock_info")
			elseif mask_id and achievement_tracker[mask_id] and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				local achievement_data = achievement_tracker[mask_id]
				local max_progress = achievement_data.max_progress
				local text_id = achievement_data.text_id
				local award = achievement_data.award
				local stat = achievement_data.stat

				if stat and max_progress > 0 then
					local progress_left = max_progress - (managers.achievment:get_stat(stat) or 0)

					if progress_left > 0 then
						local progress = tostring(progress_left)
						updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id, {
							progress = progress
						}) .. "##"
						updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
					end
				elseif award and not managers.achievment:get_info(award).awarded then
					updated_texts[3].text = "##" .. managers.localization:text(achievement_data.text_id) .. "##"
					updated_texts[3].resource_color = tweak_data.screen_colors.button_stage_2
				end
			elseif achievement_lock_id and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				local dlc_tweak = tweak_data.dlc[achievement_lock_id]
				local achievement = dlc_tweak and dlc_tweak.achievement_id
				local achievement_visual = tweak_data.achievement.visual[achievement]

				if achievement_visual then
					updated_texts[3].text = managers.localization:to_upper_text(achievement_visual.desc_id)

					if achievement_visual.progress then
						updated_texts[3].text = updated_texts[3].text .. " (" .. tostring(achievement_visual.progress.get()) .. "/" .. tostring(achievement_visual.progress.max) .. ")"
					end
				end
			elseif achievement_milestone_lock_id and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				for _, data in ipairs(tweak_data.achievement.milestones) do
					if data.id == achievement_milestone_lock_id then
						updated_texts[3].text = managers.localization:to_upper_text("bm_menu_milestone_reward_unlock", {
							NUM = tostring(data.at)
						})

						break
					end
				end
			elseif managers.dlc:is_content_skirmish_locked("masks", mask_id) and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_skirmish_content_reward")
			elseif managers.dlc:is_content_crimespree_locked("masks", mask_id) and (not slot_data.unlocked or type(slot_data.unlocked) == "number" and slot_data.unlocked <= 0) then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_crimespree_content_reward")
			end

			if mask_id and mask_id ~= "empty" then
				local desc_id = tweak_data.blackmarket.masks[mask_id].desc_id
				updated_texts[4].text = desc_id and managers.localization:text(desc_id) or Application:production_build() and "Add ##desc_id## to ##" .. mask_id .. "## in tweak_data.blackmarket.masks" or ""

				if slot_data.global_value and slot_data.global_value ~= "normal" then
					local gvalue_tweak = tweak_data.lootdrop.global_values[slot_data.global_value]

					if gvalue_tweak.desc_id then
						updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(gvalue_tweak.desc_id) .. "##"
						updated_texts[4].resource_color = gvalue_tweak.color
					end
				end
			end
		elseif slot_data.locked_slot then
			ignore_lock = true
			updated_texts[1].text = managers.localization:to_upper_text("bm_menu_locked_mask_slot")

			if slot_data.cannot_buy then
				updated_texts[3].text = slot_data.dlc_locked
			else
				updated_texts[2].text = slot_data.dlc_locked
			end

			updated_texts[4].text = managers.localization:text("bm_menu_locked_mask_slot_desc")
		else
			if slot_data.cannot_buy then
				updated_texts[2].text = managers.localization:to_upper_text("bm_menu_empty_mask_slot")
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_no_masks_in_stash_varning")
			else
				local prefix = ""

				if not managers.menu:is_pc_controller() then
					prefix = managers.localization:get_default_macro("BTN_A")
				end

				updated_texts[1].text = prefix .. managers.localization:to_upper_text("bm_menu_btn_buy_new_mask")
			end

			updated_texts[4].text = managers.localization:text("bm_menu_empty_mask_slot_buy_info")
		end
	elseif identifier == self.identifiers.weapon_mod then
		local price = slot_data.price or managers.money:get_weapon_modify_price(prev_data.name, slot_data.name, slot_data.global_value)
		updated_texts[1].text = slot_data.name_localized
		local resource_colors = {}

		if price > 0 then
			updated_texts[2].text = "##" .. managers.localization:to_upper_text("st_menu_cost") .. " " .. managers.experience:cash_string(price) .. "##"

			table.insert(resource_colors, slot_data.can_afford and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
		end

		local unlocked = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked or 0
		updated_texts[2].text = updated_texts[2].text .. (price > 0 and "   " or "")

		if slot_data.previewing then
			updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_mod_preview")
		elseif slot_data.free_of_charge then
			updated_texts[2].text = updated_texts[2].text .. (unlocked > 0 and managers.localization:to_upper_text("bm_menu_item_unlocked") or managers.localization:to_upper_text("bm_menu_item_locked"))
		else
			updated_texts[2].text = updated_texts[2].text .. "##" .. managers.localization:to_upper_text("bm_menu_item_amount", {
				amount = tostring(math.abs(unlocked))
			}) .. "##"

			table.insert(resource_colors, math.abs(unlocked) > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1)
		end

		if #resource_colors == 1 then
			updated_texts[2].resource_color = resource_colors[1]
		else
			updated_texts[2].resource_color = resource_colors
		end

		local can_not_afford = slot_data.can_afford == false
		local conflicted = slot_data.conflict
		local out_of_item = slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked == 0

		if slot_data.install_lock then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.install_lock)
			updated_texts[3].below_stats = true
		elseif slot_data.dlc_locked then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
		elseif conflicted then
			updated_texts[3].text = managers.localization:to_upper_text("bm_menu_conflict", {
				conflict = slot_data.conflict
			})
		elseif slot_data.lock_texture then
			local achievement_lock_id = managers.dlc:is_weapon_mod_achievement_locked(slot_data.name)
			local achievement_milestone_lock_id = managers.dlc:is_weapon_mod_achievement_milestone_locked(slot_data.name)

			if achievement_lock_id then
				local dlc_tweak = tweak_data.dlc[achievement_lock_id]
				local achievement = dlc_tweak and dlc_tweak.achievement_id
				local achievement_visual = tweak_data.achievement.visual[achievement]

				if achievement_visual then
					updated_texts[3].text = managers.localization:to_upper_text(achievement_visual.desc_id)

					if achievement_visual.progress then
						updated_texts[3].text = updated_texts[3].text .. " (" .. tostring(achievement_visual.progress.get()) .. "/" .. tostring(achievement_visual.progress.max) .. ")"
					end

					updated_texts[3].below_stats = true
				end
			elseif achievement_milestone_lock_id then
				for _, data in ipairs(tweak_data.achievement.milestones) do
					if data.id == achievement_milestone_lock_id then
						updated_texts[3].text = managers.localization:to_upper_text("bm_menu_milestone_reward_unlock", {
							NUM = tostring(data.at)
						})
						updated_texts[3].below_stats = true

						break
					end
				end
			elseif managers.dlc:is_content_skirmish_locked("weapon_mods", slot_data.name) then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_skirmish_content_reward")
				updated_texts[3].below_stats = true
			elseif managers.dlc:is_content_crimespree_locked("weapon_mods", slot_data.name) then
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_crimespree_content_reward")
				updated_texts[3].below_stats = true
			end
		end

		local part_id = slot_data.name
		local part_data = part_id and tweak_data.weapon.factory.parts[part_id]
		local perks = part_data and part_data.perks
		local is_gadget = part_data and part_data.type == "gadget" or perks and table.contains(perks, "gadget")
		local is_ammo = part_data and part_data.type == "ammo" or perks and table.contains(perks, "ammo")
		local is_bayonet = part_data and part_data.type == "bayonet" or perks and table.contains(perks, "bayonet")
		local is_bipod = part_data and part_data.type == "bipod" or perks and table.contains(perks, "bipod")
		local is_underbarrel_ammo = part_data and part_data.type == "underbarrel_ammo" or perks and table.contains(perks, "underbarrel_ammo")
		local has_desc = part_data and part_data.has_description == true
		updated_texts[4].resource_color = {}

		if is_gadget or is_ammo or is_bayonet or is_bipod or is_underbarrel_ammo or has_desc then
			local crafted = managers.blackmarket:get_crafted_category_slot(prev_data.category, prev_data.slot)
			updated_texts[4].text = managers.weapon_factory:get_part_desc_by_part_id_from_weapon(part_id, crafted.factory_id, crafted.blueprint)
		end

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			if is_gadget or is_ammo or is_bayonet or is_underbarrel_ammo or has_desc then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
			else
				updated_texts[4].text = "##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"
			end

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		local current_zoom = slot_data.comparision_data and slot_data.comparision_data.zoom or 1
		local zoom_stat = part_data and part_data.stats and part_data.stats.zoom
		local gadget_zoom_stat = part_data and part_data.stats and part_data.stats.gadget_zoom
		local gadget_zoom_add_stat = part_data and part_data.stats and part_data.stats.gadget_zoom_add
		local zoom_magnification = nil

		if zoom_stat then
			zoom_magnification = 1 + zoom_stat
		elseif gadget_zoom_stat then
			zoom_magnification = gadget_zoom_stat
		elseif gadget_zoom_add_stat then
			zoom_magnification = current_zoom + gadget_zoom_add_stat
		end

		if zoom_magnification then
			if zoom_magnification then
				local zoom_level_string = managers.localization:text("bm_menu_sight_zoom_level", {
					zoom = zoom_stat
				})
				updated_texts[1].text = updated_texts[1].text .. "  " .. zoom_level_string
			end
		end

		if perks and table.contains(perks, "bonus") then
			updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("bm_menu_disables_cosmetic_bonus") .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
		end

		updated_texts[4].below_stats = true
		local weapon_id = managers.weapon_factory:get_factory_id_by_weapon_id(prev_data.name)

		local function get_forbids(weapon_id, part_id)
			local weapon_data = tweak_data.weapon.factory[weapon_id]

			if not weapon_data then
				return {}
			end

			local default_parts = {}

			for _, part in ipairs(weapon_data.default_blueprint) do
				table.insert(default_parts, part)

				local part_data = tweak_data.weapon.factory.parts[part]

				if part_data and part_data.adds then
					for _, part in ipairs(part_data.adds) do
						table.insert(default_parts, part)
					end
				end
			end

			local weapon_mods = {}

			for _, part in ipairs(weapon_data.uses_parts) do
				if not table.contains(default_parts, part) then
					local part_data = tweak_data.weapon.factory.parts[part]

					if part_data and not part_data.unatainable then
						weapon_mods[part] = {}
					end
				end
			end

			for part, _ in pairs(weapon_mods) do
				local part_data = tweak_data.weapon.factory.parts[part]

				if part_data.forbids then
					for other_part, _ in pairs(weapon_mods) do
						local other_part_data = tweak_data.weapon.factory.parts[part]

						if table.contains(part_data.forbids, other_part) then
							table.insert(weapon_mods[part], other_part)
							table.insert(weapon_mods[other_part], part)
						end
					end
				end
			end

			return weapon_mods[part_id]
		end

		local forbidden_parts = get_forbids(weapon_id, part_id)
		local droppable_mods = managers.blackmarket:get_dropable_mods_by_weapon_id(prev_data.name)

		if slot_data.removes and #slot_data.removes > 0 then
			local removed_mods = ""

			for i, name in ipairs(slot_data.removes) do
				local mod_data = tweak_data.weapon.factory.parts[name]

				if droppable_mods[mod_data.type] then
					local mod_name = mod_data and mod_data.name_id or name
					mod_name = managers.localization:text(mod_name)
					removed_mods = string.format("%s%s%s", removed_mods, i > 1 and ", " or "", mod_name)
				end
			end

			if #removed_mods > 0 then
				updated_texts[5].text = managers.localization:to_upper_text("bm_mod_equip_remove", {
					mod = removed_mods
				})
			end
		elseif forbidden_parts and #forbidden_parts > 0 then
			local forbids = {}

			for i, forbidden_part in ipairs(forbidden_parts) do
				local data = tweak_data.weapon.factory.parts[forbidden_part]

				if data then
					forbids[data.type] = (forbids[data.type] or 0) + 1
				end
			end

			local text = ""

			for category, amount in pairs(forbids) do
				if droppable_mods[category] then
					if text ~= "" then
						text = text .. "\n"
					end

					local category_count = 0
					local weapon_data = tweak_data.weapon.factory[weapon_id]

					for _, part_name in ipairs(weapon_data.uses_parts) do
						local part_data = tweak_data.weapon.factory.parts[part_name]

						if part_data and not part_data.unatainable and part_data.type == category and not table.contains(weapon_data.default_blueprint, part_name) then
							category_count = category_count + 1
						end
					end

					local percent_forbidden = amount / category_count
					local category = managers.localization:text("bm_menu_" .. tostring(category) .. "_plural")
					local quantifier = percent_forbidden == 1 and "all" or percent_forbidden > 0.66 and "most" or "some"
					quantifier = managers.localization:text("bm_mod_incompatibility_" .. tostring(quantifier))
					text = managers.localization:to_upper_text("bm_mod_incompatibilities", {
						quantifier = quantifier,
						category = category
					})
				end
			end

			updated_texts[5].text = text
		end
	elseif identifier == self.identifiers.mask_mod then
		if not managers.blackmarket:currently_customizing_mask() then
			return
		end

		local mask_mod_info = managers.blackmarket:info_customize_mask()
		local mask_base_price = managers.blackmarket:get_customize_mask_base_value()
		updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("bm_menu_masks") .. ": " .. self._data.topic_params.mask_name

		if mask_base_price and mask_base_price > 0 then
			updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_base_price)
		end

		updated_texts[2].text = updated_texts[2].text .. "\n"
		local resource_color = {}
		local material_text = managers.localization:to_upper_text("bm_menu_materials")
		local pattern_text = managers.localization:to_upper_text("bm_menu_textures")
		local colors_text = managers.localization:to_upper_text("bm_menu_colors")
		local color_a_text = managers.localization:to_upper_text("bm_menu_color_a")
		local color_b_text = managers.localization:to_upper_text("bm_menu_color_b")

		if mask_mod_info[1].overwritten then
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.risk)
		elseif mask_mod_info[1].is_good then
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. managers.localization:text(mask_mod_info[1].text)

			if mask_mod_info[1].price and mask_mod_info[1].price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[1].price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
		else
			updated_texts[2].text = updated_texts[2].text .. material_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.important_1)
		end

		if mask_mod_info[2].overwritten then
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.risk)
		elseif mask_mod_info[2].is_good then
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. managers.localization:text(mask_mod_info[2].text)

			if mask_mod_info[2].price and mask_mod_info[2].price > 0 then
				updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[2].price)
			end

			updated_texts[2].text = updated_texts[2].text .. "\n"
		else
			updated_texts[2].text = updated_texts[2].text .. pattern_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

			table.insert(resource_color, tweak_data.screen_colors.important_1)
		end

		local should_show_one_color = mask_mod_info[4].is_same or mask_mod_info[3].overwritten and mask_mod_info[4].overwritten

		if should_show_one_color then
			if mask_mod_info[3].overwritten then
				updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.risk)
			elseif mask_mod_info[3].is_good then
				updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. managers.localization:text(mask_mod_info[3].text)

				if mask_mod_info[3].price and mask_mod_info[3].price > 0 then
					updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[3].price)
				end

				updated_texts[2].text = updated_texts[2].text .. "\n"
			else
				updated_texts[2].text = updated_texts[2].text .. colors_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end
		else
			if mask_mod_info[3].overwritten then
				updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.risk)
			elseif mask_mod_info[3].is_good then
				updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. managers.localization:text(mask_mod_info[3].text)

				if mask_mod_info[3].price and mask_mod_info[3].price > 0 then
					updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[3].price)
				end

				updated_texts[2].text = updated_texts[2].text .. "\n"
			else
				updated_texts[2].text = updated_texts[2].text .. color_a_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end

			if mask_mod_info[4].overwritten then
				updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_overwritten") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.risk)
			elseif mask_mod_info[4].is_good then
				updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. managers.localization:text(mask_mod_info[4].text)

				if mask_mod_info[4].price and mask_mod_info[4].price > 0 then
					updated_texts[2].text = updated_texts[2].text .. " " .. managers.experience:cash_string(mask_mod_info[4].price)
				end

				updated_texts[2].text = updated_texts[2].text .. "\n"
			else
				updated_texts[2].text = updated_texts[2].text .. color_b_text .. ": " .. "##" .. managers.localization:to_upper_text("menu_bm_not_selected") .. "##" .. "\n"

				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end
		end

		updated_texts[2].text = updated_texts[2].text .. "\n"
		local price, can_afford = managers.blackmarket:get_customize_mask_value()

		if slot_data.global_value then
			local mask = managers.blackmarket:get_crafted_category("masks")[slot_data.prev_slot] or {}
			updated_texts[4].text = "\n\n" .. managers.localization:to_upper_text("menu_bm_highlighted") .. "\n" .. slot_data.name_localized
			local mod_price = managers.money:get_mask_part_price_modified(slot_data.category, slot_data.name, slot_data.global_value, mask.mask_id) or 0

			if mod_price > 0 then
				updated_texts[4].text = updated_texts[4].text .. " " .. managers.experience:cash_string(mod_price)
			else
				updated_texts[4].text = updated_texts[4].text
			end

			if slot_data.unlocked and slot_data.unlocked ~= true and slot_data.unlocked ~= 0 then
				updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:to_upper_text("bm_menu_item_amount", {
					amount = math.abs(slot_data.unlocked)
				})
			end

			updated_texts[4].resource_color = {}

			if slot_data.global_value and slot_data.global_value ~= "normal" then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
			end

			if slot_data.dlc_locked then
				updated_texts[3].text = managers.localization:to_upper_text(slot_data.dlc_locked)
			end

			local customize_mask_blueprint = managers.blackmarket:get_customize_mask_blueprint()
			local index = {
				colors = 3,
				materials = 1,
				textures = 2
			}
			index.mask_colors = index.colors
			index.colors = nil
			index = index[slot_data.category]

			if index == 1 then
				customize_mask_blueprint.material = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			elseif index == 2 then
				customize_mask_blueprint.pattern = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			elseif index == 3 then
				customize_mask_blueprint.color = {
					global_value = slot_data.global_value,
					id = slot_data.name
				}
			end

			local part_info = managers.blackmarket:get_info_from_mask_blueprint(customize_mask_blueprint, mask.mask_id)
			part_info = part_info[index]

			if part_info.override then
				updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text("menu_bm_overwrite", {
					category = managers.localization:text("bm_menu_" .. part_info.override)
				}) .. "##"

				table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.risk)
			end
		end

		if price and price > 0 then
			updated_texts[2].text = updated_texts[2].text .. managers.localization:to_upper_text("menu_bm_total_cost", {
				cost = (not can_afford and "##" or "") .. managers.experience:cash_string(price) .. (not can_afford and "##" or "")
			})

			if not can_afford then
				table.insert(resource_color, tweak_data.screen_colors.important_1)
			end
		end

		if #resource_color == 1 then
			updated_texts[2].resource_color = resource_color[1]
		else
			updated_texts[2].resource_color = resource_color
		end

		if not managers.blackmarket:can_finish_customize_mask() then
			local list_of_mods = ""
			local missed_mods = {}

			for _, data in ipairs(mask_mod_info) do
				if not data.is_good and not data.overwritten then
					table.insert(missed_mods, managers.localization:text(data.text))
				end
			end

			if #missed_mods > 1 then
				for i = 1, #missed_mods do
					list_of_mods = list_of_mods .. missed_mods[i]

					if i < #missed_mods - 1 then
						list_of_mods = list_of_mods .. ", "
					elseif i == #missed_mods - 1 then
						list_of_mods = list_of_mods .. ", "
					end
				end
			elseif #missed_mods == 1 then
				list_of_mods = missed_mods[1]
			end

			if slot_data.dlc_locked then
				updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
					missed_mods = list_of_mods
				}) .. "\n"
			else
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_missing_to_finalize_mask", {
					missed_mods = list_of_mods
				}) .. "\n"
			end
		elseif price and managers.money:total() < price then
			if slot_data.dlc_locked then
				updated_texts[3].text = updated_texts[3].text .. "\n" .. managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
			else
				updated_texts[3].text = managers.localization:to_upper_text("bm_menu_not_enough_cash") .. "\n"
			end
		end
	elseif identifier == self.identifiers.deployable then
		updated_texts[1].text = slot_data.name_localized

		if not self._slot_data.unlocked then
			updated_texts[3].text = managers.localization:to_upper_text(slot_data.level == 0 and (slot_data.skill_name or "bm_menu_skilltree_locked") or "bm_menu_level_req", {
				level = slot_data.level,
				SKILL = slot_data.name
			})
			updated_texts[3].text = updated_texts[3].text .. "\n"
		end

		updated_texts[4].text = managers.localization:text(tweak_data.blackmarket.deployables[slot_data.name].desc_id, {
			BTN_INTERACT = managers.localization:btn_macro("interact", true),
			BTN_USE_ITEM = managers.localization:btn_macro("use_item", true)
		})
	elseif identifier == self.identifiers.character then
		updated_texts[1].text = slot_data.name_localized

		if not slot_data.unlocked then
			local dlc_text_id = slot_data.dlc_locked or "ERR"
			local text = managers.localization:to_upper_text(dlc_text_id, {}) .. "\n"
			updated_texts[3].text = text
		end

		updated_texts[4].text = managers.localization:text(slot_data.name .. "_desc")
	elseif identifier == self.identifiers.weapon_cosmetic then
		updated_texts[1].text = managers.localization:text("bm_menu_steam_item_name", {
			type = managers.localization:text("bm_menu_" .. slot_data.category),
			name = slot_data.name_localized
		})
		updated_texts[1].resource_color = tweak_data.screen_colors.text

		if slot_data.weapon_id then
			updated_texts[2].text = managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)
		end

		updated_texts[4].resource_color = {}
		local cosmetic_rarity = slot_data.cosmetic_rarity
		local cosmetic_quality = slot_data.cosmetic_quality
		local cosmetic_bonus = slot_data.cosmetic_bonus

		if slot_data.is_a_color_skin then
			if slot_data.equipped then
				local color_id = slot_data.name
				local color_tweak = tweak_data.blackmarket.weapon_skins[color_id]

				if not slot_data.unlocked then
					local global_value = slot_data.global_value
					local gvalue_tweak = tweak_data.lootdrop.global_values[global_value]
					local dlc = color_tweak.dlc or managers.dlc:global_value_to_dlc(global_value)
					local unlocked = not dlc or managers.dlc:is_dlc_unlocked(dlc)
					local have_color = managers.blackmarket:has_item(global_value, "weapon_skins", color_id)

					if not unlocked then
						updated_texts[5].text = managers.localization:text(gvalue_tweak and gvalue_tweak.unlock_id or "bm_menu_dlc_locked")
					elseif not have_color then
						local achievement_locked_content = managers.dlc:weapon_color_achievement_locked_content(color_id)
						local dlc_tweak = tweak_data.dlc[achievement_locked_content]
						local achievement = dlc_tweak and dlc_tweak.achievement_id

						if achievement and managers.achievment:get_info(achievement) then
							local achievement_visual = tweak_data.achievement.visual[achievement]
							updated_texts[5].text = managers.localization:text(achievement_visual and achievement_visual.desc_id or "achievement_" .. tostring(achievement) .. "_desc" or "bm_menu_dlc_locked")
						else
							updated_texts[5].text = managers.localization:text("bm_menu_dlc_locked")
						end
					end
				end

				local name_string = managers.localization:to_upper_text(color_tweak.name_id)
				local color_index_string = managers.localization:to_upper_text("bm_menu_weapon_color_index", {
					variation = managers.localization:text(tweak_data.blackmarket:get_weapon_color_index_string(slot_data.cosmetic_color_index))
				})
				local quality_string = managers.localization:to_upper_text("bm_menu_weapon_color_quality", {
					quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
				})
				updated_texts[4].text = updated_texts[4].text .. name_string .. "\n" .. color_index_string .. "\n" .. quality_string

				table.insert(updated_texts[4].resource_color, tweak_data.screen_colors.text)
				table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
			else
				updated_texts[4].text = updated_texts[4].text .. managers.localization:text("bm_menu_customizable_weapon_color_desc")
			end
		else
			if not slot_data.unlocked then
				local safe = self:get_safe_for_economy_item(slot_data.name)
				safe = safe and safe.name_id or "invalid skin"
				local macros = {
					safe = managers.localization:text(safe)
				}
				local lock_text_id = slot_data.lock_text_id or "bm_menu_wcc_not_owned"
				updated_texts[5].text = (slot_data.default_blueprint and "" or "\n") .. managers.localization:text(lock_text_id, macros)
			end

			if cosmetic_rarity then
				updated_texts[4].text = updated_texts[4].text .. managers.localization:to_upper_text("bm_menu_steam_item_rarity", {
					rarity = managers.localization:text(tweak_data.economy.rarities[cosmetic_rarity].name_id)
				})

				table.insert(updated_texts[4].resource_color, tweak_data.economy.rarities[cosmetic_rarity].color or tweak_data.screen_colors.text)
			end

			if cosmetic_quality then
				updated_texts[4].text = updated_texts[4].text .. (cosmetic_rarity and "\n" or "") .. managers.localization:to_upper_text("bm_menu_steam_item_quality", {
					quality = managers.localization:text(tweak_data.economy.qualities[cosmetic_quality].name_id)
				})

				table.insert(updated_texts[4].resource_color, tweak_data.economy.qualities[cosmetic_quality].color or tweak_data.screen_colors.text)
			end

			if cosmetic_bonus then
				local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

				if bonus then
					local bonus_tweak = tweak_data.economy.bonuses[bonus]
					local bonus_value = bonus_tweak.exp_multiplier and bonus_tweak.exp_multiplier * 100 - 100 .. "%" or bonus_tweak.money_multiplier and bonus_tweak.money_multiplier * 100 - 100 .. "%"
					updated_texts[4].text = updated_texts[4].text .. ((cosmetic_quality or cosmetic_rarity) and "\n" or "") .. managers.localization:text("dialog_new_tradable_item_bonus", {
						bonus = managers.localization:text(bonus_tweak.name_id, {
							team_bonus = bonus_value
						})
					})
				end
			end
		end

		if slot_data.desc_id and slot_data.unlocked then
			updated_texts[4].text = updated_texts[4].text .. "\n" .. managers.localization:text(slot_data.desc_id)
		end

		if slot_data.global_value and slot_data.global_value ~= "normal" then
			updated_texts[4].text = updated_texts[4].text .. "\n##" .. managers.localization:to_upper_text(tweak_data.lootdrop.global_values[slot_data.global_value].desc_id) .. "##"

			table.insert(updated_texts[4].resource_color, tweak_data.lootdrop.global_values[slot_data.global_value].color)
		end

		updated_texts[4].below_stats = true
	elseif identifier == self.identifiers.inventory_tradable then
		if slot_data.name ~= "empty" then
			updated_texts[1].text = managers.localization:text("bm_menu_steam_item_name", {
				type = managers.localization:text("bm_menu_" .. slot_data.category),
				name = slot_data.name_localized
			})
			updated_texts[1].resource_color = tweak_data.screen_colors.text

			if slot_data.category == "weapon_skins" then
				updated_texts[1].text = ""
				local name_string = ""

				if slot_data.weapon_id then
					name_string = utf8.to_upper(managers.weapon_factory:get_weapon_name_by_weapon_id(slot_data.weapon_id)) .. " | "
				end

				name_string = name_string .. slot_data.name_localized
				local stat_bonus, team_bonus = nil

				if slot_data.cosmetic_quality then
					name_string = name_string .. ", " .. managers.localization:text(tweak_data.economy.qualities[slot_data.cosmetic_quality].name_id)
				end

				if slot_data.cosmetic_bonus then
					local bonus = tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id] and tweak_data.blackmarket.weapon_skins[slot_data.cosmetic_id].bonus

					if bonus then
						name_string = name_string .. ", " .. managers.localization:text("menu_bm_inventory_bonus")
					end
				end

				updated_texts[2].text = "##" .. name_string .. "##"

				if slot_data.cosmetic_rarity then
					updated_texts[2].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
				end

				updated_texts[4].text, updated_texts[4].resource_color = InventoryDescription.create_description_item({
					category = "weapon_skins",
					instance_id = 0,
					entry = slot_data.name,
					quality = slot_data.cosmetic_quality,
					bonus = slot_data.cosmetic_bonus
				}, tweak_data.blackmarket.weapon_skins[slot_data.name], {
					default = tweak_data.screen_colors.text,
					mods = tweak_data.screen_colors.text
				}, true)
				updated_texts[4].below_stats = true
			elseif slot_data.category == "armor_skins" then
				updated_texts[1].text = "##" .. updated_texts[1].text .. "##"

				if slot_data.cosmetic_rarity then
					updated_texts[1].resource_color = tweak_data.economy.rarities[slot_data.cosmetic_rarity].color or tweak_data.screen_colors.text
				end

				updated_texts[2].text = managers.localization:text(slot_data.desc_id)
			elseif slot_data.safe_entry then
				local content_text, color_ranges = InventoryDescription.create_description_safe(slot_data.safe_entry, {}, true)
				updated_texts[2].text = content_text
				updated_texts[2].resource_color = color_ranges
			elseif slot_data.desc_id then
				updated_texts[2].text = managers.localization:text(slot_data.desc_id)
			end
		end
	elseif identifier == self.identifiers.custom then
		if self._data.custom_update_text_info then
			self._data.custom_update_text_info(slot_data, updated_texts, self)
		end
	elseif Application:production_build() then
		updated_texts[1].text = identifier:s()
	end

	if identifier == self.identifiers.armor then
		self._stats_panel:set_top(self._armor_info_panel:bottom() + 10)
	end

	if self._desc_mini_icons then
		for _, gui_object in pairs(self._desc_mini_icons) do
			self._panel:remove(gui_object[1])
		end
	end

	self._desc_mini_icons = {}
	local desc_mini_icons = self._slot_data.desc_mini_icons
	local info_box_panel = self._panel:child("info_box_panel")

	if desc_mini_icons and table.size(desc_mini_icons) > 0 then
		for _, mini_icon in pairs(desc_mini_icons) do
			local new_icon = self._panel:bitmap({
				layer = 1,
				texture = mini_icon.texture,
				x = info_box_panel:left() + 10 + mini_icon.right,
				w = mini_icon.w or 32,
				h = mini_icon.h or 32
			})

			table.insert(self._desc_mini_icons, {
				new_icon,
				2
			})
		end

		updated_texts[2].text = string.rep("     ", table.size(desc_mini_icons)) .. updated_texts[2].text
	end

	if not ignore_lock and slot_data.lock_texture and slot_data.lock_texture ~= true then
		local new_icon = self._panel:bitmap({
			h = 20,
			blend_mode = "add",
			w = 20,
			layer = 1,
			texture = slot_data.lock_texture,
			texture_rect = slot_data.lock_rect or nil,
			x = info_box_panel:left() + 10,
			color = self._info_texts[3]:color()
		})
		updated_texts[3].text = "     " .. updated_texts[3].text

		table.insert(self._desc_mini_icons, {
			new_icon,
			3
		})
	end

	if is_renaming_this and self._rename_info_text then
		local text = self._renaming_item.custom_name ~= "" and self._renaming_item.custom_name or "##" .. tostring(slot_data.raw_name_localized) .. "##"
		updated_texts[self._rename_info_text].text = text
		updated_texts[self._rename_info_text].resource_color = tweak_data.screen_colors.text:with_alpha(0.35)
	end

	for id, _ in ipairs(self._info_texts) do
		self:set_info_text(id, updated_texts[id].text, updated_texts[id].resource_color)
	end

	local _, _, _, th = self._info_texts[1]:text_rect()

	self._info_texts[1]:set_h(th)

	local y = self._info_texts[1]:bottom()
	local title_offset = y
	local bg = self._info_texts_bg[1]

	if alive(bg) then
		bg:set_shape(self._info_texts[1]:shape())
	end

	local below_y = nil

	for i = 2, #self._info_texts do
		local info_text = self._info_texts[i]

		info_text:set_font_size(small_font_size)
		info_text:set_w(self._info_texts_panel:w())

		_, _, _, th = info_text:text_rect()

		info_text:set_y(y)
		info_text:set_h(th)

		if updated_texts[i].below_stats then
			if slot_data.comparision_data and alive(self._stats_text_modslist) then
				info_text:set_world_y(below_y or self._stats_text_modslist:world_top())

				below_y = (below_y or info_text:world_y()) + th
			else
				info_text:set_top((below_y or info_text:top()) + 20)

				below_y = (below_y or info_text:top()) + th
			end
		end

		local scale = 1
		local attempts = 5
		local max_h = self._info_texts_panel:h() - info_text:top()

		if not updated_texts[i].below_stats and slot_data.comparision_data and alive(self._stats_panel) then
			max_h = self._stats_panel:world_top() - info_text:world_top()
		end

		if info_text:h() ~= 0 and max_h > 0 and max_h < info_text:h() then
			local font_size = info_text:font_size()
			local wanted_h = max_h

			while info_text:h() ~= 0 and not math.within(math.ceil(info_text:h()), wanted_h - 10, wanted_h) and attempts > 0 do
				scale = wanted_h / info_text:h()
				font_size = math.clamp(font_size * scale, 0, small_font_size)

				info_text:set_font_size(font_size)

				_, _, _, th = info_text:text_rect()

				info_text:set_h(th)

				attempts = attempts - 1
			end

			if info_text:h() ~= 0 and info_text:h() > self._info_texts_panel:h() - info_text:top() then
				print("[BlackMarketGui] Info text dynamic font sizer failed")

				scale = (self._info_texts_panel:h() - info_text:top()) / info_text:h()

				info_text:set_font_size(font_size * scale)

				_, _, _, th = info_text:text_rect()

				info_text:set_h(th)
			end
		end

		local bg = self._info_texts_bg[i]

		if alive(bg) then
			bg:set_shape(info_text:shape())
		end

		y = info_text:bottom()
	end

	for _, desc_mini_icon in ipairs(self._desc_mini_icons) do
		desc_mini_icon[1]:set_y(title_offset)
		desc_mini_icon[1]:set_world_top(self._info_texts[desc_mini_icon[2] ]:world_top() + 1)
	end

	if is_renaming_this and self._rename_info_text and self._rename_caret then
		local info_text = self._info_texts[self._rename_info_text]
		local x, y, w, h = info_text:text_rect()

		if self._renaming_item.custom_name == "" then
			w = 0
		end

		self._rename_caret:set_w(2)
		self._rename_caret:set_h(h)
		self._rename_caret:set_world_position(x + w, y)
	end
end



function BlackMarketGui:get_lock_icon(data, default)
	local category = data.category
	local global_value = data.global_value
	local name = data.name
	local unlocked = data.unlocked
	local level = data.level
	local skill_based = data.skill_based
	local func_based = data.func_based

	if _G.IS_VR and data.vr_locked then
		return "units/pd2_dlc_vr/player/lock_vr"
	end

	if unlocked and (type(unlocked) ~= "number" or unlocked > 0) then
		return nil
	end

	local gv_tweak = tweak_data.lootdrop.global_values[global_value]

	if gv_tweak and gv_tweak.dlc and not managers.dlc:is_dlc_unlocked(global_value) then
		return gv_tweak.unique_lock_icon or "guis/textures/pd2/lock_dlc"
	end

	if level and (level > managers.experience:current_level()) then
		return "guis/textures/pd2/lock_level"
	end

	if skill_based then
		return "guis/textures/pd2/lock_skill"
	end

	if func_based then
		local _, _, icon = BlackMarketGui.get_func_based(func_based)

		return icon or "guis/textures/pd2/lock_skill"
	end

	return default or "guis/textures/pd2/lock_level"
end





function BlackMarketGui:populate_mods(data)
	local new_data = {}
	local default_mod = data.on_create_data.default_mod
	local crafted = managers.blackmarket:get_crafted_category(data.prev_node_data.category)[data.prev_node_data.slot]
	local global_values = crafted.global_values or {}
	local ids_id = Idstring(data.name)
	local cosmetic_kit_mod = nil
	local cosmetics_blueprint = crafted.cosmetics and crafted.cosmetics.id and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id] and tweak_data.blackmarket.weapon_skins[crafted.cosmetics.id].default_blueprint or {}

	for i, c_mod in ipairs(cosmetics_blueprint) do
		if Idstring(tweak_data.weapon.factory.parts[c_mod].type) == ids_id then
			cosmetic_kit_mod = c_mod

			break
		end
	end

	local old_num = #data

	for i = 1, old_num do
		data[i] = nil
	end

	local gvs = {}
	local mod_t = {}
	local num_steps = #data.on_create_data
	local achievement_tracker = tweak_data.achievement.weapon_part_tracker
	local part_is_from_cosmetic, mod_tweak, dlc_global_value, dlc_global_value_tweak, dlc_unlock_id, is_dlc_unlocked, mod_factory_tweak = nil
	local guis_catalog = "guis/"
	local index = 1

	for i, mod_t in ipairs(data.on_create_data) do
		local mod_name = mod_t[1]
		local mod_default = mod_t[2]
		local mod_global_value = mod_t[3] or "normal"
		part_is_from_cosmetic = cosmetic_kit_mod == mod_name
		mod_tweak = tweak_data.blackmarket.weapon_mods[mod_name]
		mod_factory_tweak = tweak_data.weapon.factory.parts[mod_name]
		guis_catalog = "guis/"
		local bundle_folder = mod_tweak and mod_tweak.texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = mod_name or data.prev_node_data.name,
			name_localized = mod_name and managers.weapon_factory:get_part_name_by_part_id(mod_name) or managers.localization:text("bm_menu_no_mod"),
			category = data.category or data.prev_node_data and data.prev_node_data.category
		}
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/mods/" .. new_data.name
		new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = mod_global_value
		new_data.unlocked = not crafted.customize_locked and (part_is_from_cosmetic or mod_factory_tweak.for_free) and 1 or mod_default or managers.blackmarket:get_item_amount(new_data.global_value, "weapon_mods", new_data.name, true)
		new_data.equipped = false
		new_data.stream = true
		new_data.default_mod = default_mod
		new_data.cosmetic_kit_mod = cosmetic_kit_mod
		new_data.is_internal = tweak_data.weapon.factory:is_part_internal(new_data.name)
		new_data.free_of_charge = part_is_from_cosmetic or mod_tweak and mod_tweak.is_a_unlockable
		new_data.unlock_tracker = false --achievement_tracker[new_data.name] or false
		new_data.dlc = new_data.global_value and managers.dlc:global_value_to_dlc(new_data.global_value)
		new_data.unlock_dlc = mod_tweak and mod_tweak.unlock_dlc or new_data.dlc
		is_dlc_unlocked = not new_data.dlc or managers.dlc:is_dlc_unlocked(new_data.dlc)
		new_data.hide_unavailable = not is_dlc_unlocked and managers.dlc:should_hide_unavailable(new_data.dlc)
		dlc_global_value, dlc_global_value_tweak, dlc_unlock_id = nil

		if crafted.customize_locked then
			new_data.unlocked = type(new_data.unlocked) == "number" and -math.abs(new_data.unlocked) or new_data.unlocked
			new_data.unlocked = new_data.unlocked ~= 0 and new_data.unlocked or false
			new_data.lock_texture = "guis/textures/pd2/lock_incompatible"
			new_data.dlc_locked = "bm_menu_cosmetic_locked_weapon"
		elseif not part_is_from_cosmetic and not is_dlc_unlocked then
			dlc_global_value = new_data.unlock_dlc and managers.dlc:dlc_to_global_value(new_data.unlock_dlc)
			dlc_global_value_tweak = dlc_global_value and tweak_data.lootdrop.global_values[dlc_global_value]
			dlc_unlock_id = dlc_global_value_tweak and tweak_data.lootdrop.global_values[dlc_global_value].unlock_id or managers.dlc:get_unavailable_id(new_data.global_value)
			new_data.dlc_locked = new_data.hide_unavailable and managers.dlc:get_unavailable_id(new_data.global_value) or dlc_unlock_id
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.lock_color = self:get_lock_color(new_data)
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.unlocked = new_data.unlocked ~= 0 and new_data.unlocked or false
		else
			local event_job_challenge = managers.event_jobs:get_challenge_from_reward("weapon_mods", new_data.name)

			if event_job_challenge and not event_job_challenge.completed then
				--[[managers.mission._fading_debug_output:script().log(tostring(new_data.name), Color.white)
				new_data.unlocked = type(new_data.unlocked) == "number" and -math.abs(new_data.unlocked) or new_data.unlocked
				new_data.lock_texture = "guis/textures/pd2/lock_achievement"
				new_data.dlc_locked = event_job_challenge.locked_id or "menu_event_job_lock_info"]] --todo remove later
			end
		end

		local weapon_id = managers.blackmarket:get_crafted_category(new_data.category)[new_data.slot].weapon_id
		new_data.price = part_is_from_cosmetic and 0 or managers.money:get_weapon_modify_price(weapon_id, new_data.name, new_data.global_value)
		new_data.can_afford = true --part_is_from_cosmetic or managers.money:can_afford_weapon_modification(weapon_id, new_data.name, new_data.global_value)
		local font, font_size = nil
		local no_upper = false

		if crafted.previewing then
			new_data.previewing = true
			new_data.corner_text = {
				selected_text = managers.localization:text("bm_menu_mod_preview")
			}
			new_data.corner_text.noselected_text = new_data.corner_text.selected_text
			new_data.corner_text.noselected_color = Color.white
		elseif not new_data.lock_texture and (not new_data.unlocked or new_data.unlocked == 0) then
			if managers.dlc:is_content_achievement_locked("weapon_mods", new_data.name) or managers.dlc:is_content_achievement_milestone_locked("weapon_mods", new_data.name) then
				new_data.lock_texture = "guis/textures/pd2/lock_achievement"
			elseif managers.dlc:is_content_skirmish_locked("weapon_mods", new_data.name) then
				new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
			elseif managers.dlc:is_content_crimespree_locked("weapon_mods", new_data.name) then
				new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
			elseif managers.dlc:is_content_infamy_locked("weapon_mods", new_data.name) then
				new_data.lock_texture = "guis/textures/pd2/lock_infamy"
				new_data.dlc_locked = "menu_infamy_lock_info"
			else
				local event_job_challenge = managers.event_jobs:get_challenge_from_reward("weapon_mods", new_data.name)

				--[[if event_job_challenge and not event_job_challenge.completed then
					new_data.unlocked = -math.abs(new_data.unlocked)
					new_data.lock_texture = "guis/textures/pd2/lock_achievement"
					new_data.dlc_locked = event_job_challenge.locked_id or "menu_event_job_lock_info"
				else]] --todo remove later
					local selected_text = managers.localization:text("bm_menu_no_items")
					new_data.corner_text = {
						selected_text = selected_text,
						noselected_text = selected_text
					}
				--end
			end
		elseif new_data.unlocked and not new_data.can_afford then
			new_data.corner_text = {
				selected_text = managers.localization:text("bm_menu_not_enough_cash")
			}
			new_data.corner_text.noselected_text = new_data.corner_text.selected_text
		end

		local forbid = nil

		if mod_name then
			forbid = managers.blackmarket:can_modify_weapon(new_data.category, new_data.slot, new_data.name)

			if forbid then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				else
					new_data.unlocked = false
				end

				new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
				new_data.mid_text = nil
				new_data.conflict = managers.localization:text("bm_menu_" .. tostring(string.gsub(tweak_data.weapon.factory.parts[forbid] and tweak_data.weapon.factory.parts[forbid].type or forbid, "_lock", "")))
			end

			local replaces, removes = managers.blackmarket:get_modify_weapon_consequence(new_data.category, new_data.slot, new_data.name)
			new_data.removes = removes or {}
			local weapon = managers.blackmarket:get_crafted_category_slot(data.prev_node_data.category, data.prev_node_data.slot) or {}
			local gadget = nil
			local mod_td = tweak_data.weapon.factory.parts[new_data.name]
			local mod_type = mod_td.type
			local sub_type = mod_td.sub_type
			local is_auto = weapon and tweak_data.weapon[weapon.weapon_id] and tweak_data.weapon[weapon.weapon_id].FIRE_MODE == "auto"

			if mod_type == "gadget" then
				gadget = not (mod_td.adds and #mod_td.adds>0) and sub_type or nil
			end

			local silencer = sub_type == "silencer" and true
			local texture = managers.menu_component:get_texture_from_mod_type(mod_type, sub_type, gadget, silencer, is_auto)
			new_data.desc_mini_icons = {}

			if DB:has(Idstring("texture"), texture) then
				table.insert(new_data.desc_mini_icons, {
					h = 16,
					w = 16,
					bottom = 0,
					right = 0,
					texture = texture
				})
			end

			local is_gadget = false
			local show_stats = not new_data.conflict and new_data.unlocked and not is_gadget and not new_data.dlc_locked and tweak_data.weapon.factory.parts[new_data.name].type ~= "charm"

			if show_stats then
				new_data.comparision_data = managers.blackmarket:get_weapon_stats_with_mod(new_data.category, new_data.slot, mod_name)
			end

			if managers.blackmarket:got_new_drop(mod_global_value, "weapon_mods", mod_name) then
				new_data.mini_icons = new_data.mini_icons or {}

				table.insert(new_data.mini_icons, {
					texture = "guis/textures/pd2/blackmarket/inv_newdrop",
					name = "new_drop",
					h = 16,
					w = 16,
					top = 0,
					layer = 1,
					stream = false,
					right = 0
				})

				new_data.new_drop_data = {
					new_data.global_value or "normal",
					"weapon_mods",
					mod_name
				}
			end
		end

		local active = true
		local can_apply = not crafted.previewing
		local preview_forbidden = managers.blackmarket:is_previewing_legendary_skin() or managers.blackmarket:preview_mod_forbidden(new_data.category, new_data.slot, new_data.name)

		if mod_name and not crafted.customize_locked and active then
			local locked = (
				managers.dlc:is_content_achievement_locked("weapon_mods", new_data.name)
				or managers.dlc:is_content_achievement_milestone_locked("weapon_mods", new_data.name)
				or managers.dlc:is_content_skirmish_locked("weapon_mods", new_data.name)
				or managers.dlc:is_content_crimespree_locked("weapon_mods", new_data.name)
				or managers.dlc:is_content_infamy_locked("weapon_mods", new_data.name)
			)
			if new_data.unlocked and (type(new_data.unlocked) ~= "number" or new_data.unlocked > 0) and can_apply and not locked then
				if new_data.can_afford then
					table.insert(new_data, "wm_buy")
				end

				if managers.blackmarket:is_previewing_any_mod() then
					table.insert(new_data, "wm_clear_mod_preview")
				end

				if not new_data.is_internal and not preview_forbidden then
					if managers.blackmarket:is_previewing_mod(new_data.name) then
						table.insert(new_data, "wm_remove_preview")
					else
						table.insert(new_data, "wm_preview_mod")
					end
				end
			else
				local dlc_data = dlc_global_value and Global.dlc_manager.all_dlc_data[dlc_global_value]
				dlc_data = dlc_data or Global.dlc_manager.all_dlc_data[new_data.global_value]

				if dlc_data and dlc_data.app_id and not dlc_data.external and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
					table.insert(new_data, "bw_buy_dlc")
				end

				if managers.blackmarket:is_previewing_any_mod() then
					table.insert(new_data, "wm_clear_mod_preview")
				end

				if not new_data.is_internal and not preview_forbidden then
					if managers.blackmarket:is_previewing_mod(new_data.name) then
						table.insert(new_data, "wm_remove_preview")
					else
						table.insert(new_data, "wm_preview_mod")
					end
				end
			end

			if managers.workshop and managers.workshop:enabled() and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), weapon_id) then
				table.insert(new_data, "w_skin")
			end

			if new_data.unlocked and not new_data.dlc_locked and not locked then
				local weapon_mod_tweak = tweak_data.weapon.factory.parts[mod_name]

				if weapon_mod_tweak and weapon_mod_tweak.is_a_unlockable ~= true and can_apply and managers.custom_safehouse:unlocked() then
					table.insert(new_data, "wm_buy_mod")
				end
			end
		end

		data[index] = new_data
		index = index + 1
	end

	for i = 1, math.max(math.ceil(num_steps / WEAPON_MODS_SLOTS[1]), WEAPON_MODS_SLOTS[2]) * WEAPON_MODS_SLOTS[1] do
		if not data[i] then
			new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = i,
				unlocked = true,
				equipped = false
			}
			data[i] = new_data
		end
	end

	local weapon_blueprint = managers.blackmarket:get_weapon_blueprint(data.prev_node_data.category, data.prev_node_data.slot) or {}
	local equipped = nil

	local function update_equipped()
		if equipped then
			data[equipped].equipped = true
			data[equipped].unlocked = not crafted.customize_locked and (data[equipped].unlocked or true)
			data[equipped].mid_text = crafted.customize_locked and data[equipped].mid_text or nil
			data[equipped].lock_texture = crafted.customize_locked and data[equipped].lock_texture or nil
			data[equipped].corner_text = crafted.customize_locked and data[equipped].corner_text or nil

			for i = 1, #data[equipped] do
				table.remove(data[equipped], 1)
			end

			--data[equipped].price = 0
			data[equipped].can_afford = true

			if not crafted.customize_locked then
				table.insert(data[equipped], "wm_remove_buy")

				if not data[equipped].is_internal then
					local preview_forbidden = managers.blackmarket:is_previewing_legendary_skin() or managers.blackmarket:preview_mod_forbidden(data[equipped].category, data[equipped].slot, data[equipped].name)

					if managers.blackmarket:is_previewing_any_mod() then
						table.insert(data[equipped], "wm_clear_mod_preview")
					end

					if managers.blackmarket:is_previewing_mod(data[equipped].name) then
						table.insert(data[equipped], "wm_remove_preview")
					elseif not preview_forbidden then
						table.insert(data[equipped], "wm_preview_mod")
					end
				else
					table.insert(data[equipped], "wm_preview")
				end

				if managers.workshop and managers.workshop:enabled() and data.prev_node_data and not table.contains(managers.blackmarket:skin_editor():get_excluded_weapons(), data.prev_node_data.name) then
					table.insert(data[equipped], "w_skin")
				end

				local weapon_mod_tweak = tweak_data.weapon.factory.parts[data[equipped].name]

				if weapon_mod_tweak and weapon_mod_tweak.type ~= "bonus" and weapon_mod_tweak.is_a_unlockable ~= true and managers.custom_safehouse:unlocked() then
					table.insert(data[equipped], "wm_buy_mod")
				end
			end

			local factory = tweak_data.weapon.factory.parts[data[equipped].name]
			local is_correct_type = data.name == "sight" or data.name == "gadget"
			is_correct_type = is_correct_type or data.name == "second_sight"

			if is_correct_type and factory and factory.texture_switch then
				if not crafted.customize_locked then
					table.insert(data[equipped], "wm_reticle_switch_menu")
				end

				local reticle_texture = managers.blackmarket:get_part_texture_switch(data[equipped].category, data[equipped].slot, data[equipped].name)

				if reticle_texture and reticle_texture ~= "" then
					data[equipped].mini_icons = data[equipped].mini_icons or {}

					table.insert(data[equipped].mini_icons, {
						layer = 2,
						h = 30,
						stream = true,
						w = 30,
						blend_mode = "add",
						bottom = 1,
						right = 1,
						texture = reticle_texture
					})
				end
			end

			local gmod_name = data[equipped].name
			local gmod_td = tweak_data.weapon.factory.parts[gmod_name]
			local has_customizable_gadget = (data.name == "gadget" or table.contains(gmod_td.perks or {}, "gadget")) and (gmod_td.sub_type == "laser" or gmod_td.sub_type == "flashlight")

			if not has_customizable_gadget and gmod_td.adds then
				for _, part_id in ipairs(gmod_td.adds) do
					local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type

					if sub_type == "laser" or sub_type == "flashlight" then
						has_customizable_gadget = true

						break
					end
				end
			end

			if has_customizable_gadget then
				if not crafted.customize_locked then
					table.insert(data[equipped], "wm_customize_gadget")
				end

				local secondary_sub_type = false

				if gmod_td.adds then
					for _, part_id in ipairs(gmod_td.adds) do
						local sub_type = tweak_data.weapon.factory.parts[part_id].sub_type

						if sub_type == "laser" or sub_type == "flashlight" then
							secondary_sub_type = sub_type

							break
						end
					end
				end

				local colors = managers.blackmarket:get_part_custom_colors(data[equipped].category, data[equipped].slot, gmod_name)

				if colors then
					data[equipped].mini_colors = {}

					if gmod_td.sub_type then
						table.insert(data[equipped].mini_colors, {
							alpha = 0.8,
							blend = "add",
							color = colors[gmod_td.sub_type] or Color(1, 0, 1)
						})
					end

					if secondary_sub_type then
						table.insert(data[equipped].mini_colors, {
							alpha = 0.8,
							blend = "add",
							color = colors[secondary_sub_type] or Color(1, 0, 1)
						})
					end
				end
			end

			if not data[equipped].conflict then
				if false then
					if data[equipped].default_mod then
						data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_with_mod(data[equipped].category, data[equipped].slot, data[equipped].default_mod)
					else
						data[equipped].comparision_data = managers.blackmarket:get_weapon_stats_without_mod(data[equipped].category, data[equipped].slot, data[equipped].name)
					end
				end
			end
		end
	end

	for i, mod in ipairs(data) do
		for _, weapon_mod in ipairs(weapon_blueprint) do
			if mod.name == weapon_mod and (not global_values[weapon_mod] or global_values[weapon_mod] == data[i].global_value) then
				equipped = i

				break
			end
		end
	end

	update_equipped()
end

--BUYING PARTS FOR CASH
function BlackMarketGui:purchase_weapon_mod_callback(data)
	data.cc_cost = managers.money:get_weapon_modify_price(nil, data.name, data.global_value)
	local params = {
		name = data.name_localized or data.name,
		category = data.category,
		slot = data.slot,
		money = managers.experience:cash_string(data.cc_cost)
	}
	local weapon_mod_tweak = tweak_data.weapon.factory.parts[data.name]

	if weapon_mod_tweak and weapon_mod_tweak.is_event_mod and (not data.unlocked or data.unlocked < 1) then
		params.unlock_text = managers.localization:text(weapon_mod_tweak.is_event_mod)
		local dialog_data = {
			title = managers.localization:text("dialog_bm_purchase_mod_locked_title"),
			text = managers.localization:text("dialog_bm_purchase_mod_locked", params)
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)

		return
	end

	local total = managers.money:total()
	if data.cc_cost > total then
		local dialog_data = {
			title = managers.localization:text("dialog_bm_purchase_mod_cant_afford_title"), --bm_menu_not_enough_cash
			text = managers.localization:text("dialog_bm_purchase_mod_cant_afford_nqr", params)
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)

		return
	end

	params.yes_func = callback(self, self, "_dialog_yes", callback(self, self, "_confirm_purchase_weapon_mod_callback", data))
	params.no_func = callback(self, self, "_dialog_no")

	managers.menu:show_confirm_blackmarket_weapon_mod_purchase(params)
end

--WITHDRAW CASH INSTEAD OF COINS
function BlackMarketGui:_confirm_purchase_weapon_mod_callback(data)
	managers.menu_component:post_event("item_sell")
	managers.blackmarket:add_to_inventory(data.global_value, "weapon_mods", data.name, true)
	managers.money:_deduct_from_total(data.cc_cost)
	self:reload()
end



function BlackMarketGui:show_stats()
	if not self._stats_panel or not self._rweapon_stats_panel or not self._armor_stats_panel or not self._mweapon_stats_panel then return end
	self._stats_panel:hide()
	self._rweapon_stats_panel:hide()
	self._armor_stats_panel:hide()
	self._mweapon_stats_panel:hide()
	if not self._slot_data then return end
	if not self._slot_data.comparision_data then return end
	local weapon = managers.blackmarket:get_crafted_category_slot(self._slot_data.category, self._slot_data.slot)
	local name = weapon and weapon.weapon_id or self._slot_data.name
	local category = self._slot_data.category
	local slot = self._slot_data.slot
	local hide_stats = false
	local value = 0
	local tweak_stats = tweak_data.weapon.stats
	local modifier_stats = tweak_data.weapon[name] and tweak_data.weapon[name].stats_modifiers

	-------------------------------------------------------------------------------------------------------------------------

	if self._slot_data.dont_compare_stats then
		local selection_index = tweak_data:get_raw_value("weapon", self._slot_data.weapon_id, "use_data", "selection_index") or 1
		local category = selection_index == 1 and "secondaries" or "primaries"
		modifier_stats = tweak_data.weapon[self._slot_data.weapon_id] and tweak_data.weapon[self._slot_data.weapon_id].stats_modifiers
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(self._slot_data.weapon_id, nil, nil, self._slot_data.default_blueprint)

		self:set_weapons_stats_columns()
		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles({
			x = 170,
			name = "base"
		}, {
			name = "mod",
			x = 215,
			text_id = "bm_menu_stats_mod",
			color = tweak_data.screen_colors.stats_mods
		}, {
			alpha = 0.0075,
			name = "skill"
		})

		for _, title in pairs(self._stats_titles) do
			title:show()
		end

		self:set_stats_titles({
			hide = true,
			name = "total"
		}, {
			alpha = 1,
			name = "equip",
			x = 120,
			text_id = "bm_menu_stats_total"
		})

		for _, stat in ipairs(self._stats_shown) do
			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = (
				type(base_stats[stat.name].value)=="number"
				and math.max(base_stats[stat.name].value + mods_stats[stat.name].value + skill_stats[stat.name].value, 0)
				or (mods_stats[stat.name].value or base_stats[stat.name].value)
			)
			local base = base_stats[stat.name].value

			local mags_slot = stat.name=="totalammo" and not (
				tweak_data.weapon[name].use_shotgun_reload or tweak_data.weapon[name].feed_system=="break_action"
			) and " mag" or ""

			self._stats_texts[stat.name].equip:set_alpha(1)
			self._stats_texts[stat.name].equip:set_text(format_round(value, stat.round_value)..mags_slot..(mags_slot~="" and mods_to_draw~="" and mods_to_draw~="1" and "s" or ""))
			self._stats_texts[stat.name].base:set_text(format_round(base, stat.round_value)..mags_slot..(mags_slot~="" and mods_to_draw~="" and mods_to_draw~="1" and "s" or ""))
			self._stats_texts[stat.name].mods:set_text((mods_stats[stat.name].value==0 or mods_stats[stat.name].value=="") and "" or (mods_stats[stat.name].value > 0 and "+" or "") .. format_round(mods_stats[stat.name].value, stat.round_value)..(mods_stats[stat.name].value>0 and mags_text or "")..(mods_stats[stat.name].value>0 and mods_stats[stat.name].value>1 and "s" or ""))
			self._stats_texts[stat.name].skill:set_text(skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name].value > 0 and "+" or "") .. format_round(skill_stats[stat.name].value, stat.round_value) or "")
			self._stats_texts[stat.name].total:set_text("")
			self._stats_texts[stat.name].base:set_alpha(0.75)
			self._stats_texts[stat.name].mods:set_alpha(0.75)
			self._stats_texts[stat.name].skill:set_alpha(0.75)

			if base < value then
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
			elseif value < base then
				self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
			else
				self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
			end

			self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
			self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
		end
	elseif tweak_data.weapon[self._slot_data.name] or self._slot_data.default_blueprint then --BLACKMARKET MAIN
		self:set_weapons_stats_columns()

		local equipped_item = managers.blackmarket:equipped_item(category)
		local equipped_slot = self._slot_data.equipped_slot or managers.blackmarket:equipped_weapon_slot(category)
		local equipped_name = self._slot_data.equipped_name or equipped_item.weapon_id
		if self._slot_data.default_blueprint then equipped_slot = slot equipped_name = name end
		local equip_base_stats, equip_mods_stats, equip_skill_stats = WeaponDescription._get_stats(equipped_name, category, equipped_slot)
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, self._slot_data.default_blueprint)

		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles(
			{ x = 195, name = "base" },
			{ alpha = 0.75, name = "mod", text_id = "bm_menu_stats_mod", x = 265, color = tweak_data.screen_colors.stats_mods },
			{ alpha = 0.0075, name = "skill" }
		)

		if slot ~= equipped_slot then
			for _, title in pairs(self._stats_titles) do title:hide() end
			self:set_stats_titles(
				{ show = true, name = "total" },
				{ name = "equip", text_id = "bm_menu_equipped", alpha = 0.75, x = 105, show = true }
			)
		else
			for _, title in pairs(self._stats_titles) do title:show() end
			self:set_stats_titles(
				{ hide = true, name = "total" },
				{ alpha = 1, name = "equip", x = 120, text_id = "bm_menu_stats_total" }
			)
		end

		for _, stat in ipairs(self._stats_shown) do
			local base = base_stats[stat.name] and base_stats[stat.name].value
			local total = 0
			local mods_to_draw = 0
			local equip = 0
			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			if stat.name == "optimal_range" then
				local equipped_blueprint = managers.blackmarket:get_weapon_blueprint(category, equipped_slot)
				local equipped_damage_falloff = self:get_damage_falloff_from_weapon(equipped_name, equipped_blueprint)
				local stat_object = self._stats_texts[stat.name]
				local equipped_falloff_string = self:damage_falloff_to_string(equipped_damage_falloff)
				stat_object.equip:set_text(equipped_falloff_string)
				stat_object.equip:set_alpha(1)
				if slot == equipped_slot then
					local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(managers.weapon_factory:get_factory_id_by_weapon_id(name))
					local default_damage_falloff = self:get_damage_falloff_from_weapon(equipped_name, default_blueprint)
					local default_falloff_string = self:damage_falloff_to_string(default_damage_falloff)
					stat_object.base:set_text(default_falloff_string)
					if default_falloff_string ~= equipped_falloff_string then
						stat_object.mods:set_text(equipped_falloff_string)
					else
						stat_object.mods:set_text("") end
					stat_object.total:set_text("")
				else
					local selected_blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)
					local selected_damage_falloff = self:get_damage_falloff_from_weapon(name, selected_blueprint)
					local selected_falloff_string = self:damage_falloff_to_string(selected_damage_falloff)
					stat_object.base:set_text("")
					stat_object.mods:set_text("")
					stat_object.total:set_text(selected_falloff_string)
					stat_object.total:set_alpha(1)
					stat_object.equip:set_alpha(0.75)
				end
				stat_object.skill:set_text("")
				stat_object.removed:set_text("")
			elseif stat.name=="damage" or stat.name=="spread" or stat.name=="recoil" then
				mods_stats[stat.name].value = mods_stats[stat.name].value~=base_stats[stat.name].value and mods_stats[stat.name].value-base_stats[stat.name].value or 0
				mods_to_draw = mods_stats[stat.name].value~=0 and format_round(mods_stats[stat.name].value, stat.round_value)
				mods_to_draw = (
					mods_stats[stat.name].value==0 and ""
					or (mods_stats[stat.name].value>0 and (stat.override and "=" or "+") or "")..format_round(mods_stats[stat.name].value, stat.round_value)
				) or format_round(mods_stats[stat.name].value, stat.round_value)
				total = math.max(base_stats[stat.name].value + mods_stats[stat.name].value, 0)

				if slot~=equipped_slot then
					equip_mods_stats[stat.name].value = equip_mods_stats[stat.name].value~=equip_base_stats[stat.name].value and equip_mods_stats[stat.name].value-equip_base_stats[stat.name].value or 0
					equip = math.max(equip_base_stats[stat.name].value + equip_mods_stats[stat.name].value, 0)
				end
			else
				if type(mods_stats[stat.name].value)=="table" then
					mods_stats[stat.name].value = mods_stats[stat.name].value[
						mods_stats["caliber"].value~=0
						and mods_stats["caliber"].value
						or base_stats["caliber"].value
					] or 0
				end
				mods_to_draw = (
					(type(base_stats[stat.name].value)=="number" or type(mods_stats[stat.name].value)=="number")
					and (
						mods_stats[stat.name].value==0 and ""
						or (mods_stats[stat.name].value>0 and (stat.override and "=" or "+") or "")..format_round(mods_stats[stat.name].value, stat.round_value)
					)
					or format_round(mods_stats[stat.name].value, stat.round_value)
				)
				total = (
					stat.override and (mods_stats[stat.name].value~=0 and mods_stats[stat.name].value or base_stats[stat.name].value)
					or math.max((base_stats[stat.name].value or 0) + (mods_stats[stat.name].value or 0), 0)
				)

				if slot~=equipped_slot then
					if type(equip_mods_stats[stat.name].value)=="table" or type(equip_base_stats[stat.name].value)=="table" then
						equip_mods_stats[stat.name].value = equip_mods_stats[stat.name].value[equip_mods_stats["caliber"].value~=0 and equip_mods_stats["caliber"].value or equip_base_stats["caliber"].value ] or 0
					end
					equip = stat.override and
						(equip_mods_stats[stat.name].value~=0 and equip_mods_stats[stat.name].value or equip_base_stats[stat.name].value)
						or ( math.max(equip_base_stats[stat.name].value + equip_mods_stats[stat.name].value, 0))
				end
			end

			local mags_slot = stat.name=="totalammo" and not (
				tweak_data.weapon[name].use_shotgun_reload or tweak_data.weapon[name].feed_system=="break_action"
			) and " mag" or ""
			local mags_eqslot = stat.name=="totalammo" and not (
				tweak_data.weapon[equipped_name].use_shotgun_reload or tweak_data.weapon[equipped_name].feed_system=="break_action"
			) and " mag" or ""

			if stat.name == "optimal_range" then
			else
				if slot == equipped_slot then
					self._stats_texts[stat.name].equip:set_alpha(1)
					self._stats_texts[stat.name].equip:set_text(format_round(total, stat.round_value)..mags_slot..(mags_slot~="" and total~=1 and "s" or ""))
					self._stats_texts[stat.name].base:set_text(format_round(base, stat.round_value)..mags_slot..(mags_slot~="" and base~=1 and "s" or ""))
					self._stats_texts[stat.name].mods:set_text(mods_to_draw..(mods_to_draw~="" and mags_slot or "")..(mags_slot~="" and mods_to_draw~="" and mods_to_draw~="1" and "s" or ""))
					self._stats_texts[stat.name].skill:set_text(skill_stats[stat.name]) --skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name] > 0 and "+" or "") .. format_round(skill_stats[stat.name], stat.round_value) or "")
					self._stats_texts[stat.name].total:set_text("")
					self._stats_texts[stat.name].removed:set_text("")
					self._stats_texts[stat.name].base:set_alpha(0.75)
					self._stats_texts[stat.name].mods:set_alpha(0.75)
					self._stats_texts[stat.name].skill:set_alpha(0.75)
					if type(base)=="number" and type(total)=="number" then
						if base < total then
							self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
						elseif total < base then
							self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
						else
							self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
						end
					end
					self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
					self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				else
					self._stats_texts[stat.name].equip:set_alpha(0.75)
					self._stats_texts[stat.name].equip:set_text(format_round(equip, stat.round_value)..mags_eqslot..(mags_eqslot~="" and equip~=1 and "s" or ""))
					self._stats_texts[stat.name].base:set_text("")
					self._stats_texts[stat.name].mods:set_text("")
					self._stats_texts[stat.name].skill:set_text("")
					self._stats_texts[stat.name].removed:set_text("")
					self._stats_texts[stat.name].total:set_text(format_round(total, stat.round_value)..mags_slot..(mags_slot~="" and total~=1 and "s" or ""))
					if type(equip)=="number" and type(total)=="number" then
						local mag = math.max(base_stats.magazine.value + mods_stats.magazine.value, 0)
						local eqmag = math.max(equip_base_stats.magazine.value + equip_mods_stats.magazine.value, 0)
						if (mags_eqslot~="" and (equip*eqmag) or equip) < (mags_slot~="" and (total*mag) or total) then
							self._stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
						elseif (mags_slot~="" and (total*mag) or total) < (mags_eqslot~="" and (equip*eqmag) or equip) then
							self._stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
						else
							self._stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
						end
					end
					self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.resource)
					self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end
			end
		end
	elseif tweak_data.blackmarket.armors[self._slot_data.name] then --BLACKMARKET ARMORS
		local equipped_item = managers.blackmarket:equipped_item(category)
		local equipped_slot = managers.blackmarket:equipped_armor_slot()
		local equip_base_stats, equip_mods_stats, equip_skill_stats = self:_get_armor_stats(equipped_item)
		local base_stats, mods_stats, skill_stats = self:_get_armor_stats(self._slot_data.name)

		self._armor_stats_panel:show()
		self:hide_weapon_stats()
		self:hide_melee_weapon_stats()
		self:set_stats_titles({
			x = 185,
			name = "base"
		}, {
			name = "mod",
			x = 245,
			text_id = "bm_menu_stats_skill",
			color = tweak_data.screen_colors.resource
		}, {
			alpha = 0,
			name = "skill"
		})

		if self._slot_data.name ~= equipped_slot then
			for _, title in pairs(self._stats_titles) do
				title:hide()
			end

			self:set_stats_titles({
				show = true,
				name = "total"
			}, {
				name = "equip",
				text_id = "bm_menu_equipped",
				alpha = 0.75,
				x = 105,
				show = true
			})
		else
			for title_name, title in pairs(self._stats_titles) do
				title:show()
			end

			self:set_stats_titles({
				hide = true,
				name = "total"
			}, {
				alpha = 1,
				name = "equip",
				x = 120,
				text_id = "bm_menu_stats_total"
			})
		end

		for _, stat in ipairs(self._armor_stats_shown) do
			self._armor_stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			value = base_stats[stat.name].value --+ mods_stats[stat.name] + skill_stats[stat.name] --math.max(base_stats[stat.name] + mods_stats[stat.name] + skill_stats[stat.name], 0)

			if self._slot_data.name == equipped_slot then
				local base = base_stats[stat.name].value

				self._armor_stats_texts[stat.name].equip:set_alpha(1)
				self._armor_stats_texts[stat.name].equip:set_text((stat.multiplier and "x" or "")..format_round(value, stat.round_value)..(stat.percent and "%" or ""))
				self._armor_stats_texts[stat.name].base:set_text((stat.multiplier and "x" or "")..format_round(base, stat.round_value)..(stat.percent and "%" or ""))
				self._armor_stats_texts[stat.name].skill:set_text()--skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name] > 0 and "+" or "") .. format_round(skill_stats[stat.name], stat.round_value) or "")
				self._armor_stats_texts[stat.name].total:set_text("")
				self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				if value ~= 0 and base < value then
					self._armor_stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
				elseif value ~= 0 and value < base then
					self._armor_stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
				else
					self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end

				self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
			else
				local equip = equip_base_stats[stat.name].value --math.max(equip_base_stats[stat.name] + equip_mods_stats[stat.name] + equip_skill_stats[stat.name], 0)

				self._armor_stats_texts[stat.name].equip:set_alpha(0.75)
				self._armor_stats_texts[stat.name].equip:set_text((stat.multiplier and "x" or "")..format_round(equip, stat.round_value)..(stat.percent and "%" or ""))
				self._armor_stats_texts[stat.name].base:set_text("")
				self._armor_stats_texts[stat.name].skill:set_text("")
				self._armor_stats_texts[stat.name].total:set_text((stat.multiplier and "x" or "")..format_round(value, stat.round_value)..(stat.percent and "%" or ""))

				if equip < value then
					self._armor_stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
				elseif value < equip then
					self._armor_stats_texts[stat.name].total:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
				else
					self._armor_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				end

				self._armor_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
			end
		end
	elseif tweak_data.economy.armor_skins[self._slot_data.name] then
		self:hide_melee_weapon_stats()
		self:hide_armor_stats()
		self:hide_weapon_stats()

		for _, title in pairs(self._stats_titles) do
			title:hide()
		end

		hide_stats = true
	elseif tweak_data.blackmarket.melee_weapons[self._slot_data.name] then --BLACKMARKET MELEE
		self:hide_armor_stats()
		self:hide_weapon_stats()
		self._mweapon_stats_panel:show()
		self:set_stats_titles({
			x = 185,
			name = "base"
		}, {
			name = "mod",
			x = 245,
			text_id = "bm_menu_stats_skill",
			color = tweak_data.screen_colors.resource
		}, {
			alpha = 0,
			name = "skill"
		})

		local equipped_item = managers.blackmarket:equipped_item(category)
		local equip_base_stats, equip_mods_stats, equip_skill_stats = self:_get_melee_weapon_stats(equipped_item)
		local base_stats, mods_stats, skill_stats = self:_get_melee_weapon_stats(self._slot_data.name)

		if self._slot_data.name ~= equipped_item then
			for _, title in pairs(self._stats_titles) do
				title:hide()
			end

			self:set_stats_titles({
				show = true,
				name = "total"
			}, {
				name = "equip",
				text_id = "bm_menu_equipped",
				alpha = 0.75,
				x = 105,
				show = true
			})
		else
			for title_name, title in pairs(self._stats_titles) do
				title:show()
			end

			self:set_stats_titles({
				hide = true,
				name = "total"
			}, {
				alpha = 1,
				name = "equip",
				x = 120,
				text_id = "bm_menu_stats_total"
			})
		end

		local value_min, value_max, skill_value_min, skill_value_max, skill_value = nil

		for _, stat in ipairs(self._mweapon_stats_shown) do
			self._mweapon_stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			if stat.range then
				value_min = base_stats[stat.name].min_value --math.max(base_stats[stat.name].min_value + mods_stats[stat.name].min_value + skill_stats[stat.name].min_value, 0)
				value_max = base_stats[stat.name].max_value --math.max(base_stats[stat.name].max_value + mods_stats[stat.name].max_value + skill_stats[stat.name].max_value, 0)
			end

			value = base_stats[stat.name] --math.max(base_stats[stat.name] + mods_stats[stat.name] + skill_stats[stat.name], 0)

			if self._slot_data.name == equipped_item then
				local base, base_min, base_max, skill, skill_min, skill_max = nil

				if stat.range then
					base_min = base_stats[stat.name].min_value
					base_max = base_stats[stat.name].max_value
					skill_min = skill_stats[stat.name].min_value
					skill_max = skill_stats[stat.name].max_value
				end

				base = base_stats[stat.name]
				skill = skill_stats[stat.name]
				local format_string = "%0." .. tostring(stat.num_decimals or 0) .. "f"
				local equip_text = value and format_round(value, stat.round_value)
				local base_text = base and format_round(base, stat.round_value)
				local skill_text = skill_stats[stat.name] and format_round(skill_stats[stat.name], stat.round_value)
				local base_min_text = base_min and format_round(base_min, true)
				local base_max_text = base_max and format_round(base_max, true)
				local value_min_text = value_min and format_round(value_min, true)
				local value_max_text = value_max and format_round(value_max, true)
				local skill_min_text = skill_min and format_round(skill_min, true)
				local skill_max_text = skill_max and format_round(skill_max, true)

				if stat.range then
					if base_min ~= base_max then
						base_text = base_min_text .. " (" .. base_max_text .. ")"
					end

					if value_min ~= value_max then
						equip_text = value_min_text .. " (" .. value_max_text .. ")"
					end

					if skill_min ~= skill_max then
						skill_text = skill_min_text .. " (" .. skill_max_text .. ")"
					end
				end

				--[[if stat.suffix then
					base_text = base_text .. tostring(stat.suffix)
					equip_text = equip_text .. tostring(stat.suffix)
					skill_text = skill_text .. tostring(stat.suffix)
				end

				if stat.prefix then
					base_text = tostring(stat.prefix) .. base_text
					equip_text = tostring(stat.prefix) .. equip_text
					skill_text = tostring(stat.prefix) .. skill_text
				end]]

				self._mweapon_stats_texts[stat.name].equip:set_alpha(1)
				self._mweapon_stats_texts[stat.name].equip:set_text(equip_text)
				self._mweapon_stats_texts[stat.name].base:set_text(base_text)
				self._mweapon_stats_texts[stat.name].skill:set_text()--skill_stats[stat.name].skill_in_effect and (skill_stats[stat.name] > 0 and "+" or "") .. skill_text or "")
				self._mweapon_stats_texts[stat.name].total:set_text("")
				self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				--[[local positive = value ~= 0 and base < value
				local negative = value ~= 0 and value < base

				if stat.inverse then
					local temp = positive
					positive = negative
					negative = temp
				end

				if stat.range then
					if positive then
						self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_positive)
					elseif negative then
						self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_negative)
					end
				elseif positive then
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_positive)
				elseif negative then
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.stats_negative)
				else
					self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)
				end]]

				self._mweapon_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
			else
				local equip, equip_min, equip_max = nil

				if stat.range then
					equip_min = math.max(equip_base_stats[stat.name].min_value + equip_mods_stats[stat.name].min_value + equip_skill_stats[stat.name].min_value, 0)
					equip_max = math.max(equip_base_stats[stat.name].max_value + equip_mods_stats[stat.name].max_value + equip_skill_stats[stat.name].max_value, 0)
				end

				equip = equip_base_stats[stat.name] --math.max(equip_base_stats[stat.name] + equip_mods_stats[stat.name] + equip_skill_stats[stat.name], 0)
				local format_string = "%0." .. tostring(stat.num_decimals or 0) .. "f"
				local equip_text = equip and format_round(equip, stat.round_value)
				local total_text = value and format_round(value, stat.round_value)
				local equip_min_text = equip_min and format_round(equip_min, true)
				local equip_max_text = equip_max and format_round(equip_max, true)
				local total_min_text = value_min and format_round(value_min, true)
				local total_max_text = value_max and format_round(value_max, true)
				local color_ranges = {}

				if stat.range then
					if equip_min ~= equip_max then
						equip_text = equip_min_text .. " (" .. equip_max_text .. ")"
					end

					if value_min ~= value_max then
						total_text = total_min_text .. " (" .. total_max_text .. ")"
					end
				end

				--[[if stat.suffix then
					equip_text = equip_text .. tostring(stat.suffix)
					total_text = total_text .. tostring(stat.suffix)
				end

				if stat.prefix then
					equip_text = tostring(stat.prefix) .. equip_text
					total_text = tostring(stat.prefix) .. total_text
				end]]

				self._mweapon_stats_texts[stat.name].equip:set_alpha(0.75)
				self._mweapon_stats_texts[stat.name].equip:set_text(equip_text)
				self._mweapon_stats_texts[stat.name].base:set_text("")
				self._mweapon_stats_texts[stat.name].skill:set_text("")
				self._mweapon_stats_texts[stat.name].total:set_text(total_text)

				--[[if stat.range then
					local positive = equip_min < value_min
					local negative = value_min < equip_min

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range_min = {
						start = 0,
						stop = utf8.len(total_min_text)
					}

					if positive then
						color_range_min.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range_min.color = tweak_data.screen_colors.stats_negative
					else
						color_range_min.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range_min)

					positive = equip_max < value_max
					negative = value_max < equip_max

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range_max = {
						start = color_range_min.stop + 1
					}
					color_range_max.stop = color_range_max.start + 3 + utf8.len(total_max_text)

					if positive then
						color_range_max.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range_max.color = tweak_data.screen_colors.stats_negative
					else
						color_range_max.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range_max)
				else
					local positive = equip < value
					local negative = value < equip

					if stat.inverse then
						local temp = positive
						positive = negative
						negative = temp
					end

					local color_range = {
						start = 0,
						stop = utf8.len(total_text)
					}

					if positive then
						color_range.color = tweak_data.screen_colors.stats_positive
					elseif negative then
						color_range.color = tweak_data.screen_colors.stats_negative
					else
						color_range.color = tweak_data.screen_colors.text
					end

					table.insert(color_ranges, color_range)
				end]]

				self._mweapon_stats_texts[stat.name].total:set_color(tweak_data.screen_colors.text)
				self._mweapon_stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text)

				for _, color_range in ipairs(color_ranges) do
					self._mweapon_stats_texts[stat.name].total:set_range_color(color_range.start, color_range.stop, color_range.color)
				end
			end
		end
	else  --BLACKMARKET CRAFTING
		local equip, stat_changed = nil
		local tweak_parts = tweak_data.weapon.factory.parts[self._slot_data.name]
		local unaltered_blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)
		local blueprint = clone(unaltered_blueprint)
		local unaltered_total_base_stats, unaltered_total_mods_stats, unaltered_total_skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)

		managers.weapon_factory:change_part_blueprint_only(weapon.factory_id, self._slot_data.name, blueprint, false)

		local total_base_stats, total_mods_stats, total_skill_stats = WeaponDescription._get_stats(name, category, slot, blueprint)
		local base_stats, mods_stats, skill_stats = WeaponDescription._get_stats(name, category, slot, self._slot_data.default_blueprint)
		local mod_stats = WeaponDescription.get_stats_for_mod(self._slot_data.name, name, category, slot)
		local hide_equip = mod_stats.equip.name == mod_stats.chosen.name
		local remove_stats = {}

		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon.weapon_id)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		--[[
		local equipped_mods = nil
		local blueprint = managers.blackmarket:get_weapon_blueprint(category, slot)
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
		local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		if blueprint then
			equipped_mods = deep_clone(blueprint)
			local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_name)
			local default_blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	
			for _, default_part in ipairs(default_blueprint) do
				table.delete(equipped_mods, default_part)
			end
		end
		for i, k in pairs(equipped_mods) do
			for o, l in pairs(default_blueprint) do
				local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(l, factory_id, default_blueprint)
				if part_data.stats.CLIP_AMMO_MAX and l==k then
					base_stats["weight"].value = base_stats["weight"].value + part_data.stats.weight
					mods_stats["weight"].value = mods_stats["weight"].value - part_data.stats.weight
				end
			end
		end
		]]

		local wep_tweak = tweak_data.weapon[name]

		if self._slot_data.removes then
			for _, part_id in ipairs(self._slot_data.removes) do
				local part_stats = WeaponDescription.get_stats_for_mod(part_id, name, category, slot)

				for category, value in pairs(part_stats.chosen or {}) do
					if type(value) == "number" then
						remove_stats[category] = (remove_stats[category] or 0) + value
					end
				end
			end
		end

		self._rweapon_stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()
		self:set_weapon_mods_stats_columns()

		for _, title in pairs(self._stats_titles) do title:hide() end

		--[[if not mod_stats.equip.name then
			self._stats_titles.equip:hide()
		else
			self._stats_titles.equip:show()
			self._stats_titles.equip:set_text(utf8.to_upper(managers.localization:text("bm_menu_equipped")))
			self._stats_titles.equip:set_alpha(0.75)
			self._stats_titles.equip:set_x(105)
		end
		if not hide_equip then
			self._stats_titles.total:show()
		end]]
		--[[self:set_stats_titles(
			{ name = "total", text_id = "bm_menu_stats_total", alpha = 1, x = 120, show = true, color = tweak_data.screen_colors.text },
			{ name = "equip", text_id = "bm_menu_equipped", alpha = 0.75, x = 170, show = not not mod_stats.equip.name, color = tweak_data.screen_colors.text },
			{ name = "removed", alpha = 0.75, x = 200, show = true, color = tweak_data.screen_colors.text },
			{ name = "mod", text_id = "bm_menu_chosen", alpha = 1, x = 245, show = true, color = tweak_data.screen_colors.text },
		)]]
		self:set_stats_titles({
			alpha = 1,
			name = "total",
			text_id = "bm_menu_stats_total",
			x = 120,
			show = true,
			color = tweak_data.screen_colors.text
		}, {
			alpha = 0.75,
			name = "equip",
			text_id = "bm_menu_equipped",
			x = 170,
			show = not not mod_stats.equip.name,
			color = tweak_data.screen_colors.text
		}, {
			name = "removed",
			alpha = 0.75,
			x = 200,
			show = true,
			color = tweak_data.screen_colors.text
		}, {
			alpha = 1,
			name = "mod",
			text_id = "bm_menu_chosen",
			x = 245,
			show = true,
			color = tweak_data.screen_colors.text
		})

		local total_value, total_index, unaltered_total_value = nil

		for _, stat in ipairs(self._stats_shown) do
			local chosen = 0
			local equip = 0

			self._stats_texts[stat.name].name:set_text(utf8.to_upper(managers.localization:text("bm_menu_" .. stat.name)))

			if stat.name == "optimal_range" then
				local equipped_damage_falloff = self:get_damage_falloff_from_weapon(name, unaltered_blueprint)
				local selected_damage_falloff = self:get_damage_falloff_from_weapon(name, blueprint)
				local equipped_string = self:damage_falloff_to_string(equipped_damage_falloff)
				local selected_string = self:damage_falloff_to_string(selected_damage_falloff)
				local stat_object = self._stats_texts[stat.name]
				stat_changed = equipped_string ~= selected_string

				for name, column in pairs(stat_object) do
					column:set_alpha(stat_changed and 1 or 0.5)
				end

				stat_object.equip:set_text(selected_string)
				stat_object.equip:set_alpha(1)

				if stat_changed then
					stat_object.base:set_text(equipped_string)
					stat_object.base:set_alpha(0.75)
					stat_object.skill:set_text(selected_string)
					stat_object.skill:set_alpha(1)
					stat_object.skill:set_color(tweak_data.screen_colors.text)
				else
					stat_object.base:set_text("")
					stat_object.skill:set_text("")
				end

				stat_object.total:set_text("")
				stat_object.mods:set_text("")
				stat_object.removed:set_text("")
			elseif stat.name=="damage" or stat.name=="spread" or stat.name=="recoil" then
				total_mods_stats[stat.name].value = total_mods_stats[stat.name].value~=total_base_stats[stat.name].value and total_mods_stats[stat.name].value-total_base_stats[stat.name].value or 0
				unaltered_total_mods_stats[stat.name].value = unaltered_total_mods_stats[stat.name].value~=unaltered_total_base_stats[stat.name].value and unaltered_total_mods_stats[stat.name].value-unaltered_total_base_stats[stat.name].value or 0
				total_value = math.max(total_base_stats[stat.name].value + total_mods_stats[stat.name].value, 0)
				unaltered_total_value = math.max(unaltered_total_base_stats[stat.name].value + unaltered_total_mods_stats[stat.name].value, 0)

				local mods_ammotype_data = tweak_data.weapon:nqr_ammotype_data(
					total_mods_stats.caliber.value~=0 and total_mods_stats.caliber.value or total_base_stats.caliber.value,
					total_mods_stats.ammotype.value~=0 and total_mods_stats.ammotype.value or total_mods_stats.ammotype.value
				)

				mod_stats.chosen.damage = tweak_data.weapon:nqr_energy(
					mods_ammotype_data,
					total_mods_stats.barrel_length.value~=0 and total_mods_stats.barrel_length.value or total_base_stats.barrel_length.value,
					name
				) * 0.025
				mod_stats.chosen.spread = tweak_data.weapon:nqr_spread(
					mods_ammotype_data,
					total_mods_stats.barrel_length.value~=0 and total_mods_stats.barrel_length.value or total_base_stats.barrel_length.value,
					name
				)
				mod_stats.chosen.recoil = tweak_data.weapon:nqr_rise(
					mods_ammotype_data,
					total_mods_stats.barrel_length.value~=0 and total_mods_stats.barrel_length.value or total_base_stats.barrel_length.value,
					total_base_stats.weight.value+total_mods_stats.weight.value,
					name
				)
				mod_stats.chosen[stat.name] = total_value~=unaltered_total_value and total_value-unaltered_total_value or 0

				chosen = mod_stats.chosen[stat.name]
				equip = mod_stats.equip[stat.name]

				stat_changed = tweak_parts and tweak_parts.stats and tweak_parts.stats[stat.stat_name or stat.name] and chosen ~= 0
				stat_changed = stat_changed or remove_stats[stat.name] and remove_stats[stat.name] ~= 0

				for stat_name, stat_text in pairs(self._stats_texts[stat.name]) do if stat_name ~= "name" then stat_text:set_text("") end end

				for name, column in pairs(self._stats_texts[stat.name]) do column:set_alpha(stat_changed and 1 or 0.5) end

				equip_to_draw = (type(equip)=="number" or type(equip)=="number") and (equip==0 and "" or (equip>0 and (stat.override and "=" or "+") or "")..format_round(equip, stat.round_value)) or format_round(equip, stat.round_value)
				chosen_to_draw = (type(chosen)=="number" or type(chosen)=="number") and (chosen==0 and "" or (chosen>0 and ((stat.override or mag_override) and "=" or "+") or "")..format_round(chosen, stat.round_value)) or format_round(chosen, stat.round_value)

				self._stats_texts[stat.name].base:set_text(equip_to_draw) --equip == 0 and "" or (equip > 0 and "+" or "") .. format_round(equip, stat.round_value)
				self._stats_texts[stat.name].base:set_alpha(0.75)
				self._stats_texts[stat.name].equip:set_alpha(1)
				self._stats_texts[stat.name].equip:set_text(format_round(total_value, stat.round_value))
				self._stats_texts[stat.name].skill:set_alpha(1)
				self._stats_texts[stat.name].skill:set_text(chosen_to_draw) --chosen == 0 and "" or (chosen > 0 and "+" or "") .. format_round(chosen, stat.round_value))

				if remove_stats[stat.name] and remove_stats[stat.name] ~= 0 then
					local stat_str = remove_stats[stat.name] == 0 and "" or (remove_stats[stat.name] > 0 and "+" or "") .. format_round(remove_stats[stat.name], stat.round_value)

					self._stats_texts[stat.name].removed:set_text("(" .. tostring(stat_str) .. ")")
				else
					self._stats_texts[stat.name].removed:set_text("") end

				equip = type(equip)~="string" and equip + math.round(remove_stats[stat.name] or 0)

				if type(total_value)=="number" and type(unaltered_total_value)=="number" then
					if unaltered_total_value < total_value then
						self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
						self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
					elseif total_value < unaltered_total_value then
						self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
						self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
					else
						self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.text)
						self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text) end end
			else
				if type(mod_stats.chosen[stat.name])=="table" then
					mod_stats.chosen[stat.name] = mod_stats.chosen[stat.name][
						mods_stats["caliber"].value~=0 and mods_stats["caliber"].value or base_stats["caliber"].value
					] or 0
				end
				mod_chosen_to_draw = (
					(type(base_stats[stat.name].value)=="number" or type(mod_stats.chosen[stat.name])=="number") and (mod_stats.chosen[stat.name]==0 and ""
					or (mod_stats.chosen[stat.name]>0 and (stat.override and "=" or "+") or "")..format_round(mod_stats.chosen[stat.name], stat.round_value))
					or format_round(mod_stats.chosen[stat.name], stat.round_value)
				)
				if type(mod_stats.equip[stat.name])=="table" then
					mod_stats.equip[stat.name] = mod_stats.equip[stat.name][
						mods_stats["caliber"].value~=0 and mods_stats["caliber"].value or base_stats["caliber"].value
					] or 0
				end
				mod_equip_to_draw = (type(base_stats[stat.name].value)=="number" or type(mod_stats.equip[stat.name])=="number") and (mod_stats.equip[stat.name]==0 and "" or (mod_stats.equip[stat.name]>0 and (stat.override and "=" or "+") or "")..format_round(mod_stats.equip[stat.name], stat.round_value)) or format_round(mod_stats.equip[stat.name], stat.round_value)
				--total = stat.override and (
				--	mod_stats[stat.name]~=0 and mod_stats[stat.name] or base_stats[stat.name]) or (
				--	math.max(base_stats[stat.name] + mod_stats[stat.name], 0))
				chosen = mod_stats.chosen[stat.name]
				equip = mod_stats.equip[stat.name]

				if type(total_mods_stats[stat.name].value)=="table" then
					total_mods_stats[stat.name].value = total_mods_stats[stat.name].value[total_mods_stats["caliber"].value~=0 and total_mods_stats["caliber"].value or total_base_stats["caliber"].value ] or 0
					unaltered_total_mods_stats[stat.name].value = unaltered_total_mods_stats[stat.name].value[unaltered_total_mods_stats["caliber"].value~=0 and unaltered_total_mods_stats["caliber"].value or unaltered_total_base_stats["caliber"].value ] or 0 end
				total_value = stat.override and (
					total_mods_stats[stat.name].value~=0 and total_mods_stats[stat.name].value or total_base_stats[stat.name].value) or (
					math.max(total_base_stats[stat.name].value + total_mods_stats[stat.name].value, 0))
				unaltered_total_value = stat.override and (
					unaltered_total_mods_stats[stat.name].value~=0 and unaltered_total_mods_stats[stat.name].value or unaltered_total_base_stats[stat.name].value) or (
					math.max(unaltered_total_base_stats[stat.name].value + unaltered_total_mods_stats[stat.name].value, 0))

				stat_changed = tweak_parts and tweak_parts.stats and tweak_parts.stats[stat.stat_name or stat.name] and chosen ~= 0
				stat_changed = stat_changed or remove_stats[stat.name] and remove_stats[stat.name] ~= 0

				for stat_name, stat_text in pairs(self._stats_texts[stat.name]) do if stat_name ~= "name" then stat_text:set_text("") end end

				for name, column in pairs(self._stats_texts[stat.name]) do column:set_alpha(stat_changed and 1 or 0.5) end

				local mag_override = tweak_parts and (tweak_parts.type=="magazine" or tweak_parts.type=="barrel" or tweak_parts.type=="exclusive_set" and (tweak_parts.stats and not tweak_parts.stats.mag_ext)) and stat.name=="magazine"
				equip_to_draw = (type(equip)=="number" or type(equip)=="number") and (equip==0 and "" or (equip>0 and ((stat.override or mag_override) and "=" or "+") or "")..format_round(equip, stat.round_value)) or format_round(equip, stat.round_value)
				chosen_to_draw = (type(chosen)=="number" or type(chosen)=="number") and (chosen==0 and "" or (chosen>0 and ((stat.override or mag_override) and "=" or "+") or "")..format_round(chosen, stat.round_value)) or format_round(chosen, stat.round_value)

				--log(base_stats.totalammo.value)
				--log(mods_stats.totalammo.value)

				local mags_slot = stat.name=="totalammo" and not (
					tweak_data.weapon[name].use_shotgun_reload or tweak_data.weapon[name].feed_system=="break_action"
				) and " mag" or ""

				self._stats_texts[stat.name].base:set_text(equip_to_draw) --equip == 0 and "" or (equip > 0 and "+" or "") .. format_round(equip, stat.round_value)
				self._stats_texts[stat.name].base:set_alpha(0.75)
				self._stats_texts[stat.name].equip:set_alpha(1)
				self._stats_texts[stat.name].equip:set_text(format_round(total_value, stat.round_value)..mags_slot..(mags_slot~="" and total_value~=1 and "s" or ""))
				self._stats_texts[stat.name].skill:set_alpha(1)
				self._stats_texts[stat.name].skill:set_text(chosen_to_draw) --chosen == 0 and "" or (chosen > 0 and "+" or "") .. format_round(chosen, stat.round_value))

				if remove_stats[stat.name] and remove_stats[stat.name] ~= 0 then
					local stat_str = remove_stats[stat.name] == 0 and "" or (remove_stats[stat.name] > 0 and "+" or "") .. format_round(remove_stats[stat.name], stat.round_value)

					self._stats_texts[stat.name].removed:set_text("(" .. tostring(stat_str) .. ")")
				else
					self._stats_texts[stat.name].removed:set_text("") end

				equip = type(equip)~="string" and equip + math.round(remove_stats[stat.name] or 0)

				if type(total_value)=="number" and type(unaltered_total_value)=="number" then
					if unaltered_total_value < total_value then
						self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
						self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_negative or tweak_data.screen_colors.stats_positive)
					elseif total_value < unaltered_total_value then
						self._stats_texts[stat.name].skill:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
						self._stats_texts[stat.name].equip:set_color(stat.inverted and tweak_data.screen_colors.stats_positive or tweak_data.screen_colors.stats_negative)
					else
						self._stats_texts[stat.name].skill:set_color(tweak_data.screen_colors.text)
						self._stats_texts[stat.name].equip:set_color(tweak_data.screen_colors.text) end end
			end
			self._stats_texts[stat.name].base:set_color(tweak_data.screen_colors.text)
		end
	end
	----------------------------------------------------------------------------------------------

	local modslist_panel = self._stats_panel:child("modslist_panel")
	local y = 0

	if self._rweapon_stats_panel:visible() then
		for i, child in ipairs(self._rweapon_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	elseif self._armor_stats_panel:visible() then
		for i, child in ipairs(self._armor_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	elseif self._mweapon_stats_panel:visible() then
		for i, child in ipairs(self._mweapon_stats_panel:children()) do
			y = math.max(y, child:bottom())
		end
	end

	modslist_panel:set_top(y + 10)

	if not hide_stats then
		self._stats_panel:show()
	end
end

--SWAP THE STRING FOR BUYING A WEP PART, 
function BlackMarketGui:_setup(is_start_page, component_data)
	self._in_setup = true

	if alive(self._panel) then
		self._ws:panel():remove(self._panel)
	end

	MenuCallbackHandler:chk_dlc_content_updated()

	self._item_bought = nil
	self._panel = self._ws:panel():panel({})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 40
	})

	self:set_layer(45)

	self._disabled_panel = self._fullscreen_panel:panel({
		layer = 100
	})

	WalletGuiObject.set_wallet(self._panel)

	self._data = component_data or self:_start_page_data()
	self._node:parameters().menu_component_data = self._data
	self._requested_textures = {}

	if self._data.init_callback_name then
		local clbk_func = callback(self, self, self._data.init_callback_name, self._data.init_callback_params)

		if clbk_func then
			clbk_func()
		end

		if self._data.init_callback_params and self._data.init_callback_params.run_once then
			self._data.init_callback_name = nil
			self._data.init_callback_params = nil
		end
	end

	if not self._data.skip_blur then
		self._data.blur_fade = self._data.blur_fade or 0
		local blur = self._fullscreen_panel:bitmap({
			texture = "guis/textures/test_blur_df",
			render_template = "VertexColorTexturedBlur3D",
			layer = -1,
			w = self._fullscreen_ws:panel():w(),
			h = self._fullscreen_ws:panel():h()
		})

		local function func(o, component_data)
			local start_blur = component_data.blur_fade

			over(0.6 - 0.6 * component_data.blur_fade, function (p)
				component_data.blur_fade = math.lerp(start_blur, 1, p)

				o:set_alpha(component_data.blur_fade)
			end)
		end

		blur:animate(func, self._data)
	end

	self._panel:text({
		vertical = "bottom",
		name = "back_button",
		align = "right",
		text = utf8.to_upper(managers.localization:text("menu_back")),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	self:make_fine_text(self._panel:child("back_button"))
	self._panel:child("back_button"):set_right(self._panel:w())
	self._panel:child("back_button"):set_bottom(self._panel:h())
	self._panel:child("back_button"):set_visible(managers.menu:is_pc_controller())

	self._pages = #self._data > 1 or self._data.show_tabs
	local grid_size = self._panel:h() - 70
	local grid_h_mul = self._data.panel_grid_h_mul or GRID_H_MUL
	local grid_panel_w = self._panel:w() * WIDTH_MULTIPLIER * (self._data.panel_grid_w_mul or 1)
	local grid_panel_h = grid_size * grid_h_mul
	local items_per_row = self._data[1] and self._data[1].override_slots and self._data[1].override_slots[1] or ITEMS_PER_ROW
	local items_per_column = self._data[1] and self._data[1].override_slots and self._data[1].override_slots[2] or ITEMS_PER_COLUMN
	grid_panel_w = math.ceil(grid_panel_w / items_per_row) * items_per_row
	grid_panel_h = math.ceil(grid_panel_h / items_per_column) * items_per_column
	local square_w = grid_panel_w / items_per_row
	local square_h = grid_panel_h / items_per_column
	local padding_w = 0
	local padding_h = 0
	local left_padding = 0
	local top_padding = 55 + (GRID_H_MUL - grid_h_mul) * grid_size
	local size_data = {
		grid_w = math.floor(grid_panel_w),
		grid_h = math.floor(grid_panel_h),
		items_per_row = items_per_row,
		items_per_column = items_per_column,
		square_w = math.floor(square_w),
		square_h = math.floor(square_h),
		padding_w = math.floor(padding_w),
		padding_h = math.floor(padding_h),
		left_padding = math.floor(left_padding),
		top_padding = math.floor(top_padding)
	}

	if grid_h_mul ~= GRID_H_MUL then
		self._no_input_panel = self._panel:panel({
			y = 60,
			w = grid_panel_w,
			h = top_padding - 60
		})
	end

	if self._data.use_bgs then
		local blur_panel = self._panel:panel({
			layer = -1,
			x = size_data.left_padding,
			y = size_data.top_padding + 33,
			w = size_data.grid_w,
			h = size_data.grid_h - 1
		})

		BlackMarketGui.blur_panel(blur_panel)
	end

	self._inception_node_name = self._node:parameters().menu_component_next_node_name or "blackmarket_node"
	self._preview_node_name = self._node:parameters().menu_component_preview_node_name or "blackmarket_preview_node"
	self._crafting_node_name = self._node:parameters().menu_component_crafting_node_name or "blackmarket_crafting_node"
	self._tabs = {}
	self._btns = {}
	self._title_text = self._panel:text({
		name = "title_text",
		text = managers.localization:to_upper_text(self._data.topic_id, self._data.topic_params),
		font_size = large_font_size,
		font = large_font,
		color = tweak_data.screen_colors.text
	})

	self:make_fine_text(self._title_text)

	if self._data.topic_colors then
		managers.menu_component:add_colors_to_text_object(self._title_text, self._data.topic_colors)
	elseif self._data.topic_color then
		managers.menu_component:make_color_text(self._title_text, self._data.topic_color)
	end

	self._tab_scroll_panel = self._panel:panel({
		w = grid_panel_w,
		y = top_padding + 1
	})
	self._tab_area_panel = self._panel:panel({
		w = grid_panel_w,
		y = top_padding + 1
	})
	self._tab_scroll_table = {
		panel = self._tab_scroll_panel
	}

	for i, data in ipairs(self._data) do
		if data.on_create_func_name then
			data.on_create_func = callback(self, self, data.on_create_func_name)
		end

		local new_tab_class = BlackMarketGuiTabItem

		if data.unique_tab_class then
			new_tab_class = _G[data.unique_tab_class]
		end

		local new_tab = new_tab_class:new(self._panel, data, self._node, size_data, not self._pages, self._tab_scroll_table, self)

		table.insert(self._tabs, new_tab)
	end

	if self._data.open_callback_name then
		local clbk_func = callback(self, self, self._data.open_callback_name, self._data.open_callback_params)

		if clbk_func then
			clbk_func()
		end
	end

	if #self._tabs > 0 then
		self._tab_area_panel:set_h(self._tabs[#self._tabs]._tab_panel:h())
	end

	self._selected = self._data.selected_tab or self._node:parameters().menu_component_selected or 1
	self._node:parameters().menu_component_selected = self._selected
	self._data.selected_tab = nil
	self._select_rect = self._panel:panel({
		name = "select_rect",
		layer = 8,
		w = square_w,
		h = square_h
	})

	if self._tabs[self._selected] then
		self._tabs[self._selected]:select(true)

		local slot_dim_x = self._tabs[self._selected].my_slots_dimensions[1]
		local slot_dim_y = self._tabs[self._selected].my_slots_dimensions[2]
		local _, any_slot = next(self._tabs[self._selected]._slots)

		if any_slot then
			self._select_rect:set_size(any_slot._panel:size())
		end

		self._select_rect_box = BoxGuiObject:new(self._select_rect, {
			sides = {
				2,
				2,
				2,
				2
			}
		})

		self._select_rect_box:set_clipping(false)

		self._box_panel = self._panel:panel()

		self._box_panel:set_shape(self._tabs[self._selected]._grid_panel:shape())

		self._box = BoxGuiObject:new(self._box_panel, {
			sides = {
				1,
				1,
				1 + (#self._tabs > 1 and 1 or 0),
				1
			}
		})
		local info_box_top = 88
		local info_box_size = self._panel:h() - 70
		local info_box_w = math.floor(self._panel:w() * (1 - WIDTH_MULTIPLIER) - BOX_GAP)
		local info_box_h = grid_panel_h

		if self._data.panel_grid_h_mul then
			info_box_h = math.floor(info_box_size * GRID_H_MUL)
		end

		self._extra_options_data = self._data.extra_options_data

		if self._data.extra_options_panel then
			self._extra_options_panel = self._panel:panel({
				name = "extra_options_panel"
			})

			self._extra_options_panel:set_size(info_box_w, self._data.extra_options_panel.height or self._data.extra_options_panel.h or 50)
			self._extra_options_panel:set_right(self._panel:w())
			self._extra_options_panel:set_top(info_box_top)

			local panel = self._extra_options_panel:panel()

			if self._data.extra_options_panel.on_create_func_name then
				if self._extra_options_data then
					self._extra_options_data.selected = math.min(self._extra_options_data.selected or 1, managers.blackmarket:num_preferred_characters() + 1, CriminalsManager.get_num_characters())
				end

				local selected = math.min(self._extra_options_data and self._extra_options_data.selected or 1, managers.blackmarket:num_preferred_characters() + 1, CriminalsManager.get_num_characters())
				self._extra_options_data = callback(self, self, self._data.extra_options_panel.on_create_func_name)(panel)
				self._extra_options_data.selected = selected
				local num_panels = 0

				for i = 1, #self._extra_options_data do
					if self._extra_options_data[i].panel then
						num_panels = num_panels + 1
					end
				end

				self._extra_options_data.num_panels = num_panels
			end

			self._extra_options_box = BoxGuiObject:new(self._extra_options_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
			local h = self._extra_options_panel:h() + 5
			info_box_top = info_box_top + h
			info_box_h = info_box_h - h
			self._data.extra_options_data = self._extra_options_data

			if is_win32 then
				self._ws:connect_keyboard(Input:keyboard())
				self._panel:key_press(callback(self, self, "extra_option_key_press"))

				self._keyboard_connected = true
			end
		end

		if self._data.add_market_panel then
			self._market_panel = self._panel:panel({
				visible = true,
				name = "market_panel",
				h = 140,
				layer = 1,
				y = info_box_top,
				w = info_box_w
			})

			self._market_panel:set_right(self._panel:w())
			self._market_panel:rect({
				alpha = 0.25,
				layer = -1,
				color = Color.black
			})

			self._market_border = BoxGuiObject:new(self._market_panel, {
				sides = {
					1,
					1,
					1,
					1
				}
			})
			local h = self._market_panel:h() + 5
			local market_bundles = {}

			for entry, safe in pairs(tweak_data.economy.safes) do
				if not safe.promo then
					table.insert(market_bundles, {
						content = safe.content or "NONE",
						safe = entry,
						drill = safe.drill,
						prio = safe.prio or 0
					})
				end
			end

			local loc_sort = {}

			table.sort(market_bundles, function (x, y)
				if x.prio ~= y.prio then
					return (x.prio or 0) < (y.prio or 0)
				end

				if not loc_sort[x.safe] then
					loc_sort[x.safe] = managers.localization:text(tweak_data.economy.safes[x.safe].name_id)
				end

				if not loc_sort[y.safe] then
					loc_sort[y.safe] = managers.localization:text(tweak_data.economy.safes[y.safe].name_id)
				end

				return loc_sort[x.safe] < loc_sort[y.safe]
			end)

			local num_market_bundles = #market_bundles

			if managers.menu:is_pc_controller() and num_market_bundles > 0 then
				info_box_top = info_box_top + h
				info_box_h = info_box_h - h
				local title_text = self._panel:text({
					text = managers.localization:to_upper_text("menu_steam_market_inspect_title"),
					font = small_font,
					font_size = small_font_size,
					color = tweak_data.screen_colors.text
				})

				self:make_fine_text(title_text)
				title_text:set_left(self._market_panel:left())
				title_text:set_bottom(self._market_panel:top())

				local padding = 10
				local w = self._market_panel:w() - 2 * padding
				local h = self._market_panel:h() - 2 * padding
				local size = math.min(w / 2, h - 2 * small_font_size - padding * 0.5)
				local panel, safe_panel, drill_panel, safe_text, drill_text, safe_market_panel, drill_market_panel, title_text = nil
				self._market_bundles = {}
				self._data.active_market_bundle = self._data.active_market_bundle or 1
				local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
				local select_bg = self._market_panel:rect({
					blend_mode = "add",
					layer = -2,
					color = tweak_data.screen_colors.button_stage_3:with_alpha(0.2)
				})
				local arrow_left = self._market_panel:bitmap({
					blend_mode = "add",
					texture = "guis/textures/menu_arrows",
					texture_rect = {
						24,
						0,
						24,
						24
					},
					color = tweak_data.screen_colors.button_stage_3,
					y = padding
				})
				local arrow_right = self._market_panel:bitmap({
					texture = "guis/textures/menu_arrows",
					blend_mode = "add",
					rotation = 180,
					texture_rect = {
						24,
						0,
						24,
						24
					},
					color = tweak_data.screen_colors.button_stage_3,
					y = padding
				})

				arrow_left:set_world_y(math.round(arrow_left:world_y()))
				arrow_right:set_world_y(math.round(arrow_right:world_y()) + 1)
				arrow_right:set_right(self._market_panel:w() - padding)
				arrow_left:set_left(padding)
				select_bg:set_shape(arrow_left:left(), arrow_left:top(), arrow_right:right() - arrow_left:left(), arrow_left:h())

				self._market_bundles.arrow_left = arrow_left
				self._market_bundles.arrow_right = arrow_right
				self._market_bundles.num_bundles = num_market_bundles
				self._market_bundles.market_bundles = market_bundles

				for i, bundle in ipairs(market_bundles) do
					panel = self._market_panel:panel({
						name = tostring(i),
						x = padding,
						y = padding,
						w = w,
						h = h,
						visible = i == self._data.active_market_bundle
					})
					title_text = panel:text({
						vertical = "center",
						h = 24,
						align = "center",
						halign = "center",
						valign = "center",
						text = managers.localization:to_upper_text("menu_steam_market_content_" .. bundle.content),
						font = small_font,
						font_size = small_font_size,
						color = tweak_data.screen_colors.button_stage_2
					})

					self:make_fine_text(title_text)
					title_text:set_center(panel:w() / 2, 12)

					local guis_catalog = "guis/"
					local bundle_folder = tweak_data.economy.safes[bundle.safe].texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					local path = "safes/"
					local texture_path = guis_catalog .. path .. bundle.safe
					safe_panel = panel:panel({
						alpha = 0.9,
						name = "safe",
						y = small_font_size + padding * 0.5,
						w = size,
						h = size
					})

					safe_panel:set_center_x(w * 0.5)
					self:request_texture(texture_path, safe_panel, true, "normal")

					safe_text = panel:text({
						blend_mode = "add",
						text = managers.localization:to_upper_text("menu_steam_market_show_content"),
						font = small_font,
						font_size = small_font_size,
						x = safe_panel:x(),
						y = safe_panel:bottom() + 1,
						color = tweak_data.screen_colors.button_stage_3
					})

					self:make_fine_text(safe_text)
					safe_text:set_center_x(safe_panel:center_x())

					safe_market_panel = panel:panel({
						x = safe_panel:x(),
						y = safe_panel:y(),
						w = safe_panel:w(),
						h = safe_panel:h() + small_font_size
					})
					local guis_catalog = "guis/"
					local bundle_folder = tweak_data.economy.drills[bundle.drill].texture_bundle_folder

					if bundle_folder then
						guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
					end

					if not tweak_data.economy.safes[bundle.safe].free then
						local path = "drills/"
						local texture_path = guis_catalog .. path .. bundle.drill
						drill_panel = panel:panel({
							alpha = 0.9,
							name = "drill",
							y = small_font_size + padding * 0.5,
							w = size,
							h = size
						})

						drill_panel:set_center_x(w * 0.75)
						self:request_texture(texture_path, drill_panel, true, "normal")

						drill_text = panel:text({
							text = managers.localization:to_upper_text("menu_steam_market_buy_drill"),
							font = small_font,
							font_size = small_font_size,
							x = drill_panel:x(),
							y = drill_panel:bottom() + 1,
							color = tweak_data.screen_colors.button_stage_3
						})

						self:make_fine_text(drill_text)
						drill_text:set_center_x(drill_panel:center_x())
						drill_text:set_x(math.round(drill_text:x()))

						drill_market_panel = panel:panel({
							x = drill_panel:x(),
							y = drill_panel:y(),
							w = drill_panel:w(),
							h = drill_panel:h() + small_font_size
						})
					else
						drill_text = nil
						drill_panel = nil
						drill_market_panel = nil
					end

					self._market_bundles[i] = {
						panel = panel,
						safe = {
							entry = bundle.safe,
							image = safe_panel,
							text = safe_text,
							select = safe_market_panel
						},
						drill = {
							entry = bundle.drill,
							image = drill_panel,
							text = drill_text,
							select = drill_market_panel
						}
					}
				end
			else
				self._market_panel:hide()
				self._market_panel:set_h(0)
			end
		end

		local info_box_panel = self._panel:panel({
			name = "info_box_panel"
		})

		info_box_panel:set_size(info_box_w, info_box_h)
		info_box_panel:set_right(self._panel:w())
		info_box_panel:set_top(info_box_top)

		self._selected_slot = self._tabs[self._selected]:select_slot(nil, true)
		self._slot_data = self._selected_slot._data
		local x, y = self._tabs[self._selected]:selected_slot_center()

		self._select_rect:set_world_center(x, y)

		local BTNS = {
			w_move = {
				btn = "BTN_A",
				name = "bm_menu_btn_move_weapon",
				prio = managers.menu:is_pc_controller() and 5 or 1,
				callback = callback(self, self, "pickup_crafted_item_callback")
			},
			w_place = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_place_weapon",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			w_swap = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_weapon",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			m_move = {
				btn = "BTN_A",
				prio = 5,
				name = "bm_menu_btn_move_mask",
				callback = callback(self, self, "pickup_crafted_item_callback")
			},
			m_place = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_place_mask",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			m_swap = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_mask",
				callback = callback(self, self, "place_crafted_item_callback")
			},
			i_stop_move = {
				btn = "BTN_X",
				name = "bm_menu_btn_stop_move",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "drop_hold_crafted_item_callback")
			},
			i_rename = {
				btn = "BTN_BACK",
				name = "bm_menu_btn_rename_item",
				prio = 2,
				pc_btn = "toggle_chat",
				callback = callback(self, self, "rename_item_with_gamepad_callback")
			},
			w_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_mod",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "choose_weapon_mods_callback")
			},
			w_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon",
				callback = callback(self, self, "equip_weapon_callback")
			},
			w_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_callback")
			},
			w_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_item_callback")
			},
			w_skin = {
				btn = "BTN_STICK_L",
				name = "bm_menu_btn_skin",
				prio = 5,
				pc_btn = "menu_edit_skin",
				callback = callback(self, self, "edit_weapon_skin_callback")
			},
			w_unequip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unequip_weapon",
				callback = function ()
				end
			},
			ew_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_weapon_slot",
				callback = callback(self, self, "choose_weapon_slot_unlock_callback")
			},
			ew_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_weapon",
				callback = callback(self, self, "choose_weapon_buy_callback")
			},
			bw_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_selected_weapon",
				callback = callback(self, self, "buy_weapon_callback")
			},
			bw_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_buy_weapon_callback")
			},
			bw_available_mods = {
				btn = "BTN_Y",
				name = "bm_menu_available_mods",
				prio = 2,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "show_available_mods_callback")
			},
			bw_buy_dlc = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_buy_dlc",
				color = tweak_data.screen_colors.dlc_buy_color,
				callback = callback(self, self, "show_buy_dlc_callback")
			},
			bw_preview_mods = {
				btn = "BTN_Y",
				name = "bm_menu_preview_mods",
				prio = 2,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_mods_callback")
			},
			mt_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose",
				callback = callback(self, self, "choose_mod_callback")
			},
			wm_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_craft_mod",
				callback = callback(self, self, "buy_mod_callback")
			},
			wm_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_preview",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_mod_callback")
			},
			wm_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_with_mod",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_with_mod_callback")
			},
			wm_remove_buy = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_mod",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_mod_callback")
			},
			wm_remove_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_with_mod",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_mod_callback")
			},
			wm_remove_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_preview_no_mod",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "preview_weapon_without_mod_callback")
			},
			wm_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_weapon_mods_callback")
			},
			wm_reticle_switch_menu = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_switch_reticle",
				callback = callback(self, self, "open_reticle_switch_menu")
			},
			wm_buy_mod = {
				btn = "BTN_START",
				name = "menu_buy",
				prio = 4,
				pc_btn = "menu_respec_tree_all",
				callback = callback(self, self, "purchase_weapon_mod_callback")
			},
			wm_clear_mod_preview = {
				btn = "BTN_Y",
				name = "bm_menu_btn_clear_mod_preview",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "clear_weapon_mod_preview_callback")
			},
			wm_customize_gadget = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_customize_gadget",
				callback = callback(self, self, "open_customize_gadget_menu")
			},
			wcs_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "equip_weapon_color_callback")
			},
			wcs_customize_color = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_customize_weapon_color",
				callback = callback(self, self, "open_customize_weapon_color_menu")
			},
			wcc_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "equip_weapon_cosmetics_callback")
			},
			wcc_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_weapon_cosmetic",
				callback = callback(self, self, "choose_weapon_cosmetics_callback")
			},
			wcc_remove = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_weapon_cosmetic",
				prio = 1,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_weapon_cosmetics_callback")
			},
			wcc_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_weapon_cosmetic",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_cosmetic_on_weapon_callback")
			},
			wcc_buy_equip_weapon = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_weapon",
				callback = callback(self, self, "buy_equip_weapon_cosmetics_callback")
			},
			wcc_cancel_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_stop_preview_weapon_cosmetic",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "cancel_preview_cosmetic_on_weapon_callback")
			},
			wcc_market = {
				btn = "BTN_X",
				name = "bm_menu_btn_buy_tradable",
				prio = 5,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "purchase_market_cosmetic_on_weapon_callback")
			},
			it_wcc_choose_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon_cosmetic",
				callback = callback(self, self, "choose_equip_weapon_cosmetics_callback")
			},
			it_wcc_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_weapon_cosmetic",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_weapon_cosmetics_callback")
			},
			it_copen = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_open_container",
				callback = callback(self, self, "start_open_tradable_container_callback")
			},
			it_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_tradable",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_tradable_item")
			},
			it_wcc_armor_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_armor_skin",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_armor_skin_callback")
			},
			a_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_armor",
				callback = callback(self, self, "equip_armor_callback")
			},
			a_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_armor",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "open_armor_skins_menu_callback")
			},
			as_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_armor_skin",
				callback = callback(self, self, "equip_armor_skin_callback")
			},
			as_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_armor_skin",
				prio = 1,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_armor_skin_callback")
			},
			as_workshop = {
				btn = "BTN_STICK_L",
				name = "bm_menu_btn_skin",
				prio = 5,
				pc_btn = "menu_edit_skin",
				callback = callback(self, self, "edit_armor_skin_callback")
			},
			trd_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_player_style",
				callback = callback(self, self, "equip_player_style_callback")
			},
			trd_customize = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_player_style",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "customize_player_style_callback")
			},
			trd_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_player_style",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_player_style_callback")
			},
			trd_mod_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_suit_variation",
				callback = callback(self, self, "equip_suit_variation_callback")
			},
			trd_mod_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_suit_variation",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_suit_variation_callback")
			},
			hnd_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_gloves",
				callback = callback(self, self, "equip_gloves_callback")
			},
			hnd_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_gloves",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_gloves_callback")
			},
			m_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_mask",
				callback = callback(self, self, "equip_mask_callback")
			},
			m_mod = {
				btn = "BTN_Y",
				name = "bm_menu_btn_mod_mask",
				prio = 2,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "mask_mods_callback")
			},
			m_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 3,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_mask_callback")
			},
			m_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_mask_callback")
			},
			m_remove = {
				btn = "BTN_X",
				name = "bm_menu_btn_remove_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "remove_mask_callback")
			},
			em_gv = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_mask",
				callback = callback(self, self, "choose_mask_global_value_callback")
			},
			em_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_new_mask",
				callback = callback(self, self, "choose_mask_buy_callback")
			},
			em_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_mask_slot",
				callback = callback(self, self, "choose_mask_slot_unlock_callback")
			},
			em_available_mods = {
				btn = "BTN_Y",
				name = "bm_menu_buy_mask_title",
				prio = 3,
				pc_btn = "menu_preview_item_alt",
				callback = callback(self, self, "show_available_mask_mods_callback")
			},
			mm_choose_textures = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_choose_pattern",
				callback = callback(self, self, "choose_mask_mod_callback", "textures")
			},
			mm_choose_materials = {
				btn = "BTN_A",
				prio = 2,
				name = "bm_menu_choose_material",
				callback = callback(self, self, "choose_mask_mod_callback", "materials")
			},
			mm_choose_colors = {
				btn = "BTN_A",
				prio = 3,
				name = "bm_menu_choose_color",
				callback = callback(self, self, "choose_mask_mod_callback", "colors")
			},
			mm_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_mask_mod",
				callback = callback(self, self, "choose_mask_type_callback")
			},
			mm_buy = {
				btn = "BTN_Y",
				name = "bm_menu_btn_customize_mask",
				prio = 5,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "buy_customized_mask_callback")
			},
			mm_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 4,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_callback")
			},
			mp_choose = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_mask_mod",
				callback = callback(self, self, "choose_mask_part_callback")
			},
			mp_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_callback")
			},
			mp_preview_mod = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_customized_mask_with_mod_callback")
			},
			mp_choose_first = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_color_a",
				callback = callback(self, self, "choose_mask_color_a_callback")
			},
			mp_choose_second = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_choose_color_b",
				callback = callback(self, self, "choose_mask_color_b_callback")
			},
			bm_buy = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_buy_selected_mask",
				callback = callback(self, self, "buy_mask_callback")
			},
			bm_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_mask",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_buy_mask_callback")
			},
			bm_sell = {
				btn = "BTN_X",
				name = "bm_menu_btn_sell_mask",
				prio = 4,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "sell_stashed_mask_callback")
			},
			c_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_set_preferred",
				callback = callback(self, self, "set_preferred_character_callback")
			},
			c_swap_slots = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_swap_preferred_slots",
				callback = callback(self, self, "swap_preferred_character_to_slot_callback")
			},
			c_equip_to_slot = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_set_preferred_to_slot",
				callback = callback(self, self, "set_preferred_character_to_slot_callback")
			},
			c_clear_slots = {
				btn = "BTN_X",
				name = "bm_menu_btn_clear_preferred",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "clear_preferred_characters_callback")
			},
			lo_w_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_weapon",
				callback = callback(self, self, "equip_weapon_callback")
			},
			lo_d_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_deployable",
				callback = callback(self, self, "lo_equip_deployable_callback")
			},
			lo_d_equip_primary = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_primary_deployable",
				callback = callback(self, self, "lo_equip_deployable_callback")
			},
			lo_d_equip_secondary = {
				btn = "BTN_X",
				name = "bm_menu_btn_equip_secondary_deployable",
				prio = 2,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "lo_equip_deployable_callback_secondary")
			},
			lo_d_unequip = {
				btn = "BTN_X",
				name = "bm_menu_btn_unequip_deployable",
				prio = 1,
				pc_btn = "menu_remove_item",
				callback = callback(self, self, "lo_unequip_deployable_callback")
			},
			lo_d_sentry_ap_rounds = {
				btn = "BTN_Y",
				name = "bm_menu_btn_sentry_ap_rounds",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "set_sentry_ap_rounds_callback")
			},
			lo_d_sentry_default_rounds = {
				btn = "BTN_Y",
				name = "bm_menu_btn_sentry_default_rounds",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "set_sentry_default_rounds_callback")
			},
			lo_mw_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_melee_weapon",
				callback = callback(self, self, "lo_equip_melee_weapon_callback")
			},
			lo_mw_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_melee_weapon",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_melee_weapon_callback")
			},
			lo_mw_add_favorite = {
				btn = "BTN_Y",
				name = "bm_menu_btn_add_favorite",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "add_melee_weapon_favorite")
			},
			lo_mw_remove_favorite = {
				btn = "BTN_Y",
				name = "bm_menu_btn_remove_favorite",
				prio = 3,
				pc_btn = "menu_modify_item",
				callback = callback(self, self, "remove_melee_weapon_favorite")
			},
			lo_g_equip = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_equip_grenade",
				callback = callback(self, self, "lo_equip_grenade_callback")
			},
			lo_g_preview = {
				btn = "BTN_STICK_R",
				name = "bm_menu_btn_preview_grenade",
				prio = 2,
				pc_btn = "menu_preview_item",
				callback = callback(self, self, "preview_grenade_callback")
			},
			custom_select = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_select",
				callback = function ()
				end
			},
			custom_unselect = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unselect",
				callback = function ()
				end
			},
			ci_unlock = {
				btn = "BTN_A",
				prio = 1,
				name = "bm_menu_btn_unlock_crew_item",
				callback = callback(self, self, "buy_crew_item_callback")
			}
		}

		for btn, data in pairs(BTNS) do
			data.callback = callback(self, self, "overridable_callback", {
				button = btn,
				callback = data.callback
			})
		end

		local get_real_font_sizes = false
		local real_small_font_size = small_font_size

		if get_real_font_sizes then
			local test_text = self._panel:text({
				visible = false,
				font = small_font,
				font_size = small_font_size,
				text = "TeWqjI-" .. managers.localization:get_default_macro("BTN_BOTTOM_L")
			})
			local x, y, w, h = test_text:text_rect()
			real_small_font_size = h

			self._panel:remove(test_text)

			test_text = nil
		end

		self._real_small_font_size = real_small_font_size
		local real_medium_font_size = medium_font_size

		if get_real_font_sizes then
			local test_text = self._panel:text({
				visible = false,
				font = medium_font,
				font_size = medium_font_size,
				text = "TeWqjI-" .. managers.localization:get_default_macro("BTN_BOTTOM_L")
			})
			local x, y, w, h = test_text:text_rect()
			real_medium_font_size = h
		end

		self._real_medium_font_size = real_medium_font_size
		self._info_box_panel_y = info_box_panel:y()
		self._weapon_info_panel = self._panel:panel({
			x = info_box_panel:x(),
			y = info_box_panel:y(),
			w = info_box_panel:w()
		})
		self._detection_panel = self._panel:panel({
			name = "suspicion_panel",
			h = 48,
			layer = 1,
			x = info_box_panel:x(),
			y = info_box_panel:y() + 250,
			w = info_box_panel:w()
		})
		self._btn_panel = self._panel:panel({
			name = "btn_panel",
			h = 136,
			x = info_box_panel:x(),
			w = info_box_panel:w()
		})

		self._weapon_info_panel:set_h(info_box_panel:h() - self._btn_panel:h() - 8 - self._detection_panel:h() - 8)
		self._detection_panel:set_top(self._weapon_info_panel:bottom() + 8)
		self._btn_panel:set_top(self._detection_panel:bottom() + 8)

		self._weapon_info_border = BoxGuiObject:new(self._weapon_info_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._detection_border = BoxGuiObject:new(self._detection_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
		self._button_border = BoxGuiObject:new(self._btn_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		if self._data.use_bgs then
			BlackMarketGui.blur_panel(self._weapon_info_panel)
			BlackMarketGui.blur_panel(self._detection_panel)
			BlackMarketGui.blur_panel(self._btn_panel)

			if alive(self._extra_options_panel) then
				BlackMarketGui.blur_panel(self._extra_options_panel)
			end
		end

		local scale = 0.75
		local detection_ring_left_bg = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_left_bg",
			h = 64,
			w = 64,
			alpha = 0.2,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			x = 8,
			layer = 1
		})
		local detection_ring_right_bg = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_right_bg",
			h = 64,
			w = 64,
			alpha = 0.2,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			x = 8,
			layer = 1
		})

		detection_ring_left_bg:set_size(detection_ring_left_bg:w() * scale, detection_ring_left_bg:h() * scale)
		detection_ring_right_bg:set_size(detection_ring_right_bg:w() * scale, detection_ring_right_bg:h() * scale)
		detection_ring_right_bg:set_texture_rect(64, 0, -64, 64)
		detection_ring_left_bg:set_center_y(self._detection_panel:h() / 2)
		detection_ring_right_bg:set_center_y(self._detection_panel:h() / 2)

		local detection_ring_left = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_left",
			h = 64,
			x = 8,
			w = 64,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			layer = 1
		})
		local detection_ring_right = self._detection_panel:bitmap({
			blend_mode = "add",
			name = "detection_right",
			h = 64,
			x = 8,
			w = 64,
			texture = "guis/textures/pd2/blackmarket/inv_detection_meter",
			render_template = "VertexColorTexturedRadial",
			layer = 1
		})

		detection_ring_left:set_size(detection_ring_left:w() * scale, detection_ring_left:h() * scale)
		detection_ring_right:set_size(detection_ring_right:w() * scale, detection_ring_right:h() * scale)
		detection_ring_right:set_texture_rect(64, 0, -64, 64)
		detection_ring_left:set_center_y(self._detection_panel:h() / 2)
		detection_ring_right:set_center_y(self._detection_panel:h() / 2)

		local detection_value = self._detection_panel:text({
			blend_mode = "add",
			name = "detection_value",
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text
		})

		detection_value:set_x(detection_ring_left_bg:x() + detection_ring_left_bg:w() / 2 - medium_font_size / 2 + 2)
		detection_value:set_y(detection_ring_left_bg:y() + detection_ring_left_bg:h() / 2 - medium_font_size / 2 + 2)

		local detection_text = self._detection_panel:text({
			blend_mode = "add",
			name = "detection_text",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text,
			text = utf8.to_upper(managers.localization:text("bm_menu_stats_detection"))
		})

		detection_text:set_left(detection_ring_left:right() + 8)
		detection_text:set_y(detection_ring_left:y() + detection_ring_left_bg:h() / 2 - medium_font_size / 2 + 2)

		self._buttons = self._btn_panel:panel({
			y = 8
		})
		local btn_x = 10

		for btn, btn_data in pairs(BTNS) do
			local new_btn = BlackMarketGuiButtonItem:new(self._buttons, btn_data, btn_x)
			self._btns[btn] = new_btn
		end

		self._armor_info_panel = self._weapon_info_panel:panel({
			layer = 10,
			w = self._weapon_info_panel:w(),
			h = self._weapon_info_panel:h()
		})
		local armor_info_panel = self._armor_info_panel
		local armor_image = armor_info_panel:bitmap({
			texture = "guis/textures/pd2/endscreen/exp_ring",
			name = "armor_image",
			h = 96,
			y = 10,
			w = 96,
			blend_mode = "normal",
			x = 10
		})
		local armor_name = armor_info_panel:text({
			name = "armor_name_text",
			wrap = true,
			word_wrap = true,
			text = "Improved Combined Tactical Vest",
			y = 10,
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text,
			x = armor_image:right() + 10,
			w = armor_info_panel:w() - armor_image:right() - 20,
			h = medium_font_size * 2
		})
		local equip_text = armor_info_panel:text({
			name = "armor_equipped",
			layer = 1,
			font_size = small_font_size * 0.9,
			font = small_font,
			color = tweak_data.screen_colors.text,
			text = managers.localization:to_upper_text("bm_menu_equipped"),
			x = armor_image:right() + 10,
			y = armor_name:bottom(),
			w = armor_info_panel:w() - armor_image:right() - 20,
			h = small_font_size
		})
		self._info_texts = {}
		self._info_texts_panel = self._weapon_info_panel:panel({
			x = 10,
			y = 10,
			w = self._weapon_info_panel:w() - 20,
			h = self._weapon_info_panel:h() - 20 - real_small_font_size * 3
		})

		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			name = "info_text_1",
			layer = 1,
			font_size = medium_font_size,
			font = medium_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_2",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			name = "info_text_3",
			blend_mode = "add",
			wrap = true,
			word_wrap = true,
			text = "",
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.important_1
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_4",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		}))
		table.insert(self._info_texts, self._info_texts_panel:text({
			text = "",
			wrap = true,
			name = "info_text_5",
			word_wrap = true,
			layer = 1,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.important_1
		}))

		self._info_texts_color = {}
		self._info_texts_bg = {}

		for i, info_text in ipairs(self._info_texts) do
			self._info_texts_color[i] = info_text:color()
			self._info_texts_bg[i] = self._info_texts_panel:rect({
				alpha = 0.2,
				visible = false,
				layer = 0,
				color = Color.black
			})

			self._info_texts_bg[i]:set_shape(info_text:shape())
		end

		local h = real_small_font_size
		local longest_text_w = 0

		if self._data.info_callback then
			self._info_panel = self._panel:panel({
				name = "info_panel",
				layer = 1,
				w = self._btn_panel:w()
			})
			local info_table = self._data.info_callback()

			for i, info in ipairs(info_table) do
				local info_name = info.name or ""
				local info_string = info.text or ""
				local info_color = info.color or tweak_data.screen_colors.text
				local category_text = self._info_panel:text({
					w = 0,
					layer = 1,
					name = "category_" .. tostring(i),
					y = (i - 1) * h,
					h = h,
					font_size = h,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_" .. tostring(info_name)))
				})
				local status_text = self._info_panel:text({
					w = 0,
					layer = 1,
					name = "status_" .. tostring(i),
					y = (i - 1) * h,
					h = h,
					font_size = h,
					font = small_font,
					color = info_color,
					text = utf8.to_upper(managers.localization:text(info_string))
				})

				if info_string == "" then
					category_text:set_color(info_color)
				end

				local _, _, w, _ = category_text:text_rect()

				if longest_text_w < w then
					longest_text_w = w + 10
				end
			end

			for name, text in ipairs(self._info_panel:children()) do
				if string.split(text:name(), "_")[1] == "category" then
					text:set_w(longest_text_w)
					text:set_x(0)
				else
					local _, _, w, _ = text:text_rect()

					text:set_w(w)
					text:set_x(math.round(longest_text_w + 5))
				end
			end
		else
			self._stats_shown = {
				{ name = "weight", inverted = true, },
				{ name = "length", inverted = true, },
				{ name = "concealment", index = true, inverted = true, },
				{ name = "caliber", override = true, },
				{ name = "ammotype", override = true, },
				{ name = "barrel_length", override = true, },
				{ name = "damage", },
				{ name = "spread", percent = false, inverted = true, offset = false, revert = false, hunds = true, round_value = "hunds", },
				{ name = "recoil", percent = false, inverted = true, offset = false, revert = false, hunds = true, round_value = "hunds", },
				--{ name = "suppression", percent = false, offset = true, },
				{ name = "magazine", stat_name = "extra_ammo", round_value = true, },
				{ name = "totalammo", stat_name = "total_ammo_mod", },
				{ name = "fire_rate", round_value = true, },
			}

			--table.insert(self._stats_shown, { inverted = true, name = "reload" })
			--table.insert(self._stats_shown, { name = "optimal_range" })

			self._stats_panel = self._weapon_info_panel:panel({
				y = 58,
				x = 10,
				layer = 1,
				w = self._weapon_info_panel:w() - 20,
				h = self._weapon_info_panel:h() - 30
			})
			local panel = self._stats_panel:panel({
				h = 20,
				layer = 1,
				w = self._stats_panel:w()
			})

			panel:rect({
				color = Color.black:with_alpha(0.5)
			})

			self._stats_titles = {
				equip = self._stats_panel:text({
					x = 120,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text
				}),
				base = self._stats_panel:text({
					alpha = 0.75,
					x = 170,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_base"))
				}),
				mod = self._stats_panel:text({
					alpha = 0.75,
					x = 215,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.stats_mods,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_mod"))
				}),
				skill = self._stats_panel:text({
					alpha = 0.75,
					x = 260,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.resource,
					text = utf8.to_upper(managers.localization:text("bm_menu_stats_skill"))
				}),
				total = self._stats_panel:text({
					x = 200,
					layer = 2,
					font_size = small_font_size,
					font = small_font,
					color = tweak_data.screen_colors.text,
					text = utf8.to_upper(managers.localization:text("bm_menu_chosen"))
				})
			}
			local x = 0
			local y = 20
			local text_panel = nil
			local text_columns = {
				{ name = "name", size = 85, },
				{ name = "equip", size = 75, align = "right", blend = "add", alpha = 0.75, },
				{ name = "base", size = 75, align = "right", blend = "add", alpha = 0.75, },
				{ name = "mods", size = 75, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.stats_mods, },
				{ name = "removed", size = 45, align = "right", blend = "add", alpha = 0.75, offset = -75, color = tweak_data.screen_colors.important_1, font_size = tiny_font_size, },
				{ name = "skill", size = 75, align = "right", blend = "add", alpha = 0.75, color = tweak_data.screen_colors.resource, },
				{ name = "total", size = 75, align = "right", }
			}
			self._stats_texts = {}
			self._rweapon_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._stats_shown) do
				panel = self._rweapon_stats_panel:panel({
					name = "weapon_stats",
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._rweapon_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x + (column.offset or 0),
						w = column.size,
						h = panel:h()
					})
					self._stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = column.font_size or small_font_size,
						font = column.font or small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text,
						y = panel:h() - (column.font_size or small_font_size)
					})
					x = x + column.size + (column.offset or 0)

					if column.name == "total" then
						--text_panel:set_x(190)
					end
				end
			end

			self._armor_stats_shown = {
				--{ name = "health", },
				--{ name = "stamina", round_value = true, },
				{ name = "weight", inverted = true, },
				{ name = "concealment", index = true, inverted = true, },
				--{ name = "armor", },
				{ name = "movement", multiplier = true, round_value = "hunds", },
				{ name = "stamina_drain", multiplier = true, round_value = "hunds", inverted = true, },
				{ name = "dodge", percent = true, },
				--{ name = "damage_shake", },
			}
			local x = 0
			local y = 20
			local text_panel = nil
			self._armor_stats_texts = {}
			local text_columns = {
				{
					size = 100,
					name = "name"
				},
				{
					align = "right",
					name = "equip",
					blend = "add",
					alpha = 0.75,
					size = 45
				},
				{
					align = "right",
					name = "base",
					blend = "add",
					alpha = 0.75,
					size = 60
				},
				{
					align = "right",
					name = "skill",
					blend = "add",
					alpha = 0.75,
					size = 60,
					color = tweak_data.screen_colors.resource
				},
				{
					size = 45,
					name = "total",
					align = "right"
				}
			}
			self._armor_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._armor_stats_shown) do
				panel = self._armor_stats_panel:panel({
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._armor_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._armor_stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x,
						w = column.size,
						h = panel:h()
					})
					self._armor_stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = small_font_size,
						font = small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text
					})
					x = x + column.size

					if column.name == "total" then
						text_panel:set_x(190)
					end
				end
			end

			self._mweapon_stats_shown = {
				{
					range = true,
					name = "damage"
				},
				{
					range = true,
					name = "damage_effect",
					multiple_of = "damage"
				},
				{
					inverse = true,
					name = "charge_time",
					num_decimals = 1,
					suffix = managers.localization:text("menu_seconds_suffix_short")
				},
				{
					range = true,
					name = "range"
				},
				{
					index = true,
					name = "concealment"
				}
			}
			local x = 0
			local y = 20
			local text_panel = nil
			self._mweapon_stats_texts = {}
			local text_columns = {
				{
					size = 100,
					name = "name"
				},
				{
					align = "right",
					name = "equip",
					blend = "add",
					alpha = 0.75,
					size = 55
				},
				{
					align = "right",
					name = "base",
					blend = "add",
					alpha = 0.75,
					size = 60
				},
				{
					align = "right",
					name = "skill",
					blend = "add",
					alpha = 0.75,
					size = 65,
					color = tweak_data.screen_colors.resource
				},
				{
					size = 55,
					name = "total",
					align = "right"
				}
			}
			self._mweapon_stats_panel = self._stats_panel:panel()

			for i, stat in ipairs(self._mweapon_stats_shown) do
				panel = self._mweapon_stats_panel:panel({
					h = 20,
					x = 0,
					layer = 1,
					y = y,
					w = self._mweapon_stats_panel:w()
				})

				if math.mod(i, 2) == 0 and not panel:child(tostring(i)) then
					panel:rect({
						name = tostring(i),
						color = Color.black:with_alpha(0.3)
					})
				end

				x = 2
				y = y + 20
				self._mweapon_stats_texts[stat.name] = {}

				for _, column in ipairs(text_columns) do
					text_panel = panel:panel({
						layer = 0,
						x = x,
						w = column.size,
						h = panel:h()
					})
					self._mweapon_stats_texts[stat.name][column.name] = text_panel:text({
						layer = 1,
						font_size = small_font_size,
						font = small_font,
						align = column.align,
						alpha = column.alpha,
						blend_mode = column.blend,
						color = column.color or tweak_data.screen_colors.text
					})
					x = x + column.size

					if column.name == "total" then
						text_panel:set_x(190)
					end
				end
			end

			panel = self._stats_panel:panel({
				name = "modslist_panel",
				layer = 0,
				y = y + 20,
				w = self._stats_panel:w(),
				h = self._stats_panel:h()
			})
			self._stats_text_modslist = panel:text({
				word_wrap = true,
				wrap = true,
				layer = 1,
				font_size = small_font_size,
				font = small_font,
				color = tweak_data.screen_colors.text
			})
		end

		if self._info_panel then
			self._info_panel:set_size(info_box_panel:w() - 20, self._info_panel:num_children() / 2 * h)
			self._info_panel:set_rightbottom(self._panel:w() - 10, self._btn_panel:top() - 10)
		end

		local tab_x = 0

		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs > 1 then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_l") or managers.localization:get_default_macro("BTN_BOTTOM_L")
			local prev_page = self._panel:text({
				y = 0,
				name = "prev_page",
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.text,
				text = button
			})
			local _, _, w, h = prev_page:text_rect()

			prev_page:set_size(w, h)
			prev_page:set_top(top_padding)
			prev_page:set_left(tab_x)
			prev_page:set_visible(self._selected > 1)
			self._tab_scroll_panel:move(w + 15, 0)
			self._tab_scroll_panel:grow(-(w + 15), 0)
		end

		for _, tab in ipairs(self._tabs) do
			tab_x = tab:set_tab_position(tab_x)
		end

		if (not managers.menu:is_pc_controller() or managers.menu:is_steam_controller()) and #self._tabs > 1 then
			local button = managers.menu:is_steam_controller() and managers.localization:steam_btn("bumper_r") or managers.localization:get_default_macro("BTN_BOTTOM_R")
			local next_page = self._panel:text({
				y = 0,
				name = "next_page",
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.text,
				text = button
			})
			local _, _, w, h = next_page:text_rect()

			next_page:set_size(w, h)
			next_page:set_top(top_padding)
			next_page:set_right(grid_panel_w)
			next_page:set_visible(self._selected < #self._tabs)
			self._tab_scroll_panel:grow(-(w + 15), 0)
		end

		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() and self._tab_scroll_table.panel:w() < self._tab_scroll_table[#self._tab_scroll_table]:right() then
			local prev_page = self._panel:text({
				name = "prev_page",
				w = 0,
				align = "center",
				text = "<",
				y = 0,
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local _, _, w, h = prev_page:text_rect()

			prev_page:set_size(w, h)
			prev_page:set_top(top_padding)
			prev_page:set_left(0)
			prev_page:set_text(" ")
			self._tab_scroll_panel:move(w + 15, 0)
			self._tab_scroll_panel:grow(-(w + 15), 0)

			local next_page = self._panel:text({
				name = "next_page",
				w = 0,
				align = "center",
				text = ">",
				y = 0,
				layer = 2,
				font_size = medium_font_size,
				font = medium_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local _, _, w, h = next_page:text_rect()

			next_page:set_size(w, h)
			next_page:set_top(top_padding)
			next_page:set_right(grid_panel_w)

			self._tab_scroll_table.left = prev_page
			self._tab_scroll_table.right = next_page
			self._tab_scroll_table.left_klick = false
			self._tab_scroll_table.right_klick = true

			if self._selected > 1 then
				self._tab_scroll_table.left_klick = true

				self._tab_scroll_table.left:set_text("<")
			else
				self._tab_scroll_table.left_klick = false

				self._tab_scroll_table.left:set_text(" ")
			end

			if self._selected < #self._tab_scroll_table then
				self._tab_scroll_table.right_klick = true

				self._tab_scroll_table.right:set_text(">")
			else
				self._tab_scroll_table.right_klick = false

				self._tab_scroll_table.right:set_text(" ")
			end

			self._tab_scroll_panel:grow(-(w + 15), 0)
		end
	else
		self._select_rect:hide()
	end

	if MenuBackdropGUI then
		local bg_text = self._fullscreen_panel:text({
			vertical = "top",
			h = 90,
			align = "left",
			alpha = 0.4,
			text = self._title_text:text(),
			font_size = massive_font_size,
			font = massive_font,
			color = tweak_data.screen_colors.button_stage_3
		})
		local x, y = managers.gui_data:safe_to_full_16_9(self._title_text:world_x(), self._title_text:world_center_y())

		bg_text:set_world_left(x)
		bg_text:set_world_center_y(y)
		bg_text:move(-13, 9)
		MenuBackdropGUI.animate_bg_text(self, bg_text)

		if managers.menu:is_pc_controller() then
			local bg_back = self._fullscreen_panel:text({
				name = "back_button",
				vertical = "bottom",
				h = 90,
				alpha = 0.4,
				align = "right",
				layer = 0,
				text = utf8.to_upper(managers.localization:text("menu_back")),
				font_size = massive_font_size,
				font = massive_font,
				color = tweak_data.screen_colors.button_stage_3
			})
			local x, y = managers.gui_data:safe_to_full_16_9(self._panel:child("back_button"):world_right(), self._panel:child("back_button"):world_center_y())

			bg_back:set_world_right(x)
			bg_back:set_world_center_y(y)
			bg_back:move(13, -9)
			MenuBackdropGUI.animate_bg_text(self, bg_back)
		end
	end

	if self._selected_slot then
		self:on_slot_selected(self._selected_slot)
	end

	local black_rect = self._data.skip_blur or self._fullscreen_panel:rect({
		layer = 1,
		color = Color(0.4, 0, 0, 0)
	})

	if is_start_page then
		-- Nothing
	end

	if self._data.create_steam_inventory_extra then
		self._indicator_alpha = self._indicator_alpha or managers.network.account:inventory_is_loading() and 1 or 0
		self._indicator = self._panel:bitmap({
			texture = "guis/textures/icon_loading",
			name = "indicator",
			layer = 1,
			alpha = self._indicator_alpha
		})

		self._indicator:set_left(self._title_text:right() + 10)
		self._indicator:set_center_y(self._title_text:center_y())
		self._indicator:animate(function (o)
			local dt = nil

			while true do
				dt = coroutine.yield()

				self._indicator:rotate(180 * dt)

				self._indicator_alpha = math.lerp(self._indicator_alpha, managers.network.account:inventory_is_loading() and 1 or 0, 15 * dt)

				self._indicator:set_alpha(self._indicator_alpha)
			end
		end)

		local info_box_panel = self._panel:child("info_box_panel")
		self._steam_inventory_extra_panel = self._panel:panel({
			h = top_padding
		})

		self._steam_inventory_extra_panel:set_width(info_box_panel:width())
		self._steam_inventory_extra_panel:set_top(info_box_panel:bottom() + 5)
		self._steam_inventory_extra_panel:set_world_right(self._tabs[self._selected]._grid_panel:world_right())

		self._steam_inventory_extra_data = {}
		local extra_data = self._steam_inventory_extra_data
		extra_data.choices = {}

		for _, name in ipairs(tweak_data.gui.tradable_inventory_sort_list) do
			table.insert(extra_data.choices, managers.localization:to_upper_text("bm_menu_ti_sort_option", {
				sort = managers.localization:text("bm_menu_ti_" .. name)
			}))
		end

		local gui_panel = self._steam_inventory_extra_panel:panel({
			h = medium_font_size + 5
		})
		extra_data.bg = gui_panel:rect({
			alpha = 0.5,
			color = Color.black:with_alpha(0.5)
		})

		BoxGuiObject:new(gui_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		local choice_panel = gui_panel:panel({
			layer = 1
		})
		local choice_text = choice_panel:text({
			halign = "center",
			vertical = "center",
			layer = 1,
			align = "center",
			blend_mode = "add",
			y = 0,
			x = 0,
			valign = "center",
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.button_stage_2,
			text = extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1],
			render_template = Idstring("VertexColorTextured")
		})
		local arrow_left, arrow_right = nil

		if managers.menu:is_pc_controller() and not managers.menu:is_steam_controller() then
			local texture, rect = tweak_data.hud_icons:get_icon_data("scrollbar_arrow")
			arrow_left = gui_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				layer = 1,
				blend_mode = "add",
				visible = true,
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = tweak_data.screen_colors.button_stage_3
			})
			arrow_right = gui_panel:bitmap({
				texture = "guis/textures/menu_arrows",
				layer = 1,
				blend_mode = "add",
				visible = true,
				rotation = 180,
				texture_rect = {
					24,
					0,
					24,
					24
				},
				color = tweak_data.screen_colors.button_stage_3
			})
		else
			local BTN_TOP_L = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_l") or managers.localization:get_default_macro("BTN_TOP_L")
			local BTN_TOP_R = managers.menu:is_steam_controller() and managers.localization:steam_btn("trigger_r") or managers.localization:get_default_macro("BTN_TOP_R")
			arrow_left = gui_panel:text({
				blend_mode = "add",
				layer = 1,
				text = BTN_TOP_L,
				color = managers.menu:is_steam_controller() and tweak_data.screen_colors.button_stage_3,
				font = small_font,
				font_size = small_font_size
			})
			arrow_right = gui_panel:text({
				blend_mode = "add",
				layer = 1,
				text = BTN_TOP_R,
				color = managers.menu:is_steam_controller() and tweak_data.screen_colors.button_stage_3,
				font = small_font,
				font_size = small_font_size
			})

			self:make_fine_text(arrow_left)
			self:make_fine_text(arrow_right)
		end

		arrow_left:set_left(5)
		arrow_left:set_center_y(gui_panel:h() / 2)
		arrow_right:set_right(gui_panel:w() - 5)
		arrow_right:set_center_y(gui_panel:h() / 2)

		extra_data.gui_panel = gui_panel
		extra_data.arrow_left = arrow_left
		extra_data.arrow_right = arrow_right
		extra_data.choice_text = choice_text
		extra_data.arrow_left_highlighted = false
		extra_data.arrow_right_highlighted = false
	end

	self:set_tab_positions()
	self:_round_everything()

	self._in_setup = nil
end



function BlackMarketGui:open_weapon_buy_menu(data, check_allowed_item_func)
	local blackmarket_items = managers.blackmarket:get_weapon_category(data.category) or {}
	local new_node_data = {}
	local weapon_tweak = tweak_data.weapon
	local x_id, y_id, x_level, y_level, x_unlocked, y_unlocked, x_skill, y_skill, x_gv, y_gv, x_sn, y_sn, x_locked_sort, y_locked_sort = nil
	local item_categories = {}
	local sorted_categories = {}
	local gui_categories = tweak_data.gui.buy_weapon_categories[data.category]

	for i = 1, #gui_categories do
		table.insert(item_categories, {})
	end

	local function test_weapon_categories(weapon_categories, gui_weapon_categories)
		for i, weapon_category in ipairs(gui_weapon_categories) do
			if weapon_category ~= (tweak_data.gui.buy_weapon_category_aliases[weapon_categories[i]] or weapon_categories[i]) then
				return false
			end
		end

		return true
	end

	local function test_weapon_available(weapon_data)
		if not weapon_data.unlocked then
			local def_data = tweak_data.upgrades.definitions[weapon_data.weapon_id]

			if def_data and def_data.dlc then
				local dlc_unlocked = managers.dlc:is_dlc_unlocked(def_data.dlc)

				if not dlc_unlocked and managers.dlc:should_hide_unavailable(def_data.dlc) then
					return false
				end
			end
		end

		return true
	end

	for _, item in ipairs(blackmarket_items) do
		local weapon_data = tweak_data.weapon[item.weapon_id]

		for i, gui_category in ipairs(gui_categories) do
			if test_weapon_categories(weapon_data.categories, gui_category) and test_weapon_available(item) then
				table.insert(item_categories[i], item)
			end
		end
	end

	for i, category in ipairs(item_categories) do
		local category_key = table.concat(gui_categories[i], "_")
		item_categories[category_key] = category
		item_categories[i] = nil
		sorted_categories[i] = category_key
	end

	for category, items in pairs(item_categories) do
		local sort_table = {}

		for _, item in ipairs(items) do
			local id = item.weapon_id
			local unlocked = managers.blackmarket:weapon_unlocked(id)
			local gv = "normal" --weapon_tweak[id] and weapon_tweak[id].global_value
			local dlc = gv and managers.dlc:global_value_to_dlc(gv)
			local level = item.level or 0
			local sn = gv and tweak_data.lootdrop.global_values[gv].sort_number or 0
			local skill = item.skill_based or false
			local func = item.func_based or false
			sort_table[id] = {
				unlocked = unlocked,
				locked_sort = sn, -- + tweak_data.gui:get_locked_sort_number(dlc, func, skill),
				level = level,
				sort_number = sn,
				skill = skill
			}
		end

		table.sort(items, function (x, y)
			if _G.IS_VR and x.vr_locked ~= y.vr_locked then
				return not x.vr_locked
			end

			x_id = x.weapon_id
			y_id = y.weapon_id
			x_unlocked = sort_table[x_id].unlocked
			y_unlocked = sort_table[y_id].unlocked

			if x_unlocked ~= y_unlocked then
				return x_unlocked
			end

			if not x_unlocked then
				x_locked_sort = sort_table[x_id].locked_sort
				y_locked_sort = sort_table[y_id].locked_sort

				if x_locked_sort ~= y_locked_sort then
					return x_locked_sort < y_locked_sort
				end
			end

			x_level = sort_table[x_id].level
			y_level = sort_table[y_id].level

			if x_level ~= y_level then
				return x_level < y_level
			end

			x_sn = sort_table[x_id].sort_number
			y_sn = sort_table[y_id].sort_number

			if x_sn ~= y_sn then
				return x_sn < y_sn
			end

			x_skill = sort_table[x_id].skill_based
			y_skill = sort_table[y_id].skill_based

			if x_skill ~= y_skill then
				return y_skill
			end

			return x_id < y_id
		end)
	end

	local item_data = nil
	local rows = tweak_data.gui.WEAPON_ROWS_PER_PAGE or 3
	local columns = tweak_data.gui.WEAPON_COLUMNS_PER_PAGE or 3

	for _, category in ipairs(sorted_categories) do
		local items = item_categories[category]
		item_data = {}

		for _, item in ipairs(items) do
			table.insert(item_data, item)
		end

		local name_id = managers.localization:to_upper_text("menu_" .. category)

		table.insert(new_node_data, {
			name = category,
			category = data.category,
			prev_node_data = data,
			name_localized = name_id,
			on_create_func = data.on_create_func,
			on_create_func_name = not data.on_create_func and (data.on_create_func_name or "populate_buy_weapon"),
			on_create_data = item_data,
			identifier = self.identifiers.weapon,
			override_slots = {
				columns,
				rows
			}
		})
	end

	new_node_data.buying_weapon = true
	new_node_data.topic_id = "bm_menu_buy_weapon_title"
	new_node_data.topic_params = {
		weapon_category = managers.localization:text("bm_menu_" .. data.category)
	}
	new_node_data.blur_fade = self._data.blur_fade
	new_node_data.search_box_disconnect_callback_name = "on_search_item"

	managers.menu:open_node(self._inception_node_name, {
		new_node_data
	})
end



function BlackMarketGuiSlotItem:init(main_panel, data, x, y, w, h)
	BlackMarketGuiSlotItem.super.init(self, main_panel, data, x, y, w, h)

	self.rect_bg = self._panel:rect({
		alpha = 0,
		color = Color.black
	})

	if data.holding then
		self._post_load_alpha = 0.2
		data.equipped_text = managers.localization:to_upper_text("bm_menu_holding_item")
	end

	if data.custom_name_text then
		local custom_name_text = self._panel:text({
			vertical = "top",
			name = "custom_name_text",
			align = "right",
			layer = 2,
			text = data.custom_name_text,
			font_size = small_font_size,
			font = small_font,
			color = tweak_data.screen_colors.text
		})

		custom_name_text:move((data.custom_name_text_right or 0) - 5, 5)

		local right = custom_name_text:right()

		custom_name_text:grow(-(custom_name_text:w() * (data.custom_name_text_width or 0.5)), 0)

		local _, _, w, h = custom_name_text:text_rect()

		if custom_name_text:w() < w then
			custom_name_text:set_font_scale(custom_name_text:font_scale() * custom_name_text:w() / w)
		end

		custom_name_text:set_right(right)
	end

	if data.hide_bg then
		-- Nothing
	end

	if data.mid_text and type(data.mid_text) == "table" then
		local text = self._panel:text({
			name = "text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.mid_text.no_upper and data.mid_text.noselected_text or utf8.to_upper(data.mid_text.noselected_text),
			align = data.mid_text.align or "center",
			vertical = data.mid_text.vertical or "center",
			font_size = data.mid_text.font_size or medium_font_size,
			font = data.mid_text.font or medium_font,
			color = data.mid_text.noselected_color,
			blend_mode = data.mid_text.blend_mode or "add"
		})

		text:grow(-10, -10)
		text:move(5, 5)
		text:move(0, text:h() / 2 - text:font_size() / 2)
		text:set_vertical("top")

		self._text_in_mid = true
	elseif data.corner_text and type(data.corner_text) == "table" then
		self._panel:text({
			name = "corner_text",
			wrap = true,
			word_wrap = true,
			layer = 2,
			text = data.corner_text.no_upper and data.corner_text.noselected_text or utf8.to_upper(data.corner_text.noselected_text),
			align = data.corner_text.align or "center",
			vertical = data.corner_text.vertical or "bottom",
			font_size = data.corner_text.font_size or tiny_font_size,
			font = data.corner_text.font or small_font,
			color = data.corner_text.noselected_color or Color.red,
			blend_mode = data.corner_text.blend_mode or "add"
		})
	end

	local function animate_loading_texture(o)
		o:set_render_template(Idstring("VertexColorTexturedRadial"))
		o:set_color(Color(0, 0, 1, 1))

		local time = coroutine.yield()
		local tw = o:texture_width()
		local th = o:texture_height()
		local old_alpha = 0
		local flip = false
		local delta, alpha = nil

		o:set_color(Color(1, 0, 1, 1))

		while true do
			delta = time % 2
			alpha = math.sin(delta * 90)

			o:set_color(Color(1, alpha, 1, 1))

			if flip and old_alpha < alpha then
				o:set_texture_rect(0, 0, tw, th)

				flip = false
			elseif not flip and alpha < old_alpha then
				o:set_texture_rect(tw, 0, -tw, th)

				flip = true
			end

			old_alpha = alpha
			time = time + coroutine.yield() * 2
		end
	end

	self._mini_panel = self._panel:panel()
	self._extra_textures = {}

	if data.extra_bitmaps then
		local color, shape = nil

		for i, bitmap in ipairs(data.extra_bitmaps) do
			if DB:has(Idstring("texture"), bitmap) then
				color = data.extra_bitmaps_colors and data.extra_bitmaps_colors[i] or Color.white
				shape = data.extra_bitmaps_shape and data.extra_bitmaps_shape[i] or {
					x = 0,
					y = 0
				}

				table.insert(self._extra_textures, self._panel:bitmap({
					h = 32,
					w = 32,
					layer = 0,
					texture = bitmap,
					color = color,
					x = self._panel:w() * shape.x,
					y = self._panel:h() * shape.y
				}))
			else
				Application:error("[BlackMarketGuiSlotItem] Texture not found in DB: ", tostring(bitmap))
			end
		end
	end

	local texture_loaded_clbk = callback(self, self, "texture_loaded_clbk")

	if data.mini_icons then
		local padding = data.mini_icons.borders and 14 or 5

		for k, icon_data in ipairs(data.mini_icons) do
			icon_data.padding = padding

			if not icon_data.texture then
				local new_icon = nil

				if icon_data.text then
					new_icon = self._mini_panel:text({
						font = tweak_data.menu.pd2_small_font,
						font_size = tweak_data.menu.pd2_font_size,
						text = icon_data.text,
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode
					})
				else
					new_icon = self._mini_panel:rect({
						color = icon_data.color or Color.white,
						w = icon_data.w or 32,
						h = icon_data.h or 32,
						layer = icon_data.layer or 1,
						blend_mode = icon_data.blend_mode,
						alpha = icon_data.alpha
					})
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end
			elseif icon_data.stream then
				if DB:has(Idstring("texture"), icon_data.texture) then
					icon_data.request_index = managers.menu_component:request_texture(icon_data.texture, callback(self, self, "icon_loaded_clbk", icon_data)) or false
				end
			else
				local new_icon = self._mini_panel:bitmap({
					texture = icon_data.texture,
					color = icon_data.color or Color.white,
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1,
					alpha = icon_data.alpha,
					blend_mode = icon_data.blend_mode
				})

				if icon_data.render_template then
					new_icon:set_render_template(icon_data.render_template)
				end

				if icon_data.visible == false then
					new_icon:set_visible(false)
				end

				if icon_data.left then
					new_icon:set_left(padding + icon_data.left)
				elseif icon_data.right then
					new_icon:set_right(self._mini_panel:w() - padding - icon_data.right)
				else
					new_icon:set_center_x(self._mini_panel:w() / 2)
				end

				if icon_data.top then
					new_icon:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					new_icon:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				else
					new_icon:set_center_y(self._mini_panel:h() / 2)
				end

				if icon_data.name == "new_drop" and data.new_drop_data then
					data.new_drop_data.icon = new_icon
				end

				if icon_data.spin then
					local function spin_animation(o)
						local dt = nil

						while true do
							dt = coroutine.yield()

							o:rotate(dt * 180)
						end
					end

					new_icon:animate(spin_animation)

					self._loading_icon = new_icon
				end
			end

			if icon_data.borders then
				local icon_border_panel = self._mini_panel:panel({
					w = icon_data.w or 32,
					h = icon_data.h or 32,
					layer = icon_data.layer or 1
				})

				if icon_data.visible == false then
					icon_border_panel:set_visible(false)
				end

				if icon_data.left then
					icon_border_panel:set_left(padding + icon_data.left)
				elseif icon_data.right then
					icon_border_panel:set_right(self._mini_panel:w() - padding - icon_data.right)
				end

				if icon_data.top then
					icon_border_panel:set_top(padding + icon_data.top)
				elseif icon_data.bottom then
					icon_border_panel:set_bottom(self._mini_panel:h() - padding - icon_data.bottom)
				end

				BoxGuiObject:new(icon_border_panel, {
					sides = {
						1,
						1,
						1,
						1
					}
				})
			end
		end

		if data.mini_icons.borders then
			local tl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local tr_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local tr_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local bl_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local bl_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})
			local br_side = self._mini_panel:rect({
				blend_mode = "add",
				w = 10,
				h = 2,
				alpha = 0.4,
				color = Color.white
			})
			local br_down = self._mini_panel:rect({
				blend_mode = "add",
				w = 2,
				h = 10,
				alpha = 0.4,
				color = Color.white
			})

			tl_side:set_lefttop(self._mini_panel:w() - 54, 8)
			tl_down:set_lefttop(self._mini_panel:w() - 54, 8)
			tr_side:set_righttop(self._mini_panel:w() - 8, 8)
			tr_down:set_righttop(self._mini_panel:w() - 8, 8)
			bl_side:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			bl_down:set_leftbottom(self._mini_panel:w() - 54, self._mini_panel:h() - 8)
			br_side:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
			br_down:set_rightbottom(self._mini_panel:w() - 8, self._mini_panel:h() - 8)
		end
	end

	if data.mini_colors then
		local panel_size = 32
		local padding = data.mini_icons and data.mini_icons.borders and 14 or 5
		local color_panel = self._mini_panel:panel({
			layer = 1,
			w = panel_size,
			h = panel_size
		})

		color_panel:set_right(self._mini_panel:w() - padding)
		color_panel:set_bottom(self._mini_panel:h() - padding)
		BoxGuiObject:new(color_panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})

		if #data.mini_colors == 1 then
			color_panel:rect({
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend
			})
		elseif #data.mini_colors == 2 then
			color_panel:polygon({
				triangles = {
					Vector3(0, 0, 0),
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0)
				},
				color = data.mini_colors[2].color or Color.red,
				alpha = data.mini_colors[2].alpha or 1,
				blend_mode = data.mini_colors[2].blend,
				w = panel_size,
				h = panel_size
			})
			color_panel:polygon({
				triangles = {
					Vector3(0, panel_size, 0),
					Vector3(panel_size, 0, 0),
					Vector3(panel_size, panel_size, 0)
				},
				color = data.mini_colors[1].color or Color.red,
				alpha = data.mini_colors[1].alpha or 1,
				blend_mode = data.mini_colors[1].blend,
				w = panel_size,
				h = panel_size
			})
		end
	end

	if data.bitmap_texture then
		local texture = data.bitmap_texture[1] or data.bitmap_texture
		self._bitmap_panel = self._panel:panel()
		local text_callback = callback(self, self, "texture_loaded_clbk", data.bitmap_texture)

		if DB:has(Idstring("texture"), texture) then
			self._loading_texture = true

			if data.stream then
				self._requested_texture = texture
				self._request_index = managers.menu_component:request_texture(self._requested_texture, text_callback)
			else
				text_callback(data.bitmap_texture, Idstring(texture))
			end
		end

		if not self._bitmap then
			local min = math.min(self._bitmap_panel:w(), self._bitmap_panel:h())

			self._bitmap_panel:set_size(min, min)
			self._bitmap_panel:set_center(self._panel:w() / 2, self._panel:h() / 2)

			self._bitmap = self._bitmap_panel:bitmap({
				texture = "guis/dlcs/gage_pack_jobs/textures/pd2/endscreen/gage_assignment",
				name = "item_texture",
				h = 48,
				valign = "scale",
				w = 48,
				halign = "scale",
				render_template = "VertexColorTextured", --"VertexColorTexturedRadial",
				color = Color(1, 1, 1),
				layer = #self._extra_textures + 1
			})

			self._bitmap:set_center(self._bitmap_panel:w() / 2, self._bitmap_panel:h() / 2)
			--self._bitmap:animate(animate_loading_texture)
		end
	end

	local bg_image = data.button_text and self._panel:text({
		vertical = "center",
		wrap = true,
		align = "center",
		wrap_word = true,
		valign = "center",
		text = data.button_text,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		color = tweak_data.screen_colors.text
	})

	if data.bg_texture and DB:has(Idstring("texture"), data.bg_texture) then
		local bg_image = self._panel:bitmap({
			name = "bg_texture",
			halign = "scale",
			valign = "scale",
			layer = 0,
			texture = data.bg_texture,
			color = data.bg_texture_color or Color.white,
			blend_mode = data.bg_texture_blend_mode or "add",
			alpha = data.bg_alpha ~= nil and data.bg_alpha or 1
		})
		local texture_width = bg_image:texture_width()
		local texture_height = bg_image:texture_height()
		local panel_width = self._panel:w()
		local panel_height = self._panel:h()
		local tw = texture_width
		local th = texture_height
		local pw = panel_width
		local ph = panel_height

		if tw == 0 or th == 0 then
			Application:error("[BlackMarketGuiSlotItem] BG Texture size error!:", "width", tw, "height", th)

			tw = 1
			th = 1
		end

		local sw = math.min(pw, ph * tw / th)
		local sh = math.min(ph, pw / (tw / th))

		bg_image:set_size(math.round(sw), math.round(sh))
		bg_image:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5)
	end

	local equipped_text = self._panel:text({
		text = "",
		vertical = "top",
		name = "equipped_text",
		align = "left",
		layer = 2,
		font_size = small_font_size,
		font = small_font,
		color = tweak_data.screen_colors.text
	})

	equipped_text:move(5, 5)

	if data.equipped then
		local equipped_string = data.equipped_text or managers.localization:text("bm_menu_equipped")

		equipped_text:set_text(utf8.to_upper(equipped_string))

		self._equipped_box = BoxGuiObject:new(self._panel, {
			sides = {
				1,
				1,
				1,
				1
			}
		})
	end

	local red_box = false
	local number_text = false
	self._conflict = data.conflict
	self._level_req = data.level

	if data.lock_texture then
		red_box = true
	end

	if type(data.unlocked) == "number" then
		number_text = math.abs(data.unlocked)

		if data.unlocked < 0 then
			red_box = true
			self._item_req = true
		end
	end

	if data.mid_text and not data.mid_text_no_change_alpha then
		if self._bitmap then
			self._bitmap:set_color(self._bitmap:color():with_alpha(0.6))

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
			end
		end

		if self._loading_texture then
			self._post_load_alpha = 0.4
		end
	end

	if red_box then
		if self._bitmap then
			self._bitmap:set_color((data.bitmap_locked_color or DEFAULT_LOCKED_COLOR):with_alpha(data.bitmap_locked_alpha or DEFAULT_LOCKED_BLEND_ALPHA))

			for _, bitmap in pairs(self._extra_textures) do
				bitmap:set_color(bitmap:color():with_alpha(DEFAULT_LOCKED_BLEND_ALPHA))
			end

			self._bitmap:set_blend_mode(data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE)

			if self._akimbo_bitmap then
				self._akimbo_bitmap:set_color(self._bitmap:color())
				self._akimbo_bitmap:set_blend_mode(data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE)
			end
		end

		if self._loading_texture then
			self._post_load_color = data.bitmap_locked_color or DEFAULT_LOCKED_COLOR
			self._post_load_alpha = data.bitmap_locked_alpha or DEFAULT_LOCKED_BLEND_ALPHA
			self._post_load_blend_mode = data.bitmap_locked_blend_mode or DEFAULT_LOCKED_BLEND_MODE
		end

		if (not data.unlocked or data.can_afford ~= false) and data.lock_texture ~= true then
			self._lock_bitmap = self._panel:bitmap({
				name = "lock",
				h = 32,
				w = 32,
				texture = data.lock_texture or "guis/textures/pd2/skilltree/padlock",
				texture_rect = data.lock_rect or nil,
				color = data.lock_color or tweak_data.screen_colors.important_1,
				layer = #self._extra_textures + 2
			})

			if data.lock_shape then
				local w = data.lock_shape.w or 32
				local h = data.lock_shape.h or 32

				self._lock_bitmap:set_size(w, h)
			end

			self._lock_bitmap:set_center(self._panel:w() / 2, self._panel:h() / 2)

			if data.lock_shape then
				local x = data.lock_shape.x or 0
				local y = data.lock_shape.y or 0

				self._lock_bitmap:move(x, y)
			end
		end
	end

	if number_text then
		-- Nothing
	end

	self:deselect(true)
	self:set_highlight(false, true)
end



function BlackMarketGui:mouse_moved(o, x, y)
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._enabled then
		return
	end

	if self._renaming_item then
		return true, "link"
	end

	if alive(self._no_input_panel) then
		self._no_input = self._no_input_panel:inside(x, y) and self:input_focus() ~= true

		if self._no_input then
			return false, "arrow"
		end
	end

	if alive(self._context_panel) then
		local context_btns = self._context_panel:child("btns"):children()
		local update_select = false

		if not self._context_btn_selected then
			update_select = true
		elseif not context_btns[self._context_btn_selected]:inside(x, y) then
			context_btns[self._context_btn_selected]:set_color(tweak_data.screen_colors.button_stage_3)

			self._context_btn_selected = nil
			update_select = true
		end

		if update_select then
			for i, btn in ipairs(context_btns) do
				if btn:inside(x, y) then
					self._context_btn_selected = i

					managers.menu_component:post_event("highlight")
					btn:set_color(tweak_data.screen_colors.button_stage_2)

					break
				end
			end
		end

		if self._context_btn_selected then
			return true, "link"
		end

		local used = false
		local pointer = "arrow"

		if self._panel:child("back_button"):inside(x, y) then
			used = true
			pointer = "link"

			if not self._back_button_highlighted then
				self._back_button_highlighted = true

				self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")

				return used, pointer
			end
		elseif self._back_button_highlighted then
			self._back_button_highlighted = false

			self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_3)
		end

		return used, pointer
	end

	if self._extra_options_data then
		local used = false
		local pointer = "arrow"
		self._extra_options_data.selected = self._extra_options_data.selected or 1
		local selected_slot = nil

		for i = 1, self._extra_options_data.num_panels do
			local option = self._extra_options_data[i]
			local panel = option.panel
			local image = option.image

			if alive(panel) and panel:inside(x, y) then
				if not option.highlighted then
					option.highlighted = true
				end

				used = true
				pointer = "link"
			elseif option.highlighted then
				option.highlighted = false
			end

			if alive(image) then
				image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
			end
		end

		if used then
			return used, pointer
		end
	elseif self._steam_inventory_extra_data and alive(self._steam_inventory_extra_data.gui_panel) then
		local used = false
		local pointer = "arrow"
		local extra_data = self._steam_inventory_extra_data

		if extra_data.arrow_left:inside(x, y) then
			if not extra_data.arrow_left_highlighted then
				extra_data.arrow_left_highlighted = true

				extra_data.arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			used = true
			pointer = "link"
		elseif extra_data.arrow_left_highlighted then
			extra_data.arrow_left_highlighted = false

			extra_data.arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
		end

		if extra_data.arrow_right:inside(x, y) then
			if not extra_data.arrow_right_highlighted then
				extra_data.arrow_right_highlighted = true

				extra_data.arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				managers.menu_component:post_event("highlight")
			end

			used = true
			pointer = "link"
		elseif extra_data.arrow_right_highlighted then
			extra_data.arrow_right_highlighted = false

			extra_data.arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
		end

		if used then
			if alive(extra_data.bg) then
				extra_data.bg:set_color(tweak_data.screen_colors.button_stage_2:with_alpha(0.2))
				extra_data.bg:set_alpha(1)
			end

			return used, pointer
		elseif alive(extra_data.bg) then
			extra_data.bg:set_color(Color.black:with_alpha(0.5))
		end
	end

	local inside_tab_area = self._tab_area_panel:inside(x, y)
	local used = true
	local pointer = inside_tab_area and self._highlighted == self._selected and "arrow" or "link"
	local inside_tab_scroll = self._tab_scroll_panel:inside(x, y)
	local update_select = false

	if not self._highlighted then
		update_select = true
		used = false
		pointer = "arrow"
	elseif not inside_tab_scroll or self._tabs[self._highlighted] and not self._tabs[self._highlighted]:inside(x, y) then
		self._tabs[self._highlighted]:set_highlight(not self._pages, not self._pages)

		self._highlighted = nil
		update_select = true
		used = false
		pointer = "arrow"
	end

	if update_select then
		for i, tab in ipairs(self._tabs) do
			update_select = inside_tab_scroll and tab:inside(x, y)

			if update_select then
				self._highlighted = i

				self._tabs[self._highlighted]:set_highlight(self._selected ~= self._highlighted)

				used = true
				pointer = self._highlighted == self._selected and "arrow" or "link"
			end
		end
	end

	if self._tabs[self._selected] then
		local tab_used, tab_pointer = self._tabs[self._selected]:mouse_moved(x, y)

		if tab_used then
			local x, y = self._tabs[self._selected]:selected_slot_center()

			self._select_rect:set_world_center(x, y)
			self._select_rect:stop()
			self._select_rect_box:set_color(Color.white)
			self._select_rect:set_visible(self._tabs[self._selected]._grid_panel:top() < y and y < self._tabs[self._selected]._grid_panel:bottom() and self._selected_slot and self._selected_slot._name ~= "empty")

			used = tab_used
			pointer = tab_pointer
		end
	end

	if self._market_bundles then
		local active_bundle = self._market_bundles[self._data.active_market_bundle]

		if active_bundle then
			for key, data in pairs(active_bundle) do
				if key ~= "panel" and (alive(data.text) and data.text:inside(x, y) or alive(data.image) and data.image:inside(x, y)) then
					if not data.highlighted then
						data.highlighted = true

						if alive(data.image) then
							data.image:set_alpha(1)
						end

						if alive(data.text) then
							data.text:set_color(tweak_data.screen_colors.button_stage_2)
						end

						managers.menu_component:post_event("highlight")
					end

					if not used then
						used = true
						pointer = "link"
					end
				elseif data.highlighted then
					data.highlighted = false

					if alive(data.image) then
						data.image:set_alpha(0.9)
					end

					if alive(data.text) then
						data.text:set_color(tweak_data.screen_colors.button_stage_3)
					end
				end
			end
		end

		if self._market_bundles.arrow_left then
			if self._market_bundles.arrow_left:inside(x, y) then
				if not self._market_bundles.arrow_left_highlighted then
					self._market_bundles.arrow_left_highlighted = true

					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_left_highlighted then
				self._market_bundles.arrow_left_highlighted = false

				self._market_bundles.arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end

		if self._market_bundles.arrow_right then
			if self._market_bundles.arrow_right:inside(x, y) then
				if not self._market_bundles.arrow_right_highlighted then
					self._market_bundles.arrow_right_highlighted = true

					managers.menu_component:post_event("highlight")
					self._market_bundles.arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				end

				if not used then
					used = true
					pointer = "link"
				end
			elseif self._market_bundles.arrow_right_highlighted then
				self._market_bundles.arrow_right_highlighted = false

				self._market_bundles.arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
			end
		end
	end

	if self._panel:child("back_button"):inside(x, y) then
		used = true
		pointer = "link"

		if not self._back_button_highlighted then
			self._back_button_highlighted = true

			self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_2)
			managers.menu_component:post_event("highlight")

			return used, pointer
		end
	elseif self._back_button_highlighted then
		self._back_button_highlighted = false

		self._panel:child("back_button"):set_color(tweak_data.screen_colors.button_stage_3)
	end

	update_select = false

	if not self._button_highlighted then
		update_select = true
	elseif self._btns[self._button_highlighted] and not self._btns[self._button_highlighted]:inside(x, y) then
		self._btns[self._button_highlighted]:set_highlight(false)

		self._button_highlighted = nil
		update_select = true
	end

	if update_select then
		for i, btn in pairs(self._btns) do
			if not self._button_highlighted and btn:visible() and btn:inside(x, y) then
				self._button_highlighted = i

				btn:set_highlight(true)
			else
				btn:set_highlight(false)
			end
		end
	end

	if self._button_highlighted then
		used = true
		pointer = "link"
	end

	if self._tab_scroll_table.left and self._tab_scroll_table.left_klick then
		local color = nil

		if self._tab_scroll_table.left:inside(x, y) then
			color = tweak_data.screen_colors.button_stage_2
			used = true
			pointer = "link"
		else
			color = tweak_data.screen_colors.button_stage_3
		end

		self._tab_scroll_table.left:set_color(color)
	end

	if self._tab_scroll_table.right and self._tab_scroll_table.right_klick then
		local color = nil

		if self._tab_scroll_table.right:inside(x, y) then
			color = tweak_data.screen_colors.button_stage_2
			used = true
			pointer = "link"
		else
			color = tweak_data.screen_colors.button_stage_3
		end

		self._tab_scroll_table.right:set_color(color)
	end

	if self._rename_info_text then
		local text_button = self._info_texts and self._info_texts[self._rename_info_text]

		if text_button then
			if self._slot_data and text_button:inside(x, y) then
				if not self._rename_highlight then
					self._rename_highlight = true

					text_button:set_blend_mode("add")
					text_button:set_color(tweak_data.screen_colors.button_stage_2)

					local bg = self._info_texts_bg[self._rename_info_text]

					if alive(bg) then
						bg:set_visible(true)
						bg:set_color(tweak_data.screen_colors.button_stage_3)
					end

					managers.menu_component:post_event("highlight")
				end

				used = true
				pointer = "link"
			elseif self._rename_highlight then
				self._rename_highlight = false

				text_button:set_blend_mode("normal")
				text_button:set_color(tweak_data.screen_colors.text)

				local bg = self._info_texts_bg[self._rename_info_text]

				if alive(bg) then
					bg:set_visible(false)
					bg:set_color(Color.black)
				end
			end
		end
	end

	return used, pointer
end

function BlackMarketGui:mouse_pressed(button, x, y)
	if alive(self._context_panel) and not self._context_panel:inside(x, y) then
		self:destroy_context_menu()
	end

	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	if not self._enabled then
		return
	end

	if self._renaming_item then
		self:_stop_rename_item()

		return
	end

	if self._no_input then
		return
	end

	if alive(self._context_panel) then
		if self._context_btn_selected and button == Idstring("0") then
			local data = self._visible_btns[self._context_btn_selected]._data

			if data.callback then
				managers.menu_component:post_event("menu_enter")
				data.callback(self._slot_data, self._data.topic_params)
			end

			self:destroy_context_menu()
		end

		return
	end

	if self._extra_options_data then
		local selected_slot = nil

		if button == Idstring("0") or button == Idstring("1") then
			self._extra_options_data.selected = self._extra_options_data.selected or 1

			for i = 1, self._extra_options_data.num_panels do
				local option = self._extra_options_data[i]
				local panel = option.panel

				if alive(panel) and panel:inside(x, y) then
					selected_slot = i

					break
				end
			end
		end

		if selected_slot then
			self._extra_options_data.selected = selected_slot

			for i = 1, self._extra_options_data.num_panels do
				local option = self._extra_options_data[i]
				local box = option.box
				local image = option.image
				local selected = i == selected_slot

				if alive(box) then
					if selected and not option.selected then
						option.selected = true

						self:show_btns(self._selected_slot)
						self:_update_borders()
						self:update_info_text()
						managers.menu_component:post_event("highlight")
					elseif not selected then
						option.selected = false
					end

					box:set_visible(selected)
				end

				if alive(image) then
					image:set_alpha((option.selected and 1 or 0.9) * (option.highlighted and 1 or 0.9))
				end
			end

			return
		end
	elseif self._steam_inventory_extra_data and button == Idstring("0") and alive(self._steam_inventory_extra_data.gui_panel) and not self._input_wait_t then
		local extra_data = self._steam_inventory_extra_data

		if Global.blackmarket_manager.tradable_inventory_sort > 1 and extra_data.arrow_left:inside(x, y) then
			Global.blackmarket_manager.tradable_inventory_sort = math.max(Global.blackmarket_manager.tradable_inventory_sort - 1, 1)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		end

		if Global.blackmarket_manager.tradable_inventory_sort < #tweak_data.gui.tradable_inventory_sort_list and extra_data.arrow_right:inside(x, y) then
			Global.blackmarket_manager.tradable_inventory_sort = math.min(Global.blackmarket_manager.tradable_inventory_sort + 1, #tweak_data.gui.tradable_inventory_sort_list)

			extra_data.choice_text:set_text(extra_data.choices[Global.blackmarket_manager.tradable_inventory_sort or 1])

			self._reload_in_t = 0.8
			self._input_wait_t = 0.2

			managers.menu:active_menu().renderer:disable_input(0.2)
			managers.menu_component:post_event("menu_enter")

			return
		end
	end

	local holding_shift = false
	local scroll_button_pressed = button == Idstring("mouse wheel up") or button == Idstring("mouse wheel down")
	local inside_tab_area = self._tab_area_panel:inside(x, y) or self._data.scroll_tab_anywhere

	if inside_tab_area then
		if button == Idstring("mouse wheel down") then
			self:next_page(true)

			return
		elseif button == Idstring("mouse wheel up") then
			self:previous_page(true)

			return
		end
	elseif self._tabs[self._selected] and scroll_button_pressed then
		local selected_slot = self._tabs[self._selected]:mouse_pressed(button, x, y)

		self:on_slot_selected(selected_slot)

		if selected_slot then
			return
		end
	end

	if button ~= Idstring("0") or button == Idstring("1") then
		return
	end

	if self._panel:child("back_button"):inside(x, y) then
		managers.menu:back(true)

		return
	end

	if self._tab_scroll_table.left_klick and self._tab_scroll_table.left:inside(x, y) then
		self:previous_page()

		return
	end

	if self._tab_scroll_table.right_klick and self._tab_scroll_table.right:inside(x, y) then
		self:next_page()

		return
	end

	if self._market_bundles then
		local active_bundle = self._market_bundles[self._data.active_market_bundle]

		if active_bundle then
			if active_bundle.safe.text:inside(x, y) or active_bundle.safe.image:inside(x, y) then
				managers.menu:open_node("inventory_tradable_container_show", {
					{
						container = {
							show_only = true,
							content = active_bundle.safe.entry,
							drill = active_bundle.drill.entry,
							safe = active_bundle.safe.entry,
							num_bundles = self._market_bundles.num_bundles,
							active_market_bundle = self._data.active_market_bundle,
							market_bundles = self._market_bundles.market_bundles
						}
					}
				})
				managers.menu_component:post_event("menu_enter")

				return
			end

			if active_bundle.drill.text and active_bundle.drill.text:inside(x, y) or active_bundle.drill.image and active_bundle.drill.image:inside(x, y) then
				MenuCallbackHandler:steam_buy_drill(nil, {
					drill = active_bundle.drill.entry
				})
				managers.menu_component:post_event("menu_enter")

				return
			end
		end

		if self._market_bundles.arrow_left and self._market_bundles.arrow_left:inside(x, y) then
			local active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:hide()

			self._data.active_market_bundle = self._data.active_market_bundle - 1

			if self._data.active_market_bundle == 0 then
				self._data.active_market_bundle = self._market_bundles.num_bundles
			end

			active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:show()
			managers.menu_component:post_event("menu_enter")

			return
		end

		if self._market_bundles.arrow_right and self._market_bundles.arrow_right:inside(x, y) then
			local active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:hide()

			self._data.active_market_bundle = self._data.active_market_bundle % self._market_bundles.num_bundles + 1
			active_bundle = self._market_bundles[self._data.active_market_bundle]

			active_bundle.panel:show()
			managers.menu_component:post_event("menu_enter")

			return
		end
	end

	if self._selected_slot and self._selected_slot._equipped_rect then
		self._selected_slot._equipped_rect:set_alpha(1)
	end

	if self._tab_scroll_panel:inside(x, y) and self._tabs[self._highlighted] and self._tabs[self._highlighted]:inside(x, y) ~= 1 then
		if self._selected ~= self._highlighted then
			self:set_selected_tab(self._highlighted)
		end

		return
	elseif self._tabs[self._selected] then
		local selected_slot = self._tabs[self._selected]:mouse_pressed(button, x, y)

		self:on_slot_selected(selected_slot)

		if selected_slot then
			return
		end
	end

	if self._rename_info_text then
		local text_button = self._info_texts and self._info_texts[self._rename_info_text]

		if self._slot_data and text_button and text_button:inside(x, y) then
			if managers.menu:is_steam_controller() then
				self:rename_item_with_gamepad_callback(self._slot_data)
			else
				local category = self._slot_data.category
				local slot = self._slot_data.slot

				self:_start_rename_item(category, slot)
			end

			return
		end
	end

	if self._btns[self._button_highlighted] and self._btns[self._button_highlighted]:inside(x, y) then
		local data = self._btns[self._button_highlighted]._data

		if data.callback and (not self._button_press_delay or self._button_press_delay < TimerManager:main():time()) then
			managers.menu_component:post_event("menu_enter")
			data.callback(self._slot_data, self._data.topic_params)

			self._button_press_delay = TimerManager:main():time() + 0.2
		end
	end

	if self._selected_slot and self._selected_slot._equipped_rect then
		self._selected_slot._equipped_rect:set_alpha(0.6)
	end

	if _G.IS_VR and button == Idstring("0") and self._selected_slot._panel:inside(x, y) then
		self:press_first_btn(button)
	end
end
