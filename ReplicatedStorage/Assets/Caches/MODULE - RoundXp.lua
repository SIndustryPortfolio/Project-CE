local RoundXpCache = {}

-- CORE
local XpCache = {}

-- Functions
-- MECHANICS
local function Get(Type)
	-- Functions
	-- INIT
	return XpCache[Type]
end

local function Add(Type, Xp)
	-- Functions
	-- INIT
	if not Xp then
		return nil
	end
	
	if not XpCache[Type] then
		XpCache[Type] = 0
	end
	
	XpCache[Type] += Xp
end

local function Clear()
	-- Functions
	-- INIT
	for Key, Value in pairs(XpCache) do
		XpCache[Key] = nil
	end
end

-- DIRECT
function RoundXpCache.Add(NilParam, ...)
	return Add(...)
end

function RoundXpCache.GetAll()
	return XpCache
end

function RoundXpCache.Get(NilParam, ...)
	return Get(...)
end

function RoundXpCache.Clear()
	return Clear()
end

return RoundXpCache