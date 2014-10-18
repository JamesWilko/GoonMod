----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.Utils = _G.GoonBase.Utils or {}

function _G.Print(args)

	local str = tostring( args ) .. "\n"
	io.stderr:write( str )

	local file = io.open( GoonBase.LogFile, "a+" )
	io.output( file )
	io.write( str )
	io.close( file )

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

-- Custom "Base64" Implementation
_G.GoonBase.Utils.Base64 = _G.GoonBase.Utils.Base64 or {}
local Base64 = _G.GoonBase.Utils.Base64
Base64.Characters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
Base64.Encoding = {"j", "a", "m", "e", "s", "w", "i", "l", "k", "o", ".", "c", "o", "m"}

function Base64:Encode(data)

	data = data:gsub(".", function(char) 
		local x, y = '', char:byte()
		for i = 8, 1, -1 do
			x = x .. (y % 2 ^ i - y % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return x
    end)
    data = data ..'0000'
    data = data:gsub("%d%d%d?%d?%d?%d?", function(char)
        if #char < 6 then
        	return ''
        end
        local x = 0
        for i = 1, 6 do
        	x = x + (char:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
        end
        return Base64.Characters:sub(x + 1, x + 1)
    end)
    data = data .. ({ "", "==", "-" })[#data % 3 + 1]

	local str = ""
	local x = 0
	for i = 0, #data do
		local char = data:sub(i, i)
		str = str .. tostring(char)
		if i % 8 == 0 then
			str = str .. Base64.Encoding[x % 14 + 1]
			x = x + 1
		end
	end

	return str

end

function Base64:Decode(data)

	local strs = {}
	local s = ""
	local i = 0
	data:gsub(".", function(char)
		s = s .. char
		i = i + 1
		if i % 9 == 0 then
			table.insert(strs, s)
			s = ""
		end
	end)
	table.insert(strs, s)

	data = ""
	for k, v in pairs( strs ) do
		if v ~= nil and v ~= "" then
			data = data .. v:sub(2, #v)
		end
	end

	data = data:gsub("[^" .. self.Characters .. "=]", "")
	data = data:gsub(".", function(char)
		if char == '=' then
			return ''
		end
		local x, y = '', self.Characters:find(char) - 1
		for i = 6, 1, -1 do
			x = x .. (y % 2 ^ i - y % 2 ^ (i - 1) > 0 and '1' or '0')
		end
		return x
	end)
	data = data:gsub("%d%d%d?%d?%d?%d?%d?%d?", function(char)
		if #char ~= 8 then
			return ''
		end
		local x = 0
		for i = 1, 8 do
			x = x + (char:sub(i, i) == '1' and 2 ^ (8 - i) or 0)
		end
		return string.char(x)
	end)

	return data

end


-- END OF FILE
