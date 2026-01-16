local HelmetsInfoModule = {}

-- CORE
local Helmets = 
{
	["CQB"] = {Id = 1, Price = {Coins = 1000}, Description = "CQB Helmet", Rarity = "Legendary"},
	["MarkStupid"] = {Id = 2, Crew = true, Description = "MarkStupid Helmet", Rarity = "Legendary"},
	["ODST"] = {Id = 3, Price = {Coins = 1000}, Description = "ODST Helmet", Rarity = "Epic"},
	["Recon"] = {Id = 4, Crew = true, Description = "Recon Helmet", Rarity = "Epic"},
}

-- Functions
-- MECHANICS
local function GetEffectFromId(Id)
	-- Functions
	-- INIT
	Id = tostring(Id)
	
	for EffectName, EffectInfo in pairs(Helmets) do
		if Id == tostring(EffectInfo["Id"]) then
			return EffectName
		end
	end
end

local function GetSellable()
	-- CORE
	local Sellable = {}
	
	-- Functions
	-- INIT
	for ItemName, ItemInfo in pairs(Helmets) do
		if ItemInfo["Crew"] then
			continue
		end
		
		table.insert(Sellable, ItemName)
	end
	
	return Sellable
end

-- DIRECT
function HelmetsInfoModule.GetSellable()
	return GetSellable()
end

function HelmetsInfoModule.UnpackId(NilParam, Id)
	return GetEffectFromId(Id)
end

function HelmetsInfoModule.GetInfo(NilParam, SettingName)
	return Helmets[SettingName]
end

function HelmetsInfoModule.GetAllInfo()
	return Helmets
end

return HelmetsInfoModule