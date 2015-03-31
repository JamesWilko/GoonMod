
local Mutator = class(BaseMutator)
Mutator.Id = "Instagib"
Mutator.OptionsName = "Instagib"
Mutator.OptionsDesc = "All weapon damage is amplified to lethal levels."
Mutator.AllPlayersRequireMod = true
BaseMutator.IsAllowedInRandomizer = false

Mutator._RWChkID = "NewRaycastWeaponBase_" .. Mutator.Id
Mutator._RWChkIDPost = "NewRaycastWeaponBase_PostHook_" .. Mutator.Id
Mutator._NPChkID = "NPCRaycastWeaponBase_" .. Mutator.Id
Mutator._SGChkID = "SentryGunWeaponOnPostSetup_" .. Mutator.Id
Mutator._SGWepChkID = "SentryGunWeaponOnApplyDamageMultiplier_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator.Id, function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("NewRaycastWeaponBaseInit", self._RWChkID, function(weapon, unit) 

		Hooks:PostHook(NewRaycastWeaponBase, "_get_current_damage", self._RWChkIDPost, function(self, dmg_mul)
			return math.huge
		end)

	end)

	Hooks:Add("NPCRaycastWeaponBaseInit", self._NPChkID, function(weapon, unit)
		weapon._damage = math.huge
	end)

	Hooks:Add("SentryGunWeaponOnPostSetup", self._SGChkID, function(sentry, setup_data, damage_multiplier)
		sentry._damage = math.huge
	end)

	Hooks:Add("SentryGunWeaponOnApplyDamageMultiplier", self._SGWepChkID, function(sentry, damage, col_ray, from_pos)
		return math.huge
	end)

end

function Mutator:OnDisabled()

	Hooks:Remove(self._RWChkID)
	Hooks:RemovePostHook(self._RWChkIDPost)
	Hooks:Remove(self._NPChkID)
	Hooks:Remove(self._SGChkID)
	Hooks:Remove(self._SGWepChkID)

end
