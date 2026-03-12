Hooks:PostHook(UpgradesTweakData, "init", "nqr_UpgradesTweakData:init", function(self)

--ARMOR STATS
	local w = { --armor pieces weights
		0,		--1 no armor
		0.02,	--2 lbv
		0.08,	--3 plate carrier
		0.01,	--4 neck
		0.02,	--5 shoulders
		0.03,	--6 thighs
		0.04,	--7 forearms and lower legs
	}
	local arm_mul = 20
	local mov_mul = 0.5
	local sta_mul = 3
	local sha_mul = 4
    self.values.player.body_armor = {
		armor = {
            0,
			(w[2])*arm_mul,
			(w[3])*arm_mul, (w[3]+w[4])*arm_mul,
			(w[3]+w[4]+w[5])*arm_mul,
			(w[3]+w[4]+w[5]+w[6])*arm_mul,
			(w[3]+w[4]+w[5]+w[6]+w[7])*arm_mul
		},
		movement = {
            1,
			1-(w[2])*mov_mul,
			1-(w[3])*mov_mul,
			1-(w[3]+w[4])*mov_mul,
			1-(w[3]+w[4]+w[5])*mov_mul,
			1-(w[3]+w[4]+w[5]+w[6]+0.02)*mov_mul,
			1-(w[3]+w[4]+w[5]+w[6]+w[7]+0.04)*mov_mul
		},
        stamina = {
            1,
			1-(w[2])*sta_mul,
			1-(w[3])*sta_mul,
			1-(w[3]+w[4])*sta_mul,
			1-(w[3]+w[4]+w[5])*sta_mul,
			1-(w[3]+w[4]+w[5]+w[6])*sta_mul,
			1-(w[3]+w[4]+w[5]+w[6]+w[7])*sta_mul
		},
		concealment = { 0, 4, 15, 19, 23, 29, 37 },
		--dodge = { 0.00, 0.70, 0.65, 0.68, 0.74, 0.80, 0.90 },
		dodge = { 0.00, 0.60, 0.55, 0.58, 0.64, 0.70, 0.80 },
		damage_shake = {
            1,
			1-(w[2])*sha_mul,
			1-(w[3])*sha_mul,
			1-(w[3]+w[4])*sha_mul,
			1-(w[3]+w[4]+w[5])*sha_mul,
			1-(w[3]+w[4]+w[5]+w[6])*sha_mul,
			1-(w[3]+w[4]+w[5]+w[6]+w[7])*sha_mul
		},
	}
--

	self.level_tree[1].upgrades={ "body_armor1", "frag_com", "nin", "concussion", "fir_com", "dada_com" }
	self.level_tree[7].upgrades={ "body_armor2", "moneybundle" }
	table.insert(self.level_tree[1].upgrades, "pocket_ecm_jammer")
	table.insert(self.level_tree[1].upgrades, "smoke_screen_grenade")
	table.insert(self.level_tree[1].upgrades, "chico_injector")
	table.insert(self.level_tree[1].upgrades, "copr_ability")
	table.insert(self.level_tree[1].upgrades, "tag_team")
	table.insert(self.level_tree[1].upgrades, "damage_control")
	table.insert(self.level_tree[70].upgrades, "body_armor6")

	local lvl_swaps = {}

	local lvl_swaps_pistols = {
		   [0] = {
			"peacemaker",
		}, [1] = {
		}, [2] = {
			"model3",
			"push",
		}, [3] = {
		}, [4] = {
		}, [5] = {
			"c96",
		}, [6] = {
			"breech",
		}, [7] = {
			"ppk",
		}, [8] = {
			"shrew",
		}, [9] = {
			"g26",
		}, [10] = {
			"type54",
		}, [11] = {
			"legacy",
		}, [12] = {
			"m1911",
		}, [13] = {
			"colt_1911",
		}, [14] = {
			"sparrow",
		}, [15] = {
			"pl14",
		}, [16] = {
			"holt",
		}, [17] = {
			"p226",
		}, [18] = {
			"hs2000",
		}, [19] = {
			"packrat",
		}, [20] = {
			"chinchilla",
		}, [21] = {
			"b92fs",
		}, [22] = {
			"usp",
		}, [23] = {
			"new_raging_bull",
		}, [24] = {
			"glock_17",
		}, [25] = {
			"g22c",
		}, [26] = {
			"mateba",
		}, [27] = {
			"lemming",
		}, [28] = {
			"korth",
		}, [29] = {
			"maxim9",
		}, [30] = {
			"stech",
		}, [31] = {
			"judge",
		}, [32] = {
			"czech",
		}, [33] = {
			"rsh12",
		}, [34] = {
			"beer",
		}, [35] = {
			"contender",
		}, [36] = {
			"glock_18c",
		}, [37] = {
			"fmg9",
		}, [38] = {
			"deagle",
		}, [39] = {
			"scorpion",
		}, [40] = {
			"pm9",
		}, [41] = {
			"mac10",
		}, [42] = {
			"baka",
		}, [43] = {
			"tec9",
		}, [44] = {
			"sr2",
		}, [45] = {
			"cobray",
		}, [46] = {
			"mp9",
		}, [47] = {
		}, [48] = {
		}, [49] = {
		}, [50] = {
		}, [51] = {
		}, [52] = {
		}, [53] = {
		}, [54] = {
		}, [55] = {
		}, [56] = {
		}, [57] = {
		}, [58] = {
		}, [59] = {
		}, [60] = {
		}, [61] = {
		}, [62] = {
		}, [63] = {
		}, [64] = {
		}, [65] = {
		}, [66] = {
		}, [67] = {
		}, [68] = {
		}, [69] = {
		}, [70] = {
		}, [71] = {
		}, [72] = {
		}, [73] = {
		}, [74] = {
		}, [75] = {
		}, [76] = {
		}, [77] = {
		}, [78] = {
		}, [79] = {
		}, [80] = {
		}, [81] = {
		}, [82] = {
		}, [83] = {
		}, [84] = {
		}, [85] = {
		}, [86] = {
		}, [87] = {
		}, [88] = {
		}, [89] = {
		}, [90] = {
		}, [91] = {
		}, [92] = {
		}, [93] = {
		}, [94] = {
		}, [95] = {
		}, [96] = {
		}, [97] = {
		}, [98] = {
		}, [99] = {
		}, [100] = {
		},
	}
	local lvl_swaps_primaries = {
		[0] = {
			"coach",
		}, [1] = {
		}, [2] = {
			"huntsman",
		}, [3] = {
			"b682",
		}, [4] = {
		}, [5] = {
			"mosin",
		}, [6] = {
		}, [7] = {
		}, [8] = {
		}, [9] = {
		}, [10] = {
			"boot",
		}, [11] = {
		}, [12] = {
			"winchester1874",
		}, [13] = {
		}, [14] = {
			"m37",
		}, [15] = {
		}, [16] = {
			"m1897",
		}, [17] = {
		}, [18] = {
			"serbu",
		}, [19] = {
			"m590",
		}, [20] = {
			"supernova",
		}, [21] = {
			"r870",
		}, [22] = {
			"sbl",
		}, [23] = {
			"scout",
			"ksg",
		}, [24] = {
		}, [25] = {
			"model70",
		}, [26] = {
			"rota",
		}, [27] = {
			"r700",
		}, [28] = {
			"striker",
		}, [29] = {
		}, [30] = {
			"sub2000",
		}, [31] = {
			"erma",
		}, [32] = {
			"spas12",
		}, [33] = {
			"m45",
		}, [34] = {
			"sterling",
		}, [35] = {
			"ultima",
		}, [36] = {
			"uzi",
		}, [37] = {
			"benelli",
		}, [38] = {
			"m1928",
		}, [39] = {
			"ching",
		}, [40] = {
			"schakal",
		}, [41] = {
			"aa12",
		}, [42] = {
			"polymer",
		}, [43] = {
			"coal",
		}, [44] = {
			"vityaz",
		}, [45] = {
			"basset",
			"new_mp5",
		}, [46] = {
			"awp",
			"shepheard",
		}, [47] = {
			"asval",
		}, [48] = {
			"sko12",
		}, [49] = {
			"siltstone",
		}, [50] = {
			"saiga",
		}, [51] = {
			"p90",
		}, [52] = {
			"mp7",
		}, [53] = {
			"shak12",
		}, [54] = {
			"famas",
		}, [55] = {
			"l85a2",
			"msr",
		}, [56] = {
			"akmsu",
		}, [57] = {
			"vhs",
		}, [58] = {
			"flint",
			"r93",
		}, [59] = {
			"ak5",
		}, [60] = {
			"s552",
			"qbu88",
		}, [61] = {
			"hajk",
		}, [62] = {
			"g36",
			"desertfox",
		}, [63] = {
			"akm",
		}, [64] = {
			"ak74",
		}, [65] = {
			"olympic",
		}, [66] = {
			"amcar",
		}, [67] = {
			"m16",
			"new_m4",
		}, [68] = {
			"corgi",
		}, [69] = {
			"victor",
			"aug",
		}, [70] = {
			"komodo",
		}, [71] = {
			"rpk",
		}, [72] = {
			"new_m14",
		}, [73] = {
			"tkb",
		}, [74] = {
			"g3",
		}, [75] = {
			"tecci",
		}, [76] = {
			"fal",
		}, [77] = {
			"galil",
		}, [78] = {
			"mg42",
		}, [79] = {
			"hcar",
		}, [80] = {
			"contraband",
		}, [81] = {
			"tti",
		}, [82] = {
			"scar",
		}, [83] = {
			"hk51b",
		}, [84] = {
			"system",
		}, [85] = {
			"par",
		}, [86] = {
			"gre_m79",
		}, [87] = {
			"m60",
		}, [88] = {
			"wa2000",
		}, [89] = {
			"rpg7",
		}, [90] = {
			"kacchainsaw",
		}, [91] = {
			"hk21",
		}, [92] = {
			"m249",
		}, [93] = {
			"flamethrower_mk2",
		}, [94] = {
			"groza",
		}, [95] = {
			"china",
			"m95",
		}, [96] = {
			"ms3gl",
		}, [97] = {
			"slap",
		}, [98] = {
			"m32",
		}, [99] = {
			"ray",
		}, [100] = {
			"m134",
			"shuno",
			"arbiter",
			"akm_gold",
		},
	}
	lvl_swaps = deep_clone(lvl_swaps_pistols)
	for i, k in pairs(lvl_swaps_primaries) do
		for u, j in pairs(k) do table.insert(lvl_swaps[i], j) end
	end



	for i, k in pairs(lvl_swaps) do
		for u, j in pairs(k) do
			for y, h in pairs(self.level_tree) do
				table.delete(h.upgrades, j)
				if aki_id_lookup[j] then table.delete(h.upgrades, aki_id_lookup[j]) end
			end

			self.level_tree[i] = self.level_tree[i] or {}
			self.level_tree[i].upgrades = self.level_tree[i].upgrades or {}
			table.insert(self.level_tree[i].upgrades, j)

			if aki_id_lookup[j] then table.insert(self.level_tree[i].upgrades, aki_id_lookup[j]) end
		end
	end
	table.delete(self.level_tree[0].upgrades, "peacemaker")
	table.delete(self.level_tree[0].upgrades, "coach")

	--self.definitions.wpn_prj_jav = nil
	table.delete(self.level_tree[41].upgrades, "wpn_prj_jav")

	self.definitions.amcar.free = nil
	self.definitions.coach.free = true
	self.definitions.glock_17.free = nil
	self.definitions.peacemaker.free = true

    self.definitions.model70.dlc = nil



	for i, k in pairs(self.level_tree) do
		for u, j in pairs(k.upgrades or {}) do
			if not self.definitions[j] then table.delete(self.level_tree[i].upgrades, j) end
		end
	end



	self.values.player.crime_net_deal = {
		1,
		1
	}

	self.weapon_cost_multiplier = {
		akimbo = 2
	}

end)