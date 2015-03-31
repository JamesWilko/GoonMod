
CloneClass( CopActionHurt )

Hooks:RegisterHook("CopActionHurtPostUpdateRagdolled")
function CopActionHurt._upd_ragdolled(self, t)
	self.orig._upd_ragdolled(self, t)
	Hooks:Call("CopActionHurtPostUpdateRagdolled", self, t)
end
