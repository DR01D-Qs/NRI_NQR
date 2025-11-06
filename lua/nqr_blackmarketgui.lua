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
			local base_min = stats_data.min_damage * tweak_data.gui.stats_present_multiplier
			local base_max = stats_data.max_damage * tweak_data.gui.stats_present_multiplier
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
				value = (base + mod) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = (base_stats[stat.name].value + managers.player:body_armor_skill_addend(name) * tweak_data.gui.stats_present_multiplier) * managers.player:body_armor_skill_multiplier(name) - base_stats[stat.name].value
			}
		elseif stat.name == "health" then
			local base = tweak_data.player.damage.HEALTH_INIT
			local mod = managers.player:health_skill_addend()
			base_stats[stat.name] = {
				value = (base + mod) * tweak_data.gui.stats_present_multiplier
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
				value = (base_value + mod_value) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = skill_value * tweak_data.gui.stats_present_multiplier
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
	local part_is_from_cosmetic, mod_tweak, dlc_global_value, dlc_global_value_tweak, dlc_unlock_id, is_dlc_unlocked = nil
	local guis_catalog = "guis/"
	local index = 1

	for i, mod_t in ipairs(data.on_create_data) do
		local mod_name = mod_t[1]
		local mod_default = mod_t[2]
		local mod_global_value = mod_t[3] or "normal"
		part_is_from_cosmetic = cosmetic_kit_mod == mod_name
		mod_tweak = tweak_data.blackmarket.weapon_mods[mod_name]
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
		new_data.unlocked = not crafted.customize_locked and part_is_from_cosmetic and 1 or mod_default or managers.blackmarket:get_item_amount(new_data.global_value, "weapon_mods", new_data.name, true)
		new_data.equipped = false
		new_data.stream = true
		new_data.default_mod = default_mod
		new_data.cosmetic_kit_mod = cosmetic_kit_mod
		new_data.is_internal = tweak_data.weapon.factory:is_part_internal(new_data.name)
		new_data.free_of_charge = part_is_from_cosmetic or mod_tweak and mod_tweak.is_a_unlockable
		new_data.unlock_tracker = achievement_tracker[new_data.name] or false
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
				gadget = sub_type
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

				--[[mod_stats.chosen["damage"] = WeaponDescription.get_energy(
					total_mods_stats["cartridge"].value~=0 and total_mods_stats["cartridge"].value or total_base_stats["cartridge"].value,
					total_mods_stats["barrel_length"].value~=0 and total_mods_stats["barrel_length"].value or total_base_stats["barrel_length"].value
				) / 40 * 10
				mod_stats.chosen["spread"] = WeaponDescription.get_spread(
					total_mods_stats["cartridge"].value~=0 and total_mods_stats["cartridge"].value or total_base_stats["cartridge"].value,
					total_mods_stats["barrel_length"].value~=0 and total_mods_stats["barrel_length"].value or total_base_stats["barrel_length"].value,
					action_factor_spread
				)
				mod_stats.chosen["recoil"] = WeaponDescription.get_recoil(
					total_mods_stats["cartridge"].value~=0 and total_mods_stats["cartridge"].value or total_base_stats["cartridge"].value,
					total_mods_stats["barrel_length"].value~=0 and total_mods_stats["barrel_length"].value or total_base_stats["barrel_length"].value,
					total_base_stats["weight"].value+total_mods_stats["weight"].value,
					wep_tweak.rise_factor, action_factor_recoil, secondary_factor
				)]]
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
				chosen_to_draw = (type(chosen)=="number" or type(chosen)=="number") and (chosen==0 and "" or (chosen>0 and (stat.override and "=" or "+") or "")..format_round(chosen, stat.round_value)) or format_round(chosen, stat.round_value)

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

				local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(self._slot_data.name, factory_id, default_blueprint)
				local csc = nil
				if part_data and part_data.type=="magazine" and stat.name=="magazine" then csc = true end
				equip_to_draw = (type(equip)=="number" or type(equip)=="number") and (equip==0 and "" or (equip>0 and ((stat.override or csc) and "=" or "+") or "")..format_round(equip, stat.round_value)) or format_round(equip, stat.round_value)
				chosen_to_draw = (type(chosen)=="number" or type(chosen)=="number") and (chosen==0 and "" or (chosen>0 and ((stat.override or csc) and "=" or "+") or "")..format_round(chosen, stat.round_value)) or format_round(chosen, stat.round_value)

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