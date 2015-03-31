
CloneClass( FragGrenade )

Hooks:RegisterHook("FragGrenadePostInit")
function FragGrenade.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("FragGrenadePostInit", self, unit)	
end

Hooks:RegisterHook("FragGrenadeDetonate")
function FragGrenade._detonate(self)
	self._detonate(self)
	Hooks:Call("FragGrenadeDetonate")
end
