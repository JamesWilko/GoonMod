
CloneClass( AssetsTweakData )

function AssetsTweakData._init_assets(self, tweak_data)

	self.orig._init_assets(self, tweak_data)

	table.insert(self.bodybags_bag.stages, "arm_for_prof")
	table.insert(self.grenade_crate.stages, "arm_for_prof")

	table.insert(self.arm_for_info.stages, "arm_for_prof")
	table.insert(self.arm_for_ammo.stages, "arm_for_prof")
	table.insert(self.arm_for_health.stages, "arm_for_prof")

end
