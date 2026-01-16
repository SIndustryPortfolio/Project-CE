-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Modules
local WeaponsModule = require(InfoModulesFolder["Weapons"])

-- CORE
local VehicleInfo = 
{
	["VehicleIcon"] = "rbxassetid://11241372932",
	["GunInfo"] = WeaponsModule:GetWeaponInfo("Machine Gun Turret"),
	["CameraOffset"] = Vector3.new(0, 3, 6),
	["SpinUpTime"] = .5,
	["Bounds"] = {["X"] = {-90, 90}, ["Y"] = {-60, 60}}
}

return VehicleInfo