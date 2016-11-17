
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_GoonMod", function(loc)

	-- Load BLT localization
	local lang = LuaModManager._languages[LuaModManager:GetLanguageIndex()]
	lang = lang or LuaModManager._languages[LuaModManager:GetIndexOfDefaultLanguage()]
	loc:load_localization_file( GoonBase.LocalizationFolder .. lang .. ".txt" )

	-- Load default localization as a backup for strings that don't exist
	loc:load_localization_file( GoonBase.LocalizationFolder .. "en.txt", false )

end)
