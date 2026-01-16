local StatsModule = {}

-- Dirs
local ServerAPIsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["APIs"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local StatsInfoModule = require(InfoModulesFolder["Stats"])
local RanksInfoModule = require(InfoModulesFolder["Ranks"])
local CrewInfoModule = require(InfoModulesFolder["Crew"])

-- Modules
local CrewModule = require(ServerModulesFolder["Crew"])
local OrderedDataStoreModule = require(ServerModulesFolder["OrderedDataStore"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local DatastoreModule = require(ServerModulesFolder["Datastore"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- APIs
local DataStore2Module = require(ServerAPIsFolder["DataStore2"])

-- CORE
--local ProgressInts = {"CurrentXp", "Rank", "Prestige", "TimePlayed"}

-- Functions
-- MECHANICS
local function HandleLevels(Player)
	-- CORE
	local AllRanks = RanksInfoModule:GetAllRanksInfo()
	local AllTiers = CrewInfoModule:GetAllTiers()
	
	-- Elements
	-- FOLDERS
	local XpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Xp")
	local CrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	local CrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	local RankValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Rank")
	
	-- Functions
	-- MECHANICS
	local function CrewUpdate()
		-- CORE
		local NextTierInfo = AllTiers[CrewTierValue.Value + 1]
		
		-- Functions
		-- INIT
		if not NextTierInfo then
			return nil
		end
		
		if CrewXpValue.Value >= NextTierInfo["RequiredXp"] then
			CrewTierValue.Value += 1
			return CrewUpdate()
		else
			return nil
		end
	end
	
	local function Update()
		-- CORE
		local NextRankInfo = AllRanks[RankValue.Value + 1]
		
		-- Functions
		-- INIT
		if not NextRankInfo then
			return nil
		end
		
		if XpValue.Value >= NextRankInfo["RequiredXp"] then
			RankValue.Value += 1
			return Update()
		else
			return nil
		end
	end
	
	-- DIRECT
	local Connection1 = XpValue:GetPropertyChangedSignal("Value"):Connect(function()
		return Update()
	end)
	
	local Connection2 = CrewTierValue:GetPropertyChangedSignal("Value"):Connect(function()
		return CrewModule:PlayerTieredUp(Player)
	end)
	
	local Connection3 = CrewXpValue:GetPropertyChangedSignal("Value"):Connect(function()
		return CrewUpdate()
	end)
	
	-- INIT
	Update()
	
	return {Connection1, Connection2, Connection3}
end

local function CreatePlayerStats(Player)
	-- CORE
	local StatsConnections = {}
	local PlayerData = DatastoreModule:GetPlayerData(Player)
	
	-- Functions
	-- INIT
	local StatisticsFolder = Instance.new("Folder")
	StatisticsFolder.Name = "Statistics"
	StatisticsFolder.Parent = Player
	
	for FolderName, FolderChildren in pairs(StatsInfoModule:GetAllStatsConversion()) do
		local CategoryFolder = Instance.new("Folder")
		CategoryFolder.Name = FolderName
		CategoryFolder.Parent = StatisticsFolder
		
		for ValueName, ValueInfo in pairs(FolderChildren) do
			local ProgressValue = Instance.new(ValueInfo["ClassName"])
			ProgressValue.Name = ValueName
			local Success, Error = pcall(function()
				ProgressValue.Value = PlayerData[ValueName] --ValueInfo["DefaultValue"]
			end)
			
			if not Success then
				local ValueToLoad = UtilitiesModule:UnPackSavableValue(PlayerData[ValueName])
				
				DebugModule:Print("Statistics | Setting Instance: ".. tostring(ProgressValue).. " | To: ".. tostring(ValueToLoad).. " | Type: ".. typeof(ValueToLoad).. " | Original Value: ".. tostring(PlayerData[ValueName]).. " | Original Type: ".. typeof(PlayerData[ValueName]))
				
				ProgressValue.Value = ValueToLoad
			end
			
			ProgressValue.Parent = CategoryFolder
			
			local AssociatedStore = DataStore2Module(ValueName, Player)
			--[[local AssociatedInventoryType = ValueInfo["AssociatedInventory"]
			
			local InventoryFolder = nil
			
			if AssociatedInventoryType then
				InventoryFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, AssociatedInventoryType)
			end]]
			
			-- DIRECT
			local Connection1 = ProgressValue:GetPropertyChangedSignal("Value"):Connect(function()
				local PackedValue = UtilitiesModule:PackSavableValue(ProgressValue.Value)
				
				--DebugModule:Print("Saving: ".. tostring(ProgressValue).. " | To: ".. tostring(PackedValue).. " | Type: ".. typeof(PackedValue))
				
				return AssociatedStore:Set(PackedValue)
			end)
			
			--[[local Connection2 = nil
			
			if InventoryFolder then
				Connection2 = InventoryFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
					
				end)
			end]]
			
			-- CONNECTIONS
			table.insert(StatsConnections, Connection1)
			--table.insert(StatsConnections, Connection2)
		end
	end
	
	local LevelConnections = HandleLevels(Player)
	
	return UtilitiesModule:UnpackConnectionsToLargeTable(StatsConnections, LevelConnections) --{unpack(StatsConnections), unpack(LevelConnections)}
end

-- DIRECT
function StatsModule.CreatePlayerStats(NilParam, PlayerManagementModule, Player)
	return CreatePlayerStats(Player)
end

return StatsModule