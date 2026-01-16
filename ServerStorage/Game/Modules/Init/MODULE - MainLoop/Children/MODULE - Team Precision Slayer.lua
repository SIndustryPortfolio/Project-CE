local TeamSlayerModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local GameModule = require(ServerModulesFolder["Game"])

-- Elements
-- SIGNALS
local GameModeSignal = ServerSignalsFolder["GameMode"]

-- CORE
local Connections = {}

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

local function SetupPlayerConnections(Player)
	if not Player then
		return nil
	end
	
	-- CORE
	local PlayerLobbyValue = UtilitiesModule:WaitForChildTimed(SharedGameLobbyFolder, Player.Name)
	local PlayerTeam = Player.Team
	
	-- Functions
	-- DIRECT
	local Connection1 = PlayerLobbyValue:GetAttributeChangedSignal("Kills"):Connect(function()
		PlayerLobbyValue:SetAttribute("Score", PlayerLobbyValue:GetAttribute("Kills"))
		GameModule:UpdateTotalScore(PlayerTeam)
	end)
	
	-- INIT
	AddToCache(Player, {Connection1})
end

local function OnGameModeSignalInvoke()
	
end

local function Initialise()
	-- Functions
	-- DIRECT
	for i, Player in pairs(SharedGameLobbyFolder:GetChildren()) do
		SetupPlayerConnections(game.Players:FindFirstChild(Player.Name))
	end
	
	GameModeSignal.OnInvoke = OnGameModeSignalInvoke
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
function TeamSlayerModule.PlayerAdded(NilParam, Player)
	return SetupPlayerConnections(Player)
end

function TeamSlayerModule.PlayerLeft(NilParam, Player)
	return RemoveFromCache(Player)
end

function TeamSlayerModule.Initialise()
	return Initialise()
end

function TeamSlayerModule.End()
	return End()
end

return TeamSlayerModule