
CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerInitialize" )
function MenuManager.init(this, ...)
	this.orig.init(this, ...)
	Hooks:Call( "MenuManagerInitialize", this )
end

-- Helper
MenuManager.GoonBaseHelper = {}
function MenuManager.GoonBaseHelper.AddToggle( toggleName, text, help, callbackFunction, saveData, menu )

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

function MenuManager.GoonBaseHelper.AddSlider( sliderName, text, help, callbackFunction, saveData, menu )

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

-- Add GoonBase to options
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_AddGoonBaseMenuItem", function( menu_manager )

	local mainMenu = menu_manager._registered_menus.menu_main
	if mainMenu == nil then return end

	local mainMenuNodes = mainMenu.logic._data._nodes
	if mainMenuNodes["goonbase"] ~= nil then return end

	-- Create GoonBase Options Menu
	_G.GoonBase.Menu = {}
	local goonbaseMenu = deep_clone( mainMenuNodes.video )

	-- Store controls for later use
	menu_manager.stored_controls = {}
	menu_manager.stored_controls.back_button = deep_clone( goonbaseMenu._items[ #goonbaseMenu._items ] ) 
	menu_manager.stored_controls.toggle = deep_clone( goonbaseMenu._items[2] )
	menu_manager.stored_controls.slider = deep_clone( goonbaseMenu._items[6] )

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
	goonbaseMenu._items = {}

	-- Ironman Mode Toggle
	-- MenuManager.GoonBaseHelper.AddToggle(
	-- 	"toggle_ironman_mode",
	-- 	"Ironman_Toggle",
	-- 	"Ironman_ToggleDesc",
	-- 	"toggle_ironman_mode",
	-- 	GoonBase.Options.Ironman.Enabled,
	-- 	goonbaseMenu
	-- )

	-- Advanced Hostages
	-- MenuManager.GoonBaseHelper.AddToggle(
	-- 	"toggle_adv_hostage_mode",
	-- 	"Hostage_Toggle",
	-- 	"Hostage_ToggleDesc",
	-- 	"toggle_adv_hostage_mode",
	-- 	GoonBase.Options.AdvHostages.Enabled,
	-- 	goonbaseMenu
	-- )

	-- Custom Corpse Amount Toggle
	MenuManager.GoonBaseHelper.AddToggle(
		"toggle_custom_corpse",
		"OptionsMenu_CorpseToggle",
		"OptionsMenu_CorpseToggleDesc",
		"toggle_corpse",
		GoonBase.Options.EnemyManager.CustomCorpseLimit,
		goonbaseMenu
	)

	-- Corpse Amount Slider
	MenuManager.GoonBaseHelper.AddSlider(
		"corpse_amount_slider",
		"OptionsMenu_CorpseAmount",
		"OptionsMenu_CorpseAmountDesc",
		"set_corpse_amount",
		GoonBase.Options.EnemyManager.CurrentMaxCorpses,
		goonbaseMenu
	)

	-- Grenade Marker Toggle
	MenuManager.GoonBaseHelper.AddToggle(
		"toggle_grenade_marker",
		"OptionsMenu_GrenadeMarker",
		"OptionsMenu_GrenadeMarkerDesc",
		"toggle_grenade_marker",
		GoonBase.Options.EnemyManager.ShowGrenadeMarker,
		goonbaseMenu
	)

	-- Add back button
	MenuManager:add_back_button(goonbaseMenu)

	-- Add menu to data
	mainMenuNodes["goonbase"] = deep_clone(goonbaseMenu)

	-- Add GoonHUD to Options
	local optionsButton = deep_clone( mainMenuNodes.options._items[1] )
	optionsButton._parameters.name = "GoonBaseOptionsName"
	optionsButton._parameters.text_id = "GoonBaseOptionsName"
	optionsButton._parameters.help_id = "GoonBaseOptionsDesc"
	optionsButton._parameters.next_node = "goonbase"
	table.insert( mainMenuNodes.options._items, #mainMenuNodes.options._items + 1, optionsButton )

end )

-- Callbacks
function MenuCallbackHandler:toggle_corpse(item)
	GoonBase.Options.EnemyManager.CustomCorpseLimit = item:value() == "on" and true or false
	GoonBase.Options:Save()
end

function MenuCallbackHandler:set_corpse_amount(item)
	GoonBase.Options.EnemyManager.CurrentMaxCorpses = math.floor( item:value() )
	GoonBase.Localization.OptionsMenu_CorpseAmountDesc = "Maximum number of corpses allowed (Current: " .. math.floor(GoonBase.Options.EnemyManager.CurrentMaxCorpses) .. ")"
	GoonBase.Options:Save()
end

function MenuCallbackHandler:toggle_grenade_marker(item)
	GoonBase.Options.EnemyManager.ShowGrenadeMarker = item:value() == "on" and true or false
	GoonBase.Options:Save()
end

function MenuCallbackHandler:toggle_ironman_mode(item)
	GoonBase.Options.Ironman.Enabled = item:value() == "on" and true or false
	GoonBase.Ironman:SetEnabled( GoonBase.Options.Ironman.Enabled )
	GoonBase.Options:Save()
end

function MenuCallbackHandler:toggle_adv_hostage_mode(item)
	GoonBase.Options.AdvHostages.Enabled = item:value() == "on" and true or false
	GoonBase.Options:Save()
end


