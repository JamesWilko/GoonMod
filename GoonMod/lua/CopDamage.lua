
CloneClass( CopDamage )

Hooks:RegisterHook("CopDamagePostInitialize")
function CopDamage.init(self, unit)
	self.orig.init(self, unit)
	Hooks:Call("CopDamagePostInitialize", self, unit)
end

Hooks:RegisterHook("CopDamageSetMoverCollisionState")
function CopDamage.set_mover_collision_state(self, state)
	local r = Hooks:ReturnCall("CopDamageSetMoverCollisionState", self, state)
	if r ~= nil then
		state = r
	end
	self.orig.set_mover_collision_state(self, state)
end

Hooks:RegisterHook("CopDamagePreDamageExplosion")
function CopDamage.damage_explosion(self, attack_data)
	local r = Hooks:ReturnCall("CopDamagePreDamageExplosion", self, attack_data)
	if r ~= nil then
		return
	end
	self.orig.damage_explosion(self, attack_data)
end

Hooks:RegisterHook("CopDamagePostDeath")
function CopDamage.die(self, variant)
	self.orig.die(self, variant)
	Hooks:Call("CopDamagePostDeath", self, variant)
end

Hooks:RegisterHook("CopDamagePostDamageBullet")
function CopDamage.damage_bullet(self, attack_data)
	local res = self.orig.damage_bullet(self, attack_data)
	Hooks:Call("CopDamagePostDamageBullet", self, attack_data, res)
	return res
end
