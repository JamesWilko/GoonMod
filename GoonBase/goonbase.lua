----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/4/2015 2:00:55 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

if not RequiredScript then return end

if not _G.GoonBase then
	_G.GoonBase = {}
	GoonBase.Version = 23
	GoonBase.GameVersion = "1.23.3"
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
	"mods/colour_grading.lua",
	"mods/custom_grenades.lua",
	"mods/custom_waypoints.lua",
	"mods/extended_inventory.lua",
	"mods/gage_coins.lua",
	"mods/grenade_indicator.lua",
	"mods/mod_shop.lua",
	"mods/mutators.lua",
	"mods/push_to_interact.lua",
	"mods/trading.lua",
	"mods/train_heist_plans.lua",
	"mods/weapon_customization.lua",
	"mods/weapon_customization_menus.lua",
	"mods/weapon_remember_gadget.lua",
	"mods/zoom_sensitivity.lua",
}

GoonBase.RequireHookFiles = {
	"lib/managers/localizationmanager",
	"lib/managers/menumanager",
	"lib/setups/menusetup"
}

GoonBase.HookFiles = {

	["lib/managers/localizationmanager"] = "LocalizationManager.lua",
	["lib/managers/menumanager"] = "MenuManager.lua",
	["lib/managers/chatmanager"] = "ChatManager.lua",
	["lib/managers/enemymanager"] = "EnemyManager.lua",
	["lib/units/weapons/grenades/quicksmokegrenade"] = "QuickSmokeGrenade.lua",
	["lib/managers/hudmanager"] = "HUDManager.lua",
	["lib/managers/jobmanager"] = "JobManager.lua",
	["lib/managers/groupaimanager"] = "GroupAIManager.lua",
	["lib/managers/group_ai_states/groupaistatebase"] = "GroupAIStateBase.lua",
	["lib/managers/group_ai_states/groupaistatebesiege"] = "GroupAIStateBesiege.lua",
	["lib/units/beings/player/states/playerstandard"] = "PlayerStandard.lua",
	["lib/units/beings/player/playerdamage"] = "PlayerDamage.lua",
	["lib/managers/playermanager"] = "PlayerManager.lua",
	["lib/managers/gageassignmentmanager"] = "GageAssignmentManager.lua",
	["lib/managers/achievmentmanager"] = "AchievementManager.lua",
	["lib/tweak_data/infamytweakdata"] = "InfamyTweakData.lua",
	-- ["lib/setups/setup"] = "Setup.lua",
	["lib/setups/gamesetup"] = "GameSetup.lua",
	["lib/setups/menusetup"] = "MenuSetup.lua",
	["lib/managers/menu/blackmarketgui"] = "BlackMarketGUI.lua",
	["lib/managers/blackmarketmanager"] = "BlackMarketManager.lua",
	["lib/tweak_data/groupaitweakdata"] = "GroupAITweakData.lua",
	["lib/tweak_data/charactertweakdata"] = "CharacterTweakData.lua",
	["lib/units/enemies/cop/copinventory"] = "CopInventory.lua",
	["lib/units/enemies/cop/copdamage"] = "CopDamage.lua",
	["lib/managers/mission/elementlasertrigger"] = "ElementLaserTrigger.lua",
	["lib/units/weapons/weaponflashlight"] = "WeaponFlashlight.lua",
	["lib/units/weapons/weaponlaser"] = "WeaponLaser.lua",
	["lib/tweak_data/levelstweakdata"] = "LevelsTweakData.lua",
	["lib/tweak_data/assetstweakdata"] = "AssetsTweakData.lua",
	["lib/tweak_data/narrativetweakdata"] = "NarrativeTweakData.lua",
	["lib/managers/menu/menunodegui"] = "MenuNodeGUI.lua",
	["lib/managers/menu/items/menuitemcustomizecontroller"] = "MenuItemCustomizeController.lua",
	-- ["lib/network/networkgame"] = "NetworkGame.lua",
	["lib/managers/criminalsmanager"] = "CriminalsManager.lua",
	["lib/units/weapons/newraycastweaponbase"] = "NewRaycastWeaponBase.lua",
	["lib/units/weapons/npcraycastweaponbase"] = "NPCRaycastWeaponBase.lua",
	-- ["lib/units/beings/player/playerinventory"] = "PlayerInventory.lua",
	["lib/units/cameras/fpcameraplayerbase"] = "FPCameraPlayerBase.lua",
	["core/lib/managers/menu/items/coremenuitemslider"] = "CoreMenuItemSlider.lua",
	["lib/utils/game_state_machine/gamestatemachine"] = "GameStateMachine.lua",
	["lib/units/contourext"] = "ContourExt.lua",
	["lib/units/interactions/interactionext"] = "InteractionExt.lua",
	["lib/units/enemies/spooc/actions/lower_body/actionspooc"] = "ActionSpooc.lua",
	["lib/managers/menu/menucomponentmanager"] = "MenuComponentManager.lua",
	["lib/managers/menu/missionbriefinggui"] = "MissionBriefingGUI.lua",
	["lib/network/matchmaking/networkmatchmakingsteam"] = "NetworkMatchMakingSteam.lua",
	-- ["lib/units/maskext"] = "MaskExt.lua",
	["lib/managers/menu/menuscenemanager"] = "MenuSceneManager.lua",

	["lib/units/enemies/cop/actions/full_body/copactionhurt"] = "CopActionHurt.lua",

}

