
local Hooks = Hooks
local CloneClass = CloneClass
core:module("SystemMenuManager")

CloneClass( GenericSystemMenuManager )

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
