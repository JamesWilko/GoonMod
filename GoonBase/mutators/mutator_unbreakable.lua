----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "Unbreakable"
Mutator.OptionsName = "Unbreakable"
Mutator.OptionsDesc = "Enemies can not be staggered or stunned"

Mutator._CopDamageInit = "CopDamagePostInitialize_" .. Mutator:ID()

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("CopDamagePostInitialize", self._CopDamageInit, function(weapon, unit)
		CopDamage._hurt_severities = {
			none = false,
			light = false,
			moderate = false,
			heavy = false,
			explode = false
		}
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self._CopDamageInit)
end
-- END OF FILE
