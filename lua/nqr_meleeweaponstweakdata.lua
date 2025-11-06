Hooks:PostHook( BlackMarketTweakData, "_init_melee_weapons", "nqr_BlackMarketTweakData:_init_melee_weapons", function(self, tweak_data)

    self.melee_weapons.weapon.instant = true
    self.melee_weapons.weapon.stats = {
        min_damage = 3,
        max_damage = 3,
        min_damage_effect = 1,
        max_damage_effect = 1,
        charge_time = 1,
        range = 120,
        weapon_type = "blunt"
    }
    self.melee_weapons.weapon.expire_t = 0.3
    self.melee_weapons.weapon.repeat_expire_t = 0.3
    self.melee_weapons.weapon.melee_damage_delay = 0

end)