-- Required Global Functions
function _G.Print( ... )

	local str = ""
	for k, v in ipairs( arg ) do
		str = str .. tostring(v)
	end
	str = str .. "\n"
	io.stderr:write( str )

	local file = io.open( GoonBase.LogFile, "a+" )
	if file ~= nil then

		io.output( file )

		if GoonBase._print_cache ~= nil then
			for k, v in ipairs(GoonBase._print_cache) do
				io.write( v )
			end
			GoonBase._print_cache = {}
		end
		io.write( str )

		io.close( file )

	else

		io.stderr:write( "[Error] Could not write to file, caching print string: '" .. str .. "'" )
		if GoonBase._print_cache == nil then
			GoonBase._print_cache = {}
		end
		table.insert( GoonBase._print_cache, str )

	end

end

function io.file_is_readable( fname )
	local file = io.open(fname, "r" )
	if file ~= nil then
		io.close(file)
		return true
	end
	return false
end

function _G.SafeDoFile( fileName )

	local success, errorMsg = pcall(function()
		if io.file_is_readable( fileName ) then
			dofile( fileName )
		else
			Print("[Error] Could not open file '" .. fileName .. "'! Does it exist, is it readable?")
		end
	end)

	if not success then
		Print("[Error]\nFile: " .. fileName .. "\n" .. errorMsg)
	end

end

local unsupported = true

-- Load Require and Mod Scripts
if not GoonBase.HasLoadedScripts then

	-- Check required classes exist now
	if class and Application and string.split then

		GoonBase.HasLoadedScripts = true

		-- Load required files
		for k, v in pairs( GoonBase.RequireScripts ) do
			SafeDoFile( GoonBase.Path .. v )
		end

		-- Check if version is supported
		if GoonBase.Updates ~= nil then
			GoonBase.SupportedVersion = GoonBase.Updates:IsSupportedVersion()
		end

		-- Run hooks
		if Hooks ~= nil then

			Hooks:RegisterHook("GoonBasePostLoadMods")
			Hooks:Call("GoonBasePostLoadMods")

			-- Load default options
			local Options = GoonBase.Options
			if Options:UsingDefaults() then
				Options:LoadDefaults()
			end

			Hooks:RegisterHook("GoonBasePostLoadedMods")
			Hooks:Call("GoonBasePostLoadedMods")
			
		end

	end

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
