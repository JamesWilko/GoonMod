----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
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

Hooks:RegisterHook("PlayerStandardStartActionEquipWeapon")
function PlayerStandard._start_action_equip_weapon(self, t)
	self.orig._start_action_equip_weapon(self, t)
	Hooks:Call("PlayerStandardStartActionEquipWeapon", self, t)
end

Hooks:RegisterHook("PlayerStandardChangingWeapon")
function PlayerStandard._changing_weapon(self)
	self.orig._changing_weapon(self)
	Hooks:Call("PlayerStandardChangingWeapon", self)
end

-- END OF FILE
