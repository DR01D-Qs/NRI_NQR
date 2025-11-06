--managers.mission._fading_debug_output:script().log(tostring(tweak_data.weapon.factory.parts["wpn_fps_upg_o_ak_scopemount"].override), Color.white)
--Utils.PrintTable(tweak_data.weapon.factory.parts["wpn_fps_o_pos_fg"].override, 6)
--Utils.PrintTable(tweak_data.weapon.factory.parts["wpn_fps_ak_extra_ris"].forbids, 6)
--Utils.PrintTable(tweak_data.weapon.factory.parts.wpn_fps_upg_o_northtac_reddot.visibility, 6)
Utils.PrintTable(tweak_data.weapon.factory.parts.wpn_fps_upg_g36_fg_long.override, 6)
--Utils.PrintTable(tweak_data.weapon.factory["wpn_fps_ass_74"].override, 6)
--Utils.PrintTable(tweak_data.weapon.factory.parts["wpn_fps_upg_o_45rds"].override, 6)
--log(tweak_data.weapon["sbl"].desc_id)

--tweak_data.weapon.debug(tostring("csc"))

--Hooks:PostHook( WeaponTweakData, "init", "nqr_weapontweakdata", function(self)

--managers.mission._fading_debug_output:script().log(tostring(XXXXX),  Color.white)

--function a
--[[local name = "mods/test2out.lua"
local category = ""
file = io.open(name, "w")
io.output(file)
for i, k in pairs(tweak_data.weapon.factory.parts) do
    if not string.find(i, "charm") and not string.find(i, "bonus") then
    io.write(tostring("self.parts.")..tostring(i)..tostring(".stats = {}"))
    io.write("\n")
    end
end
io.write("\n")
for i, k in pairs(tweak_data.weapon.factory.parts) do
    if not string.find(i, "charm") and not string.find(i, "bonus") then
    io.write(tostring("self.parts.")..tostring(i)..tostring(".stats.concealment = 1"))
    io.write("\n")
    io.write(tostring("self.parts.")..tostring(i)..tostring(".stats.weight = 1"))
    io.write("\n")
    end
end
io.close(file)]]
--end

--[[BUFFER

managers.player:player_unit():movement():current_state():_interupt_action_running(t)
managers.player:player_unit():movement():current_state():_interupt_action_reload(t)
managers.player:player_unit():movement():current_state():_play_equip_animation()

._shooting

function HuskPlayerMovement:sync_stop_auto_fire_sound(sub_id)
	sub_id = self._arm_animator:enabled() and sub_id + 1 or 0
	self._firing = self._firing or 0
	self._firing = bit.band(self._firing, bit.bnot(sub_id))

	if sub_id > 0 then
		local equipped_weapon = self._unit:inventory():equipped_unit()

		equipped_weapon:base():stop_autofire(sub_id)

		if self._firing == 0 then
			self._auto_firing = 0
			local stance = self._stance

			if stance.transition then
				stance.transition.delayed_shot = nil
			end
		end

		return
	end

	local equipped_weapon = self._unit:inventory():equipped_unit()

	if equipped_weapon and equipped_weapon:base().shooting and equipped_weapon:base():shooting() then
		equipped_weapon:base():stop_autofire()
	end

	if self.clean_states[self._state] then
		return
	end

	if self._auto_firing > 0 then
		self._auto_firing = 0
		local stance = self._stance

		if stance.transition then
			stance.transition.delayed_shot = nil
		end
	end
end



function PlayerStandard:_start_action_unequip_weapon(t, data)
	local speed_multiplier = self:_get_swap_speed_multiplier()

	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier)

	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	self._change_weapon_data = data
	self._unequip_weapon_expire_t = t + (tweak_data.timers.unequip or 0.5) / speed_multiplier

	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local result = self._ext_camera:play_redirect(self:get_animation("unequip"), speed_multiplier)

	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self._ext_network:send("switch_weapon", speed_multiplier, 1)
end



self._shaker:play(effect, amplitude or 1, frequency or 1, offset or 0)



local t = managers.player:player_timer():time()



--STATS
    --ASSAULT RIFLE
        --AMCAR
        self.amcar.CLIP_AMMO_MAX = 30
        --M16
        self.m16.CLIP_AMMO_MAX = 30
        --PARA
        self.olympic.CLIP_AMMO_MAX = 20
        --FAMAS
        self.famas.CLIP_AMMO_MAX = 25
        --AK12
        self.flint.CLIP_AMMO_MAX = 30
        --RPK
        self.rpk.CLIP_AMMO_MAX = 75
        self.rpk.CAN_TOGGLE_FIREMODE = true
        --ASVAL
        self.asval.CLIP_AMMO_MAX = 20
    --DMR
        --SCAR
        self.scar.nqr_stat1 = 308
        self.scar.CLIP_AMMO_MAX = 20
        self.scar.AMMO_MAX = 100
        self.scar.fire_mode_data.fire_rate = 60 / 600
        --M14
        self.new_m14.CLIP_AMMO_MAX = 20
        --MARLIN
        self.sbl.CLIP_AMMO_MAX = 6
        --GALIL
        self.galil.CLIP_AMMO_MAX = 25
        --ASH12
        self.shak12.CLIP_AMMO_MAX = 20
        --G3
        self.g3.CLIP_AMMO_MAX = 20
    --SMG
        --UMP
        self.schakal.CLIP_AMMO_MAX = 25
        --MP40
        self.erma.CLIP_AMMO_MAX = 32
        --SR2
        self.sr2.CLIP_AMMO_MAX = 30
        --UZI
        self.uzi.CLIP_AMMO_MAX = 32
        --VECTOR
        self.polymer.CLIP_AMMO_MAX = 25
        --MAC11
        self.mac10.CLIP_AMMO_MAX = 16
        --FMG
        self.fmg9.CLIP_AMMO_MAX = 27
        --MP9
        self.mp9.CLIP_AMMO_MAX = 15
        --TEC9
        self.tec9.CLIP_AMMO_MAX = 32
        --SWEDISH
        self.m45.CLIP_AMMO_MAX = 36
    --LMG
        --M240
        self.par.CLIP_AMMO_MAX = 100
        --M60
        self.m60.CLIP_AMMO_MAX = 100
        --MG42
        self.mg42.CLIP_AMMO_MAX = 50
    --SNIPER RIFLE
        --R93
        self.r93.CLIP_AMMO_MAX = 5
        --WA2000
        self.wa2000.CLIP_AMMO_MAX = 6
        --M95
        self.m95.shake = { fire_multiplier = 5, fire_steelsight_multiplier = -5 }
    --SHOTGUN
        --REM870
        self.r870.CLIP_AMMO_MAX = 7
        --M590
        self.m590.CLIP_AMMO_MAX = 6
        --LOCO
        self.serbu.CLIP_AMMO_MAX = 3
        --TRENCH
        self.m1897.CLIP_AMMO_MAX = 5
        --ITACA
        self.m37.CLIP_AMMO_MAX = 5
        --1887
        self.boot.CLIP_AMMO_MAX = 5
        --SAIGA
        self.saiga.CLIP_AMMO_MAX = 5
        self.saiga.CAN_TOGGLE_FIREMODE = false
        --GRIMM
        self.basset.CLIP_AMMO_MAX = 5
        self.basset.CAN_TOGGLE_FIREMODE = false
        --SKO12
        self.sko12.CLIP_AMMO_MAX = 24
        self.sko12.CAN_TOGGLE_FIREMODE = false
    --PISTOL
        --G17
        self.glock_17.CLIP_AMMO_MAX = 19
        --USP
        self.usp.CLIP_AMMO_MAX = 12
        --PPK
        self.ppk.CLIP_AMMO_MAX = 7
        --P226
        self.p226.CLIP_AMMO_MAX = 13
        --1911
        self.colt_1911.CLIP_AMMO_MAX = 8
        --M9
        self.b92fs.CLIP_AMMO_MAX = 15
        --CHUNKY
        self.m1911.CLIP_AMMO_MAX = 7
        --LEBEDEV
        self.pl14.CLIP_AMMO_MAX = 15
        --JERICHO
        self.sparrow.CLIP_AMMO_MAX = 15
        --TOKAREV
        self.type54.CLIP_AMMO_MAX = 8
        --5-7
        self.lemming.CLIP_AMMO_MAX = 20
        --COLT DEFENDER
        self.shrew.CLIP_AMMO_MAX = 8
        --XDM
        self.hs2000.CLIP_AMMO_MAX = 16
        --G18
        self.glock_18c.CLIP_AMMO_MAX = 19
        --CZ75
        self.czech.CLIP_AMMO_MAX = 21
        --DEAGLE
        self.deagle.CLIP_AMMO_MAX = 7
        --M93R
        self.beer.FIRE_MODE = "burst"
        self.beer.BURST_COUNT = 3
        self.beer.fire_mode_data = { fire_rate = 0.0545, burst_cooldown = 0.2 }
        self.beer.burst = { fire_rate = 1 }
        self.beer.CAN_TOGGLE_FIREMODE = false



]]
