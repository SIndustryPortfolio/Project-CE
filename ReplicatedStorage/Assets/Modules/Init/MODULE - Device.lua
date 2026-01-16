local DeviceModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local SettingsModule = require(SharedModulesFolder["Settings"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE
local DeviceName = ""

local TouchInput = 
{
	Enum.UserInputType.Touch,
	Enum.UserInputType.Gyro,
	Enum.UserInputType.Accelerometer	
}

local KeyboardInput = 
{
	Enum.UserInputType.Keyboard		
}

local MouseInput = 
{	
	Enum.UserInputType.MouseButton1,
	Enum.UserInputType.MouseButton2,
	Enum.UserInputType.MouseButton3,
	Enum.UserInputType.MouseMovement,
	Enum.UserInputType.MouseWheel
}

local GamepadInput = 
{
	Enum.UserInputType.Gamepad1,
	Enum.UserInputType.Gamepad2,
	Enum.UserInputType.Gamepad3,
	Enum.UserInputType.Gamepad4,
	Enum.UserInputType.Gamepad5,
	Enum.UserInputType.Gamepad6,
	Enum.UserInputType.Gamepad7,
	Enum.UserInputType.Gamepad8
}

-- Services
local UserInputService = game:GetService("UserInputService")

-- Functions
-- MECHANICS
local function GetDeviceFromInputType(InputType)
	-- Functions
	-- INIT
	if table.find(KeyboardInput, InputType) or table.find(MouseInput, InputType) then
		return "Computer"
	elseif table.find(GamepadInput, InputType) then
		return "Console"
	elseif table.find(TouchInput, InputType) then
		return "Mobile"
	end
end

local function Initialise()
	-- Functions
	-- MECHANICS
	local function Update(LastInputType)
		-- Functions
		-- INIT
		if GetDeviceFromInputType(LastInputType) == DeviceName then
			return nil
		end
		
		DeviceName = GetDeviceFromInputType(LastInputType)
		SettingsModule:ChangeDevicePreset(DeviceName)
		return GameProcessRemote:FireServer("Devices", "ChangeDevice", DeviceName)
	end
	
	-- DIRECT
	local Connection1 = UserInputService.LastInputTypeChanged:Connect(function(LastInputType)
		return Update(LastInputType)
	end)
	
	-- INIT
	return Update(UserInputService:GetLastInputType())
end

-- DIRECT
function DeviceModule.Initialise()
	return Initialise()
end

return DeviceModule