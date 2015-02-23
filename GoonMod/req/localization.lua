
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_LocExample", function(loc)
	loc:load_localization_file( GoonBase.Path .. GoonBase.LocalizationFolder .. "en.txt" )
end)
