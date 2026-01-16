local DatastoreModule = {}

-- Dirs
local ServerAPIsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["APIs"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]

-- Info Modules
local DataStoreInfoModule = require(ServerInfoModulesFolder["DataStore"])
local StatsInfoModule = require(SharedInfoModulesFolder["Stats"])
local InventoryInfoModule = require(SharedInfoModulesFolder["Inventory"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DataStore2Module = require(ServerAPIsFolder["DataStore2"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
DataStore2Module.Combine(DataStoreInfoModule:GetMasterKey(), "RedeemCodes", unpack(UtilitiesModule:CombineTables(StatsInfoModule:GetAllStatNames(), InventoryInfoModule:GetStoreNames(), DataStoreInfoModule:GetStores())) --[[unpack(StatsInfoModule:GetAllStatNames()), unpack(InventoryInfoModule:GetStoreNames())]])

-- Functions
-- MECHANICS
local function GetValue(Value)
	-- Functions
	-- INIT
	if typeof(Value) == "table" and Value["Function"] ~= nil and typeof(Value["Function"]) == "function" then
		return Value["Function"](unpack(Value["Params"]))
	end
	
	return Value
end

local function GetPlayerData(Player)
	-- Functions
	-- INIT
	local DataStructure = {}
	
	for CategoryName, CategoryInfo in pairs(StatsInfoModule:GetAllStatsConversion()) do
		for StatName, StatInfo in pairs(CategoryInfo) do
			local Store = DataStore2Module(StatName, Player)
			DataStructure[StatName] = Store:Get(UtilitiesModule:PackSavableValue(GetValue(StatInfo["DefaultValue"])))
			
			--DebugModule:Print("DataStore | Stat Name: ".. tostring(StatName).. " | Value: ".. tostring(Store:Get(StatInfo["DefaultValue"])))
		end
	end
	
	return DataStructure
end

--[[local function Setup()
	-- CORE
	local Stores = {}
	
	-- Functions
	-- INIT
	for i, StatName in pairs(StatsInfoModule:GetAllStatNames()) do
		table.insert(Stores, StatName)
	end
	
	for i, StoreName in pairs(InventoryInfoModule:GetStoreNames()) do
		table.insert(Stores, StoreName)
	end
	
	DataStore2Module.Combine(DataStoreInfoModule:GetMasterKey(), unpack(Stores))
end]]

-- DIRECT
function DatastoreModule.GetPlayerData(NilParam, Player)
	return GetPlayerData(Player)
end

-- INIT
--Setup()

return DatastoreModule