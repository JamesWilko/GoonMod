
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
