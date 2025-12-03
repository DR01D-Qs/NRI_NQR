--[[function CriminalsManager:init()
	self._listener_holder = EventListenerHolder:new()

	self:_create_characters()

	self._loadout_map = {}

	self._loadout_slots = {}
	self._loadout_slots[1] = {}
end

function CriminalsManager:_reserve_loadout_for(char)
	print("[CriminalsManager]._reserve_loadout_for", char)

	local char_index = char

	if type(char) == "string" then
		for id, data in pairs(self._characters) do
			if data.name == char then
				char_index = id

				break
			end
		end
	end

	local my_char = self._characters[char_index]
	local slot = self._loadout_map[my_char.name]
	slot = slot and self._loadout_slots[slot]

	if slot and slot.char_index == char_index then
		self._loadout_slots[self._loadout_map[my_char.name] ].char_index = nil
	end

	for i = 1, 1 do
		local data = self._loadout_slots[i]
		local char_data = data and self._characters[data.char_index]

		if slot and (not char_data or not char_data.data.ai or not char_data.taken or data.char_index == char_index) then
			local slot = self._loadout_slots[i]
			slot.char_index = char_index
			self._loadout_map[self._characters[char_index].name] = i

			return managers.blackmarket:henchman_loadout(i, true)
		end
	end

	debug_pause("Failed to reserve loadout!")

	return managers.blackmarket:henchman_loadout(1, true)
end]]