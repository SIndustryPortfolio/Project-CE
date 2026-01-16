local CrewMarketplaceModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
--local CrewModule = require(ServerModulesFolder["Crew"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Functions
-- MECHANICS
local function Initialise(Player)
	-- Functions
	-- INIT
	--DebugModule:Print("Marketplace | Crew | Processing Crew for: ".. tostring(Player))
	--CrewModule:CrewMemberAdded(Player)
	Player:SetAttribute("Crew", true)
	return GameProcessRemote:FireClient(Player, "Marketplace", "JoinedCrew")
end

-- DIRECT
function CrewMarketplaceModule.Initialise(NilParam, Player)
	return Initialise(Player)
end

return CrewMarketplaceModule