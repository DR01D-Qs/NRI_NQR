function ElementSpawnEnemyDummy:init(...)
	ElementSpawnEnemyDummy.super.init(self, ...)

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

function ElementSpawnEnemyDummy:produce(params)
	if not managers.groupai:state():is_AI_enabled() then return end

	local players_amount_mul = managers.groupai:state():_get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_balance_mul) or 1

	local harasser = nil
	local denied = nil
	local job = Global.level_data and Global.level_data.level_id
	local forbids = {
		election_day_1 = {
			"ai_spawn_enemy_039",
			"ai_spawn_enemy_040",
			"ai_spawn_enemy_067",
			"ai_spawn_enemy_068",
			"ai_spawn_enemy_069",
			"ai_spawn_enemy_070",
			"ai_spawn_enemy_071",
			"ai_spawn_enemy_072",
			"ai_spawn_enemy_084",
			"ai_spawn_enemy_085",
			"ai_spawn_enemy_086",
			"ai_spawn_enemy_087",
			"ai_spawn_enemy_088",
			"ai_spawn_enemy_089",
			"ai_spawn_enemy_090",
			"ai_spawn_enemy_091",
			"ai_spawn_enemy_092",
			"ai_spawn_enemy_093",
			"ai_spawn_enemy_094",
			"ai_spawn_enemy_095",
			"ai_spawn_enemy_096",
			"ai_spawn_enemy_097",
			"ai_spawn_enemy_098",
			"ai_spawn_enemy_099",
		},
		election_day_3 = {
			"ai_spawn_enemy_013",
			"ai_spawn_enemy_009",

			"spawn1_001",
			"spawn1_002",
			"spawn1_003",
			"spawn1_004",
			"spawn1_005",
			"spawn1_006",
			"spawn2_001",
			"spawn2_002",
			"spawn2_003",
			"spawn2_004",
			"spawn2_005",
			"spawn2_006",
			"spawn3_001",
			"spawn3_002",
			"spawn3_003",
			"spawn3_004",
			"spawn3_005",
			"spawn3_006",
			"spawn4_001",
			"spawn4_002",
			"spawn4_003",
			"spawn4_004",
			"spawn4_005",
			"spawn4_006",
			"spawn5_001",
			"spawn5_002",
			"spawn5_003",
			"spawn5_004",
			"spawn5_005",
			"spawn5_006",
			"spawn6_001",
			"spawn6_002",
			"spawn6_003",
			"spawn6_004",
			"spawn6_005",
			"spawn6_006",
		},
	}
	forbids.election_day_3_skip1 = deep_clone(forbids.election_day_3)
	forbids.election_day_3_skip2 = deep_clone(forbids.election_day_3)

	local lookup = {
		{ editor_name = "haras" },
		{ instance_name = "haras" },
	}
	if not string.find(self._editor_name, "boss") and (
		string.find(self._editor_name, "haras") or string.find(self._values and self._values.instance_name or "", "haras")
		or string.find(self._editor_name, "supres") or string.find(self._values and self._values.instance_name or "", "supres")
		or string.find(job, "election_day_3") and string.find(self._editor_name, "escape")
		or string.find(self._values and self._values.instance_name or "", "pbr_stationary")
		or string.find(self._values and self._values.instance_name or "", "pet_helicopter_swat")
		or job=="peta2" and string.find(self._editor_name, "swat")
	) then
		harasser = true
	else
		for i, k in pairs(forbids[job] or {}) do if self._editor_name==k then harasser = true break end end
	end
	local deny_harasser = math.random() > ((job=="peta2" and (0.4 * players_amount_mul)) or (job=="flat" and (0.1 * players_amount_mul)) or 0.2)
	if harasser and deny_harasser and not string.find(self._values and self._values.instance_name or "", "pet_roadswats") then denied = true end

	local deny_other = math.random() > (0.4 * players_amount_mul)
	if not denied and deny_other and (
		string.find(self._values and self._values.instance_name or "", "prison_train_")
		or job=="pbr2" and (
			string.find(self._editor_name, "sniper")
			or string.find(self._editor_name, "_entry_enem")
			or string.find(self._editor_name, "sewer_enem")
			or string.find(self._values and self._values.instance_name or "", "sewer_enem")
			or string.find(self._values and self._values.instance_name or "", "pbr_plane_c")
		)
		or job=="deep" and string.find(self._editor_name, "dozer_overkill")
		or job=="wwh" and string.find(self._editor_name, "intro_shield")
		or job=="jolly" and string.find(self._editor_name, "ai_spawn_enemy_br")
		or job=="peta2" and string.find(self._editor_name, "thug") and not string.find(self._editor_name, "thug_scene")
		or job=="peta" and string.find(self._editor_name, "cop") and not string.find(self._editor_name, "_cop")
		or job=="nail" and (
			string.find(self._editor_name, "titan")
			or string.find(self._editor_name, "ai_spawn_enemy_001")
			or string.find(self._editor_name, "ai_spawn_enemy_002")
		)
		or string.find(job, "welcome_to_the_jungle_1") and (
			string.find(self._editor_name, "ai_spawn_enemy_018")
			or string.find(self._editor_name, "ai_spawn_enemy_019")
			or string.find(self._editor_name, "ai_spawn_enemy_020")
			or string.find(self._editor_name, "ai_spawn_enemy_021")
		)
		or string.find(self._editor_name, "murky_water_")
		or string.find(self._editor_name, "enemy_ambush_windows")
		or string.find(self._editor_name, "sniper") and (
			job=="mia_2"
			or job=="family"
			or job=="born"
			or job=="shoutout_raid"
			or job=="alex_1"
			or job=="rat"
			or job=="big"
			or job=="arm_hcm"
			or job=="arm_cro"
			or job=="roberts"
			or job=="chca"
			or job=="election_day_2"
			or job=="man"
			or job=="hox_2"
			or job=="wwh"
			or (job=="mad" and not string.find(self._editor_name, "_sniper"))
		)
	) then
		denied = true
	end

	local function harasser_deheavify(name)
		local deheav_lookup = {
			[Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"):key()] = Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
		}
		return harasser and deheav_lookup[name:key()] or name
	end

	local ass_phase = managers.groupai:state()._task_data.assault.phase
	denied = denied or (not (job=="wwh") and harasser and (ass_phase=="fade" or not ass_phase))



	local unit = nil
	local pos, rot = self:get_orientation()
	if denied then pos = pos + Vector3(0,0,-100000) end

	if params and params.name then
		unit = safe_spawn_unit(harasser_deheavify(params.name), pos, rot)
		local spawn_ai = self:_create_spawn_AI_parametric(params.stance, params.objective, self._values)
		unit:brain():set_spawn_ai(spawn_ai)
	else
		local enemy_name = self:value("enemy") or self._enemy_name
		unit = safe_spawn_unit(harasser_deheavify(enemy_name), pos, rot)
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