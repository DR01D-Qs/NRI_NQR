local melee_vars = {
	"player_melee",
	"player_melee_var2"
}
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize

local mvec_pos_new = Vector3()
local mvec_achieved_walk_vel = Vector3()
local mvec_move_dir_normalized = Vector3()

function PlayerStandard:get_animation(anim)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	if anim=="unequip" and wep_tweak.anim_unequip_swap then
		self:_play_running_enter_anim(managers.player:player_timer():time()) return Idstring("")
	elseif anim=="equip" then
		anim = wep_tweak.anim_equip_swap or anim
	end

	return PlayerStandard._current_anim_state[2][anim] or PlayerStandard.ANIM_STATES.standard[anim]
end

function math.rot_to_vec(rot)
	return math.string_to_vector(CoreMath.rotation_to_string(deep_clone(rot)))
end

--INSPECT: SHOW STATS
function PlayerStandard:_check_action_cash_inspect(t, input)
	if not input.btn_cash_inspect_press then return end
	local action_forbidden = self:_interacting()
	or self:is_deploying()
	or self:_changing_weapon()
	or self:_is_throwing_projectile()
	or self:_is_meleeing()
	or self:_on_zipline()
	or self:running()
	or self:_is_reloading()
	or self:in_steelsight()
	or self:is_equipping()
	or self:shooting()
	or self:_is_cash_inspecting(t)
	or not self._movement_equipped
	or not self._wall_equipped
	if action_forbidden then return end

	self._ext_camera:play_redirect(self:get_animation("cash_inspect"), 1.6)
	managers.player:send_message(Message.OnCashInspectWeapon)

	local wep_base = self._equipped_unit:base()
	--managers.mission._fading_debug_output:script().log(tostring("Noise: ")..tostring(wep_base._alert_size),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Shouldered: ")..tostring(wep_base._current_stats.shouldered),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Magazine Weight: ")..tostring(wep_base._current_stats.mag_weight*0.1)..tostring(" Kg"),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Fire rate: ")..tostring(math.round(60/(wep_base:weapon_fire_rate()/wep_base:fire_rate_multiplier())))..tostring(" RPM"),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Kick: ")..tostring(wep_base._kick),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Rise: ")..tostring(wep_base._recoil),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Spread: ")..tostring(wep_base._spread),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Penetration: ")..tostring(wep_base._penetration),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Damage: ")..tostring(math.round(wep_base._damage)),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Barrel: ")..tostring(wep_base._barrel_length)..tostring(" inches"),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Ammo Type: ")..tostring(wep_base._ammotype),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Caliber: ")..tostring(wep_base._caliber),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Length: ")..tostring(wep_base._length),  Color.white)
	managers.mission._fading_debug_output:script().log(tostring("Weight: ")..tostring(wep_base._current_stats.weight*0.1)..tostring(" Kg"),  Color.white)
	if wep_base.chamber_state then managers.mission._fading_debug_output:script().log(tostring(wep_base.chamber_state==0 and "EMPTY" or wep_base.chamber_state==-1 and "SPENT CASING IN THE")..tostring(" CHAMBER"),  Color.white) end
	managers.mission._fading_debug_output:script().log(tostring("---STATS---"),  Color.red)
end



--MOVEMENT UNEQUIP INIT
function PlayerStandard:init(unit)
	PlayerMovementState.init(self, unit)

	self._tweak_data = tweak_data.player.movement_state.standard
	self._obj_com = self._unit:get_object(Idstring("rp_mover"))
	local slot_manager = managers.slot
	self._slotmask_gnd_ray = World:make_slot_mask(1, 8, 11, 15, 39) --8 shields, 12 enemies
	self._slotmask_fwd_ray = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_foley_ray = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_bullet_impact_targets = slot_manager:get_mask("bullet_impact_targets")
	self._slotmask_bullet_impact_targets = managers.mutators:modify_value("PlayerStandard:modify_melee_slot_mask", self._slotmask_bullet_impact_targets)
	self._slotmask_pickups = slot_manager:get_mask("pickups")
	self._slotmask_AI_visibility = slot_manager:get_mask("AI_visibility")
	self._slotmask_long_distance_interaction = slot_manager:get_mask("long_distance_interaction")
	self._ext_camera = unit:camera()
	self._ext_movement = unit:movement()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._ext_anim = unit:anim_data()
	self._ext_network = unit:network()
	self._ext_event_listener = unit:event_listener()
	self._camera_unit = self._ext_camera._camera_unit
	self._camera_unit_anim_data = self._camera_unit:anim_data()
	self._machine = unit:anim_state_machine()
	self._m_pos = self._ext_movement:m_pos()
	self._pos = Vector3()
	self._stick_move = Vector3()
	self._stick_look = Vector3()
	self._cam_fwd_flat = Vector3()
	self._walk_release_t = -100
	self._last_sent_pos = unit:position()
	self._last_sent_pos_t = 0
	self._state_data = unit:movement()._state_data
	local pm = managers.player
	self.RUN_AND_RELOAD = pm:has_category_upgrade("player", "run_and_reload")
	self._pickup_area = 200 * pm:upgrade_value("player", "increased_pickup_area", 1)

	self:set_animation_state("standard")

	self._interaction = managers.interaction
	self._on_melee_restart_drill = pm:has_category_upgrade("player", "drill_melee_hit_restart_chance")
	local controller = unit:base():controller()

	if controller:get_type() ~= "pc" and controller:get_type() ~= "vr" then
		self._input = {}

		table.insert(self._input, BipodDeployControllerInput:new())

		if pm:has_category_upgrade("player", "second_deployable") then
			table.insert(self._input, SecondDeployableControllerInput:new())
		end
	end

	self._input = self._input or {}

	table.insert(self._input, HoldButtonMetaInput:new("night_vision", "weapon_firemode", nil, 0.5))

	self._menu_closed_fire_cooldown = 0

	managers.menu:add_active_changed_callback(callback(self, self, "_on_menu_active_changed"))



	self._movement_equipped = true
	self._wall_equipped = true

	self._recoil_kick = { h = {} }

	self.nqr_offset = 0

	self._ext_camera:set_shaker_parameter("breathing", "frequency", 1.2)

	self._unit:mover():set_gravity(Vector3(0, 0, -(982*2)))
    tweak_data.player.movement_state.standard.movement.jump_velocity.z = 700

	local data = tweak_data.blackmarket.projectiles["concussion"]
	if data then
		local unit_name = Idstring(not Network:is_server() and data.local_unit or data.unit)
		if not managers.dyn_resource:is_resource_ready(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
			managers.dyn_resource:load(Idstring("unit"), unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
		end
	end
end
--ENTER: CHECK LYING TILT
function PlayerStandard:enter(state_data, enter_data)
	PlayerMovementState.enter(self, state_data, enter_data)
	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)

	self._state_data = state_data
	self._unit:camera():camera_unit():base():set_target_tilt(self._state_data.lying and 15 or 0)
	self._state_data.using_bipod = managers.player:current_state() == "bipod"
	self._equipped_unit = self._ext_inventory:equipped_unit()
	local weapon = self._ext_inventory:equipped_unit()
	self._weapon_hold = weapon and weapon:base().weapon_hold and weapon:base():weapon_hold() or weapon:base():get_name_id()
	--self._weapon_hold_orig = self._weapon_hold

	self:inventory_clbk_listener(self._unit, "equip")
	self:_enter(enter_data)
	self:_update_ground_ray()

	self._controller = self._unit:base():controller()

	if not self._unit:mover() then
		self:_activate_mover(PlayerStandard.MOVER_STAND)
	end

	if not _G.IS_VR and (enter_data and enter_data.wants_crouch or not self:_can_stand()) and not self._state_data.ducking then
		self:_start_action_ducking(managers.player:player_timer():time())
	end

	self._ext_camera:clbk_fp_enter(self._unit:rotation():y())

	if self._ext_movement:nav_tracker() then
		self._pos_reservation = {
			radius = 100,
			position = self._ext_movement:m_pos(),
			filter = self._ext_movement:pos_rsrv_id()
		}
		self._pos_reservation_slow = {
			radius = 100,
			position = mvector3.copy(self._ext_movement:m_pos()),
			filter = self._ext_movement:pos_rsrv_id()
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)
		managers.navigation:add_pos_reservation(self._pos_reservation_slow)
	end

	for _, data in ipairs(self._ext_inventory._available_selections) do
		local unit = data.unit

		managers.hud:set_ammo_amount(unit:base():selection_index(), unit:base():ammo_info())
	end

	if enter_data and enter_data.equip_weapon then
		self:_start_action_unequip_weapon(managers.player:player_timer():time(), {
			selection_wanted = enter_data.equip_weapon
		})
	end

	if enter_data then
		self._change_weapon_data = enter_data.change_weapon_data or self._change_weapon_data
		self._unequip_weapon_expire_t = enter_data.unequip_weapon_expire_t or self._unequip_weapon_expire_t
		self._unequip_weapon_expire_t0 = enter_data.unequip_weapon_expire_t0 or self._unequip_weapon_expire_t0
		self._equip_weapon_expire_t = enter_data.equip_weapon_expire_t or self._equip_weapon_expire_t
		self._equip_weapon_expire_t0 = enter_data.equip_weapon_expire_t0 or self._equip_weapon_expire_t0
		if enter_data.equip_at_enter then self:_start_action_equip_weapon(managers.player:player_timer():time()) end
	end

	self:_reset_delay_action()

	self._last_velocity_xy = Vector3()
	self._last_sent_pos_t = enter_data and enter_data.last_sent_pos_t or managers.player:player_timer():time()
	self._last_sent_pos = enter_data and enter_data.last_sent_pos or mvector3.copy(self._pos)
	self._gnd_ray = true
	local slow_mul, prevents_running = self._ext_damage:get_current_slowdown()
	self._slowdown_mul = slow_mul ~= 1 and slow_mul or nil
	self._slowdown_run_prevent = slow_mul and prevents_running or false
end
function PlayerStandard:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end

	if self._ext_movement:nav_tracker() then
		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	self._equipping_mask = nil
	local skip_equip = enter_data and enter_data.skip_equip
	local skip_mask_anim = enter_data and enter_data.skip_mask_anim

	if not self:_changing_weapon() and not skip_equip then
		if not self._state_data.mask_equipped then
			self._state_data.mask_equipped = true

			if not skip_mask_anim then
				self._equipping_mask = true
				local equipped_mask = managers.blackmarket:equipped_mask()
				local peer_id = managers.network:session() and managers.network:session():local_peer():id()
				local mask_id = managers.blackmarket:get_real_mask_id(equipped_mask.mask_id, peer_id)
				local equipped_mask_type = tweak_data.blackmarket.masks[mask_id].type

				self._camera_unit:anim_state_machine():set_global((equipped_mask_type or "mask") .. "_equip", 1)
				self:_start_action_equip(self:get_animation("mask_equip"), 1.6)
			end
		else
			self:_start_action_equip(self:get_animation("equip"))
			self._ext_inventory:show_equipped_unit()
		end
	end

	if self._ext_movement:nav_tracker() then
		self._standing_nav_seg_id = self._ext_movement:nav_tracker():nav_segment()
		local metadata = managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id)
		local location_id = metadata.location_id

		managers.hud:set_player_location(location_id)
		self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
		self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
	end

	self._ext_inventory:set_mask_visibility(true)
	self:_upd_attention()
	self._ext_network:send("set_stance", 3, false, false)
end
--UPDATE: SLIDE LOCK THING, INTERUPTED RELOAD OFFSET, OFFSET RECOIL CHECK, BREATH SHAKER DYNAMIC
function PlayerStandard:update(t, dt)
	PlayerMovementState.update(self, t, dt)
	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_update_check_actions(t, dt)

	local wep_base = self._equipped_unit:base()
	if wep_base then wep_base.angular_recoil = self:_vertical_recoil_kick(t, dt) end

	if self._menu_closed_fire_cooldown > 0 then
		self._menu_closed_fire_cooldown = self._menu_closed_fire_cooldown - dt
	end

	self:_update_movement(t, dt)
	self:_upd_nav_data()
	managers.hud:_update_crosshair_offset(t, dt)
	self:_update_omniscience(t, dt)
	self:_upd_stance_switch_delay(t, dt)
	wep_base:update_bolting(t)

	if not wep_base then return end
	local wep_tweak = wep_base:weapon_tweak_data()
	local no_lock =
		wep_tweak.anim_without_lockback
		or (wep_tweak.bolt_release=="none" and wep_tweak.feed_system~="break_action")
		or wep_tweak.action=="pump_action"
		or wep_tweak.action=="lever_action"
		or wep_tweak.action=="bolt_action"
		or wep_tweak.action=="gatling"
		or wep_base.shot_without_mag
	--local last_round = wep_base:ammo_base():get_ammo_remaining_in_clip()<=(wep_base.AKIMBO and 1 or 0)

	if not self:_is_reloading() then
		if ((not no_lock) or wep_base.delayed_t1==-1)
		and not wep_base:is_category("revolver")
		and not wep_tweak.dao
		and not wep_tweak.dao_delayed
		--and not wep_tweak.feed_system=="ejecting_mag"
		--and not wep_base.r_offset
		then
			local offset = wep_tweak.feed_system=="tube_fed" and 2/30 or 1/30
			local reload_anim = wep_tweak.feed_system=="tube_fed" and "fire" or "reload"

			if wep_base.AKIMBO and wep_base:ammo_base():get_ammo_remaining_in_clip()==1 then
				wep_base:tweak_data_anim_stop("fire")
				wep_base:tweak_data_anim_pause("reload_left", offset, not wep_base._fire_second_gun_next)
			elseif wep_base:ammo_base():get_ammo_remaining_in_clip()==0 then
				wep_base:tweak_data_anim_stop("fire")
				wep_base:tweak_data_anim_stop(reload_anim)
				wep_base:tweak_data_anim_stop("reload_left")
				wep_base:tweak_data_anim_pause(reload_anim, offset)
				wep_base:tweak_data_anim_pause("reload_left", offset, true)
			end
		end

		if wep_base.r_offset and (table.contains(wep_base.r_cycle or {}, "r_bolt_release_1") or wep_tweak.feed_system=="ejecting_mag") then
			local offset = wep_base.r_offset
			local reload_anim = wep_base:use_shotgun_reload() and "reload_enter" or wep_base.r_not_empty and "reload_not_empty" or "reload"
			wep_base:tweak_data_anim_stop("fire")
			wep_base:tweak_data_anim_stop("reload")
			wep_base:tweak_data_anim_stop("reload_left")
			wep_base:tweak_data_anim_play(reload_anim, 1, offset, true)
		elseif wep_base:is_category("revolver") then
			if wep_base.delayed_t1==0 then
				wep_base:tweak_data_anim_play("fire", 1, 0.05, true)
			elseif wep_tweak.sao and not self._cock_t and not wep_base.delayed_t1 and not wep_base.delayed_t2 then
				wep_base:tweak_data_anim_stop("fire")
			end
		--elseif wep_base._bolting_interupted then
		elseif wep_base._bolting_interupted and wep_base.chamber_state then
			local offset = wep_base._is_bolting==2 and wep_base:weapon_fire_rate()*0.5 or 0.1
			wep_base:tweak_data_anim_play("fire", 1, offset, true)
		end
	end

	--managers.mission._fading_debug_output:script().log(tostring(self._controller:get_input_pressed("nqr_key_stocktoggle")), Color.white)

	local weight = wep_base._current_stats.weight or 10
	local shouldered = wep_base._current_stats.shouldered
	local weight_mod = (0.1 + (weight/200/(shouldered and 3 or 1)))
	local crouched_mod = self._camera_unit:base()._head_stance.translation.z/145
	local shake = (1 + ((75 - (self._ext_movement.stamina_breath or 75)) * 0.008))

	self._ext_camera:set_shaker_parameter("breathing", "amplitude", shake * 0.5 * crouched_mod * weight_mod)

	self._initial_shake = self._initial_shake or shake
	self._breath_offset = (self._breath_offset or self._initial_shake) + ((shake - self._initial_shake) * 4 * dt)
	self._ext_camera:set_shaker_parameter("breathing", "offset", self._breath_offset)
end

function PlayerStandard:exit(state_data, new_state_name)
	PlayerMovementState.exit(self, state_data)
	tweak_data:remove_reload_callback(self)
	self:_interupt_action_interact()
	self:_interupt_action_use_item()
	managers.environment_controller:set_dof_distance()

	if new_state_name=="driving" then self:_interupt_changing_weapon() end

	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)
		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation = nil
		self._pos_reservation_slow = nil
	end

	if self._running then
		self:_end_action_running(managers.player:player_timer():time())
		self:set_running(false)
	end

	if self._shooting then
		self._camera_unit:base():stop_shooting()
		self:_check_stop_shooting()
	end

	self._headbob = 0
	self._target_headbob = 0

	self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)


	local exit_data = {
		skip_equip = true,
		last_sent_pos_t = self._last_sent_pos_t,
		last_sent_pos = self._last_sent_pos,
		ducking = self._state_data.ducking,
		change_weapon_data = self._change_weapon_data,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t,
		unequip_weapon_expire_t0 = self._unequip_weapon_expire_t0,
		equip_weapon_expire_t = self._equip_weapon_expire_t,
		equip_weapon_expire_t0 = self._equip_weapon_expire_t0,
	}
	self._state_data.using_bipod = managers.player:current_state() == "bipod"

	self:_update_network_jump(nil, true)

	self._state_data.previous_state = "standard"

	return exit_data
end



--CHECK SWITCH: BOLTING INTERUPT, IS SHOOTING CHECK
function PlayerStandard:_check_change_weapon(t, input)
	local new_action = nil
	local action_wanted = input.btn_switch_weapon_press

	if action_wanted then
		local action_forbidden = nil --self._unequip_weapon_expire_t --self:_changing_weapon()
		action_forbidden =
		action_forbidden
		or self:_is_meleeing()
		or self._use_item_expire_t
		or self._change_item_expire_t
		action_forbidden =
		action_forbidden
		or self._unit:inventory():num_selections() == 1
		or self:_interacting()
		or self:_is_throwing_projectile()
		or self:_is_deploying_bipod()
		or (not self._movement_equipped and self._move_dir)
		action_forbidden =
		action_forbidden
		or self:is_shooting_count()
		or self:shooting()

		if not action_forbidden then
			local data = {
				next = true
			}
			self._change_weapon_pressed_expire_t = t + 0.33

			self:_start_action_unequip_weapon(t, data)
			local wep_base = self._equipped_unit:base()

			new_action = true

			managers.player:send_message(Message.OnSwitchWeapon)
		end
	end

	return new_action
end
function PlayerStandard:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice
	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip")
		action_forbidden = action_forbidden
		or not self._ext_inventory:is_selection_available(selection_wanted)
		or self:_is_meleeing()
		or self._use_item_expire_t
		or self:_interacting()
		or self:_is_throwing_projectile()
		or (not self._movement_equipped and self._move_dir)

		if not action_forbidden then
			if not self._ext_inventory:is_equipped(selection_wanted) and not self._unequip_weapon_expire_t then
				self:_start_action_unequip_weapon(t, { selection_wanted = selection_wanted })
				local wep_base = self._equipped_unit:base()
			elseif self._ext_inventory:is_equipped(selection_wanted) and self._unequip_weapon_expire_t then
				self:_start_action_equip_weapon0(t)
				local wep_base = self._equipped_unit:base()
			end
		end
	end

	return new_action
end

--SWAP SPEED MULTIPLIER: -
function PlayerStandard:_get_swap_speed_multiplier()
	local multiplier = 1
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	return multiplier
end
function PlayerStandard:nqr_eq_speed(is_unequip)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local wep_length = wep_base._length
	local wep_weight = wep_base._current_stats.weight
	local length_pnlt = (math.max(0, wep_length*0.025 - 0.15))
	local weight_pnlt = wep_base:selection_index()==1 and (math.max(0, (wep_weight*0.015)^1)-0.1 + length_pnlt*0.5) or ((math.max(0, wep_weight-20)*0.005)^0.8 + length_pnlt*0.2)
	local eq_t = (wep_base._current_stats.shouldered and 0.4 or 0.2) + (is_unequip and 0 or (weight_pnlt))
	local eq_tt = (
		wep_base:selection_index()==1 and not (self._change_weapon_data and self._change_weapon_data.reequip)
		and (length_pnlt + (is_unequip and 0.5 or 0.3) + (wep_base._current_stats.shouldered and 0.5 or 0))
		or 0
	)
	local anim_spd = 1
	local eq_fr = wep_tweak.eq_fr or {0,20,20}
	local eq_t1 = (eq_fr[2] - eq_fr[1]) /30
	local eq_t2 = (eq_fr[3]) /30
	anim_spd = ((is_unequip and eq_t2 or eq_t1) / eq_t)

	return eq_t, eq_tt, anim_spd
end
function PlayerStandard:_start_action_unequip_weapon(t, data, mul)
	self._change_weapon_data = data
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local speed_multiplier = self:_get_swap_speed_multiplier() * (mul or 1)
	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed(true)
	eq_t = (eq_t or 0.5) / speed_multiplier
	eq_tt = (eq_tt or 0) / speed_multiplier
	anim_spd = (anim_spd or 1) * speed_multiplier

	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self._running_enter_end_t = nil

	wep_base:tweak_data_anim_stop(wep_tweak.anim_equip_swap or "equip")
	wep_base:tweak_data_anim_play(wep_tweak.anim_unequip_swap or "unequip", anim_spd)

	self._unequip_weapon_expire_t = t + eq_t + eq_tt
	if eq_tt~=0 then self._unequip_weapon_expire_t0 = t + eq_t end
	--self._unequip_weapon_expire_t = t + (wep_tweak.timers.unequip or 0.5) / speed_multiplier

	if not self._equip_weapon_expire_t0 then
		self._ext_camera:play_redirect(self:get_animation("unequip"), anim_spd)
	else
		self._unequip_weapon_expire_t = 0
	end

	self._equip_weapon_expire_t = nil
	self._equip_weapon_expire_t0 = nil

	self._ext_network:send("switch_weapon", (wep_tweak.timers.unequip / eq_t) * speed_multiplier, 1)
