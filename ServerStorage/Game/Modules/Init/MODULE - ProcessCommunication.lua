local ProcessCommunicationModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Modules
local ShopModule = require(ServerModulesFolder["Shop"])
local LobbyModule = require(ServerModulesFolder["Lobby"])
local PlayerManagementModule = require(ServerModulesFolder["PlayerManagement"])
local TeamsModule = require(ServerModulesFolder["Teams"])
local DevicesModule = require(ServerModulesFolder["Devices"])
local StatisticsModule = require(ServerModulesFolder["Statistics"])
local MainLoopModule = require(ServerInitModulesFolder["MainLoop"])
local InventoryModule = require(ServerModulesFolder["Inventory"])
local CrewModule = require(ServerModulesFolder["Crew"])
local RedeemCodesModule = require(ServerModulesFolder["RedeemCodes"])
local WebhookModule = require(ServerModulesFolder["Webhook"])

-- Functions
-- CORE FUNCTIONS
local ClientProcesses = 
{
	["Webhook"] = function(Player, ...)
		return WebhookModule:ClientRequest(Player, ...)		
	end,
	["RedeemCodes"] = function(Player, ...)
		return RedeemCodesModule:ClientRequest(Player, ...)		
	end,
	["Crew"] = function(Player, FunctionName, ...)
		return CrewModule:ClientRequest(Player, FunctionName, ...)
	end,
	["Shop"] = function(Player, FunctionName, ...)
		return ShopModule:ClientRequest(Player, FunctionName, ...)
	end,
	["Inventory"] = function(Player, FunctionName, ...)
		return InventoryModule:ClientRequest(Player, FunctionName, ...)	
	end,
	["Lobby"] = function(Player, FunctionName, ...)
		return LobbyModule:ClientRequest(Player, FunctionName, ...)
	end,
	["Settings"] = function(Player, FunctionName, ...)
		return PlayerManagementModule:PlayerProcess("Settings", "ClientRequest", FunctionName, Player, ...)
	end,
	["Statistics"] = function(Player, FunctionName, ...)
		return StatisticsModule:ClientRequest(Player, FunctionName, ...)
	end,
	["SwitchTeam"] = function(Player, TeamName)
		return TeamsModule:ClientRequest(Player, "Switch", TeamName)
	end,
	["Devices"] = function(Player, FunctionName, ...)
		return DevicesModule:ClientRequest(Player, FunctionName, ...)
	end,
	["MainLoop"] = function(Player, FunctionName, ...)
		return MainLoopModule:ClientRequest(Player, FunctionName, ...)
	end,
}

-- MECHANICS
local function OnGameProcessRemoteFired(Player, FunctionName, ...)
	return ClientProcesses[FunctionName](Player, ...)
end

-- CONNECTIONS
GameProcessRemote.OnServerEvent:Connect(OnGameProcessRemoteFired)


return ProcessCommunicationModule