local PerksInfoModule = {}

-- CORE
local PerksInfo = 
{
	["HP Perk"] = {Id = 1, Name = "HP PERK", Icon = {Id = "rbxassetid://9168559046"}, Multiplier = 1.5},
	["Marksman Perk"] = {Id = 2, Name = "MARKSMAN PERK", Icon = {Id = "rbxassetid://9168988394"}, Multiplier = 1.5},
	["Damage Perk"] = {Id = 3, Name = "DAMAGE PERK", Icon = {Id = "rbxassetid://9168559282"}, Multiplier = 1.25},
	["Explosive Perk"] = {Id = 4, Name = "EXPLOSIVE PERK", Icon = {Id = "rbxassetid://9168559183"}, Multiplier = 1.5}
}

-- Functions
-- MECHANICS
local function GetPerkFromId(Id)
	-- Functions
	-- INIT
	Id = tostring(Id)

	for PerkName, PerkInfo in pairs(PerksInfo) do
		if Id == tostring(PerkInfo["Id"]) then
			return PerkName
		end
	end
end

-- DIRECT
function PerksInfoModule.UnpackId(NilParam, Id)
	return GetPerkFromId(Id)
end

function PerksInfoModule.GetInfo(NilParam, SettingName)
	return PerksInfo[SettingName]
end

function PerksInfoModule.GetAllInfo()
	return PerksInfo
end

return PerksInfoModule