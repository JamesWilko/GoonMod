
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
	local goonhudMenu = deep_clone( mainMenuNodes.video )

	-- Store controls for later use
	menu_manager.stored_controls = {}
	menu_manager.stored_controls.back_button = deep_clone( goonhudMenu._items[ #goonhudMenu._items ] ) 
	menu_manager.stored_controls.toggle = deep_clone( goonhudMenu._items[2] )
	menu_manager.stored_controls.slider = deep_clone( goonhudMenu._items[6] )

	-- Clear Items
	goonhudMenu._items = {}

	-- Add corpse amount slider
	local corpseSlider = deep_clone( menu_manager.stored_controls.slider )
	corpseSlider._parameters.text_id = "OptionsMenu_CorpseAmount"
	corpseSlider._parameters.help_id = "OptionsMenu_CorpseAmountDesc"
	corpseSlider.dirty_callback = MenuCallbackHandler.set_corpse_amount
	corpseSlider._parameters.callback[1] = MenuCallbackHandler.set_corpse_amount
	corpseSlider._parameters.callback_name[1] = "set_corpse_amount"
	table.insert( goonhudMenu._items, corpseSlider )

	-- Add back button
	table.insert( goonhudMenu._items, deep_clone(menu_manager.stored_controls.back_button) )

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


function MenuCallbackHandler.set_corpse_amount(item)

	if item.setup == nil then
		item:set_min( 8 )
		item:set_max( GoonHUD.Options.EnemyManager.MaxCorpses )
		item._value = GoonHUD.Options.EnemyManager.CurrentMaxCorpses
		item.setup = true
	end

	GoonHUD.Options.EnemyManager.CurrentMaxCorpses = math.floor( item:value() )
	GoonHUD.Localization.OptionsMenu_CorpseAmountDesc = "Maximum number of corpses allowed (Current: " .. math.floor(GoonHUD.Options.EnemyManager.CurrentMaxCorpses) .. ")"
	GoonHUD.Options:Save()

end

-- Allow restarting multiplayer missions if you are the host
-- 10/7/14 - Disabled due to crashing on pressing escape for some players
-- Hooks:RegisterHook( "MenuManagerOnRestartGame" )
-- function MenuCallbackHandler.singleplayer_restart(this)

-- 	-- Check if everybody is synced before restarting
-- 	if Network:is_server() and not this:is_singleplayer() then
-- 		for k, v in pairs( managers.network:session():peers() ) do
-- 			if not v:synched() then
-- 				return false
-- 			end
-- 		end
-- 	end

-- 	-- Check if we can restart and call hook
-- 	local restart = ( self:is_singleplayer() or ( self:is_multiplayer() and self:is_server() ) ) and self:has_full_game() and self:is_normal_job() and not managers.job:stage_success()
-- 	if restart then
-- 		Hooks:Call( "MenuManagerOnRestartGame" )
-- 	end
-- 	return restart

-- end
