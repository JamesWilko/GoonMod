----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 12/21/2014 1:04:58 AM
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
