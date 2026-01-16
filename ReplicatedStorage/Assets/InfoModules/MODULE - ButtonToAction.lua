local ButtonToActionInfoModule = {}

-- CORE
local UiButtonToAction = 
{
	["Console"] = 
	{
		[Enum.KeyCode.ButtonA] = {Image = {Id = "rbxassetid://8839280853"}, ActionName = "Select"},
		[Enum.KeyCode.ButtonSelect] = {Image = {Id = "rbxassetid://8839280688"}, ActionName = "UI / Game"},
		[Enum.KeyCode.ButtonStart] = {Image = {Id = "rbxassetid://8839280587"}, ActionName = "Roblox Menu"},
		[Enum.KeyCode.ButtonB] = {Image = {Id = "rbxassetid://8839280760"}, ActionName = "Back"}
	}	
}

local Conversion = 
{
	["Ui"] = UiButtonToAction	
}

-- Functions
-- DIRECT
function ButtonToActionInfoModule.GetButtonToActionInfo(NilParam, Type, Device)
	return Conversion[Type][Device]
end

function ButtonToActionInfoModule.GetAllButtonToActionInfo()
	return Conversion
end

return ButtonToActionInfoModule