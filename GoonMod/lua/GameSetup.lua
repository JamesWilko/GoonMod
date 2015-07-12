
CloneClass( GameSetup )

Hooks:RegisterHook("GameSetupUpdate")
function GameSetup.update(self, t, dt)
	Hooks:Call("GameSetupUpdate", t, dt)
	return self.orig.update(self, t, dt)
end
