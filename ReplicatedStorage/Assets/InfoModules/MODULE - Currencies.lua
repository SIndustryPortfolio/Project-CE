local CurrenciesInfoModule = {}

-- CORE
local CurrencyInfo = 
{
	["CECoins"] = {Id = "rbxassetid://11636184648"},
	["Robux"] = {Id = "rbxassetid://9091506472"}
}

-- Functions
-- DIRECT
function CurrenciesInfoModule.GetCurrencyInfo(NilParam, SettingName)
	return CurrencyInfo[SettingName]
end

return CurrenciesInfoModule