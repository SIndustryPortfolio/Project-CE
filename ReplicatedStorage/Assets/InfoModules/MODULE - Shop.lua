local ShopInfoModule = {}

-- Workspace gravity: 196.2

-- CORE
local ShopInfo = 
{
	["Tiles"] = 
	{
		["Default"] = {Id = "rbxassetid://9162157147"},
		["Gold"] = {Id = "rbxassetid://10268164073"}
	}	
}

-- Functions
-- DIRECT
function ShopInfoModule.GetAllShopInfo()
	return ShopInfo
end

function ShopInfoModule.GetShopInfo(NilParam, SettingName)
	return ShopInfo[SettingName]
end

return ShopInfoModule