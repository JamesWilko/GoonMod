
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "MenuColourGrading"
Mod.Name = "Menu Colour Grading"
Mod.Desc = "Allows you to change the colour grading scheme used on the main menu"
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
ColourGrading.GradingOptions = {
	"color_matrix", -- color_off for default, menu default is matrices
	"color_payday",
	"color_heat",
	"color_nice",
	"color_sin",
	"color_bhd",
	"color_xgen",
	"color_xxxgen",
	"color_matrix"
}

-- Options
GoonBase.Options.ColourGrading 					= GoonBase.Options.ColourGrading or {}
GoonBase.Options.ColourGrading.GradingOption 	= GoonBase.Options.ColourGrading.GradingOption or 9

-- Functions
function ColourGrading:ColourGradingEnabled()
	if not GoonBase.Options.ColourGrading then
		return false
	end
	if not GoonBase.Options.ColourGrading.GradingOption then
		return false
	end
	return GoonBase.Options.ColourGrading.GradingOption > 1
end

function ColourGrading:GetGradingIndex()
	if not GoonBase.Options.ColourGrading then
		return 1
	end
	if not GoonBase.Options.ColourGrading.GradingOption then
		return 1
	end
	return  GoonBase.Options.ColourGrading.GradingOption
end

function ColourGrading:GetGradingOption()
	if not Utils:IsInGameState() then
		return ColourGrading.GradingOptions[ ColourGrading:GetGradingIndex() ]
	else
		return ColourGrading:GetDefaultGradingOption()
	end
end

function ColourGrading:GetDefaultGradingOption()
	return "color_matrix"
end

function ColourGrading:UpdateColourGrading()
	if not Utils:IsInGameState() and managers and managers.environment_controller then
		local grading = ColourGrading:GetGradingOption()
		if grading then
			managers.menu_scene._environments.standard.color_grading = grading
			managers.environment_controller:set_default_color_grading( grading )
			managers.environment_controller:refresh_render_settings()
		end
	end
end

-- Menu
Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_" .. Mod:ID(), function( menu_manager )

	MenuCallbackHandler.goonmod_set_menu_colour_grading = function(this, item)
		GoonBase.Options.ColourGrading.GradingOption = tonumber(item:value())
		GoonBase.Options:Save()
		ColourGrading:UpdateColourGrading()
	end

	MenuHelper:AddMultipleChoice({
		id = "gm_colour_grading_override_multichoice",
		title = "gm_options_color_grading_menu",
		desc = "gm_options_color_grading_menu_desc",
		callback = "goonmod_set_menu_colour_grading",
		menu_id = "goonbase_options_menu",
		items = {
			[1] = "gm_col_grading_off",
			[2] = "gm_col_grading_payday_plus",
			[3] = "gm_col_grading_heat",
			[4] = "gm_col_grading_nice",
			[5] = "gm_col_grading_sin",
			[6] = "gm_col_grading_bhd",
			[7] = "gm_col_grading_xgen",
			[8] = "gm_col_grading_xxxgen",
			[9] = "gm_col_grading_matrix",
		},
		value = GoonBase.Options.ColourGrading.GradingOption,
		priority = 1,
	})

end)

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_" .. Mod:ID(), function( menu_manager, menu, position )
	ColourGrading:UpdateColourGrading()
end)
