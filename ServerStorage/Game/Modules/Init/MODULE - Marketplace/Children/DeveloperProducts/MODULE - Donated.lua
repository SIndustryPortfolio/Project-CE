local DonatedModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Modules
local OrderedDataStoreModule = require(ServerModulesFolder["OrderedDataStore"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Functions
-- MECHANICS
local function Initialise(Player, AmountToReward)
	-- Functions
	-- INIT
	GameProcessRemote:FireAllClients("Game", "LogConsole", "Donation", Player, "Donated ".. tostring(AmountToReward).. " robux!")
	return OrderedDataStoreModule:Increment(Player, "Donated", AmountToReward)
end

-- DIRECT
function DonatedModule.Initialise(NilParam, Player, AmountToReward)
	return Initialise(Player, AmountToReward)
end

return DonatedModule