----------
-- Payday 2 GoonMod, Public Release Beta 1, built on 10/18/2014 6:25:56 PM
-- Copyright 2014, James Wilkinson, Overkill Software
----------

_G.GoonBase.CommandQueue = _G.GoonBase.CommandQueue or {}
_G.Queue = _G.GoonBase.CommandQueue
local Queue = _G.GoonBase.CommandQueue
local GoonNetwork = _G.GoonBase.Network

Queue.CommandQueue = {}

Hooks:Add("MenuUpdate", "MenuUpdate_Queue", function(t, dt)
	Queue:Update(t, dt)
end)

Hooks:Add("GameSetupUpdate", "GameSetupUpdate_Queue", function(t, dt)
	Queue:Update(t, dt)
end)

function Queue:Update(time, deltaTime)

	-- Update
	for k, v in pairs( Queue.CommandQueue ) do

		if v ~= nil then

			v.currentTime = v.currentTime + deltaTime
			if v.currentTime > v.timeToWait then
				v.functionCall()
				v = nil
			end

		end

	end

	-- Clear nil or expired commands
	local t = {}
	for k, v in pairs( Queue.CommandQueue ) do
		if v ~= nil then
			if v.currentTime <= v.timeToWait then
				table.insert(t, v)
			end
		end
	end
	Queue.CommandQueue = t

end

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

-- END OF FILE
