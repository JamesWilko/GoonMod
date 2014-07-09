
function _G.GetCrosshairPosition(penetrate, from, to)

	local ray = GetCrosshairRay(penetrate, from, to)

	if not ray then
		return false
	end

	return ray.hit_position

end

function _G.GetCrosshairRay(penetrate, from, to, slotMask)

    if not slotMask then
    	slotMask = "bullet_impact_targets"
    end

    local player = managers.player:player_unit()
    local from = player:camera():position()
    local mvecTo = Vector3()

    mvector3.set( mvecTo, player:camera():forward() )
    mvector3.multiply(mvecTo, 20000)
    mvector3.add(to, from)

    local colRay = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask(slotMask))
    return colRay

end

function _G.GetPlayerAimPos( player )
	local ray = GetCrosshairRay(false, player:position(), player:position() + player:camera():forward() * 50000)
	if not ray then
		return false
	end
	return ray.hit_position
end

Vector3.StringFormat = "%08f,%08f,%08f"
Vector3.MatchFormat = "([-0-9.]+),([-0-9.]+),([-0-9.]+)"
function Vector3.ToString(v)
	return string.format(Vector3.StringFormat, v.x, v.y, v.z)
end

function string.ToVector3(string)
	local x, y, z = string:match( Vector3.MatchFormat )
	if x ~= nil and y ~= nil and z ~= nil then
		return Vector3( tonumber(x), tonumber(y), tonumber(z) )
	end
	return nil
end

_G.GoonHUD.UtilsLoaded = true
