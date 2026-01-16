local MysteryBoxInfoModule = {}

-- CORE
local MysteryBoxInfo = 
{	
	["Hint"] = {Name = "Stamin Up"},
	["Icon"] = {Id = "rbxassetid://11881251707"},
	["Price"] = 2000,
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