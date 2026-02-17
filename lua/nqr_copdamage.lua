local mvec_1 = Vector3()
local mvec_2 = Vector3()
local temp_vec3 = Vector3()
local mvec3_dir = mvector3.direction

CopDamage._hurt_severities = {
	heavy = "heavy_hurt",
	fire = "fire_hurt",
	poison = "poison_hurt",
	explode = "expl_hurt",
	moderate = "hurt",
	light = "light_hurt",
	none = false
}



function CopDamage:_comment_death(...) end



function CopDamage:damage_mission(attack_data)
	if self._dead or (self._invulnerable or self._immortal) and not attack_data.forced then
		return
	end

	if self.immortal and self.is_escort then
		if attack_data.backup_so then
			attack_data.backup_so:on_executed(self._unit)
		end

		return
	end

	local damage_percent = self._HEALTH_GRANULARITY
	local result_type = self:get_damage_type(damage_percent)
	local result = {
		type = result_type,
		variant = attack_data.variant
	}

	if (not attack_data.pls_dont_just_kill_the_guy) or self._health<=attack_data.damage then
		attack_data.damage = self._health
		result = {
			type = "death",
			variant = attack_data.variant
		}

		self:die(attack_data)

		if attack_data.attacker_unit == managers.player:local_player() and CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.money:civilian_killed()
		end
	else
		self:_apply_damage_to_health(attack_data.damage)
	end

	attack_data.result = result
	attack_data.attack_dir = self._unit:rotation():y()
	attack_data.pos = self._unit:position()

	--log(attack_data.damage)
	--log(result_type)

	self:_send_explosion_attack_result(attack_data, self._unit, damage_percent, self:_get_attack_variant_index("explosion"), attack_data.col_ray and attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end



--REMOVE IMPACT EFFECT
function CopDamage:damage_simple(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage

	if self._unit:base():char_tweak().DAMAGE_CLAMP_SHOCK then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_SHOCK)
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = self:get_damage_type(damage_percent)
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "shock", false, attack_data.weapon_unit and attack_data.weapon_unit:base():get_name_id())

		if attacker_unit == managers.player:player_unit() then
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local i_result = ({
		healed = 3,
		knock_down = 1,
		stagger = 2
	})[result.type] or 0

	self:_send_simple_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end
function CopDamage:sync_damage_simple(attacker_unit, damage_percent, i_attack_variant, i_result, death)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	mvector3.set_z(hit_pos, hit_pos.z + 100)

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = variant
	attack_data.weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		distance = mvector3.normalize(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, variant, false, attack_data.weapon_unit and attack_data.weapon_unit:base():get_name_id())

		local data = {
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if data.weapon_unit then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = i_result == 1 and "knock_down" or i_result == 2 and "stagger" or self:get_damage_type(damage_percent)

		if i_result == 3 then
			result_type = "healed"
		end

		result = {
			type = result_type,
			variant = variant
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
end



--GET DAMAGE TYPE: -
function CopDamage:get_damage_type(damage_percent, category)
	if not (self._char_tweak and self._char_tweak.damage and self._char_tweak.damage.hurt_severity) then
		--log(self._unit and self._unit:base() and self._unit:base()._tweak_table)
		return "dmg_rcv"
	end
	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	local dmg = damage_percent / self._HEALTH_GRANULARITY

	if hurt_table.health_reference == "full" then
		-- Nothing
	elseif hurt_table.health_reference == "current" then
		dmg = math.min(1, self._HEALTH_INIT * dmg / self._health)
	else
		dmg = math.min(1, self._HEALTH_INIT * dmg / hurt_table.health_reference)
	end

	local zone = nil
	for i_zone, test_zone in ipairs(hurt_table.zones) do
		if i_zone == #hurt_table.zones or test_zone.health_limit>dmg then zone = test_zone break end
	end

	local rand_nr = math.random()
	local total_w = 0
	for i, k in pairs(self._hurt_severities) do
		if zone[i] and zone[i] > 0 then
			total_w = total_w + zone[i]
			if rand_nr <= total_w then return k or "dmg_rcv" end
		end
	end

	return "dmg_rcv"
end



--DIE: SEND DEATH VARIANT TO DROP_PICKUP
function CopDamage:die(attack_data)
	if self._immortal then
		debug_pause("Immortal character died!")
	end

	local variant = attack_data.variant

	self:_check_friend_4(attack_data)
	self:_check_ranc_9(attack_data)
	CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	self:_remove_debug_gui()
	self._unit:base():set_slot(self._unit, 17)

	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end

	self:drop_pickup(variant)

	self._unit:inventory():drop_shield()
	self:_chk_unique_death_requirements(attack_data, true)

	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)

		if not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end
	end

	if self._unit:movement() then
		self._unit:movement():remove_giveaway()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)

	if self._death_sequence then
		if self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
			self._unit:damage():run_sequence_simple(self._death_sequence)
		else
			debug_pause_unit(self._unit, "[CopDamage:die] does not have death sequence", self._death_sequence, self._unit)
		end
	end

	if self._unit:base():char_tweak().die_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().die_sound_event, nil, nil)
	end

	self:_on_death()
	managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)

	if self._tmp_invulnerable_clbk_key then
		managers.enemy:remove_delayed_clbk(self._tmp_invulnerable_clbk_key)

		self._tmp_invulnerable_clbk_key = nil
	end
