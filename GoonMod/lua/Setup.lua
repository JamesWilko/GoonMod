
CloneClass( Setup )

Hooks:RegisterHook("SetupOnQuit")
function Setup.quit(self)
	Hooks:Call("SetupOnQuit", self)
	return self.orig.quit(self)
end
