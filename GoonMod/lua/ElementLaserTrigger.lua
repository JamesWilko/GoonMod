
CloneClass( ElementLaserTrigger )

Hooks:RegisterHook("ElementLaserTriggerPostInit")
function ElementLaserTrigger.init(self, ...)
	if self and self.orig then
		self.orig.init(self, ...)
		Hooks:Call("ElementLaserTriggerPostInit", self)
	end
end

Hooks:RegisterHook("ElementLaserTriggerUpdateDraw")
function ElementLaserTrigger.update_laser_draw(self, t, dt)
	if self and self.orig then
		self.orig.update_laser_draw(self, t, dt)
		Hooks:Call("ElementLaserTriggerUpdateDraw", self, t, dt)
	end
end
