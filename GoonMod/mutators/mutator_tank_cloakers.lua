
local Mutator = class(BaseMutator)
Mutator.Id = "BulldozerCloakers"
Mutator.OptionsName = "Bulldozers are Cloakers"
Mutator.OptionsDesc = "Bulldozers will charge and jump kick you"
Mutator.AllPlayersRequireMod = true

Mutator.HookTankData = "CharacterTweakDataPostInitTank_BulldozerCloakers"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_AllTaserSpawns", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("CharacterTweakDataPostInitTank", self.HookTankData, function(data, presets)
		data.spooc.spooc_attack_timeout = {10, 10}
		data.spooc.spooc_attack_beating_time = {3, 3}
		data.spooc.spooc_attack_use_smoke_chance = 1
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.HookTankData)
end
