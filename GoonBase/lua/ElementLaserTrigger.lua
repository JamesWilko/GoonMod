----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( ElementLaserTrigger )

Hooks:RegisterHook("ElementLaserTriggerPostInit")
function ElementLaserTrigger.init(self, ...)
	self.orig.init(self, ...)
	Hooks:Call("ElementLaserTriggerPostInit", self)
end

Hooks:RegisterHook("ElementLaserTriggerUpdateDraw")
function ElementLaserTrigger.update_laser_draw(self, t, dt)
	self.orig.update_laser_draw(self, t, dt)
	Hooks:Call("ElementLaserTriggerUpdateDraw", self, t, dt)
end
-- END OF FILE
