
_G.GoonHUD.Options = _G.GoonHUD.Options or {}
local Options = _G.GoonHUD.Options
Options.SaveFile = "GoonHUD/options.ini"

Options.EnemyManager = {}
Options.EnemyManager.CustomCorpseLimit = true
Options.EnemyManager.MaxCorpses = 1024
Options.EnemyManager.CurrentMaxCorpses = 256
Options.EnemyManager.ShowGrenadeMarker = false
Options.EnemyManager.UseDefaultGrenadeTimer = true

function Options:GetSaveString()

	local contents = "";
	for k, v in pairs( Options ) do
		
		if type(v) == "table" then
			contents = string.format( "%s[%s]\n", contents, tostring(k) )
			for a, b in pairs( v ) do
				contents = string.format( "%s%s=%s\n", contents, tostring(a), tostring(b) )
			end
		end

	end

	return contents

end

function Options:Save(fileName)

	if fileName == nil then
		fileName = Options.SaveFile
	end

	local file = io.open(fileName, "w")
	file:write( Options:GetSaveString() )
	file:close()

end

function Options:Load(fileName)

	if fileName == nil then
		fileName = Options.SaveFile
	end

	local file = io.open(fileName, 'r')
	local key

	if file == nil then
		Print( "Could not open file (" .. fileName .. ")! Does it exist?" )
		return
	end

	for line in file:lines() do

		local loadKey = line:match('^%[([^%[%]]+)%]$')

		if loadKey then
			key = tonumber(loadKey) and tonumber(loadKey) or loadKey
			Options[key] = Options[key] or {}
		end

		local param, val = line:match('^([%w|_]+)%s-=%s-(.+)$')

		if param and val ~= nil then

			if tonumber(val) then
				val = tonumber(val)
			elseif val == "true" then
				val = true
			elseif val == "false" then
				val = false
			end

			if tonumber(param) then
				param = tonumber(param)
			end

			Options[key][param] = val

		end

	end

	file:close()

end
Options:Load()
