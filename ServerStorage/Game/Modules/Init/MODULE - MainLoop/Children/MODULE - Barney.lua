local InfectionModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedGameDeployedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Deployed"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local GameModule = require(ServerModulesFolder["Game"])
local TeamsModule = require(ServerModulesFolder["Teams"])

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]

-- SIGNALS
local GameModeSignal = ServerSignalsFolder["GameMode"]

-- CORE
local Connections = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function AddToCache(Player, _Connections)
	-- Functions
	-- INIT
	if Connections[Player] == nil then
		Connections[Player] = {}
	end
	
	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Player], Connection)
	end
end

local function RemoveFromCache(Player)
	-- Functions
	-- INIT
	if Connections[Player] ~= nil then
		UtilitiesModule:DisconnectConnections(Connections[Player])
		Connections[Player] = nil
	end
end

local function LastManStanding(Player)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	CollectionService:AddTag(Character, "LastManStanding")
	
	--[[local HeadPart = UtilitiesModule:WaitForChildTimed(Character, "Head")
	
	if HeadPart:FindFirstChild("Marker") then
		return nil
	end
	
	InterfacesModule:LoadBillboard(HeadPart, "Marker", "rbxassetid://11328827586")]]
end

local function CheckIfRoundEnd()
	-- CORE
	local Survivors = {}
	
	-- Functions
	-- INIT
	local RoundEnd = true
	
	for i, PlayerDeployedValue in pairs(SharedGameDeployedFolder:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerDeployedValue.Name)
		
		if not Player then
			continue
		end
		
		local PlayerTeam = Player.Team
		
		if PlayerTeam and PlayerTeam.Name ~= "Barney" then
			RoundEnd = false
			table.insert(Survivors, Player)
		end
	end
	
	if #Survivors == 1 then
		LastManStanding(unpack(Survivors))
	end
	
	return RoundEnd
end

local function OnPlayerKilled(Player)
	-- Functions
	-- INIT
	local PlayerTeam = Player.Team

	if PlayerTeam and PlayerTeam.Name ~= "Barney" then
		TeamsModule:SwitchTeam(Player, "Barney")
	end
	
	local Result = CheckIfRoundEnd()
	
	if Result then
		MainRemote:Fire("DisconnectRoundLoop")
	end
end

local function SetupPlayerConnections(Player)
	if not Player then
		return nil
	end
	
	-- CORE
	local PlayerLobbyValue = UtilitiesModule:WaitForChildTimed(SharedGameLobbyFolder, Player.Name)
	--local PlayerTeam = Player.Team
	
	-- Functions
	-- DIRECT
	local Connection1 = PlayerLobbyValue:GetAttributeChangedSignal("Kills"):Connect(function()
		PlayerLobbyValue:SetAttribute("Score", PlayerLobbyValue:GetAttribute("Kills"))
		--GameModule:UpdateTotalScore(PlayerTeam)
	end)
	
	--[[local Connection2 = PlayerLobbyValue:GetAttributeChangedSignal("Deaths"):Connect(function()
		OnPlayerDied(Player)
	end)]]
	
	-- INIT
	AddToCache(Player, {Connection1--[[, Connection2]]})
end


local function GetKillType(Murdered, Murderer, CurrentKillType)
	-- Functions
	-- INIT
	local BlacklistedKillTypes = {" suicide ", " betrayed "}
	
	if table.find(BlacklistedKillTypes, CurrentKillType) then
		return nil
	end
	
	if Murdered and Murdered.Team and Murdered.Team.Name == "Runner" and Murderer and Murderer.Team and Murderer.Team.Name == "Barney" then
		return " infected "
	end
end

local Requests = 
{
	["GetKillType"] = GetKillType
}

local function OnGameModeSignalInvoke(FunctionName, ...)
	-- Functions
	-- INIT
	return Requests[FunctionName](...)
end

local function Initialise()
	-- Functions
	-- DIRECT
	GameModeSignal.OnInvoke = OnGameModeSignalInvoke
	
	for i, Player in pairs(SharedGameLobbyFolder:GetChildren()) do
		SetupPlayerConnections(game.Players:FindFirstChild(Player.Name))
	end
	
	CheckIfRoundEnd()
end

local function DisconnectAllConnections()
	-- Functions
	-- INIT
	for Player, PlayerConnections in pairs(Connections) do
		if PlayerConnections then
			UtilitiesModule:DisconnectConnections(PlayerConnections)
			
			
			Connections[Player] = nil
		end
	end
	
	Connections = {}
end

local function End()
	-- Functions
	-- INIT
	DisconnectAllConnections()
end

-- DIRECT
function InfectionModule.PlayerDied(NilParam, Player)
	return OnPlayerKilled(Player)
end

function InfectionModule.PlayerKilled(NilParam, Murdered, Murderer)
	return OnPlayerKilled(Murdered, Murderer)
end

function InfectionModule.PlayerAdded(NilParam, Player)
	return SetupPlayerConnections(Player)
end

function InfectionModule.PlayerLeft(NilParam, Player)
	return RemoveFromCache(Player)
end

function InfectionModule.Initialise()
	return Initialise()
end

function InfectionModule.End()
	return End()
end

return InfectionModule