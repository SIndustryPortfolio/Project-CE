local DataStoreInfoModule = {}

-- CORE
local MasterKey = "test52"
local OrderedMasterKey = "test3"

local OrderedStores = {"Donated"}
local Stores = {"ClaimedTiers"}

-- Functions
-- DIRECT
function DataStoreInfoModule.GetStores()
	return Stores
end

function DataStoreInfoModule.GetOrderedStores()
	return OrderedStores
end

function DataStoreInfoModule.GetOrderedMasterKey()
	return OrderedMasterKey
end

function DataStoreInfoModule.GetMasterKey()
	return MasterKey
end

return DataStoreInfoModule