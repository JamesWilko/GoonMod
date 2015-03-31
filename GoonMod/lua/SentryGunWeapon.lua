
CloneClass( SentryGunWeapon )

Hooks:RegisterHook("SentryGunWeaponOnPostSetup")
function SentryGunWeapon.setup( self, setup_data, damage_multiplier )
	self.orig.setup( self, setup_data, damage_multiplier )
	Hooks:Call( "SentryGunWeaponOnPostSetup", self, setup_data, damage_multiplier )
end

Hooks:RegisterHook("SentryGunWeaponOnApplyDamageMultiplier")
function SentryGunWeapon._apply_dmg_mul( self, damage, col_ray, from_pos )
	local val = Hooks:ReturnCall("SentryGunWeaponOnApplyDamageMultiplier", self, damage, col_ray, from_pos)
	return val or self.orig._apply_dmg_mul( self, damage, col_ray, from_pos )
end
