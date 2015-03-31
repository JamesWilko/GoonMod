
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

Hooks:RegisterHook("WeaponLaserSetOn")
Hooks:RegisterHook("WeaponLaserSetOff")
function WeaponLaser._check_state(self)
	self.orig._check_state(self)
	if self._on then
		Hooks:Call("WeaponLaserSetOn", self)
	else
		Hooks:Call("WeaponLaserSetOff", self)
	end
end
