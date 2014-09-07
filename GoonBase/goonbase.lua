
if not RequiredScript then return end

local scriptsToLoad = {
	"utils.lua",
	"hooks.lua",
	"network.lua",
	"options.lua",
	"command_queue.lua",
	"localization.lua",

	"lua/SimpleMenu.lua",
	-- "mods/trading.lua",
	-- "ironman.lua",
	-- "lua/CustomWaypoints.lua",
}

local requiredScriptsToLoad = {

	["lib/managers/localizationmanager"] = "LocalizationManager.lua",
	["lib/managers/menumanager"] = "MenuManager.lua",
	["lib/managers/chatmanager"] = "ChatManager.lua",
	["lib/managers/enemymanager"] = "EnemyManager.lua",
	["lib/units/weapons/grenades/quicksmokegrenade"] = "QuickSmokeGrenade.lua",
	["lib/managers/hudmanager"] = "HUDManager.lua",

	-- ["lib/setups/menusetup"] = "MenuSetup.lua",
	-- ["lib/managers/menu/blackmarketgui"] = "BlackMarketGUI.lua",
	-- ["lib/managers/blackmarketmanager"] = "BlackMarketManager.lua",

	-- ["lib/units/civilians/civiliandamage"] = "CivilianDamage.lua",
	-- ["lib/managers/trademanager"] = "TradeManager.lua",
	-- ["lib/managers/hintmanager"] = "HintManager.lua",
	-- ["lib/managers/playermanager"] = "PlayerManager.lua",
	-- ["lib/managers/hud/hudstageendscreen"] = "HUDStageEndScreen.lua",
	-- ["lib/units/beings/player/playerdamage"] = "PlayerDamage.lua",
	-- ["lib/managers/hud/hudblackscreen"] = "HUDBlackScreen.lua",
	-- ["lib/managers/hud/hudmissionbriefing"] = "HUDMissionBriefing.lua",
	-- ["lib/managers/hud/hudplayercustody"] = "HUDPlayerCustody.lua",
	-- ["lib/managers/menu/contractboxgui"] = "ContractBoxGUI.lua",

}

if not _G.GoonBase then
	_G.GoonBase = {}
	_G.GoonBase.Version = "0.01"
	_G.GoonBase.Path = "GoonBase/"
	_G.GoonBase.LuaPath = "GoonBase/lua/"
	_G.GoonBase.SafeMode = true
end

-- Load Scripts
function _G.SafeDoFile( fileName )
	local success, errorMsg = pcall(function()
		dofile( fileName )
	end)
	if not success then
		Print("[Error]\nFile: " .. fileName .. "\n" .. errorMsg)
	end
end

if not GoonBase.HasLoadedScripts then

	for k, v in pairs( scriptsToLoad ) do
		SafeDoFile( GoonBase.Path .. v )
	end

	GoonBase.HasLoadedScripts = true

end

-- Load Post Require Scripts
local requiredScript = RequiredScript:lower()
if requiredScriptsToLoad[requiredScript] then
	
	if type( requiredScriptsToLoad[requiredScript] ) == "table" then
		for k, v in pairs( requiredScriptsToLoad[requiredScript] ) do
			SafeDoFile( GoonBase.LuaPath .. v )
		end
	else
		SafeDoFile( GoonBase.LuaPath .. requiredScriptsToLoad[requiredScript] )
	end

end
