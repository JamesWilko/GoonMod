
_G.GoonBase.Utils = _G.GoonBase.Utils or {}

function GoonBase.Utils:GameUpdateVersionCheck()

	local mod_version = GoonBase.GameVersion:split("[.]")
	local game_version = Application:version():split("[.]")

	if not mod_version or not game_version then
		return false
	end

	for i = 1, 2, 1 do
		if mod_version[i] < game_version[i] then
			return false
		end
	end

	return true

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
