
CloneClass( NetworkGame )

Hooks:RegisterHook("NetworkGamePostLoad")
function NetworkGame.load(self, game_data)
	self.orig.load(self, game_data)
	Hooks:Call("NetworkGamePostLoad", self, game_data)
end

Hooks:RegisterHook("NetworkGameCheckPeerPreferredCharacter")
function NetworkGame.check_peer_preferred_character(self, preferred_character)
	local r = Hooks:ReturnCall("NetworkGameCheckPeerPreferredCharacter", self, preferred_character)
	if r ~= nil then
		return r
	end
	return self.orig.check_peer_preferred_character(self, preferred_character)
end
