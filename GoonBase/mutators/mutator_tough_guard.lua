----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 01/22/2015 15:34:00 PM
-- Copyright 2014 - 2015, Bruce Li, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "ToughGuard"
Mutator.OptionsName = "Dozer Guard!"
Mutator.OptionsDesc = "Guards are tough as rock. I would bring a Thanatos for stealth!"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_HellStealth", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.Units = {}
Mutator.Units.Sec = "CharacterTweakDataPostInitSecurity_" .. Mutator.Id

function Mutator:OnEnabled()
   Print("Tough guard  enabled\n")
   Hooks:Add("CharacterTweakDataPostInitSecurity", self.Units.Sec, function(data, presets)
                io.stderr:write("Set security health to 200\n")
                data.security.HEALTH_INIT = 200
   end)
end

function Mutator:OnDisabled()
   Hooks:Remove(self.Units.Sec)
end
-- END OF FILE
