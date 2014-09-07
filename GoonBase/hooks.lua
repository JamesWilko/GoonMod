
_G.GoonBase.Hooks = _G.GoonBase.Hooks or {}
_G.Hooks = GoonBase.Hooks

function Hooks:RegisterHook( key )
	self[key] = self[key] or {}
end

function Hooks:Add( key, id, func )
	self[key] = self[key] or {}
	self[key][id] = func
end

function Hooks:Remove( id )

	for k, v in pairs(self) do
		if v[id] ~= nil then
			v[id] = nil
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