end
function PlayerStandard:_start_action_equip_weapon(t)
	self._unequip_weapon_expire_t = nil
	self._unequip_weapon_expire_t0 = nil

	self._change_weapon_data = self._change_weapon_data or { next = false }
	if self._change_weapon_data.next then
		local next_equip = self._ext_inventory:get_next_selection()
		next_equip = next_equip and next_equip.unit
		if next_equip then self:set_animation_state(self:_is_underbarrel_attachment_active(next_equip) and "underbarrel" or "standard") end
		self._ext_inventory:equip_next(false)
	elseif self._change_weapon_data.previous then
		local prev_equip = self._ext_inventory:get_previous_selection()
		prev_equip = prev_equip and next_equip.unit
		if prev_equip then self:set_animation_state(self:_is_underbarrel_attachment_active(prev_equip) and "underbarrel" or "standard") end
		self._ext_inventory:equip_previous(false)
	elseif self._change_weapon_data.selection_wanted then
		local select_equip = self._ext_inventory:get_selected(self._change_weapon_data.selection_wanted)
		select_equip = select_equip and select_equip.unit
		if select_equip then self:set_animation_state(self:_is_underbarrel_attachment_active(select_equip) and "underbarrel" or "standard") end
		self._ext_inventory:equip_selection(self._change_weapon_data.selection_wanted, false)
	end
	self:set_animation_weapon_hold(nil)

	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
	eq_t = (eq_t or 0.5) / speed_multiplier
	anim_spd = (anim_spd or 1) * speed_multiplier

	self._equip_weapon_expire_t0 = t + eq_tt
	self._equip_weapon_expire_t = t + eq_tt + eq_t

	managers.upgrades:setup_current_weapon()
	self:_stance_entered()
	self._change_weapon_data = nil
end
function PlayerStandard:_start_action_equip_weapon0(t)
	self._unequip_weapon_expire_t = nil
	self._unequip_weapon_expire_t0 = nil
	self._running_enter_end_t = nil

	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
	anim_spd = (anim_spd or 1) / speed_multiplier

	self._equip_weapon_expire_t = t + eq_t

	self:_stance_entered()
	self._camera_unit:base():show_weapon()

	self._ext_camera:play_redirect(self:get_animation("equip"), anim_spd, (wep_tweak.eq_fr and wep_tweak.eq_fr[1] or 0)/30)
	wep_base:tweak_data_anim_stop(wep_tweak.anim_unequip_swap or "unequip")
	wep_base:tweak_data_anim_play(wep_tweak.anim_equip_swap or "equip", anim_spd, (wep_tweak.eq_fr and wep_tweak.eq_fr[1] or 0)/30)
end
function PlayerStandard:_start_action_equip(redirect, extra_time)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
	eq_t = (eq_t or 0.5) / speed_multiplier
	anim_spd = (anim_spd or 1) / speed_multiplier

	self._equip_weapon_expire_t = managers.player:player_timer():time() + eq_t + (extra_time or 0)

	if redirect == self:get_animation("equip") then
		wep_base:tweak_data_anim_stop("unequip")
		wep_base:tweak_data_anim_play("equip", anim_spd)
	end

	local result = self._ext_camera:play_redirect(redirect or self:get_animation("equip"))
end
function PlayerStandard:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_press

	if action_wanted then
		local action_forbidden =
		self._use_item_expire_t
		or self:_interacting()
		--or self:_changing_weapon()
		or self:_is_throwing_projectile()
		or self:_is_meleeing()
		or not self._movement_equipped
		--or not self._wall_equipped

		if not action_forbidden and managers.player:can_use_selected_equipment(self._unit) then
			self:_start_action_use_item(t)

			new_action = true
		end
	end

	if input.btn_use_item_release then
		self:_interupt_action_use_item()
	end

	return new_action
end
function PlayerStandard:_start_action_use_item(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self._running_enter_end_t = nil
	self._running_exit_start_t = nil

	if not self._unequip_weapon_expire_t then self:_start_action_unequip_weapon(t) end

	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed(true)
	local deploy_timer = managers.player:selected_equipment_deploy_timer() + (self._equip_weapon_expire_t0 and 0 or (eq_t + eq_tt))
	self._use_item_expire_t = t + deploy_timer
	managers.hud:show_progress_timer_bar(0, deploy_timer)

	local text = managers.player:selected_equipment_deploying_text() or managers.localization:text("hud_deploying_equipment", {
		EQUIPMENT = managers.player:selected_equipment_name()
	})
	managers.hud:show_progress_timer({ text = text })

	local post_event = managers.player:selected_equipment_sound_start()
	if post_event then self._unit:sound_source():post_event(post_event) end

	local equipment_id = managers.player:selected_equipment_id()
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, true, equipment_id, deploy_timer, false)
end
function PlayerStandard:_interupt_action_use_item(t, input, complete)
	if self._use_item_expire_t then
		t = t or managers.player:player_timer():time()
		self._use_item_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()

		if self._unequip_weapon_expire_t then
			self:_start_action_equip_weapon0(t)
		else
			self:_start_action_equip_weapon(t)
		end

		local post_event = managers.player:selected_equipment_sound_interupt()

		if not complete and post_event then
			self._unit:sound_source():post_event(post_event)
		end

		self._unit:equipment():on_deploy_interupted()
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 2, false, "", 0, complete and true or false)
	end
end
function PlayerStandard:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end

		self._ext_camera:camera_unit():base():remove_limits()
		self._interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)

		self._interact_params = nil

		self:_start_action_equip_weapon(t)
		managers.hud:hide_interaction_bar(complete)
		self._unit:network():send("sync_interaction_anim", false, "")
	end
end
function PlayerStandard:_play_equip_animation(speed_multiplier)
	local wep_tweak = self._equipped_unit:base():weapon_tweak_data()
	self._equip_weapon_expire_t = managers.player:player_timer():time() + (0.4)
	self._ext_camera:play_redirect(self:get_animation("equip"), speed_multiplier)
end
function PlayerStandard:_play_unequip_animation(speed_multiplier)
	local wep_tweak = self._equipped_unit:base():weapon_tweak_data()
	self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)
end

--NEW FUNCTION: REEQUIP FORCED
function PlayerStandard:_nqr_force_reequip(t)
	local t = t or Application:time()
	local wep_base = self._equipped_unit:base()

	self._camera_unit:base():stop_shooting()
	self:stop_shooting()
	self:_check_stop_shooting()
	self:_interupt_action_reload(t)
	self:_interupt_action_running(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_interact(t)
	self:_interupt_action_throw_projectile(t)
	self:_interupt_action_throw_grenade(t)
	self:_interupt_action_ladder(t)

	local speed_multiplier = 2
	self._change_weapon_data = { reequip = true }
	self:_start_action_unequip_weapon(t, {next = false, reequip = true}, speed_multiplier)
end
function PlayerStandard:_update_equip_weapon_timers(t, input)
	local wep_base = self._equipped_unit:base()

	if self._unequip_weapon_expire_t and self._unequip_weapon_expire_t <= t then
		self._unequip_weapon_expire_t = nil

		if self._change_weapon_data and self._change_weapon_data.unequip_callback and not self._change_weapon_data.unequip_callback() then return end

		if not self._equip_weapon_expire_t and not self:_interacting() and not self:is_deploying() then
			self:_start_action_equip_weapon(t)
			if wep_base:selection_index()~=1 then wep_base:play_sound("m4_equip") end
		end
	end
	if self._unequip_weapon_expire_t0 and self._unequip_weapon_expire_t0 <= t then
		self._unequip_weapon_expire_t0 = nil
		wep_base:play_sound("m4_equip")
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil
		self._equipping_mask = nil
		if input.btn_steelsight_state then self._steelsight_wanted = true end
		TestAPIHelper.on_event("load_weapon")
		TestAPIHelper.on_event("mask_up")
	end
	if self._equip_weapon_expire_t0 and self._equip_weapon_expire_t0 <= t then
		self._equip_weapon_expire_t0 = nil
		self:_start_action_equip_weapon0(t)
		if input.btn_steelsight_state then self._steelsight_wanted = true end
		TestAPIHelper.on_event("load_weapon")
		TestAPIHelper.on_event("mask_up")
	end
end
--CHECK ACTION GADGET: RERUN ON GADGET
function PlayerStandard:_check_action_weapon_gadget(t, input)
	local wep_base = self._equipped_unit:base()
	local action_forbidden =
		   self:_interacting()
		or self:is_deploying()
		or self._unequip_weapon_expire_t
		or self:_is_throwing_projectile()
		or self:_is_meleeing()
		or self:_is_reloading()
		or self:_is_using_bipod()
		or self._reequip_on_second_sight
		or (wep_base.next_fire_allowed and wep_base.next_fire_allowed < t)
		or not self._movement_equipped
		or not self._wall_equipped

	if not action_forbidden and input.btn_weapon_gadget_press then
		self:_interupt_action_running(t)

		if self._reequip_gadget_expire_t and self._do_the_thing then
			self:_toggle_gadget(wep_base)
		end

		if (wep_base.toggle_second_sight and self:in_steelsight() and wep_base:has_second_sight() and wep_base:toggle_second_sight(self)) then
			if tweak_data.weapon.factory.parts[wep_base._second_sights[1].part_id].stats.zoom then
				self:_gadget_reequip(t, true)
			else
				self:_toggle_second_sight()
			end
		else
			if wep_base:has_gadget() then
				self:_gadget_reequip(t, false)
			end
		end
	end



	if self._reequip_gadget_expire_t and t >= self._reequip_gadget_expire_t-0.05 then
		if self._do_the_thing then
			if not self._reequip_on_second_sight then
				self:_toggle_gadget(self._equipped_unit:base())
			else
				self:_toggle_second_sight()
				self._reequip_on_second_sight = false
			end

			self._do_the_thing = nil
		end

		if t >= self._reequip_gadget_expire_t then
			self._reequip_gadget_expire_t = nil
			self._ext_camera:play_redirect(self:get_animation("stop_running"), 1.2)
			self._equip_weapon_expire_t = t + 0.2
		end
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil

		TestAPIHelper.on_event("load_weapon")
		TestAPIHelper.on_event("mask_up")
	end
end
--NEW FUNCTION: _GADGET_REEQUIP
function PlayerStandard:_gadget_reequip(t, second_sight)
	if self:shooting() then return end

	self._camera_unit:base():stop_shooting()
	self:stop_shooting()
	self:_check_stop_shooting()
	self:_interupt_action_running(t)
	self:_interupt_action_steelsight(t)

	self._ext_camera:play_redirect(self:get_animation("start_running"), 1.4)

	self._reequip_on_second_sight = second_sight
	self._reequip_gadget_expire_t = t + 0.2
	self._do_the_thing = true
end
--NEW FUNCTION: UPDATE REEQUIP ON GADGET
function PlayerStandard:_update_reequip_gadget_timers(t, input)
	if self._reequip_gadget_expire_t and t >= self._reequip_gadget_expire_t-0.05 then
		if self._do_the_thing then
			if not self._reequip_on_second_sight then
				self:_toggle_gadget(self._equipped_unit:base())
			else
				self:_toggle_second_sight()
				self._reequip_on_second_sight = false
			end

			self._do_the_thing = nil
		end

		if t >= self._reequip_gadget_expire_t then
			self._reequip_gadget_expire_t = nil
			self._ext_camera:play_redirect(self:get_animation("stop_running"), 1.2)
			self._equip_weapon_expire_t = t + 0.2
		end
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil

		TestAPIHelper.on_event("load_weapon")
		TestAPIHelper.on_event("mask_up")
	end
end
--NEW FUNCTION: _TOGGLE_SECOND_SIGHT
function PlayerStandard:_toggle_second_sight()
	local wep_base = self._equipped_unit:base()
	local second_sight_on = wep_base._second_sight_on or 0
	local second_sights = wep_base._second_sights
	local sight_order = NQR.settings.nqr_sight_order==1 and 1 or -1
	if second_sights then
		second_sight_on = (second_sight_on + sight_order) % (#second_sights + 1)
		wep_base:set_second_sight_on(second_sight_on, false, second_sights, self)
	end
end
--IS CHANGING WEAPON: ADD REEQUIP FACTOR
function PlayerStandard:_changing_weapon()
	return self._unequip_weapon_expire_t or self._equip_weapon_expire_t or self._reequip_gadget_expire_t --or self._state_data.interact_redirect_t
end
--UPDATE ACTIONS: REEQUIP ON GADGET CHECK, MOVEMENT UNEQUIP CHECK
function PlayerStandard:_update_check_actions(t, dt, paused)
	local input = self:_get_input(t, dt, paused)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_charging_weapon_timers(t, input)
	self:_update_use_item_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	if self._change_item_expire_t and self._change_item_expire_t <= t then
		self._change_item_expire_t = nil
	end

	if self._change_weapon_pressed_expire_t and self._change_weapon_pressed_expire_t <= t then
		self._change_weapon_pressed_expire_t = nil
	end

	self:_update_steelsight_timers(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	local anim_data = self._ext_anim
	new_action = new_action or self:_check_action_weapon_gadget(t, input)

	if _G.IS_VR then
		new_action = new_action or self:_check_action_deploy_underbarrel(t, input)
	end

	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	self:_check_movement_equipped(t)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not _G.IS_VR and not new_action then
			self:_check_stop_shooting()
		end
	end

	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_use_item(t, input)
	new_action = new_action or self:_check_action_throw_projectile(t, input)
	new_action = new_action or self:_check_action_interact(t, input)

	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)

	if not new_action then
		new_action = self:_check_action_deploy_bipod(t, input)
		new_action = new_action or self:_check_action_deploy_underbarrel(t, input)
	end

	self:_check_action_change_equipment(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
	self:_check_action_night_vision(t, input)
	self:_find_pickups(t)
end
--TOGGLE_GADGET: JUST A COMPAT FIX
function PlayerStandard:_toggle_gadget(wep_base)
	local gadget_index = 0

	if wep_base.toggle_second_sight and self:in_steelsight() and wep_base:has_second_sight() and wep_base:toggle_second_sight(self) then
		return
	end

	if wep_base.toggle_gadget and wep_base:has_gadget() and wep_base:toggle_gadget(self) then
		gadget_index = wep_base:current_gadget_index()

		self._unit:network():send("set_weapon_gadget_state", wep_base._gadget_on)

		local gadget = wep_base:get_active_gadget()

		if gadget and gadget.color then
			local col = gadget:color()

			--self._unit:network():send("set_weapon_gadget_color", col.r * 255, col.g * 255, col.b * 255)
		end

		if alive(self._equipped_unit) then
			managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())
		end

		wep_base._last_gadget_idx = wep_base._gadget_on
	end
end
--CHECK BIPODS: BIPODLESS BIPODS
function PlayerStandard:_check_action_deploy_bipod(t, input)
	local new_action = nil
	local action_forbidden = false

	if not input.btn_deploy_bipod then return end

	action_forbidden =
	self:in_steelsight() or
	self:_on_zipline() or
	self:_is_throwing_projectile() or
	self:_is_meleeing() or
	self:is_equipping() or
	self:_changing_weapon()
	or not self._movement_equipped
	or not self._wall_equipped

	if not action_forbidden then
		local weapon = self._equipped_unit:base()
		local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)
		new_action = true
	end

	return new_action
end
--FORBID FIREMODE ON SOME STUFF
function PlayerStandard:_check_action_weapon_firemode(t, input)
	local action_forbidden = (
		self:is_shooting_count()
		or self:_is_reloading()
		or not self._movement_equipped
		or self._running
		or self:_is_meleeing()
		or self._use_item_expire_t
		or self:_interacting()
		or self:_is_throwing_projectile()
		or self:_is_deploying_bipod()
	)

	if input.btn_weapon_firemode_press and not action_forbidden then
		if self._equipped_unit:base().toggle_firemode then
			self:_check_stop_shooting()

			if self._equipped_unit:base():toggle_firemode() then
				managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, self._unit:inventory():equipped_selection(), self._equipped_unit:base():fire_mode())
			end
		end
	end
end



