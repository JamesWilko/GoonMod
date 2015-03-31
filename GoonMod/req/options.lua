
_G.GoonBase.Options = _G.GoonBase.Options or {}
local Options = GoonBase.Options

local mt = getmetatable( Options )
if mt == nil then
	mt = {}
	mt.__func = {}
	mt.__data = {}
	setmetatable( Options, mt )
end

function mt.__index(tbl, key)
	return mt.__data[key] or mt.__func[key]
end

function mt.__newindex(tbl, key, value)
	mt.__data[key] = value
end

local options_menu_id = "goonbase_options_menu"
Hooks:RegisterHook( "MenuManagerSetupGoonBaseMenu" )
Hooks:RegisterHook( "MenuManagerPostSetupGoonBaseMenu" )

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_OptionsMenu", function( menu_manager )

	MenuCallbackHandler.ClosedGoonModOptions = function(this)
		GoonBase.Options:Save()
	end

end)

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
		MenuHelper:AddMenuItem( mainmenu_nodes[mod_options_menu], options_menu_id, "gm_options_menu", "gm_options_menu_desc" )
		
		Hooks:Call( "MenuManagerPostSetupGoonBaseMenu", menu_manager, mainmenu_nodes )

	end

end)

local function OptionsSave( self, file_path )

	file_path = file_path or GoonBase.SavePath

	local file = io.open(file_path, "w+")
	if file then

		file:write( json.encode(mt.__data) )
		file:close()

	else
		Print("[Error] Could not save GoonMod options!")
	end

end
rawset( mt.__func, "Save", OptionsSave )

local function OptionsLoad( self, file_path )

	file_path = file_path or GoonBase.SavePath

	local file = io.open( file_path, "r" )
	if file then

		local file_contents = file:read("*all")
		local data = json.decode( file_contents )
		file:close()

		if data then
			mt.__data = data
		end

	else
		Print("[Warning] Could not load file '" .. file_path .. "', no data loaded...")
	end

end
rawset( mt.__func, "Load", OptionsLoad )

Options:Load()
