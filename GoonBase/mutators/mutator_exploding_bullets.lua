----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "AllBulletsExplode"
Mutator.OptionsName = "4th of July"
Mutator.OptionsDesc = "Every bullet explodes and every person has them"
Mutator.AllPlayersRequireMod = true

Mutator._WeaponBaseInit = "NewRaycastWeaponBaseInit_" .. Mutator:ID()
Mutator._CopDamage = "CopDamagePreDamageExplosion_" .. Mutator:ID()
Mutator._EnemyDamageMulitplier = 10

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("NewRaycastWeaponBaseInit", self._WeaponBaseInit, function(weapon, unit)

		tweak_data.upgrades.explosive_bullet.curve_pow_orig = tweak_data.upgrades.explosive_bullet.curve_pow
		tweak_data.upgrades.explosive_bullet.player_dmg_mul_orig = tweak_data.upgrades.explosive_bullet.player_dmg_mul
		tweak_data.upgrades.explosive_bullet.range_orig = tweak_data.upgrades.explosive_bullet.range

		InstantExplosiveBulletBase.CURVE_POW = tweak_data.upgrades.explosive_bullet.curve_pow
		InstantExplosiveBulletBase.PLAYER_DMG_MUL = tweak_data.upgrades.explosive_bullet.player_dmg_mul * 4
		InstantExplosiveBulletBase.RANGE = tweak_data.upgrades.explosive_bullet.range * 1.5

		InstantBulletBase.CURVE_POW = tweak_data.upgrades.explosive_bullet.curve_pow_orig
		InstantBulletBase.PLAYER_DMG_MUL = tweak_data.upgrades.explosive_bullet.player_dmg_mul_orig
		InstantBulletBase.RANGE = tweak_data.upgrades.explosive_bullet.range_orig
		InstantBulletBase.EFFECT_PARAMS = clone( InstantExplosiveBulletBase.EFFECT_PARAMS )

		InstantBulletBase.on_collision = function(bullet, col_ray, weapon_unit, user_unit, damage, blank)
			if damage then
				damage = damage * Mutator._EnemyDamageMulitplier
			end
			InstantExplosiveBulletBase.on_collision(bullet, col_ray, weapon_unit, user_unit, damage, blank)
		end
		InstantBulletBase.on_collision_client = InstantExplosiveBulletBase.on_collision_client

	end)

	Hooks:Add("CopDamagePreDamageExplosion", self._CopDamage, function(cop, attack_data)

		if attack_data.attacker_unit and attack_data.attacker_unit:movement() then
			local same_team = attack_data.attacker_unit:movement():team().id == "law1"
			if same_team then
				return true
			end
		end
		attack_data.damage = attack_data.damage / Mutator._EnemyDamageMulitplier

	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self._WeaponBaseInit)
	Hooks:Remove(self._CopDamage)
end

-- END OF FILE
