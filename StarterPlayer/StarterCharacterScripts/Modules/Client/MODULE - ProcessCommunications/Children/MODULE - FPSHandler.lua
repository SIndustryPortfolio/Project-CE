local FPSHandlerProcessCommunicationsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local FPSHandlerModule = require(UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSHandler"))

-- Functions
-- MECHANICS
local function Initialise(...)
	-- Functions
	-- INIT
	return FPSHandlerModule:ServerProcess(...)
end

-- DIRECT
function FPSHandlerProcessCommunicationsModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return FPSHandlerProcessCommunicationsModule