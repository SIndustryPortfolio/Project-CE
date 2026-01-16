local PlayerCoreModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]

local SpawnBoxFolder = workspace:WaitForChild("SpawnBox")

-- Elements
-- REMOTES
local CoreRemote = ServerRemotesFolder["Core"]

-- SPAWNS
local SpawnBoxSpawnLocation = SpawnBoxFolder:WaitForChild("FirstSpawn")

-- Info Modules
local CharacterInfoModule = require(ServerInfoModulesFolder["Character"])

-- Modules
local CrewModule = require(ServerModulesFolder["Crew"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local LobbyModule = require(ServerModulesFolder["Lobby"])
local DebugModule = require(SharedModulesFolder["Debug"])
local PlayerManagementModule = require(ServerModulesFolder["PlayerManagement"])
local MainLoopModule = require(ServerModulesInitFolder["MainLoop"])
local MarketplaceModule = require(ServerModulesInitFolder["Marketplace"])
local OrderedDataStoreModule = require(ServerModulesFolder["OrderedDataStore"])
local CharacterCoreModule = require(UtilitiesModule:WaitForChildTimed(script, "CharacterCore"))
local AdminModule = require(ServerModulesFolder["Admin"])

-- CORE
local PlayerConnectionsCache = {}

-- Functions
-- MECHANICS
local function CreateConnectionsCache(Player, Connections)
	-- Functions
	-- INIT
	PlayerConnectionsCache[Player] = Connections
end

local function RemoveConnectionsCache(Player)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(PlayerConnectionsCache[Player])
	PlayerConnectionsCache[Player] = nil
end

local function OnPlayerLeft(Player)
	-- Functions	
	-- INIT
	PlayerManagementModule:PlayerProcess("Collisions", "PlayerLeft", Player)
	RemoveConnectionsCache(Player)
	LobbyModule:PlayerLeft(Player)
	
	if MainLoopModule.PlayerLeft ~= nil then
		MainLoopModule:PlayerLeft(Player)
	end
	
	CharacterCoreModule:End(Player, UtilitiesModule:GetCharacter(Player, true))
	MarketplaceModule:PlayerLeft(Player)
	OrderedDataStoreModule:PlayerLeft(Player)
end

local function OnPlayerAdded(Player)
	-- CORE
	--print("Player Added: ".. tostring(Player))
	
	DebugModule:Print(script.Name.." | OnPlayerAdded | Player: ".. tostring(Player))
	
	-- Functions
	-- DIRECT
	--[[local Connection1 = Player.CharacterAdded:Connect(function(Character)
		return OnCharacterAdded(Player, Character)
	end)]]
	
	local Connection2 = Player.CharacterAdded:Connect(function(Character) --Player:GetPropertyChangedSignal("Character"):Connect(function()
		return CharacterCoreModule:Initialise(Player, --[[UtilitiesModule:GetCharacter(Player)]] Character) --OnCharacterAdded(Player, UtilitiesModule:GetCharacter(Player))
	end)
	
	-- INIT
	--local RandomX = math.random(-3 * 100, 3 * 100) / 100
	--local RandomZ = math.random(-3 * 100, 3 * 100) / 100
	
	Player.RespawnLocation = SpawnBoxSpawnLocation --(SpawnBoxSpawnLocation.CFrame * CFrame.new(RandomX, 10, RandomZ)).p
	OrderedDataStoreModule:PlayerAdded(Player)
	PlayerManagementModule:PlayerProcess("Settings", "CreatePlayerSettings", Player)
	local InventoryConnections = PlayerManagementModule:PlayerProcess("Inventory", "CreatePlayerInventory", Player)
	local StatConnections = PlayerManagementModule:PlayerProcess("Statistics", "CreatePlayerStats", Player)
	local AdminConnections = AdminModule:PlayerAdded(Player)
	PlayerManagementModule:PlayerProcess("Collisions", "PlayerAdded", Player)
	local PlayerConnections = UtilitiesModule:UnpackConnectionsToLargeTable(StatConnections, InventoryConnections, AdminConnections)
	
	--CreateConnectionsCache(Player, {Connection2, unpack(PlayerConnections)})
	
	--
	MarketplaceModule:GetUserPurchasedGamepasses(Player)
	MarketplaceModule:PlayerAdded(Player)
	PlayerManagementModule:PlayerProcess("Marketplace", "PlayerAdded", Player)
	CrewModule:PlayerAdded(Player)
	
	local Connection1 = Player:GetAttributeChangedSignal("Crew"):Connect(function()
		if Player:GetAttribute("Crew") then
			CrewModule:CrewMemberAdded(Player)
		end
	end)
	
	CreateConnectionsCache(Player, {Connection1, Connection2, unpack(PlayerConnections)})
end

-- DIRECT
function PlayerCoreModule.CharacterAdded(NilParam, Player, Character)
	return CharacterCoreModule:Initialise(Player, UtilitiesModule:GetCharacter(Player))--OnCharacterAdded(Player, Character)
end

game.Players.PlayerAdded:Connect(function(Player)
	OnPlayerAdded(Player)
end)

game.Players.PlayerRemoving:Connect(function(Player)
	OnPlayerLeft(Player)
end)

-- MECHANICS
local function OnCoreRemoteFired(FunctionName, ...)
	-- Functions
	-- INIT
	return PlayerCoreModule[FunctionName](nil, ...)
end

-- Connectors
CoreRemote.Event:Connect(OnCoreRemoteFired)

-- INIT
for i, Player in pairs(game.Players:GetPlayers()) do
	OnPlayerAdded(Player)
end

return PlayerCoreModule