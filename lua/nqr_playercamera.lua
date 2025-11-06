require("lib/units/cameras/ScopeCamera")

PlayerCamera = PlayerCamera or class()
PlayerCamera.IDS_NOTHING = Idstring("")

function PlayerCamera:init(unit)
	self._unit = unit
	self._m_cam_rot = unit:rotation()
	self._m_cam_pos = unit:position() + math.UP * 140
	self._m_cam_fwd = self._m_cam_rot:y()
	self._m_cam_right = self._m_cam_rot:x()
	self._camera_object = World:create_camera()

	self._camera_object:set_near_range(2)
	self._camera_object:set_far_range(250000)
	self._camera_object:set_fov(75)
	self:spawn_camera_unit()
	self:_setup_sound_listener()

	self._sync_dir = {
		pitch = 0,
		yaw = unit:rotation():yaw()
	}
	self._last_sync_t = 0

	self:setup_viewport(managers.player:viewport_config())

	if _G.IS_VR then
		self._scope_camera = ScopeCamera:new(self)
	end
end

function PlayerCamera:nqr_play_anim(anim)
	self._camera_unit:base():nqr_play_anim(anim)
end