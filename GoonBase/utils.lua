
function _G.Print(args)
	io.stderr:write( tostring(args) .. "\n" )
end

function _G.CloneClass(class)
	if not class.orig then
		class.orig = clone(class)
	end
end

function _G.PrintTable (tbl, cmp)
	cmp = cmp or {}
	if type(tbl) == "table" then
		for k, v in pairs (tbl) do
			if type(v) == "table" and not cmp[v] then
				cmp[v] = true
				Print( string.format("[\"%s\"] -> table", tostring(k)) );
				PrintTable (v, cmp)
			else
				Print( string.format("\"%s\" -> %s", tostring(k), tostring(v)) )
			end
		end
	else Print(tbl) end
end

function _G.SaveTable(tbl, file)
	DoSaveTable(tbl, {}, file, nil, "")
end

function _G.DoSaveTable(tbl, cmp, fileName, fileIsOpen, preText)

	local file = nil
	if fileIsOpen == nil then
		file = io.open(fileName, "w")
	else
		file = fileIsOpen
	end

	cmp = cmp or {}
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			if type(v) == "table" and not cmp[v] then
				cmp[v] = true
				file:write( preText .. string.format("[\"%s\"] -> table", tostring (k)) .. "\n" )
				DoSaveTable(v, cmp, fileName, file, preText .. "\t")
			else
				file:write( preText .. string.format( "\"%s\" -> %s", tostring(k), tostring(v) ) .. "\n" )
			end
		end
	else
		file:write( preText .. tbl .. "\n")
	end

	if fileIsOpen == nil then
		file:close()
	end

end

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
