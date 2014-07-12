
CloneClass( ChatManager )

Hooks:RegisterHook( "ChatManagerOnSendMessage" )
function ChatManager.send_message(this, channel_id, sender, message)
	Hooks:Call( "ChatManagerOnSendMessage", channel_id, sender, message )
	this.orig.send_message(this, channel_id, sender, message)
end

Hooks:RegisterHook( "ChatManagerOnReceiveMessage" )
function ChatManager._receive_message(this, channel_id, name, message, color, icon)
	Hooks:Call( "ChatManagerOnReceiveMessage", channel_id, name, message, color, icon )

	if message == "/flash" then

		local success, err = pcall(function()
			local detonate_pos = GetPlayerAimPos( managers.player:player_unit() )
			local rotation = Rotation()
			local flash_grenade = World:spawn_unit(Idstring("units/weapons/flash_grenade_quick/flash_grenade_quick"), detonate_pos, Rotation())
			flash_grenade:base():activate(detonate_pos, 5)
		end)
		if not success then
			Print("Error: " .. err)
		end

	end

	this.orig._receive_message(this, channel_id, name, message, color, icon)
end
