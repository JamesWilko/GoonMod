
CloneClass( GroupAIStateBesiege )

Hooks:RegisterHook("GroupAIStateBesiegeInit")
function GroupAIStateBesiege.init(self)
	self.orig.init(self)
	Hooks:Call("GroupAIStateBesiegeInit", self)
end
