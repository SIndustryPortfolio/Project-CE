local MOTDInfoModule = {}

-- CORE
local MOTDInfo = 
{
	["Icon"] = {Id = "rbxassetid://9048272468"},
	["Description"] = {Text = "Remember! This game is in heavy pre alpha so expect the game to not run flawlessly. If you would like to support development of Project CE please donate via the in game shop."},
	["Title"] = {Text = "EXPECT BUGS!"}
}

-- Functions
-- DIRECT
function MOTDInfoModule.GetMOTDInfo(NilParam, SettingName)
	return MOTDInfo[SettingName]
end

function MOTDInfoModule.GetAllMOTDInfo()
	return MOTDInfo
end

return MOTDInfoModule