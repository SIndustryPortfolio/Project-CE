local InventoryModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- Functions
-- MECHANICS
local function CreateItem(ItemName)
	-- Functions
	-- INIT
	local BoolValue = Instance.new("BoolValue")
	BoolValue.Name = tostring(ItemName)
	
	return BoolValue
end

local function AddItem(Player, ItemType, ItemName)
	-- Functions
	-- INIT
	DebugModule:Print("Inventory | Adding Item | Type: ".. tostring(ItemType).. " | Name: ".. tostring(ItemName).. " | Player: ".. tostring(Player))
	
	local PlayerInventoryFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, ItemType)
	local Item = CreateItem(ItemName)
	Item.Parent = PlayerInventoryFolder
end

local function Equip(Player, InventoryType, ItemName)
	-- Functions
	-- INIT
	local InventoryFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, InventoryType)
	local InventoryValue = ShortcutsModule:GetPlayerInventoryValue(Player, InventoryType, ItemName)
	
	if not InventoryValue then
		DebugModule:Print("Inventory | Player: ".. tostring(Player).. " trying to equip item they don't own | Name: ".. tostring(ItemName).. " | Type: ".. tostring(InventoryType))
		return nil
	end
	
	InventoryFolder:SetAttribute("Equipped", ItemName)
end

local function Unequip(Player, InventoryType)
	-- Functions
	-- INIT
	local InventoryFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, InventoryType)
	
	if not InventoryFolder then
		DebugModule:Print("Inventory | Folder not found: ".. tostring(InventoryType))
		return nil
	end
	
	InventoryFolder:SetAttribute("Equipped", "")
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Equip"] = Equip,
	["Unequip"] = Unequip
}

-- DIRECT
function InventoryModule.AddItem(NilParam, Player, ItemType, ItemName)
	return AddItem(Player, ItemType, ItemName)
end

function InventoryModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

return InventoryModule