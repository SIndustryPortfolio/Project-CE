local PurchaseableModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local CachesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]

-- CACHES
local GamepassesCacheModule = require(CachesFolder["Gamepasses"])

-- Info Modules
local DeveloperProductsInfoModule = require(InfoModulesFolder["DeveloperProducts"])
local GamepassesInfoModule = require(InfoModulesFolder["Gamepasses"])

-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function PromptPurchase(Player, Type, Name)
	-- Functions
	-- INIT
	if Type == "Gamepass" then
		local GamepassInfo = GamepassesInfoModule:GetGamepassProductInfo(Name)
		return MarketplaceService:PromptGamePassPurchase(Player, GamepassInfo["Id"])
	else
		local ProductInfo = DeveloperProductsInfoModule:GetDeveloperProductInfo(Name)
		return MarketplaceService:PromptProductPurchase(Player,  ProductInfo["Id"])
	end
end

local function DoesUserHavePass(Player, Name)
	-- CORE
	local GamepassInfo = GamepassesInfoModule:GetGamepassProductInfo(Name)
	
	if not GamepassInfo then
		return nil
	end
	
	-- Functions
	-- INIT
	local Response = GamepassesCacheModule:Get(Player, Name)
	
	if not Response then
		local Response = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassInfo["Id"])
		
		if Response then
			GamepassesCacheModule:Add(Player, Name)
		end
	end
	
	return Response
end

-- DIRECT
function PurchaseableModule.PromptPurchase(NilParam, Player, Type, Name)
	return PromptPurchase(Player, Type, Name)
end

function PurchaseableModule.DoesUserHavePass(NilParam, Player, Name)
	return DoesUserHavePass(Player, Name)
end

return PurchaseableModule