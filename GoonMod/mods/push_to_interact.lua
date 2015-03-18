
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
local PushToInteract = GoonBase.PushToInteract
PushToInteract.MenuFile = "push_to_interact_menu.txt"
PushToInteract.ForceKeepInteraction = {
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

	PushToInteract.CancelCurrentInteraction = function( self )

		if managers.player and managers.player:local_player() then
			local ply = managers.player:local_player():movement()._current_state
			if ply and ply:_interacting() and PushToInteract:ShouldUseStopKey() then
				ply:_interupt_action_interact()
			end
		end

	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. PushToInteract.MenuFile, PushToInteract, GoonBase.Options.PushToInteract )
end)

-- Hooks
Hooks:Add("PlayerStandardCheckActionInteract", "PlayerStandardCheckActionInteract_PushToInteract", function(ply, t, input)		

	if not PushToInteract:IsEnabled() then
		return nil
	end

	if input.btn_interact_press then

		if ply:_interacting() and not PushToInteract:ShouldUseStopKey() then
			ply:_interupt_action_interact()
			return false
		end

	elseif input.btn_interact_release then

		local data = nil
		if managers.interaction and alive( managers.interaction:active_object() ) then
			data = managers.interaction:active_object():interaction().tweak_data
		end

		if PushToInteract:ShouldHoldInteraction( data ) then
			return false
		end

	end

end)

function PushToInteract:IsEnabled()
	return GoonBase.Options.PushToInteract.Enabled or true
end

function PushToInteract:ShouldHoldAllInteractions()
	return GoonBase.Options.PushToInteract.HoldAllEnabled or false
end

function PushToInteract:MinimumInteractionTime()
	return GoonBase.Options.PushToInteract.InteractionMinTime or 2
end

function PushToInteract:ShouldUseStopKey()
	return GoonBase.Options.PushToInteract.UseStopKey or false
end

function PushToInteract:ShouldHoldInteraction( interaction_data )

	if PushToInteract:IsEnabled() and interaction_data then
		local hold_all = PushToInteract:ShouldHoldAllInteractions()
		local interaction = (interaction_data.timer or 10) >= PushToInteract:MinimumInteractionTime()
		local forced_hold = PushToInteract.ForceKeepInteraction[ interaction_data ]
		return hold_all or interaction or forced_hold
	end

end
