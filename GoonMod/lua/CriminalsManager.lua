
CloneClass( CriminalsManager )

Hooks:Call("CriminalsManagerNumberOfTakenCriminals")
function CriminalsManager.nr_taken_criminals(self)
	local orig = self.orig.nr_taken_criminals(self)
	local r = Hooks:ReturnCall("CriminalsManagerNumberOfTakenCriminals", self)
	if r ~= nil then
		return r
	end
	return orig
end
