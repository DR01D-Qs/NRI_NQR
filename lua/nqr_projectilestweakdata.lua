Hooks:PostHook( BlackMarketTweakData, "_init_projectiles", "nqr_projectilestweakdata:_init_projectiles", function(self, tweak_data)
    self.projectiles.wpn_prj_jav = nil



    self.projectiles.wpn_prj_target.max_amount = 3
    self.projectiles.wpn_prj_target.add_trail_effect = nil

    self.projectiles.wpn_prj_four.max_amount = 9
    self.projectiles.wpn_prj_four.add_trail_effect = nil

    self.projectiles.wpn_prj_ace.max_amount = 9
    self.projectiles.wpn_prj_ace.add_trail_effect = nil

    self.projectiles.wpn_prj_hur.max_amount = 2
    self.projectiles.wpn_prj_hur.add_trail_effect = nil

    self.projectiles.molotov.max_amount = 2

    self.projectiles.dynamite.max_amount = 2

    self.projectiles.fir_com.max_amount = 3

    self.projectiles.concussion.max_amount = 3
    self.projectiles.concussion.animation = "throw_grenade"
    self.projectiles.concussion.anim_global_param = "projectile_frag"
    self.projectiles.concussion.throw_allowed_expire_t = 0.1
    self.projectiles.concussion.expire_t = 1.1
    self.projectiles.concussion.repeat_expire_t = 1.5
    self.projectiles.concussion.impact_detonation = true

    self.projectiles.smoke_screen_grenade.ability = nil
    self.projectiles.smoke_screen_grenade.base_cooldown = nil
    self.projectiles.smoke_screen_grenade.max_amount = 3
    self.projectiles.smoke_screen_grenade.throw_allowed_expire_t = 0.1
    self.projectiles.smoke_screen_grenade.expire_t = 1.1
    self.projectiles.smoke_screen_grenade.repeat_expire_t = 1.5
    self.projectiles.smoke_screen_grenade.no_shouting = nil

    self.projectiles.chico_injector.ability = nil
    self.projectiles.chico_injector.base_cooldown = nil
    self.projectiles.chico_injector.max_amount = 3
    self.projectiles.chico_injector.throw_allowed_expire_t = 0.1
    self.projectiles.chico_injector.expire_t = 1.1
    self.projectiles.chico_injector.repeat_expire_t = 1.5

    self.projectiles.pocket_ecm_jammer.ability = nil
    self.projectiles.pocket_ecm_jammer.base_cooldown = nil
    self.projectiles.pocket_ecm_jammer.max_amount = 5
    self.projectiles.pocket_ecm_jammer.throw_allowed_expire_t = 0.1
    self.projectiles.pocket_ecm_jammer.expire_t = 1.1
    self.projectiles.pocket_ecm_jammer.repeat_expire_t = 1.5

    self.projectiles.copr_ability.ability = nil
    self.projectiles.copr_ability.base_cooldown = nil
    self.projectiles.copr_ability.max_amount = 5
    self.projectiles.copr_ability.throw_allowed_expire_t = 0.1
    self.projectiles.copr_ability.expire_t = 1.1
    self.projectiles.copr_ability.repeat_expire_t = 1.5

    self.projectiles.tag_team.ability = nil
    self.projectiles.tag_team.base_cooldown = nil
    self.projectiles.tag_team.max_amount = 5
    self.projectiles.tag_team.throw_allowed_expire_t = 0.1
    self.projectiles.tag_team.expire_t = 1.1
    self.projectiles.tag_team.repeat_expire_t = 1.5

    self.projectiles.damage_control.ability = nil
    self.projectiles.damage_control.base_cooldown = nil
    self.projectiles.damage_control.max_amount = 5
    self.projectiles.damage_control.throw_allowed_expire_t = 0.1
    self.projectiles.damage_control.expire_t = 1.1
    self.projectiles.damage_control.repeat_expire_t = 1.5

    self.projectiles.wpn_gre_electric.throwable = nil
    self.projectiles.wpn_gre_electric.max_amount = 3

    self.projectiles.poison_gas_grenade.throwable = nil
    self.projectiles.poison_gas_grenade.max_amount = 3
    self.projectiles.poison_gas_grenade.no_shouting = nil



    self.projectiles.launcher_frag.time_cheat = 0.2
    self.projectiles.launcher_incendiary.time_cheat = 0.2
    self.projectiles.launcher_frag_m32.time_cheat = 0.2
    self.projectiles.launcher_incendiary_m32.time_cheat = 0.2
    self.projectiles.launcher_frag_arbiter.time_cheat = 0.15
    self.projectiles.launcher_incendiary_arbiter.time_cheat = 0.15
    self.projectiles.rocket_frag.time_cheat = 0.45
    self.projectiles.rocket_ray_frag.time_cheat = 0.45
end)
