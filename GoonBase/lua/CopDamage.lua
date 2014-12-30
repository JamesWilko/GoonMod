----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CopDamage )

Hooks:RegisterHook("CopDamagePostInitialize")
function CopDamage.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("CopDamagePostInitialize")
end

Hooks:RegisterHook("CopDamageSetMoverCollisionState")
function CopDamage.set_mover_collision_state(self, state)
	local r = Hooks:ReturnCall("CopDamageSetMoverCollisionState", self, state)
	if r ~= nil then
		state = r
	end
	self.orig.set_mover_collision_state(self, state)
end

Hooks:RegisterHook("CopDamagePreDamageExplosion")
function CopDamage.damage_explosion(self, attack_data)
	local r = Hooks:ReturnCall("CopDamagePreDamageExplosion", self, attack_data)
	if r ~= nil then
		return
	end
	self.orig.damage_explosion(self, attack_data)
end
-- END OF FILE
