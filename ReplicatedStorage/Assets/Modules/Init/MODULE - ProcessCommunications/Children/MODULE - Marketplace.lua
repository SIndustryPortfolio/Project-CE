local MarketplaceCommunicationsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local SoundsModule = require(ModulesFolder["Sounds"])

-- Functions
-- MECHANICS
local function ShopPurchaseComplete()
	-- Functions
	-- INIT
	SoundsModule:PlaySoundEffectByName("Shop", "PurchaseComplete")
end

local function PurchaseComplete(ProductName, PurchaseId)
	-- Functions
	-- INIT
	return InterfacesModule:LoadPage("Custom", "PurchaseComplete", nil, ProductName, PurchaseId)
end

local function JoinedCrew()
	-- Functions
	-- INIT
	return InterfacesModule:LoadPage("Custom", "JoinedCrew")
end

-- CORE FUNCTIONS
local ServerRequests = 
{
	["ShopPurchaseComplete"] = ShopPurchaseComplete,
	["PurchaseComplete"] = PurchaseComplete,
	["JoinedCrew"] = JoinedCrew
}

-- DIRECT
function MarketplaceCommunicationsModule.Initialise(NilParam, FunctionName, ...)
	return ServerRequests[FunctionName](...)
end

return MarketplaceCommunicationsModule