----------
-- Payday 2 GoonMod, Weapon Customizer Beta, built on 12/30/2014 6:10:13 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

CloneClass( HUDManager )

Hooks:RegisterHook("HUDManagerSetStaminaValue")
function HUDManager.set_stamina_value(this, value)
	this.orig.set_stamina_value(this, value)
	Hooks:PCall("HUDManagerSetStaminaValue", this, value)
end

Hooks:RegisterHook("HUDManagerSetMaxStamina")
function HUDManager.set_max_stamina(this, value)
	this.orig.set_max_stamina(this, value)
	Hooks:PCall("HUDManagerSetMaxStamina", this, value)
end

Hooks:RegisterHook("HUDManagerSetMugshotDowned")
function HUDManager.set_mugshot_downed(this, id)
	this.orig.set_mugshot_downed(this, id)
	Hooks:PCall("HUDManagerSetMugshotDowned", this, id)
end

Hooks:RegisterHook("HUDManagerPreAddWaypoint")
function HUDManager.add_waypoint(self, id, data)
	local r = Hooks:ReturnCall("HUDManagerPreAddWaypoint", self, id, data)
	if r then
		return
	end
	return self.orig.add_waypoint(self, id, data)
end

Hooks:RegisterHook("HUDManagerPreAddNameLabel")
function HUDManager._add_name_label(self, data)
	Hooks:Call("HUDManagerPreAddNameLabel", self, data)
	return self.orig._add_name_label(self, data)
end
-- END OF FILE
