local OrderedDataStoreModule = {}

-- Dirs
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local DataStoreInfoModule = require(ServerInfoModulesFolder["DataStore"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local OrderedStores = DataStoreInfoModule:GetOrderedStores()
local AmountOfFields = 12
local Stores = {}

-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Functions
-- MECHANICS
local function ConstructStoreName(StoreName)
	local MasterKey = DataStoreInfoModule:GetOrderedMasterKey()
	return MasterKey.. StoreName
end

local function GetStoreCache(StoreName)
	return Stores[ConstructStoreName(StoreName)]["Cache"]
end

local function GetDataStore(StoreName)
	-- Functions
	-- INIT
	local ConstructedStoreName = ConstructStoreName(StoreName)
	
	while Stores[ConstructedStoreName] == nil do
		DebugModule:Print(script.Name.. " | GetDataStore | StoreName: ".. tostring(ConstructedStoreName).. " | Store Not Found!")
		task.wait(.1)
	end
	
	return Stores[ConstructedStoreName]["DataStore"]
end

local function ConstructKeyFromPlayer(Player)
	return "PCESave-".. tostring(Player.UserId)
end

local function GetLocalCache(Store, Player)
	-- CORE
	if Store[Player] == nil then
		Store[Player] = {Key = ConstructKeyFromPlayer(Player), Value = 0}
	end

	return Store[Player]
end

local function SetValue(LocalCache, Value)
	LocalCache["Value"] = Value
end

local function GetValue(LocalCache)
	return LocalCache["Value"]
end

local function CreateStores()
	-- CORE
	local MasterKey = DataStoreInfoModule:GetOrderedMasterKey()
	
	local BetterStores = {}
	for i, StoreName in pairs(OrderedStores) do
		table.insert(BetterStores, ConstructStoreName(StoreName))
	end
	
	-- Functions
	-- DIRECT
	--[[local Connection1 = game.Players.PlayerRemoving:Connect(function(Player)
		for i, StoreName in pairs(OrderedStores) do
			local LocalCache = GetLocalCache(GetStoreCache(StoreName), Player)
			local DataStore = GetDataStore(StoreName)
			if LocalCache ~= nil then
				DataStore:SetAsync(LocalCache["Key"], LocalCache["Value"])
			end
		end
	end)
	
	local Connection2 = game.Players.PlayerAdded:Connect(function(Player)
		for i, StoreName in pairs(OrderedStores) do
			GetStoreCache(StoreName)[Player] = {Key = ConstructKeyFromPlayer(Player), Value = GetDataStore(StoreName):GetAsync(ConstructKeyFromPlayer(Player)) or 0}
		end
	end)]]
	
	-- INIT
	for i, StoreName in pairs(BetterStores) do
		local Success, Error = false, nil
		
		while not Success do
			Success, Error = pcall(function()
				Stores[StoreName] = {Cache = {}, DataStore = DataStoreService:GetOrderedDataStore(StoreName)}
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | CreateStores | StoreName: ".. tostring(StoreName).. " | Error: ".. tostring(Error))
				task.wait(math.random(0,  100) / 100)
			end
		end
	end
end

-- DIRECT
function OrderedDataStoreModule.PlayerAdded(NilParam, Player)
	-- Functions
	-- INIT
	for i, StoreName in pairs(OrderedStores) do
		local Success, Error = pcall(function()
			GetStoreCache(StoreName)[Player] = {Key = ConstructKeyFromPlayer(Player), Value = GetDataStore(StoreName):GetAsync(ConstructKeyFromPlayer(Player)) or 0}
		end)
		
		if not Success then
			coroutine.wrap(function()
				repeat
					Success, Error = pcall(function()
						GetStoreCache(StoreName)[Player] = {Key = ConstructKeyFromPlayer(Player), Value = GetDataStore(StoreName):GetAsync(ConstructKeyFromPlayer(Player)) or 0}
					end)
					
					task.wait(3)
				until not Player or Success
			end)()
		end
	end
end

function OrderedDataStoreModule.PlayerLeft(NilParam, Player)
	-- Functions
	-- INIT
	for i, StoreName in pairs(OrderedStores) do
		local LocalCache = GetLocalCache(GetStoreCache(StoreName), Player)
		local DataStore = GetDataStore(StoreName)
		if LocalCache ~= nil then
			local Success, Error =  nil, nil
			local Tries = 0
			--DebugModule:Print("OrderedDataStore | Saving: ".. tostring(StoreName).. " | Player: ".. tostring(Player))

			
			repeat
				Success, Error = pcall(function()
					return DataStore:SetAsync(LocalCache["Key"], LocalCache["Value"])
				end)
				
				if not Success then
					Tries += 1
					--DebugModule:Print("OrderedDataStore | Store Name: ".. tostring(StoreName).. " | Tries: ".. tostring(Tries))
					task.wait(5)
				end
			until Success
		else
			DebugModule:Print("OrderedDataStore | Nothing to save for: ".. tostring(Player))
		end
	end
end

function OrderedDataStoreModule.Update(NilParam, Player, StoreName, Value)
	-- CORE
	local DataStore = GetDataStore(StoreName)
	local GlobalCache = GetStoreCache(StoreName)
	local LocalCache = GetLocalCache(GlobalCache, Player)
	
	-- Functions
	-- INIT
	OrderedDataStoreModule:Set(Player, StoreName, Value)
	
	DataStore:UpdateAsync(LocalCache.Key, LocalCache.Value)
end

function OrderedDataStoreModule.Increment(NilParam, Player, StoreName, Difference)
	-- CORE
	local GlobalCache = GetStoreCache(StoreName)
	local LocalCache = GetLocalCache(GlobalCache, Player)
	
	-- Functions
	-- INIT
	local OldValue = OrderedDataStoreModule:Get(Player, StoreName)
	SetValue(LocalCache, OldValue + Difference)
end

function OrderedDataStoreModule.Set(NilParam, Player, StoreName, Value)
	-- CORE
	local GlobalCache = GetStoreCache(StoreName)
	local LocalCache = GetLocalCache(GlobalCache, Player)
	
	-- Functions
	-- INIT
	SetValue(LocalCache, Value)
end

function OrderedDataStoreModule.Get(NilParam, Player, StoreName)
	-- CORE
	local GlobalCache = GetStoreCache(StoreName)
	local LocalCache = GetLocalCache(GlobalCache, Player)
	
	-- Functions
	-- INIT
	return GetValue(LocalCache) or 0
end

function OrderedDataStoreModule.GetDataFields(NilParam, StoreName, Ascending)
	-- CORE
	local DataStore = GetDataStore(StoreName)
	local Success, Pages = pcall(function() 
		return DataStore:GetSortedAsync(Ascending, AmountOfFields)
	end)
	
	local TopFields = nil
	
	if Success then
		Success, TopFields = pcall(function() 
			return Pages:GetCurrentPage()
		end)
	end
	
	return TopFields
end


-- INIT
CreateStores()

return OrderedDataStoreModule