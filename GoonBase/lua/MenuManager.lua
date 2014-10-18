----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerInitialize" )
function MenuManager.init(this, ...)
	this.orig.init(this, ...)
	Hooks:Call( "MenuManagerInitialize", this )
end

Hooks:RegisterHook( "MenuManagerOnOpenMenu" )
function MenuManager.open_menu(this, menu_name, position)
	this.orig.open_menu(this, menu_name, position)
	Hooks:Call( "MenuManagerOnOpenMenu", this, menu_name, position )
end

-- Add GoonBase to options
Hooks:RegisterHook( "MenuManagerSetupCustomMenus" )
Hooks:RegisterHook( "MenuManagerPopulateCustomMenus" )
Hooks:RegisterHook( "MenuManagerBuildCustomMenus" )
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_AddGoonBaseMenuItem", function( menu_manager )

	local success, err = pcall(function()

		MenuManager._goonbase_process_main_menu( menu_manager )
		MenuManager._goonbase_process_pause_menu( menu_manager )

	end)
	if not success then Print("[Error] " .. err) end

end )

function MenuManager._goonbase_process_main_menu( menu_manager )

	local psuccess, perror = pcall(function()
		
		local main_menu = menu_manager._registered_menus.menu_main
		if main_menu == nil then return end
		local mainmenu_nodes = main_menu.logic._data._nodes

		GoonBase.MenuHelper:SetupMenu( mainmenu_nodes, "video" )
		GoonBase.MenuHelper:SetupMenuButton( mainmenu_nodes, "options" )

		Hooks:Call("MenuManagerSetupCustomMenus", menu_manager, mainmenu_nodes)
		Hooks:Call("MenuManagerPopulateCustomMenus", menu_manager, mainmenu_nodes)
		Hooks:Call("MenuManagerBuildCustomMenus", menu_manager, mainmenu_nodes)

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

function MenuManager._goonbase_process_pause_menu( menu_manager )

	local psuccess, perror = pcall(function()
		
		local pause_menu = menu_manager._registered_menus.menu_pause
		if pause_menu == nil then return end
		local pausemenu_nodes = pause_menu.logic._data._nodes

		GoonBase.MenuHelper:SetupMenu( pausemenu_nodes, "video" )
		GoonBase.MenuHelper:SetupMenuButton( pausemenu_nodes, "options" )

		Hooks:Call("MenuManagerSetupCustomMenus", menu_manager, pausemenu_nodes)
		Hooks:Call("MenuManagerPopulateCustomMenus", menu_manager, pausemenu_nodes)
		Hooks:Call("MenuManagerBuildCustomMenus", menu_manager, pausemenu_nodes)

	end)
	if not psuccess then
		Print("[Error] " .. perror)
	end

end

-- END OF FILE
