----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( WeaponFlashLight )

Hooks:RegisterHook("WeaponFlashLightInit")
function WeaponFlashLight.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("WeaponFlashLightInit", self, unit)
end

function WeaponFlashLight._check_state(self)
    self._unit:set_extension_update_enabled( Idstring("base"), self._on )
    self.orig._check_state(self)
end

Hooks:RegisterHook("WeaponFlashLightUpdate")
function WeaponFlashLight:update(unit, t, dt)
    Hooks:Call( "WeaponFlashLightUpdate", self, unit, t, dt )
end

-- END OF FILE
