local InventoryInfoModule = {}

-- CORE
local InventoryStoreNames = {}

local InventoryInfo = 
{
	["Categories"] =
	{
		["VisorColours"] = {},
		["Arms"] = {},
		["Legs"] = {},
		["Helmets"] = {},
		["Chestplates"] = {},
		["Camos"] = {},
		["Perks"] = {},
		["Covers"] = {},
		["ArmourEffects"] = {},
		["DeathEffects"] = {}
	}
}

-- Functions
-- DIRECT
function InventoryInfoModule.GetStoreNames()
	return InventoryStoreNames
end

function InventoryInfoModule.GetInventoryInfo(NilParam, SettingName)
	return InventoryInfo[SettingName]
end

function InventoryInfoModule.GetAllInventoryInfo()
	return InventoryInfo
end

-- INIT
for CategoryName, _ in pairs(InventoryInfo["Categories"]) do
	table.insert(InventoryStoreNames, CategoryName)
	table.insert(InventoryStoreNames, "Equipped".. CategoryName)	
end

return InventoryInfoModule