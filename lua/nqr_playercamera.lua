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



local camera_mvec = Vector3()
local reticle_mvec = Vector3()
function PlayerCamera:forward_with_shake_toward_reticle(reticle_obj, is_holo)
	self._camera_object:m_position(camera_mvec)

	local target_pos = reticle_mvec
	local forward_dir = Vector3()

	if alive(reticle_obj) then
		reticle_obj:m_position(reticle_mvec)
		forward_dir = reticle_obj:rotation():y()
		if is_holo then mvector3.add_scaled(reticle_mvec, forward_dir, 500) end
	else
		local weapon_unit = managers.player:equipped_weapon_unit()
		if alive(weapon_unit) then
			local fire_obj = weapon_unit:get_object(Idstring("fire")) or weapon_unit:orientation_object()
			fire_obj:m_position(reticle_mvec)
			forward_dir = fire_obj:rotation():y()
			mvector3.add_scaled(reticle_mvec, forward_dir, 500)
		else
			return self._camera_object:rotation():y()
		end
	end

	mvector3.subtract(reticle_mvec, camera_mvec)
	mvector3.normalize(reticle_mvec)

	return reticle_mvec
end