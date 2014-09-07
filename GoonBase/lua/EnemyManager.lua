
CloneClass( EnemyManager )

function EnemyManager._upd_corpse_disposal(this)
	this._MAX_NR_CORPSES = GoonBase.Options.EnemyManager.CustomCorpseLimit and GoonBase.Options.EnemyManager.CurrentMaxCorpses or 8
	this.orig._upd_corpse_disposal(this)
end
