----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( NewRaycastWeaponBase )

Hooks:RegisterHook("NewRaycastWeaponBaseInit")
function NewRaycastWeaponBase.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("NewRaycastWeaponBaseInit", self, unit)
end

Hooks:RegisterHook("NewRaycastWeaponBaseUpdate")
function NewRaycastWeaponBase.update(self, unit, t, dt)
	Hooks:Call("NewRaycastWeaponBaseUpdate", self, unit, t, dt)
end

Hooks:RegisterHook("NewRaycastWeaponBaseSetFactoryData")
function NewRaycastWeaponBase.set_factory_data(self, factory_id)
	self.orig.set_factory_data(self, factory_id)
	Hooks:Call("NewRaycastWeaponBaseSetFactoryData", self, factory_id)
end

-- END OF FILE
