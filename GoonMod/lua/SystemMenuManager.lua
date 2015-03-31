
local Hooks = Hooks
core:module("SystemMenuManager")

GenericSystemMenuManager.orig = {}
GenericSystemMenuManager.orig.init = GenericSystemMenuManager.init

Hooks:RegisterHook("GenericSystemMenuManagerPostInit")
function GenericSystemMenuManager.init( self )
	Hooks:Call("GenericSystemMenuManagerPostInit", self)
	self.orig.init( self )
end

Hooks:RegisterHook("GenericSystemMenuManagerPreShowNewUnlock")
function GenericSystemMenuManager.show_new_unlock( self, data )
	local r = Hooks:ReturnCall("GenericSystemMenuManagerPreShowNewUnlock", self, data)
	if r ~= nil then
		return
	end
	self.orig.show_new_unlock( self, data )
end
