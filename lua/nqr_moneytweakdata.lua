MoneyTweakData = MoneyTweakData or class()

function MoneyTweakData._create_value_table(min, max, table_size, round, curve)
	local t = {}

	for i = 1, table_size do
		local v = math.lerp(min, max, math.pow((i - 1) / (table_size - 1), curve and curve or 1))

		if v > 999 then
			v = v * 0.001

			if round then
				v = math.ceil(v) or v
			end

			v = v * 1000
		elseif v > 99 then
			v = v * 0.01

			if round then
				v = math.ceil(v) or v
			end

			v = v * 100
		elseif v > 9 then
			v = v * 0.1

			if round then
				v = math.ceil(v) or v
			end

			v = v * 10
		elseif round then
			v = math.ceil(v) or v
		end

        --[[if v>1000 then
            --log(v)
            v = v * 0.001
            v = math.floor(v)
            v = v * 1000
        end]]

		table.insert(t, v)
	end

	return t
end

Hooks:PostHook(MoneyTweakData, "init", "nqr_MoneyTweakData:init", function(self)

    local smallest_cashout = (self.stage_completion[1] + self.job_completion[1]) * self.offshore_rate

	local biggest_weapon_cost = math.round(self.biggest_cashout * 12.5)
	local smallest_weapon_cost = math.round(smallest_cashout * 2)
    self.weapon_cost = self._create_value_table(smallest_weapon_cost, biggest_weapon_cost, 100, true, 2.3)

    local biggest_weapon_mod_cost = math.round(self.biggest_cashout * 10)
	local smallest_weapon_mod_cost = math.round(smallest_cashout * 2)
	self.modify_weapon_cost = self._create_value_table(smallest_weapon_mod_cost, biggest_weapon_mod_cost, 100, true, 1.5)

    self.global_value_multipliers.gage_pack_jobs = 1
    self.global_value_multipliers = {}

	self.stage_failed_multiplier = 0
	self.bag_values = {
		default = 100,
		money = 1500,
		gold = 2875,
		diamonds = 1000,
		coke = 2000,
		coke_pure = 3000,
		meth = 13000,
		meth_half = 6500,
		weapon = 3000,
		weapons = 3000,
		painting = 3000,
		samurai_suit = 5000,
		artifact_statue = 5000,
		mus_artifact_bag = 1000,
		circuit = 1000,
		shells = 2100,
		turret = 10000,
		sandwich = 10000,
		cro_loot = 10000,
		hope_diamond = 30000,
		evidence_bag = 3000,
		vehicle_falcogini = 4000,
		warhead = 4600,
		unknown = 5000,
		safe = 4600,
		prototype = 10000,
		faberge_egg = 3000,
		treasure = 3200,
		counterfeit_money = 1100,
		box_unknown = 10000,
		black_tablet = 10000,
		masterpiece_painting = 10000,
		master_server = 10000,
		lost_artifact = 10000,
		present = 2049,
		mad_master_server_value_1 = 5000,
		mad_master_server_value_2 = 10000,
		mad_master_server_value_3 = 15000,
		mad_master_server_value_4 = 20000,
		weapon_glock = 2000,
		weapon_scar = 2000,
		drk_bomb_part = 9000,
		drone_control_helmet = 18000,
		toothbrush = 18000,
		cloaker_gold = 2000,
		cloaker_money = 1750,
		cloaker_cocaine = 1500,
		diamond_necklace = 2875,
		vr_headset = 2875,
		women_shoes = 2875,
		expensive_vine = 2875,
		ordinary_wine = 2875,
		robot_toy = 2875,
		rubies = 1500,
		red_diamond = 10000,
		old_wine = 2000
	}
	self.bag_values.garden_gnome = 9.99
	self.bag_values.ranc_weapon = 3000
	self.bag_values.turret_part = 6000
	--for i, k in pairs(self.bag_values) do self.bag_values[i] = k*10 end
	--self.bag_values.money = 500000
	--self.bag_values.gold = 3000000
	--self.bag_value_multiplier = { 0.25, 0.5, 0.75, 1, 0, 0, 0, }
	self.small_loot_difficulty_multiplier = { 0, 0, 0, 0, 0, 0, 0, } --deep_clone(self.difficulty_multiplier)
	self.difficulty_multiplier_payout = { 1, 1.1, 1.15, 1.2, 1, 1, 1, }
	self.alive_humans_multiplier = { 1, 1, 1, 1 }
	self.alive_humans_multiplier[0] = 1
	self.killing_civilian_deduction = self._create_value_table(2000, 50000, 10, true, 2)

	self.small_loot.money_bundle = 10000
	self.small_loot.money_bundle_value = 9999
	self.small_loot.ring_band = 1954
	self.small_loot.diamondheist_vault_bust = 900
	self.small_loot.diamondheist_vault_diamond = 1150
	self.small_loot.diamondheist_big_diamond = 1150
	self.small_loot.mus_small_artifact = 700
	self.small_loot.value_gold = 30000
	self.small_loot.gen_atm = 50000
	self.small_loot.special_deposit_box = 3500
	self.small_loot.slot_machine_payout = 10000
	self.small_loot.vault_loot_chest = 5700
	self.small_loot.vault_loot_diamond_chest = 6100
	self.small_loot.vault_loot_banknotes = 5000
	self.small_loot.vault_loot_silver = 2000
	self.small_loot.vault_loot_diamond_collection = 6500
	self.small_loot.vault_loot_trophy = 6900
	self.small_loot.money_wrap_single_bundle_vscaled = 3850
	self.small_loot.spawn_bucket_of_money = 20000
	self.small_loot.vault_loot_gold = 30000
	self.small_loot.vault_loot_cash = 30000
	self.small_loot.vault_loot_coins = 8000
	self.small_loot.vault_loot_ring = 3000
	self.small_loot.vault_loot_jewels = 6000
	self.small_loot.vault_loot_macka = 1
	self.small_loot.federali_medal = 769

end)
