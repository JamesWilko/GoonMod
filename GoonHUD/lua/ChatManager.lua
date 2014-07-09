
CloneClass( ChatManager )

Hooks:RegisterHook( "ChatManagerOnSendMessage" )
function ChatManager.send_message(this, channel_id, sender, message)
	Hooks:Call( "ChatManagerOnSendMessage", channel_id, sender, message )
	this.orig.send_message(this, channel_id, sender, message)
end

Hooks:RegisterHook( "ChatManagerOnReceiveMessage" )
function ChatManager._receive_message(this, channel_id, name, message, color, icon)
	Hooks:Call( "ChatManagerOnReceiveMessage", channel_id, name, message, color, icon )

	if message == "butts" then
		-- SaveTable(managers.menu:active_menu(), {}, "goonhud/active_menu.txt", nil, "")
	end

	this.orig._receive_message(this, channel_id, name, message, color, icon)
end
