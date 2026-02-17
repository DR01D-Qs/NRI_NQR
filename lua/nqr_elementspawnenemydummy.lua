core:import("CoreMissionScriptElement")

ElementSpawnEnemyDummy = ElementSpawnEnemyDummy or class(CoreMissionScriptElement.MissionScriptElement)

function ElementSpawnEnemyDummy:init(...)
	ElementSpawnEnemyDummy.super.init(self, ...)

    local job = Global.level_data and Global.level_data.level_id
	local lookup_cut = {
		pal = {
			ai_spawn_enemy_shield_defend005 = { [101483] = true, },
			ai_spawn_enemy_shield_defend011 = { [101483] = true, },
			ai_spawn_enemy_shield_defend003 = { [101321] = true, },
			ai_spawn_enemy_shield_defend009 = { [101321] = true, },
		},
	}
	if lookup_cut[job] and lookup_cut[job][self._editor_name] and self._values.on_executed then
		for i, k in pairs(self._values.on_executed) do
			if lookup_cut[job][self._editor_name][k.id] then table.remove(self._values.on_executed, i) end
		end
		self._values.enabled = false
	end

	self._enemy_name = self._values.enemy and Idstring(self._values.enemy) or Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
	self._values.enemy = nil
	self._units = {}
	self._events = {}

	self:_finalize_values()
end

function ElementSpawnEnemyDummy:on_executed(instigator)
	if not self._values.enabled then return end
	if not managers.groupai:state():is_AI_enabled() and not Application:editor() then return end

	local unit, denied = self:produce()
	ElementSpawnEnemyDummy.super.on_executed(self, unit)

	if denied then
		unit:character_damage():damage_mission({damage = 1000, forced = true, variant = "denied"})
		unit:brain():set_active(false)
		unit:base():set_slot(unit, 0)
	end
end



local rtrn_buffer = {}
local hrss_buffer = {}
local deny_buffer = {}

local sfind = string.find
local function sfind_plain(string, text)
	return sfind(string, text, 1, true)
end
local function sfindt_plain(string, table)
	for i, k in pairs(table or {}) do
		if sfind_plain(string, k) then return true end
	end
end

local job_instance_returns = {
	peta2 = { "pet_roadswats" },
	wwh = { "intro_shield009", "intro_shield012", "intro_shield013", "intro_shield016" },
}

local haras_job_denys_specific = {
	election_day_1 = {
		ai_spawn_enemy_039 = true,
		ai_spawn_enemy_040 = true,
		ai_spawn_enemy_067 = true,
		ai_spawn_enemy_068 = true,
		ai_spawn_enemy_069 = true,
		ai_spawn_enemy_070 = true,
		ai_spawn_enemy_071 = true,
		ai_spawn_enemy_072 = true,
		ai_spawn_enemy_084 = true,
		ai_spawn_enemy_085 = true,
		ai_spawn_enemy_086 = true,
		ai_spawn_enemy_087 = true,
		ai_spawn_enemy_088 = true,
		ai_spawn_enemy_089 = true,
		ai_spawn_enemy_090 = true,
		ai_spawn_enemy_091 = true,
		ai_spawn_enemy_092 = true,
		ai_spawn_enemy_093 = true,
		ai_spawn_enemy_094 = true,
		ai_spawn_enemy_095 = true,
		ai_spawn_enemy_096 = true,
		ai_spawn_enemy_097 = true,
		ai_spawn_enemy_098 = true,
		ai_spawn_enemy_099 = true,
	},
	election_day_3 = {
		ai_spawn_enemy_013 = true,
		ai_spawn_enemy_009 = true,

		spawn1_001 = true,
		spawn1_002 = true,
		spawn1_003 = true,
		spawn1_004 = true,
		spawn1_005 = true,
		spawn1_006 = true,
		spawn2_001 = true,
		spawn2_002 = true,
		spawn2_003 = true,
		spawn2_004 = true,
		spawn2_005 = true,
		spawn2_006 = true,
		spawn3_001 = true,
		spawn3_002 = true,
		spawn3_003 = true,
		spawn3_004 = true,
		spawn3_005 = true,
		spawn3_006 = true,
		spawn4_001 = true,
		spawn4_002 = true,
		spawn4_003 = true,
		spawn4_004 = true,
		spawn4_005 = true,
		spawn4_006 = true,
		spawn5_001 = true,
		spawn5_002 = true,
		spawn5_003 = true,
		spawn5_004 = true,
		spawn5_005 = true,
		spawn5_006 = true,
		spawn6_001 = true,
		spawn6_002 = true,
		spawn6_003 = true,
		spawn6_004 = true,
		spawn6_005 = true,
		spawn6_006 = true,
	},
	pal = {
		ai_spawn_enemy_shield_defend005 = true,
		ai_spawn_enemy_shield_defend011 = true,
		ai_spawn_enemy_shield_defend014 = true,

		ai_spawn_enemy_shield_defend003 = true,
		ai_spawn_enemy_shield_defend009 = true,
		ai_spawn_enemy_shield_defend016 = true,
	},
}
local haras_job_denys = {
	election_day_3 = { "escape" },
	peta2 = { "swat" },
}

