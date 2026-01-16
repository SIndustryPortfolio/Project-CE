local ShopModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameShopFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Shop"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Info Modules
local CamosInfoModule = require(SharedInfoModulesFolder["Camos"])
local ArmourEffectsInfoModule = require(SharedInfoModulesFolder["ArmourEffects"])
local VisorColoursInfoModule = require(SharedInfoModulesFolder["VisorColours"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local InventoryModule = require(ServerModulesFolder["Inventory"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local Types = {"Camos", "ArmourEffects", "VisorColours", "Helmets"}

--[[local Heaps = 
{
	["Camos"] = {Sellable = CamosInfoModule:GetSellable(), Heap = CamosInfoModule.GetAllCamosInfo},
	["ArmourEffects"] = {Sellable = ArmourEffectsInfoModule:GetSellable(), Heap = ArmourEffectsInfoModule.GetAllArmourEffects},
	["VisorColours"] = {Sellable = VisorColoursInfoModule:GetSellable(), Heap = VisorColoursInfoModule.GetAllVisorColoursInfo}
}

local Conversion = 
{
	["VisorColours"] = "VisorColours",
	["Camos"] = "Camos",
	["ArmourEffects"] = "ArmourEffects"	
}

local PluralToSingle = 
{
	["VisorColours"] = "Visor colour",
	["Camos"] = "Camo",
	["ArmourEffects"] = "Armour effect"	
}]]
-- Functions
-- MECHANICS
local function DeleteShop()
	-- Functions
	-- INIT
	for i, BoolValue in pairs(SharedGameShopFolder["Featured"]:GetChildren()) do
		BoolValue:Destroy()
	end
	
	for i, BoolValue in pairs(SharedGameShopFolder:GetChildren()) do
		if not BoolValue:IsA("BoolValue") then
			continue
		end
		
		BoolValue:Destroy()
	end
end

local function BuildShopValue(ItemType, ItemName, ItemInfo)
	-- Functions
	-- INIT
	local BoolValue = Instance.new("BoolValue")
	BoolValue.Name = ItemName
	--BoolValue:SetAttribute("Type", Conversion[ItemType])
	BoolValue:SetAttribute("Type", ItemType)
	
	return BoolValue
end

local function BuildShop()
	-- CORE
	--local Types = UtilitiesModule:GetDictKeys(Heaps)
	local TakenNames = {}
	
	-- Functions
	-- INIT
	for i = 1, 6 do
		local ItemType = Types[math.random(1, #Types)]
		
		local HeapInfoModule = require(UtilitiesModule:WaitForChildTimed(SharedInfoModulesFolder, ItemType))
		
		local AllSellable = HeapInfoModule:GetSellable() --Heaps[ItemType]["Sellable"]
		local ItemName = AllSellable[math.random(1, #AllSellable)]
		local ItemInfo = HeapInfoModule:GetInfo(ItemName) --Heaps[ItemType]["Heap"]()[ItemName]
		
		table.insert(TakenNames, ItemName)
		
		local ShopValue = BuildShopValue(ItemType, ItemName, ItemInfo)
		ShopValue.Parent = SharedGameShopFolder
	end
	
	for i = 1, 2 do
		local ItemName = nil
		local ItemType = nil
		local ItemInfo = nil
		
		repeat
			ItemType = Types[math.random(1, #Types)]
			
			local HeapInfoModule = require(UtilitiesModule:WaitForChildTimed(SharedInfoModulesFolder, ItemType))
			
			local AllSellable = HeapInfoModule:GetSellable() --Heaps[ItemType]["Sellable"]
			ItemName = AllSellable[math.random(1, #AllSellable)]
			ItemInfo = HeapInfoModule:GetInfo(ItemName) --Heaps[ItemType]["Heap"]()[ItemName]
			task.wait()
		until not table.find(TakenNames, ItemName)
		
		local ShopValue = BuildShopValue(ItemType, ItemName, ItemInfo)
		ShopValue.Parent = SharedGameShopFolder["Featured"]
	end
end

local function CreateShop()
	-- Functions
	-- INIT
	coroutine.wrap(function()
		while task.wait() do
			DeleteShop()
			BuildShop()
			task.wait(UtilitiesModule:HoursToSeconds(1))
		end
	end)()
end

local function Purchase(Player, ProductType, ProductName)
	-- Functions
	-- INIT
	local DoesPlayerHaveItem = ShortcutsModule:GetPlayerInventoryValue(Player, ProductType, ProductName)
	
	if DoesPlayerHaveItem then
		DebugModule:Print("Shop | Player already has item | Player: ".. tostring(Player).. " ProductName: ".. tostring(ProductName))
		return nil
	end
	
	local PlayerCECoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")
	
	DebugModule:Print("Shop | Purchase | Product Type: ".. tostring(ProductType).. " | Product Name: ".. tostring(ProductName))
	
	local Heap = require(UtilitiesModule:WaitForChildTimed(SharedInfoModulesFolder, ProductType)):GetAllInfo() --Heaps[ProductType] or Heaps[Conversion[ProductType]]
	
	--[[if not Heap then
		DebugModule:Print("Shop | Heap not found!")
		return nil
	else
		Heap = Heap["Heap"]()
	end]]
	
	local ProductInfo = Heap[ProductName]
	local Price = ProductInfo["Price"]["Coins"]
	
	if PlayerCECoinsValue.Value >= Price then
		InventoryModule:AddItem(Player, ProductType, ProductName)
	else
		DebugModule:Print("Shop | Player short of funds!")
		return nil
	end
	
	GameProcessRemote:FireAllClients("Game", "LogConsole", "Purchase", Player, "purchased: ".. tostring(ProductName)..  " ".. tostring(ProductType) --[[tostring(PluralToSingle[ProductType])]])
	GameProcessRemote:FireClient(Player, "Marketplace", "ShopPurchaseComplete")
	PlayerCECoinsValue.Value -= Price
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Purchase"] = 	Purchase
}

-- Direct
function ShopModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function ShopModule.Initialise()
	return CreateShop()
end

return ShopModule