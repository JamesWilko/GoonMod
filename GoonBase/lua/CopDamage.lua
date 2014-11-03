----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 11/3/2014 6:23:30 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( CopDamage )

Hooks:RegisterHook("CopDamageSetMoverCollisionState")
function CopDamage.set_mover_collision_state(self, state)
	local r = Hooks:ReturnCall("CopDamageSetMoverCollisionState", self, state)
	if r ~= nil then
		state = r
	end
	self.orig.set_mover_collision_state(self, state)
end

-- END OF FILE
