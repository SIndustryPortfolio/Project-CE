local InventoryMarketplaceModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InventoryModule = require(ServerModulesFolder["Inventory"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- Functions
-- MECHANICS
local function Initialise(Player, FolderType, ItemName)
	-- Functions
	-- INIT
	if ShortcutsModule:GetPlayerInventoryValue(Player, FolderType, ItemName) then
		return nil
	end
	
	InventoryModule:AddItem(Player, FolderType, ItemName)
end

-- DIRECT
function InventoryMarketplaceModule.Initialise(NilParam, Player, FolderType, ItemName)
	return Initialise(Player, FolderType, ItemName)
end

return InventoryMarketplaceModule