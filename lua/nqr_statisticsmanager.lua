require("lib/utils/accelbyte/Telemetry")
require("lib/units/enemies/cop/CopDamage")

StatisticsManager = StatisticsManager or class()
StatisticsManager.special_unit_ids = {
	"shield",
	"spooc",
	"shadow_spooc",
	"tank",
	"tank_hw",
	"tank_green",
	"tank_black",
	"tank_skull",
	"tank_medic",
	"tank_mini",
	"taser",
	"medic",
	"sniper",
	"phalanx_minion",
	"phalanx_vip",
	"swat_turret",
	"biker_boss",
	"chavez_boss",
	"mobster_boss",
	"hector_boss",
	"hector_boss_no_armor",
	"drug_lord_boss",
	"drug_lord_boss_stealth",
	"ranchmanager",
	"marshal_marksman",
	"marshal_shield",
	"marshal_shield_break",
	"triad_boss",
	"triad_boss_no_armor",
	"deep_boss",
	"snowman_boss",
	"piggydozer"
}
StatisticsManager.JOB_STATS_VERSION = 2



function StatisticsManager:publish_to_steam(session, success, completion) end
