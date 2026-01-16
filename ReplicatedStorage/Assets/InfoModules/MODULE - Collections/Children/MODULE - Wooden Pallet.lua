local WoodenPalletInfoModule = {}

-- CORE
local WoodenPalletInfo = 
{
	["Properties"] = 
	{
		["Humanoid"] = 
		{
			["MaxHealth"] = 30,
			["Health"] = 30
		}
	}
}

-- Functions
-- DIRECT
function WoodenPalletInfoModule.GetInfo(NilParam, SettingName)
	return WoodenPalletInfo[SettingName]
end

function WoodenPalletInfoModule.GetAllInfo()
	return WoodenPalletInfo
end

return WoodenPalletInfoModule