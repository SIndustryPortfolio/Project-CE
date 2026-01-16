local MysteryBoxInfoModule = {}

-- CORE
local MysteryBoxInfo = 
{	
	["Hint"] = {Name = "Thumper Pumper"},
	["Icon"] = {Id = "rbxassetid://11910202477"},
	["Price"] = 3000,
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