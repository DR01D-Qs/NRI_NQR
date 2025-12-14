Hooks:PostHook( PlayerTweakData, "init", "nqr_playertweakdata", function(self)

    self.damage.HEALTH_INIT = 16

--MASKING TIME
    self.put_on_mask_time = 0.5

--STAMINA STATS
    self.movement_state.stamina.STAMINA_INIT = 60
    self.movement_state.stamina.STAMINA_REGEN_RATE = 1
    self.movement_state.stamina.STAMINA_DRAIN_RATE = 1
    self.movement_state.stamina.MIN_STAMINA_THRESHOLD = 4
    self.movement_state.stamina.JUMP_STAMINA_DRAIN = 3
    self.movement_state.stamina.REGENERATE_TIME = 2

--MOVE SPEED
    self.movement_state.standard.movement.speed.STANDARD_MAX = 240
    self.movement_state.standard.movement.speed.RUNNING_MAX = 600
    self.movement_state.standard.movement.speed.CROUCHING_MAX = 120
    self.movement_state.standard.movement.speed.INAIR_MAX = 160
    self.movement_state.standard.movement.speed.CLIMBING_MAX = 160

--AUTOHIT DISABLE
    self.suppression.autohit_chance_mul = 0

    self.movement_state.interaction_delay = 0.5

    self.max_nr_following_hostages = 5

--LYING STANCE
    self.stances.default.lying = { head = {} }
    self.stances.default.lying.head.translation = Vector3(0, 0, 40)
    self.stances.default.lying.head.rotation = Rotation()



	self.damage.respawn_time_penalty = 15
	self.damage.base_respawn_time_penalty = 60

    self.gravity = -(982*2)

end)

function PlayerTweakData:_set_normal()
	self.damage.automatic_respawn_time = 240
end

function PlayerTweakData:_set_hard()
	self.damage.automatic_respawn_time = 480
end

