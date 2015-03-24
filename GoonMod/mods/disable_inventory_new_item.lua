
-- Mod Definition
local Mod = class( BaseMod )
Mod.id = "DisableInventoryNewItem"
Mod.Name = "Disable New Item Notifications"
Mod.Desc = "Disables the exclamation point icons, and new item unlocked notifications."
Mod.Requirements = {}
Mod.Incompatibilities = {}

Hooks:Add("GoonBaseRegisterMods", "GoonBaseRegisterMutators_" .. Mod:ID(), function()
	GoonBase.Mods:RegisterMod( Mod )
end)

if not Mod:IsEnabled() then
	return
end

-- Hooks
Hooks:Add("BlackMarketGUISlotItemOnRefresh", "BlackMarketGUISlotItemOnRefresh_" .. Mod:ID(), function(self)

	if self._data.new_drop_data then
		local newdrop = self._data.new_drop_data
		if newdrop[1] and newdrop[2] and newdrop[3] then
			managers.blackmarket:remove_new_drop(newdrop[1], newdrop[2], newdrop[3])
			if newdrop.icon then
				newdrop.icon:parent():remove(newdrop.icon)
			end
			self._data.new_drop_data = nil
		end
	end

end)

Hooks:Add("BlackMarketManagerGotAnyNewDrop", "BlackMarketManagerGotAnyNewDrop_" .. Mod:ID(), function(self)
	return false
end)

Hooks:Add("BlackMarketManagerGotNewDrop", "BlackMarketManagerGotNewDrop_" .. Mod:ID(), function(self, global_value, category, id)
	return false
end)

Hooks:Add("GenericSystemMenuManagerPreShowNewUnlock", "GenericSystemMenuManagerPreShowNewUnlock_" .. Mod:ID(), function(self, data)
	return false
end)
