----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CopActionHurt )

Hooks:RegisterHook("CopActionHurtPostUpdateRagdolled")
function CopActionHurt._upd_ragdolled(self, t)
	self.orig._upd_ragdolled(self, t)
	Hooks:Call("CopActionHurtPostUpdateRagdolled", self, t)
end
-- END OF FILE
