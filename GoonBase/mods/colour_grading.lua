----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "GameColourGrading"
Mod.Name = "Colour Grading"
Mod.Desc = "Allows you to use the colour grading options from Payday: The Heist"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Colour Grading
GoonBase.ColourGrading = GoonBase.ColourGrading or {}
local ColourGrading = GoonBase.ColourGrading
ColourGrading.MenuId = "goonbase_colour_grading"
ColourGrading.GradingOptions = {
	"color_off",
	"color_payday",
	"color_heat",
	"color_nice",
	"color_sin",
	"color_bhd",
	"color_xgen",
	"color_xxxgen",
	"color_matrix"
}

-- Localization
local Localization = GoonBase.Localization
Localization.Options_ColourGradingName = "Colour Grading"
Localization.Options_ColourGradingDesc = "Allows you to change the colour grading post-FX"
Localization.Option_ColourGradingName = "Colour Grading"
Localization.Option_ColourGradingDesc = "Specify a colour grading scheme to use instead of the default"
Localization.Option_Menu_ColourGradingName = "Menu Colour Grading"
Localization.Option_Menu_ColourGradingDesc = "Specify a colour grading scheme to use on the main menu instead of the default"
Localization.GradingOption_Off = "Default"
Localization.GradingOption_PaydayPlus = "Payday+"
Localization.GradingOption_Heat = "Dinero"
Localization.GradingOption_Nice = "In Traffic"
Localization.GradingOption_Sin = "GenSec"
Localization.GradingOption_BHD = "BHD"
Localization.GradingOption_XGen = "XGen Brown"
Localization.GradingOption_XXXGen = "Future of Gaming"
Localization.GradingOption_Matrix = "The Matrices"

-- Options
if GoonBase.Options.ColourGrading == nil then
	GoonBase.Options.ColourGrading = {}
	GoonBase.Options.ColourGrading.Enabled = false
	GoonBase.Options.ColourGrading.GradingOption = 1
	GoonBase.Options.ColourGrading.GradingOptionMenu = 1
end

-- Functions
function ColourGrading:ColourGradingEnabled( is_menu )
	if not GoonBase.Options.ColourGrading then
		return false
	end
	if not GoonBase.Options.ColourGrading.GradingOption then
		return false
	end
	local i = is_menu and GoonBase.Options.ColourGrading.GradingOptionMenu or GoonBase.Options.ColourGrading.GradingOption
	return i > 1
end

function ColourGrading:GetGradingIndex( is_menu )
	if not GoonBase.Options.ColourGrading then
		return 1
	end
	if not GoonBase.Options.ColourGrading.GradingOption then
		return 1
	end
	return is_menu and GoonBase.Options.ColourGrading.GradingOptionMenu or GoonBase.Options.ColourGrading.GradingOption
end

function ColourGrading:GetGradingOption( is_menu )
	if is_menu == nil then
		is_menu = not ColourGrading:IsInGame()
		if not is_menu then
			return false
		end
	end
	if ColourGrading:ColourGradingEnabled( is_menu ) then
		return ColourGrading.GradingOptions[ ColourGrading:GetGradingIndex(is_menu) ]
	else
		return ColourGrading:GetDefaultGradingOption( is_menu )
	end
end

function ColourGrading:GetDefaultGradingOption( is_menu )
	return is_menu and "color_matrix" or "color_off"
end

function ColourGrading:IsInGame()
	if not game_state_machine then
		return false
	end
	return string.find( game_state_machine:current_state_name(), "ingame" ) and true or false
end

function ColourGrading:UpdateColourGrading()
	if managers and managers.environment_controller then
		local grading = ColourGrading:GetGradingOption()
		if grading then
			managers.environment_controller:set_default_color_grading( grading )
			managers.environment_controller:refresh_render_settings()
		end
	end
end

-- Menu
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_" .. Mod:ID(), function(menu_manager, menu_nodes)
	GoonBase.MenuHelper:NewMenu( ColourGrading.MenuId )
end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function(menu_manager, menu_nodes)

	-- Submenu Button
	GoonBase.MenuHelper:AddButton({
		id = "colour_grading_override",
		title = "Options_ColourGradingName",
		desc = "Options_ColourGradingDesc",
		next_node = ColourGrading.MenuId,
		menu_id = "goonbase_options_menu",
	})

	-- Menu
	MenuCallbackHandler.colour_grading_set_override_menu = function(this, item)
		GoonBase.Options.ColourGrading.GradingOptionMenu = tonumber(item:value())
		GoonBase.Options:Save()
		ColourGrading:UpdateColourGrading()
	end

	GoonBase.MenuHelper:AddMultipleChoice({
		id = "colour_grading_override_selector_menu",
		title = "Option_Menu_ColourGradingName",
		desc = "Option_Menu_ColourGradingDesc",
		callback = "colour_grading_set_override_menu",
		menu_id = ColourGrading.MenuId,
		items = {
			[1] = "GradingOption_Off",
			[2] = "GradingOption_PaydayPlus",
			[3] = "GradingOption_Heat",
			[4] = "GradingOption_Nice",
			[5] = "GradingOption_Sin",
			[6] = "GradingOption_BHD",
			[7] = "GradingOption_XGen",
			[8] = "GradingOption_XXXGen",
			[9] = "GradingOption_Matrix",
		},
		value = GoonBase.Options.ColourGrading.GradingOptionMenu,
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_" .. Mod:ID(), function(menu_manager, mainmenu_nodes)
	local menu_id = ColourGrading.MenuId
	local data = {
		area_bg = "half"
	}
	mainmenu_nodes[menu_id] = GoonBase.MenuHelper:BuildMenu( menu_id, data )
end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_" .. Mod:ID(), function( menu_manager, menu, position )
	ColourGrading:UpdateColourGrading()
end)
-- END OF FILE
