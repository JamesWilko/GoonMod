----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NetworkMatchMakingSTEAM )

Hooks:RegisterHook("NetworkMatchmakingSetAttributes")
function NetworkMatchMakingSTEAM.set_attributes(self, settings)
	self.orig.set_attributes(self, settings)
	Hooks:Call("NetworkMatchmakingSetAttributes", self, settings)
	self.lobby_handler:set_lobby_data( self._lobby_attributes )
end

Hooks:RegisterHook("NetworkMatchmakingJoinOKServer")
function NetworkMatchMakingSTEAM.join_server(self, room_id, skip_showing_dialog)
	Hooks:Call("NetworkMatchmakingJoinOKServer", self, room_id, skip_showing_dialog)
	self.orig.join_server(self, room_id, skip_showing_dialog)
end

-- END OF FILE
