
if not _G.GoonBase then

	_G.GoonBase = {}

	GoonBase.Version = 100
	GoonBase.GameVersion = "1.29.0"
	GoonBase.SupportedVersion = true

	GoonBase.Path = ""
	GoonBase.LuaPath = "lua/"
	GoonBase.RequiresFolder = "req/"
	GoonBase.ModsFolders = {
		"mods/",
		"mods/custom_colours/"
	}
	GoonBase.MenusPath = "menus/"
	GoonBase.LocalizationFolder = "loc/"

	GoonBase.LogFile = "GoonMod.txt"
	GoonBase.SavePath = SavePath .. "goonmod_options.txt"

	GoonBase.LogTag = "[GoonMod]"

end

GoonBase.RequireHookFiles = {
	"lib/managers/menumanager",
	"lib/setups/menusetup"
}

GoonBase.HookFiles = {

	["lib/managers/menumanager"] = "MenuManager.lua",
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
	["lib/managers/criminalsmanager"] = "CriminalsManager.lua",
	["lib/units/weapons/newraycastweaponbase"] = "NewRaycastWeaponBase.lua",
	["lib/units/weapons/npcraycastweaponbase"] = "NPCRaycastWeaponBase.lua",
	["lib/units/cameras/fpcameraplayerbase"] = "FPCameraPlayerBase.lua",
	["core/lib/managers/menu/items/coremenuitemslider"] = "CoreMenuItemSlider.lua",
	["lib/utils/game_state_machine/gamestatemachine"] = "GameStateMachine.lua",
	["lib/units/contourext"] = "ContourExt.lua",
	["lib/units/interactions/interactionext"] = "InteractionExt.lua",
	["lib/units/enemies/spooc/actions/lower_body/actionspooc"] = "ActionSpooc.lua",
	["lib/managers/menu/menucomponentmanager"] = "MenuComponentManager.lua",
	["lib/managers/menu/missionbriefinggui"] = "MissionBriefingGUI.lua",
	["lib/network/matchmaking/networkmatchmakingsteam"] = "NetworkMatchMakingSteam.lua",
	["lib/managers/menu/menuscenemanager"] = "MenuSceneManager.lua",
	["lib/units/enemies/cop/actions/full_body/copactionhurt"] = "CopActionHurt.lua",
	["lib/units/equipment/ecm_jammer/ecmjammerbase"] = "ECMJammerBase.lua",
	["lib/tweak_data/weapontweakdata"] = "WeaponTweakData.lua",
	["lib/units/beings/player/playerinventory"] = "PlayerInventory.lua",
	["lib/tweak_data/skilltreetweakdata"] = "SkillTreeTweakData.lua",
	-- ["lib/managers/gameplaycentralmanager"] = "GameplayCentralManager.lua",
	["lib/managers/systemmenumanager"] = "SystemMenuManager.lua",
	-- ["lib/managers/challengemanager"] = "ChallengeManager.lua",
	["lib/managers/menu/playerprofileguiobject"] = "PlayerProfileGUIObject.lua",
	["lib/managers/menu/walletguiobject"] = "WalletGUIObject.lua",
	["lib/managers/experiencemanager"] = "ExperienceManager.lua",

}

-- Required Global Functions
function _G.Print( ... )

	local str = GoonBase.LogTag
	for k, v in ipairs( arg ) do
		str = str .. tostring(v)
	end

	-- Write to console
	log( str )

	-- Write to log file
	str = str .. "\n"
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

		log( "[Error] Could not write to file, caching print string: '" .. str .. "'" )
		if GoonBase._print_cache == nil then
			GoonBase._print_cache = {}
		end
		table.insert( GoonBase._print_cache, str )

	end

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

	GoonBase.Path = ModPath
	GoonBase.LogFile = LogsPath .. GoonBase.LogFile

	GoonBase.LuaPath = ModPath .. GoonBase.LuaPath
	GoonBase.RequiresFolder = ModPath .. GoonBase.RequiresFolder
	GoonBase.MenusPath = ModPath .. GoonBase.MenusPath
	GoonBase.LocalizationFolder = ModPath .. GoonBase.LocalizationFolder

	-- Check required classes exist now
	if class and Application and string.split then

		GoonBase.HasLoadedScripts = true

		-- Load required files
		local required_files = file.GetFiles( GoonBase.RequiresFolder )
		for k, v in ipairs( required_files ) do
			SafeDoFile( GoonBase.RequiresFolder .. v )
		end

		GoonBase.SupportedVersion = GoonBase.Utils:GameUpdateVersionCheck()

		-- Run hooks
		if GoonBase.SupportedVersion and Hooks ~= nil then

			Hooks:RegisterHook("GoonBaseLoadMods")
			Hooks:Call("GoonBaseLoadMods")

			Hooks:RegisterHook("GoonBasePostLoadedMods")
			Hooks:Call("GoonBasePostLoadedMods")

		end

	end

end

-- Load Hook Scripts
if RequiredScript then

	local requiredScript = RequiredScript:lower()
	if GoonBase.HookFiles[requiredScript] then

		if GoonBase.SupportedVersion or table.contains(GoonBase.RequireHookFiles, requiredScript) then
		
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
