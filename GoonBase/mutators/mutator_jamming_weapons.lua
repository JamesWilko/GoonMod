----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "WeaponsJam"
Mutator.OptionsName = "Crappy Weapons"
Mutator.OptionsDesc = "You thought the drills were bad? Weapons randomly jam when firing!"
Mutator.AllPlayersRequireMod = true

Mutator._WeaponFirehkID = "NewRaycastWeaponBase_" .. Mutator.Id
Mutator._WeaponFirehkIDPost = "NewRaycastWeaponBase_Post_" .. Mutator.Id

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator.Id, function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()

	Hooks:Add("NewRaycastWeaponBaseInit", self._WeaponFirehkID, function(weapon, unit) 

		Hooks:PostHook(NewRaycastWeaponBase, self._WeaponFirehkIDPost, function(weapon, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
			local roll = math.rand(1)
			local chance = 0.05
			local gun = weapon.parent_weapon and weapon.parent_weapon:base() or weapon
			if roll < chance then
				gun:set_ammo_remaining_in_clip(0)
				--one day we'll mosin ping sound but until then, EXPLOSIONSSSSSSSSSS
				managers.explosion:play_sound_and_effects(weapon._unit:get_object(Idstring("a_shell")):position(), Vector3(), 0)
			end
		end)

	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self._WeaponFirehkID)
	Hooks:RemovePostHook(self._WeaponFirehkIDPost)
end

-- END OF FILE
