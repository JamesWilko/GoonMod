
CloneClass( ChatManager )

Hooks:RegisterHook( "ChatManagerOnSendMessage" )
function ChatManager.send_message(this, channel_id, sender, message)
	Hooks:Call( "ChatManagerOnSendMessage", channel_id, sender, message )

	if message == "a" then

		Print( "Local Peer ID: " .. managers.network:session():local_peer():id() )
		local success, err = pcall(function()
		for k, v in pairs(managers.network:session():peers()) do
			Print("Peer " .. tostring(k) .. ": " .. tostring(v:name()))
		end
		end)
		if not success then Print(err) end

	end

	this.orig.send_message(this, channel_id, sender, message)
end

Hooks:RegisterHook( "ChatManagerOnReceiveMessage" )
function ChatManager._receive_message(this, channel_id, name, message, color, icon)
	Hooks:Call( "ChatManagerOnReceiveMessage", channel_id, name, message, color, icon )

	if message == "butts" then
		local num_winners = managers.network:game():amount_of_alive_players()
		managers.network:session():send_to_peers( "mission_ended", true, num_winners )
		game_state_machine:change_state_by_name( "victoryscreen", { num_winners = num_winners, personal_win = true } )
	end

	if message == "die" then

		for k, ply in pairs( managers.groupai:state():all_player_criminals() ) do
			ply.unit:character_damage():damage_fall({height = 1000})
		end
		return

	end

	this.orig._receive_message(this, channel_id, name, message, color, icon)
end
