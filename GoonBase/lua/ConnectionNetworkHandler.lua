
CloneClass(ConnectionNetworkHandler)

_G.GoonHUD.Network = _G.GoonHUD.Network or {}
local GoonNetwork = _G.GoonHUD.Network

-- Overload this function since it only runs on specific states on an unmodded client
-- State 0 checks for correct type and ID, wont run with custom types/IDs
Hooks:RegisterHook("NetworkManagerOnCustomHookReceived")
function ConnectionNetworkHandler.preplanning_reserved(this, type, id, peer_id, state, sender)

	if not this._verify_sender(sender) then
		return
	end

	-- Base States
	if state == 0 then
		managers.preplanning:client_reserve_mission_element(type, id, peer_id)
	elseif state == 1 then
		managers.preplanning:client_unreserve_mission_element(id)
	elseif state == 2 then
		managers.preplanning:client_vote_on_plan(type, id, peer_id)
	end

	-- Call hook
	Hooks:Call("NetworkManagerOnCustomHookReceived", this, type, id, peer_id, state, sender)

end

Hooks:Add("NetworkManagerOnCustomHookReceived", "OnCustomHookReceived_Example", function(networkHandler, msgType, id, peer_id, state, sender)

	-- Print("Type: " .. tostring(msgType))
	-- Print("ID: " .. tostring(id))
	-- Print("Peer ID: " .. tostring(peer_id))
	-- Print("State: " .. tostring(state))
	-- Print("----")

end)

function GoonNetwork:SendToPeers(msgType, id)
	--managers.network:session():send_to_peers("preplanning_reserved", msgType, id, managers.network:session():local_peer():id(), 0)
	managers.network:session():send_to_host("preplanning_reserved", msgType, id, managers.network:session():local_peer():id(), 0)
end

function GoonNetwork:SendToPeer(peer, msgType, id)
	managers.network:session():send_to_peer(peer, "preplanning_reserved", msgType, id, managers.network:session():local_peer():id(), 0)
end
