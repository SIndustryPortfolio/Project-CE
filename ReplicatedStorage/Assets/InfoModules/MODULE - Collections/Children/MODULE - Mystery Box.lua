local MysteryBoxInfoModule = {}

-- CORE
local MysteryBoxInfo = 
{	
	["Hint"] = {Name = "Mystery Box"},
	["Icon"] = {Id = "rbxassetid://11796716253"},
	["Rotations"] = 50,
	["Price"] = 950,
	["HoldToInteract"] = true,
	["OpenSound"] = {Id = "rbxassetid://5645899877"},
	["TickSound"] = {Id = "rbxassetid://6761979152"}
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