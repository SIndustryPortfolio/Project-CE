local PowerUpDropsInfoModule = {}

-- CORE
local PowerUpDropsInfo = 
{
	["Nuke"] = {Duration = 10, Sound = {Id = "rbxassetid://7358219350"}, Image = {Id = "rbxassetid://11790029441"}},
	["Slowdown"] = {Duration = 30, Sound = {Id = "rbxassetid://1837832793", FromTime = 0, EndTime = 5}, Image = {Id = "rbxassetid://11790029267"}},
	["InstaKill"] = {Duration = 30, Sound = {Id = "rbxassetid://8642650762"}, Image = {Id = "rbxassetid://11484502631"}},
	["MaxAmmo"] = {Duration = nil, Sound = {Id = "rbxassetid://131062752"}, Image = {Id = ""}},
	["DoublePoints"] = {Duration = 30, Sound = {Id = "rbxassetid://131149750"}, Image = {Id = "rbxassetid://11842852952"}}
}

-- Functions
-- DIRECT
function PowerUpDropsInfoModule.GetPowerUpDropInfo(NilParam, SettingName)
	return PowerUpDropsInfo[SettingName]
end

function PowerUpDropsInfoModule.GetAllPowerUpDropInfo()
	return PowerUpDropsInfo
end

return PowerUpDropsInfoModule