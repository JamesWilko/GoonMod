
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "CustomWaypoints"
Mod.Name = "Custom Waypoints"
Mod.Desc = "Allows players to set waypoints for themselves and friends"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Custom Waypoints
_G.GoonBase.CustomWaypoints = _G.GoonBase.CustomWaypoints or {}
local CustomWaypoints = _G.GoonBase.CustomWaypoints
CustomWaypoints.MenuFile = "custom_waypoints_menu.txt"

-- Network 
CustomWaypoints.Network = {}
CustomWaypoints.Network.PlaceWaypoint = "CustomWaypointPlace"
CustomWaypoints.Network.RemoveWaypoint = "CustomWaypointRemove"

-- Options
GoonBase.Options.CustomWaypoints 				= GoonBase.Options.CustomWaypoints or {}
GoonBase.Options.CustomWaypoints.ShowDistance 	= GoonBase.Options.CustomWaypoints.ShowDistance
if GoonBase.Options.CustomWaypoints.ShowDistance == nil then
	GoonBase.Options.CustomWaypoints.ShowDistance = true
end

-- Menu
Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_" .. Mod:ID(), function( menu_manager )

	MenuCallbackHandler.ToggleWaypointShowDistance = function(this, item)
		GoonBase.Options.CustomWaypoints.ShowDistance = item:value() == "on" and true or false
	end

	CustomWaypoints.DoPlaceWaypoint = function(self)
		if Utils:IsInGameState() then
			CustomWaypoints:SetWaypoint()
		end
	end

	CustomWaypoints.DoRemoveWaypoint = function(self)
		if Utils:IsInGameState() then
			CustomWaypoints:RemoveWaypoint()
		end
	end

	MenuHelper:LoadFromJsonFile( GoonBase.MenusPath .. CustomWaypoints.MenuFile, CustomWaypoints, GoonBase.Options.CustomWaypoints )

end)


-- Waypoints
function CustomWaypoints:_AddWaypoint( waypoint_name, pos, color_id )
	managers.hud:add_waypoint(
		"CustomWaypoint_" .. waypoint_name,
		{
			icon = "infamy_icon",
			distance = GoonBase.Options.CustomWaypoints.ShowDistance,
			position = pos,
			no_sync = false,
			present_timer = 0,
			state = "present",
			radius = 50,
			color = tweak_data.preplanning_peer_colors[color_id or 1],
			blend_mode = "add"
		} 
	)
end

function CustomWaypoints:_RemoveWaypoint( waypoint_name )
	managers.hud:remove_waypoint("CustomWaypoint_" .. waypoint_name)
end

function CustomWaypoints:SetWaypoint()

	if managers.player:player_unit() == nil then
		return
	end

	local pos = Utils:GetPlayerAimPos( managers.player:player_unit() )
	if not pos then
		return
	end

	CustomWaypoints:_AddWaypoint( "localplayer", pos, LuaNetworking:LocalPeerID() )

	pos = Vector3.ToString( pos )
	LuaNetworking:SendToPeers( CustomWaypoints.Network.PlaceWaypoint, pos )

end

function CustomWaypoints:RemoveWaypoint()
	LuaNetworking:SendToPeers( CustomWaypoints.Network.RemoveWaypoint, "" )
	CustomWaypoints:_RemoveWaypoint( "localplayer" )
end

function CustomWaypoints:NetworkPlace( player, position )

	if player then

		local ply_name = LuaNetworking:GetNameFromPeerID(player)
		local pos = string.ToVector3(position)
		if pos ~= nil then
			CustomWaypoints:_AddWaypoint( ply_name, pos, player )
		end

	end

end

function CustomWaypoints:NetworkRemove(player)
	local ply_name = LuaNetworking:GetNameFromPeerID(player)
	CustomWaypoints:_RemoveWaypoint( ply_name )
end

-- Networked Data
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_" .. Mod:ID(), function(sender, messageType, data)

	if messageType == CustomWaypoints.Network.PlaceWaypoint then
		CustomWaypoints:NetworkPlace(sender, data)
	end

	if messageType == CustomWaypoints.Network.RemoveWaypoint then
		CustomWaypoints:NetworkRemove(sender)
	end

end)
