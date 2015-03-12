----------
-- Payday 2 GoonMod, Public Release Beta 2, built on 1/9/2015 9:30:33 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( PlayerStandard )

Hooks:RegisterHook("PlayerStandardCheckActionInteract")
function PlayerStandard._check_action_interact(self, t, input)
	local r = Hooks:ReturnCall("PlayerStandardCheckActionInteract", self, t, input)
	if r ~= nil then
		return r
	end
	return self.orig._check_action_interact(self, t, input)
end

Hooks:RegisterHook("PlayerStandardStartMaskUp")
function PlayerStandard._enter(self, enter_data)
	self.orig._enter(self, enter_data)
	Hooks:Call("PlayerStandardStartMaskUp", self, enter_data)
end

Hooks:RegisterHook("PlayerStandardStartActionEquipWeapon")
function PlayerStandard._start_action_equip_weapon(self, t)
	self.orig._start_action_equip_weapon(self, t)
	Hooks:Call("PlayerStandardStartActionEquipWeapon", self, t)
end

Hooks:RegisterHook("PlayerStandardChangingWeapon")
function PlayerStandard._changing_weapon(self)
	Hooks:Call("PlayerStandardChangingWeapon", self)
	return self.orig._changing_weapon(self)
end

Hooks:RegisterHook("PlayerStandardCheckActionThrowGrenade")
function PlayerStandard._check_action_throw_grenade(self, t, input)
	local r = Hooks:ReturnCall("PlayerStandardCheckActionThrowGrenade", self, t, input)
	if r ~= nil then
		return r
	end
	return self.orig._check_action_throw_grenade(self, t, input)
end
-- END OF FILE
