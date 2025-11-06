Hooks:PostHook(CoreBodyDamage, "init", "nqr_CoreBodyDamage:init", function (self)
	local part = self._body_element
	--Utils.PrintTable(part)
	if part and self._unit:character_damage() then
		if part._name=="body_helmet_glass" then
			part._damage_multiplier = 0.25 or 0.15
		elseif part._name=="body_helmet_plate" then
			part._damage_multiplier = 0.15
		elseif part._name=="body_armor_neck" or part._name=="body_armor_throat" then
			part._damage_multiplier = 0.15
		elseif part._name=="body_armor_chest" or part._name=="body_armor_stomache" or part._name=="body_armor_back" then
			part._damage_multiplier = 0.03
		end
	end

	if part
	and string.find(part._name, "door_handle")
	and self._endurance
	and self._endurance.bullet
	and self._endurance.bullet._endurance
	then
		self._endurance.bullet._endurance.bullet = math.round(math.random(5, 10))
	end
end)
