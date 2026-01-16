local SpecialRanksInfoModule = {}

-- CORE
local SpecialRanksInfo = 
{
	["Top Donator"] = {Id = "rbxassetid://11345529378"}
}

-- Functions
-- MECHANICS
local function UnpackId(Id)
	-- Functions
	-- INIT
	for Name, Info in pairs(SpecialRanksInfo) do
		if Info["Id"] == Id then
			return Name
		end
	end
end

-- DIRECT
function SpecialRanksInfoModule.UnpackId(NilParam, Id)
	return UnpackId(Id)
end

function SpecialRanksInfoModule.GetSpecialRankInfo(NilParam, SettingName)
	return SpecialRanksInfo[SettingName]
end

function SpecialRanksInfoModule.GetAllSpecialRanksInfo()
	return SpecialRanksInfo
end

return SpecialRanksInfoModule