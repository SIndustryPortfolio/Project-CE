local GamepassesInfoModule = {}

-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- CORE
local GamepassesInfo = 
{
	["DoubleXp"] = {Name = "DOUBLE XP", Id = 60772430, BackupImage = {Id = "rbxassetid://9155041899"}, Tile = "Default", Rarity = "Epic"},
	["CECrew"] = {Name = "CE CREW", Id = 60772739, BackupImage = {Id = "rbxassetid://9162123865"}, Tile = "Default", Rewards = {{Type = "Crew"}}, Rarity = "Legendary"},
	["DeprecatedCECrew"] = {Name = "DEPRECATED", Id = 35721941, Hide = true},
	["BlueFire"] = {Name = "BLUE FIRE", Id = 62585180, BackupImage = {Id = "rbxassetid://10267992445"}, Tile = "Gold", Rewards = {{Type = "Inventory", Folder = "ArmourEffects", Name = "Blue Fire"}}, Hide = true}
	--["DoubleAmmo"] = {Name = "DOUBLE AMMO", Id = 35941971, BackupImage = {Id = "rbxassetid://9162441664"}, ZOffset = 7.5}

}

-- Functions
-- MECHANICS
local function GetGamepassFromId(GamepassId)
	-- Functions
	-- INIT
	for GamepassName, GamepassInfo in pairs(GamepassesInfo) do
		if GamepassInfo["Id"] == GamepassId then

			--[[if PlayerToPurchased[Player] then
				table.insert(PlayerToPurchased[Player], GamepassName)
			end]]
			
			return GamepassName
		end
	end
end

local function GetSellable()
	-- CORE
	local Sellable = {}
	
	-- Functions
	-- INIT
	for GamepassName, GamepassInfo in pairs(GamepassesInfo) do
		if not GamepassInfo["Price"]  or GamepassInfo["Hide"] then
			continue
		end
		
		table.insert(Sellable, GamepassName)
	end
	
	return Sellable
end

-- DIRECT
function GamepassesInfoModule.GetSellable()
	return GetSellable()
end

function GamepassesInfoModule.GetGamepassFromId(NilParam, GamepassId)
	return GetGamepassFromId(GamepassId)
end

function GamepassesInfoModule.GetGamepassProductInfo(NilParam, GamepassName)
	return GamepassesInfo[GamepassName]
end

function GamepassesInfoModule.GetAllGamepassesInfo()
	return GamepassesInfo
end

-- INIT
for GamepassName, GamepassInfo in pairs(GamepassesInfo) do
	local GlobalGamepassInfo = {}
	
	local Success, GlobalGamepassInfo = pcall(function()
		return MarketplaceService:GetProductInfo(GamepassInfo["Id"], Enum.InfoType.GamePass)
	end)
		
	GamepassInfo["Price"] = GlobalGamepassInfo["PriceInRobux"]
	GamepassInfo["Description"] = GlobalGamepassInfo["Description"]
	--GamepassInfo["Image"] = {Id = "rbxassetid://".. tostring(GlobalGamepassInfo["IconImageAssetId"])}
end

return GamepassesInfoModule