
CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerInitialize" )
function MenuManager.init(this, ...)
	this.orig.init(this, ...)
	Hooks:Call( "MenuManagerInitialize", this )
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
	local grenadeMarkerData = {
		type = "CoreMenuItemToggle.ItemToggle",
		clone( toggleOnData ),
		clone( toggleOffData )
	}
	local grenadeMarkerParams = {
		name = "toggle_grenade_marker",
		text_id = "OptionsMenu_GrenadeMarker",
		help_id = "OptionsMenu_GrenadeMarkerDesc",
		callback = "toggle_grenade_marker",
		disabled_color = Color(0.25, 1, 1, 1),
		icon_by_text = false
	}
	local grenademarkertoggle_menu_item = goonhudMenu:create_item(grenadeMarkerData, grenadeMarkerParams)
	grenademarkertoggle_menu_item:set_value( GoonHUD.Options.EnemyManager.ShowGrenadeMarker and "on" or "off" )
	goonhudMenu:add_item(grenademarkertoggle_menu_item)

	-- Custom Corpse Amount Toggle
	local corpseToggleData = {
		type = "CoreMenuItemToggle.ItemToggle",
		clone( toggleOnData ),
		clone( toggleOffData )
	}
	local corpseToggleParams = {
		name = "toggle_custom_corpse",
		text_id = "OptionsMenu_CorpseToggle",
		help_id = "OptionsMenu_CorpseToggleDesc",
		callback = "toggle_corpse",
		disabled_color = Color(0.25, 1, 1, 1),
		icon_by_text = false
	}
	local corpsetoggle_menu_item = goonhudMenu:create_item(corpseToggleData, corpseToggleParams)
	corpsetoggle_menu_item:set_value( GoonHUD.Options.EnemyManager.CustomCorpseLimit and "on" or "off" )
	goonhudMenu:add_item(corpsetoggle_menu_item)

	-- Corpse Amount Slider
	local corpseSliderData = {
		type = "CoreMenuItemSlider.ItemSlider",
		min = 8,
		max = 1024,
		step = 1,
		show_value = false
	}
	local corpseSliderParams = {
		name = "corpse_amount_slider",
		text_id = "OptionsMenu_CorpseAmount",
		help_id = "OptionsMenu_CorpseAmountDesc",
		callback = "set_corpse_amount",
		disabled_color = Color(0.25, 1, 1, 1),
	}
	local corpseslider_menu_item = goonhudMenu:create_item(corpseSliderData, corpseSliderParams)
	corpseslider_menu_item:set_value( GoonHUD.Options.EnemyManager.CurrentMaxCorpses or 8 )
	goonhudMenu:add_item(corpseslider_menu_item)

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
