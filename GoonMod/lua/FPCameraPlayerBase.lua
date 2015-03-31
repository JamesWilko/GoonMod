
CloneClass( FPCameraPlayerBase )

Hooks:RegisterHook("FPCameraPlayerBaseOnSpawnMeleeItem")
function FPCameraPlayerBase.spawn_melee_item( self )
	self.orig.spawn_melee_item( self )
	Hooks:Call( "FPCameraPlayerBaseOnSpawnMeleeItem", self, self._melee_item_units )
end

Hooks:RegisterHook("FPCameraPlayerBaseStanceEnteredCallback")
function FPCameraPlayerBase.clbk_stance_entered(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
	Hooks:Call( "FPCameraPlayerBaseStanceEnteredCallback", self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration )
	self.orig.clbk_stance_entered(self, new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
end
