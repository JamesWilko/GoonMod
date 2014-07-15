
CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerInitialize" )
function MenuManager.init(this, ...)
	this.orig.init(this, ...)
	Hooks:Call( "MenuManagerInitialize", this )
end

-- Helper
MenuManager.GoonHUDHelper = {}
function MenuManager.GoonHUDHelper.AddToggle( toggleName, text, help, callbackFunction, saveData, menu )

	local data = {
		type = "CoreMenuItemToggle.ItemToggle",
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "on",
			x = 24,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 24,
			s_y = 24,
			s_w = 24,
			s_h = 24
		},
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "off",
			x = 0,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 0,
			s_y = 24,
			s_w = 24,
			s_h = 24
		}
	}

	local params = {
		name = toggleName,
		text_id = text,
		help_id = help,
		callback = callbackFunction,
		disabled_color = Color( 0.25, 1, 1, 1 ),
		icon_by_text = false
	}

	local menuItem = menu:create_item( data, params )
	menuItem:set_value( saveData and "on" or "off" )
	menu:add_item( menuItem )

end

function MenuManager.GoonHUDHelper.AddSlider( sliderName, text, help, callbackFunction, saveData, menu )

	local data = {
		type = "CoreMenuItemSlider.ItemSlider",
		min = 8,
		max = 1024,
		step = 1,
		show_value = false
	}

	local params = {
		name = sliderName,
		text_id = text,
		help_id = help,
		callback = callbackFunction,
		disabled_color = Color(0.25, 1, 1, 1),
	}

	local menuItem = menu:create_item(data, params)
	menuItem:set_value( saveData or 1 )
	menu:add_item(menuItem)

end

-- Add GoonHUD to options
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_AddGoonHUDMenuItem", function( menu_manager )

	local mainMenu = menu_manager._registered_menus.menu_main
	if mainMenu == nil then return end

	local mainMenuNodes = mainMenu.logic._data._nodes
	if mainMenuNodes["goonhud"] ~= nil then return end

	-- Create GoonHUD Options Menu
	_G.GoonHUD.Menu = {}
	local goonhudMenu = deep_clone( mainMenuNodes.video )

	-- Store controls for later use
	menu_manager.stored_controls = {}
	menu_manager.stored_controls.back_button = deep_clone( goonhudMenu._items[ #goonhudMenu._items ] ) 
	menu_manager.stored_controls.toggle = deep_clone( goonhudMenu._items[2] )
	menu_manager.stored_controls.slider = deep_clone( goonhudMenu._items[6] )

	-- Toggles
	local toggleOnData = {
		_meta = "option",
		icon = "guis/textures/menu_tickbox",
		value = "on",
		x = 24,
		y = 0,
		w = 24,
		h = 24,
		s_icon = "guis/textures/menu_tickbox",
		s_x = 24,
		s_y = 24,
		s_w = 24,
		s_h = 24
	}
	local toggleOffData = {
		_meta = "option",
		icon = "guis/textures/menu_tickbox",
		value = "off",
		x = 0,
		y = 0,
		w = 24,
		h = 24,
		s_icon = "guis/textures/menu_tickbox",
		s_x = 0,
		s_y = 24,
		s_w = 24,
		s_h = 24
	}

	-- Clear Items
	goonhudMenu._items = {}

	-- Grenade Marker Toggle
	MenuManager.GoonHUDHelper.AddToggle(
		"toggle_grenade_marker",
		"OptionsMenu_GrenadeMarker",
		"OptionsMenu_GrenadeMarkerDesc",
		"toggle_grenade_marker",
		GoonHUD.Options.EnemyManager.ShowGrenadeMarker,
		goonhudMenu
	)

	-- Custom Corpse Amount Toggle
	MenuManager.GoonHUDHelper.AddToggle(
		"toggle_custom_corpse",
		"OptionsMenu_CorpseToggle",
		"OptionsMenu_CorpseToggleDesc",
		"toggle_corpse",
		GoonHUD.Options.EnemyManager.CustomCorpseLimit,
		goonhudMenu
	)

	-- Corpse Amount Slider
	MenuManager.GoonHUDHelper.AddSlider(
		"corpse_amount_slider",
		"OptionsMenu_CorpseAmount",
		"OptionsMenu_CorpseAmountDesc",
		"set_corpse_amount",
		GoonHUD.Options.EnemyManager.CurrentMaxCorpses,
		goonhudMenu
	)

	-- Add back button
	MenuManager:add_back_button(goonhudMenu)

	-- Add menu to data
	mainMenuNodes["goonhud"] = deep_clone(goonhudMenu)

	-- Add GoonHUD to Options
	local optionsButton = deep_clone( mainMenuNodes.options._items[1] )
	optionsButton._parameters.name = "GoonHUDOptionsName"
	optionsButton._parameters.text_id = "GoonHUDOptionsName"
	optionsButton._parameters.help_id = "GoonHUDOptionsDesc"
	optionsButton._parameters.next_node = "goonhud"
	table.insert( mainMenuNodes.options._items, #mainMenuNodes.options._items + 1, optionsButton )

end )

-- Callbacks
function MenuCallbackHandler:toggle_corpse(item)
	GoonHUD.Options.EnemyManager.CustomCorpseLimit = item:value() == "on" and true or false
	GoonHUD.Options:Save()
end

function MenuCallbackHandler:set_corpse_amount(item)
	GoonHUD.Options.EnemyManager.CurrentMaxCorpses = math.floor( item:value() )
	GoonHUD.Localization.OptionsMenu_CorpseAmountDesc = "Maximum number of corpses allowed (Current: " .. math.floor(GoonHUD.Options.EnemyManager.CurrentMaxCorpses) .. ")"
	GoonHUD.Options:Save()
end

function MenuCallbackHandler:toggle_grenade_marker(item)
	GoonHUD.Options.EnemyManager.ShowGrenadeMarker = item:value() == "on" and true or false
	GoonHUD.Options:Save()
end
