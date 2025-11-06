SavefileManager.PROGRESS_SLOT = 50
SavefileManager.BACKUP_SLOT = 50



function SavefileManager:_load_done(slot, cache_only, wrong_user, wrong_version)
	cat_print("savefile_manager", "[SavefileManager:_load_done]", slot, cache_only, wrong_user, wrong_version)

	local is_setting_slot = slot == self.SETTING_SLOT
	local is_progress_slot = slot == self.PROGRESS_SLOT
	local meta_data = self:_meta_data(slot)
	local success = meta_data.cache ~= nil

	cat_print("savefile_manager", "[SavefileManager] Done loading slot \"" .. tostring(slot) .. "\". Success: \"" .. tostring(success) .. "\".")

	if not cache_only then
		self:_set_corrupt(slot, not success)
		self:_set_synched_cache(slot, success)
	end

	if self._backup_data and is_progress_slot then
		local meta_data = self:_meta_data(slot)
		local cache = meta_data.cache

		if cache and managers.experience:chk_ask_use_backup(cache, self._backup_data.save_data.data) then
			self:_ask_load_backup("low_progress", true, {
				cache_only,
				wrong_user
			})

			return
		end
	end

	--[[if self._vr_progress_data and is_progress_slot then
		local meta_data = self:_meta_data(slot)
		local cache = meta_data.cache

		if cache and managers.experience:chk_ask_use_backup(cache, self._vr_progress_data.save_data.data) then
            managers.mission._fading_debug_output:script().log(tostring(managers.experience:chk_ask_use_backup(cache, self._vr_progress_data.save_data.data)), Color.white)

			self:_ask_load_vr_progress(true, {
				cache_only,
				wrong_user
			})

			return
		end
	end]]

	local req_version = self:_load_cache(slot)
	success = req_version == nil and success or false

	self._load_done_callback_handler:dispatch(slot, success, is_setting_slot, cache_only)

	if not success and wrong_user then
		if not self._queued_wrong_user then
			self._queued_wrong_user = true

			managers.menu:show_savefile_wrong_user()
		end

		self._save_slots_to_load[slot] = nil
	elseif not success then
		self._try_again = self._try_again or {}
		local dialog_data = {
			title = managers.localization:text("dialog_error_title")
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		if is_setting_slot or is_progress_slot then
			local at_init = false
			local error_msg = is_setting_slot and "dialog_fail_load_setting_" or is_progress_slot and "dialog_fail_load_progress_"
			error_msg = error_msg .. (req_version == nil and "corrupt" or "wrong_version")

			cat_print("savefile_manager", "ERROR: ", error_msg)

			if not self._try_again[slot] then
				local yes_button = {
					text = managers.localization:text("dialog_yes")
				}
				local no_button = {
					text = managers.localization:text("dialog_no")
				}
				dialog_data.button_list = {
					yes_button,
					no_button
				}
				dialog_data.id = "savefile_try_again"
				dialog_data.text = managers.localization:text(error_msg .. "_retry", {
					VERSION = req_version
				})

				if is_setting_slot then
					function yes_button.callback_func()
						self:load_settings()
					end
				elseif is_progress_slot then
					function yes_button.callback_func()
						self:load_progress()
					end
				end

				function no_button.callback_func()
					if is_progress_slot and self._backup_data then
						self:_ask_load_backup("progress_" .. (req_version == nil and "corrupt" or "wrong_version"), false)

						return
					else
						local rem_dialog_data = {
							title = managers.localization:text("dialog_error_title"),
							text = managers.localization:text(error_msg, {
								VERSION = req_version
							})
						}
						local ok_button = {
							text = managers.localization:text("dialog_ok"),
							callback_func = function ()
								self:_remove(slot)
							end
						}
						rem_dialog_data.button_list = {
							ok_button
						}

						managers.system_menu:show(rem_dialog_data)
					end
				end

				self._try_again[slot] = true
			else
				at_init = false

				if is_progress_slot and self._backup_data then
					self:_ask_load_backup("progress_" .. (req_version == nil and "corrupt" or "wrong_version"), false)

					return
				else
					dialog_data.text = managers.localization:text(error_msg, {
						VERSION = req_version
					})
					dialog_data.id = "savefile_new_safefile"

					function ok_button.callback_func()
						self:_remove(slot)
					end
				end
			end

			if at_init then
				managers.system_menu:add_init_show(dialog_data)
			else
				managers.system_menu:show(dialog_data)
			end

			return
		end

		dialog_data.text = managers.localization:text("dialog_fail_load_game_corrupt")

		managers.system_menu:add_init_show(dialog_data)
	elseif wrong_user then
		Global.savefile_manager.progress_wrong_user = true
		self._save_slots_to_load[slot] = nil

		if not self._queued_wrong_user then
			self._queued_wrong_user = true
			local dialog_data = {
				title = managers.localization:text("dialog_information_title"),
				text = managers.localization:text("dialog_load_wrong_user"),
				id = "wrong_user"
			}
			local ok_button = {
				text = managers.localization:text("dialog_ok")
			}
			dialog_data.button_list = {
				ok_button
			}

			managers.system_menu:add_init_show(dialog_data)
		end
	else
		self._save_slots_to_load[slot] = nil
	end
end