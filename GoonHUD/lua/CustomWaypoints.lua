
local CustomWaypointText = "GoonHUDWaypoint"
local CustomWaypointTextRemove = "RemoveGoonHUDWaypoint"
local CustomWaypointSplit = '/'

function _G.GoonHUD.PlaceCustomWaypoint()
	local pos = GetPlayerAimPos( managers.player:player_unit() )
	local posString = Vector3.ToString(pos)
	local message = CustomWaypointText .. CustomWaypointSplit .. posString
	ChatManager:send_message( ChatManager.GLOBAL, managers.player:player_unit():nick_name(), message )
end

function _G.GoonHUD.RemoveCustomWaypoint()
	ChatManager:send_message( ChatManager.GLOBAL, managers.player:player_unit():nick_name(), CustomWaypointTextRemove )
end

Hooks:Add( "ChatManagerOnReceiveMessage", "CustomWaypoint_OnReceiveMessage", function(channel_id, name, message, color, icon)

	-- Add Waypoint
	local messageHead, messageContent = message:match("(" .. CustomWaypointText .. ")/([^/]+)")
	if messageHead ~= nil and messageContent ~= nil then

		local pos = string.ToVector3(messageContent)
		if pos ~= nil then

			local col = color
			managers.hud:add_waypoint(
				'CustomWaypoint_' .. name,
				{ icon = 'infamy_icon', distance = true, position = pos, no_sync = false, present_timer = 0, state = "present", radius = 50, color = col, blend_mode = "add" } 
			)

			-- Dont show chat message
			return false

		end

	end

	-- Remove Waypoint
	if message == CustomWaypointTextRemove then
		managers.hud:remove_waypoint('CustomWaypoint_' .. name)
	end

end )
