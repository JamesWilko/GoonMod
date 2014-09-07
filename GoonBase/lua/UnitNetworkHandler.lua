
CloneClass( UnitNetworkHandler )

Hooks:RegisterHook("TestNetworkCall")
function UnitNetworkHandler.sync_player_movement_state(this, unit, state, down_time, unit_id_str)
	Hooks:Call("TestNetworkCall", state, down_time, unit_id_str)
	this.orig.sync_player_movement_state(this, unit, state, down_time, unit_id_str)
end

Hooks:Add("TestNetworkCall", "TestNetworkCallTest", function(state, down_time, unit_id_str)
	Print("state: " .. tostring(state))
	Print("down_time: " .. tostring(down_time))
	Print("unit_id_str: " .. tostring(unit_id_str))
end)
