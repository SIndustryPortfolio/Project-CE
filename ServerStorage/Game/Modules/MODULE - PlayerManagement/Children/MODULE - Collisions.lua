local CollisionsManagementModule = {}

-- Dirs
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Groups = {"Characters", "Grenades"}
local MaxPlayers = 12 --game.Players.MaxPlayers
local GroupsCache = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function GetFreeGroup()
	-- Functions
	-- INIT
	for CacheName, CacheInfo in pairs(GroupsCache) do
		if not CacheInfo["Player"] then
			return CacheName
		end
	end
end

local function GetPlayerCache(Player)
	-- Functions
	-- INIT
	for CacheName, CacheInfo in pairs(GroupsCache) do
		if CacheInfo["Player"] == Player then
			return CacheName
		end
	end
end

local function PlayerAdded(Player)
	-- Functions
	-- INIT
	if not Player then
		return nil
	end
	
	local CacheName = GetFreeGroup()
	
	if not CacheName then
		CacheName = GetPlayerCache(Player)
	end
	
	GroupsCache[CacheName]["Player"] = Player
	
	Player:SetAttribute("CollisionGroup", CacheName)
	DebugModule:Print("Player Management | Collisions | Setting ".. tostring(Player.Name).. "'s cache to: ".. tostring(CacheName))
	
	--[[for i, GroupName in pairs(Groups) do
		PhysicsService:RegisterCollisionGroup(Player.Name.. GroupName)
	end]]
end

local function PlayerRemoved(Player)
	-- Functions
	-- INIT
	local CacheName = GetPlayerCache(Player)
	
	if CacheName then
		GroupsCache[CacheName]["Player"] = nil
	end
	
	DebugModule:Print("Player Management | Collisions | Freeing up cache: ".. tostring(CacheName))
end

local function Initialise()
	-- FUNCTIONS
	-- INIT	
	PhysicsService:RegisterCollisionGroup("OneWayDoors")
	PhysicsService:RegisterCollisionGroup("Weapons")
	PhysicsService:RegisterCollisionGroup("AIs")
	
	PhysicsService:CollisionGroupSetCollidable("OneWayDoors", "AIs", false)
	
	for i = 1, MaxPlayers do
		GroupsCache["Player".. tostring(i)] = 
		{
			["Player"] = nil,
			["CharacterGroup"] = PhysicsService:RegisterCollisionGroup("Player".. tostring(i).. "Characters"),
			["GrenadesGroup"] = PhysicsService:RegisterCollisionGroup("Player".. tostring(i).. "Grenades") 	
		}

		PhysicsService:CollisionGroupSetCollidable("Player".. tostring(i).. "Characters", "Player".. tostring(i).. "Grenades", false)
		PhysicsService:CollisionGroupSetCollidable("Player".. tostring(i).. "Characters", "Weapons", false)
	end
end

-- DIRECT
function CollisionsManagementModule.PlayerAdded(NilParam, PlayerManagementModule, Player)
	return PlayerAdded(Player)
end

function CollisionsManagementModule.PlayerLeft(NilParam, PlayerManagementModule, Player)
	return PlayerRemoved(Player)
end

-- INIT
Initialise()

return CollisionsManagementModule