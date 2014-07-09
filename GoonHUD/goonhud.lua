
if not RequiredScript then return end

local scriptsToLoad = {
	"CustomWaypoints.lua",
}

local requiredScriptsToLoad = {
	["lib/managers/systemmenumanager"] = "SimpleMenu.lua",
	["lib/managers/chatmanager"] = "ChatManager.lua",
	["lib/managers/enemymanager"] = "EnemyManager.lua",
	["lib/managers/menumanager"] = "MenuManager.lua",
	["lib/managers/localizationmanager"] = "LocalizationManager.lua",
	["lib/managers/preplanningmanager"] = "PreplanningManager.lua",
	["lib/tweak_data/preplanningtweakdata"] = "PreplanningTweakData.lua"
}

-- HUD
_G.GoonHUD = {}
_G.GoonHUD.Version = "0.01"

-- Load Utils
if not _G.GoonHUD.UtilsLoaded then
	dofile( "GoonHud/util.lua" )
end

function _G.Print(args)
	io.stderr:write( tostring(args) .. "\n" )
end

function _G.CloneClass(class)
	if not class.orig then
		class.orig = clone(class)
	end
end

function _G.PrintTable (tbl, cmp)
    cmp = cmp or {}
    if type(tbl) == "table" then
        for k, v in pairs (tbl) do
            if type(v) == "table" and not cmp[v] then
                cmp[v] = true
                Print( string.format("[\"%s\"] -> table", tostring(k)) );
                PrintTable (v, cmp)
            else
                Print( string.format("\"%s\" -> %s", tostring(k), tostring(v)) )
            end
        end
    else Print(tbl) end
end

function _G.SaveTable(tbl, cmp, fileName, fileIsOpen, preText)

	local file = nil
	if fileIsOpen == nil then
		file = io.open(fileName, "w")
	else
		file = fileIsOpen
	end

	cmp = cmp or {}
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            if type(v) == "table" and not cmp[v] then
                cmp[v] = true
                file:write( preText .. string.format("[\"%s\"] -> table", tostring (k)) .. "\n" )
                SaveTable(v, cmp, fileName, file, preText .. "\t")
            else
                file:write( preText .. string.format( "\"%s\" -> %s", tostring(k), tostring(v) ) .. "\n" )
            end
        end
    else
    	file:write( preText .. tbl .. "\n")
    end

    if fileIsOpen == nil then
    	file:close()
    end

end

-- Load Options
if not _G.GoonHUD.Options then 
	dofile( "GoonHud/options.lua" )
end

-- Load Localization
if not _G.GoonHUD.Localization then
	dofile( "GoonHud/localization.lua" )
end

-- Hooks
if not _G.GoonHUD.Hook then
	_G.GoonHUD.Hooks = {}
end
if not _G.Hooks then
	_G.Hooks = GoonHUD.Hooks
end

function Hooks:RegisterHook( key )
	self[key] = self[key] or {}
end

function Hooks:Add( key, id, func )
	self[key] = self[key] or {}
	self[key][id] = func
end

function Hooks:Remove( id )

	for k, v in pairs(self) do
		if v[id] ~= nil then
			v[id] = nil
		end
	end

end

function Hooks:Call( key, ... )

	if self[key] ~= nil then
		for k, v in pairs(self[key]) do
			if v ~= nil and type(v) == "function" then
				v( ... )
			end
		end
	end

end

-- Load Scripts
local path = "GoonHud/lua/"
local requiredScript = RequiredScript:lower()
if requiredScriptsToLoad[requiredScript] then
	
	if type( requiredScriptsToLoad[requiredScript] ) == "table" then
		for k, v in pairs( requiredScriptsToLoad[requiredScript] ) do
			dofile( path .. v )
		end
	else
		dofile( path .. requiredScriptsToLoad[requiredScript] )
	end

end

if not _G.GoonHUDHasLoadedScripts then

	for k, v in pairs( scriptsToLoad ) do
		dofile( path .. v )
	end

end
