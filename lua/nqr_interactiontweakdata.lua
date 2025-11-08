Hooks:PostHook( InteractionTweakData, "init", "nqr_interactiontweakdata", function(self)

	self.INTERACT_DISTANCE = 130
	for i, k in pairs(self) do
		if type(k)=="table" and k.interact_distance then k.interact_distance = math.min(k.interact_distance, 130) end
	end

	self.crate_loot_crowbar.interact_distance = 180
	self.place_flare.interact_distance = 400
	self.place_flare.timer = 1
	self.place_flare.sound_start = "bar_light_fireworks"
	self.place_flare.sound_interupt = "bar_light_fireworks_cancel"
	self.place_flare.sound_done = "bar_light_fireworks_finished"
	self.ignite_flare.interact_distance = 400
	self.ignite_flare.timer = 1
	self.ignite_flare.sound_start = "bar_light_fireworks"
	self.ignite_flare.sound_interupt = "bar_light_fireworks_cancel"
	self.ignite_flare.sound_done = "bar_light_fireworks_finished"
	self.use_flare.interact_distance = 400
	self.use_flare.timer = 1
	self.use_flare.sound_start = "bar_light_fireworks"
	self.use_flare.sound_interupt = "bar_light_fireworks_cancel"
	self.use_flare.sound_done = "bar_light_fireworks_finished"
	self.open_train_cargo_door.interact_distance = 90
	self.connect_hose.interact_distance = 300 --90
	self.connect_hose_wwh.interact_distance = 300 --90
	self.c4_bag.interact_distance = 200
	self.c4_x1_bag.interact_distance = 180
	self.start_hacking.interact_distance = 100
	self.push_button.interact_distance = 180
	self.push_button_des.interact_distance = 180
	self.c4_diffusible.interact_distance = 110
	self.take_confidential_folder_event.timer = nil
	self.pick_lock_x_axis.timer = 8
	self.pick_lock_hard_no_skill.interact_distance = 80
	self.pick_lock_hard_no_skill.timer = 10
	self.pick_lock_deposit_transport.timer = 5
	self.hold_blow_torch.interact_distance = 120
	self.hold_open.interact_distance = 150
	self.hold_open.timer = nil
	self.invisible_interaction_open.timer = nil
	self.cut_fence.timer = 3
	self.bag_zipline.timer = 1
	self.bag_zipline.sound_start = "bar_drill_apply"
	self.bag_zipline.sound_interupt = "bar_drill_apply_cancel"
	self.bag_zipline.sound_done = "bar_drill_apply_finished"
	self.grenade_briefcase.timer = nil
	self.atm_interaction.timer = 1

	self.copy_machine_smuggle.interact_distance = 180
	self.big_computer_hackable.interact_distance = 140
	self.hold_signal_driver.interact_distance = 350
	self.hold_remove_rope.interact_distance = 110
	self.hold_open_bomb_hatch.interact_distance = 100
	self.hold_start_bomb_charge.interact_distance = 100
	self.disarm_bomb.interact_distance = 180
	self.glass_cutter.interact_distance = 200
	self.glass_cutter_jammed.interact_distance = 200
	self.hold_circle_cutter.interact_distance = 200
	self.gen_pku_circle_cutter.interact_distance = 200
	self.circle_cutter_jammed.interact_distance = 200
	self.apartment_helicopter.interact_distance = 320
	self.apartment_helicopter.timer = 8
	self.gen_pku_warhead_box.interact_distance = 100
	self.gen_pku_warhead.interact_distance = 100
	self.cas_screw_down.interact_distance = 130
	self.methlab_bubbling.interact_distance = 120
	self.methlab_caustic_cooler.interact_distance = 110
	self.methlab_gas_to_salt.interact_distance = 110
	self.ranc_hold_construct_weapon.timer = 6
	self.ranc_take_weapons.timer = 2
	self.stn_int_place_camera.timer = 2
	self.stn_int_take_camera.timer = 1
	self.hold_pku_disassemble_cro_loot.interact_distance = 200 --axis
	self.gen_pku_lance_part.interact_distance = 150
	self.bex_prop_faberge_egg.interact_distance = 180
	self.money_briefcase.interact_distance = 110
	self.money_luggage.interact_distance = 110
	self.hold_take_server_axis.interact_distance = 150
	self.hold_take_parachute.timer = nil
	self.cas_take_empty_watertank.timer = 1
	self.cas_take_full_watertank.timer = 1
	self.fex_hold_prop_wall_lamp.timer = 1
	self.pent_press_take_car_jack.timer = 1
	self.pent_press_take_gas_can.timer = 1
	self.pent_hold_remove_elevator_hatch.interact_distance = 210
	self.pent_hold_connect_wire_to_elevator.interact_distance = 150
	self.pent_hold_connect_wire_to_elevator.interact_dont_interupt_on_distance = true
	self.pent_hold_connect_wire_to_elevator.timer = 1
	self.pent_hold_connect_wire_to_door.timer = 1
	self.fex_take_wire.timer = nil
	self.fex_take_wire_axis.timer = nil
	self.fex_take_alarm_clock.timer = nil
	self.fex_take_alarm_clock_axis.timer = nil
	self.hold_approve_req.timer = nil
	self.mus_hold_open_display.timer = nil
	self.mus_take_diamond.timer = 1
	self.pex_hook_car.interact_distance = 100
	self.pex_pickup_cutter.timer = nil
	self.pex_burn.timer = 1
	self.pex_burn.sound_start = "bar_light_fireworks"
	self.pex_burn.sound_interupt = "bar_light_fireworks_cancel"
	self.pex_burn.sound_done = "bar_light_fireworks_finished"
	self.cas_open_securityroom_door.timer = nil
	self.bex_activate_flare.interact_distance = 400
	self.bex_activate_flare.sound_start = "grenade_gas_npc_fire"
	self.bex_activate_flare.sound_interupt = "bar_light_fireworks_cancel"
	self.bex_activate_flare.sound_done = "bar_light_fireworks_finished"
	self.c4_consume_x3.interact_distance = 100
	self.stash_server_pickup.interact_distance = 160
	self.stash_server_pickup.timer = nil
	self.stash_server_pickup_server.interact_distance = 160
	self.stash_server_pickup_server.timer = nil
	self.c4_consume_x3.interact_distance = 100
	self.corp_prop_celing_wires_cut.interact_distance = 200
	self.hold_generator_start.interact_distance = 180
	self.burning_money.interact_distance = 200

	self.gold_pile.interact_distance = 180
	self.gold_pile.timer = 2
	self.take_pardons.timer = nil
	self.gen_pku_blow_torch.timer = nil
	self.drk_pku_blow_torch.timer = nil
	self.gage_assignment.timer = nil    
    self.gage_assignment.sound_event = "money_grab" 

	self.drill_jammed.timer = 8
	self.player_zipline.interact_distance = 200
	self.player_zipline.timer = 1.5
	self.player_zipline.sound_start = "bar_drill_apply"
	self.player_zipline.sound_interupt = "bar_drill_apply_cancel"
	self.player_zipline.sound_done = "bar_drill_apply_finished"
	self.carry_drop.timer = nil
	self.cg22_bag_carry_drop.timer = nil
	self.painting_carry_drop.timer = nil
	self.parachute_carry_drop.timer = nil
	self.hold_grab_goat.timer = nil
	self.goat_carry_drop.timer = nil
	self.hold_pickup_lance.timer = nil

	self.doctor_bag.timer = 8
	self.first_aid_kit.timer = 4

	self.nqr_corpse_loot = {
		icon = "equipment_ammo_bag",
		text_id = "hud_int_nqr_corpse_loot",
        interact_distance = 120,
        timer = 1.5,
        blocked_hint = "full_ammo",
		sound_start = "bar_bag_generic",
		sound_interupt = "bar_bag_generic_cancel",
		sound_done = "bar_bag_generic_finished",
		action_text_id = "hud_action_nqr_corpse_loot",
		interact_dont_interupt_on_distance = true,
	}

    local job = Global.level_data and Global.level_data.level_id
	local lookup = {
		man = { gen_int_saw = { interact_distance = 120 }, gen_int_saw_jammed = { interact_distance = 120 }, gen_int_saw_upgrade = { interact_distance = 120 } },
		flat = { apartment_saw = { interact_distance = 200 }, gen_int_saw_jammed = { interact_distance = 200 }, gen_int_saw_upgrade = { interact_distance = 200 } },
	}
	for i, k in pairs(lookup[job] or {}) do for u, j in pairs(k) do self[i][u] = j end end

end)