end



--DROP PICKUP: DELET_THIS
function CopDamage:drop_pickup(variant)
	if self._pickup then
		local tracker = self._unit:movement():nav_tracker()
		local position = tracker:lost() and tracker:field_position() or tracker:position()
		local rotation = self._unit:rotation()

		mvector3.set(mvec_1, position)

		local level_data = tweak_data.levels[managers.job:current_level_id()]

		if level_data and level_data.drop_pickups_to_ground then
			mvector3.set(mvec_2, math.UP)
			mvector3.multiply(mvec_2, -200)
			mvector3.add(mvec_2, mvec_1)

			local ray = self._unit:raycast("ray", mvec_1, mvec_2, "slot_mask", managers.slot:get_mask("bullet_impact_targets"))

			if ray then
				mvector3.set(mvec_1, ray.hit_position)
			end
		end

		if self._pickup~="ammo" then
			managers.game_play_central:spawn_pickup({ name = self._pickup, position = mvec_1, rotation = rotation })
		end
	end
end



--DAMAGE MELEE: KNOCKDOWN SHENANIGANS
function CopDamage:damage_melee(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if self:chk_immune_to_attacker(attack_data.attacker_unit) then
		return
	end

	local result = nil
	local is_civlian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local is_gangster = CopDamage.is_gangster(self._unit:base()._tweak_table)
	local is_cop = not is_civlian and not is_gangster
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		if tweak_data.achievement.cavity.melee_type == attack_data.name_id and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
	end

	if self._unit:movement():cool() then damage = self._HEALTH_INIT end

	local damage_effect = attack_data.damage_effect
	local damage_effect_percent = 1
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then damage = math.min(damage, self._health - 1) end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			damage_effect_percent = 1
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "melee", false, attack_data.name_id)
		end
	else
		attack_data.damage = damage
		damage_effect = math.clamp(damage_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		damage_effect_percent = self._HEALTH_GRANULARITY --math.clamp(damage_effect_percent, 1, self._HEALTH_GRANULARITY)
		local result_type = attack_data.shield_knock and self._char_tweak.damage.shield_knocked and "shield_knock" or attack_data.variant == "counter_tased" and "counter_tased" or attack_data.variant == "taser_tased" and "taser_tased" or attack_data.variant == "counter_spooc" and "expl_hurt" or self:get_damage_type(damage_effect_percent, "melee") or "fire_hurt"
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local dismember_victim = false
	local snatch_pager = false

	if result.type == "death" then
		if self:_dismember_condition(attack_data) then
			self:_dismember_body_part(attack_data)

			dismember_victim = true
		end

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			name_id = attack_data.name_id,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.attacker_unit == managers.player:player_unit() then
			managers.statistics:killed(data)

			if not is_civlian and managers.groupai:state():whisper_mode() and managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.cant_hear_you_scream.mask then
				managers.achievment:award_progress(tweak_data.achievement.cant_hear_you_scream.stat)
			end

			mvector3.set(mvec_1, self._unit:position())
			mvector3.subtract(mvec_1, attack_data.attacker_unit:position())
			mvector3.normalize(mvec_1)
			mvector3.set(mvec_2, self._unit:rotation():y())

			local from_behind = mvector3.dot(mvec_1, mvec_2) >= 0

			if is_cop and Global.game_settings.level_id == "nightclub" and attack_data.name_id and attack_data.name_id == "fists" then
				managers.achievment:award_progress(tweak_data.achievement.final_rule.stat)
			end

			if is_civlian then
				managers.money:civilian_killed()
			elseif math.rand(1) < managers.player:upgrade_value("player", "melee_kill_snatch_pager_chance", 0) then
				snatch_pager = true
				self._unit:unit_data().has_alarm_pager = false
			end
		end
	end

	self:_check_melee_achievements(attack_data)

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local variant = nil

	if result.type == "shield_knock" then
		variant = 1
	elseif result.type == "counter_tased" then
		variant = 2
	elseif result.type == "expl_hurt" then
		variant = 4
	elseif snatch_pager then
		variant = 3
	elseif result.type == "taser_tased" then
		variant = 5
	elseif dismember_victim then
		variant = 6
	elseif result.type == "healed" then
		variant = 7
	else
		variant = 0
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	self:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	self:_on_damage_received(attack_data)

	return result
end



--DAMAGE BULLET: PENETRATION SYSTEM
function CopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then return end
	if self:chk_immune_to_attacker(attack_data.attacker_unit) then return end

	mvector3.set(mvec_1, attack_data.col_ray.ray)
	mvector3.set_z(mvec_1, 0)
	mrotation.y(self._unit:rotation(), mvec_2)
	mvector3.set_z(mvec_2, 0)
	local hit_front = mvector3.dot(mvec_1, mvec_2) < -0.2
	local hit_back = mvector3.dot(mvec_1, mvec_2) > 0.2
	local char_tweak = self._unit:base():char_tweak()
	local armor = char_tweak.armor
	local spot = attack_data.col_ray.body:name()
	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	local slip_through = nil
	local absorb_tier = 0
	local absorb_chance = 0
	local absorb_table = { 300, 2000, 4000, 8000 } absorb_table[0] = 0
	local absorb_roll = math.random()
	local crit_chance = 0
	local crit_roll = math.random()
	local switch = nil

	if attack_data.col_ray.body then
		if spot==Idstring("head") then
			absorb_tier = hit_back and armor.head[1] or (absorb_roll<armor.head[2] and armor.head[1] or armor.face[1])
			absorb_chance = hit_back and armor.head[3] or (absorb_roll<armor.head[2] and armor.head[2] or armor.face[2]+armor.head[2])
			damage = damage * 8
			crit_chance = 0.8
		elseif spot==Idstring("body_helmet") or spot==Idstring("body_helmet_glass") or spot==Idstring("body_helmet_plate") then
			if spot==Idstring("body_helmet_glass") then switch = "glass_breakable" end
			absorb_tier = armor.head[1]
			absorb_chance = 2
			damage = damage * 5
			crit_chance = 0.8
		elseif spot==Idstring("body_armor_chest") or spot==Idstring("body_armor_stomache") or spot==Idstring("body_armor_back") then
			absorb_tier = 4
			absorb_chance = 2
			damage = damage * 1
			crit_chance = 0.4
		elseif spot==Idstring("body") or spot==Idstring("body_plate") then
			if spot==Idstring("body") then switch = true
			elseif spot==Idstring("body_plate") and self._unit:base()._tweak_table=="tank_hw" then return end
			absorb_tier = armor.whole_body or (hit_front and armor.body or armor.back)
			absorb_chance = armor.whole_body and 2 or 1
			damage = damage * 1
			crit_chance = 0.4
		elseif spot==Idstring("rag_LeftArm") or spot==Idstring("rag_RightArm") or spot==Idstring("LeftArm") or spot==Idstring("RightArm") then
			absorb_tier = armor.whole_body or armor.upper_arm
			absorb_chance = armor.whole_body and 2 or (hit_back and 0.9 or 1)
			damage = damage * 0.6
			switch = true
		elseif spot==Idstring("rag_LeftForeArm") or spot==Idstring("rag_RightForeArm") or spot==Idstring("LeftForeArm") or spot==Idstring("RightForeArm") then
			absorb_tier = armor.whole_body or armor.lower_arm
			absorb_chance = armor.whole_body and 2 or 1
			damage = damage * 0.4
			switch = true
		elseif spot==Idstring("rag_LeftUpLeg") or spot==Idstring("rag_RightUpLeg") or spot==Idstring("LeftUpLeg") or spot==Idstring("RightUpLeg") then
			absorb_tier = armor.whole_body or armor.upper_legs
			absorb_chance = armor.whole_body and 2 or 0.8
			damage = damage * 0.8
			switch = true
		elseif spot==Idstring("rag_LeftLeg") or spot==Idstring("rag_RightLeg") or spot==Idstring("LeftLeg") or spot==Idstring("RightLeg") then
			absorb_tier = armor.whole_body or armor.lower_legs
			absorb_chance = armor.whole_body and 2 or (hit_back and 0 or 1)
			damage = damage * 0.6
			switch = true
		elseif armor.whole_body then
			absorb_tier = armor.whole_body
			absorb_chance = 2
			damage = damage * 0.2
			switch = true
		end
	end

	local target_dis = attack_data.col_ray.distance*attack_data.col_ray.distance --mvector3.distance_sq(self._unit:position(), attack_data.attacker_unit:position())
	local pointblank_dis = 100
	if target_dis < (pointblank_dis*pointblank_dis) and absorb_chance<2 then slip_through = 1 end

	if math.random(20) < (damage-30) then end

	attack_data.penetration = attack_data.penetration or 1000
	local penetration_tier = 0
	for i, k in pairs(absorb_table) do if attack_data.penetration>k then penetration_tier = i+1 end end

	if absorb_roll<absorb_chance and not slip_through then
		if penetration_tier > absorb_tier then
			damage = damage * ( 1 - ( absorb_table[absorb_tier] / attack_data.penetration ) ) * ((crit_roll<crit_chance) and 100 or 1) --damage - (absorb_table[absorb_tier]/90)*2
			attack_data.penetration = attack_data.penetration * ( 1 - ( absorb_table[absorb_tier] / attack_data.penetration ) )
			attack_data.penetration = math.max(0, attack_data.penetration - 100)
			switch = Idstring("flesh")
		else
			damage = damage / ((absorb_tier+0.5)^2.5)
			attack_data.penetration = 0
			switch = (
				(switch==true and armor.whole_body) and Idstring("concrete")
				or switch=="glass_breakable" and Idstring("glass_breakable")
				or Idstring("steel")
			)
		end

		if absorb_tier==4 then
			damage = damage * 0.25
			attack_data.penetration = attack_data.penetration * 0.25
		end
	else
		switch = Idstring("flesh")
	end

	local headshot = false
	if attack_data.attacker_unit == managers.player:player_unit() then
		local damage_scale = nil

		if alive(attack_data.weapon_unit) and attack_data.weapon_unit:base() and attack_data.weapon_unit:base().is_weak_hit then
			local weak_hit = attack_data.weapon_unit:base():is_weak_hit(attack_data.col_ray and attack_data.col_ray.distance, attack_data.attacker_unit)
			damage_scale = weak_hit and 0.5 or 1
		end

		if head then
			headshot = true
		end
	end

	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then damage = math.min(damage, self._health - 1) end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = { type = "healed", variant = attack_data.variant }
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				if attack_data.raw_damage>math.random(1000, 10000) then
					self:_spawn_head_gadget({position = attack_data.col_ray.body:position(), rotation = attack_data.col_ray.body:rotation(), dir = attack_data.col_ray.ray})
				end
			end

			attack_data.damage = self._health
			result = { type = "death", variant = attack_data.variant }

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot, attack_data.weapon_unit:base():get_name_id())
		end
	else
		attack_data.damage = damage
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")
		--local result_type = "heavy"
		result = { type = result_type, variant = attack_data.variant }

		self:_apply_damage_to_health(damage)
		if (self._health/self._HEALTH_INIT)<=0.3 and not self._immortal and not (self._unit:base()._tweak_table=="deep_boss") and not string.find(self._unit:base()._tweak_table, "phalanx") then
			result.type = "bleedout"
		end
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end

		if attack_data.attacker_unit == managers.player:player_unit() then
			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state

			managers.statistics:killed(data)
			self:_check_damage_achievements(attack_data, head)

			if is_civilian then managers.money:civilian_killed() end
		elseif managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)
			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
		elseif attack_data.attacker_unit:base().sentry_gun then
			if Network:is_server() then
				local server_info = attack_data.weapon_unit:base():server_information()

				if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
					local owner_peer = managers.network:session():peer(server_info.owner_peer_id)

					if owner_peer then
						owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant, data.stats_name)
					end
				else
					data.attacker_state = managers.player:current_state()

					managers.statistics:killed(data)
				end
			end

			local sentry_attack_data = deep_clone(attack_data)
			sentry_attack_data.attacker_unit = attack_data.attacker_unit:base():get_owner()

			if sentry_attack_data.attacker_unit == managers.player:player_unit() then
				self:_check_damage_achievements(sentry_attack_data, head)
			else
				self._unit:network():send("sync_damage_achievements", sentry_attack_data.weapon_unit, sentry_attack_data.attacker_unit, sentry_attack_data.damage, sentry_attack_data.col_ray and sentry_attack_data.col_ray.distance, head)
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)

	local attacker = attack_data.attacker_unit
	if attacker:id() == -1 then attacker = self._unit end

	local weapon_unit = attack_data.weapon_unit
	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local variant = nil
	if result.type == "knock_down" then variant = 1
	elseif result.type == "stagger" then variant = 2 --self._has_been_staggered = true
	elseif result.type == "healed" then variant = 3
	else variant = 0 end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)
	if not is_civilian then managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data) end
	result.attack_data = attack_data
	result.switch = switch

	return result