Hooks:PostHook( PlayerTweakData, "_init_new_stances", "nqr_playertweakdata:_init_new_stances", function(self)

	self.stances.m16.steelsight.shoulders.translation = Vector3(-10.748, -10.996, 1.329)
	self.stances.m16.standard.shoulders.translation = Vector3(-5.248, -8.996, -1.217)
	self.stances.m16.standard.shoulders.rotation = Rotation(-0.108053, 0.0859222, -3.628)

	self.stances.ksg.standard.shoulders.translation = Vector3(-1.346, -20.469, -2.311)
	self.stances.ksg.standard.shoulders.rotation = Rotation(-4.34929e-005, -5.76868e-005, -3.15)
	self.stances.ksg.steelsight.shoulders.translation = Vector3(-7.34565, -19.469, 0.689)
	self.stances.ksg.crouched.shoulders.translation = Vector3(-1.346, -23.469, -1.311)
	self.stances.ksg.crouched.shoulders.rotation = Rotation(-4.34929e-005, -5.76868e-005, -1.15)

	self.stances.cobray.steelsight.shoulders.translation = Vector3(-9.27771, -8.45, 5.83447)
	self.stances.cobray.standard.shoulders.translation = Vector3(0.72229, -2.44963, 1.834)

	self.stances.basset.standard.shoulders.translation = Vector3(-5.841, -7.028, 0.169)
	self.stances.basset.standard.shoulders.rotation = Rotation(-4.34127e-005, 0.0010354, -3)
	self.stances.basset.steelsight.shoulders.translation = Vector3(-11.8411, -6.028, 2.16879)
	self.stances.basset.crouched.shoulders.translation = Vector3(-4.841, -10.028, 0.169)
	self.stances.basset.crouched.shoulders.rotation = Rotation(-4.34061e-005, 0.00103616, -1)

	self.stances.boot.standard.shoulders.translation = Vector3(-3.335, -1.555, 2.568)
	self.stances.boot.standard.shoulders.rotation = Rotation(-0.000912031, -0.000168076, -3)
	self.stances.boot.steelsight.shoulders.translation = Vector3(-9.33527, -5.555, 4.56761)
	self.stances.boot.crouched.shoulders.translation = Vector3(-3.335, -4.555, 2.568)
	self.stances.boot.crouched.shoulders.rotation = Rotation(-0.000912031, -0.000168076, -1)

	self.stances.baka.standard.shoulders.translation = Vector3(-2.33502, 2.08721, 1.787)
	self.stances.baka.steelsight.shoulders.translation = Vector3(-8.681, -19.646, 4.787)
	self.stances.baka.steelsight.shoulders.rotation = Rotation(-0.115, -0.012, -0.633)
	self.stances.baka.crouched.shoulders.translation = Vector3(-7.215, -4.913, 3.017)

	self.stances.fal.standard.shoulders.translation = Vector3(-5.743, -7.101, 1.21)
	self.stances.fal.standard.shoulders.rotation = Rotation(-0.107605, 0.0861107, -3.628)
	self.stances.fal.crouched.shoulders.translation = Vector3(-5.743, -10.101, 1.21)
	self.stances.fal.crouched.shoulders.rotation = Rotation(-0.107605, 0.0861107, -1.628)
	self.stances.fal.steelsight.shoulders.translation = Vector3(-10.7432, -5.101, 4.20962)

	self.stances.tkb.standard.shoulders.translation = Vector3(-0.544945, -1.39307, 0.333)
	self.stances.tkb.standard.shoulders.rotation = Rotation(-4.7998e-005, -0.00548041, 0.001)
	self.stances.tkb.steelsight.shoulders.translation = Vector3(-5.88365, 4.565, 3.2184)

	self.stances.r700.standard.shoulders.translation = Vector3(-1.966, 0.925, -0.237)
	self.stances.r700.standard.shoulders.rotation = Rotation(3.68458e-005, -1.02456e-005, -3.001)
	self.stances.r700.steelsight.shoulders.translation = Vector3(-7.96552, 1.925, 3.76269)
	self.stances.r700.crouched.shoulders.translation = Vector3(-1.966, -2.075, 0.763)
	self.stances.r700.crouched.shoulders.rotation = Rotation(3.68458e-005, -1.02456e-005, -1.001)

	self.stances.contraband.steelsight.shoulders.translation = Vector3(-9.369, -2.853, 1.835)
	self.stances.contraband.steelsight.shoulders.rotation = Rotation(-3.1268e-010, 5.82412e-019, -0)
	self.stances.contraband.standard.shoulders.translation = Vector3(-2.869, -1.853, -1.565)
	self.stances.contraband.standard.shoulders.rotation = Rotation(-6.9945e-005, -0.000377475, -0)

	self.stances.famas.standard.shoulders.translation = Vector3(-4.11787, -6.41738, -1.452)
	self.stances.famas.steelsight.shoulders.translation = Vector3(-14.1179, -8.417, 1.54789)
	self.stances.famas.steelsight.shoulders.rotation = Rotation(-2.58501, 0.113, -0.624)

	self.stances.akm_gold.standard.shoulders.translation = Vector3(-2.46229, -7.47765, 1.805)

	self.stances.m1928.steelsight.shoulders.translation = Vector3(-8.454, 0.375, 3.99501)
	self.stances.m1928.steelsight.shoulders.rotation = Rotation(-4.14635e-005, -0.000589106, -0)
	self.stances.m1928.standard.shoulders.translation = Vector3(-0.453511, -5.62475, -3.005)
	self.stances.m1928.standard.shoulders.rotation = Rotation(-4.14634e-005, -0.000589105, -0)

	self.stances.x_shrew.standard.shoulders.translation = Vector3(-0.46375, -16.943, -2.751)
	self.stances.x_shrew.steelsight.shoulders.translation = Vector3(0, -8.943, -1.751)
	self.stances.x_shrew.steelsight.shoulders.rotation = Rotation(0.39, -0.00124487, 0.000512833)

	self.stances.par.steelsight.shoulders.translation = Vector3(-10.05, 9.631, 3.85)
	self.stances.par.steelsight.shoulders.rotation = Rotation(-0.108, 0.0860001, -0.628)
	self.stances.par.standard.shoulders.translation = Vector3(-0.690504, 0.552, -6.32)

	self.stances.g36.standard.shoulders.translation = Vector3(-1.04496, -9.85853, -1.102)
	self.stances.g36.steelsight.shoulders.translation = Vector3(-10.545, -11.859, 1.14793)

	self.stances.mp9.standard.shoulders.translation = Vector3(-5.753, -10.201, 4.189)
	self.stances.mp9.standard.shoulders.rotation = Rotation(-0.107602, 0.0861498, -3.628)
	self.stances.mp9.steelsight.shoulders.translation = Vector3(-10.7531, -11.201, 7.18905)
	self.stances.mp9.crouched.shoulders.translation = Vector3(-5.753, -13.201, 5.189)
	self.stances.mp9.crouched.shoulders.rotation = Rotation(-0.107602, 0.0861498, -1.628)

	self.stances.x_cobray.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_cobray.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_cobray.steelsight.shoulders.translation = Vector3(0, -8.943, -2.751)
	self.stances.x_cobray.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.ak74.crouched.shoulders.translation = Vector3(-5.745, -11.371, 3.81)
	self.stances.ak74.crouched.shoulders.rotation = Rotation(-0.107628, 0.0867136, -1.628)
	self.stances.ak74.standard.shoulders.translation = Vector3(-5.745, -8.371, 1.81)
	self.stances.ak74.standard.shoulders.rotation = Rotation(-0.107628, 0.0867136, -3.628)
	self.stances.ak74.steelsight.shoulders.translation = Vector3(-10.7447, -10.3707, 4.81)

	self.stances.model70.standard.shoulders.translation = Vector3(2.03473, 2.92615, 0.922)
	self.stances.model70.steelsight.shoulders.translation = Vector3(-7.96527, 3.926, 3.92244)

	self.stances.supernova.standard.shoulders.translation = Vector3(-2.516, 4.543, 1.64)
	self.stances.supernova.standard.shoulders.rotation = Rotation(-0.37, 0.1, -4)
	self.stances.supernova.crouched.shoulders.translation = Vector3(-2.516, 1.543, 2.44)
	self.stances.supernova.crouched.shoulders.rotation = Rotation(0, 0, -2)
	self.stances.supernova.steelsight.shoulders.translation = Vector3(-8.472, 4.843, 4.94)
	self.stances.supernova.steelsight.shoulders.rotation = Rotation(-0.308, 0.689015, 1.32151e-007)

	self.stances.x_beer.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_beer.standard.shoulders.rotation = Rotation(0.39, -1.26812e-006, 7.7526e-014)
	self.stances.x_beer.steelsight.shoulders.translation = Vector3(0, -8.943, -2.3)
	self.stances.x_beer.steelsight.shoulders.rotation = Rotation(0.39, -1.26812e-006, 7.7526e-014)

	self.stances.x_holt.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_holt.standard.shoulders.rotation = Rotation(0.39, -0.255, 1.70911e-006)
	self.stances.x_holt.steelsight.shoulders.translation = Vector3(0, -8.943, -0.751)
	self.stances.x_holt.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.m1911.standard.shoulders.translation = Vector3(-4.572, -15.277, 0.393)
	self.stances.m1911.standard.shoulders.rotation = Rotation(-0.107874, 0.68962, -3.628)
	self.stances.m1911.steelsight.shoulders.translation = Vector3(-8.57236, -21.277, 3.39273)
	self.stances.m1911.crouched.shoulders.translation = Vector3(-4.572, -18.277, 1.393)
	self.stances.m1911.crouched.shoulders.rotation = Rotation(-0.107875, 0.689621, -1.628)

	self.stances.b92fs.standard.shoulders.translation = Vector3(-4.617, -14.983, 0.31)
	self.stances.b92fs.standard.shoulders.rotation = Rotation(-0.113, 1.189, -3.629)
	self.stances.b92fs.steelsight.shoulders.translation = Vector3(-8.61747, -21.983, 3.30954)
	self.stances.b92fs.crouched.shoulders.translation = Vector3(-4.617, -17.983, 1.31)
	self.stances.b92fs.crouched.shoulders.rotation = Rotation(-0.113, 1.189, -1.629)

	self.stances.x_1911.steelsight.shoulders.translation = Vector3(0, -8.943, -2.251)
	self.stances.x_1911.steelsight.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)
	self.stances.x_1911.standard.shoulders.translation = Vector3(0, -16.943, -2.75089)
	self.stances.x_1911.standard.shoulders.rotation = Rotation(0.39, -0.254866, 1.00052e-008)

	self.stances.flint.standard.shoulders.translation = Vector3(-0.247, 3.30434, 2.382)
	self.stances.flint.steelsight.shoulders.translation = Vector3(-10.247, -4.696, 4.432)

	self.stances.m37.steelsight.shoulders.translation = Vector3(-9.27649, 8.554, 5.668)
	self.stances.m37.steelsight.shoulders.rotation = Rotation(-4.2843e-005, 0.199, 0.000336079)
	self.stances.m37.standard.shoulders.translation = Vector3(-1.77649, 2.60637, 3.038)

	self.stances.vityaz.standard.shoulders.translation = Vector3(-4.765, -5.956, 0.966)
	self.stances.vityaz.standard.shoulders.rotation = Rotation(-0.107515, 0.0858296, -3.628)
	self.stances.vityaz.steelsight.shoulders.translation = Vector3(-10.7653, -7.956, 2.966)
	self.stances.vityaz.crouched.shoulders.translation = Vector3(-4.765, -8.956, -0.034)
	self.stances.vityaz.crouched.shoulders.rotation = Rotation(-0.107515, 0.0858296, -1.628)

	self.stances.ultima.standard.shoulders.translation = Vector3(-3.276, 6.554, 1.368)
	self.stances.ultima.standard.shoulders.rotation = Rotation(-4.57742e-005, -0.00055666, -3)
	self.stances.ultima.steelsight.shoulders.translation = Vector3(-9.27649, 4.554, 3.36842)
	self.stances.ultima.crouched.shoulders.translation = Vector3(-3.276, 3.554, 1.368)
	self.stances.ultima.crouched.shoulders.rotation = Rotation(-4.57742e-005, -0.00055666, -1)

	self.stances.x_mac10.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_mac10.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_mac10.steelsight.shoulders.translation = Vector3(0, -8.943, -2.751)
	self.stances.x_mac10.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.deagle.standard.shoulders.translation = Vector3(-4.592, -12.667, -0.956)
	self.stances.deagle.standard.shoulders.rotation = Rotation(-0.113, 1.189, -3.62701)
	self.stances.deagle.steelsight.shoulders.translation = Vector3(-8.59212, -20.667, 2.04389)
	self.stances.deagle.crouched.shoulders.translation = Vector3(-4.592, -15.667, 1.044)
	self.stances.deagle.crouched.shoulders.rotation = Rotation(-0.113, 1.189, -1.627)

	self.stances.stech.steelsight.shoulders.translation = Vector3(-8.57222, -21.573, 3.40415)

	self.stances.arbiter.steelsight.shoulders.translation = Vector3(-12.6008, 4.071, -1.925)
	self.stances.arbiter.standard.shoulders.translation = Vector3(-1.60076, 8.07115, -3.425)

	self.stances.hk51b.standard.shoulders.translation = Vector3(-5.57, -4.499, -0.126)
	self.stances.hk51b.standard.shoulders.rotation = Rotation(0.399967, 0.794521, -4.999)
	self.stances.hk51b.steelsight.shoulders.translation = Vector3(-10.705, -6.435, 3.164)
	self.stances.hk51b.steelsight.shoulders.rotation = Rotation(-0.100029, 0.99452, 0.001)
	self.stances.hk51b.crouched.shoulders.translation = Vector3(-5.57, -7.499, 0.874)
	self.stances.hk51b.crouched.shoulders.rotation = Rotation(0.399967, 0.794521, -2.999)

	self.stances.x_2006m.steelsight.shoulders.translation = Vector3(0, -8.943, -2.341)
	self.stances.x_2006m.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_2006m.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_2006m.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.x_p226.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_p226.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_p226.steelsight.shoulders.translation = Vector3(0, -8.943, -1.341)
	self.stances.x_p226.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.vhs.standard.shoulders.translation = Vector3(-0.430178, 2.78362, -1.21)
	self.stances.vhs.steelsight.shoulders.translation = Vector3(-9.43018, 2.784, 1.79038)

	self.stances.fmg9.standard.shoulders.translation = Vector3(-5.753, 2.799, -0.811)
	self.stances.fmg9.standard.shoulders.rotation = Rotation(-0.107602, 0.0861498, -3.628)
	self.stances.fmg9.steelsight.shoulders.translation = Vector3(-11.7531, 0.799, 1.68905)
	self.stances.fmg9.crouched.shoulders.translation = Vector3(-5.753, -0.201, 0.689)
	self.stances.fmg9.crouched.shoulders.rotation = Rotation(-0.108827, 0.101296, -1.628)

	self.stances.victor.standard.shoulders.translation = Vector3(-3.869, -2.853, -1.065)
	self.stances.victor.standard.shoulders.rotation = Rotation(0.000713286, -0.000348389, -3)
	self.stances.victor.steelsight.shoulders.translation = Vector3(-10.745, -11.005, 1.332)
	self.stances.victor.steelsight.shoulders.rotation = Rotation(-0.108001, 0.0860015, -0.629)
	self.stances.victor.crouched.shoulders.translation = Vector3(-3.869, -5.853, -0.065)
	self.stances.victor.crouched.shoulders.rotation = Rotation(0.000713286, -0.000348389, -1)

	self.stances.x_judge.steelsight.shoulders.translation = Vector3(0, -8.943, -3.341)
	self.stances.x_judge.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_judge.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_judge.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.judge.standard.shoulders.translation = Vector3(-2.614, -12.886, -1.172)
	self.stances.judge.standard.shoulders.rotation = Rotation(-0.106842, 0.690638, -3.617)
	self.stances.judge.steelsight.shoulders.translation = Vector3(-8.61421, -20.886, 1.82785)
	self.stances.judge.crouched.shoulders.translation = Vector3(-2.614, -15.886, -0.172)
	self.stances.judge.crouched.shoulders.rotation = Rotation(-0.106842, 0.690637, -1.617)

	self.stances.ecp.standard.shoulders.translation = Vector3(0.511894, -1.14883, -1.58)

	self.stances.rpg7.steelsight.shoulders.translation = Vector3(-9.60746, -4.101, -1.055)

	self.stances.p226.standard.shoulders.translation = Vector3(-4.572, -15.166, 1.022)
	self.stances.p226.standard.shoulders.rotation = Rotation(-0.107658, 0.68955, -3.629)
	self.stances.p226.steelsight.shoulders.translation = Vector3(-8.57245, -22.166, 4.02176)
	self.stances.p226.crouched.shoulders.translation = Vector3(-4.572, -18.166, 2.022)
	self.stances.p226.crouched.shoulders.rotation = Rotation(-0.107658, 0.68955, -1.629)

	self.stances.chinchilla.standard.shoulders.translation = Vector3(-4.54, -13.696, -0.698)
	self.stances.chinchilla.standard.shoulders.rotation = Rotation(-0.10732, 0.689384, -3.607)
	self.stances.chinchilla.steelsight.shoulders.translation = Vector3(-8.53958, -21.696, 2.30238)
	self.stances.chinchilla.crouched.shoulders.translation = Vector3(-4.54, -16.696, -0.698)
	self.stances.chinchilla.crouched.shoulders.rotation = Rotation(-0.10732, 0.689384, -1.607)

	self.stances.desertfox.crouched.shoulders.translation = Vector3(-1.392, -2.298, 0.609)
	self.stances.desertfox.crouched.shoulders.rotation = Rotation(0.180153, -0.179782, -1.181)
	self.stances.desertfox.standard.shoulders.translation = Vector3(-1.392, 0.702, -1.391)
	self.stances.desertfox.standard.shoulders.rotation = Rotation(0.180153, -0.179782, -3.181)
	self.stances.desertfox.steelsight.shoulders.translation = Vector3(-7.39164, 5.702, 4.6085)

	self.stances.x_sr2.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_sr2.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_sr2.steelsight.shoulders.translation = Vector3(0, -8.943, -2.751)
	self.stances.x_sr2.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.x_baka.steelsight.shoulders.translation = Vector3(0, -8.943, -2.251)
	self.stances.x_baka.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_baka.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_baka.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.sko12.standard.shoulders.translation = Vector3(-4.725, 4.657, -2.39)
	self.stances.sko12.standard.shoulders.rotation = Rotation(-0.107606, 0.0861493, -3.628)
	self.stances.sko12.steelsight.shoulders.translation = Vector3(-10.7251, 2.657, 1.6099)
	self.stances.sko12.crouched.shoulders.translation = Vector3(-4.725, 1.657, -1.39)
	self.stances.sko12.crouched.shoulders.rotation = Rotation(-0.107619, 0.0861716, -1.628)

	self.stances.type54.steelsight.shoulders.translation = Vector3(-8.57216, -21.745, 4.38819)
	self.stances.type54.standard.shoulders.translation = Vector3(1.42784, -6.66911, 1.388)

	self.stances.p90.standard.shoulders.translation = Vector3(-6.04, -8.281, -1.598)
	self.stances.p90.standard.shoulders.rotation = Rotation(-0.209443, -0.968301, -3.2)
	self.stances.p90.steelsight.shoulders.translation = Vector3(-11.0398, -10.281, 1.40186)
	self.stances.p90.crouched.shoulders.translation = Vector3(-6.04, -11.281, 0.402)
	self.stances.p90.crouched.shoulders.rotation = Rotation(-0.209442, -0.968301, -1.2)

	self.stances.korth.standard.shoulders.translation = Vector3(-3.532, -12.883, -1.193)
	self.stances.korth.standard.shoulders.rotation = Rotation(-0.107327, 0.689376, -3.607)
	self.stances.korth.steelsight.shoulders.translation = Vector3(-8.544, -20.883, 3.828)
	self.stances.korth.steelsight.shoulders.rotation = Rotation(-0.107, 0.691001, -0.617)
	self.stances.korth.crouched.shoulders.translation = Vector3(-3.532, -15.872, -0.193)
	self.stances.korth.crouched.shoulders.rotation = Rotation(-0.107479, 0.694064, -1.607)

	self.stances.corgi.steelsight.shoulders.translation = Vector3(-11.8414, -7.769, 4.23172)
	self.stances.corgi.standard.shoulders.translation = Vector3(-1.7657, -2.76897, 0.438)

	self.stances.wa2000.steelsight.shoulders.translation = Vector3(-10.5288, 6.532, -0.247821)
	self.stances.wa2000.standard.shoulders.translation = Vector3(-0.528773, 3.53238, -2.248)

	self.stances.shak12.standard.shoulders.translation = Vector3(-6.841, -9.805, 1.4)
	self.stances.shak12.standard.shoulders.rotation = Rotation(-2.63013e-005, 0.501, -3.001)
	self.stances.shak12.crouched.shoulders.translation = Vector3(-6.841, -12.805, 1.4)
	self.stances.shak12.crouched.shoulders.rotation = Rotation(2.50167e-009, 0.501, -1.001)
	self.stances.shak12.steelsight.shoulders.translation = Vector3(-11.8414, -3.805, 1.40031)

	self.stances.x_sparrow.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_sparrow.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_sparrow.steelsight.shoulders.translation = Vector3(0, -8.943, -1.341)
	self.stances.x_sparrow.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.coal.steelsight.shoulders.translation = Vector3(-11.6275, -3.299, 3.54485)
	self.stances.coal.steelsight.shoulders.rotation = Rotation(0.2, 0.3, 0.000339108)
	self.stances.coal.standard.shoulders.translation = Vector3(-1.62751, 2.70145, 1.045)

	self.stances.m1897.standard.shoulders.translation = Vector3(-5.276, 6.948, 1.669)
	self.stances.m1897.standard.shoulders.rotation = Rotation(-4.57742e-005, -0.00055666, -3)
	self.stances.m1897.steelsight.shoulders.translation = Vector3(-9.27649, 7.948, 5.66907)
	self.stances.m1897.crouched.shoulders.translation = Vector3(-5.276, 3.948, 2.669)
	self.stances.m1897.crouched.shoulders.rotation = Rotation(-4.57742e-005, -0.00055666, -1)

	self.stances.x_legacy.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_legacy.standard.shoulders.rotation = Rotation(0.39, -1.08291e-006, 5.56597e-014)
	self.stances.x_legacy.steelsight.shoulders.translation = Vector3(0, -8.943, -0.629)
	self.stances.x_legacy.steelsight.shoulders.rotation = Rotation(0.39, -1.08291e-006, 5.56597e-014)

	self.stances.sparrow.standard.shoulders.translation = Vector3(-4.572, -14.343, 1.09556)
	self.stances.sparrow.standard.shoulders.rotation = Rotation(-0.107588, 0.68935, -3.628)
	self.stances.sparrow.steelsight.shoulders.translation = Vector3(-8.57222, -22.343, 4.09556)
	self.stances.sparrow.crouched.shoulders.translation = Vector3(-4.572, -17.343, 2.096)
	self.stances.sparrow.crouched.shoulders.rotation = Rotation(-0.107588, 0.68935, -1.628)

	self.stances.usp.standard.shoulders.translation = Vector3(-4.617, -13.201, -0.292)
	self.stances.usp.standard.shoulders.rotation = Rotation(-0.107255, 0.688006, -3.629)
	self.stances.usp.steelsight.shoulders.translation = Vector3(-8.61716, -21.201, 2.70756)
	self.stances.usp.crouched.shoulders.translation = Vector3(-4.617, -16.201, 1.608)
	self.stances.usp.crouched.shoulders.rotation = Rotation(-0.107255, 0.688006, -1.629)

	self.stances.x_tec9.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_tec9.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_tec9.steelsight.shoulders.translation = Vector3(0, -8.943, -2.251)
	self.stances.x_tec9.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.akmsu.standard.shoulders.translation = Vector3(-5.745, -8.371, 1.81)
	self.stances.akmsu.steelsight.shoulders.translation = Vector3(-10.7449, -10.371, 4.546)
	self.stances.akmsu.steelsight.shoulders.rotation = Rotation(-0.107631, 0.087, -0.628471)
	self.stances.akmsu.crouched.shoulders.translation = Vector3(-5.745, -13.375, 2.546)

	self.stances.c96.standard.shoulders.translation = Vector3(-4.571, -14.055, 0.768)
	self.stances.c96.standard.shoulders.rotation = Rotation(-0.107584, 0.68935, -3.628)
	self.stances.c96.steelsight.shoulders.translation = Vector3(-8.57126, -21.055, 3.76824)
	self.stances.c96.crouched.shoulders.translation = Vector3(-4.571, -17.055, 1.768)
	self.stances.c96.crouched.shoulders.rotation = Rotation(-0.107584, 0.68935, -1.628)

	self.stances.sub2000.steelsight.shoulders.translation = Vector3(-10.5285, 1.903, 5.12)
	self.stances.sub2000.standard.shoulders.translation = Vector3(-0.528522, 0.903269, 2.12)

	self.stances.r870.standard.shoulders.translation = Vector3(-4.725, 1.677, 2.228)
	self.stances.r870.standard.shoulders.rotation = Rotation(-0.107601, 0.0861551, -3.628)
	self.stances.r870.steelsight.shoulders.translation = Vector3(-10.7253, 2.677, 5.228)
	self.stances.r870.crouched.shoulders.translation = Vector3(-4.725, -1.323, 2.228)
	self.stances.r870.crouched.shoulders.rotation = Rotation(-0.107601, 0.0861552, -1.628)

	self.stances.x_mp9.steelsight.shoulders.translation = Vector3(0, -8.943, -2.251)
	self.stances.x_mp9.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_mp9.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_mp9.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.ppk.standard.shoulders.translation = Vector3(-4.617, -15.68, 1.07473)
	self.stances.ppk.standard.shoulders.rotation = Rotation(-0.106466, 0.687651, -3.63)
	self.stances.ppk.steelsight.shoulders.translation = Vector3(-8.61702, -21.68, 4.07473)
	self.stances.ppk.crouched.shoulders.translation = Vector3(-4.617, -18.68, 2.075)
	self.stances.ppk.crouched.shoulders.rotation = Rotation(-0.106466, 0.687651, -1.63)

	self.stances.x_deagle.steelsight.shoulders.translation = Vector3(0, -7.943, -2.27)
	self.stances.x_deagle.steelsight.shoulders.rotation = Rotation(0.39, -0.255751, 1.45909e-008)
	self.stances.x_deagle.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_deagle.standard.shoulders.rotation = Rotation(0.39, -0.255751, 1.50077e-008)

	self.stances.rpk.standard.shoulders.translation = Vector3(-5.745, -8.371, 1.81)
	self.stances.rpk.standard.shoulders.rotation = Rotation(-0.108, 0.087, -3.628)
	self.stances.rpk.steelsight.shoulders.translation = Vector3(-10.745, -10.371, 4.81)
	self.stances.rpk.steelsight.shoulders.rotation = Rotation(-0.107988, 0.087, -0.628)
	self.stances.rpk.crouched.shoulders.translation = Vector3(-5.719, 1.295, 2.81518)
	self.stances.rpk.crouched.shoulders.rotation = Rotation(-0.107474, 0.085454, -1.628)

	self.stances.x_czech.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_czech.standard.shoulders.rotation = Rotation(0.39, 3.90827e-010, -1.83449e-017)
	self.stances.x_czech.steelsight.shoulders.translation = Vector3(0, -8.943, -1.502)
	self.stances.x_czech.steelsight.shoulders.rotation = Rotation(0.39, 3.90827e-010, -1.83449e-017)

	self.stances.peacemaker.standard.shoulders.translation = Vector3(-1.7561, -12.2673, -0.192)
	self.stances.peacemaker.steelsight.shoulders.translation = Vector3(-8.5722, -22.083, 2.80797)

	self.stances.x_pl14.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_pl14.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_pl14.steelsight.shoulders.translation = Vector3(0, -8.943, -0.751)
	self.stances.x_pl14.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.aa12.crouched.shoulders.translation = Vector3(-5.231, -9.552, 0.275)
	self.stances.aa12.crouched.shoulders.rotation = Rotation(-6.50993e-006, 0.000117821, -1)
	self.stances.aa12.steelsight.shoulders.translation = Vector3(-11.2307, -5.552, 1.27525)
	self.stances.aa12.standard.shoulders.translation = Vector3(-5.231, -6.552, -1.725)
	self.stances.aa12.standard.shoulders.rotation = Rotation(-6.50993e-006, 0.000117821, -3)

	self.stances.m134.standard.shoulders.translation = Vector3(-5.24195, -11.5731, -21.961)
	self.stances.m134.steelsight.shoulders.translation = Vector3(-4.817, -17.573, 0.284)
	self.stances.m134.steelsight.shoulders.rotation = Rotation(1.25305e-005, -0.0011095, -11)

	self.stances.hailstorm.standard.shoulders.translation = Vector3(-2.05985, 2.00543, -2.73)
	self.stances.hailstorm.steelsight.shoulders.translation = Vector3(-10.7849, -5.022, -0.816179)

	self.stances.breech.standard.shoulders.translation = Vector3(-4.216, -3.432, 0.793)
	self.stances.breech.standard.shoulders.rotation = Rotation(-0.159942, 0.074906, -3.102)
	self.stances.breech.crouched.shoulders.translation = Vector3(-4.216, -6.432, -1.207)
	self.stances.breech.crouched.shoulders.rotation = Rotation(-0.159942, 0.074906, -1.102)
	self.stances.breech.steelsight.shoulders.translation = Vector3(-8.21608, -6.432, 3.79284)

	self.stances.mosin.steelsight.shoulders.translation = Vector3(-8.77739, -8.503, 3.87288)
	self.stances.mosin.standard.shoulders.translation = Vector3(-0.777393, -8.5033, 2.873)

	self.stances.striker.standard.shoulders.translation = Vector3(-4.716, 1.073, 1.54)
	self.stances.striker.standard.shoulders.rotation = Rotation(-0.107605, 0.0861444, -3.628)
	self.stances.striker.steelsight.shoulders.translation = Vector3(-10.7165, -1.927, 3.53988)
	self.stances.striker.crouched.shoulders.translation = Vector3(-4.716, -1.927, 1.54)
	self.stances.striker.crouched.shoulders.rotation = Rotation(-0.107605, 0.0861444, -1.628)

	self.stances.new_m14.standard.shoulders.translation = Vector3(1.0324, -10.9988, 1.566)
	self.stances.new_m14.steelsight.shoulders.translation = Vector3(-10.9676, -9.999, 4.06587)

	self.stances.beer.standard.shoulders.translation = Vector3(-4.667, -7.188, -0.131)
	self.stances.beer.standard.shoulders.rotation = Rotation(-4.44706e-005, -0.000568556, -3)
	self.stances.beer.steelsight.shoulders.translation = Vector3(-8.613, -21.82, 3.714)
	self.stances.beer.steelsight.shoulders.rotation = Rotation(-0.108, 0.689001, -0.629)
	self.stances.beer.crouched.shoulders.translation = Vector3(-4.667, -10.188, 0.869)
	self.stances.beer.crouched.shoulders.rotation = Rotation(-4.44706e-005, -0.000568556, -1)

	self.stances.x_packrat.standard.shoulders.translation = Vector3(0, -16.943, -2.75089)
	self.stances.x_packrat.standard.shoulders.rotation = Rotation(0.39, -0.254866, 1.00052e-008)
	self.stances.x_packrat.steelsight.shoulders.translation = Vector3(0, -8.943, -0.251)
	self.stances.x_packrat.steelsight.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)

	self.stances.g22c.standard.shoulders.translation = Vector3(-4.57, -12, 1.934)
	self.stances.g22c.standard.shoulders.rotation = Rotation(-0.100001, 1.25004, -3.6)
	self.stances.g22c.steelsight.shoulders.translation = Vector3(-8.583, -22, 5.134)
	self.stances.g22c.steelsight.shoulders.rotation = Rotation(-0.108, 0.689, -0.629)
	self.stances.g22c.crouched.shoulders.translation = Vector3(-4.57, -15, 2.6)
	self.stances.g22c.crouched.shoulders.rotation = Rotation(-0.0999998, 1.25, -1.6)

	self.stances.x_pm9.steelsight.shoulders.translation = Vector3(0, -8.943, -3.751)
	self.stances.x_pm9.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_pm9.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_pm9.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.scorpion.standard.shoulders.translation = Vector3(-0.756248, -10.7522, 3.381)
	self.stances.scorpion.steelsight.shoulders.translation = Vector3(-10.7562, -16.752, 6.38121)

	self.stances.hk21.standard.shoulders.translation = Vector3(-2.545, -1.393, -6.667)
	self.stances.hk21.standard.shoulders.rotation = Rotation(-4.79977e-005, -0.00548037, -3.001)
	self.stances.hk21.steelsight.shoulders.translation = Vector3(-8.6, 6, 3.3)
	self.stances.hk21.steelsight.shoulders.rotation = Rotation(-0.108, 0.0860001, -0.628)
	self.stances.hk21.crouched.shoulders.translation = Vector3(-2.545, -4.393, -0.667)
	self.stances.hk21.crouched.shoulders.rotation = Rotation(-4.79978e-005, -0.00548037, -1.001)

	self.stances.glock_17.steelsight.shoulders.translation = Vector3(-8.583, -21.82, 5.134)
	self.stances.glock_17.standard.shoulders.translation = Vector3(-1.6134, -7.82, 1.93359)

	self.stances.gre_m79.steelsight.shoulders.translation = Vector3(-10.8141, -9.538, 5.2255)
	self.stances.gre_m79.standard.shoulders.translation = Vector3(0.185923, -7.53816, 0.725)

	self.stances.mac10.steelsight.shoulders.translation = Vector3(-8.6814, -18.646, 3.13712)
	self.stances.mac10.standard.shoulders.translation = Vector3(-0.681, -13.646, 0.137)
	self.stances.mac10.standard.shoulders.rotation = Rotation(-0.105352, -0.012, -0.633)

	self.stances.bessy.standard.shoulders.translation = Vector3(-0.777393, -0.503, 2.873)
	self.stances.bessy.steelsight.shoulders.translation = Vector3(-8.77739, -11.503, 5.87288)

	self.stances.maxim9.standard.shoulders.translation = Vector3(-4.623, -15.669, 2.067)
	self.stances.maxim9.standard.shoulders.rotation = Rotation(-0.108, 0.689, -3.628)
	self.stances.maxim9.steelsight.shoulders.translation = Vector3(-8.62261, -22.669, 5.06716)
	self.stances.maxim9.crouched.shoulders.translation = Vector3(-4.623, -18.669, 3.067)
	self.stances.maxim9.crouched.shoulders.rotation = Rotation(-0.107768, 0.689, -1.628)

	self.stances.sr2.standard.shoulders.translation = Vector3(-2.4607, 2.46388, 1.831)
	self.stances.sr2.steelsight.shoulders.translation = Vector3(-9.4607, 0.464, 5.33089)

	self.stances.aug.steelsight.shoulders.translation = Vector3(-8.83927, -4.893, 4.31838)
	self.stances.aug.standard.shoulders.translation = Vector3(-0.339274, 1.10662, 0.818)

	self.stances.x_chinchilla.standard.shoulders.translation = Vector3(0, -14.695, -2.751)
	self.stances.x_chinchilla.standard.shoulders.rotation = Rotation(-4.16893e-010, 0.68941, -0)
	self.stances.x_chinchilla.steelsight.shoulders.translation = Vector3(0, -8.943, -2.187)
	self.stances.x_chinchilla.steelsight.shoulders.rotation = Rotation(0, 0.689411, 0)

	self.stances.g26.steelsight.shoulders.translation = Vector3(-8.61347, -21.69, 4.5355)

	self.stances.new_raging_bull.steelsight.shoulders.translation = Vector3(-8.53967, -20.872, 2.407)
	self.stances.new_raging_bull.standard.shoulders.translation = Vector3(-0.539675, -10.8721, -1.393)

	self.stances.serbu.steelsight.shoulders.translation = Vector3(-10.716, -4.324, 5.223)
	self.stances.serbu.standard.shoulders.translation = Vector3(-3.21602, -2.32356, 1.223)

	self.stances.x_g18c.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_g18c.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_g18c.steelsight.shoulders.translation = Vector3(0, -8.943, -0.751)
	self.stances.x_g18c.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.m45.standard.shoulders.translation = Vector3(0.262773, -5.24995, 3.387)

	self.stances.x_scorpion.standard.shoulders.translation = Vector3(-0.4257, -16.943, -2.751)
	self.stances.x_scorpion.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_scorpion.steelsight.shoulders.translation = Vector3(0, -8.943, -2.751)
	self.stances.x_scorpion.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.new_m4.crouched.shoulders.translation = Vector3(-5.248, -11.496, 0.783)
	self.stances.new_m4.crouched.shoulders.rotation = Rotation(-0.107613, 0.0861495, -1.628)
	self.stances.new_m4.standard.shoulders.translation = Vector3(-5.248, -8.996, -1.217)
	self.stances.new_m4.standard.shoulders.rotation = Rotation(-0.107613, 0.0861496, -3.628)
	self.stances.new_m4.steelsight.shoulders.rotation = Rotation(0, 0, -45)
	self.stances.new_m4.steelsight.shoulders.translation = Vector3(-10.748, -10.996, 1.783)
	self.stances.new_m4.steelsight.shoulders.rotation = Rotation(-0.108, 0.086, -0.628441)

	self.stances.coach.steelsight.shoulders.translation = Vector3(-11.7495, -4.638, 6.813)
	self.stances.coach.standard.shoulders.translation = Vector3(-3.74948, -7.13793, 4.313)

	self.stances.uzi.steelsight.shoulders.translation = Vector3(-10.7529, -5.131, 5.69002)
	self.stances.uzi.standard.shoulders.translation = Vector3(-0.752888, -2.13148, 2.19)

	self.stances.akm.crouched.shoulders.translation = Vector3(-5.745, -11.371, 1.80527)
	self.stances.akm.crouched.shoulders.rotation = Rotation(-0.107633, 0.0877074, -1.627)
	self.stances.akm.standard.shoulders.translation = Vector3(-5.745, -8.371, 1.81)
	self.stances.akm.standard.shoulders.rotation = Rotation(-0.107633, 0.087, -3.628)
	self.stances.akm.steelsight.shoulders.translation = Vector3(-10.7445, -10.371, 4.81)
	self.stances.akm.steelsight.shoulders.rotation = Rotation(-0.107633, 0.087, -0.628)

	self.stances.tec9.standard.shoulders.translation = Vector3(-7.048, -4.994, -0.566)
	self.stances.tec9.standard.shoulders.rotation = Rotation(-5.01609e-005, -0.000580993, -3)
	self.stances.tec9.crouched.shoulders.translation = Vector3(-7.048, -7.994, 1.434)
	self.stances.tec9.crouched.shoulders.rotation = Rotation(-5.01609e-005, -0.000580993, -1)
	self.stances.tec9.steelsight.shoulders.translation = Vector3(-11.0476, -5.994, 4.43413)

	self.stances.scout.standard.shoulders.translation = Vector3(2.44481, 5.8, 0.445)
	self.stances.scout.steelsight.shoulders.translation = Vector3(-7.96527, 4.926, 3.072)

	self.stances.holt.crouched.shoulders.translation = Vector3(-4.573, -18.669, 3.867)
	self.stances.holt.crouched.shoulders.rotation = Rotation(-0.107768, 0.695029, -1.628)
	self.stances.holt.steelsight.shoulders.translation = Vector3(-8.57261, -21.669, 5.86716)
	self.stances.holt.standard.shoulders.translation = Vector3(-4.573, -15.669, 2.867)
	self.stances.holt.standard.shoulders.rotation = Rotation(-0.108, 0.689, -3.628)

	self.stances.saiga.standard.shoulders.translation = Vector3(-1.994, 0.289, -1.158)
	self.stances.saiga.standard.shoulders.rotation = Rotation(-0.106891, 0.0637608, -3.63)
	self.stances.saiga.steelsight.shoulders.translation = Vector3(-7.49391, 0.289, 1.84245)
	self.stances.saiga.crouched.shoulders.translation = Vector3(-1.994, -2.711, -0.158)
	self.stances.saiga.crouched.shoulders.rotation = Rotation(-0.106891, 0.0637608, -1.63)

	self.stances.packrat.standard.shoulders.translation = Vector3(-4.573, -15.277, 2.472)
	self.stances.packrat.standard.shoulders.rotation = Rotation(-0.107784, 0.689363, -3.629)
	self.stances.packrat.steelsight.shoulders.translation = Vector3(-8.57259, -22.277, 5.47154)
	self.stances.packrat.crouched.shoulders.translation = Vector3(-4.573, -18.277, 3.472)
	self.stances.packrat.crouched.shoulders.rotation = Rotation(-0.107784, 0.689363, -1.629)

	self.stances.x_hs2000.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_hs2000.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_hs2000.steelsight.shoulders.translation = Vector3(0, -8.943, -1.341)
	self.stances.x_hs2000.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.amcar.standard.shoulders.translation = Vector3(-5.248, -8.996, -1.271)
	self.stances.amcar.standard.shoulders.rotation = Rotation(-0.107612, 0.0861495, -3.628)
	self.stances.amcar.steelsight.shoulders.translation = Vector3(-10.748, -10.996, 1.32866)
	self.stances.amcar.crouched.shoulders.translation = Vector3(-4.25012, -11.495, 0.329)
	self.stances.amcar.crouched.shoulders.rotation = Rotation(-0.107612, 0.0861495, -1.628)

	self.stances.x_stech.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_stech.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_stech.steelsight.shoulders.translation = Vector3(0, -8.943, -1.841)
	self.stances.x_stech.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.x_breech.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_breech.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_breech.steelsight.shoulders.translation = Vector3(0, -8.943, -1.341)
	self.stances.x_breech.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.scar.crouched.shoulders.translation = Vector3(-4.247, -12.472, -1.124)
	self.stances.scar.crouched.shoulders.rotation = Rotation(-0.107611, 0.0861495, -1.628)
	self.stances.scar.standard.shoulders.translation = Vector3(-4.247, -9.472, -2.124)
	self.stances.scar.standard.shoulders.rotation = Rotation(-0.107611, 0.0861495, -3.628)
	self.stances.scar.steelsight.shoulders.rotation = Rotation(0, 0, -45)
	self.stances.scar.steelsight.shoulders.translation = Vector3(-10.747, -10.472, -0.124)
	self.stances.scar.steelsight.shoulders.rotation = Rotation(-0.107624, 0.086, -0.62802)

	self.stances.mg42.standard.shoulders.translation = Vector3(-2.72117, -3.14975, -9.8)
	self.stances.mg42.steelsight.shoulders.translation = Vector3(-10.78, -2.15, -0.9)
	self.stances.mg42.steelsight.shoulders.rotation = Rotation(-0.108, 0.286, 1.32881e-009)

	self.stances.olympic.standard.shoulders.translation = Vector3(-5.248, -8.996, -1.217)
	self.stances.olympic.standard.shoulders.rotation = Rotation(-0.107598, 0.0861546, -3.628)
	self.stances.olympic.steelsight.shoulders.translation = Vector3(-10.748, -10.996, 1.329)
	self.stances.olympic.crouched.shoulders.translation = Vector3(-4.745, -11.999, 0.335)
	self.stances.olympic.crouched.shoulders.rotation = Rotation(-0.107598, 0.0861547, -1.628)

	self.stances.x_g17.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_g17.standard.shoulders.rotation = Rotation(0.39, -0.255, 3.64771e-010)
	self.stances.x_g17.steelsight.shoulders.translation = Vector3(-0, -8.943, -0.751)
	self.stances.x_g17.steelsight.shoulders.rotation = Rotation(0.39, -0.254867, 9.37984e-009)

	self.stances.galil.steelsight.shoulders.translation = Vector3(-10.745, -10.069, 3.61564)
	self.stances.galil.standard.shoulders.translation = Vector3(-3.24497, -6.0689, 1.616)

	self.stances.sbl.standard.shoulders.translation = Vector3(-4.697, 0.99, 5.319)
	self.stances.sbl.standard.shoulders.rotation = Rotation(-0.0019002, 0.0863347, -3.631)
	self.stances.sbl.crouched.shoulders.translation = Vector3(-4.697, -2.01, 5.319)
	self.stances.sbl.crouched.shoulders.rotation = Rotation(-0.0019002, 0.0863347, -1.631)
	self.stances.sbl.steelsight.shoulders.translation = Vector3(-10.6967, -2.01, 8.3194)

	self.stances.pl14.standard.shoulders.translation = Vector3(-4.572, -14.277, 1.79273)
	self.stances.pl14.standard.shoulders.rotation = Rotation(-0.107874, 0.68962, -3.628)
	self.stances.pl14.steelsight.shoulders.translation = Vector3(-8.57236, -22.277, 4.79273)
	self.stances.pl14.crouched.shoulders.translation = Vector3(-4.572, -17.277, 2.793)
	self.stances.pl14.crouched.shoulders.rotation = Rotation(-0.107874, 0.68962, -1.628)

	self.stances.ching.steelsight.shoulders.translation = Vector3(-10.895, 1.742, 2.67622)
	self.stances.ching.standard.shoulders.translation = Vector3(-0.894999, 1.74154, 2.176)

	self.stances.legacy.standard.shoulders.translation = Vector3(-4.573, -15.88, 3.007)
	self.stances.legacy.standard.shoulders.rotation = Rotation(-0.108958, 0.68835, -3.628)
	self.stances.legacy.steelsight.shoulders.translation = Vector3(-8.57328, -21.88, 6.00697)
	self.stances.legacy.crouched.shoulders.translation = Vector3(-4.573, -18.88, 4.007)
	self.stances.legacy.crouched.shoulders.rotation = Rotation(-0.108958, 0.68835, -1.628)

	self.stances.colt_1911.standard.shoulders.translation = Vector3(-4.617, -13.202, -0.394)
	self.stances.colt_1911.standard.shoulders.rotation = Rotation(-0.107556, 0.689669, -3.629)
	self.stances.colt_1911.steelsight.shoulders.translation = Vector3(-8.61721, -21.202, 2.60639)
	self.stances.colt_1911.crouched.shoulders.translation = Vector3(-4.617, -16.202, 0.606)
	self.stances.colt_1911.crouched.shoulders.rotation = Rotation(-0.107556, 0.68967, -1.629)

	self.stances.shepheard.standard.shoulders.translation = Vector3(-5.712, -9, -1.49)
	self.stances.shepheard.standard.shoulders.rotation = Rotation(-6.8428e-005, -0.000472969, -3)
	self.stances.shepheard.steelsight.shoulders.translation = Vector3(-10.7119, -11, 1.51)
	self.stances.shepheard.steelsight.shoulders.rotation = Rotation(-6.84281e-005, -0.000472974, -0)
	self.stances.shepheard.crouched.shoulders.translation = Vector3(-5, -12, 0.51)
	self.stances.shepheard.crouched.shoulders.rotation = Rotation(-6.84277e-005, -0.000472967, -1)

	self.stances.polymer.standard.shoulders.translation = Vector3(-2.723, -0.503, -1.367)
	self.stances.polymer.standard.shoulders.rotation = Rotation(-3.95221e-005, -0.000647161, -3)
	self.stances.polymer.crouched.shoulders.translation = Vector3(-2.723, -3.503, -0.367)
	self.stances.polymer.crouched.shoulders.rotation = Rotation(-3.95221e-005, -0.000647161, -1)
	self.stances.polymer.steelsight.shoulders.translation = Vector3(-8.97259, -1.503, 1.63314)

	self.stances.m95.standard.shoulders.translation = Vector3(-5.943, 0.585, -3.398)
	self.stances.m95.standard.shoulders.rotation = Rotation(-0.107561, -0.51707, -3.628)
	self.stances.m95.steelsight.shoulders.translation = Vector3(-12.9429, -0.415, 2.60163)
	self.stances.m95.crouched.shoulders.translation = Vector3(-5.943, -2.415, -1.398)
	self.stances.m95.crouched.shoulders.rotation = Rotation(-0.107561, -0.51707, -1.628)

	self.stances.erma.standard.shoulders.translation = Vector3(-0.493946, -1.43597, 0.262)
	self.stances.erma.steelsight.shoulders.translation = Vector3(-8.49395, -2.436, 2.76158)

	self.stances.tecci.standard.shoulders.translation = Vector3(-5.248, -8.996, -1.217)
	self.stances.tecci.standard.shoulders.rotation = Rotation(-0.108, 0.086, -3.628)
	self.stances.tecci.steelsight.shoulders.translation = Vector3(-10.748, -10.996, 2.883)
	self.stances.tecci.steelsight.shoulders.rotation = Rotation(-0.108, 0.086, -0.628)
	self.stances.tecci.crouched.shoulders.translation = Vector3(-5.731, -2.277, 1.559)
	self.stances.tecci.crouched.shoulders.rotation = Rotation(-5.14968e-005, -0.00122516, -1)

	self.stances.msr.standard.shoulders.translation = Vector3(-3.772, -11.823, 0.115)
	self.stances.msr.standard.shoulders.rotation = Rotation(-0.107632, 0.0860669, -3.628)
	self.stances.msr.crouched.shoulders.translation = Vector3(-3.772, -14.823, 0.115)
	self.stances.msr.crouched.shoulders.rotation = Rotation(-0.107632, 0.0860669, -1.628)
	self.stances.msr.steelsight.shoulders.translation = Vector3(-8.77198, -7.823, 3.11458)

	self.stances.mp7.steelsight.shoulders.translation = Vector3(-10.754, -9.195, 5.61266)
	self.stances.mp7.standard.shoulders.translation = Vector3(-1.75399, -4.19497, 1.613)

	self.stances.winchester1874.standard.shoulders.translation = Vector3(1.29651, -0.181728, 7.4)
	self.stances.winchester1874.steelsight.shoulders.translation = Vector3(-10.703, -1.182, 8.2)
	self.stances.winchester1874.steelsight.shoulders.rotation = Rotation(-0.00219243, 0.186, -0.630104)

	self.stances.groza.steelsight.shoulders.translation = Vector3(-12.8252, -7.03, 1.89685)
	self.stances.groza.standard.shoulders.translation = Vector3(-2.82523, 0.96999, -0.103)

	self.stances.qbu88.steelsight.shoulders.translation = Vector3(-11.8411, -7.028, 1.169)
	self.stances.qbu88.standard.shoulders.translation = Vector3(-1.80145, -3.02753, 0.375)

	self.stances.glock_18c.standard.shoulders.translation = Vector3(-4.613, -13.69, 1.934)
	self.stances.glock_18c.standard.shoulders.rotation = Rotation(-0.107559, 0.688843, -3.629)
	self.stances.glock_18c.steelsight.shoulders.translation = Vector3(-8.583, -21.69, 5.134)
	self.stances.glock_18c.crouched.shoulders.translation = Vector3(-4.613, -16.69, 2.535)
	self.stances.glock_18c.crouched.shoulders.rotation = Rotation(-0.107559, 0.688843, -1.629)

	self.stances.hunter.steelsight.shoulders.translation = Vector3(-10.5286, -23.13, 5.3989)

	self.stances.new_mp5.standard.shoulders.translation = Vector3(-4.197, -8.715, -3.009)
	self.stances.new_mp5.standard.shoulders.rotation = Rotation(-0.107167, 0.688049, -3.628)
	self.stances.new_mp5.steelsight.shoulders.translation = Vector3(-10.1966, -7.715, 0.490728)
	self.stances.new_mp5.crouched.shoulders.translation = Vector3(-4.197, -11.715, -1.509)
	self.stances.new_mp5.crouched.shoulders.rotation = Rotation(-0.107167, 0.688049, -1.628)

	self.stances.m60.steelsight.shoulders.translation = Vector3(-10.75, -6.369, -0.1)
	self.stances.m60.steelsight.shoulders.rotation = Rotation(-0.208001, 0.286, 5.21102e-011)
	self.stances.m60.standard.shoulders.translation = Vector3(0.278701, 4.63058, -3.1)

	self.stances.x_g22c.standard.shoulders.translation = Vector3(0, -16.943, -2.75089)
	self.stances.x_g22c.standard.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)
	self.stances.x_g22c.steelsight.shoulders.translation = Vector3(0, -8.943, -0.751)
	self.stances.x_g22c.steelsight.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)

	self.stances.kacchainsaw.standard.shoulders.translation = Vector3(0.355, 5.694, -15.898)
	self.stances.kacchainsaw.steelsight.shoulders.translation = Vector3(-5.244, -5.306, -1.3322)

	self.stances.huntsman.standard.shoulders.translation = Vector3(-2.79086, -11.9613, 4.566)
	self.stances.huntsman.steelsight.shoulders.translation = Vector3(-10.7909, -10.071, 5.58983)

	self.stances.b682.standard.shoulders.translation = Vector3(0.526857, -1.14329, 3.312)
	self.stances.b682.steelsight.shoulders.translation = Vector3(-8.43, 0.75, 6.425)
	self.stances.b682.steelsight.shoulders.rotation = Rotation(1.219e-005, 0, -0.000353222)

	self.stances.china.steelsight.shoulders.translation = Vector3(-12.6957, -4.939, 8.095)
	self.stances.china.steelsight.shoulders.rotation = Rotation(-3.28964e-005, -0.001, 0.000339163)
	self.stances.china.standard.shoulders.translation = Vector3(-0.69567, -10.653, -1.3)

	self.stances.spas12.standard.shoulders.translation = Vector3(-2.716, 1.232, 0.405)
	self.stances.spas12.standard.shoulders.rotation = Rotation(-0.107434, 0.0867763, -3.629)
	self.stances.spas12.steelsight.shoulders.translation = Vector3(-10.7162, 3.232, 4.40481)
	self.stances.spas12.crouched.shoulders.translation = Vector3(-4.716, 0.232, 1.405)
	self.stances.spas12.crouched.shoulders.rotation = Rotation(-0.107434, 0.0867764, -1.629)

	self.stances.r93.crouched.shoulders.translation = Vector3(-3.745, -16.425, 3.266)
	self.stances.r93.crouched.shoulders.rotation = Rotation(-0.107598, 0.0861374, -1.628)
	self.stances.r93.standard.shoulders.translation = Vector3(-3.745, -13.425, 2.266)
	self.stances.r93.standard.shoulders.rotation = Rotation(-0.107598, 0.0861373, -3.628)
	self.stances.r93.steelsight.shoulders.translation = Vector3(-10.7449, -12.425, 4.26611)

	self.stances.flamethrower_mk2.standard.shoulders.translation = Vector3(1.18986, 0.741307, -1.507)
	self.stances.flamethrower_mk2.steelsight.shoulders.translation = Vector3(-10.81, -0.258693, 2.493)

	self.stances.czech.standard.shoulders.translation = Vector3(-4.667, -7.123, 0.714)
	self.stances.czech.standard.shoulders.rotation = Rotation(-3.37599e-005, -0.000953238, -3)
	self.stances.czech.steelsight.shoulders.translation = Vector3(-8.613, -21.82, 3.714)
	self.stances.czech.steelsight.shoulders.rotation = Rotation(-0.108, 0.689001, -0.629)
	self.stances.czech.crouched.shoulders.translation = Vector3(-4.667, -10.123, 1.121)
	self.stances.czech.crouched.shoulders.rotation = Rotation(-3.37599e-005, -0.000953238, -1)

	self.stances.x_rage.steelsight.shoulders.translation = Vector3(0, -7.943, -3.34067)
	self.stances.x_rage.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_rage.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_rage.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.asval.steelsight.shoulders.translation = Vector3(-10.7334, -4.252, 6.21344)
	self.stances.asval.steelsight.shoulders.rotation = Rotation(-0.11, 0.0863531, -0.630607)
	self.stances.asval.standard.shoulders.translation = Vector3(-2.73343, -1.25235, 2.213)

	self.stances.awp.steelsight.shoulders.translation = Vector3(-10.063, -6.823, 1.369)
	self.stances.awp.steelsight.shoulders.rotation = Rotation(-0.107812, 0.078546, 2.872)
	self.stances.awp.standard.shoulders.translation = Vector3(-1.325, -3.82336, 1.961)

	self.stances.g3.steelsight.shoulders.translation = Vector3(-10.708, -3.53, 1.74856)
	self.stances.g3.standard.shoulders.translation = Vector3(-2.2266, -6.52831, -2.411)

	self.stances.x_model3.standard.shoulders.translation = Vector3(0, -16.943, -2.68703)
	self.stances.x_model3.standard.shoulders.rotation = Rotation(0, 0.68941, 2.66804e-008)
	self.stances.x_model3.steelsight.shoulders.translation = Vector3(0, -8.943, -2.18703)
	self.stances.x_model3.steelsight.shoulders.rotation = Rotation(0, 0.68941, -8.33764e-010)

	self.stances.hajk.standard.shoulders.translation = Vector3(-0.186032, 3.89743, 0.493)
	self.stances.hajk.steelsight.shoulders.translation = Vector3(-9.18603, 1.897, 1.49328)

	self.stances.sterling.standard.shoulders.translation = Vector3(-3.04, 2.016, 2.256)
	self.stances.sterling.standard.shoulders.rotation = Rotation(0.080801, -0.114, -3.552)
	self.stances.sterling.steelsight.shoulders.translation = Vector3(-7.04, 3.016, 6.25562)
	self.stances.sterling.crouched.shoulders.translation = Vector3(-3.04, -0.984, 2.256)
	self.stances.sterling.crouched.shoulders.rotation = Rotation(0.0810001, -0.114, -1.552)

	self.stances.pm9.steelsight.shoulders.translation = Vector3(-8.681, -17.646, 4.287)
	self.stances.pm9.steelsight.shoulders.rotation = Rotation(-0.105, -0.012, -0.633)
	self.stances.pm9.standard.shoulders.translation = Vector3(-2.33471, 2.087, 1.287)

	self.stances.ak5.steelsight.shoulders.translation = Vector3(-10.7638, -3.601, 2.66242)
	self.stances.ak5.standard.shoulders.translation = Vector3(-2.74676, -4.60071, -0.338)

	self.stances.s552.steelsight.shoulders.translation = Vector3(-10.7007, -9.075, 3.8522)
	self.stances.s552.standard.shoulders.translation = Vector3(-0.200676, -8.075, 1)

	self.stances.m32.steelsight.shoulders.translation = Vector3(-9.64378, -2.878, 3.22063)
	self.stances.m32.standard.shoulders.translation = Vector3(-1.14378, 1.12154, 0.721)

	self.stances.m249.standard.shoulders.translation = Vector3(0.278701, 8.63058, -2.877)
	self.stances.m249.steelsight.shoulders.translation = Vector3(-10.75, 6.6, 0.42)
	self.stances.m249.steelsight.shoulders.rotation = Rotation(-0.108, 0.086001, -0.628)

	self.stances.ray.steelsight.shoulders.translation = Vector3(-7.559, -0.611, 5.17)
	self.stances.ray.steelsight.shoulders.rotation = Rotation(-0.107327, 0.0863753, -0.628)
	self.stances.ray.standard.shoulders.translation = Vector3(0.440737, 4.38941, 4.67)

	self.stances.benelli.standard.shoulders.translation = Vector3(-4.716, 2.243, 1.24)
	self.stances.benelli.standard.shoulders.rotation = Rotation(-0.107528, 0.0870683, -3.629)
	self.stances.benelli.steelsight.shoulders.translation = Vector3(-10.7162, 2.243, 5.23982)
	self.stances.benelli.crouched.shoulders.translation = Vector3(-4.716, -0.757, 2.24)
	self.stances.benelli.crouched.shoulders.rotation = Rotation(-0.107528, 0.0870683, -1.629)

	self.stances.hcar.standard.shoulders.translation = Vector3(-0.544945, -1.39307, 0.333)
	self.stances.hcar.steelsight.shoulders.rotation = Rotation(0, 0, -0)
	self.stances.hcar.steelsight.shoulders.translation = Vector3(-10.728, -8.435, 0.818)
	self.stances.hcar.steelsight.shoulders.rotation = Rotation(0.0500003, 0, -0.600006)
	self.stances.hcar.steelsight.shoulders.rotation = Rotation(-0.15, 0, 0)

	self.stances.mateba.standard.shoulders.translation = Vector3(-4.637, -13.242, 0.2)
	self.stances.mateba.standard.shoulders.rotation = Rotation(-0.106406, 0.68878, -3.607)
	self.stances.mateba.steelsight.shoulders.translation = Vector3(-8.607, -22.242, 3.19964)
	self.stances.mateba.crouched.shoulders.translation = Vector3(-4.637, -16.242, 1.2)
	self.stances.mateba.crouched.shoulders.rotation = Rotation(-0.106406, 0.68878, -1.607)

	self.stances.jowi.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.jowi.standard.shoulders.rotation = Rotation(0.39, -0.247275, 7.29543e-009)
	self.stances.jowi.steelsight.shoulders.translation = Vector3(0, -8.943, -0.751)
	self.stances.jowi.steelsight.shoulders.rotation = Rotation(0.39, -0.247275, 7.29543e-009)

	self.stances.x_c96.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_c96.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_c96.steelsight.shoulders.translation = Vector3(0, -8.943, -1.841)
	self.stances.x_c96.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.siltstone.standard.shoulders.translation = Vector3(-0.929828, 5.15353, -0.755)
	self.stances.siltstone.steelsight.shoulders.translation = Vector3(-9.42983, 2.154, 3.24493)

	self.stances.schakal.standard.shoulders.translation = Vector3(-1.876, 3.459, -1.797)
	self.stances.schakal.standard.shoulders.rotation = Rotation(-5.5583e-005, -0.000568586, -3)
	self.stances.schakal.steelsight.shoulders.translation = Vector3(-7.87628, 4.459, 2.20344)
	self.stances.schakal.crouched.shoulders.translation = Vector3(-1.876, 0.459, 0.203)
	self.stances.schakal.crouched.shoulders.rotation = Rotation(-5.5583e-005, -0.000568586, -1)

	self.stances.lemming.standard.shoulders.translation = Vector3(-4.572, -13.669, 1.664)
	self.stances.lemming.standard.shoulders.rotation = Rotation(-0.107581, 0.689398, -3.628)
	self.stances.lemming.steelsight.shoulders.translation = Vector3(-8.57216, -20.669, 4.66377)
	self.stances.lemming.crouched.shoulders.translation = Vector3(-4.572, -16.669, 2.664)
	self.stances.lemming.crouched.shoulders.rotation = Rotation(-0.107581, 0.689398, -1.628)

	self.stances.l85a2.standard.shoulders.translation = Vector3(0.577317, -2.05838, -0.441)
	self.stances.l85a2.steelsight.shoulders.translation = Vector3(-9.42268, -5.558, 1.05914)

	self.stances.komodo.steelsight.shoulders.translation = Vector3(-11.0168, -9.983, 4.40512)
	self.stances.komodo.standard.shoulders.translation = Vector3(-3.01683, -8.98274, 1.405)

	self.stances.rsh12.standard.shoulders.translation = Vector3(-2.614, -12.8862, -2.172)
	self.stances.rsh12.standard.shoulders.rotation = Rotation(-0.106842, 0.690638, -3.617)
	self.stances.rsh12.steelsight.shoulders.translation = Vector3(-8.61421, -21.886, 0.827854)
	self.stances.rsh12.crouched.shoulders.translation = Vector3(-2.614, -15.886, -0.172)
	self.stances.rsh12.crouched.shoulders.rotation = Rotation(-0.106842, 0.690637, -1.617)

	self.stances.model3.standard.shoulders.translation = Vector3(-4.54, -13.696, -0.698)
	self.stances.model3.standard.shoulders.rotation = Rotation(-0.10732, 0.689384, -3.607)
	self.stances.model3.steelsight.shoulders.translation = Vector3(-8.53958, -21.696, 2.30238)
	self.stances.model3.crouched.shoulders.translation = Vector3(-4.54, -16.696, 0.302)
	self.stances.model3.crouched.shoulders.rotation = Rotation(-0.10732, 0.689384, -1.607)

	self.stances.contender.standard.shoulders.translation = Vector3(-6.079, -15.747, 2.644)
	self.stances.contender.standard.shoulders.rotation = Rotation(0.207917, 0.173627, -3.069)
	self.stances.contender.crouched.shoulders.translation = Vector3(-6.079, -18.747, 3.644)
	self.stances.contender.steelsight.shoulders.translation = Vector3(-12.0794, -20.747, 6.14383)

	self.stances.m590.standard.shoulders.translation = Vector3(-4.716, 2.356, 2.185)
	self.stances.m590.standard.shoulders.rotation = Rotation(-0.113, 0.588, -3.627)
	self.stances.m590.crouched.shoulders.translation = Vector3(-4.716, -0.644, 2.185)
	self.stances.m590.crouched.shoulders.rotation = Rotation(-0.107526, 0.087522, -1.627)
	self.stances.m590.steelsight.shoulders.translation = Vector3(-10.7159, 2.356, 5.685)

	self.stances.x_usp.steelsight.shoulders.translation = Vector3(0, -8.943, -1.751)
	self.stances.x_usp.steelsight.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)
	self.stances.x_usp.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_usp.standard.shoulders.rotation = Rotation(0.39, -0.254866, 9.37984e-009)

	self.stances.hs2000.standard.shoulders.translation = Vector3(-4.617, -14.283, 1.81607)
	self.stances.hs2000.standard.shoulders.rotation = Rotation(-0.107623, 0.686981, -3.629)
	self.stances.hs2000.steelsight.shoulders.translation = Vector3(-8.61718, -22.283, 4.81607)
	self.stances.hs2000.crouched.shoulders.translation = Vector3(-4.617, -17.283, 2.816)
	self.stances.hs2000.crouched.shoulders.rotation = Rotation(-0.107623, 0.686981, -1.629)

	self.stances.x_b92fs.standard.shoulders.translation = Vector3(0, -16.943, -2.751)
	self.stances.x_b92fs.standard.shoulders.rotation = Rotation(0.39, -0.235341, 1.56331e-010)
	self.stances.x_b92fs.steelsight.shoulders.translation = Vector3(0, -8.943, -1.296)
	self.stances.x_b92fs.steelsight.shoulders.rotation = Rotation(0.39, -0.235344, -5.21102e-011)

	self.stances.x_ppk.standard.shoulders.translation = Vector3(-0.4257, -16.943, -2.751)
	self.stances.x_ppk.standard.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)
	self.stances.x_ppk.steelsight.shoulders.translation = Vector3(0, -8.943, -1.341)
	self.stances.x_ppk.steelsight.shoulders.rotation = Rotation(0.39, 8.32429e-006, 1.70755e-006)

	self.stances.shrew.standard.shoulders.translation = Vector3(-4.574, -15.279, 0.434985)
	self.stances.shrew.standard.shoulders.rotation = Rotation(-0.10835, 0.689279, -3.629)
	self.stances.shrew.crouched.shoulders.translation = Vector3(-4.574, -18.279, 1.435)
	self.stances.shrew.crouched.shoulders.rotation = Rotation(-0.10835, 0.689279, -1.629)
	self.stances.shrew.steelsight.shoulders.translation = Vector3(-8.57357, -21.279, 3.43498)

	self.stances.slap.standard.shoulders.translation = Vector3(-2.627, -10.619, 0.187)
	self.stances.slap.standard.shoulders.rotation = Rotation(-3.3781e-005, -0.000599726, -3)
	self.stances.slap.steelsight.shoulders.translation = Vector3(-11.097, -8.619, 1.837)
	self.stances.slap.steelsight.shoulders.rotation = Rotation(-3.37758e-005, -0.000599141, -1.5)
	self.stances.slap.crouched.shoulders.translation = Vector3(-2.62695, -13.619, 3.187)
	self.stances.slap.crouched.shoulders.rotation = Rotation(-3.37758e-005, -0.000599136, -1)

	self.stances.rota.steelsight.shoulders.translation = Vector3(-11.4444, -3.155, 2.515)
	self.stances.rota.standard.shoulders.translation = Vector3(-0.4444, -1.15507, 0.515)

	self.stances.tti.crouched.shoulders.translation = Vector3(-2.869, -4.853, -0.065)
	self.stances.tti.crouched.shoulders.rotation = Rotation(0.000713286, -0.000348389, -1)
	self.stances.tti.standard.shoulders.translation = Vector3(-2.869, -1.853, -1.065)
	self.stances.tti.standard.shoulders.rotation = Rotation(0, -0.000348389, 0)
	self.stances.tti.steelsight.shoulders.rotation = Rotation(0, 0, -45)
	self.stances.tti.steelsight.shoulders.translation = Vector3(-9.36896, -2.853, 0.935059)
	self.stances.tti.steelsight.shoulders.rotation = Rotation(0, -0.000348389, 5.86957e-005)

end)