--PRIMARY FIRE: NO RELOAD ON LMB, NO HIPFIRE ANIM ON ADS, SHAKE SHENANIGANS, UN-ADS FOR BOLTACTIONS, DELAYED FIRE, BOLTING CHECK, DELAYED SHELL EJECTION
function PlayerStandard:_check_action_primary_attack(t, input)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local new_action = nil
	local action_forbidden =
		   self:_is_reloading()
		or self._state_data.reload_exit_expire_t
		or self:_changing_weapon()
		or self._wall_unequip_t
		or self:_is_meleeing()
		or self._use_item_expire_t
		or self:_interacting()
		or self:_is_throwing_projectile()
		or self:_is_deploying_bipod()
		or self._menu_closed_fire_cooldown > 0
		or self:is_switching_stances()
		or self._running
		or self._cock_t
		or (wep_base.r_stage and wep_tweak.mag_safety)
		or (wep_base.r_stage and wep_base:use_shotgun_reload() and not (wep_base.r_cycle and wep_base.r_cycle[#wep_base.r_cycle]=="r_bolt_release_2"))
		or (wep_base.r_stage and wep_base.r_cycle[1]=="r_bolt_release_1" and wep_base.r_cycle[wep_base.r_stage-1]~="r_bolt_release_1" and wep_base.r_cycle[wep_base.r_stage]~="r_bolt_release_2")
		or not self._movement_equipped
		or not self._wall_equipped
	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release
	action_wanted = action_wanted or self:is_shooting_count()
	action_wanted = action_wanted or self:_is_charging_weapon()

	local is_revolver = wep_base:is_category("revolver") or wep_tweak.dao
	local is_openbolt = wep_tweak.open_bolt
	local delayed = is_openbolt or is_revolver
	wep_base.delayed = delayed
	local rof = (wep_base:weapon_fire_rate()/wep_base:fire_rate_multiplier())*(wep_base.AKIMBO and self._shooting and 0.5 or 1)
	if not wep_base.force_fire_t then wep_base.force_fire_t = -1 end

	if not action_forbidden and action_wanted
	and not (wep_base:use_shotgun_reload() and not wep_base.r_stage)
	and wep_base.r_cycle and wep_base.r_cycle[1]=="r_bolt_release_1"
	and (wep_base.r_stage==2 or wep_base.r_stage==#wep_base.r_cycle) then
		wep_base.r_didnt_load = wep_base.r_stage~=#wep_base.r_cycle
		wep_base.r_stage = #wep_base.r_cycle
		if wep_tweak.action=="bolt_action" and self._state_data.in_steelsight then
			self:_interupt_action_steelsight(t)
		end
		self:_start_action_reload(t)
		return
	end

	if (not action_forbidden) and delayed and (wep_base.delayed_t1 or action_wanted) then
		if (not self:shooting() and input.btn_primary_attack_press) or ((self._shooting or self._shooting2) and not self._shooting_started) then
			self._shooting_started = true
			wep_base:dryfire()
		end

		if not wep_base.delayed_t1 and not wep_base.delayed_t2 and not wep_tweak.sao then
			if (wep_base:fire_mode()=="single" and input.btn_primary_attack_press) or (wep_base:fire_mode()~="single" and input.btn_primary_attack_state) then
				if not self._shooting2 then
					self._shooting2 = true
					wep_base.force_fire_t = math.max(wep_base.force_fire_t, t)
				end

				wep_base.force_fire_t = wep_base.force_fire_t + rof
				rof = (wep_base.force_fire_t - t)
				wep_base.delayed_t1 = t + rof*0.5
				wep_base:tweak_data_anim_play((wep_tweak.anim_shoot_stop or wep_tweak.dao_delayed) and "" or "fire", wep_tweak.bolt_speed or 1)
				wep_base._fire_second_gun_next = not wep_base._fire_second_gun_next
			end
		end

		if wep_base.delayed_t1 and t>=wep_base.delayed_t1 and wep_base.delayed_t1~=-1 then
			if not wep_base:clip_empty() then
				if is_openbolt then
					wep_base.delayed_t1 = nil
					wep_base.delayed_start = true
				elseif is_revolver and (wep_base.delayed_t1~=0 or (wep_base.delayed_t1==0 and input.btn_primary_attack_press)) then
					wep_base.delayed_t1 = nil
					wep_base.delayed_start = true
					self:set_animation_weapon_hold(nil)
					wep_base:tweak_data_anim_stop("fire")
				end
			else
				if is_openbolt then
					wep_base.delayed_t1 = -1
					self._shooting2 = nil
					wep_base:tweak_data_anim_stop("fire")
					wep_base:tweak_data_anim_stop("reload")
					wep_base:tweak_data_anim_play("reload", 1, wep_tweak.r_ass and 0.033 or nil, true)
					self._ext_camera:play_redirect(self:get_animation(wep_tweak.anim_no_semi and "recoil_exit" or "recoil"), 1, 0.12)
					wep_base:play_sound("wp_rifle_slide_lock")
				elseif is_revolver and not wep_base.delayed_t2 then
					if wep_base.delayed_t1~=0 then
						wep_base.delayed_t1 = nil
						self._shooting2 = nil
						wep_base.delayed_t2 = t + rof*0.5
						self:set_animation_weapon_hold(nil)
						wep_base:tweak_data_anim_stop("fire")
						self._ext_camera:play_redirect(self:get_animation("recoil"), 1, wep_tweak.anim_custom_click or 11/30)
					elseif wep_base.delayed_t1==0 and input.btn_primary_attack_press then
						wep_base.delayed_t1 = nil
						self._shooting2 = nil
						wep_base.delayed_t2 = t + rof*0.5
						wep_base:tweak_data_anim_stop("fire")
					end
				end
			end
		end
	end
	if wep_base.delayed_t2 and t>=wep_base.delayed_t2 then wep_base.delayed_t2 = nil end
	action_wanted = action_wanted or wep_base.delayed_start

	if action_wanted then
		if not action_forbidden then
			self._queue_reload_interupt = nil
			local start_shooting = false

			self._ext_inventory:equip_selected_primary(false)

			if self._equipped_unit then
				local fire_mode = wep_base:fire_mode()
				local fire_on_release = wep_base:fire_on_release()

				if (wep_base.chamber_state or wep_base.clip_empty and wep_base:clip_empty()) and wep_base:start_shooting_allowed() then
					if input.btn_primary_attack_press and not delayed then
						wep_base:dryfire()
						if wep_base.chamber_state then self:do_bolting(t) return end
						if self:_is_using_bipod() then wep_base:tweak_data_anim_stop("fire") end
					end

					if wep_tweak.action=="gatling" and input.btn_primary_attack_state then
						if not self._shooting_fake then
							if wep_base._next_fire_allowed <= t then
								self._shooting_fake = true
							else
								return false
							end
						end

						new_action = true

						if wep_base._next_fire_allowed <= t then
							wep_base:tweak_data_anim_play("fire")
							wep_base._next_fire_allowed = math.max(wep_base._next_fire_allowed, t) + wep_base:weapon_fire_rate()
						end
					end
				elseif self._running and not wep_base:run_and_shoot_allowed() then
					self:_interupt_action_running(t)
				else
					if not self._shooting then
						if wep_base:start_shooting_allowed() then
							local start = fire_mode == "single" and input.btn_primary_attack_press
							start = start or fire_mode == "auto" and input.btn_primary_attack_state
							start = start or fire_mode == "burst" and input.btn_primary_attack_press
							start = start and not fire_on_release
							start = start or fire_on_release and input.btn_primary_attack_release
							if delayed then start = wep_base.delayed_start end

							if start then
								wep_base:start_shooting()
								self._camera_unit:base():start_shooting()
								self:start_shooting()

								self._shooting = true
								start_shooting = true

								if fire_mode == "auto" then
									self._unit:camera():play_redirect(self:get_animation((wep_tweak.anim_shoot_stop_hands or wep_tweak.anim_no_full) and "idle" or "recoil_enter"))

									if (not wep_base.akimbo or wep_base:weapon_tweak_data().allow_akimbo_autofire) and (not wep_base.third_person_important or wep_base.third_person_important and not wep_base:third_person_important()) then
										self._ext_network:send("sync_start_auto_fire_sound", 0)
									end
								end
							end
						else
							self:_check_stop_shooting()
							return false
						end
					end

					local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
					local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
					local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
					local suppression_mul = managers.blackmarket:threat_multiplier()
					local dmg_mul = 1

					local fired = nil
					if fire_mode == "single" then
						if (not delayed and input.btn_primary_attack_press and start_shooting) or (delayed and wep_base.delayed_start) then
							fired = wep_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						elseif fire_on_release then
							if input.btn_primary_attack_release then
								fired = wep_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							elseif input.btn_primary_attack_state then
								wep_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
							end
						end
					elseif fire_mode == "burst" then
						fired = wep_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					elseif fire_mode == "volley" then
						if self._shooting then
							fired = wep_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						end
					elseif (not delayed and input.btn_primary_attack_state) or (delayed and wep_base.delayed_start) then
						fired = wep_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					end

					if wep_base.manages_steelsight and wep_base:manages_steelsight() then
						if wep_base:wants_steelsight() and not self._state_data.in_steelsight then
							self:_start_action_steelsight(t)
						elseif not wep_base:wants_steelsight() and self._state_data.in_steelsight then
							self:_end_action_steelsight(t)
						end
					end

					local charging_weapon = fire_on_release and wep_base:charging()
					if not self._state_data.charging_weapon and charging_weapon then
						self:_start_action_charging_weapon(t)
					elseif self._state_data.charging_weapon and not charging_weapon then
						self:_end_action_charging_weapon(t)
					end

					new_action = true

					if fired then
						if wep_base.delayed_start then
							wep_base.delayed_start = nil
							wep_base.delayed_t2 = t + rof*0.5
						end

						self._fire2_played = nil

						managers.rumble:play("weapon_fire")

						local shake_multiplier = wep_base._kick or 1
						self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier * (self._state_data.in_steelsight and 1.5 or 1))
						self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier * (self._state_data.in_steelsight and 0.4 or 1), 1, 0.15)
						wep_base:tweak_data_anim_stop("unequip")
						wep_base:tweak_data_anim_stop("equip")

						local hands_mul = nil
						if wep_tweak.shot_anim_hands and (wep_tweak.action=="pump_action" or wep_tweak.action=="bolt_action" or wep_tweak.action=="lever_action") then
							hands_mul = (wep_tweak.shot_anim_hands/30) / wep_tweak.fire_mode_data.fire_rate
						end

						if not (is_revolver and not wep_tweak.dao_delayed) and not is_openbolt then
							--if not self._state_data.in_steelsight or not wep_base:tweak_data_anim_play(wep_tweak.anim_shoot_stop and "" or "fire_steelsight", wep_base:fire_rate_multiplier()) then
							wep_base:tweak_data_anim_play(wep_tweak.anim_shoot_stop and "" or (wep_tweak.shot_anim_hip and "fire" or "fire_steelsight"), wep_base:fire_rate_multiplier() * (hands_mul or wep_tweak.shot_anim_mul or 1))
							--end
						end

						if (wep_tweak.action=="bolt_action" or wep_tweak.ads_reset) and self._state_data.in_steelsight then
							self:_interupt_action_steelsight(t)
							self._steelsight_wanted = true
						end
						if (fire_mode == "single" or fire_mode == "burst") and wep_base:get_name_id() ~= "saw" then
							self._ext_camera:play_redirect(Idstring(wep_tweak.shot_anim_steelsight and "recoil_steelsight" or wep_tweak.anim_no_semi and "recoil_exit" or "recoil"), wep_base:fire_rate_multiplier() * (hands_mul or wep_tweak.shot_anim_hands or 1), wep_tweak.shot_anim_hands_offset or 0)
						elseif fire_mode == "auto" and wep_tweak.anim_no_full then
							self._ext_camera:play_redirect(Idstring(wep_tweak.shot_anim_steelsight and "recoil_steelsight" or "recoil"), wep_base:fire_rate_multiplier() * (hands_mul or wep_tweak.shot_anim_hands or 1), wep_tweak.shot_anim_hands_offset or 0)
						end

						local recoil_multiplier = (wep_base:recoil()) * (wep_base.AKIMBO and 1.5 or 1) -- + wep_base:recoil_addend()) * wep_base:recoil_multiplier()
						local up, down, left, right = 1.6, 1.2, -0.1, 1.0 --unpack(wep_tweak.kick[self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])
						if wep_tweak.reverse_rise then up, down, left, right = -1, -1.2, -0.1, 1.0 end
						self._camera_unit:base():recoil_kick(up * recoil_multiplier, down * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier)
						if not wep_base._current_stats.shouldered then self:recoil_kick(up * recoil_multiplier, up * recoil_multiplier, left * recoil_multiplier, right * recoil_multiplier) end

						if wep_base.set_recharge_clbk then wep_base:set_recharge_clbk(callback(self, self, "weapon_recharge_clbk_listener")) end

						managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())

						local impact = not fired.hit_enemy

						if wep_base.third_person_important and wep_base:third_person_important() then
							self._ext_network:send("shot_blank_reliable", impact, 0)
						elseif wep_base.akimbo and not wep_base:weapon_tweak_data().allow_akimbo_autofire or fire_mode == "single" or fire_mode == "burst" then
							self._ext_network:send("shot_blank", impact, 0)
						end
					elseif fire_mode == "single" then
						new_action = false
					elseif fire_mode == "burst" and wep_base:shooting_count() == 0 then
						new_action = false
					end
				end
			end
		elseif self:_is_reloading() and wep_base:reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt = true
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end

	return new_action
end
--IS SHOOTING: DELAYED FIRE CHECK
function PlayerStandard:shooting()
	local wep_base = self._equipped_unit:base()
	return self._shooting or self._shooting2 or (wep_base.delayed_t1 and wep_base.delayed_t1>0) or wep_base.delayed_t2
end
--STOP SHOOTING CHECK: STOP _SHOOTING2
function PlayerStandard:_check_stop_shooting()
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	if (self._shooting and not (wep_base.delayed_t1 and wep_base.delayed_t1>0)) or self._shooting_fake then
		wep_base:stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())
		self:stop_shooting()

		local is_auto_fire_mode = wep_base:fire_mode()=="auto"
		if is_auto_fire_mode and (not wep_base.akimbo or wep_base:weapon_tweak_data().allow_akimbo_autofire) then
			self._ext_network:send("sync_stop_auto_fire_sound", 0)
		end

		if is_auto_fire_mode and not self:_is_reloading() and not self:_is_meleeing() and not wep_tweak.anim_no_full then
			self._unit:camera():play_redirect(self:get_animation("recoil_exit"), nil, wep_tweak.shot_anim_hands_offset or 0)
		end

		self._shooting = false
		self._shooting_fake = false
		self._shooting_t = nil
		self._shooting2 = false
		self._shooting_started = nil
	end
end
function PlayerStandard:get_fire_weapon_direction()
	local csc = nil
	--if self:is_reticle_aim() then
		csc = self._ext_camera:forward_with_shake_toward_reticle(self._state_data.reticle_obj, self._state_data.reticle_holo)
	--else
	--	csc = self._ext_camera:forward()
	--end

	return csc
end
function PlayerStandard:is_reticle_aim()
	return self._state_data.reticle_obj and self._camera_unit:base():is_stance_done()
end
--[[local fwd_ray_to = Vector3()
function PlayerStandard:_update_fwd_ray()
	local weap_base = alive(self._equipped_unit) and self._equipped_unit:base()
	local from = self._unit:movement():m_head_pos()
	local range = weap_base and weap_base.needs_extended_fwd_ray_range and weap_base:needs_extended_fwd_ray_range(self._state_data.in_steelsight) and 20000 or 4000

	mvec3_set(fwd_ray_to, self._cam_fwd)
	mvec3_mul(fwd_ray_to, range)
	mvec3_add(fwd_ray_to, from)

	local fwd_ray = World:raycast("ray", from, fwd_ray_to, "slot_mask", self._slotmask_fwd_ray)
	self._fwd_ray = fwd_ray

	managers.environment_controller:set_dof_distance(math.max(0, math.min(fwd_ray and fwd_ray.distance or 4000, 4000) - 200), self._state_data.in_steelsight)

	if weap_base then
		if fwd_ray and self._state_data.in_steelsight and weap_base.check_highlight_unit then
			weap_base:check_highlight_unit(fwd_ray.unit)
		end

		if weap_base.set_unit_health_display then
			weap_base:set_unit_health_display(fwd_ray and fwd_ray.unit or nil)
		end

		if weap_base.set_scope_range_distance then
			weap_base:set_scope_range_distance(fwd_ray and fwd_ray.distance / 100 or false)
		end
	end

	local to = Vector3()
	mvector3.set(to, self:get_fire_weapon_direction())
	mvector3.multiply(to, range)
	mvector3.add(to, self:get_fire_weapon_position())
	Draw:brush(Color(0.5,1,0,0)):cylinder(self:get_fire_weapon_position(), to, 0.02)
end]]
--NEW FUNCTION: OFFSET RECOIL
function PlayerStandard:_vertical_recoil_kick(t, dt)
	local r_value = 0

	if managers.player:current_state() == "bipod" then
		self:break_recoil()
		return 0
	end

	if self._recoil_kick.current and 1e-05 < self._recoil_kick.accumulated - self._recoil_kick.current then
		local n = math.step(self._recoil_kick.current, self._recoil_kick.accumulated, 40 * dt)
		r_value = n - self._recoil_kick.current
		self._recoil_kick.current = n
	elseif self._recoil_wait then
		self._recoil_wait = self._recoil_wait - dt

		if self._recoil_wait < 0 then
			self._recoil_wait = nil
		end
	elseif self._recoil_kick.to_reduce then
		self._recoil_kick.current = nil
		local n = math.lerp(self._recoil_kick.to_reduce, 0, 9 * dt)
		r_value = -(self._recoil_kick.to_reduce - n)
		self._recoil_kick.to_reduce = n

		if self._recoil_kick.to_reduce == 0 then
			self._recoil_kick.to_reduce = nil
		end
	end

	return self._recoil_kick.current or self._recoil_kick.to_reduce --r_value
end
function PlayerStandard:start_shooting()
	self._recoil_kick.accumulated = self._recoil_kick.to_reduce or 0
	self._recoil_kick.to_reduce = nil
	self._recoil_kick.current = self._recoil_kick.current and self._recoil_kick.current or self._recoil_kick.accumulated or 0
	self._recoil_kick.h.accumulated = self._recoil_kick.h.to_reduce or 0
	self._recoil_kick.h.to_reduce = nil
	self._recoil_kick.h.current = self._recoil_kick.h.current and self._recoil_kick.h.current or self._recoil_kick.h.accumulated or 0
end
function PlayerStandard:stop_shooting(wait)
	self._recoil_kick.to_reduce = self._recoil_kick.accumulated
	self._recoil_kick.h.to_reduce = self._recoil_kick.h.accumulated
	self._recoil_wait = wait or 0
end
function PlayerStandard:break_recoil()
	self._recoil_kick.current = 0
	self._recoil_kick.h.current = 0
	self._recoil_kick.accumulated = 0
	self._recoil_kick.h.accumulated = 0
	self:stop_shooting()
end
function PlayerStandard:recoil_kick(up, down, left, right)
	if not (self._recoil_kick and self._recoil_kick.accumulated) then return end

	if math.abs(self._recoil_kick.accumulated) < 20 then
		local v = math.lerp(up, down, math.random())
		self._recoil_kick.accumulated = (self._recoil_kick.accumulated or 0) + v
	end

	local h = math.lerp(left, right, math.random())
	self._recoil_kick.h.accumulated = (self._recoil_kick.h.accumulated or 0) + h
end



--RELOAD ACTION CHECK: MAGDROP CHECK, BOLTING INTERUPT, IS SHOOTING CHECK
function PlayerStandard:_check_action_reload(t, input)
	local new_action = nil
	local btn_reload_state  = self._controller:get_any_input() and self._controller:get_input_bool("reload")
	local btn_reload_release  = self._controller:get_any_input_released() and self._controller:get_input_released("reload")
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	if not wep_base then return end
	local action_forbidden = (
		self._state_data.reload_expire_t
		or (wep_base:clip_full() and not wep_base.r_stage)
		or (wep_tweak.only_empty and not wep_base:clip_empty())
		or self:shooting()
		or self:_changing_weapon()
		or self:_is_meleeing()
		or self._use_item_expire_t
		or self:_interacting()
		or self:_is_throwing_projectile()
		or self:is_shooting_count()
		or not self._movement_equipped
		or not self._wall_equipped
		or self._state_data.on_ladder
	)

	if input.btn_reload_press then
		if not action_forbidden then
			if wep_base:can_magdrop() then
				if not self._magdrop_t then
					local no_mag = nil
					if wep_base.r_stage then for i=1, wep_base.r_stage-1 do if wep_base.r_cycle[i]=="r_mag_out" then no_mag = 0 break end end end
					self._magdrop_t = t + (no_mag or NQR.settings.nqr_retention_time or 0.2)
					if not self._magdrop_first_press then self._magdrop_first_press = true end
				end

				if self._magdrop_t and not self._magdrop_first_press then
					self._magdrop_t = nil
					self:_start_action_reload_enter(t, true)
					new_action = true
				end
			else
				self:_start_action_reload_enter(t, false)

				new_action = true
			end
		end
	end

	if btn_reload_release then self._magdrop_first_press = nil end

	if not wep_base:use_shotgun_reload() then
		if self._magdrop_t and t>=self._magdrop_t then
			self._magdrop_t = nil
			self._magdrop_first_press = nil
			self:_start_action_reload_enter(t, false)
			new_action = true
		end
	end

	return new_action
end
--RELOAD START ENTER: MAGDROP CHECK
function PlayerStandard:_start_action_reload_enter(t, magdrop)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	if wep_base and wep_base:can_reload() then
		managers.player:send_message_now(Message.OnPlayerReload, nil, self._equipped_unit)
		self:_interupt_action_steelsight(t)
		self:_interupt_action_charging_weapon(t)
		self:_interupt_action_running(t)

		self._state_data.reload_exit_expire_t = nil
		self:_start_action_reload(t, magdrop)
		return true
	end

	return nil
