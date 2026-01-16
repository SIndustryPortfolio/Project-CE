local SettingsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Info Modules
local SettingsInfoModule = require(InfoModulesFolder["Settings"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Elements
-- FOLDERS
local SettingsFolder = nil --

if Player then
	SettingsFolder = Player:WaitForChild("Settings") --UtilitiesModule:WaitForChildTimed(Player, "Settings")
end

-- Functions
-- MECHANICS
local function GetSettingValueInstance(SettingType, SettingName)
	-- Functions
	-- INIT
	if not SettingsFolder then
		DebugModule:Print(script.Name.. " | GetSettingValueInstance | No Settings Folder!")
		return nil
	end
	
	local SettingsSubTypeFolder = UtilitiesModule:WaitForChildTimed(SettingsFolder, SettingType)

	local Value = UtilitiesModule:WaitForChildTimed(SettingsSubTypeFolder, SettingName)
	
	return Value
end

local function GetSettingValue(SettingType, SettingName, ConvertToBool)
	-- Functions
	-- INIT
	if not SettingsFolder then
		DebugModule:Print(script.Name.. " | GetSettingValue | No Settings Folder!")
		return nil
	end
	
	local Value = GetSettingValueInstance(SettingType, SettingName)
	
	if Value then
		Value = Value.Value
	else
		DebugModule:Print("Settings | Setting value doesn't exist | Type: ".. tostring(SettingType).. " | Name: ".. tostring(SettingName))
		return nil
	end
	
	if ConvertToBool then
		local ToggleToBool = {["ON"] = true, ["OFF"] = false}
		
		return ToggleToBool[Value]
	end
	
	return Value
end

local function ChangeDeviceSettingPreset(Device)
	-- Functions
	-- INIT
	local PresetInfo = SettingsInfoModule:GetDeviceSettingPresetInfo(Device)
	
	if not PresetInfo then
		return nil
	end
	
	for SettingCat, Settings in pairs(PresetInfo) do
		for SettingName, SettingValue in pairs(Settings) do
			GameProcessRemote:FireServer("Settings", "Change", SettingCat, SettingName, SettingValue)
		end
	end
end

local function ChangeSettingPreset(PresetName)
	-- CORE
	local PresetInfo = SettingsInfoModule:GetSettingPresetInfo(PresetName)
	
	-- Functions
	-- INIT
	if not PresetInfo then
		return nil
	end
	
	for SettingCat, Settings in pairs(PresetInfo) do
		for SettingName, SettingValue in pairs(Settings) do
			GameProcessRemote:FireServer("Settings", "Change", SettingCat, SettingName, SettingValue)
		end
	end
end

-- DIRECT
function SettingsModule.ChangeDevicePreset(NilParam, DeviceName)
	return ChangeDeviceSettingPreset(DeviceName)
end

function SettingsModule.ChangeSettingPreset(NilParam, PresetName)
	return ChangeSettingPreset(PresetName)
end

function SettingsModule.GetSettingValueInstance(NilParam, SettingType, SettingName)
	return GetSettingValueInstance(SettingType, SettingName)
end

function SettingsModule.GetSettingValue(NilParam, SettingType, SettingName, ConvertToBool)
	return GetSettingValue(SettingType, SettingName, ConvertToBool)
end


return SettingsModule