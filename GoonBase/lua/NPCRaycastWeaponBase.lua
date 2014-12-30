----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NPCRaycastWeaponBase )

Hooks:RegisterHook("NPCRaycastWeaponBaseInit")
function NPCRaycastWeaponBase.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("NPCRaycastWeaponBaseInit", self, unit)
end
--[[ dunno if these exist for enemy weapons but whatever
Hooks:RegisterHook("NPCRaycastWeaponBaseUpdate")
function NPCRaycastWeaponBase.update(self, unit, t, dt)
	Hooks:Call("NPCRaycastWeaponBaseUpdate", self, unit, t, dt)
end

Hooks:RegisterHook("NPCRaycastWeaponBaseSetFactoryData")
function NPCRaycastWeaponBase.set_factory_data(self, factory_id)
	self.orig.set_factory_data(self, factory_id)
	Hooks:Call("NPCRaycastWeaponBaseSetFactoryData", self, factory_id)
end
]]--
-- END OF FILE
