local ArmourEffectsInfoModule = {}

-- CORE
local ArmourEffects = 
{
	["Blue Fire"] = {Id = 1, Price = {Coins = 1000}, Wrap = {Id = "rbxassetid://10250226844", Scale = Enum.ScaleType.Fit}, Description = "Burn bright. Burn blue", Rarity = "Legendary"},
	["Fire"] = {Id = 2, Crew = true, Wrap = {Id = "rbxassetid://10250226664", Scale = Enum.ScaleType.Fit}, Description = "Burn bright", Rarity = "Legendary"},
	["Stench"] = {Id = 3, Crew = true, Wrap = {Id = "rbxassetid://10255260399", Scale = Enum.ScaleType.Fit}, Description = "Foul brown clouds stink and swirl around steel.", Rarity = "Epic"},
	["Inclement Weather"] = {Id = 4, Crew = true, Wrap = {Id = "rbxassetid://10255260579", Scale = Enum.ScaleType.Fit}, Description = "High voltage, indeed", Rarity = "Epic"},
	["Hearts"] = {Id = 5, Price = {Coins = 500}, Wrap = {Id = "rbxassetid://10269478717", Scale = Enum.ScaleType.Fit}, Description = "Numerous laws of attraction", Rarity = "Epic"},
	["Alterra"] = {Id = 6, Price = {Coins = 500}, Wrap = {Id = "rbxassetid://10279477611", Scale = Enum.ScaleType.Fit}, Description = "Proximus", Rarity = "Epic"},
	["Default"] = {Id = 7, Price = {Coins = 500}, Wrap = {Id = "rbxassetid://10338922594", Scale = Enum.ScaleType.Fit}, Description = "Just a default particle emitter", Rarity = "Epic"},
	["Party"] = {Id = 8, Price = {Coins = 500}, Wrap = {Id = "rbxassetid://10338921027", Scale = Enum.ScaleType.Fit}, Description = "Bring the confetti", Rarity = "Epic"}
}

-- Functions
-- MECHANICS
local function GetEffectFromId(Id)
	-- Functions
	-- INIT
	Id = tostring(Id)
	
	for EffectName, EffectInfo in pairs(ArmourEffects) do
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
	for ItemName, ItemInfo in pairs(ArmourEffects) do
		if ItemInfo["Crew"] then
			continue
		end
		
		table.insert(Sellable, ItemName)
	end
	
	return Sellable
end

-- DIRECT
function ArmourEffectsInfoModule.GetSellable()
	return GetSellable()
end

function ArmourEffectsInfoModule.UnpackId(NilParam, Id)
	return GetEffectFromId(Id)
end

function ArmourEffectsInfoModule.GetInfo(NilParam, SettingName)
	return ArmourEffects[SettingName]
end

function ArmourEffectsInfoModule.GetAllInfo()
	return ArmourEffects
end

return ArmourEffectsInfoModule