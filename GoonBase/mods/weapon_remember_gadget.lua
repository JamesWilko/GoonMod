----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "RememberGadgetState"
Mod.Name = "Remember Gadget State"
Mod.Desc = "Your weapon gadget will be in the same state as you left it when you switch weapons"
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod.id, function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Data
_G.GoonBase.RememberGadgetState = _G.GoonBase.RememberGadgetState or {}
local Gadget = _G.GoonBase.RememberGadgetState
Gadget.States = {}

-- Hooks
Hooks:Add("PlayerStandardStartActionEquipWeapon", "PlayerStandardStartActionEquipWeapon_WeaponRememberGadget", function(ply, t)

	local weapon_base = ply._equipped_unit:base()
	if weapon_base._has_gadget then
		weapon_base:set_gadget_on(Gadget.States[ weapon_base._factory_id ] or 0, true)
	end

end)

Hooks:Add("PlayerStandardChangingWeapon", "PlayerStandardChangingWeapon_" .. Mod:ID(), function(ply)

	local weapon_base = ply._equipped_unit:base()
	if weapon_base._has_gadget then
		Gadget.States[ weapon_base._factory_id ] = weapon_base._gadget_on or 0
	end

end)
-- END OF FILE
