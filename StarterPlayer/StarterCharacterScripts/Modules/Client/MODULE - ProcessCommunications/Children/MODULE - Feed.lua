local ConsoleModule = {}

-- Dirs
--local CacheFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- CACHES
--local RoundXpCacheModule = require(CacheFolder["RoundXp"])

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function LogOnFeed(...)
	-- CORE
	local HudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")	
	
	-- Functions
	-- INIT
	if HudUiModule then
		HudUiModule:HudProcess("Feed", "Add", ...)
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	InterfacesModule = nil
	
end

-- DIRECT
function ConsoleModule.Initialise(NilParam, ...)
	LogOnFeed(...)
end

function ConsoleModule.GarbageCollect()
	GarbageCollect()
end

return ConsoleModule