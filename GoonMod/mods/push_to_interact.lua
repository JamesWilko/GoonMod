
local interact_menu_id = "goonbase_pushtointeract_menu"

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "PushToInteract"
Mod.Name = "Push to Interact"
Mod.Desc = "Push interact key to toggle interacting with an object."
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Push to Interact
_G.GoonBase.PushToInteract = _G.GoonBase.PushToInteract or {}
GoonBase.PushToInteract.MenuFile = "push_to_interact_menu.txt"
GoonBase.PushToInteract.ForceKeepInteraction = {
	["corpse_alarm_pager"] = true,
	["c4_diffusible"] = true,
	["disarm_bomb"] = true,
}

-- Options
GoonBase.Options.PushToInteract 					= GoonBase.Options.PushToInteract or {}
GoonBase.Options.PushToInteract.Enabled 			= GoonBase.Options.PushToInteract.Enabled or true
GoonBase.Options.PushToInteract.InteractionMinTime 	= GoonBase.Options.PushToInteract.InteractionMinTime or 2
GoonBase.Options.PushToInteract.HoldAllEnabled 		= GoonBase.Options.PushToInteract.HoldAllEnabled or false
GoonBase.Options.PushToInteract.UseStopKey 			= GoonBase.Options.PushToInteract.UseStopKey or false

-- Menu
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	-- Callbacks
	MenuCallbackHandler.TogglePushToInteract = function(this, item)
		GoonBase.Options.PushToInteract.Enabled = item:value() == "on" and true or false
	end

	MenuCallbackHandler.SetPushToInteractMinimumTime = function( this, item )
		GoonBase.Options.PushToInteract.InteractionMinTime = tonumber( item:value() )
	end

	MenuCallbackHandler.ToggleHoldAllInteractions = function( this, item )
		GoonBase.Options.PushToInteract.HoldAllEnabled = item:value() == "on" and true or false
	end

	MenuCallbackHandler.TogglePushInteractUseStopKey = function( this, item )
		GoonBase.Options.PushToInteract.UseStopKey = item:value() == "on" and true or false
	end

	GoonBase.PushToInteract.CancelCurrentInteraction = function( self )
		log("Cancel Interaction")
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. GoonBase.PushToInteract.MenuFile, GoonBase.PushToInteract, GoonBase.Options.PushToInteract )

end)
