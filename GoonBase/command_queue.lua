
_G.GoonBase.CommandQueue = _G.GoonBase.CommandQueue or {}
local Queue = _G.GoonBase.CommandQueue
local GoonNetwork = _G.GoonBase.Network

Queue.CommandQueue = {}

Hooks:Add("MenuUpdate", "MenuUpdate_NetworkQueue", function(t, dt)

	for k, v in pairs( Queue.CommandQueue ) do

		if v ~= nil then

			v.currentTime = v.currentTime + dt
			if v.currentTime > v.timeToWait then
				v.functionCall()
				v = nil
			end

		end

	end

	-- Clear nil or expired commands
	-- local t = {}
	-- for k, v in pairs( Queue.CommandQueue ) do
	-- 	if v ~= nil then
	-- 		if v.currentTime <= v.timeToWait then
	-- 			table.insert(t, v)
	-- 		end
	-- 	end
	-- end
	-- Queue.CommandQueue = t

end)

function Queue:Add(id, func, time)

	local queuedFunc = {
		functionCall = func,
		timeToWait = time,
		currentTime = 0
	}
	Queue.CommandQueue[id] = queuedFunc

end

function Queue:Remove(id)
	Queue.CommandQueue[id] = nil
end
