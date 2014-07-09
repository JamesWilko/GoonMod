
CloneClass( MenuManager )
CloneClass( MenuCallbackHandler )

Hooks:RegisterHook( "MenuManagerInitialize" )
function MenuManager.init(this, ...)
	this.orig.init(this, ...)
	Hooks:Call( "MenuManagerInitialize", this )
end

-- Add GoonHUD to options
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_AddGoonHUDMenuItem", function( menu_manager )

	if menu_manager == nil then return end
	if menu_manager._registered_menus == nil then return end
	if menu_manager._registered_menus.menu_main == nil then return end
	if menu_manager._registered_menus.menu_main.logic._data == nil then return end
	if menu_manager._registered_menus.menu_main.logic._data._nodes == nil then return end
	if menu_manager._registered_menus.menu_main.logic._data._nodes.main == nil then return end

	local mainMenuNodes = menu_manager._registered_menus.menu_main.logic._data._nodes.main
	local insertPoint

	-- Get insert point
	for k, v in pairs( mainMenuNodes._items ) do
		if v._parameters.name == "options" then
			insertPoint = k
			break
		end
	end

	-- Insert using clone of safehouse button
	for k, v in pairs( mainMenuNodes._items ) do
		if v._parameters.name == "safehouse" then

			local menu_item = deep_clone(v)
			menu_item._parameters.name = "GoonHUDOptions"
			menu_item._parameters.text_id = "MainMenuOptionsName"
			menu_item._parameters.help_id = "MainMenuOptionsDesc"
			menu_item._parameters.next_node = nil
			menu_item._parameters.callback_name[1] = "open_goonhudmenu"
			menu_item._parameters.callback[1] = MenuCallbackHandler.open_goonhudmenu
			
			table.insert( mainMenuNodes._items, insertPoint + 1, deep_clone(menu_item) )
			break

		end
	end

end )

function MenuCallbackHandler.open_goonhudmenu(this, params)
	
	local enemyManager = GoonHUD.Options.EnemyManager

	local options = {
		{ text = "Corpse Limit: " .. (enemyManager.CustomCorpseLimit and enemyManager.MaxCorpses or 8) },
		{ text = "Use Custom Corpse Limit: " .. (enemyManager.CustomCorpseLimit and "True" or "False"), callback = function()
			GoonHUD.Options.EnemyManager.CustomCorpseLimit = not GoonHUD.Options.EnemyManager.CustomCorpseLimit
		end },
		{ text = "Close", is_cancel_button = true },
	}
	local menu = SimpleMenu:new("GoonHUD", "v" .. GoonHUD.Version, options)
	menu:show()

end

-- Allow restarting multiplayer missions if you are the host
Hooks:RegisterHook( "MenuManagerOnRestartGame" )
function MenuCallbackHandler.singleplayer_restart(this)

	-- Check if everybody is synced before restarting
	if Network:is_server() and not this:is_singleplayer() then
		for k, v in pairs( managers.network:session():peers() ) do
			if not v:synched() then
				return false
			end
		end
	end

	-- Check if we can restart and call hook
	local restart = ( self:is_singleplayer() or ( self:is_multiplayer() and self:is_server() ) ) and self:has_full_game() and self:is_normal_job() and not managers.job:stage_success()
	if restart then
		Hooks:Call( "MenuManagerOnRestartGame" )
	end
	return restart

end
