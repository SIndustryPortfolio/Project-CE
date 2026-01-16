local MysteryBoxInfoModule = {}

-- CORE
local MysteryBoxInfo = 
{	
	["Hint"] = {Name = "Deadshot Daiquiri"},
	["Icon"] = {Id = "rbxassetid://11861739787"},
	["Price"] = 1500,
	["HoldToInteract"] = true,
}

-- Functions
-- DIRECT
function MysteryBoxInfoModule.GetInfo(NilParam, SettingName)
	return MysteryBoxInfo[SettingName]
end

function MysteryBoxInfoModule.GetAllInfo()
	return MysteryBoxInfo
end

return MysteryBoxInfoModule