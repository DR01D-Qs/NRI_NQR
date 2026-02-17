NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "NQR"
NetworkMatchMakingEPIC._BUILD_SEARCH_INTEREST_KEY = "NQR"



function NetworkManager:init()
	self.OVERWRITEABLE_MSGS = {
		set_look_dir = {
			clbk = NetworkManager.clbk_msg_overwrite
		},
		criminal_hurt = {
			clbk = PlayerDamage.clbk_msg_overwrite_criminal_hurt,
			indexes = {}
		},
		suspicion = {
			clbk = PlayerMovement.clbk_msg_overwrite_suspicion,
			indexes = {}
		}
	}
	self._event_listener_holder = EventListenerHolder:new()

	if SystemInfo:platform() == Idstring("PS3") then
		self._is_ps3 = true
	elseif SystemInfo:platform() == Idstring("X360") then
		self._is_x360 = true
	elseif SystemInfo:platform() == Idstring("PS4") then
		self._is_ps4 = true
	elseif SystemInfo:platform() == Idstring("XB1") then
		self._is_xb1 = true
	else
		self._is_win32 = true
	end

	self._spawn_points = {}

	if self._is_ps3 then
		Network:set_use_psn_network(true)

		if #PSN:get_world_list() == 0 then
			PSN:init_matchmaking()
		end

		self:_register_PSN_matchmaking_callbacks()
	elseif self._is_ps4 then
		Network:set_use_psn_network(true)

		if #PSN:get_world_list() == 0 then
			PSN:init_matchmaking()
		end

		self:_register_PSN_matchmaking_callbacks()
	elseif self._is_xb1 then
		self.account = NetworkAccountXBL:new()
		self.voice_chat = NetworkVoiceChatXBL:new()
	elseif self._is_win32 then
		if SystemInfo:distribution() == Idstring("STEAM") then
			self.account = NetworkAccountSTEAM:new()
			self.voice_chat = NetworkVoiceChatSTEAM:new()
		elseif SystemInfo:distribution() == Idstring("EPIC") then
			self.account = NetworkAccountEPIC:new()
			self.voice_chat = NetworkVoiceChatDisabled:new()
		else
			self.account = NetworkAccount:new()
			self.voice_chat = NetworkVoiceChatDisabled:new()
		end
	elseif self._is_x360 then
		self.account = NetworkAccountXBL:new()
		self.voice_chat = NetworkVoiceChatXBL:new()
	end

	self._started = false
	managers.network = self

	self:_create_lobby()
	self:load()
end