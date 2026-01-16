local CommandModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]

-- Info Modules
local MapsInfoModule = require(SharedInfoModulesFolder["Maps"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function GetMapFromAbbreviation(MapName)
	-- Functions
	-- INIT
	MapName = string.lower(MapName)
	
	for _MapName, MapInfo in pairs(MapsInfoModule:GetAllMapsInfo()) do
		if string.lower(string.sub(_MapName, 1, string.len(MapName))) == MapName then
			return _MapName
		end
	end
end

local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local MapName = GetMapFromAbbreviation(AdminModule:GetMessageFromArgs(Args, 1))
	
	return MainRemote:Fire("ForceMapChange", MapName)
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end

return CommandModule