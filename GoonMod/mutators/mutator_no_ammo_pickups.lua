
local Mutator = class(BaseMutator)
Mutator.Id = "NoAmmoPickups"
Mutator.OptionsName = "Rationing"
Mutator.OptionsDesc = "Enemies no longer drop ammo. Bulldozers have a chance to drop an ammo bag where they die."
Mutator.AllPlayersRequireMod = true

Mutator.CopDamageInit = "CopDamagePostInitialize_" .. Mutator:ID()
Mutator.CopPostDeath = "CopDamagePostDeath_" .. Mutator:ID()

Mutator.DozersKilledSinceAmmo = 0
Mutator.DropAmmoChance = {
	[1] = 0.08,
	[2] = 0.15,
	[3] = 0.30,
	[4] = 0.65,
	[5] = 1.00,
}

Hooks:Add("GoonBaseRegisterMutators", "GoonBaseRegisterMutators_" .. Mutator:ID(), function()
	GoonBase.Mutators:RegisterMutator( Mutator )
end)

function Mutator:OnEnabled()
	
	Hooks:Add("CopDamagePostInitialize", self.CopDamageInit, function(cop, unit)
		cop:set_pickup(nil)
	end)

	Hooks:Add("CopDamagePostDeath", self.CopPostDeath, function(cop, variant)
		local cop_type = cop._unit:base()._tweak_table
		if cop_type == "tank" then
			Mutator:CheckSpawnAmmoBag( cop._unit )
		end
	end)

end

function Mutator:OnDisabled()
	Hooks:Remove(self.CopDamageInit)
	Hooks:Remove(self.CopPostDeath)
end

function Mutator:CheckSpawnAmmoBag(unit)

	if GoonBase.Network:IsMultiplayer() and GoonBase.Network:IsHost() then

		self.DozersKilledSinceAmmo = self.DozersKilledSinceAmmo + 1
		local dozers = self.DozersKilledSinceAmmo
		if dozers > #self.DropAmmoChance then
			dozers = #self.DropAmmoChance
		end

		if self.DropAmmoChance[ self.DozersKilledSinceAmmo ] > math.random() then
			Mutator:SpawnAmmoBag(unit)
			self.DozersKilledSinceAmmo = 0
		end

	end

end

function Mutator:SpawnAmmoBag(unit)

	local pos = unit:position()
	local rot = Rotation(unit:movement():m_head_rot():yaw(), 0, 0)
	AmmoBagBase.spawn(pos, rot, 0)

end
