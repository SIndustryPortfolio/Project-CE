local MysteryBoxInfoModule = {}

-- CORE
local MysteryBoxInfo = 
{	
	["Hint"] = {Name = "Juggernog"},
	["Icon"] = {Id = "rbxassetid://11847044043"},
	["Price"] = 2500,
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