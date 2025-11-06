--NOT SURE IF I NEED THAT BUT WONT HURT
function CopLogicPhalanxMinion.damage_clbk(data, damage_info)
	CopLogicIdle.damage_clbk(data, damage_info)
	CopLogicPhalanxMinion.chk_should_breakup(data)
end

--BREAKUP CONDITION, BREAKUP VOICELINE, END WINTERS ASSAULT, REMOVE BUFF HUD
function CopLogicPhalanxMinion.chk_should_breakup()
	local phalanx_minion_count = managers.groupai:state():get_phalanx_minion_count()
	local min_count_minions = tweak_data.group_ai.phalanx.minions.min_count

	if phalanx_minion_count <= min_count_minions then
        managers.game_play_central:announcer_say("cpw_a04")

		CopLogicPhalanxMinion.breakup()
        managers.groupai:state():force_end_assault_phase()
	    managers.groupai:state():phalanx_damage_reduction_disable()
	end
end

--ADD BUFF HUD, ASSEMBLED VOICELINE, SET RUSHING OBJECTIVE AFTER ASSEMBLE
function CopLogicPhalanxMinion.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)

	local my_data = {
		unit = data.unit
	}
	local is_cool = data.unit:movement():cool()
	my_data.detection = data.char_tweak.detection.combat
	local old_internal_data = data.internal_data

	if old_internal_data then
		my_data.turning = old_internal_data.turning

		if old_internal_data.firing then
			data.unit:movement():set_allow_fire(false)
		end

		if old_internal_data.shooting then
			data.unit:brain():action_request({
				body_part = 3,
				type = "idle"
			})
		end

		local lower_body_action = data.unit:movement()._active_actions[2]
		my_data.advancing = lower_body_action and lower_body_action:type() == "walk" and lower_body_action
	end

	data.internal_data = my_data
	local key_str = tostring(data.unit:key())
	my_data.detection_task_key = "CopLogicPhalanxMinion.update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicPhalanxMinion.queued_update, data, data.t)

	local objective = data.objective
	objective.attitude = "engage"

	CopLogicPhalanxMinion._chk_has_old_action(data, my_data)

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range

	CopLogicPhalanxMinion.calc_initial_phalanx_pos(data.m_pos, objective)
	data.unit:brain():set_update_enabled_state(false)
	CopLogicPhalanxMinion._perform_objective_action(data, my_data, objective)
	managers.groupai:state():phalanx_damage_reduction_enable()
	managers.game_play_central:announcer_say("cpw_a01")

    local pos = managers.groupai:state()._phalanx_center_pos
    local nav_seg = managers.navigation:get_nav_seg_from_pos(pos)
    local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
    local grp_objective = {
        type = "assault_area",
        area = area,
        nav_seg = nav_seg,
    }
    managers.groupai:state():_set_objective_to_enemy_group(managers.groupai:state()._phalanx_spawn_group, grp_objective)

	if my_data ~= data.internal_data then
		return
	end
end
