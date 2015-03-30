
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_GoonMod", function(loc)
	loc:load_localization_file( GoonBase.LocalizationFolder .. "en.txt" )
end)
