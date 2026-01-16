local ModeChangeModule = {}

-- Dirs
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- REMOTES
local MainRemote = UtilitiesModule:WaitForChildTimed(ServerRemotesFolder, "Main")
local GameProcessRemote = UtilitiesModule:WaitForChildTimed(ClientServerRemotesFolder, "GameProcess")

-- Functions
-- MECHANICS
local function Initialise(Player, AmountToGive)
	-- Functions
	-- INIT
	--[[for i = 1, AmountToGive do
		table.insert(MainLoopModule:GetClientsCanSwitchMap(), Player.UserId)
	end]]
	
	MainRemote:Fire("ModeChange", Player, AmountToGive)
	GameProcessRemote:FireClient(Player, "Game", "LoadPage", "Custom", "ChangeGameMode", true)
end

local function End()
	
end

-- DIRECT
function ModeChangeModule.Initialise(NilParam, Player, AmountToGive)
	return Initialise(Player, AmountToGive)
end

function ModeChangeModule.End()
	
end

return ModeChangeModule