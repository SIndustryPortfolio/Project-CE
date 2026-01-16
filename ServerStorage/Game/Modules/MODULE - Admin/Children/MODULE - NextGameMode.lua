local CommandModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function GetGameModeFromAbbreviation(GameModeName)
	-- Functions
	-- INIT
	GameModeName = string.lower(GameModeName)

	for _GameModeName, GameModeInfo in pairs(GameModesInfoModule:GetAllGameModesInfo()) do
		if string.lower(string.sub(_GameModeName, 1, string.len(GameModeName))) == GameModeName then
			return _GameModeName
		end
	end
end

local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local GameModeName = GetGameModeFromAbbreviation(AdminModule:GetMessageFromArgs(Args, 1))

	return MainRemote:Fire("ForceGameModeChange", GameModeName)
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end

return CommandModule