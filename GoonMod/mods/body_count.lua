
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "BodyCountMod"
Mod.Name = "Corpse Delimiter"
Mod.Desc = "Change the amount of bodies that can appear after enemies are killed."
Mod.Requirements = {}
Mod.Incompatibilities = {}
Mod.EnabledByDefault = true

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Body Count Mod
_G.GoonBase.CorpseDelimiter = _G.GoonBase.CorpseDelimiter or {}
GoonBase.CorpseDelimiter.MenuFile = "corpse_mod_menu.txt"

-- Options
GoonBase.Options.BodyCount = GoonBase.Options.BodyCount or {}
GoonBase.Options.BodyCount.UseCustomCorpseLimit 	= GoonBase.Options.BodyCount.UseCustomCorpseLimit or true
GoonBase.Options.BodyCount.MaxCorpses 				= GoonBase.Options.BodyCount.MaxCorpses or 256
GoonBase.Options.BodyCount.RemoveShields 			= GoonBase.Options.BodyCount.RemoveShields or false
GoonBase.Options.BodyCount.RemoveShieldsTime 		= GoonBase.Options.BodyCount.RemoveShieldsTime or 120

-- Stop bodies from despawning
Hooks:Add("EnemyManagerPreUpdateCorpseDisposal", "EnemyManagerPreUpdateCorpseDisposal_BodyCount", function(enemy_manager)
	enemy_manager._MAX_NR_CORPSES = GoonBase.Options.BodyCount.UseCustomCorpseLimit and GoonBase.Options.BodyCount.MaxCorpses or 8
end)

-- Despawn shields after time
local shield_timer_id = 0
Hooks:Add("CopInventoryDropShield", "CopInventoryDropShield_BodyCount", function(inventory)

	if GoonBase.Options.BodyCount.UseCustomCorpseLimit and GoonBase.Options.BodyCount.RemoveShields then

		local id = "CopInventoryDropShield_" .. tostring(shield_timer_id)
		shield_timer_id = shield_timer_id + 1

		Queue:Add(id, function()
			if inventory ~= nil then
				inventory:destroy_all_items()
			end
		end, GoonBase.Options.BodyCount.RemoveShieldsTime)

	end

end)

-- Menu
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	-- Callbacks
	MenuCallbackHandler.ToggleCorpseLimit = function(this, item)
		GoonBase.Options.BodyCount.UseCustomCorpseLimit = item:value() == "on" and true or false
	end

	MenuCallbackHandler.SetMaximumCorpseAmount = function(this, item)
		GoonBase.Options.BodyCount.MaxCorpses = math.floor( item:value() )
	end

	MenuCallbackHandler.ToggleDespawnShields = function(this, item)
		GoonBase.Options.BodyCount.RemoveShields = item:value() == "on" and true or false
	end

	MenuCallbackHandler.SetShieldDespawnTime = function(this, item)
		GoonBase.Options.BodyCount.RemoveShieldsTime = math.floor( item:value() )
	end

	GoonBase.CorpseDelimiter.DoRemoveAllCorpses = function(self)
		managers.enemy:dispose_all_corpses()
	end

	GoonBase.CorpseDelimiter.DoRemoveAllShields = function(self)

		local enemy_data = managers.enemy._enemy_data
		local corpses = enemy_data.corpses
		for u_key, u_data in pairs(corpses) do
			if u_data.unit:inventory() ~= nil then
				u_data.unit:inventory():destroy_all_items()
			end
		end

	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. GoonBase.CorpseDelimiter.MenuFile, GoonBase.CorpseDelimiter, GoonBase.Options.BodyCount )

end)
