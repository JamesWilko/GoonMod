
GoonBase.LocalizationFiles = GoonBase.LocalizationFiles or {}
GoonBase.LocalizationFiles.Languages = {
	"en",
	"fr"
}
GoonBase.LocalizationFiles.DefaultLanguage = "en"

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_GoonMod", function(loc)

	-- Load Saved Localization
	GoonBase.Options.Localization 			= GoonBase.Options.Localization or {}
	GoonBase.Options.Localization.Language 	= GoonBase.Options.Localization.Language or 1

	local selected_language = GoonBase.LocalizationFiles.Languages[GoonBase.Options.Localization.Language]
	loc:load_localization_file( GoonBase.LocalizationFolder .. selected_language .. ".txt" )

	-- Load default localization as a backup for strings that don't exist
	loc:load_localization_file( GoonBase.LocalizationFolder .. GoonBase.LocalizationFiles.DefaultLanguage .. ".txt", false )

end)

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_Localization", function( menu_manager )

	MenuCallbackHandler.goonmod_select_language = function(this, item)
		GoonBase.Options.Localization.Language = tonumber(item:value())
		GoonBase.Options:Save()
	end

	MenuHelper:AddMultipleChoice({
		id = "gm_language_select",
		title = "gm_language_select",
		desc = "gm_language_select_desc",
		callback = "goonmod_select_language",
		menu_id = "goonbase_options_menu",
		items = {
			[1] = "gm_language_en",
			[2] = "gm_language_fr",
		},
		value = GoonBase.Options.Localization.Language,
		priority = 951,
	})

	MenuHelper:AddDivider({
		size = 16,
		menu_id = "goonbase_options_menu",
		priority = 950,
	})

end)
