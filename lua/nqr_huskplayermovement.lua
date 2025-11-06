function HuskPlayerMovement:_get_pose_redirect(pose_code)
	if pose_code==3 then self._bleedout = true else self._bleedout = false end
	return pose_code == 1 and "stand" or pose_code == 3 and "bleedout" or "crouch"
end