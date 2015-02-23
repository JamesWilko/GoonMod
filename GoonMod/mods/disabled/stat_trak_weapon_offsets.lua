
local StatTrak = _G.GoonBase.StatTrak

function StatTrak:GetDefaultOffsets()
	return clone( StatTrak.StandardOffsets )
end

function StatTrak:GetOffsetsForWeaponID(factory_id)

	local offsets = self:GetDefaultOffsets()
	local weapon_offsets = StatTrak.WeaponOffsets[ factory_id ]
	if weapon_offsets == nil then
		Print("[Warning] Weapon factory ID '", tostring(factory_id) ,"' does not exist in weapon offsets table. Using default offsets.")
		return offsets
	end

	offsets.w = weapon_offsets.w or offsets.w
	offsets.h = weapon_offsets.h or offsets.h
	offsets.scale = weapon_offsets.scale or offsets.scale
	offsets.position_offset = weapon_offsets.position_offset or offsets.position_offset
	offsets.rotation_offset = weapon_offsets.rotation_offset or offsets.rotation_offset
	offsets.inspect_position_offset = weapon_offsets.inspect_position_offset or offsets.inspect_position_offset
	offsets.inspect_rotation_offset = weapon_offsets.inspect_rotation_offset or offsets.inspect_rotation_offset

	return offsets

end

StatTrak.StandardOffsets = {
	w = 960,
	h = 240,
	scale = 0.01,
	position_offset = function(parent)
		local rot = parent:rotation()
		return (rot:x() * 0) + (rot:y() * 0) + (rot:z() * 0)
	end,
	rotation_offset = function(parent)
		return Rotation(0, 0, 0)
	end,
	inspect_position_offset = Vector3(40, 10, 0),
	inspect_rotation_offset = Rotation(80, 10, 45),
}

StatTrak.WeaponOffsets = {

	["wpn_fps_pis_1911"] = {
		position_offset = function(parent)
			local rot = parent:rotation()
			return (rot:x() * -1.5) + (rot:y() * 14) + (rot:z() * 7.5)
		end,
		rotation_offset = function(parent)
			return Rotation(-90, 0, 0)
		end,
		inspect_position_offset = Vector3(40, 10, 0),
		inspect_rotation_offset = Rotation(80, 10, 45),
	},

	["wpn_fps_snp_r93"] = {

	},

}
