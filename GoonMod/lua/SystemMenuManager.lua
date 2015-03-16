
local Hooks = Hooks
core:module("SystemMenuManager")

GenericSystemMenuManager.orig = {}
GenericSystemMenuManager.orig.init = GenericSystemMenuManager.init

Hooks:RegisterHook("GenericSystemMenuManagerPostInit")
function GenericSystemMenuManager.init( self )
	Hooks:Call("GenericSystemMenuManagerPostInit", self)
	self.orig.init( self )
end