end
--RELOAD START: RELOADING OVERHAUL
function PlayerStandard:_start_action_reload(t, magdrop)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	--if not (wep_base and wep_base:can_reload()) then return end

	local wep_tweak_orig = wep_tweak
	local is_akimbo = wep_base.AKIMBO
	wep_base:tweak_data_anim_stop("fire")
	if not wep_base:use_shotgun_reload() then
		wep_base:tweak_data_anim_stop("fire")
		wep_base:tweak_data_anim_stop("reload")
		wep_base:tweak_data_anim_stop("reload_left")
		wep_base:tweak_data_anim_stop("reload_not_empty")
		wep_base:tweak_data_anim_stop("reload_exit")
		if is_akimbo and wep_base._second_gun then
			wep_base._second_gun:base():tweak_data_anim_stop("fire")
			wep_base._second_gun:base():tweak_data_anim_stop("reload")
			wep_base._second_gun:base():tweak_data_anim_stop("reload_left")
			wep_base._second_gun:base():tweak_data_anim_stop("reload_not_empty")
			wep_base._second_gun:base():tweak_data_anim_stop("reload_exit")
		end
	end

	local base_reload_time = 0
	local offset = 0
	local penalty = 0
	local chamber = wep_base:get_chamber() --wep_tweak.chamber or 1
	local is_bolting = wep_base._bolting_interupted or wep_base._is_bolting==1
	if is_bolting then wep_base:tweak_data_anim_stop("fire") end
	local mag_weight = wep_tweak.feed_system=="backpack" and 10 or math.max(1, wep_base._current_stats.mag_weight)
	local mag_size = math.max(1, wep_base._mag_size or 1)
	local is_reload_not_empty = (
		((is_akimbo and wep_base:get_ammo_remaining_in_clip()>1) or (not is_akimbo and wep_base:clip_not_empty()))
		and not wep_base._started_reload_empty
		and not is_bolting
		and not wep_base.chamber_state
		and not wep_tweak.always_empty
	)
	is_reload_not_empty = wep_tweak.open_bolt and not (wep_base.delayed_t1==-1) or is_reload_not_empty
	is_reload_not_empty = wep_tweak.feed_system=="ejecting_mag" and wep_base.r_not_empty or is_reload_not_empty
	wep_base._started_reload_empty = not is_reload_not_empty or wep_base._started_reload_empty
	wep_base.r_not_empty = is_reload_not_empty
	local speed_multiplier = 1
	local speed_multiplier_enter = 1
	local speed_multiplier_loop = 1
	local speed_multiplier_exit = 1
	local empty_reload = wep_base:clip_empty() and 1 or 0
	local reload_prefix = wep_base:reload_prefix() or ""
	local reload_name_id = wep_tweak.r_anim_swap or wep_tweak.animations.reload_name_id or wep_base.name_id
	local reload_anim = (is_reload_not_empty) and "reload_not_empty" or "reload"
	local reload_ids = Idstring(string.format("%s%s_%s", reload_prefix, reload_anim, reload_name_id))
	local reload_tweak = is_reload_not_empty and (wep_tweak.timers.reload_not_empty or 2.2) or (wep_tweak.timers.reload_empty or 2.6)
	local true_enter_tweak = wep_tweak.r_enter and (wep_tweak.r_enter/30) or wep_base:_first_shell_reload_expire_t(is_reload_not_empty)
	local ammo_to_reload = math.min(wep_base:get_ammo_total(), wep_base:get_ammo_max_per_clip() + chamber) - wep_base:get_ammo_remaining_in_clip()

	local armor = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)].upgrade_level
	local r_multipliers = ( 1
		* (wep_tweak.bullpup and 1.1 or 1)
		* ( 1 + ((0.002*math.max(0, wep_base._weight-5))^0.75) )
		* ((armor==6 or armor==5) and 1.05 or armor==7 and 1.1 or 1)
		* (self._state_data.lying and 1.1 or 1)
		* (wep_base:use_shotgun_reload() and 1 or math.rand(0.9, 1.1))
	)
	local r_steps = {
		r_reach_for_old_mag = 0.2 * (wep_tweak.bullpup and 2 or 1) * r_multipliers,
		r_mag_out = (tweak_data.weapon.r_timings[wep_tweak.mag_release] or 0.1) * r_multipliers,
		r_keep_old_mag =   ( 0.7 + ((0.008*math.max(0, mag_size-2))^0.50) + ((0.016*math.max(0, mag_weight-1))^0.75) ) * r_multipliers,
		r_get_new_mag_in = ( 0.4 + ((0.024*math.max(0, mag_size-2))^0.50) + ((0.048*math.max(0, mag_weight-1))^0.75) ) * r_multipliers,
		r_bolt_release = (tweak_data.weapon.r_timings[wep_tweak.bolt_release] or 0.2) * r_multipliers,
		r_ending = 0.05+(r_multipliers-1)*2 } --0.3 + ((r_multipliers-1)*1.5) }
		r_steps.r_get_new_mag_in_2 = r_steps.r_get_new_mag_in * 0.5
		r_steps.r_bolt_release_1 = r_steps.r_bolt_release * (wep_tweak.bolt_release_ratio and wep_tweak.bolt_release_ratio[1] or 0.5)
		r_steps.r_bolt_release_2 = r_steps.r_bolt_release * (wep_tweak.bolt_release_ratio and wep_tweak.bolt_release_ratio[2] or 0.5)
		r_steps.r_bolt_release = is_reload_not_empty and 0 or r_steps.r_bolt_release
	local r_cycle = (
		((is_reload_not_empty or wep_tweak.always_empty) and wep_tweak.custom_cycle) or
		(not is_reload_not_empty and wep_tweak.custom_cycle_2) or
		{ "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release" }
	)
	if is_akimbo then
		r_cycle = wep_tweak.custom_cycle and wep_tweak.custom_cycle[1]=="r_bolt_release_1"
		and { "r_bolt_release_1", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release_2", }
		or { "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_reach_for_old_mag", "r_mag_out", "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release", }
	end
	local anim_reload_mul = wep_tweak.anim_reload_mul or 1

	if wep_base._is_bolting==2 then
		if r_cycle[#r_cycle]=="r_bolt_release_2" then
			wep_base.r_stage = math.max(2, wep_base.r_stage or 0)
		else
			r_steps.r_bolt_release = r_steps.r_bolt_release_2
		end
	end

	if not wep_base:use_shotgun_reload() then
		for i, k in pairs(r_cycle) do if k=="r_keep_old_mag" and r_cycle[i-1]~="r_mag_out" then r_steps.r_keep_old_mag = 0.3 end end --if theres no old mag

		if magdrop and not wep_base._magdrop then
			managers.mission._fading_debug_output:script().log(tostring("nqr_magdrop"),  Color.red)
			self._state_data.magdrop_t = t
			for i=(wep_base.r_stage or 1), #r_cycle do
				self._state_data.magdrop_t = self._state_data.magdrop_t + r_steps[ r_cycle[i] ]
				if r_cycle[i]=="r_mag_out" then break end
			end

			r_steps.r_keep_old_mag = 0.2
			if r_steps.r_mag_out==0 then r_steps.r_reach_for_old_mag = 0 end
		end

		if wep_base.r_stage and wep_base.r_stage>1 then
			if wep_base.shot_without_mag then r_steps.r_bolt_release = tweak_data.weapon.r_timings.none * r_multipliers end

			for i=1, wep_base.r_stage-1 do offset = offset + r_steps[ r_cycle[i] ] end

			if r_cycle[wep_base.r_stage]=="r_get_new_mag_in" then
				penalty = 0.2 * r_multipliers
			elseif r_cycle[wep_base.r_stage]=="r_bolt_release"
			or r_cycle[wep_base.r_stage]=="r_bolt_release_1"
			or r_cycle[wep_base.r_stage]=="r_bolt_release_2" then
				penalty = 0.1 * r_multipliers
			end
		end

		for i=(wep_base.r_stage or 1), #r_cycle do base_reload_time = base_reload_time + r_steps[ r_cycle[i] ] end

		base_reload_time = base_reload_time + penalty
		offset = offset - penalty

		speed_multiplier = reload_tweak / (base_reload_time + offset)
		offset = offset * speed_multiplier
	else
		empty_reload = wep_base:get_ammo_max_per_clip() - wep_base:get_ammo_remaining_in_clip()

		wep_base.r_amount = 1
		wep_base.r_doubleload = ((wep_base.r_amount>1) and wep_tweak.r_can_doubleload --[[and wep_base._current_stats.shouldered]])
		local doubleload_penalty = 0
		if wep_base.r_doubleload then
			if wep_base.r_amount==4 then if ammo_to_reload>=4 then doubleload_penalty = 0.0 else wep_base.r_amount = 2 end end --todo wtf is this yandere dev kinda garbage dude
			if wep_base.r_amount==2 then if ammo_to_reload>=2 then doubleload_penalty = 0.0 else wep_base.r_amount = 1 end end
		else wep_base.r_amount = 1 end
		wep_base.r_anim_swap = wep_base.r_doubleload and "ultima_orig" or wep_tweak.r_anim_swap
		if wep_base.r_anim_swap then wep_tweak = tweak_data.weapon[wep_base.r_anim_swap] end

		reload_tweak = wep_base:reload_shell_expire_t(is_reload_not_empty, wep_base.r_anim_swap)
		r_steps.r_bolt_release = (tweak_data.weapon.r_timings[wep_tweak.bolt_release or "none"]) * r_multipliers
		r_steps.r_keep_old_mag = 0.3 --* r_multipliers
		r_steps.r_keep_old_mag_orig = r_steps.r_keep_old_mag
		r_steps.r_get_new_mag_in = ((wep_tweak.r_get_new_mag_in or 0.5) + doubleload_penalty) * r_multipliers
		r_cycle = wep_tweak.custom_cycle or { "r_keep_old_mag", "r_get_new_mag_in", "r_bolt_release" }

		if wep_base.r_stage==#r_cycle and not self._state_data.reload_expire_t then wep_base.r_stage = nil end

		if (r_cycle[1]=="r_bolt_release_1") and (wep_base._is_bolting==2) then
			wep_base.r_stage = math.max(2, wep_base.r_stage or 0)
			wep_base.r_offset_enter = wep_tweak.custom_enter or r_steps.r_bolt_release_1
			r_steps.r_bolt_release_1 = 0
		end

		for i=(#r_cycle), 1, -1 do
			if (r_cycle[i]=="r_bolt_release_1" and wep_base.r_stage)
			or (r_cycle[i]=="r_bolt_release_2" and not wep_base:clip_full() and not (wep_base.r_stage==#r_cycle))
			or (r_cycle[i]=="r_bolt_release" and not (wep_base.r_stage==#r_cycle))
			then
				r_steps[ r_cycle[i] ] = 0
			end
		end

		if wep_base.r_stage==#r_cycle then
			base_reload_time = r_steps[ r_cycle[#r_cycle] ]
			speed_multiplier_exit = (wep_tweak.r_exit_mul or wep_tweak.timers.shotgun_reload_exit_empty or 0.7) / base_reload_time
		else
			r_steps.r_bolt_release = 0
			r_steps.r_bolt_release_2 = 0
			for i=(wep_base.r_stage or 1), #r_cycle do base_reload_time = base_reload_time + r_steps[ r_cycle[i] ] end

			speed_multiplier_loop = (wep_tweak.timers.shotgun_reload_shell or 17/30) / (r_steps.r_keep_old_mag_orig + r_steps.r_get_new_mag_in)
			local vanilla_r_shell = ((wep_tweak.timers.shotgun_reload_enter or 9/30) - (wep_tweak.timers.shotgun_reload_first_shell_offset or 10/30)) + (wep_tweak.timers.shotgun_reload_shell or 17/30) - true_enter_tweak
			local adjusted_r_shell = vanilla_r_shell / speed_multiplier_loop
			local adjusted_r_enter = ((r_cycle[1]=="r_bolt_release_1" and true_enter_tweak or 0) + r_steps.r_keep_old_mag_orig + r_steps.r_get_new_mag_in) - adjusted_r_shell
			speed_multiplier_enter = adjusted_r_enter<=0 and 100 or (true_enter_tweak / adjusted_r_enter)
		end
		wep_base.r_offset_enter = r_cycle[1]=="r_bolt_release_1" and wep_base.r_offset_enter or 10/30 -- -0.0001
	end

	wep_base.r_starting_stage = wep_base.r_stage
	wep_base.r_steps = r_steps
	wep_base.r_cycle = r_cycle
	wep_base.r_time = base_reload_time
	wep_base.r_shell_start = wep_base.r_time
	wep_base.r_offset = offset
	wep_base.r_penalty = penalty
	wep_base.r_shell_end = (reload_tweak/speed_multiplier_loop) -- + (2/30)
	wep_base.r_multipliers = r_multipliers
	wep_base._current_reload_speed_multiplier = speed_multiplier
	wep_base._current_reload_speed_multiplier_loop = speed_multiplier_loop
	wep_base.r_anim = wep_base.r_anim_swap=="ultima_orig" and "reload_ultima" or "reload_enter_"..(wep_base.r_anim_swap or wep_base.name_id)
	local r_stages = {}
	local count = penalty
	for i=1, #r_cycle do
		count = count + (wep_base.r_stage and i<wep_base.r_stage and 0 or r_steps[ r_cycle[i] ])
		r_stages[i] = count
	end
	wep_base.r_stages = r_stages

	if not wep_base:use_shotgun_reload() then
		self._ext_camera:play_redirect(reload_ids, speed_multiplier, offset)
		if not wep_base:tweak_data_anim_play(reload_anim, speed_multiplier*anim_reload_mul, math.max(wep_tweak.r_ass or 0, offset*anim_reload_mul)) then
			wep_base:tweak_data_anim_play("reload", speed_multiplier*anim_reload_mul, math.max(wep_tweak.r_ass or 0, offset*anim_reload_mul))
			Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_anim)
		end
	elseif not wep_base.r_doubleload then
		if not self._state_data.reload_expire_t then
			self._ext_camera:play_redirect(Idstring(wep_base.r_anim), speed_multiplier_enter, wep_base.r_stage and wep_base.r_offset_enter or 0)
			if wep_tweak.custom_enter and wep_base._bolting_interupted and wep_base._is_bolting~=2 then
				wep_base:tweak_data_anim_play("fire", speed_multiplier_enter, 3.5/30)
				self._state_data.reload_enter_anim_expire_t = t + (wep_tweak.custom_enter or (11/30))
			else
				wep_base:tweak_data_anim_stop("fire_steelsight")
				wep_base:tweak_data_anim_play("reload_enter", speed_multiplier_enter, wep_base.r_stage and wep_base.r_offset_enter or 0)
				if wep_tweak.sao then 
					wep_base:tweak_data_anim_play("fire", 0, 1/30)
				end
			end
		elseif wep_base.r_stage==#r_cycle then
			self._state_data.reload_enter_anim_expire_t = nil
			self._state_data.reload_shell_start_expire_t = nil
			self._state_data.reload_shell_end_expire_t = nil

			local anim_wep = (is_reload_not_empty or wep_base.r_doubleload or wep_tweak.exit_anim_partial) and "reload_not_empty_exit" or "reload_exit"
			local anim_cam = wep_base.r_doubleload and "reload_exit" or anim_wep
			anim_wep = anim_wep=="reload_exit" and wep_tweak.anim_r_exit or anim_wep

			if wep_base.r_doubleload and (not is_reload_not_empty) and wep_tweak.action and not wep_base:clip_empty() then
				anim_cam = "reload_exit"
				self._state_data.reload_exit2_expire_t = t + 0.2
			end

			self._ext_camera:play_redirect(Idstring(wep_base.r_anim), 0)
			wep_base:tweak_data_anim_stop("reload_enter")
			if wep_tweak.custom_enter then
				wep_base:tweak_data_anim_play("fire", 0.25, 15/30)
				self._ext_camera:play_redirect(self:get_animation(anim_cam), 1)
			else
				if r_cycle[1]=="r_bolt_release_1" then wep_base:tweak_data_anim_play("reload_enter", 0, wep_tweak.r_enter) end
				wep_base:tweak_data_anim_play(anim_wep, speed_multiplier_exit, wep_tweak.anim_r_exit and 0.2 or 1/30)
				self._ext_camera:play_redirect(self:get_animation(anim_cam), speed_multiplier_exit)
			end
			--if r_cycle[1]=="r_bolt_release_1" then wep_base._is_bolting = 2 end
		end
	elseif wep_base.r_doubleload then
		wep_base.ultima_t = wep_base.ultima_t or {
			cl_start = 10/30, --9/30,
			cl_done = 41/30,
			ql_start = 52/30,
			ql_half = 61/30,
			ql_done = 72/30,
			dl_start = 80/30,
			dl_done = 92/30 }
		local length_ql = wep_base.ultima_t["dl_start"]-wep_base.ultima_t["ql_start"]
		local length_ql1 = wep_base.ultima_t["ql_half"]-wep_base.ultima_t["ql_start"]
		local length_ql2 = wep_base.ultima_t["ql_done"]-wep_base.ultima_t["ql_half"]
		local length_dl = wep_base.ultima_t["dl_done"]-wep_base.ultima_t["dl_start"]
		r_steps.r_get_new_mag_in_half = 0.3 * r_multipliers
		wep_base.r_time = r_steps.r_keep_old_mag + r_steps.r_get_new_mag_in
		wep_base._current_reload_speed_multiplier_loop = (wep_base.r_amount==4 and length_ql1 or length_dl) / r_steps.r_get_new_mag_in
		wep_base.r_shell_start = r_steps.r_get_new_mag_in + (wep_base.r_amount==4 and 0 or r_steps.r_keep_old_mag) + (1/30) --+ (wep_base.r_amount==4 and r_steps.r_get_new_mag_in_half or 0)

		if not self._state_data.reload_expire_t then
			local enter_anim_t = 0.3
			speed_multiplier_enter = wep_base.ultima_t["cl_start"] / enter_anim_t
			local enter_shoulder_t = (0.2 * r_multipliers)
			wep_base.r_time = enter_shoulder_t + r_steps.r_keep_old_mag + r_steps.r_get_new_mag_in

			if wep_base:clip_empty() and not wep_tweak_orig.action then
				wep_base.r_time = enter_shoulder_t + r_steps.r_keep_old_mag + r_steps.r_get_new_mag_in --(0.5 * r_multipliers)
				wep_base.r_amount = 1
				speed_multiplier_enter = wep_base.ultima_t["cl_done"] / wep_base.r_time
				self._state_data.reload_shell_start_expire_t = t + wep_base.r_time + r_steps.r_keep_old_mag
				self._state_data.reload_shell_end_expire_t = t + (wep_base.ultima_t["ql_start"] / speed_multiplier_enter)
				wep_base.r_shell_start = r_steps.r_keep_old_mag + r_steps.r_get_new_mag_in
				if wep_base.name_id=="ultima" then
					wep_base:tweak_data_anim_play(reload_anim, speed_multiplier_enter, 0)
				else
					wep_base:tweak_data_anim_play(reload_anim, 0, 0.8)
				end
			else
				self._state_data.reload_shell_end_expire_t = t + enter_anim_t
				self._state_data.reload_shell_start_expire_t = t + enter_shoulder_t + r_steps.r_keep_old_mag
			end

			self._ext_camera:play_redirect(Idstring(wep_base.r_anim), speed_multiplier_enter)
		elseif wep_base.r_quad_half then
			wep_base.r_amount = 2
			wep_base.r_time = r_steps.r_get_new_mag_in_half
			wep_base._current_reload_speed_multiplier_loop = length_ql2 / wep_base.r_time
			wep_base.r_shell_start = wep_base.r_time + r_steps.r_keep_old_mag
		end
	end

	self._state_data.reload_expire_t = t + wep_base.r_time
	wep_base.r_expire_t = self._state_data.reload_expire_t
	wep_base.r_exit_expire_t = self._state_data.reload_exit_expire_t

	local r_show_mag_t = 0
	for i=1, #r_cycle do
		if r_cycle[i]=="r_get_new_mag_in" then break end
		if not wep_base.r_stage or wep_base.r_stage<=i then r_show_mag_t = r_show_mag_t + r_steps[ r_cycle[i] ] end
	end
	if wep_tweak.r_no_bullet_clbk and r_show_mag_t>0 then
		--self._state_data.r_show_mag_t = t + math.max(r_show_mag_t, wep_base.r_time*0.0)
		self._state_data.r_show_mag_t = t + r_show_mag_t --wep_base.r_time*0.5
	else
		self._state_data.r_show_mag_t = nil
	end

	Application:trace("PlayerStandard:_start_action_reload( t ): ", reload_ids)
	wep_base:start_reload()
	self._ext_network:send("reload_weapon", empty_reload, speed_multiplier)
	if wep_base.r_stage then
		if r_cycle[wep_base.r_stage]=="r_get_new_mag_in" then
			wep_base:predict_bullet_objects()
		end
	else
		wep_base:check_bullet_objects()
	end

	local is_revolver = wep_base:is_category("revolver")
	if is_revolver then
		wep_base.delayed_t1 = nil
		wep_base.delayed_t2 = nil
		self._cock_t = nil
	end

	if wep_base.r_stage~=#wep_base.r_cycle then wep_base:set_loader_visibility(true) end
	wep_base:set_casing_visibility(true)
end
--RELOAD UPDATE: RESETTING RELOAD STAGE AND BOLTING, EXIT SPEED MULTIPLIER, BULLET OBJECTS REFILL FIX, AMMO BACKPACK CHECK
function PlayerStandard:_update_reload_timers(t, dt, input)
	if not self._equipped_unit then return end
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local open_reload = wep_base.r_cycle and wep_base.r_cycle[1]=="r_bolt_release_1"
	local is_reload_not_empty = not wep_base:started_reload_empty()
	local finish = nil
	local closing = nil
	wep_base.r_expire_t = self._state_data.reload_expire_t
	wep_base.r_exit_expire_t = self._state_data.reload_exit_expire_t

	if self._state_data.reload_expire_t then
		wep_base:update_r_stage(t)

		if self._queue_reload_interupt then
			self._queue_reload_interupt = nil

			if not (wep_base.r_stage==#wep_base.r_cycle) then
				if open_reload or (not is_reload_not_empty and (wep_base:get_ammo_remaining_in_clip()>0)) then
					wep_base.r_stage = #wep_base.r_cycle
					self:_start_action_reload(t, false)
					return
				else
					finish = true
				end
			end
		end

		local tweak_anim = wep_base.r_doubleload and "reload" or "reload_enter"
		local speed_mul = wep_base._current_reload_speed_multiplier_loop
		local offset = wep_base.r_doubleload and (wep_base.r_amount==4 and wep_base.ultima_t["ql_start"] or wep_base.ultima_t["dl_start"]) or 0

		if self._state_data.reload_enter_anim_expire_t and self._state_data.reload_enter_anim_expire_t<=t then
			self._state_data.reload_enter_anim_expire_t = nil
			local speed_mul1 = 0.05 --(wep_base.r_doubleload and not wep_base._started_reload_empty) and 0.05 or 0
			local offset1 = wep_base.r_doubleload and offset or wep_base.r_offset_enter
			local offset1 = wep_base.r_doubleload and (
				wep_base.r_quad_half and wep_base.ultima_t["ql_half"] or wep_base.r_amount==4 and wep_base.ultima_t["ql_start"] or wep_base.ultima_t["dl_start"]
			) or wep_base.r_offset_enter
			if wep_base.r_doubleload then
				self._state_data.reload_shell_start_expire_t = t + wep_base.r_shell_start
				self._state_data.reload_shell_end_expire_t = t + wep_base.r_shell_end
			end
			wep_base:tweak_data_anim_stop("fire")
			wep_base:tweak_data_anim_play(wep_tweak.anim_r_loop or tweak_anim, speed_mul, offset1)
		end
		if self._state_data.reload_shell_start_expire_t and self._state_data.reload_shell_start_expire_t<=t then
			local offset1 = wep_base.r_doubleload and (
				wep_base.r_quad_half and wep_base.ultima_t["ql_half"]
				or wep_base.r_amount==4 and wep_base.ultima_t["ql_start"]
				or wep_base.ultima_t["dl_start"]
			) or wep_base.r_offset_enter
			self._state_data.reload_shell_start_expire_t = t + wep_base.r_shell_start
			self._state_data.reload_shell_end_expire_t = t + wep_base.r_shell_end
			wep_base:tweak_data_anim_play(wep_tweak.anim_r_loop or tweak_anim, speed_mul, offset1)
			self._ext_camera:play_redirect(Idstring(wep_base.r_anim), speed_mul, offset1)
		end
		if self._state_data.reload_shell_end_expire_t and self._state_data.reload_shell_end_expire_t<=t then
			self._state_data.reload_shell_end_expire_t = nil
			local speed_mul1 = (wep_base.r_doubleload and not wep_base._started_reload_empty) and 0.05 or 0
			local offset1 = wep_base.r_doubleload and (
				wep_base.r_quad_half and wep_base.ultima_t["ql_half"]
				or wep_base.r_amount==4 and wep_base.ultima_t["ql_start"]
				or wep_base.ultima_t["dl_start"]
			) or wep_base.r_offset_enter
			wep_base:tweak_data_anim_play(tweak_anim, 0)
			self._ext_camera:play_redirect(Idstring(wep_base.r_anim), 0, offset1)
		end

		if self._state_data.reload_enter_expire_t and self._state_data.reload_enter_expire_t<=t then
			self._state_data.reload_enter_expire_t = nil

			if wep_base:get_ammo_remaining_in_clip()>0 then
			end
		end

		if self._state_data.magdrop_t and self._state_data.magdrop_t <= t then self._state_data.magdrop_t = nil wep_base:do_magdrop() end

		if self._state_data.r_show_mag_t and self._state_data.r_show_mag_t <= t then
			self._state_data.r_show_mag_t = nil
			wep_base:predict_bullet_objects()
			if wep_base._second_gun then wep_base._second_gun:base():predict_bullet_objects() end
		end

		if self._state_data.reload_expire_t<=t then finish = true end

		if finish then
			if not wep_base:use_shotgun_reload() then
				if self._state_data.reload_expire_t<=t then
					if not wep_base.r_didnt_load then
						wep_base:on_reload()
						managers.statistics:reloaded()
						managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())
					end

					if input.btn_steelsight_state then
						self._steelsight_wanted = true
					elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not wep_base:run_and_shoot_allowed() and self._wall_equipped then
						self._ext_camera:play_redirect(self:get_animation("start_running"))
						self._ext_network:send("set_stance", 2, false, false)
					end

					if wep_base:get_ammo_remaining_in_clip()>0 then
						wep_base._started_reload_empty = nil
					end
					wep_base.chamber_state = nil
				end
			else
				if wep_base.r_stage ~= #wep_base.r_cycle then
					local chamber = (
						open_reload or is_reload_not_empty or (not is_reload_not_empty and wep_base.r_doubleload and not wep_tweak.action)
					) and not string.find(wep_tweak.feed_system, "cylinder") and 1 or 0

					if self._state_data.reload_expire_t<=t then
						if wep_base.r_amount==4 then wep_base.r_amount = 2 wep_base.r_quad_half = true
						elseif wep_base.r_quad_half then wep_base.r_quad_half = nil end
						is_reload_not_empty = is_reload_not_empty or wep_base:clip_empty()

						if wep_base:clip_empty() and wep_base.r_doubleload and not wep_tweak.action then
							wep_base:tweak_data_anim_play(wep_tweak.anim_r_loop or tweak_anim, speed_mul, wep_base.ultima_t["dl_start"])
						end

						wep_base:set_ammo_remaining_in_clip(math.min(wep_base:get_ammo_total(), wep_base:get_ammo_max_per_clip()+chamber, wep_base:get_ammo_remaining_in_clip()+wep_base.r_amount))
						managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())

						local clip_full = wep_base:get_ammo_remaining_in_clip()==math.min(wep_base:get_ammo_max_per_clip()+chamber, wep_base:get_ammo_total())
						if not clip_full then
							if open_reload then wep_base.r_stage = 2 end
							self:_start_action_reload(t, false)
							return
						end
					end

					local clip_full = wep_base:get_ammo_remaining_in_clip()>0 --wep_base:clip_full()
					if clip_full and (open_reload or (wep_base.r_cycle[#wep_base.r_cycle]=="r_bolt_release" and not wep_base.r_doubleload and not is_reload_not_empty)) then
						wep_base.r_stage = #wep_base.r_cycle
						self:_start_action_reload(t, false)
						return
					end

					wep_base.r_exit_expire_init = not is_reload_not_empty

					local wep_anim = "reload_not_empty_exit" --(is_reload_not_empty or wep_base.r_doubleload) and "reload_not_empty_exit" or "reload_exit"
					local cam_anim = wep_base.r_doubleload and "reload_exit" or wep_anim
					wep_anim = wep_anim=="reload_exit" and wep_tweak.anim_r_exit or wep_anim

					if wep_base.r_doubleload and (not is_reload_not_empty) and wep_tweak.action then
						cam_anim = "reload_exit"
						self._state_data.reload_exit2_expire_t = t + 0.2
					end

					self._ext_camera:play_redirect(self:get_animation(cam_anim), 1)
					wep_base:tweak_data_anim_stop("reload_not_empty_exit")
					wep_base:tweak_data_anim_stop("reload_exit")
					wep_base:tweak_data_anim_stop("reload")
					wep_base:tweak_data_anim_stop("reload_enter")
					wep_base:tweak_data_anim_play(wep_anim, 1, wep_tweak.anim_r_exit and 0.2 or 0)
				end
	
				wep_base.r_quad_half = nil
				if wep_base:get_ammo_remaining_in_clip()>0 then wep_base._started_reload_empty = nil end
			end

			if (wep_tweak.action~="pump_action" and wep_tweak.action~="lever_action") or wep_tweak.force_anim_reload_transition then
				self._state_data.reload_exit_expire_t = t + wep_base.r_steps["r_ending"]
			end

			self._state_data.reload_enter_expire_t = nil
			self._state_data.reload_expire_t = nil
			self._state_data.reload_shell_start_expire_t = nil
			self._state_data.reload_shell_end_expire_t = nil
			self._state_data.reload_halfed = nil
			self._state_data.bolt_dropped = nil
			self._started_reload_empty = nil
			wep_base.r_time = nil
			wep_base.r_stage = nil
			wep_base.shot_without_mag = nil
			wep_base._magdrop = nil
			wep_base._magdrop_shotgun = nil
			wep_base.delayed_t1 = nil
			wep_base.r_not_empty = nil
			wep_base.r_offset = nil
			wep_base.r_didnt_load = nil
		end
	end

	if self._state_data.reload_exit2_expire_t and self._state_data.reload_exit2_expire_t <= t then
		self._state_data.reload_exit2_expire_t = nil
		self:do_bolting(t)
	end

	if self._state_data.reload_exit_expire_t and self._state_data.reload_exit_expire_t <= t then
		self._state_data.reload_exit_expire_t = nil

		if self._state_data.in_steelsight then self._ext_camera:play_redirect(self:get_animation("idle")) end

		if self._equipped_unit then
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if input.btn_steelsight_state then
				self._steelsight_wanted = true
			elseif self.RUN_AND_RELOAD and self._running and not self._end_running_expire_t and not self._equipped_unit:base():run_and_shoot_allowed() and self._wall_equipped then
				self._ext_camera:play_redirect(self:get_animation("start_running"))
				self._ext_network:send("set_stance", 2, false, false)
			end

			if self._equipped_unit:base().on_reload_stop then
				self._equipped_unit:base():on_reload_stop()
			end

			if wep_tweak.force_anim_reload_transition then self._ext_camera:play_redirect(self:get_animation("idle")) end
		end
	end
end
--RELOAD INTERUPT: EMPTY A MAG, DONT UPDATE BULLET OBJECTS
function PlayerStandard:_interupt_action_reload(t)
	local wep_base = self._equipped_unit:base()
	--if not self:_is_reloading() then return end
	self._magdrop_t = nil
	self._state_data.reload_exit_expire_t = nil
	if not self._state_data.reload_expire_t then wep_base:interupt_bolting(true) return end

	local t = t or TimerManager:game():time()
	local wep_tweak = wep_base:weapon_tweak_data()
	--if alive(self._equipped_unit) then wep_base:check_bullet_objects() end
	local reload_anim = wep_base.r_not_empty and "reload_not_empty" or "reload"
	local chamber = wep_base:get_chamber()
	local offset = 0
	local r_stage = wep_base.r_stage
	local r_cycle = wep_base.r_cycle
	local r_steps = wep_base.r_steps
	local anim_reload_mul = wep_tweak.anim_reload_mul or 1
	wep_base:tweak_data_anim_stop("reload_enter")
	wep_base:tweak_data_anim_stop("reload")
	wep_base:tweak_data_anim_stop("reload_not_empty")
	wep_base:tweak_data_anim_stop("reload_exit")
	wep_base:set_loader_visibility(false)

	if not wep_base:use_shotgun_reload() then
		if r_cycle[r_stage]=="r_reach_for_old_mag" or r_cycle[r_stage]=="r_mag_out" then
			r_stage = r_cycle[r_stage]=="r_reach_for_old_mag" and r_stage or (r_stage-1) --table.get_vector_index(r_cycle, "r_reach_for_old_mag")
			wep_base._magdrop = nil
		end

		if (r_cycle[r_stage]=="r_keep_old_mag" and r_cycle[r_stage-1]=="r_mag_out") or r_cycle[r_stage]=="r_get_new_mag_in" then
			if wep_base:can_magdrop() and not wep_base._magdrop then
				managers.mission._fading_debug_output:script().log(tostring("nqr_magdrop"..(r_cycle[r_stage]=="r_get_new_mag_in" and " (full mag)" or "(partial mag)")),  Color.red)
				wep_base:do_magdrop(r_cycle[r_stage]=="r_get_new_mag_in")
			end
			if r_cycle[r_stage]==r_cycle[r_stage-4] then
				if wep_base._second_gun then wep_base._second_gun:base():set_mag_visibility(false) end
			else
				wep_base:set_mag_visibility(false)
				if wep_base._second_gun then wep_base._second_gun:base():set_mag_visibility(false) end
			end

			r_stage = r_cycle[r_stage]=="r_get_new_mag_in" and r_stage or (r_stage+1) --table.get_vector_index(r_cycle, "r_get_new_mag_in")
		end

		if wep_base:started_reload_empty() and ((r_cycle[#r_cycle]=="r_bolt_release" or r_cycle[#r_cycle]=="r_bolt_release_2") and (wep_tweak.action=="bolt_action" or wep_tweak.action=="pump_action" or wep_tweak.action=="lever_action")) then
			wep_base:interupt_bolting()
		end

		if r_stage==1 then r_stage = nil end

		if r_stage then
			for i=1, r_stage-1 do
				offset = offset + r_steps[ r_cycle[i] ]
			end
			offset = offset * wep_base._current_reload_speed_multiplier
			wep_base.r_offset = offset*anim_reload_mul
		end
	else
		local time = wep_base.r_time - ((self._state_data.reload_expire_t or 0) - t)
		local count = 0
		for i=(r_stage or 1), #r_cycle do
			count = count + r_steps[ r_cycle[i] ]
			if count>time then
				r_stage = i>1 and i or nil
				break
			end
		end
		local whole_length = 0
		for i, k in pairs(r_cycle) do whole_length = whole_length + r_steps[k] end

		if r_cycle[r_stage]=="r_reach_for_old_mag" or r_cycle[r_stage]=="r_mag_out" then
			for i, k in pairs(r_cycle) do
				if k=="r_reach_for_old_mag" then
					r_stage = i>1 and i or nil
					wep_base._magdrop = nil
				end
			end
		end

		if r_stage and (r_cycle[r_stage]=="r_keep_old_mag" and r_cycle[r_stage-1]=="r_mag_out") or r_cycle[r_stage]=="r_get_new_mag_in" then
			--if wep_base:can_magdrop() and not wep_base._magdrop then
				managers.mission._fading_debug_output:script().log(tostring("nqr_magdrop"),  Color.red)
				wep_base:do_magdrop()
			--end

			for i, k in pairs(r_cycle) do
				if k=="r_keep_old_mag" then
					r_stage = i>1 and i or nil
				end
			end
		end

		if r_stage and r_cycle[1]=="r_bolt_release_1" then
			--wep_base:interupt_bolting()
		end

		if r_stage then
			wep_base.r_offset = wep_base.r_offset_enter
		end

		if wep_base:started_reload_empty() and ((r_cycle[#r_cycle]=="r_bolt_release" or r_cycle[#r_cycle]=="r_bolt_release_2") and (wep_tweak.action=="bolt_action" or wep_tweak.action=="pump_action" or wep_tweak.action=="lever_action")) then
			wep_base:interupt_bolting()
			r_stage = nil --#r_cycle
		end
	end

	self._queue_reload_interupt = nil
	self._state_data.reload_enter_expire_t = nil
	self._state_data.reload_expire_t = nil
	self._state_data.reload_exit_expire_t = nil
	self._state_data.reload_exit2_expire_t = nil
	self._state_data.reload_halfed = nil
	self._state_data.magdrop_t = nil
	wep_base._magdrop_shotgun = nil

	wep_base.r_offset = r_stage and wep_base.r_offset
	wep_base.r_stage = r_stage

	self:send_reload_interupt()
end
--IS RELOADING: RELOAD_READY CHECK
function PlayerStandard:_is_reloading()
	return self._state_data.reload_expire_t
	or self._state_data.reload_enter_expire_t
end
--NEW FUNCTION: BOLTING
function PlayerStandard:do_bolting(t)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local offset = 0.07

	wep_base:set_casing_visibility(wep_base.chamber_state~=0)
	if wep_tweak.r_hide_mag_on_bolting then wep_base:set_mag_visibility(not wep_base:clip_empty()) end

	if self._state_data.in_steelsight and (wep_tweak.action=="bolt_action" or wep_tweak.ads_reset) then
		self:_interupt_action_steelsight(t)
		self._steelsight_wanted = not wep_base.r_stage
	end

	if wep_base.r_stage then
		if wep_base:use_shotgun_reload() then
			--wep_base.r_stage = #wep_base.r_cycle
			self:_start_action_reload(t, false)
			self._queue_reload_interupt = true
			return
		elseif wep_base.r_cycle[wep_base.r_stage]=="r_bolt_release_2" or wep_base.r_cycle[wep_base.r_stage]=="r_bolt_release" then
			self:_start_action_reload(t, false)
			return
		end
	else
		wep_base:update_next_shooting_time(offset)

		local hands_mul = wep_tweak.shot_anim_hands and ((wep_tweak.shot_anim_hands/30) / wep_tweak.fire_mode_data.fire_rate)
		wep_base:tweak_data_anim_stop("fire")
		wep_base:tweak_data_anim_stop("fire_steelsight")
		wep_base:tweak_data_anim_play(wep_tweak.shot_anim_mul and "fire" or "fire_steelsight", hands_mul or wep_tweak.shot_anim_mul or 1, offset*2)
		self._ext_camera:play_redirect(self:get_animation(wep_tweak.shot_anim_steelsight and "recoil_steelsight" or "recoil"), hands_mul or wep_tweak.shot_anim_mul or 1, offset)
	end

	wep_base._started_reload_empty = nil
	wep_base._bolting_interupted = nil
end



--THROW GRENADE CHECK: BOLTING INTERUPT
function PlayerStandard:_check_action_throw_grenade(t, input)
	local action_wanted = input.btn_throw_grenade_press

	if not action_wanted then
		return
	end

	if not managers.player:can_throw_grenade() then
		return
	end

	local action_forbidden = (
		not PlayerBase.USE_GRENADES
		or self:chk_action_forbidden("interact")
		or self._unit:base():stats_screen_visible()
		or self:_is_throwing_grenade()
		or self:_interacting()
		or self:is_deploying()
		or self:_is_meleeing()
		or self:_is_using_bipod()
		or not self._movement_equipped
	)

	if action_forbidden then
		return
	end

	self:_start_action_throw_grenade(t, input)

	local wep_base = self._equipped_unit:base()

	return action_wanted
end
--THROW GRENADE: SPRINTING BUFFERING
function PlayerStandard:_start_action_throw_grenade(t, input)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self:_interupt_changing_weapon(t)

	local equipped_grenade = managers.blackmarket:equipped_grenade()
	local projectile_tweak = tweak_data.blackmarket.projectiles[equipped_grenade]

	if self._projectile_global_value then
		self._camera_unit:anim_state_machine():set_global(self._projectile_global_value, 0)

		self._projectile_global_value = nil
	end

	if projectile_tweak.anim_global_param then
		self._projectile_global_value = projectile_tweak.anim_global_param

		self._camera_unit:anim_state_machine():set_global(self._projectile_global_value, 1)
	end

	local delay = self:_get_projectile_throw_offset()

	managers.network:session():send_to_peers_synched("play_distance_interact_redirect_delay", self._unit, "throw_grenade", delay)
	self._ext_camera:play_redirect(Idstring(projectile_tweak.animation or "throw_grenade"))

	local projectile_data = tweak_data.blackmarket.projectiles[equipped_grenade]
	self._state_data.throw_grenade_expire_t = t + (projectile_data.expire_t or 1.1)

	self:_stance_entered()

	if self._setting_hold_to_run then
		self._running_wanted = input.btn_run_state
	elseif not self:get_animation("stop_running") then
		self._running_wanted = true
	end
end

function PlayerStandard:_check_action_throw_projectile(t, input)
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_tweak = tweak_data.blackmarket.projectiles[projectile_entry]

	if projectile_tweak.is_a_grenade then
		return self:_check_action_throw_grenade(t, input)
	elseif projectile_tweak.ability then
		return self:_check_action_use_ability(t, input)
	end

	if self._state_data.projectile_throw_wanted then
		if not self._state_data.projectile_throw_allowed_t then
			self._state_data.projectile_throw_wanted = nil

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_wanted = input.btn_projectile_press or input.btn_projectile_release or self._state_data.projectile_idle_wanted

	if not action_wanted then
		return
	end

	if not managers.player:can_throw_grenade() then
		self._state_data.projectile_throw_wanted = nil
		self._state_data.projectile_idle_wanted = nil

		return
	end

	if input.btn_projectile_release then
		if self._state_data.throwing_projectile then
			if self._state_data.projectile_throw_allowed_t then
				self._state_data.projectile_throw_wanted = true

				return
			end

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_forbidden = (
		not PlayerBase.USE_GRENADES
		or not self:_projectile_repeat_allowed()
		or self:chk_action_forbidden("interact")
		or self:_interacting()
		or self:is_deploying()
		--or self:_changing_weapon()
		or self:_is_meleeing()
		or self:_is_using_bipod()
		or not self._movement_equipped
	)

	if action_forbidden then
		return
	end

	self:_start_action_throw_projectile(t, input)

	return true
end
function PlayerStandard:_start_action_throw_projectile(t, input)
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self:_interupt_changing_weapon(t)

	self._state_data.projectile_idle_wanted = nil
	self._state_data.throwing_projectile = true
	self._state_data.projectile_start_t = nil
	local projectile_entry = managers.blackmarket:equipped_projectile()

	self:_stance_entered()

	if self._state_data.projectile_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 0)
	end

	self._state_data.projectile_global_value = tweak_data.blackmarket.projectiles[projectile_entry].anim_global_param or "projectile_frag"

	self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 1)

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self:get_animation("base"))
	local throw_allowed_expire_t = tweak_data.blackmarket.projectiles[projectile_entry].throw_allowed_expire_t or 0.15
	self._state_data.projectile_throw_allowed_t = t + (current_state_name ~= self:get_animation("projectile_throw_state") and throw_allowed_expire_t or 0)

	if current_state_name == self:get_animation("projectile_throw_state") then
		self._ext_camera:play_redirect(self:get_animation("projectile_idle"))

		return
	end

	local offset = nil

	if current_state_name == self:get_animation("projectile_exit_state") then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(self:get_animation("base"))
		offset = (1 - segment_relative_time) * 0.9
	end

	self._ext_camera:play_redirect(self:get_animation("projectile_enter"), nil, offset)
end
--THROW INTERUPT: BOLT DROPPED CHECK
function PlayerStandard:_interupt_action_throw_projectile(t)
	if not self:_is_throwing_projectile() then
		return
	end

	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	self._state_data.projectile_idle_wanted = nil
	self._state_data.projectile_expire_t = nil
	self._state_data.projectile_throw_allowed_t = nil
	self._state_data.throwing_projectile = nil
	self._camera_unit_anim_data.throwing = nil

	self._ext_camera:play_redirect(self:get_animation("equip"))
	wep_base:tweak_data_anim_stop("unequip")
	wep_base:tweak_data_anim_play("equip")
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()
	self:_stance_entered()
end
function PlayerStandard:_interupt_action_throw_grenade(t, input)
	if not self:_is_throwing_grenade() then
		return
	end

	self._ext_camera:play_redirect(self:get_animation("equip"))
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()

	self._state_data.throw_grenade_expire_t = nil

	self:_stance_entered()
end



--DO MELEE: RATE OF FIRE
function PlayerStandard:_do_action_melee(t, input, skip_damage)
	self._state_data.meleeing = nil
	local wep_base = self._equipped_unit:base()
	local wep_weight = wep_base._current_stats.weight
	local is_secondary = wep_base:weapon_tweak_data().use_data.selection_index==1 and 1 or 1
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local pre_calc_hit_ray = tweak_data.blackmarket.melee_weapons[melee_entry].hit_pre_calculation
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	self._state_data.melee_expire_t = t + (tweak_data.blackmarket.melee_weapons[melee_entry].expire_t + wep_weight/100) / is_secondary
	self._state_data.melee_repeat_expire_t = t + (math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t) + wep_weight/100) / is_secondary

	if melee_damage_delay~=0 and not skip_damage then
		self._state_data.melee_damage_delay_t = t + melee_damage_delay

		if pre_calc_hit_ray then
			self._state_data.melee_hit_ray = self:_calc_melee_hit_ray(t, 20) or true
		else
			self._state_data.melee_hit_ray = nil
		end
	end

	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"

	if instant_hit then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	else
		self._ext_network:send("sync_melee_discharge")
	end

	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self._melee_attack_var = 0

	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)

		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_bayonet") or self:get_animation("melee"))
		else
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_miss_bayonet") or self:get_animation("melee_miss"))
		end
	else
		local state = self._ext_camera:play_redirect(self:get_animation("melee_attack"))
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		self._melee_attack_var = anim_attack_vars and math.random(#anim_attack_vars)

		self:_play_melee_sound(melee_entry, "hit_air", self._melee_attack_var)

		local melee_item_tweak_anim = "attack"
		local melee_item_prefix = ""
		local melee_item_suffix = ""
		local anim_attack_param = anim_attack_vars and anim_attack_vars[self._melee_attack_var]

		if anim_attack_param then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_param, 1)

			melee_item_prefix = anim_attack_param .. "_"
		end

		if self._state_data.melee_hit_ray and self._state_data.melee_hit_ray ~= true then
			self._camera_unit:anim_state_machine():set_parameter(state, "hit", 1)

			melee_item_suffix = "_hit"
		end

		melee_item_tweak_anim = melee_item_prefix .. melee_item_tweak_anim .. melee_item_suffix

		self._camera_unit:base():play_anim_melee_item(melee_item_tweak_anim)
	end
end
--DO MELEE DAMAGE: WEIGHT DEPENDANCY, STAMINA DRAIN
function PlayerStandard:_do_melee_damage(t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
	melee_entry = melee_entry or managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	local charge_lerp_value = instant_hit and 0 or self:_get_melee_charge_lerp_value(t, melee_damage_delay)

	self._ext_camera:play_shaker(melee_vars[math.random(#melee_vars)], math.max(0.3, charge_lerp_value))

	local wep_base = self._equipped_unit:base()
	local wep_weight = wep_base._current_stats.weight
	local stamina_factor = self._unit:movement():is_above_stamina_threshold() and 1 or 3
	self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.1 * (1+wep_weight/30) / managers.player:body_armor_value("stamina"))
	self._ext_movement:activate_regeneration()

	local sphere_cast_radius = 20
	local col_ray = nil

	if melee_hit_ray then
		col_ray = melee_hit_ray ~= true and melee_hit_ray or nil
	else
		col_ray = self:_calc_melee_hit_ray(t, sphere_cast_radius)
	end

	if col_ray and alive(col_ray.unit) then
		local damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info(charge_lerp_value)
		local damage_effect_mul = math.max(managers.player:upgrade_value("player", "melee_knockdown_mul", 1), managers.player:upgrade_value(self._equipped_unit:base():weapon_tweak_data().categories and self._equipped_unit:base():weapon_tweak_data().categories[1], "melee_knockdown_mul", 1))
		damage = damage -- * managers.player:get_melee_dmg_multiplier()
		damage_effect = damage_effect * damage_effect_mul
		col_ray.sphere_cast_radius = sphere_cast_radius
		local hit_unit = col_ray.unit

		if hit_unit:character_damage() then
			if bayonet_melee then
				self._unit:sound():play("fairbairn_hit_body", nil, false)
			else
				local hit_sfx = "hit_body"

				if hit_unit:character_damage() and hit_unit:character_damage().melee_hit_sfx then
					hit_sfx = hit_unit:character_damage():melee_hit_sfx()
				end

				self:_play_melee_sound(melee_entry, hit_sfx, self._melee_attack_var)
			end

			if not hit_unit:character_damage()._no_blood then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray
				})
				managers.game_play_central:play_impact_sound_and_effects({
					no_decal = true,
					no_sound = true,
					col_ray = col_ray
				})
			end

			self._camera_unit:base():play_anim_melee_item("hit_body")
		else
			if self._on_melee_restart_drill and hit_unit:base() and (hit_unit:base().is_drill or hit_unit:base().is_saw) and hit_unit:interaction().check_for_upgrade then
				hit_unit:base():on_melee_hit(managers.network:session():local_peer():id())
			end

			if bayonet_melee then
				self._unit:sound():play("knife_hit_gen", nil, false)
			else
				self:_play_melee_sound(melee_entry, "hit_gen", self._melee_attack_var)
			end

			self._camera_unit:base():play_anim_melee_item("hit_gen")
			managers.game_play_central:play_impact_sound_and_effects({
				no_decal = true,
				no_sound = true,
				col_ray = col_ray,
				effect = Idstring("effects/payday2/particles/impacts/fallback_impact_pd2")
			})
		end

		local custom_data = nil

		if _G.IS_VR and hand_id then
			custom_data = {
				engine = hand_id == 1 and "right" or "left"
			}
		end

		managers.rumble:play("melee_hit", nil, nil, custom_data)
		managers.game_play_central:physics_push(col_ray)

		local character_unit, shield_knock = nil
		local can_shield_knock = managers.player:has_category_upgrade("player", "shield_knock")

		if can_shield_knock and hit_unit:in_slot(8) and alive(hit_unit:parent()) and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
			shield_knock = true
			character_unit = hit_unit:parent()
		end

		character_unit = character_unit or hit_unit

		if character_unit:character_damage() and character_unit:character_damage().damage_melee then
			local dmg_multiplier = 1

			if not managers.enemy:is_civilian(character_unit) and not managers.groupai:state():is_enemy_special(character_unit) then
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "non_special_melee_multiplier", 1)
			else
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_damage_multiplier", 1)
			end

			dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "melee_" .. tostring(tweak_data.blackmarket.melee_weapons[melee_entry].stats.weapon_type) .. "_damage_multiplier", 1)

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if stack[1] and t < stack[1] then
					dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2])
				else
					stack[2] = 0
				end
			end

			local health_ratio = self._ext_damage:health_ratio()
			local damage_health_ratio = managers.player:get_damage_health_ratio(health_ratio, "melee")

			if damage_health_ratio > 0 then
				local damage_ratio = damage_health_ratio
				dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) * damage_ratio)
			end

			dmg_multiplier = dmg_multiplier * managers.player:temporary_upgrade_value("temporary", "berserker_damage_multiplier", 1)
			local target_dead = character_unit:character_damage().dead and not character_unit:character_damage():dead()
			local target_hostile = managers.enemy:is_enemy(character_unit) and not tweak_data.character[character_unit:base()._tweak_table].is_escort and character_unit:brain():is_hostile()
			local life_leach_available = managers.player:has_category_upgrade("temporary", "melee_life_leech") and not managers.player:has_activate_temporary_upgrade("temporary", "melee_life_leech")

			if target_dead and target_hostile and life_leach_available then
				managers.player:activate_temporary_upgrade("temporary", "melee_life_leech")
				self._unit:character_damage():restore_health(managers.player:temporary_upgrade_value("temporary", "melee_life_leech", 1))
			end

			local action_data = {
				variant = "melee"
			}

			if _G.IS_VR and melee_entry == "weapon" and not bayonet_melee then
				dmg_multiplier = 0.1
			end

			action_data.damage = shield_knock and 0 or damage * 8 * (1+wep_weight/100) / stamina_factor --dmg_multiplier
			action_data.damage_effect = damage_effect
			action_data.attacker_unit = self._unit
			action_data.col_ray = col_ray

			if shield_knock then
				action_data.shield_knock = can_shield_knock
			end

			action_data.name_id = melee_entry
			action_data.charge_lerp_value = charge_lerp_value

			if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
				self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
				self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
					nil,
					0
				}
				local stack = self._state_data.stacking_dmg_mul.melee

				if character_unit:character_damage().dead and not character_unit:character_damage():dead() then
					stack[1] = t + managers.player:upgrade_value("melee", "stacking_hit_expire_t", 1)
					stack[2] = math.min(stack[2] + 1, tweak_data.upgrades.max_melee_weapon_dmg_mul_stacks or 5)
				else
					stack[1] = nil
					stack[2] = 0
				end
			end

			local defense_data = character_unit:character_damage():damage_melee(action_data)

			self:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
			self:_perform_sync_melee_damage(hit_unit, col_ray, action_data.damage)

			if tweak_data.blackmarket.melee_weapons[melee_entry].tase_data and character_unit:character_damage().damage_tase then
				local action_data = {
					variant = tweak_data.blackmarket.melee_weapons[melee_entry].tase_data.tase_strength,
					damage = 0,
					attacker_unit = self._unit,
					col_ray = col_ray
				}

				character_unit:character_damage():damage_tase(action_data)
			end

			if tweak_data.blackmarket.melee_weapons[melee_entry].fire_dot_data and character_unit:character_damage().damage_fire then
				local action_data = {
					variant = "fire",
					damage = 0,
					attacker_unit = self._unit,
					col_ray = col_ray,
					fire_dot_data = tweak_data.blackmarket.melee_weapons[melee_entry].fire_dot_data
				}

				character_unit:character_damage():damage_fire(action_data)
			end

			return defense_data
		else
			self:_perform_sync_melee_damage(hit_unit, col_ray, damage)
		end
	end

	if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
		self._state_data.stacking_dmg_mul = self._state_data.stacking_dmg_mul or {}
		self._state_data.stacking_dmg_mul.melee = self._state_data.stacking_dmg_mul.melee or {
			nil,
			0
		}
		local stack = self._state_data.stacking_dmg_mul.melee
		stack[1] = nil
		stack[2] = 0
	end

	return col_ray
end
function PlayerStandard:_calc_melee_hit_ray(t, sphere_cast_radius)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local wep_base = self._equipped_unit:base()
	range = managers.blackmarket:equipped_bayonet(wep_base.name_id) and (wep_base._length*2.54)+10 or range
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range

	return self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
end
function PlayerStandard:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
	if not defense_data or defense_data.type == "death" then
		return
	end

	local dot_data = tweak_data.blackmarket.melee_weapons[melee_entry].dot_data

	if not dot_data then
		return
	end

	local data = managers.dot:create_dot_data(dot_data.type, dot_data.custom_data)
	local damage_class = CoreSerialize.string_to_classtable(data.damage_class)

	damage_class:start_dot_damage(col_ray, nil, data, melee_entry)
end
--CHECK MELEE: BOLTING INTERUPT
function PlayerStandard:_check_action_melee(t, input)
	if self._state_data.melee_attack_wanted then
		if not self._state_data.melee_attack_allowed_t then
			self._state_data.melee_attack_wanted = nil

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_wanted = input.btn_melee_press or input.btn_melee_release or self._state_data.melee_charge_wanted

	if not action_wanted then
		return
	end

	if input.btn_melee_release then
		if self._state_data.meleeing then
			if self._state_data.melee_attack_allowed_t then
				self._state_data.melee_attack_wanted = true

				return
			end

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_forbidden =
		not self:_melee_repeat_allowed()
		or self._use_item_expire_t
		or (self._equip_weapon_expire_t and self._equip_weapon_expire_t0)
		or self:_interacting()
		or self:_is_throwing_projectile()
		or self:_is_using_bipod()
		or self:is_shooting_count()
		or not self._movement_equipped
		or self._state_data.lying

	if action_forbidden then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant = tweak_data.blackmarket.melee_weapons[melee_entry].instant

	self._unequip_weapon_expire_t = nil
	self:_start_action_melee(t, input, instant)
	local wep_base = self._equipped_unit:base()
	self._running_enter_end_t = nil
	self._running_exit_start_t = nil

	return true
end
--JUMP: STAMINA DRAIN
function PlayerStandard:_check_action_jump(t, input)
	local new_action = nil
	local action_wanted = input.btn_jump_press

	if action_wanted then
		local action_forbidden = self._jump_t and t < self._jump_t + 0.55
		action_forbidden = action_forbidden or self._state_data.in_air or self:_interacting() or self:_on_zipline() or self:_does_deploying_limit_movement() or self:_is_using_bipod() --or self._unit:base():stats_screen_visible()

		if not action_forbidden then
			if self._state_data.lying then
				self:_interupt_action_ducking(t)
			elseif self._state_data.ducking then
				self:_interupt_action_ducking(t)
			else
				if self._state_data.on_ladder then
					self:_interupt_action_ladder(t)
				end
				--else
					local action_start_data = {}
					local jump_vel_z = tweak_data.player.movement_state.standard.movement.jump_velocity.z * (not self._unit:movement():is_above_stamina_threshold() and 0.5 or 1)
					local armor = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)].upgrade_level
					action_start_data.jump_vel_z = jump_vel_z * (armor<=2 and 1.1 or 1)

					if self._move_dir then
						local is_running = self._running and self._unit:movement():is_above_stamina_threshold() and t - self._start_running_t > 0.4
						local jump_vel_xy = tweak_data.player.movement_state.standard.movement.jump_velocity.xy[is_running and "run" or "walk"]
						action_start_data.jump_vel_xy = self._unit:movement().move_speed:length()
						action_start_data.jump_vel_z = math.max(0, action_start_data.jump_vel_z - (action_start_data.jump_vel_xy*0.2))
					end

					new_action = self:_start_action_jump(t, action_start_data)
					self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN / managers.player:body_armor_value("stamina"))
					self._unit:movement():activate_regeneration()
					self._ext_camera:play_shaker("player_enter_zipline")
				--end
			end
		end
	end

	return new_action
end
function PlayerStandard:_start_action_jump(t, action_start_data)
	if self._running and not self.RUN_AND_RELOAD and not self._equipped_unit:base():run_and_shoot_allowed() then
		self:_interupt_action_reload(t)
		self._ext_camera:play_redirect(self:get_animation("stop_running"), self._equipped_unit:base():exit_run_speed_multiplier())
		self._ext_network:send("set_stance", 3, false, false)
	end

	self:_interupt_action_running(t)

	self._jump_t = t
	local jump_vec = action_start_data.jump_vel_z * math.UP

	self._unit:mover():jump()

	if self._move_dir then
		local move_dir_clamp = self._move_dir:normalized() * math.min(1, self._move_dir:length())
		self._last_velocity_xy = move_dir_clamp * action_start_data.jump_vel_xy
		self._jump_vel_xy = mvector3.copy(self._last_velocity_xy)
	else
		self._last_velocity_xy = Vector3()
	end

	self:_perform_jump(jump_vec)
end



--WALK HEADBOB: TWEAK
function PlayerStandard:_get_walk_headbob()
	if self._state_data.in_air then
		return 0
	elseif self._state_data.using_bipod then
		return 0.01
	else
		return (self._state_data.ducking and 0.04 or 0.02) * (self._state_data.in_steelsight and 0.5 or 1)
	end
end
--CHECK RUN: BOLTING INTERUPT
function PlayerStandard:_check_action_run(t, input)
	if self._state_data.lying then return end

	if self._setting_hold_to_run and input.btn_run_release or self._running and not self._move_dir then
		self._running_wanted = false

		if self._running then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	elseif not self._setting_hold_to_run and input.btn_run_release and not self._move_dir then
		self._running_wanted = false
	elseif input.btn_run_press or self._running_wanted then
		if not self._running or self._end_running_expire_t then
			self:_start_action_running(t)
		elseif self._running and not self._setting_hold_to_run then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	end
end
--START RUN: DELAYED FIRE CHECK
function PlayerStandard:_start_action_running(t)
	if self._state_data.getup_t then self._running_wanted = true return end
	if self._slowdown_run_prevent then self._running_wanted = false return end
	if not self._move_dir then self._running_wanted = true return end
	if self:on_ladder() or self:_on_zipline() then return end

	if self:shooting() and not self._equipped_unit:base():run_and_shoot_allowed()
	or self:_changing_weapon()
	or self:_is_meleeing()
	or self._use_item_expire_t
	or self._state_data.in_air
	or self:_is_throwing_projectile()
	or self:_is_charging_weapon()
	or self._state_data.ducking and not self:_can_stand()
	or self._end_running_expire_t then
		self._running_wanted = true
		return
	end
	if not self:_can_run_directional() then return end

	self._running_wanted = false

	if managers.player:get_player_rule("no_run") then return end
	if not self._unit:movement():is_above_stamina_threshold() then return end

	if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_headbob") then
		self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
	end

	self:set_running(true)

	self._end_running_expire_t = nil
	self._start_running_t = t
	self._play_stop_running_anim = nil

	if not self:_is_reloading() or not self.RUN_AND_RELOAD then
		if not self._equipped_unit:base():run_and_shoot_allowed() then
			if self._wall_equipped then
				self._ext_camera:play_redirect(self:get_animation("start_running"))
				self._ext_network:send("set_stance", 2, false, false)
			end
		else
			self._ext_camera:play_redirect(self:get_animation("idle"))
		end
	end

	if not self.RUN_AND_RELOAD then
		self:_interupt_action_reload(t)
	end

	local wep_base = self._equipped_unit:base()
	self:_interupt_action_steelsight(t)
	self:_interupt_action_ducking(t)
end
function PlayerStandard:_end_action_running(t)
	if not self._end_running_expire_t then
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		local stop_running = not self._equipped_unit:base():run_and_shoot_allowed() and (not self.RUN_AND_RELOAD or not self:_is_reloading())

		if stop_running and self._wall_equipped then
			local wep_base = self._equipped_unit:base()
			local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
			self._ext_camera:play_redirect(self:get_animation("stop_running"), 1-(1-anim_spd)*(wep_base._current_stats.shouldered and 0.8 or 0.2))
			self._ext_network:send("set_stance", 3, false, false)
			self._equip_weapon_expire_t = t + (eq_t*0.8)
		end
	end
end
function PlayerStandard:set_running(running)
	self._running = running

	self._unit:movement():set_running(self._running)
	self._ext_network:send("action_change_run", running)
end
--PLAYER GRAVITY ON STATE CHANGE
function PlayerStandard:_activate_mover(mover, velocity)
	self._unit:activate_mover(mover, velocity)

	if self._state_data.on_ladder then
		self._unit:mover():set_gravity(Vector3(0, 0, 0))
	else
		self._unit:mover():set_gravity(Vector3(0, 0, -(982*2)))
	end

	if self._is_jumping then
		self._unit:mover():jump()
		self._unit:mover():set_velocity(velocity)
	end
end
function PlayerStandard:_end_action_ladder(t, input)
	if not self._state_data.on_ladder then return end

	self._state_data.on_ladder = false

	if self._unit:mover() then
		self._unit:mover():set_gravity(Vector3(0, 0, -(982*2)))
	end

	self._unit:movement():on_exit_ladder()
end
--CHECK LADDER: LYING RESTRICTION
function PlayerStandard:_check_action_ladder(t, input)
	if self._state_data.lying then return end

	if self._state_data.on_ladder then
		local ladder_unit = self._unit:movement():ladder_unit()
		if ladder_unit:ladder():check_end_climbing(self._unit:movement():m_pos(), self._normal_move_dir, self._gnd_ray) then self:_end_action_ladder() end
		return
	end

	if not self._move_dir then return end

	local u_pos = self._unit:movement():m_pos()
	for i = 1, math.min(Ladder.LADDERS_PER_FRAME, #Ladder.active_ladders) do
		local ladder_unit = Ladder.next_ladder()
		if alive(ladder_unit) then
			if ladder_unit:ladder():can_access(u_pos, self._move_dir) then
				self:_start_action_ladder(t, ladder_unit)
				break
			end
		end
	end
end
--FALL: NQR_FORCE_REEQUIP ON FALL DUCK, LANDING SHAKER DYNAMIC, ROTANIM
function PlayerStandard:_update_foley(t, input)
	if self.nqr_rotanim_ready_t and self.nqr_rotanim_ready_t <= t then self.nqr_rotanim_ready_t = nil end
	if self.nqr_rotanim_notready_t and self.nqr_rotanim_notready_t <= t then self.nqr_rotanim_notready_t = nil end
	if self.nqr_rotanim_t and self.nqr_rotanim_t <= t then self.nqr_rotanim_t = nil self._unit:sound():play("bar_bag_generic_cancel") end

	if self._state_data.on_zipline then return end

	if not self._gnd_ray and not self._state_data.on_ladder then
		if not self._state_data.in_air then
			self._state_data.in_air = true
			self._state_data.enter_air_pos_z = self._pos.z

			self:_interupt_action_running(t)
			self._unit:set_driving("orientation_object")
		end
	elseif self._state_data.in_air then
		self._unit:set_driving("script")

		self._state_data.in_air = false
		local from = self._pos + math.UP * 10
		local to = self._pos - math.UP * 60
		local material_name, pos, norm = World:pick_decal_material(from, to, self._slotmask_foley_ray)

		self._unit:sound():play_land(material_name)

		local playerdamage = self._unit:character_damage()
		local damage_fall, damage_to_take = playerdamage:damage_fall({height = self._state_data.enter_air_pos_z - self._pos.z})
		if damage_fall then
			self._running_wanted = false

			managers.rumble:play("hard_land")
			self._ext_camera:play_shaker("player_fall_damage")

			if damage_to_take<playerdamage:get_real_health() and self.nqr_rotanim_ready_t and (self._camera_unit:base()._output_data.rotation:pitch()<-60) then
				managers.mission._fading_debug_output:script().log("nqr_rotanim",  Color.red)
				self.nqr_rotanim_t = t + 0.6*self:_armor_penalty_mul("movement")
				self._camera_unit:base():animate_pitch(t, nil, 0, 0.6)
				self._camera_unit:base():nqr_rotanim_init(t, nil, -360, 1.2*self:_armor_penalty_mul("movement"))
				self._state_data.getup_t = self.nqr_rotanim_t
				playerdamage:change_health(-math.max(0, damage_to_take-4))
				self._unit:sound():play("bar_bag_generic")
			else
				if self._state_data.lying then
					self:_start_action_lying(t)
				else
					managers.mission._fading_debug_output:script().log("nqr_force_reequip on fall duck",  Color.red)
					managers.hud:on_hit_direction(Vector3(0, 0, 0), HUDHitDirection.DAMAGE_TYPES.HEALTH, 0)
					self._camera_unit:base():set_pitch(-70)
					self._state_data.getup_t = damage_to_take*0.5
					self:_nqr_force_reequip(t)
					playerdamage:_calc_armor_damage({damage = damage_to_take*4})
					if playerdamage:get_real_armor()>0 then self:_start_action_ducking(t, 0.4) end
				end
				playerdamage:change_health(-damage_to_take)
			end
		elseif input.btn_run_state then
			self._running_wanted = true
		end

		self._jump_t = nil
		self._jump_vel_xy = nil

		self._ext_camera:stop_shaker("player_enter_zipline")
		if not self.nqr_rotanim_ready_t then self._ext_camera:play_shaker("player_land", 0.5 * (1 + ((self._state_data.enter_air_pos_z-self._pos.z)*0.05))) end
		managers.rumble:play("land")
	elseif self._jump_vel_xy and t - self._jump_t > 0.3 then
		self._jump_vel_xy = nil

		if input.btn_run_state then
			self._running_wanted = true
		end
	end

	self:_check_step(t)
end
--WALK SPEED TWEAK
function PlayerStandard:_get_max_walk_speed(t, force_run)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.STANDARD_MAX
	local speed_state = "walk"
	local is_lying = self._state_data.lying and 0.4 or 1
	local is_steelsight = (self._state_data.in_steelsight and not managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and not _G.IS_VR) and 0.9 or 1

	if self._state_data.on_ladder then
		movement_speed = speed_tweak.CLIMBING_MAX
		speed_state = "climb"
	elseif self._running or force_run then
		movement_speed = speed_tweak.RUNNING_MAX
		speed_state = "run"
	elseif self._state_data.ducking then
		movement_speed = speed_tweak.CROUCHING_MAX
		speed_state = "crouch"
	elseif self._state_data.in_air then
		movement_speed = speed_tweak.INAIR_MAX
		speed_state = nil
	end

	if self.nqr_rotanim_t then
		movement_speed = speed_tweak.STANDARD_MAX + (speed_tweak.RUNNING_MAX-speed_tweak.STANDARD_MAX)*0.5
		speed_state = nil
	end

	movement_speed = managers.modifiers:modify_value("PlayerStandard:GetMaxWalkSpeed", movement_speed, self._state_data, speed_tweak)
	local morale_boost_bonus = self._ext_movement:morale_boost()
	local multiplier = managers.player:movement_speed_multiplier(speed_state, speed_state and morale_boost_bonus and morale_boost_bonus.move_speed_bonus, nil, self._ext_damage:health_ratio())
	multiplier = multiplier * (self._tweak_data.movement.multiplier[speed_state] or 1)
	local apply_weapon_penalty = true

	if self:_is_meleeing() then
		apply_weapon_penalty = not tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.remove_weapon_movement_penalty
	end

	if alive(self._equipped_unit) and apply_weapon_penalty then
		multiplier = multiplier * self._equipped_unit:base():movement_penalty()
		multiplier = multiplier * managers.player:upgrade_value(self._equipped_unit:base():get_name_id(), "increased_movement_speed", 1)
	end

	if self._slowdown_mul then multiplier = multiplier * self._slowdown_mul end

	local final_speed = movement_speed * multiplier
	self._cached_final_speed = self._cached_final_speed or 0

	if final_speed ~= self._cached_final_speed then
		self._cached_final_speed = final_speed
		self._ext_network:send("action_change_speed", final_speed)
	end

	return final_speed * is_steelsight * is_lying
end
--ADD ROTANIM FACTOR
function PlayerStandard:_determine_move_direction()
	if self._state_data.on_zipline then return end

	if self._stop_moving then self._move_dir = nil return end

	if self.nqr_rotanim_t then
		local rot = Vector3()
		mvector3.set(rot, self._camera_unit:base()._output_data.rotation:y())
		mvector3.set_z(rot, 0)
		mvector3.normalize(rot)
		self._move_dir = Vector3(0, 1, 0)
		mvector3.rotate_with(self._move_dir, Rotation(rot, math.UP))
		self._normal_move_dir = mvector3.copy(self._move_dir)
		return
	end

	self._stick_move = self._controller:get_input_axis("move")
	if mvector3.length(self._stick_move) < PlayerStandard.MOVEMENT_DEADZONE or self:_interacting() or self:_does_deploying_limit_movement() then
		self._move_dir = nil
		self._normal_move_dir = nil
	else
		local ladder_unit = self._unit:movement():ladder_unit()

		if alive(ladder_unit) then
			local ladder_ext = ladder_unit:ladder()
			self._move_dir = mvector3.copy(self._stick_move)
			self._normal_move_dir = mvector3.copy(self._move_dir)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._normal_move_dir, cam_flat_rot)

			local cam_rot = Rotation(self._cam_fwd, self._ext_camera:rotation():z())

			mvector3.rotate_with(self._move_dir, cam_rot)

			local up_dot = math.dot(self._move_dir, ladder_ext:up())
			local w_dir_dot = math.dot(self._move_dir, ladder_ext:w_dir())
			local normal_dot = math.dot(self._move_dir, ladder_ext:normal()) * -1
			local normal_offset = ladder_ext:get_normal_move_offset(self._unit:movement():m_pos())

			mvector3.set(self._move_dir, ladder_ext:up() * (up_dot + normal_dot))
			mvector3.add(self._move_dir, ladder_ext:w_dir() * w_dir_dot)
			mvector3.add(self._move_dir, ladder_ext:normal() * normal_offset)
		else
			self._move_dir = mvector3.copy(self._stick_move)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._move_dir, cam_flat_rot)

			self._normal_move_dir = mvector3.copy(self._move_dir)
		end
	end
end
--MOVEMENT REFACTOR, HEADBOB REFACTOR
function PlayerStandard:_update_movement(t, dt)
	if self._state_data.lying_t and t>self._state_data.lying_t then self._state_data.lying_t = nil end
	if self._state_data.getup_t and t>self._state_data.getup_t then self._state_data.getup_t = nil end

	local anim_data = self._unit:anim_data()
	local weapon_id = alive(self._equipped_unit) and self._equipped_unit:base() and self._equipped_unit:base():get_name_id()
	local weapon_tweak_data = weapon_id and tweak_data.weapon[weapon_id]
	local pos_new = nil
	self._target_headbob = self._target_headbob or 0
	self._headbob = self._headbob or 0

	if self._state_data.on_zipline and self._state_data.zipline_data.position then
		local speed = mvector3.length(self._state_data.zipline_data.position - self._pos) / dt / 500
		pos_new = mvec_pos_new
		mvector3.set(pos_new, self._state_data.zipline_data.position)
		if self._state_data.zipline_data.camera_shake then self._ext_camera:shaker():set_parameter(self._state_data.zipline_data.camera_shake, "amplitude", speed) end
		if alive(self._state_data.zipline_data.zipline_unit) then
			local dot = mvector3.dot(self._ext_camera:rotation():x(), self._state_data.zipline_data.zipline_unit:zipline():current_direction())
			self._ext_camera:camera_unit():base():set_target_tilt(dot * 10 * speed)
		end
		self._target_headbob = 0
	elseif self._move_dir and not (self._state_data.lying_t) then
		local enter_moving = not self._moving
		self._moving = true

		if enter_moving then
			self._last_sent_pos_t = t

			self:_update_crosshair_offset()
		end

		local WALK_SPEED_MAX = self:_get_max_walk_speed(t)

		mvector3.set(mvec_move_dir_normalized, self._move_dir)
		mvector3.normalize(mvec_move_dir_normalized)

		local wanted_walk_speed = WALK_SPEED_MAX * math.min(1, self._move_dir:length())
		local acceleration = (self._state_data.in_air and 1200 or 1500) * managers.player:body_armor_value("movement", nil, 1)
		local achieved_walk_vel = mvec_achieved_walk_vel

		if self._jump_vel_xy and self._state_data.in_air and mvector3.dot(self._jump_vel_xy, self._last_velocity_xy) > 0 then
			local input_move_vec = wanted_walk_speed * self._move_dir
			local jump_dir = mvector3.copy(self._last_velocity_xy)
			local jump_vel = mvector3.normalize(jump_dir)
			local fwd_dot = jump_dir:dot(input_move_vec)

			if fwd_dot < jump_vel then
				local sustain_dot = (input_move_vec:normalized() * jump_vel):dot(jump_dir)
				local new_move_vec = input_move_vec + jump_dir * (sustain_dot - fwd_dot)

				mvector3.step(achieved_walk_vel, self._last_velocity_xy, new_move_vec, 700 * dt)
			else
				mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
				mvector3.step(achieved_walk_vel, self._last_velocity_xy, wanted_walk_speed * self._move_dir:normalized(), acceleration * dt)
			end

			local fwd_component = nil
		else
			mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
			mvector3.step(achieved_walk_vel, self._last_velocity_xy, mvec_move_dir_normalized, acceleration * dt)
		end

		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = self:_get_walk_headbob() * (achieved_walk_vel:length()/WALK_SPEED_MAX)
		self._target_headbob = self._target_headbob * (1 + (WALK_SPEED_MAX * 0.005)) --* self._move_dir:length()

		local offset = 0
		if self._running then offset = 0.2 elseif self._state_data.ducking then offset = -0.3 end
		self._headbob_offset = (self._headbob_offset or 0) + (offset * dt)
	elseif not mvector3.is_zero(self._last_velocity_xy) then
		local decceleration = self._state_data.in_air and 250 or math.lerp(2000, 1500, math.min(self._last_velocity_xy:length() / tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX, 1))
		local achieved_walk_vel = math.step(self._last_velocity_xy, Vector3(), decceleration * dt)
		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = 0
	elseif self._moving then
		self._target_headbob = 0
		self._moving = false

		self:_update_crosshair_offset()
	end

	if self._headbob ~= self._target_headbob then
		self._headbob = math.step(self._headbob, self._target_headbob, dt / 8)
		self._ext_camera:set_shaker_parameter("headbob", "amplitude", self._headbob)
	end
	self._ext_camera:set_shaker_parameter("headbob", "frequency", 1.0)
	self._ext_camera:set_shaker_parameter("headbob", "offset", self._headbob_offset or 0)

	local ground_z = self:_chk_floor_moving_pos()

	if ground_z and not self._is_jumping then
		if not pos_new then
			pos_new = mvec_pos_new

			mvector3.set(pos_new, self._pos)
		end

		mvector3.set_z(pos_new, ground_z)
	end

	if pos_new then
		self._unit:movement():set_position(pos_new)
		mvector3.set(self._last_velocity_xy, pos_new)
		mvector3.subtract(self._last_velocity_xy, self._pos)

		if not self._state_data.on_ladder and not self._state_data.on_zipline then
			mvector3.set_z(self._last_velocity_xy, 0)
		end

		mvector3.divide(self._last_velocity_xy, dt)
	else
		mvector3.set_static(self._last_velocity_xy, 0, 0, 0)
	end

	local cur_pos = pos_new or self._pos

	self:_update_network_jump(cur_pos, false)
	self:_update_network_position(t, dt, cur_pos, pos_new)

	self._unit:movement().move_speed = self._last_velocity_xy

	if self._running_enter_end_t and t>self._running_enter_end_t then
		self._running_enter_end_t = nil
		self._ext_camera:play_redirect(self:get_animation("start_running"), 0, 15/30)
	end
	if not self._running_enter_end_t and self._running_exit_start_t and t>self._running_exit_start_t then
		local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
		if not ((self._running and not self._end_running_expire_t)) then
			self._ext_camera:play_redirect(self:get_animation("stop_running"), self._running_exit_mul)
			self._ext_network:send("set_stance", 3, false, false)
		else
			self._ext_camera:play_redirect(self:get_animation("start_running"), 1, 24/30)
		end
		self._wall_unequip_t = t + (eq_t*0.8)
		self._running_exit_start_t = nil
		self._running_exit_mul = nil
	end
end
--CHECK STEP: SPRINT SHAKE
function PlayerStandard:_check_step(t)
	if self._state_data.in_air then
		return
	end

	self._last_step_pos = self._last_step_pos or Vector3()
	local step_length = (
		self._state_data.on_ladder and 50 or
		self._state_data.in_steelsight and (managers.player:has_category_upgrade("player", "steelsight_normal_movement_speed") and 150 or 100) or
		self._state_data.ducking and 70 or
		self._running and 175 or 100
	) * managers.player:mod_movement_penalty(managers.player:body_armor_value("movement", nil, 1))

	if mvector3.distance_sq(self._last_step_pos, self._pos) > step_length * step_length then
		mvector3.set(self._last_step_pos, self._pos)
		self._unit:base():anim_data_clbk_footstep()
		if self._running then self._ext_camera:play_shaker("player_land", 0.3) end
	end
end
--NEW FUNCTION: MOVEMENT UNEQUIP
function PlayerStandard:_check_movement_equipped(t)
	if self:_interacting()
	or self:_is_meleeing()
	or managers.player:current_state()=="driving"
	then
		self._wall_equipped = true

		self._wall_unequip_t = nil
		self._wall_unequip = nil
		--self._running_enter_end_t = nil
		self._running_exit_start_t = nil	
		return
	end

	local new_action = nil
	local wep_base = self._equipped_unit:base()

	local lying_moving = self._move_dir and self._state_data.lying
	local ladder_with_primary = self._state_data.on_ladder and wep_base:selection_index()==2
	local ladder_moving = self._move_dir and self._state_data.on_ladder
	--if self._wall_equipped
	if lying_moving or ladder_moving or self.nqr_rotanim_t --[[and not self._equip_weapon_expire_t]] then
		if self._movement_equipped then
			self._movement_equipped = nil
			wep_base:tweak_data_anim_stop("fire")
			wep_base:tweak_data_anim_stop("equip")
			self._camera_unit:base():stop_shooting()
			self:stop_shooting()
			self:_check_stop_shooting()
			self:_interupt_action_reload(t)
			self:_interupt_action_steelsight(t)
			self:_interupt_action_running(t)
			self:_interupt_action_charging_weapon(t)
			self:_interupt_action_throw_projectile(t)
			self:_interupt_action_throw_grenade(t)
			self:_interupt_action_use_item(t)
			self._ext_network:send("set_stance", 2, false, false)

			if not (self._equip_weapon_expire_t0 or (self._unequip_weapon_expire_t and not self._unequip_weapon_expire_t0)) then
				self:_play_unequip_animation(4)
				self._ext_network:send("set_stance", 2, false, false)
			end

			self:_interupt_changing_weapon()
		end
	else
		if not self._movement_equipped then
			self._movement_equipped = true
			self:_start_action_equip_weapon0(t)
			self._ext_network:send("set_stance", 3, false, false)
		end
	end



	if self:_changing_weapon()
	or self:is_deploying()
	or self:_is_throwing_grenade()
	or self:_is_throwing_projectile()
	or not self._movement_equipped
	--or self._running
	then
		self._wall_equipped = true
		self._wall_unequip_t = nil
		self._wall_unequip = nil
		self._running_enter_end_t = self:is_deploying() and self._running_enter_end_t or nil
		self._running_exit_start_t = nil	
		return
	end

	if self._wall_unequip_t and self._wall_unequip_t < t then self._wall_unequip_t = nil end

	if self._wall_unequip or (self._state_data.on_ladder and self._move_dir) then
		if self._wall_equipped and self._movement_equipped then
			self._wall_equipped = nil
			wep_base:tweak_data_anim_stop("equip")
			self._camera_unit:base():stop_shooting()
			self:stop_shooting()
			self:_check_stop_shooting()
			self:_interupt_action_reload(t)
			self:_interupt_action_steelsight(t)
			self:_interupt_action_charging_weapon(t)
			self:_interupt_action_use_item(t)
			self._ext_network:send("set_stance", 2, false, false)

			self:_play_running_enter_anim(t, 2)
		end
	else
		if not self._wall_equipped then
			local eq_t, eq_tt, anim_spd = self:nqr_eq_speed()
			self._wall_equipped = true
			self._wall_unequip_t = t + (eq_t*0.8)
			self:_play_running_exit_anim(t, 1-(1-anim_spd)*(wep_base._current_stats.shouldered and 0.8 or 0.2))
			self._ext_network:send("set_stance", 3, false, false)
		end
	end
	self._wall_unequip = nil
end
function PlayerStandard:_is_movement_equipped()
	return self._movement_equipped
end
function PlayerStandard:_play_running_enter_anim(t, mul)
	local mul = mul or 1
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	if not self._running_enter_end_t and not (self._running and not self._end_running_expire_t) then
		self._ext_camera:play_redirect(self:get_animation("start_running"), mul)
	end
	self._running_exit_start_t = nil
	self._running_enter_end_t = t + (self._running_enter_end_t and (self._running_enter_end_t - t) or ((wep_tweak.anim_sprint_t or 14/30)/mul))
end
function PlayerStandard:_play_running_exit_anim(t, mul)
	local mul = mul or 1
	self._running_exit_start_t = self._running_enter_end_t or t
	self._running_exit_mul = mul
end
--CHECK DUCK: REMOVE TAB BLOCK
function PlayerStandard:_check_action_duck(t, input)
	if self:_is_using_bipod() then return end

	if self._setting_hold_to_duck and input.btn_duck_release or self._state_data.getup_wanted then
		if self._state_data.ducking then
			self:_end_action_ducking(t)
		end
	elseif input.btn_duck_press or self._state_data.getup_wanted then
		if not self._state_data.ducking and not self._state_data.getup_t then
			self:_start_action_ducking(t)
			if not self.nqr_rotanim_notready_t then self.nqr_rotanim_ready_t = t + 0.25 end
		elseif self._state_data.ducking then
			self:_end_action_ducking(t)
		end
	end
end
--GETUP COOLDOWN
function PlayerStandard:_start_action_ducking(t, cooldown)
	if self:_on_zipline() then return end

	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self._state_data.getup_t = t + (cooldown or 0.2)*self:_armor_penalty_mul()

	self:_stance_entered()
	self:_update_crosshair_offset()
	local velocity = self._unit:mover():velocity()
	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
	self._ext_network:send("action_change_pose", 2, self._unit:position())
	self:_upd_attention()

	self._state_data.getup_wanted = nil
end
---GETUP COOLDOWN, STAMINA DRAIN
function PlayerStandard:_end_action_ducking(t, skip_can_stand_check)
	if self._state_data.getup_t then
		self._state_data.getup_wanted = true
		return
	end

	local t = t or Application:time()

	if self._state_data.lying then
		if self._state_data.lying_t then return end
		self._state_data.lying = false
		self._state_data.getup_t = t + 0.4*self:_armor_penalty_mul()
		self._ext_camera:play_shaker("player_start_running", 1, nil, 0.5)
		self._unit:camera():camera_unit():base():set_target_tilt(0)
		self:_stance_entered()
		self._ext_network:send("action_change_pose", 2, self._unit:position())
		if self._movement_equipped then self:_start_action_unequip_weapon(t, {next = false, reequip = true}) end
		return
	end

	self._state_data.getup_t = t + 0.15

	if not skip_can_stand_check and not self:_can_stand() then return end
	if self._unit:movement()._stamina < (tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.5 / managers.player:body_armor_value("stamina")) then return end
	self._unit:movement():subtract_stamina(tweak_data.player.movement_state.stamina.JUMP_STAMINA_DRAIN * 0.5 / managers.player:body_armor_value("stamina"))

	self._state_data.ducking = false

	self:_stance_entered()
	self:_update_crosshair_offset()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("action_change_pose", 1, self._unit:position())
	self:_upd_attention()

	self._state_data.getup_wanted = nil

	self.nqr_rotanim_ready_t = nil
	self.nqr_rotanim_notready_t = t + 0.25
end
--NEW FUNCTION: LYING
function PlayerStandard:_start_action_lying(t)
	if managers.player:current_state()=="driving" then return end

	managers.mission._fading_debug_output:script().log("nqr_force_reequip on lying",  Color.red)
	self:_nqr_force_reequip(t)

	--self:_start_action_ducking(t)
	self._state_data.getup_t = nil
	self._state_data.ducking = true
	self._state_data.lying = true
	self._state_data.lying_t = t + 0.6*self:_armor_penalty_mul()

	self:_stance_entered()
	self:_update_crosshair_offset()
	local vel = self._unit:mover():velocity()
	self._unit:kill_mover()
	self:_activate_mover(Idstring("duck"), vel)
	self._ext_network:send("action_change_pose", 3, self._unit:position())
	self:_upd_attention()

	self._unit:camera():camera_unit():base():set_target_tilt(15)
	self._ext_camera:play_shaker("player_fall_damage")
	managers.rumble:play("hard_land")

	self._camera_unit:base():set_pitch(45)

	self._ext_damage:set_armor(0)
end
--NEW FUNCTION: ARMOR PENALTY MUL
function PlayerStandard:_armor_penalty_mul(param)
	return 1 + ( 1 - managers.player:body_armor_value(param or "stamina", nil, 1) )
end
--NQVM, LAYING STANCE POS
function PlayerStandard:_stance_entered(unequipped)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local wep_factory = tweak_data.weapon.factory[wep_base._factory_id]
	local stance_standard = tweak_data.player.stances.default[managers.player:current_state()] or tweak_data.player.stances.default.standard
	local head_stance = self._state_data.ducking and tweak_data.player.stances.default[self._state_data.lying and "lying" or "crouched"].head or stance_standard.head
	local stance_id = nil
	local stance_mod = { translation = Vector3(0, 0, 0) }
	local stance_mod2 = { translation = Vector3(0, 0, 0), rotation = Rotation(0, 0, 0) }

	if not unequipped then
		stance_id = wep_base:get_stance_id()

		if self._state_data.in_steelsight and wep_base.stance_mod then
			stance_mod2 = wep_base:stance_mod() or stance_mod2
		end
	end

	local stances = (self:_is_meleeing() or self:_is_throwing_projectile()) and tweak_data.player.stances.default or tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = deep_clone(stances.steelsight) --(not self:_is_using_bipod() or self:_is_throwing_projectile() or stances.bipod) and (self._state_data.in_steelsight and stances.steelsight or self._state_data.ducking and stances.crouched or stances.standard)
	local stock = wep_base._current_stats.shouldered
	local smol = wep_base:selection_index()==1 --(wep_base:is_category("pistol") or wep_base:is_category("revolver") or wep_base:is_category("machine_pistol"))
	local sightheight_mod = (wep_factory.sightheight_mod or 0)
	local nqr_stancemod = not self._state_data.in_steelsight and wep_tweak.stancemod or { trn = Vector3(0, 0, 0), rot = Vector3(0, 0, 0) }

	local trn_x = self._state_data.in_steelsight and 0 or (stock and 6 or 3)
	local trn_y = self._state_data.in_steelsight and (stock and -2 or (smol and 10 or 6)) or (self._state_data.ducking and (stock and -2 or 1) or (stock and 0 or 4))
	local trn_z = self._state_data.in_steelsight and 0 or (self._state_data.ducking and (stock and 0 or -1) or (stock and -1 or -2)) --self._state_data.in_steelsight and 0 or self._state_data.ducking and (stock and -2 or -3) or (stock and -3 or -4)
	if wep_base.AKIMBO then trn_x = 0 end
	local z_ads = stances.steelsight.shoulders.translation.z + sightheight_mod + stance_mod2.translation.z
	local z_hip = stances.standard.shoulders.translation.z + trn_z
	--z_ads = (z_ads-z_hip)>6 and z_ads or math.min(z_ads, z_hip - trn_z + 3)

	misc_attribs.shoulders.translation = deep_clone(stances.steelsight.shoulders.translation) + Vector3(trn_x, trn_y, trn_z) + nqr_stancemod.trn -- + nqr_pos
	misc_attribs.shoulders.translation = Vector3(
		misc_attribs.shoulders.translation.x + (self._state_data.in_steelsight and stance_mod2.translation.x or 0),
		misc_attribs.shoulders.translation.y + stance_mod2.translation.y,
		self._state_data.in_steelsight and z_ads or z_hip
	)

	local nqr_rot = self._state_data.in_steelsight and math.rot_to_vec(stance_mod2.rotation) or self._state_data.ducking and Vector3(0, 0, stock and -2 or -6) or Vector3(0, 0, stock and -4 or -8)
	if wep_base.AKIMBO then nqr_rot = Vector3(0, 0, 0) end
	local rot = math.rot_to_vec(misc_attribs.shoulders.rotation) + nqr_rot + nqr_stancemod.rot
	rot = math.string_to_rotation(CoreMath.vector_to_string(rot))
	misc_attribs.shoulders.rotation = rot

	if wep_base.AKIMBO then misc_attribs = self._state_data.in_steelsight and deep_clone(stances.steelsight) or deep_clone(stances.standard) end

	local head_duration = tweak_data.player.TRANSITION_DURATION
	local head_duration_multiplier = 1
	local duration = head_duration + (wep_base:transition_duration() or 0)
	local duration_multiplier = (
		(self._state_data.in_steelsight and 1/wep_base:enter_steelsight_speed_multiplier())
		or (self._state_data.lying_t and 0.5)
		or (self._state_data.getup_t and 0.2)
	) or 1

	if self._instant_stance_transition then
		self._instant_stance_transition = nil
		duration_multiplier = 0
	end

	local new_fov = self:get_zoom_fov(misc_attribs) + 0

	local rot_a = misc_attribs.shoulders.translation.x
	local rot_b = misc_attribs.shoulders.translation.z
	local rot_t = (rot_b/math.abs(rot_b)) * math.acos(((rot_a*1)+(rot_b*0))/math.sqrt(((rot_a^2)+(rot_b^2))*(1+0)))
	local rot_a1 = math.sqrt((rot_a^2)+(rot_b^2)) * math.cos(rot_t - math.rot_to_vec(stance_mod2.rotation).z)
	local rot_b1 = math.sqrt((rot_a^2)+(rot_b^2)) * math.sin(rot_t - math.rot_to_vec(stance_mod2.rotation).z)
	local rot_res = Vector3(rot_a1, misc_attribs.shoulders.translation.y, rot_b1)
	if math.abs(math.rot_to_vec(stance_mod2.rotation).z)>0 then misc_attribs.shoulders.translation = rot_res end

	local overshot = math.max(0.5, ((self._state_data.ducking and 3 or 1) + (wep_base._current_stats.weight * (stock and 0.5 or 1) * (smol and 1.2 or 1) * 0.4)) - 3)
	misc_attribs.vel_overshot.yaw_pos = overshot
	misc_attribs.vel_overshot.yaw_neg = -overshot
	misc_attribs.vel_overshot.pitch_pos = -overshot
	misc_attribs.vel_overshot.pitch_neg = overshot*0.5
	misc_attribs.vel_overshot.pivot = Vector3(0-misc_attribs.shoulders.translation.x, -8-stances.steelsight.shoulders.translation.y, misc_attribs.vel_overshot.pivot.z)

	self._camera_unit:base():clbk_stance_entered(misc_attribs.shoulders, head_stance, misc_attribs.vel_overshot, new_fov, misc_attribs.shakers, stance_mod, duration_multiplier, duration, head_duration_multiplier, head_duration)
	managers.menu:set_mouse_sensitivity(self:in_steelsight())
end

--ADS CHECK: SECONDS SIGHT RESET, INTERUPT SHOTGUN RELOAD
function PlayerStandard:_check_action_steelsight(t, input)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local new_action = nil

	if alive(self._equipped_unit) then
		local result = nil

		--[[local wanted_sight = NQR.settings.nqr_wanted_sight - 1
		if wep_base:has_second_sight() and not self._state_data.in_steelsight then
			if not tweak_data.weapon.factory.parts[wep_base._second_sights[1].part_id].stats.zoom then
				wep_base._second_sight_on = wep_base._second_sights[1].piggyback and 1 or (wanted_sight==2 and (#wep_base._second_sights==2 and 2 or 1)) or wanted_sight
				wep_base:set_second_sight_on(wep_base._second_sight_on, false, wep_base._second_sights, self)
			end
		end]]

		if wep_base.manages_steelsight and wep_base:manages_steelsight() then
			if input.btn_steelsight_press and wep_base.steelsight_pressed then
				result = wep_base:steelsight_pressed()
			elseif input.btn_steelsight_release and wep_base.steelsight_released then
				result = wep_base:steelsight_released()
			end

			if result then
				if result.enter_steelsight and not self._state_data.in_steelsight then
					self:_start_action_steelsight(t)

					new_action = true
				elseif result.exit_steelsight and self._state_data.in_steelsight then
					self:_end_action_steelsight(t)

					new_action = true
				end
			end

			return new_action
		end
	end

	if (self._state_data.reload_steelsight_expire_t and t < self._state_data.reload_steelsight_expire_t) or
	(self:_is_reloading() and self._equipped_unit:base():reload_interuptable()) then
		if managers.user:get_setting("hold_to_steelsight") and input.btn_steelsight_release then
			self._steelsight_wanted = false
		elseif input.btn_steelsight_press then
			self._queue_reload_interupt = true
			if not wep_tweak.sao then self._steelsight_wanted = true end
		end

		return new_action
	end

	if managers.user:get_setting("hold_to_steelsight") and input.btn_steelsight_release then
		self._steelsight_wanted = false

		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		end
	elseif input.btn_steelsight_press or self._steelsight_wanted then
		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		elseif not self._state_data.in_steelsight then
			self:_start_action_steelsight(t)

			new_action = true
		end
	end

	if self._cock_t and self._cock_t<=t then
		self._cock_t = nil
		wep_base.delayed_t1 = 0
		wep_base:dryfire()
	end

	return new_action
end
--START STEELSIGHT: BOLTACTION CHECK, DAO COCK, ADS ENTER SOUND
function PlayerStandard:_start_action_steelsight(t, gadget_state)
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()

	local wanted_sight = NQR.settings.nqr_wanted_sight - 1
	if wep_base:has_second_sight() and not self._state_data.in_steelsight then
		if not tweak_data.weapon.factory.parts[wep_base._second_sights[1].part_id].stats.zoom then
			wep_base._second_sight_on = wep_base._second_sights[1].piggyback and 1 or (wanted_sight==2 and (#wep_base._second_sights==2 and 2 or 1)) or wanted_sight
			wep_base:set_second_sight_on(wep_base._second_sight_on, false, wep_base._second_sights, self)
		end
	end

	if not self._movement_equipped then return end

	if wep_base:is_category("revolver")
	and not wep_base.AKIMBO
	and not wep_base.delayed_t1
	and not wep_base.r_offset
	and not wep_tweak.dao
	and not self._cock_t
	then
		self:_interupt_action_running(t)
		self._cock_t = t + 0.2
		self:set_animation_weapon_hold("model3")
		wep_base:tweak_data_anim_play("fire", (wep_tweak.bolt_speed or 1)*0.4, wep_tweak.sao and 0.035 or nil)
		self._ext_camera:play_redirect(self:get_animation("recoil"), 0.7, 0.035)
		if wep_tweak.sao then
			self._steelsight_wanted = false
			return
		end
	end

	if self:_changing_weapon()
	or self:_interacting()
	or self:_is_meleeing()
	or self._use_item_expire_t
	or self:_is_throwing_projectile()
	or self._reequip_gadget_expire_t
	or self._equip_weapon_expire_t
	or self:_on_zipline()
	or self._wall_unequip_t
	or (
		not self._state_data.reload_expire_t and
		(wep_tweak.action=="bolt_action" or wep_tweak.ads_reset)
		and not self._equipped_unit:base():start_shooting_allowed()
	)
	then
		if not self._state_data.reload_expire_t then self._steelsight_wanted = true end
		return
	end

	if self._running and not self._end_running_expire_t then
		self:_interupt_action_running(t)
		if not self._state_data.reload_expire_t then self._steelsight_wanted = true end
		return
	end

	if self._state_data.reload_expire_t or
	not self._wall_push
	and not self._cock_t
	and not ((t or 0) < (wep_base._next_fire_allowed+0.5))
	and not self._state_data.reload_exit_expire_t
	then
		self:_interupt_action_reload(t)
		self._ext_camera:play_redirect(self:get_animation("idle"))
		wep_base:tweak_data_anim_stop("reload")
		wep_base:tweak_data_anim_stop("reload_not_empty")
		wep_base:tweak_data_anim_stop("reload_exit")
	end

	if (self._state_data.on_ladder and wep_base:selection_index()==2)
	or wep_tweak.reverse_rise
	then self._steelsight_wanted = false return end

	self._steelsight_wanted = false
	self._state_data.in_steelsight = true

	self:_update_crosshair_offset()
	self:_stance_entered()

	wep_base:play_sound("gadget_steelsight_enter")

	if wep_base:weapon_tweak_data().animations.has_steelsight_stance then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 1

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._state_data.reticle_obj = wep_base.get_reticle_obj and wep_base:get_reticle_obj()
	self._state_data.reticle_holo = wep_base._reticle_holo

	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") then
		local closest_ray = self._equipped_unit:base():check_autoaim(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), nil, true)

		self._camera_unit:base():clbk_aim_assist(closest_ray)
	end

	self._ext_network:send("set_stance", 3, false, false)
	managers.job:set_memory("cac_4", true)
end
--ADS EXIT SOUND
function PlayerStandard:_end_action_steelsight(t)
	self._state_data.in_steelsight = false
	self._state_data.reticle_obj = nil

	self:_stance_entered()
	self:_update_crosshair_offset()
	self._camera_unit:base():clbk_stop_aim_assist()

	local wep_base = self._equipped_unit:base()

	wep_base:play_sound("gadget_steelsight_exit")

	if wep_base:weapon_tweak_data().animations.has_steelsight_stance then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 0

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._ext_network:send("set_stance", 3, false, false)
end
--GET ADS MOD
function PlayerStandard:in_steelsight()
	if not (alive(self._equipped_unit) and self._equipped_unit:base()) then return end
	local wep_base = self._equipped_unit:base()
	local wep_tweak = wep_base:weapon_tweak_data()
	local ads_mod = wep_base:_ads_mod()

	return self._state_data.in_steelsight and ads_mod
end
--NO MORE ZOOM
function PlayerStandard:get_zoom_fov(stance_data)
	local fov = stance_data and stance_data.FOV or 75
	local fov_multiplier = managers.user:get_setting("fov_multiplier")
	local fov_ads = self._state_data.in_steelsight and math.max(self._equipped_unit:base():zoom()/1.25, 1.02) or 1

	return fov * fov_multiplier / fov_ads
end



function PlayerStandard:_check_action_interact(t, input)
	local keyboard = self._controller.TYPE == "pc" or managers.controller:get_default_wrapper_type() == "pc"
	local pressed, released, holding = nil

	if self._interact_expire_t and not self._use_item_expire_t then
		pressed, released, holding = self:_check_tap_to_interact_inputs(t, input.btn_interact_press, input.btn_interact_release, input.btn_interact_state)
	else
		holding = input.btn_interact_state
		released = input.btn_interact_release
		pressed = input.btn_interact_press
	end

	local new_action, timer, interact_object = nil

	if pressed then
		if _G.IS_VR then
			self._interact_hand = input.btn_interact_left_press and PlayerHand.LEFT or PlayerHand.RIGHT
		end

		if not self:_action_interact_forbidden() and not self._state_data.interact_redirect_t then
			new_action, timer, interact_object = self._interaction:interact(self._unit, input.data, self._interact_hand)

			--if interact_object then managers.mission._fading_debug_output:script().log(tostring(interact_object and interact_object:interaction().tweak_data), Color.white) end
			if interact_object then log(interact_object:interaction().tweak_data) end

			if new_action then
				self:_play_interact_redirect(t, input)
			end

			if timer then
				new_action = true

				self._ext_camera:camera_unit():base():set_limits(20, 20)
				self:_start_action_interact(t, input, timer, interact_object)
				self:_chk_tap_to_interact_enable(t, timer, interact_object)
			end

			if not new_action then
				self._start_intimidate = true
				self._start_intimidate_t = t
			end
		end
	end

	local secondary_delay = tweak_data.team_ai.stop_action.delay
	local force_secondary_intimidate = false

	if not new_action and keyboard and input.btn_interact_secondary_press then
		force_secondary_intimidate = true
	end

	if released then
		if _G.IS_VR then
			local release_hand = input.btn_interact_left_release and PlayerHand.LEFT or PlayerHand.RIGHT
			released = release_hand == self._interact_hand
		end

		if released then
			if self._start_intimidate and not self:_action_interact_forbidden() then
				if t < self._start_intimidate_t + secondary_delay then
					self:_start_action_intimidate(t)

					self._start_intimidate = false
				end
			else
				self:_interupt_action_interact()
			end
		end
	end

	if (self._start_intimidate or force_secondary_intimidate) --[[and not self:_action_interact_forbidden()]] and (not keyboard and t > self._start_intimidate_t + secondary_delay or force_secondary_intimidate) then
		self:_start_action_intimidate(t, true)

		self._start_intimidate = false
	end

	return new_action
end
function PlayerStandard:_action_interact_forbidden()
	return (
		self:chk_action_forbidden("interact")
		or self._unit:base():stats_screen_visible()
		or self:_interacting()
		or self._ext_movement:has_carry_restriction()
		or self:is_deploying()
		or self._equipping_mask
		or self:_is_throwing_projectile()
		or self:_is_meleeing()
		or self._running
		or self._shooting or not self._equipped_unit:base():start_shooting_allowed()
	)
end
function PlayerStandard:_update_interaction_timers(t)
	if self._state_data.interact_redirect_t and self._state_data.interact_redirect_t < t then
		self._state_data.interact_redirect_t = nil
	end

	if self._interact_expire_t then
		local dt = self:_get_interaction_speed()
		self._interact_expire_t = self._interact_expire_t - dt

		--managers.hud:set_progress_timer_bar_valid(valid, not valid and "hud_deploy_valid_help")
		managers.hud:set_progress_timer_bar_width(self._interact_orig_timer - self._interact_expire_t, self._interact_orig_timer)

		if not alive(self._interact_params.object) or self._interact_params.object ~= self._interaction:active_unit() or self._interact_params.tweak_data ~= self._interact_params.object:interaction().tweak_data or self._interact_params.object:interaction():check_interupt() then
			self:_interupt_action_interact(t)
		else
			local current = self._interact_params.timer - self._interact_expire_t
			local total = self._interact_params.timer

			managers.hud:set_interaction_bar_width(current, total)

			if self._interact_expire_t <= 0 then
				self:_end_action_interact(t)

				self._interact_expire_t = nil
			end
		end
	end
end
function PlayerStandard:_play_interact_redirect(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self._running_enter_end_t = nil
	self._running_exit_start_t = nil

	self._state_data.interact_redirect_t = t + 0.65

	self._ext_camera:play_redirect(self:get_animation("use"))
end
function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self._running_enter_end_t = nil
	self._running_exit_start_t = nil

	self._interact_orig_timer = timer
	local eq_t, eq_tt, anim_spd = self:nqr_eq_speed(true)
	local final_timer = timer
	final_timer = managers.modifiers:modify_value("PlayerStandard:OnStartInteraction", final_timer, interact_object) + (self._equip_weapon_expire_t0 and 0 or (eq_t + eq_tt))
	self._interact_expire_t = final_timer
	local start_timer = 0
	self._interact_params = {
		object = interact_object,
		timer = final_timer,
		tweak_data = interact_object:interaction().tweak_data
	}

	if not self._unequip_weapon_expire_t and self._movement_equipped then self:_start_action_unequip_weapon(t) end

	managers.hud:show_progress_timer_bar(start_timer, final_timer)
	managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, true, self._interact_params.tweak_data, final_timer, false)
	self._unit:network():send("sync_interaction_anim", true, self._interact_params.tweak_data)
end
function PlayerStandard:_end_action_interact(t)
	self:_interupt_action_interact(t, nil, true)
	self._interaction:end_action_interact(self._unit)
end
function PlayerStandard:_interupt_action_interact(t, input, complete)
	if self._interact_expire_t then
		t = t or managers.player:player_timer():time()
		self:_clear_tap_to_interact()

		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			self._interact_params.object:interaction():interact_interupt(self._unit, complete)
		end

		self._ext_camera:camera_unit():base():remove_limits()
		self._interaction:interupt_action_interact(self._unit)
		managers.network:session():send_to_peers_synched("sync_teammate_progress", 1, false, self._interact_params.tweak_data, 0, complete and true or false)

		self._interact_params = nil
		managers.hud:hide_interaction_bar(complete)
		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()
		self._unit:network():send("sync_interaction_anim", false, "")

		if not self._movement_equipped then return end
		if self._unequip_weapon_expire_t then
			self:_start_action_equip_weapon0(t)
		else
			self:_start_action_equip_weapon(t)
		end
	end
end
--GET INTIMIDATION ACTION: REMOVE ENEMY MARKING
function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	local voice_type, new_action, plural = nil
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local is_whisper_mode = managers.groupai:state():whisper_mode()

	if prime_target then
		if prime_target.unit_type == unit_type_teammate then
			local is_human_player, record = nil

			if not detect_only then
				record = managers.groupai:state():all_criminals()[prime_target.unit:key()]

				if record.ai then
					if not prime_target.unit:brain():player_ignore() then
						prime_target.unit:movement():set_cool(false)
						prime_target.unit:brain():on_long_dis_interacted(0, self._unit, secondary)
					end
				else
					is_human_player = true
				end
			end

			local amount = 0

			if not secondary then
				local current_state_name = self._unit:movement():current_state_name()

				if current_state_name ~= "arrested" and current_state_name ~= "bleed_out" and current_state_name ~= "fatal" and current_state_name ~= "incapacitated" then
					local rally_skill_data = self._ext_movement:rally_skill_data()

					if rally_skill_data and mvec3_dis_sq(self._pos, record.m_pos) < rally_skill_data.range_sq then
						local needs_revive, is_arrested = nil

						if prime_target.unit:base().is_husk_player then
							is_arrested = prime_target.unit:movement():current_state_name() == "arrested"
							needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive() and not is_arrested
						else
							is_arrested = prime_target.unit:character_damage():arrested()
							needs_revive = prime_target.unit:character_damage():need_revive()
						end

						if needs_revive and managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive") then
							voice_type = "revive"

							managers.player:disable_cooldown_upgrade("cooldown", "long_dis_revive")
						elseif is_human_player and not is_arrested and not needs_revive and rally_skill_data.morale_boost_delay_t and rally_skill_data.morale_boost_delay_t < managers.player:player_timer():time() then
							voice_type = "boost"
							amount = 1
						end
					end
				end
			end

			if is_human_player then
				prime_target.unit:network():send_to_unit({
					"long_dis_interaction",
					prime_target.unit,
					amount,
					self._unit,
					secondary or false
				})
			end

			voice_type = voice_type or secondary and "ai_stay" or "come"
			plural = false
		else
			local prime_target_key = prime_target.unit:key()

			if prime_target.unit_type == unit_type_enemy then
				plural = false

				if prime_target.unit:anim_data().hands_back then
					voice_type = "cuff_cop"
				elseif prime_target.unit:anim_data().surrender then
					voice_type = "down_cop"
				elseif is_whisper_mode and prime_target.unit:movement():cool() and prime_target.unit:base():char_tweak().silent_priority_shout then
					--voice_type = "mark_cop_quiet"
				elseif prime_target.unit:base():char_tweak().priority_shout then
					--voice_type = "mark_cop"
				else
					voice_type = "stop_cop"
				end
			elseif prime_target.unit_type == unit_type_camera then

			elseif prime_target.unit_type == unit_type_turret then
				plural = false
				voice_type = "mark_turret"
			elseif prime_target.unit:base():char_tweak().is_escort then
				plural = false
				local e_guy = prime_target.unit

				if e_guy:anim_data().move or e_guy:anim_data().standing_hesitant then
					voice_type = "escort_keep"
				elseif e_guy:anim_data().panic then
					voice_type = "escort_go"
				else
					voice_type = prime_target.unit:base():char_tweak().speech_escort or "escort"
				end
			else
				if prime_target.unit:anim_data().drop then
					voice_type = "down_stay"
				elseif prime_target.unit:anim_data().tied or prime_target.unit:movement():stance_name() == "cbt" then
					voice_type = "come"
				elseif prime_target.unit:anim_data().move then
					voice_type = "stop"
				elseif prime_target.unit:anim_data().drop then
					voice_type = "down_stay"
				else
					voice_type = "down"
				end

				local num_affected = 0

				if voice_type ~= "come" then
					for _, char in pairs(char_table) do
						if char.unit_type == unit_type_civilian then
							if voice_type == "stop" and char.unit:anim_data().move then
								num_affected = num_affected + 1
							elseif voice_type == "down_stay" and char.unit:anim_data().drop then
								num_affected = num_affected + 1
							elseif voice_type == "down" and not char.unit:anim_data().move and not char.unit:anim_data().drop then
								num_affected = num_affected + 1
							end

							if num_affected > 1 then
								break
							end
						end
					end
				end

				if num_affected > 1 then
					plural = true
				else
					plural = false
				end
			end

			if detect_only then
				voice_type = "come"
			else
				local max_inv_wgt = 0

				for _, char in pairs(char_table) do
					if max_inv_wgt < char.inv_wgt then
						max_inv_wgt = char.inv_wgt
					end
				end

				if max_inv_wgt < 1 then
					max_inv_wgt = 1
				end

				amount = amount or tweak_data.player.long_dis_interaction.intimidate_strength
				local amount_civ = amount * managers.player:upgrade_value("player", "civ_intimidation_mul", 1) * managers.player:team_upgrade_value("player", "civ_intimidation_mul", 1)

				for _, char in pairs(char_table) do
					local not_ass = char.unit_type~=unit_type_enemy or not (
						managers.groupai:state()
						and managers.groupai:state()._task_data
						and managers.groupai:state()._task_data.assault
						and (
							managers.groupai:state()._task_data.assault.phase=="build"
							or managers.groupai:state()._task_data.assault.phase=="sustain"
							or managers.groupai:state()._task_data.assault.phase=="fade"
						)
					)
					local not_bleedout = not (char.unit:movement() and char.unit:movement().bleedouted)
					local int_amount = char.unit_type == unit_type_civilian and amount_civ or amount or 0

					if (char.unit_type ~= unit_type_camera
					and char.unit_type ~= unit_type_teammate
					and (not is_whisper_mode or not char.unit:movement():cool()))
					and not_ass and not_bleedout
					then
						if prime_target_key == char.unit:key() then
							voice_type = char.unit:brain():on_intimidated(int_amount, self._unit) or voice_type
						elseif not primary_only and char.unit_type ~= unit_type_enemy then
							char.unit:brain():on_intimidated(int_amount * char.inv_wgt / max_inv_wgt, self._unit)
						end
					end
				end
			end
		end
	end

	return voice_type, plural, prime_target
end
function PlayerStandard:_play_distance_interact_redirect(t, variant)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, variant)

	if self._state_data.in_steelsight then return end

	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then return end

	if self:_is_reloading()
	or self:_changing_weapon()
	or self:_is_meleeing()
	or self:_interacting()
	or self._use_item_expire_t
	or not self._wall_equipped
	or not self._movement_equipped
	or self._cock_t
	then
		return
	end

	if self._running then return end

	self._state_data.interact_redirect_t = t + 1
	self._ext_camera:play_redirect(Idstring(variant))
end



function PlayerStandard:_interupt_changing_weapon()
	self._equip_weapon_expire_t0 = nil
	self._equip_weapon_expire_t = nil
	self._unequip_weapon_expire_t0 = nil
	self._unequip_weapon_expire_t = nil
end
