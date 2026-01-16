local CommandModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- InfoModules
--[[local ArmourEffectsInfoModule = require(SharedInfoModulesFolder["ArmourEffects"])
local CamosInfoModule = require(SharedInfoModulesFolder["Camos"])
local VisorColoursInfoModule = require(SharedInfoModulesFolder["VisorColours"])
local CoversInfoModule = require(SharedInfoModulesFolder["Covers"])]]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local InventoryModule = require(ServerModulesFolder["Inventory"])

-- CORE
local AdminType = "Owner"

--[[local TypeToHeap = 
{
	["Covers"] = CoversInfoModule.GetAllCoversInfo,
	["ArmourEffects"] = ArmourEffectsInfoModule.GetAllArmourEffects,
	["Camos"] = CamosInfoModule.GetAllCamosInfo,	
	["VisorColours"] = VisorColoursInfoModule.GetAllVisorColoursInfo
}]]

-- Functions
-- MECHANICS
local function GetInventoryTypeFromAbbreviation(Player, ItemType)
	-- Functions
	-- INIT
	local PlayerInventoryFolder = UtilitiesModule:WaitForChildTimed(Player, "Inventory")
	
	for i, SubInventoryFolder in pairs(PlayerInventoryFolder:GetChildren()) do
		local FolderName = string.lower(SubInventoryFolder.Name)
		
		if string.sub(FolderName, 1, string.len(ItemType)) == ItemType then
			return SubInventoryFolder.Name
		end
	end
end

local function GetItemNameFromAbbreviation(ItemName, Heap)
	-- Functions
	-- INIT
	for Name, Info in pairs(Heap) do
		local _ItemName = string.lower(Name)
		
		if string.sub(_ItemName, 1, string.len(ItemName)) == ItemName then
			return Name
		end
	end
end

local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	local ItemType = Args[2] --AdminModule:GetMessageFromArgs(Args, 2)
	local ItemName = AdminModule:GetMessageFromArgs(Args, 3)
	
	DebugModule:Print("Pre Item Type: ".. tostring(ItemType))
	DebugModule:Print("Pre Item Name: ".. tostring(ItemName))
	
	local InventoryType = GetInventoryTypeFromAbbreviation(Player, ItemType)
	DebugModule:Print("Inventory Type: ".. tostring(InventoryType))
	
	local Heap = require(UtilitiesModule:WaitForChildTimed(SharedInfoModulesFolder, InventoryType)):GetAllInfo()
	
	ItemName = GetItemNameFromAbbreviation(ItemName, Heap) --GetItemNameFromAbbreviation(ItemName, TypeToHeap[InventoryType]())
	
	DebugModule:Print("Inventory Type: ".. tostring(InventoryType))
	DebugModule:Print("Item Name: "..  tostring(ItemName))
	
	if not ItemName then
		return nil
	end
	
	for i, Recipient in pairs(Recipients) do
		InventoryModule:AddItem(Recipient, InventoryType, ItemName)
	end
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end

return CommandModule