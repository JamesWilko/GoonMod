----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 01/22/2015 15:34:00 PM
-- Copyright 2014 - 2015, Bruce Li, James Wilkinson, Overkill Software
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

                -- Framing frame day 3
                if managers.job:current_level_id() == "framing_frame_3" then
                   for k,v in pairs(managers.mission._scripts.default._elements) do

                      -- sudden death upon picking up gold
                      if v._values and v._values.trigger_list
                         and v._values.trigger_list[1]
                         and (v._values.trigger_list[1].notify_unit_sequence == "state_zipline_enable")
                      then
                         v._values.on_executed = function(unit)
                         end
                      end

                      -- spawn cloakers in vault
                      if v._editor_name and string.sub(v._editor_name, 1, -2) == "spawnLootInVault"
                      then
                         v._values.orig_on_executed = v._values.on_executed
                         v._values.on_executed = function(unit)
                            local unitName = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1")
                            World:spawn_unit(unitName, v._values.position, v._values.rotation)
                            v._values.orig_on_executed(unit)
                         end
                      end
                   end
                end

   end)
end

function Mutator:OnDisabled()
   Hooks:Remove(self.Units.Sec)
   Hooks:Remove(self.Tweak)
end
-- END OF FILE