local job_denys_specific = {
	nail = {
		ai_spawn_enemy_001 = true,
		ai_spawn_enemy_002 = true,
	},
	welcome_to_the_jungle_1 = {
		ai_spawn_enemy_018 = true,
		ai_spawn_enemy_019 = true,
		ai_spawn_enemy_020 = true,
		ai_spawn_enemy_021 = true,
	},
	run = {
		force_spawned_cop = true,
		ai_spawn_enemy_206 = true,
		ai_spawn_enemy_205 = true,
		ai_spawn_enemy_151 = true,
		ai_spawn_enemy_056 = true,
		ai_spawn_enemy_087 = true,
		ai_spawn_enemy_152 = true,
		ai_spawn_enemy_187 = true,
		ai_spawn_enemy_188 = true,
		ai_spawn_enemy_185 = true,
		ai_spawn_enemy_204 = true,
		ai_spawn_enemy_116 = true,
		ai_spawn_enemy_184 = true,
		ai_spawn_enemy_186 = true,
		ai_spawn_enemy_127 = true,
		ai_spawn_enemy_128 = true,
	},
	wwh = {
		ai_spawn_enemy_091 = true,
		ai_spawn_enemy_085 = true,
		ai_spawn_enemy_012 = true,
		ai_spawn_enemy_057 = true,
		ai_spawn_enemy_011 = true,
		ai_spawn_enemy_013 = true,
		ai_spawn_enemy_083 = true,
		ai_spawn_enemy_058 = true,
		ai_spawn_enemy_059 = true,
		ai_spawn_enemy_084 = true,
		ai_spawn_enemy_082 = true,
		ai_spawn_enemy_087 = true,
		ai_spawn_enemy_088 = true,
		ai_spawn_enemy_094 = true,
		ai_spawn_enemy_093 = true,
		ai_spawn_enemy_086 = true,
		ai_spawn_enemy_092 = true,
		ai_spawn_enemy_009 = true,
		ai_spawn_enemy_056 = true,
		ai_spawn_enemy_076 = true,
		ai_spawn_enemy_094 = true,
		ai_spawn_enemy_015 = true,
		ai_spawn_enemy_060 = true,
	},
	glace = {
		ai_spawn_cop_001 = true,
		ai_spawn_cop_002 = true,
		ai_spawn_cop_006 = true,
		ai_spawn_cop_007 = true,
		ai_spawn_cop_010 = true,
		ai_spawn_cop_011 = true,
		spawn_left1_helicopter001_hard_vh_ovk = true,
	},
	bph = {
		ai_spawn_enemy_133 = true,
		ai_spawn_enemy_132 = true,
		ai_spawn_enemy_116 = true,
		ai_spawn_enemy_136 = true,
		ai_spawn_enemy_137 = true,
		ai_spawn_enemy_138 = true,
		ai_spawn_enemy_140 = true,
		ai_spawn_enemy_139 = true,
	},
}
--instance glace_helicopter_dozer_003
--glace_prison_bus_002 ai_spawn_enemy_002
local job_denys = {
	pbr2 = { "sniper", "_entry_enem", "sewer_enem" },
	deep = { "dozer_overkill" },
	wwh = { "intro_shield", "ambush_enemy", "train_dozer" },
	jolly = { "ai_spawn_enemy_br" },
	mex = { "enemy_thug_mexico", "ai_spawn_enemy_biker" },
	nail = { "titan" },
	pbr = { "_blockade_", "murky_reinforcements", "welcoming_party_", "slope_", "shield_wall_", "ctrl_room_", "surface_", "dozer_hell_", "sniper_ambush" },
	red2 = { "_after_vault" },
	spa = { "ai_spawn_gangster_apt" },
	bph = { "spawn_ambush_connector_", "spawn_ambush_turretroom_" },
	des = { "ai_spawn_murkywater_" }
}
local job_instance_denys = {
	pbr2 = { "sewer_enem", "pbr_plane_" },
	deep = { "deep_helicopter_enemies" },
	spa = { "spa_gangster_group_" },
}

local sniper_denys = {
	mia_2 = true,
	family = true,
	born = true,
	shoutout_raid = true,
	alex_1 = true,
	rat = true,
	big = true,
	arm_hcm = true,
	arm_cro = true,
	roberts = true,
	chca = true,
	election_day_2 = true,
	man = true,
	hox_2 = true,
	wwh = true,
}

