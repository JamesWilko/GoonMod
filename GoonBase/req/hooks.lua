----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:02:05 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.Hooks = _G.GoonBase.Hooks or {}
_G.Hooks = GoonBase.Hooks

function Hooks:RegisterHook( key )
	self[key] = self[key] or {}
end

function Hooks:Register( key )
	self:RegisterHook( key )
end

function Hooks:AddHook( key, id, func )
	self:Add( key, id, func )
end

function Hooks:Add( key, id, func )
	self[key] = self[key] or {}
	self[key][id] = func
end

function Hooks:Remove( id )

	for k, v in pairs(self) do
		if k[id] ~= nil then
			k[id] = nil
		end
	end

end

function Hooks:Call( key, ... )

	if self[key] ~= nil then
		for k, v in pairs(self[key]) do
			if v ~= nil and type(v) == "function" then
				v( ... )
			end
		end
	end

end

function Hooks:ReturnCall( key, ... )

	if self[key] ~= nil then
		for k, v in pairs(self[key]) do
			if v ~= nil and type(v) == "function" then

				local r = v( ... )
				if r ~= nil then
					return r
				end

			end
		end
	end

end

function Hooks:PCall( key, ... )

	if self[key] ~= nil then
		for k, v in pairs(self[key]) do
			if v ~= nil and type(v) == "function" then
				local args = ...
				local success, err = pcall( function() v( args ) end )
				if not success then
					Print("[Error]\nHook: " .. k .. "\n" .. err)
				end
			end
		end
	end

end

-- END OF FILE
