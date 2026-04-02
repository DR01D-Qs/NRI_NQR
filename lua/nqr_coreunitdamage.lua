Hooks:PostHook(CoreBodyDamage, "init", "nqr_CoreBodyDamage:init", function (self)
	local part = self._body_element
	if part and self._unit:character_damage() then
		if part._name=="body_helmet_glass" then
			part._damage_multiplier = 0.25
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
		self._endurance.bullet._endurance.bullet = 8 --math.round(math.random(5, 10))
	end

	local unit = self._unit and self._unit:name():key()
	if part._name=="held_body" and (unit=="5deefee472c1903d" or unit=="e26c602b7a43d7bb") then
		self._endurance.damage._endurance = { explosion = 10, damage = 50 }
		self._endurance.damage._next.damage._endurance = { explosion = 10, damage = 100 }
		self._endurance.damage._next.damage._next.damage._endurance = { explosion = 10, damage = 150 }
		self._endurance.damage._next.damage._next.damage._next.damage._endurance = { explosion = 10, damage = 200 }
		self._endurance.damage._next.damage._next.damage._next.damage._next.damage._endurance = { explosion = 10, damage = 250 }
		self._endurance.damage._next.damage._next.damage._next.damage._next.damage._next.damage._endurance = { explosion = 10, damage = 300 }
		self._endurance.damage._next.damage._next.damage._next.damage._next.damage._next.damage._next.damage._endurance = { explosion = 10, damage = 350 }
	end
end)
