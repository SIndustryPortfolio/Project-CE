local ConsoleModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function LogOnConsole(...)
	-- CORE
	local ConsoleUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Console")	
	
	-- Functions
	-- INIT
	if ConsoleUiModule then
		ConsoleUiModule:Add(...)
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
	LogOnConsole(...)
end

function ConsoleModule.GarbageCollect()
	GarbageCollect()
end

return ConsoleModule