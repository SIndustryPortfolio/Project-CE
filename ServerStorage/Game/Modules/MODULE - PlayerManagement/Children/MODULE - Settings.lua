local SettingsModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local SettingsInfoModule = require(InfoModulesFolder["Settings"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function GetPlayerSettingValue(Player, SettingType, SettingName)
	-- Elements
	-- FOLDERS
	local SettingsFolder = UtilitiesModule:WaitForChildTimed(Player, "Settings")
	local SubSettingsFolder = UtilitiesModule:WaitForChildTimed(SettingsFolder, SettingType)
	
	return UtilitiesModule:WaitForChildTimed(SubSettingsFolder, SettingName)
end

local function CreateSubSettings(Player, SettingType, SubSettings)
	-- Elements
	-- FOLDERS
	local SubSettingFolder = Instance.new("Folder")
	SubSettingFolder.Name = SettingType
	SubSettingFolder.Parent = UtilitiesModule:WaitForChildTimed(Player, "Settings")
	
	for SettingName, SettingInfo in pairs(SubSettings) do
		local DefaultValueInstance = nil
		
		if SettingInfo["Type"] and SettingInfo["Type"] == "Slider" then
			DefaultValueInstance = Instance.new("NumberValue")
		else
			DefaultValueInstance = Instance.new("StringValue")
		end
		
		DefaultValueInstance.Name = SettingName
		DefaultValueInstance.Value = SettingInfo["DefaultValue"]
		DefaultValueInstance.Parent = SubSettingFolder
	end
end

local function CreatePlayerSettings(Player)
	-- Instancing
	local SettingsFolder = Instance.new("Folder")
	SettingsFolder.Name = "Settings"
	SettingsFolder.Parent = Player
	
	-- Functions
	-- INIT
	for SettingType, SettingTypeInfo in pairs(SettingsInfoModule:GetAllSettingPageInfo()) do
		CreateSubSettings(Player, SettingType, SettingTypeInfo["Table"])
	end
end

local function ChangeSetting(Player, SettingType, SettingName, SettingValue)
	-- CORE
	local SettingInfo = SettingsInfoModule:GetSettingPageInfo(SettingType)[SettingName]
	local SettingInstanceValue = GetPlayerSettingValue(Player, SettingType, SettingName)
	
	if not SettingInstanceValue then
		DebugModule:Print("Settings | Cannot find Setting Instance Value | Type: ".. tostring(SettingType).. " | Name: ".. tostring(SettingName))
		return nil
	end
	
	-- Functions
	-- INIT
	if SettingInfo["LockedValue"] then
		if Player:GetAttributes()["Device"] == SettingInfo["LockedValue"]["Device"] then
			SettingInstanceValue.Value = SettingInfo["LockedValue"]["Value"]
			return nil
		end	
	end
	
	if SettingInfo["Type"] == "Toggle" then
		if not table.find(SettingInfo["AcceptableValues"], SettingValue) then
			return nil
		end
	elseif SettingInfo["Type"] == "Adjustable" then
		SettingValue = tonumber(SettingValue)
		
		if SettingValue < tonumber(SettingInfo["AcceptableValueBounds"]["Min"]) or SettingValue > tonumber(SettingInfo["AcceptableValueBounds"]["Max"]) then
			return nil
		end
	end
		
	SettingInstanceValue.Value = SettingValue
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Change"] = function(...)
		return ChangeSetting(...)
	end,	
}

-- DIRECT
function SettingsModule.CreatePlayerSettings(NilParam, PlayerManagementModule, Player)
	return CreatePlayerSettings(Player)
end

function SettingsModule.ClientRequest(NilParam, PlayerManagementModule, FunctionName, ...)
	return ClientRequests[FunctionName](...)
end

return SettingsModule