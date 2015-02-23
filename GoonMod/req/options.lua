
_G.GoonBase.Options = _G.GoonBase.Options or {}
local Options = _G.GoonBase.Options
Options.SaveFileName = "goonmod_options.txt"
Options.SaveFilePath = SavePath .. Options.SaveFileName

local options_menu_id = "goonbase_options_menu"
Hooks:RegisterHook( "MenuManagerSetupGoonBaseMenu" )
Hooks:RegisterHook( "MenuManagerPostSetupGoonBaseMenu" )

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_OptionsMenu", function(menu_manager, mainmenu_nodes)
	MenuHelper:NewMenu( options_menu_id )
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_OptionsMenu", function(menu_manager, mainmenu_nodes)
	Hooks:Call( "MenuManagerSetupGoonBaseMenu", menu_manager, mainmenu_nodes )
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_OptionsMenu", function(menu_manager, mainmenu_nodes)

	local mod_options_menu = LuaModManager.Constants._lua_mod_options_menu_id
	if mainmenu_nodes[mod_options_menu] then

		mainmenu_nodes[options_menu_id] = MenuHelper:BuildMenu( options_menu_id )
		MenuHelper:AddMenuItem( mainmenu_nodes[mod_options_menu], options_menu_id, "GoonBaseOptionsName", "GoonBaseOptionsDesc" )
		
		Hooks:Call( "MenuManagerPostSetupGoonBaseMenu", menu_manager, mainmenu_nodes )

	end

end)

function Options:Save( file_path )

	file_path = file_path or Options.SaveFilePath

	local file = io.open(file_path, "w+")
	if file then
		file:write( json.encode(Options) )
		file:close()
	else
		Print("[Error] Could not save GoonMod options!")
	end

end

function Options:Load( file_path )

	file_path = file_path or Options.SaveFilePath

	local file = io.open( file_path, "r" )
	if file then

		local file_contents = file:read("*all")
		Options = json.decode( file_contents )
		file:close()
		return Options

	else
		Print("[Warning] Could not load file '" .. file_path .. "', no data loaded...")
	end

end
Options:Load()
