----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NetworkGame )

Hooks:RegisterHook("NetworkGameCheckPeerPreferredCharacter")
function NetworkGame.check_peer_preferred_character(self, preferred_character)
	local orig = self.orig.check_peer_preferred_character(self, preferred_character)
	local r = Hooks:ReturnCall("NetworkGameCheckPeerPreferredCharacter", self, preferred_character)
	if r ~= nil then
		return r
	end
	return orig
end

-- END OF FILE
