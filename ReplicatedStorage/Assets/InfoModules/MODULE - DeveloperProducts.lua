local DeveloperProductsInfoModule = {}

-- CORE
local DeveloperProductsInfo = 
{
	["LowDonation"] = {Name = "LOW DONATION", Id = 1284065449, Tile = "Default"},
	["MediumDonation"] = {Name = "MEDIUM DONATION", Id = 1284064904, Tile = "Default"},
	["HighDonation"] = {Name = "HIGH DONATION", Id = 1284065265, Tile = "Gold"},
	--["100CECoins"] = {Name = "100 CE COINS", Id = 1275648880, Reward = {Coins = 100}, Layout = 1},
	["250CECoins"] = {Name = "250 CE COINS", Id = 1284068410, Rewards = {{Coins = 250}}, Layout = 2, Tile = "Default", Rarity = "Uncommon"},
	["500CECoins"] = {Name = "500 CE COINS", Id = 1284069308, Rewards = {{Coins = 500}}, Layout = 3, Tile = "Default", Rarity = "Rare"},
	["1000CECoins"] = {Name = "1000 CE COINS", Id = 1284069306, Rewards = {{Coins = 1000}}, Layout = 4, Tile = "Gold", Rarity = "Epic"},
	["2500CECoins"] = {Name = "2500 CE COINS", Id = 1284068411, Rewards = {{Coins = 2500}}, Layout = 5, ZOffset = 7.5, Tile = "Gold", Rarity = "Legendary"},
	--["5000CECoins"] = {Name = "5000 CE COINS", Id = 1275949707, Reward = {Coins = 5000}, Layout = 6, ZOffset = 7.5},
	["ChangeMap"] = {Name = "CHANGE MAP", Id = 1284068413, Rewards = {{MapChange = 1}}, Tile = "Default"},
	["ChangeMode"] = {Name = "CHANGE MODE", Id = 1284068414, Rewards = {{ModeChange = 1}}, Tile = "Default"}
}


-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function GetDeveloperProductFromId(DeveloperProductId)
	-- Functions
	-- INIT
	for ProductName, ProductInfo in pairs(DeveloperProductsInfo) do
		if ProductInfo["Id"] == DeveloperProductId then
			return ProductName
		end
	end
end

-- DIRECT
function DeveloperProductsInfoModule.GetDeveloperProductFromId(NilParam, DeveloperProductId)
	return GetDeveloperProductFromId(DeveloperProductId)
end

function DeveloperProductsInfoModule.GetDeveloperProductInfo(NilParam, DeveloperProductName)
	return DeveloperProductsInfo[DeveloperProductName]
end

function DeveloperProductsInfoModule.GetAllDeveloperProductsInfo()
	return DeveloperProductsInfo
end

-- INIT
for ProductName, ProductInfo in pairs(DeveloperProductsInfo) do
	local GlobalGamepassInfo = {}
	
	local Success, GlobalGamepassInfo = pcall(function()
		return MarketplaceService:GetProductInfo(ProductInfo["Id"], Enum.InfoType.Product)
	end)
	
	ProductInfo["Price"] = GlobalGamepassInfo["PriceInRobux"]
	ProductInfo["Description"] = GlobalGamepassInfo["Description"]
	
	if string.find(ProductName, "Donation") then
		ProductInfo["Rewards"] = {{Donated = GlobalGamepassInfo["PriceInRobux"]}}
	end
	
	--GamepassInfo["Image"] = {Id = "rbxassetid://".. tostring(GlobalGamepassInfo["IconImageAssetId"])}
end

return DeveloperProductsInfoModule