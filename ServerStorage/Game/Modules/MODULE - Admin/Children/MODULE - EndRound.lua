local CommandModule = {}

-- Dirs
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]

-- Modules
local MainLoopInitModule = require(ServerInitModulesFolder["MainLoop"])

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	return MainLoopInitModule:DisconnectRoundLoop()
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end


return CommandModule