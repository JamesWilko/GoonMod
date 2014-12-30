----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
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

function MenuManager.open_node(self, node_name, parameter_list)
	self.orig.open_node(self, node_name, parameter_list)
end

Hooks:RegisterHook( "MenuManagerSetMouseSensitivity" )
function MenuManager.set_mouse_sensitivity(self, zoomed)
	self.orig.set_mouse_sensitivity(self, zoomed)
	Hooks:Call( "MenuManagerSetMouseSensitivity", self, zoomed )
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

-- Start game delaying
Hooks:RegisterHook("MenuCallbackHandlerPreStartTheGame")
function MenuCallbackHandler.start_the_game(self)

	if not self._start_the_game then
		self._start_the_game = function()
			self.orig.start_the_game()
		end
	end

	local r = Hooks:ReturnCall("MenuCallbackHandlerPreStartTheGame", self)
	if r then
		self._delayed_start_game = true
		return nil
	end

	self.orig.start_the_game(self)
end

function MenuCallbackHandler:_process_start_game_delay( t, dt )

	if self._delayed_start_game and #self._start_delays == 0 then
		self._delayed_start_game = false
		if self._start_the_game then
			self:_start_the_game()
		end
	end

end

function MenuCallbackHandler:delay_game_start( id )

	self._delayed_start_game = true

	if not self._start_delays then
		self._start_delays = {}
	end
	table.insert( self._start_delays, id ) 

end

function MenuCallbackHandler:release_game_start_delay( id )

	for i = #self._start_delays, 0, -1 do
		if self._start_delays[i] == id then
			table.remove( self._start_delays, i )
		end
	end

end

Hooks:Add("MenuUpdate", "MenuUpdate_MenuManager", function(t, dt)
	MenuCallbackHandler._process_start_game_delay(MenuCallbackHandler, t, dt)
end)

-- Lobby permissions
Hooks:RegisterHook("MenuCallbackHandlerPreChoseLobbyPermission")
function MenuCallbackHandler.choice_lobby_permission(self, item)
	local r = Hooks:ReturnCall("MenuCallbackHandlerPreChoseLobbyPermission", self, item)
	if r then
		return
	end
	self.orig.choice_lobby_permission(self, item)
end

Hooks:RegisterHook("MenuCallbackHandlerPreCrimeNetChoseLobbyPermission")
function MenuCallbackHandler.choice_crimenet_lobby_permission(self, item)
	local r = Hooks:ReturnCall("MenuCallbackHandlerPreCrimeNetChoseLobbyPermission", self, item)
	if r then
		return
	end
	self.orig.choice_crimenet_lobby_permission(self, item)
end
-- END OF FILE
