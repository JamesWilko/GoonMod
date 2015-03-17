
CloneClass( PlayerProfileGuiObject )

Hooks:RegisterHook("PlayerProfileGuiObjectPostInit")
function PlayerProfileGuiObject.init(self, ws)
	self.orig.init(self, ws)
	Hooks:Call( "PlayerProfileGuiObjectPostInit", self, ws )
end
