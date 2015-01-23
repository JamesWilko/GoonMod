----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 01/22/2015 15:34:00 PM
-- Copyright 2014 - 2015, Bruce Li, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "LimitedPager"
Mutator.OptionsName = "Clever Communicators"
Mutator.OptionsDesc = "The pager communicators only believe you twice"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_LimitedPager", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.Pager = "PagerTweakDataPostInit_" .. Mutator.Id

function Mutator:OnEnabled()
   io.stderr:write("Clever communicators enabled\n")
   Hooks:Add("PlayerTweakDataPostInit", self.Pager, function(data)
                io.stderr:write("Reduce pagers to 2\n")
                data.alarm_pager.bluff_success_chance = {1, 1, 0, 0, 0}
   end)
end

function Mutator:OnDisabled()
   Hooks:Remove(self.Pager)
end
-- END OF FILE
