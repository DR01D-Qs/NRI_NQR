--NQR_CORPSE_LOOT ON KILL
function CopLogicInactive._set_interaction(data, my_data)
	if data.unit:character_damage():dead() then
		if managers.groupai:state():whisper_mode() then
			if data.unit:unit_data().has_alarm_pager then
				data.brain:begin_alarm_pager()
			else
				data.unit:interaction():set_tweak_data("corpse_dispose")
				data.unit:interaction():set_active(true, true, true)
			end
		else
			data.unit:interaction():set_tweak_data("nqr_corpse_loot")
			data.unit:interaction():set_active(true, true, true)
		end
	end
end



--DONT DISABLE INTERACTION ON ALARM
function CopLogicInactive.on_enemy_weapons_hot(data)
	local my_data = data.internal_data

	data.unit:brain():set_attention_settings({ corpse_cbt = true })

    data.unit:interaction():set_tweak_data("nqr_corpse_loot")
    data.unit:interaction():set_active(true, true, true)
end
