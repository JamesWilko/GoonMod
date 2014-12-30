----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( FPCameraPlayerBase )

Hooks:RegisterHook("FPCameraBaseStanceEnteredCallback")
function FPCameraPlayerBase.clbk_stance_entered(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
	Hooks:Call( "FPCameraBaseStanceEnteredCallback", self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration )
	self.orig.clbk_stance_entered(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
end
-- END OF FILE
