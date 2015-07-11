
CloneClass( SavefileManager )

Hooks:RegisterHook("SaveFileManagerOnSave")
function SavefileManager._save(self, slot, cache_only, save_system)
	Hooks:Call("SaveFileManagerOnSave", self, slot, cache_only, save_system)
	return self.orig._save(self, slot, cache_only, save_system)
end
