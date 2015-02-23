
CloneClass( EnemyManager )

Hooks:RegisterHook( "EnemyManagerPreUpdateCorpseDisposal" )
function EnemyManager._upd_corpse_disposal(this)
	Hooks:Call("EnemyManagerPreUpdateCorpseDisposal", this)
	this.orig._upd_corpse_disposal(this)
end

Hooks:RegisterHook("EnemyManagerInitEnemyData")
function EnemyManager._init_enemy_data(self)
	self.orig._init_enemy_data(self)
	Hooks:Call("EnemyManagerInitEnemyData", self)
end
