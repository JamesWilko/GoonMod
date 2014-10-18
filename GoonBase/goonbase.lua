----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/19/2014 12:01:24 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

if not RequiredScript then return end

if not _G.GoonBase then
	_G.GoonBase = {}
	GoonBase.Version = 10
	GoonBase.GameVersion = "1.15.1"
	GoonBase.LogFile = "GoonBase.log"
	GoonBase.Path = "GoonBase/"
	GoonBase.LuaPath = "GoonBase/lua/"
	GoonBase.SafeMode = true
end

GoonBase.RequireScripts = {
	"req/autils.lua",
	"req/hooks.lua",
	"req/hooks_command_queue.lua",
	"req/localization.lua",
	"req/menus.lua",
	"req/mods.lua",
	"req/network.lua",
	"req/options.lua",
	"req/SimpleMenu.lua",
	"req/updates.lua",
}

GoonBase.ModFiles = {
	"mods/colors/color_hsvrgb.lua",
	"mods/colors/enemy_weapon_laser.lua",
	"mods/colors/weapon_flashlight.lua",
	"mods/colors/weapon_laser.lua",
	"mods/colors/world_laser_colors.lua",
	"mods/body_count.lua",
	"mods/custom_waypoints.lua",
	"mods/extended_inventory.lua",
	"mods/gage_coins.lua",
	"mods/grenade_indicator.lua",
	"mods/mod_shop.lua",
	"mods/mutators.lua",
	"mods/push_to_interact.lua",
	"mods/trading.lua",
	"mods/train_heist_plans.lua",
	"mods/weapon_remember_gadget.lua",
	"mods/zoom_sensitivity.lua",
}

GoonBase.RequireHookFiles = {
	"lib/managers/localizationmanager",
	"lib/managers/menumanager",
}

GoonBase.HookFiles = {

	["lib/managers/localizationmanager"] = "LocalizationManager.lua",
	["lib/managers/menumanager"] = "MenuManager.lua",
	["lib/managers/chatmanager"] = "ChatManager.lua",
	["lib/managers/enemymanager"] = "EnemyManager.lua",
	["lib/units/weapons/grenades/quicksmokegrenade"] = "QuickSmokeGrenade.lua",
	["lib/managers/hudmanager"] = "HUDManager.lua",
	["lib/managers/jobmanager"] = "JobManager.lua",
	["lib/managers/group_ai_states/groupaistatebesiege"] = "GroupAIStateBesiege.lua",
	["lib/units/beings/player/states/playerstandard"] = "PlayerStandard.lua",
	["lib/managers/gageassignmentmanager"] = "GageAssignmentManager.lua",
	["lib/managers/achievmentmanager"] = "AchievementManager.lua",
	["lib/tweak_data/infamytweakdata"] = "InfamyTweakData.lua",
	["lib/setups/gamesetup"] = "GameSetup.lua",
	["lib/setups/menusetup"] = "MenuSetup.lua",
	["lib/managers/menu/blackmarketgui"] = "BlackMarketGUI.lua",
	["lib/managers/blackmarketmanager"] = "BlackMarketManager.lua",
	["lib/tweak_data/groupaitweakdata"] = "GroupAITweakData.lua",
	["lib/tweak_data/charactertweakdata"] = "CharacterTweakData.lua",
	["lib/units/enemies/cop/copinventory"] = "CopInventory.lua",
	["lib/managers/mission/elementlasertrigger"] = "ElementLaserTrigger.lua",
	["lib/units/weapons/weaponflashlight"] = "WeaponFlashlight.lua",
	["lib/units/weapons/weaponlaser"] = "WeaponLaser.lua",
	["lib/tweak_data/levelstweakdata"] = "LevelsTweakData.lua",
	["lib/tweak_data/assetstweakdata"] = "AssetsTweakData.lua",
	["lib/tweak_data/narrativetweakdata"] = "NarrativeTweakData.lua",
	["lib/managers/menu/menunodegui"] = "MenuNodeGUI.lua",
	["lib/managers/menu/items/menuitemcustomizecontroller"] = "MenuItemCustomizeController.lua",

}

-- Required Global Functions
function _G.SafeDoFile( fileName )

	local success, errorMsg = pcall(function()
		dofile( fileName )
	end)

	if not success then
		Print("[Error]\nFile: " .. fileName .. "\n" .. errorMsg)
	end

end

local unsupported = true

-- Load Require and Mod Scripts
if not GoonBase.HasLoadedScripts then

	-- Load required files
	for k, v in pairs( GoonBase.RequireScripts ) do
		SafeDoFile( GoonBase.Path .. v )
	end

	-- Check if version is supported
	GoonBase.SupportedVersion = GoonBase.Updates:IsSupportedVersion()

	-- Run hooks
	if Hooks ~= nil then

		Hooks:RegisterHook("GoonBasePostLoadMods")
		Hooks:Call("GoonBasePostLoadMods")

		Hooks:RegisterHook("GoonBasePostLoadedMods")
		Hooks:Call("GoonBasePostLoadedMods")

	end

	GoonBase.HasLoadedScripts = true

end

-- Load Hook Scripts
if RequiredScript then

	local requiredScript = RequiredScript:lower()
	if GoonBase.HookFiles[requiredScript] then

		if GoonBase.SupportedVersion or (not GoonBase.SupportedVersion and table.contains(GoonBase.RequireHookFiles, requiredScript)) then
		
			if type( GoonBase.HookFiles[requiredScript] ) == "table" then
				for k, v in pairs( GoonBase.HookFiles[requiredScript] ) do
					SafeDoFile( GoonBase.LuaPath .. v )
				end
			else
				SafeDoFile( GoonBase.LuaPath .. GoonBase.HookFiles[requiredScript] )
			end

		end

	end

end

-- END OF FILE
