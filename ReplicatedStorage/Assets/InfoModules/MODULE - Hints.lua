local HintsInfoModule = {}

-- Dirs
--local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
--local PowerUpsInfoModule = require(InfoModulesFolder["PowerUps"])

-- CORE
local HintsInfo = 
{
	["Ammo"] = {Image = {Id = "rbxassetid://8833341234"}},
	["Explosive"] = {Image = {Id = "rbxassetid://8839772923"}},
	["Turret"] = {Image = {Id = "rbxassetid://8839772826"}},
	["Health"] = {Image = {Id = "rbxassetid://8840874338"}},
	["PowerUp"] = {Image = {Id = "rbxassetid://8840925138"}}
}

-- Functions
-- DIRECT
function HintsInfoModule.GetHintInfo(NilParam, SettingName)
	return HintsInfo[SettingName]
end

function HintsInfoModule.GetAllHintInfo()
	return HintsInfo
end

-- INIT
--[[for PowerUpName, Info in pairs(PowerUpsInfoModule:GetAllPowerUpInfo()) do
	HintsInfo[PowerUpName] = HintsInfo["PowerUp"]
end]]

return HintsInfoModule