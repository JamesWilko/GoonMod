
CloneClass( MenuSetup )

Hooks:RegisterHook("MenuUpdate")
function MenuSetup.update(self, t, dt)
	self.orig.update(self, t, dt)
	Hooks:Call("MenuUpdate", t, dt)
end
