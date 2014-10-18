----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( ChatManager )

Hooks:RegisterHook( "ChatManagerOnSendMessage" )
function ChatManager.send_message(this, channel_id, sender, message)
	Hooks:Call( "ChatManagerOnSendMessage", channel_id, sender, message )
	this.orig.send_message(this, channel_id, sender, message)
end

Hooks:RegisterHook( "ChatManagerOnReceiveMessage" )
function ChatManager._receive_message(this, channel_id, name, message, color, icon)
	Hooks:Call( "ChatManagerOnReceiveMessage", channel_id, name, message, color, icon )
	this.orig._receive_message(this, channel_id, name, message, color, icon)
end

-- END OF FILE
