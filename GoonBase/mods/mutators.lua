----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/6/2014 12:06:38 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GameplayMutators"
Mod.Name = "Mutators"
Mod.Desc = "Micro-gameplay mods that give you new gameplay modes and experiences"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Mutators
_G.GoonBase.Mutators = _G.GoonBase.Mutators or {}
local Mutators = _G.GoonBase.Mutators
Mutators.MenuID = "goonbase_mutators_menu"
Mutators.LoadedMutators = Mutators.LoadedMutators or {}
Mutators.ActiveMutators = Mutators.ActiveMutators or {}

-- Paths
Mutators.MutatorsPath = "/"
Mutators.MutatorsList = {
	"mutators/base_mutator.lua",
	"mutators/mutator_all_bulldozers.lua",
	"mutators/mutator_all_cloakers.lua",
	"mutators/mutator_all_shields.lua",
	"mutators/mutator_all_tazers.lua",
	"mutators/mutator_insane_spawnrate.lua",
	"mutators/mutator_insane_spawnrate_cops.lua",
	"mutators/mutator_lightning_speed.lua",
	"mutators/mutator_suicidal_spawnrate.lua",
	"mutators/mutator_suicidal_spawnrate_cops.lua",
}
Mutators.MenuPrefix = "toggle_mutator_"

-- Localization
local Localization = GoonBase.Localization
Localization.Mutators_OptionsName = "Mutators"
Localization.Mutators_OptionsDesc = "Control active gameplay Mutators"
Localization.Mutators_OptionsIngameName = "Mutators"
Localization.Mutators_OptionsIngameDesc = "Control active gameplay Mutators (Changes will take place on a restart/new day)"
Localization.Mutators_IncompatibleTitle = "Mutators"
Localization.Mutators_IncompatibleMessage = "'{1}' could not be enabled as it is in compatible with {2}. Please disable these mutators first."
Localization.Mutators_IncompatibleAccept = "OK"

Localization.Mutators_HelpButton = "Help"
Localization.Mutators_HelpButtonDesc = "Show the mutators menu help"
Localization.Mutators_HelpTitle = "Mutators"
Localization.Mutators_HelpMessage = [[This menu allows you to enable and disable specific gameplay mutators. Mutators are small gameplay modifications that can offer new gameplay modes, and unique experiences.

Certain mutators may be incompatible with other mutators, and will turn red when an incompatible mutator is active. In order to use this mutator, you must first disable the incompatible mutator.

Mutators are only active in certain circumstances, and in order to prevent griefing in public games, mutators are disabled in all games except for friends-only, and private games.

Mutators will also disabled ALL achievements while they are active. If you are achievement hunting, disable all of your mutators first.
]]
Localization.Mutators_HelpAccept = "Close"

-- Options
if GoonBase.Options.Mutators == nil then
	GoonBase.Options.Mutators = {}
end

-- Add mutators menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_MutatorsMenu", function(menu_manager, menu_nodes)

	-- Create menu
	GoonBase.MenuHelper:NewMenu( Mutators.MenuID )

	-- Add help button
	MenuCallbackHandler.open_mutators_menu_help = function(this, item)
		Mutators:ShowHelpMenu()
	end

	GoonBase.MenuHelper:AddButton({
		id = "goonbase_mutators_menu_help_button",
		title = "Mutators_HelpButton",
		desc = "Mutators_HelpButtonDesc",
		callback = "open_mutators_menu_help",
		menu_id = Mutators.MenuID,
		priority = 1003,
	})

	GoonBase.MenuHelper:AddDivider({
		id = "goonbase_mutators_menu_help_divider",
		menu_id = Mutators.MenuID,
		size = 8,
		priority = 1002,
	})

	-- Add mutators to menu
	Mutators:AddLoadedMutatorsToMenu()
	
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_MutatorsMenu", function(menu_manager, menu_nodes)

	-- Build menu
	local menu_id = Mutators.MenuID
	menu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id )

	-- Add to main menu and lobby only
	if menu_nodes.main ~= nil then
		GoonBase.MenuHelper:AddMenuItem( menu_nodes.main, menu_id, "Mutators_OptionsName", "Mutators_OptionsDesc", "safehouse", "after" )
	end
	if menu_nodes.lobby ~= nil then
		GoonBase.MenuHelper:AddMenuItem( menu_nodes.lobby, menu_id, "Mutators_OptionsName", "Mutators_OptionsDesc", "skilltree", "after" )
	end

	-- Add to ingame menu
	if menu_nodes.pause ~= nil then
		GoonBase.MenuHelper:AddMenuItem( menu_nodes.pause, menu_id, "Mutators_OptionsIngameName", "Mutators_OptionsIngameDesc", "options", "after" )
	end
	
	-- Verify incompatibilities
	Mutators:VerifyAllIncompatibilities()

