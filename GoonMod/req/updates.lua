
_G.GoonBase.Updates = _G.GoonBase.Updates or {}
local Updates = GoonBase.Updates
Updates.MenuPriority = 500

GoonBase.Options.Updates = GoonBase.Options.Updates or {}
GoonBase.Options.Updates.LastCheckedVersion = GoonBase.Options.Updates.LastCheckedVersion or nil
GoonBase.Options.Updates.BypassVersion 		= GoonBase.Options.Updates.BypassVersion or false

function Updates:GameUpdateVersionCheck()
	
	if Updates:HasGameUpdated() then
		GoonBase.Options.Updates.BypassVersion = false
	end
	GoonBase.Options.Updates.LastCheckedVersion = Application:version()

	if Updates:IsBypassingVersionCheck() then
		return true
	else

		local mod_version = GoonBase.GameVersion:split("[.]")
		local game_version = Application:version():split("[.]")

		if not mod_version or not game_version then
			return false
		end

		for i = 1, 2, 1 do
			if mod_version[i] < game_version[i] then
				return false
			end
		end

		return true, nil

	end

end

function Updates:HasGameUpdated()
	return Application:version() ~= GoonBase.Options.Updates.LastCheckedVersion
end

function Updates:IsBypassingVersionCheck()
	return GoonBase.Options.Updates.BypassVersion
end

Hooks:Add("MenuManagerSetupGoonBaseMenu", "MenuManagerSetupGoonBaseMenu_GoonModUpdates", function(menu_manager, menu_nodes)

	-- Menu
	MenuCallbackHandler.goonmod_bypass_version_check = function(this, item)
		GoonBase.Options.Updates.BypassVersion = Utils:ToggleItemToBoolean(item)
		GoonBase.Options:Save()
	end

	if not Updates:GameUpdateVersionCheck() or Updates:IsBypassingVersionCheck() then

		MenuHelper:AddToggle({
			id = "gm_updates_bypass_version",
			title = "gm_mods_version_bypass_title",
			desc = "gm_mods_version_bypass_desc",
			callback = "goonmod_bypass_version_check",
			menu_id = "goonbase_options_menu",
			value = GoonBase.Options.Updates.BypassVersion,
			default_value = false,
			priority = Updates.MenuPriority + 2,
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = "goonbase_options_menu",
			priority = Updates.MenuPriority + 1
		})

	end

end)

