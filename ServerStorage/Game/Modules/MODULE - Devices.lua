local DevicesModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local DevicesInfoModule = require(SharedInfoModulesFolder["Devices"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local DeviceTypes = UtilitiesModule:GetDictKeys(DevicesInfoModule:GetAllDevicesInfo()) --{"Console", "Mobile", "Computer"}

-- Functions
-- MECHANICS
local function ChangeDevice(Player, DeviceName)
	-- Functions
	-- INIT
	if not table.find(DeviceTypes, DeviceName) then
		return nil
	end
	
	Player:SetAttribute("Device", DeviceName)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["ChangeDevice"] = ChangeDevice
}

-- DIRECT
function DevicesModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

return DevicesModule