local function harasser_deheavify(name)
	local deheav_lookup = {
		[Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"):key()] = Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
		[Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"):key()] = Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
	}
	return deheav_lookup[name:key()] or name
end

function ElementSpawnEnemyDummy:produce(params)
	if not managers.groupai:state():is_AI_enabled() then return end

	local editor_name = self._editor_name
	local instance_name = self._values and self._values.instance_name or ""
	local job = Global.level_data and Global.level_data.level_id
	if sfind_plain(job, "election_day_3") then job = "election_day_3"
	elseif sfind_plain(job, "welcome_to_the_jungle_1") then job = "welcome_to_the_jungle_1"
	end

	local harasser = nil
	local denied = nil
	local dont_antiharass = nil

	if rtrn_buffer[editor_name]
	or (job_instance_returns[job] and sfindt_plain(instance_name, job_instance_returns[job]))
	or sfind_plain(editor_name, "boss") 
	then
		rtrn_buffer[editor_name] = true
		dont_antiharass = true
	else
		local players_amount_mul = managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_balance_mul) or 1

		if hrss_buffer[editor_name]
		or (haras_job_denys_specific[job] and haras_job_denys_specific[job][editor_name])
		or (haras_job_denys[job] and sfindt_plain(editor_name, haras_job_denys[job]))
		or (
			sfind_plain(editor_name, "haras") or sfind_plain(instance_name, "haras")
			or sfind_plain(editor_name, "supres") or sfind_plain(instance_name, "supres")
			or sfind_plain(instance_name, "pbr_stationary")
			or sfind_plain(instance_name, "pet_helicopter_swat")
		) then
			hrss_buffer[editor_name] = true
			harasser = true
		end

		local deny_harasser_proc = math.random() > (
			(job=="peta2" and (0.4 * players_amount_mul))
			or (job=="flat" and (0.1 * players_amount_mul))
			or 0.2
		)
		local deny_other_proc = math.random() > ((job=="jolly" and 0.2 or 0.4) * players_amount_mul)

		if (harasser and deny_harasser_proc)
		or deny_other_proc and (
			deny_buffer[editor_name] or (
				(job_denys_specific[job] and job_denys_specific[job][editor_name])
				or (job_denys[job] and sfindt_plain(editor_name, job_denys[job]))
				or (job_instance_denys[job] and sfindt_plain(instance_name, job_instance_denys[job]))
				or (sfind_plain(editor_name, "sniper") and sniper_denys[job])
				or (
					job=="peta2" and sfind_plain(editor_name, "thug") and not sfind_plain(editor_name, "thug_scene")
					or job=="peta" and sfind_plain(editor_name, "cop") and not sfind_plain(editor_name, "_cop")
					or job=="mad" and sfind_plain(editor_name, "sniper") and not sfind_plain(editor_name, "_sniper")
				)
				or (
					sfind_plain(instance_name, "prison_train_")
					or sfind_plain(editor_name, "murky_water_")
					or sfind_plain(editor_name, "enemy_ambush_windows")
				)
			)
		) then
			deny_buffer[editor_name] = true
			denied = true
		end

		local ass_phase = managers.groupai:state()._task_data.assault.phase
		denied = denied or (not (job=="wwh") and harasser and (ass_phase=="fade" or not ass_phase))
	end

	local unit = nil
	local pos, rot = self:get_orientation()
	if denied then pos = pos + Vector3(0,0,-100000) end

	if params and params.name then
		unit = safe_spawn_unit(harasser and harasser_deheavify(params.name) or params.name, pos, rot)
		local spawn_ai = self:_create_spawn_AI_parametric(params.stance, params.objective, self._values)
		unit:brain():set_spawn_ai(spawn_ai)
	else
		local enemy_name = self:value("enemy") or self._enemy_name
		unit = safe_spawn_unit(harasser and harasser_deheavify(enemy_name) or enemy_name, pos, rot)
		local objective = nil
		local action = self._create_action_data(CopActionAct._act_redirects.enemy_spawn[self._values.spawn_action])
		local stance = managers.groupai:state():enemy_weapons_hot() and "cbt" or "ntl"

		if action.type == "act" then
			objective = {
				type = "act",
				action = action,
				stance = stance
			}
		end

		local spawn_ai = {
			init_state = "idle",
			objective = objective
		}

		unit:brain():set_spawn_ai(spawn_ai)

		local team_id = params and params.team or self._values.team or tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")

		if self._values.participate_to_group_ai then
			managers.groupai:state():assign_enemy_to_group_ai(unit, team_id)
		else
			managers.groupai:state():set_char_team(unit, team_id)
		end

		if self._values.voice then
			unit:sound():set_voice_prefix(self._values.voice)
		end
	end

	unit:base():add_destroy_listener(self._unit_destroy_clbk_key, callback(self, self, "clbk_unit_destroyed"))

	unit:unit_data().mission_element = self

	table.insert(self._units, unit)
	self:event("spawn", unit)

	if self._values.force_pickup and self._values.force_pickup ~= "none" then
		local pickup_name = self._values.force_pickup ~= "no_pickup" and self._values.force_pickup or nil

		unit:character_damage():set_pickup(pickup_name)
	end

	return unit, denied
end