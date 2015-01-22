----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "HellStealth"
Mutator.OptionsName = "Stealth in the hell"
Mutator.OptionsDesc = "Prepare to be suprised in stealth"
Mutator.AllPlayersRequireMod = true

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_HellStealth", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.Units = {}
Mutator.Units.Sec = "CharacterTweakDataPostInitSecurity_" .. Mutator::ID()
Mutator.Tweak = "TweakDataPostInit_" .. Mutator::ID()

function Mutator:OnEnabled()
   io.stderr:write("HellStealth enabled\n")
   Hooks:Add("CharacterTweakDataPostInitSecurity", self.Units.Sec, function(data, presets)
                io.stderr:write("Set security health to 200\n")
                data.security.HEALTH_INT = 200
   end)
   Hooks:Add("TweakDataPostInit", self.Tweak, function()
                io.stderr:write("Reduce pagers to 2\n")
                tweak_data.player.alarm_pager.bluff_success_chance = {1, 1, 0, 0, 0}
   end)
end

function Mutator:OnDisabled()
   Hooks:Remove(self.Units.Sec)
   Hooks:Remove(self.Tweak)
end
-- END OF FILE
