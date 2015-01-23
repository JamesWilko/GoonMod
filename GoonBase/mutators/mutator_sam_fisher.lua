----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 01/22/2015 15:34:00 PM
-- Copyright 2014 - 2015, Bruce Li, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "SamFisherInteraction"
Mutator.OptionsName = "Sam Fisher Trigger"
Mutator.OptionsDesc = "Interacting with things have 10% possibility to spawn cloakers"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_HellStealth", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.SpawnClk = "BaseInteractionExtPostStart_" .. Mutator.Id

function Spawn_Clk(pos)
   local clker = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1" )
   local unit = World:spawn_unit(clker, Vector3(), Rotation())
   unit:brain():set_logic("inactive", nil)
   unit:movement():set_position(pos)
   unit:brain():set_logic("attack", nil)
end

function Mutator:OnEnabled()
   _G.Print("Sam Fisher Here\n")

   Hooks:Add("BaseInteractionExtPostStart", self.SpawnClk, function(interact, player)
                local pos = interact._unit:position()
                if math.random() < 0.1 then
                   Spawn_Clk(pos)
                end
   end)
end

function Mutator:OnDisabled()
   Hooks:Remove(self.SpawnClk)
end
-- END OF FILE
