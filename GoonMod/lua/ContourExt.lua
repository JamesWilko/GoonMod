
CloneClass( ContourExt )

Hooks:RegisterHook("ContourExtPreInitialize")
Hooks:RegisterHook("ContourExtPostInitialize")
function ContourExt.init(self, unit)
	Hooks:Call("ContourExtPreInitialize", self, unit)
	self.orig.init(self, unit)
	Hooks:Call("ContourExtPostInitialize", self, unit)
end

Hooks:RegisterHook("ContourExtPreAdd")
function ContourExt.add(self, type, sync, multiplier)
	local r = Hooks:ReturnCall("ContourExtPreAdd", self, type, sync, multiplier)
	if r ~= nil then
		return
	end
	return self.orig.add(self, type, sync, multiplier)
end
