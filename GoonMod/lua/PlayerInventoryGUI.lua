
CloneClass( PlayerInventoryGui )

--[[
	Temporary until PlayerInventoryGui decides to decrypt fully instead of stopping half way through the initialization function
]]

Hooks:RegisterHook("PlayerInventoryGUIOnPreviewPrimary")
function PlayerInventoryGui.preview_primary(self, ...)
	local args = ...
	local r = Hooks:ReturnCall("PlayerInventoryGUIOnPreviewPrimary", self, args)
	if r ~= nil then
		return r
	end
	self.orig.preview_primary(self, ...)
end

Hooks:RegisterHook("PlayerInventoryGUIOnPreviewSecondary")
function PlayerInventoryGui.preview_secondary(self, ...)
	local args = ...
	local r = Hooks:ReturnCall("PlayerInventoryGUIOnPreviewSecondary", self, args)
	if r ~= nil then
		return r
	end
	self.orig.preview_secondary(self, ...)
end

Hooks:RegisterHook("PlayerInventoryGUIOnPreviewMelee")
function PlayerInventoryGui.preview_melee(self, ...)
	local args = ...
	local r = Hooks:ReturnCall("PlayerInventoryGUIOnPreviewMelee", self, args)
	if r ~= nil then
		return r
	end
	self.orig.preview_melee(self, ...)
end