end)

-- Mutators Functions
function Mutators:ShowHelpMenu()

	local title = managers.localization:text("Mutators_HelpTitle")
	local message = managers.localization:text("Mutators_HelpMessage")
	local menu_options = {}
	menu_options[1] = { text = managers.localization:text("Mutators_HelpAccept"), is_cancel_button = true }
	local tradeMenu = SimpleMenu:New(title, message, menu_options)
	tradeMenu:Show()

end

function Mutators:LoadMutators()
	
	for k, v in pairs( self.MutatorsList ) do
		SafeDoFile( GoonBase.Path .. self.MutatorsPath .. v )		
	end

end

function Mutators:RegisterMutator(mutator)
	Print("[Mutators] Registering mutator '" .. mutator:ID() .. "'")
	self.LoadedMutators[ mutator:ID() ] = mutator
end

function Mutators:SetupMutators()

	for k, v in pairs( Mutators.LoadedMutators ) do
		v:Setup()
	end

end

function Mutators:AddLoadedMutatorsToMenu()

	for k, v in pairs( Mutators.LoadedMutators ) do
		if v.HideInOptionsMenu ~= true then
			v:SetupMenu()
		end
	end

end

function Mutators:VerifyAllIncompatibilities()

	for i, mutator in pairs( Mutators.LoadedMutators ) do
		mutator:VerifyIncompatibilities()
	end

end

function Mutators:CheckIncompatibilities( mutator )

	local incompatible_list = mutator:IncompatibleMutators()
	local incompatible = {}
	local num_incompatibilities = 0

	-- Find incompatible mutators
	for k, v in pairs( Mutators.LoadedMutators ) do
		if v:ShouldBeEnabled() and table.contains( incompatible_list, v:ID() ) then
			incompatible[k] = true
			num_incompatibilities = num_incompatibilities + 1
		end
	end

	-- Mutators are all compatible
	if num_incompatibilities < 1 then
		return true
	end

	-- Incompatible mutators
	return incompatible

end

function Mutators:ShowIncompatibilitiesWindow( mutator, incompatible )

	-- Display incompatible mutators
	local incompatible_str = ""
	for k, v in pairs( incompatible ) do

		if incompatible_str ~= "" then
			incompatible_str = incompatible_str .. ", "
		end
		incompatible_str = incompatible_str .. "'" .. Mutators.LoadedMutators[k]:GetLocalizedName() .. "'"

	end

	-- Display
	local title = managers.localization:text("Mutators_IncompatibleTitle")
	local message = managers.localization:text("Mutators_IncompatibleMessage")
	message = message:gsub("{1}", mutator:GetLocalizedName())
	message = message:gsub("{2}", incompatible_str)
	local menuOptions = {}
	menuOptions[1] = {
		text = managers.localization:text("Mutators_IncompatibleAccept"),
		is_cancel_button = true
	}
	local menu = SimpleMenu:New(title, message, menuOptions)
	menu:Show()

	return false

end

-- Hooks
Hooks:Add("AchievementManagerCheckDisable", "AchievementManagerCheckDisable_Mutators", function(achievement_manager)

	for k, v in pairs( Mutators.LoadedMutators ) do
		if v:ShouldBeEnabled() then
			achievement_manager:DisableAchievements("mutators")
		end
	end

end)

-- Load mutators
Hooks:RegisterHook("GoonBaseRegisterMutators")
Hooks:Add("GoonBasePostLoadedMods", "GoonBasePostLoadedMods_Mutators", function()

	Print("[Mutators] Loading Mutators")
	Mutators:LoadMutators()

	Hooks:Call("GoonBaseRegisterMutators")

	Print("[Mutators] Setting up mutators")
	Mutators:SetupMutators()

end)

-- END OF FILE
