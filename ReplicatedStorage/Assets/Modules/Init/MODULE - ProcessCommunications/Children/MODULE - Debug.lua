local DebugModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise(Type, Sender, Message)
	-- Functions
	-- INIT
	local ConsoleUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Console")
	
	if ConsoleUiModule then
		return ConsoleUiModule:Add(Type, Sender, Message)
	end
end

-- DIRECT
function DebugModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return DebugModule