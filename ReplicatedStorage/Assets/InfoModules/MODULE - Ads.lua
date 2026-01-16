local AdsInfoModule = {}

-- CORE
local AdsInfo = 
{
	[1] = {FieldOfView = 50},
	[1.5] = {FieldOfView = 45},
	[2] = {FieldOfView = 40},
	[4] = {FieldOfView = 20}
}
-- Functions
-- DIRECT
function AdsInfoModule.GetAdsInfo(NilParam, SettingName)
	return AdsInfo[SettingName]
end

function AdsInfoModule.GetAllAdsInfo()
	return AdsInfo
end

return AdsInfoModule