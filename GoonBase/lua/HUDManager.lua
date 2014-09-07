
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
