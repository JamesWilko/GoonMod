
CloneClass( NewSkillTreeSkillItem )

Hooks:RegisterHook("NewSkillTreeSkillItemPostInit")
function NewSkillTreeSkillItem.init(self, skill_id, skill_data, skill_panel, tree_panel, tree, tier, fullscreen_panel, gui)
	self.orig.init(self, skill_id, skill_data, skill_panel, tree_panel, tree, tier, fullscreen_panel, gui)
	Hooks:Call("NewSkillTreeSkillItemPostInit", self, skill_id, skill_data, skill_panel, tree_panel, tree, tier, fullscreen_panel, gui)
end

Hooks:RegisterHook("NewSkillTreeSkillItemPostRefresh")
function NewSkillTreeSkillItem.refresh(self)
	self.orig.refresh(self)
	Hooks:Call("NewSkillTreeSkillItemPostRefresh", self)
end
