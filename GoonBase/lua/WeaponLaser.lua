----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( WeaponLaser )

Hooks:RegisterHook("WeaponLaserInit")
function WeaponLaser.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("WeaponLaserInit", self, unit)
end

Hooks:RegisterHook("WeaponLaserUpdate")
function WeaponLaser.update(self, unit, t, dt)
	self.orig.update(self, unit, t, dt)
	Hooks:Call("WeaponLaserUpdate", self, unit, t, dt)
end

Hooks:RegisterHook("WeaponLaserSetNPC")
function WeaponLaser.set_npc(self)
	self.orig.set_npc(self)
	Hooks:Call("WeaponLaserSetNPC", self)
end

Hooks:RegisterHook("WeaponLaserPostSetColorByTheme")
function WeaponLaser.set_color_by_theme(self, theme)
	self.orig.set_color_by_theme(self, theme)
	Hooks:Call("WeaponLaserPostSetColorByTheme", self, theme)
end

-- END OF FILE
