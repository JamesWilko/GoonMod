----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 01/22/2015 15:34:00 PM
-- Copyright 2014 - 2015, Bruce Li, James Wilkinson, Overkill Software
----------

local Mutator = class(BaseMutator)
Mutator.Id = "HellStealth"
Mutator.OptionsName = "Stealth in the hell"
Mutator.OptionsDesc = "Prepare to be suprised in stealth"

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_HellStealth", function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

Mutator.Units = {}
Mutator.Units.Sec = "CharacterTweakDataPostInitSecurity_" .. Mutator.Id
Mutator.Units.Cop = "CharacterTweakDataPostInitCop_" .. Mutator.Id
Mutator.Tweak = "TweakDataPostInit_" .. Mutator.Id
Mutator.Mission = "BaseInteractionExtPostStart_" .. Mutator.Id

function Spawn_Clk(pos)
   local clker = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1" )
   local unit = World:spawn_unit(clker, Vector3(), Rotation())
   unit:brain():set_logic("inactive", nil)
   unit:movement():set_position(pos)
   unit:brain():set_logic("attack", nil)
end

function Spawn_Taser(pos)
   local clker = Idstring( "units/payday2/characters/ene_tazer_1/ene_tazer_1" )
   local unit = World:spawn_unit(clker, Vector3(), Rotation())
   unit:brain():set_logic("inactive", nil)
   unit:movement():set_position(pos)
   unit:brain():set_logic("attack", nil)
end

function Die(pos)
   local clker = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1" )
   local unit = World:spawn_unit(clker, Vector3(), Rotation(270))
   unit:movement():set_position(pos)
   unit:brain():set_logic("attack", nil)

--   unit:brain():set_logic("attack", nil)
end

function Mutator:OnEnabled()
   io.stderr:write("HellStealth enabled\n")
   Hooks:Add("CharacterTweakDataPostInitSecurity", self.Units.Sec, function(data, presets)
                io.stderr:write("Set security health to 200\n")
                data.security.HEALTH_INIT = 200
   end)
   Hooks:Add("CharacterTweakDataPostInitCop", self.Units.Cop, function(data, presets)
                io.stderr:write("Set cop health to 200\n")
   end)

   Hooks:Add("PlayerTweakDataPostInit", self.Tweak, function(data)
                io.stderr:write("Reduce pagers to 2\n")
                data.alarm_pager.bluff_success_chance = {1, 1, 0, 0, 0}
   end)

   Hooks:Add("BaseInteractionExtPostStart", self.Mission, function(interact, player)
                local pos = interact._unit:position()

                local current_level = managers.job:current_level_id()
                local idstr = interact._unit:name():t()
                io.stderr:write("[Interact] " .. current_level .. " " .. interact._unit:name():t() .. "\n")
                if current_level == "framing_frame_1" then
                   if idstr == "@ID5422d8b99c7c1b57@" then -- Keycard
                      Die(pos)
                   end
                   if idstr == "@IDdeeb533605a7f83b@" then -- A random painting
                      if math.random() < 0.1 then
                         Die(pos)
                      end
                   end
                end

                if current_level == "framing_frame_2" then
                   if idstr == "@IDdd162740788712c8@" then -- Money
                      Die(pos)
                   end
                end

                if current_level == "framing_frame_3" then
                   if idstr == "@ID24118b6b9d2f5f81@" then -- Computer
                      Die(pos)
                   end
                   if idstr == "@ID54e8d784dbceaf07@" then -- HDD
                      Spawn_Clk(pos)
                   end
                   if idstr == "@IDd904ebd1e81458a8@" then -- Computer on Roof
                      Spawn_Clk(pos)
                   end
                end
   end)
   --[[
   Hooks:Add("TweakDataPostInit", self.Tweak, function()
                io.stderr:write("Reduce pagers to 2\n")
                tweak_data.player.alarm_pager.bluff_success_chance = {1, 1, 0, 0, 0}

                -- Framing frame day 3
                if managers.job:current_level_id() == "framing_frame_3" then
                   for _,v in pairs(managers.mission._scripts.default._elements) do

                      -- sudden death upon picking up gold
                      if v._values and v._values.trigger_list
                         and v._values.trigger_list[1]
                         and (v._values.trigger_list[1].notify_unit_sequence == "state_zipline_enable")
                      then
                         v._values.on_executed = function(unit)
                            io.stderr:write("Sudden death!\n")
                            player = managers.player:player_unit()
                            player:character_damage():set_health(0)
                            player:character_damage():_check_bleed_out(false)
                         end
                      end

                      -- spawn cloakers in vault
                      if v._editor_name and string.sub(v._editor_name, 1, -2) == "spawnLootInVault"
                      then
                         v.orig_on_executed = v._values.on_executed
                         v.on_executed = function(unit)
                            io.stderr:write("spawn cloaker!\n")
                            local unitName = Idstring( "units/payday2/characters/ene_spook_1/ene_spook_1")
                            World:spawn_unit(unitName, v._values.position, v._values.rotation)
                            v.orig_on_executed(unit)
                         end
                      end
                   end
                end

   end)
   --]]
end

function Mutator:OnDisabled()
   Hooks:Remove(self.Units.Sec)
   Hooks:Remove(self.Units.Cop)
   Hooks:Remove(self.Tweak)
end
-- END OF FILE
