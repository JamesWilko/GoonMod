
CloneClass( NetworkMatchMakingSTEAM )

Hooks:RegisterHook("NetworkMatchmakingSetAttributes")
function NetworkMatchMakingSTEAM.set_attributes(self, settings)
	self.orig.set_attributes(self, settings)
	Hooks:Call("NetworkMatchmakingSetAttributes", self, settings)
	if self.lobby_handler then
		self.lobby_handler:set_lobby_data( self._lobby_attributes )
	end
end

Hooks:RegisterHook("NetworkMatchmakingJoinOKServer")
function NetworkMatchMakingSTEAM.join_server(self, room_id, skip_showing_dialog)
	Hooks:Call("NetworkMatchmakingJoinOKServer", self, room_id, skip_showing_dialog)
	self.orig.join_server(self, room_id, skip_showing_dialog)
end
