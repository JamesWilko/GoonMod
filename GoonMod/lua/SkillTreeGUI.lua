
CloneClass( SkillTreeSkillItem )

Hooks:RegisterHook("SkillTreeSkillItemPostInit")
function SkillTreeSkillItem.init(self, skill_id, tier_panel, num_skills, i, tree, tier, w, h, skill_refresh_skills)
	self.orig.init(self, skill_id, tier_panel, num_skills, i, tree, tier, w, h, skill_refresh_skills)
	Hooks:Call("SkillTreeSkillItemPostInit", self, skill_id, tier_panel, num_skills, i, tree, tier, w, h, skill_refresh_skills)
end

Hooks:RegisterHook("SkillTreeSkillItemPostRefresh")
function SkillTreeSkillItem.refresh(self, locked)
	self.orig.refresh(self, locked)
	Hooks:Call("SkillTreeSkillItemPostRefresh", self, locked)
end