end



function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable then return end
	if self:chk_immune_to_attacker(attack_data.attacker_unit) then return end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage
	--damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit)

	if self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION then
		--damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_EXPLOSION)
	end

	damage = damage * (self._char_tweak.armor and self._char_tweak.armor.whole_body and 0.1 or 1)

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data, damage)

		if critical_hit then
			damage = crit_damage
		end
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then damage = math.min(damage, self._health - 1) end

	if self._health <= damage then
		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = nil

	if result.type == "death" and self._head_body_name and attack_data.variant ~= "stun" then
		head = attack_data.col_ray.body and self._head_body_key and attack_data.col_ray.body:key() == self._head_body_key
		local body = self._unit:body(self._head_body_name)

		self:_spawn_head_gadget({
			position = body:position(),
			rotation = body:rotation(),
			dir = -attack_data.col_ray.ray
		})
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		self:chk_killshot(attacker_unit, "explosion", false, attack_data.weapon_unit and attack_data.weapon_unit:base():get_name_id())

		if attacker_unit == managers.player:player_unit() then
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if not self._no_blood then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end




function CopDamage:pickup_dropped_bag()
	local dropped_bag = self._unit:movement():was_carrying_bag()

	if dropped_bag and alive(dropped_bag.unit) then
		local distance = mvector3.distance_sq(self._unit:movement():m_pos(), dropped_bag.unit:position())
		local max_distance = math.pow(tweak_data.ai_carry.revive_distance_autopickup, 2)

		if distance <= max_distance then
			dropped_bag.unit:carry_data():link_to(self._unit, false)

			if self._unit:movement().set_carrying_bag then
				self._unit:movement():set_carrying_bag(dropped_bag.unit)
			end
		end
	end
end
