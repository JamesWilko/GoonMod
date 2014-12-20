----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "Instagib"
Mutator.OptionsName = "Instagib"
Mutator.OptionsDesc = "All weapon damage is amplified to lethal levels"
Mutator.AllPlayersRequireMod = true

Mutator._RWChkID = "NewRaycastWeaponBase_" .. Mutator.Id
Mutator._RWChkIDPost = "NewRaycastWeaponBase_PostHook_" .. Mutator.Id
Mutator._NPChkID = "NPCRaycastWeaponBase_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator.Id, function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("NewRaycastWeaponBaseInit", self._RWChkID, function(weapon, unit) 

		Hooks:PostHook(NewRaycastWeaponBase, self._RWChkIDPost, function(self, dmg_mul)
			return math.huge
		end)

	end)

	Hooks:Add("NPCRaycastWeaponBaseInit", self._NPChkID, function(weapon, unit)
		weapon._damage = math.huge
	end)

end

function Mutator:OnDisabled()

	Hooks:Remove(self._RWChkID)
	Hooks:RemovePostHook(self._RWChkIDPost)
	Hooks:Remove(self._NPChkID)

end

-- END OF FILE
