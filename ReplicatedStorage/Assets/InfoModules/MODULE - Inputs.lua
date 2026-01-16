local InputsInfoModule = {}

-- CORE
local Console = 
{
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonSelect,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.Thumbstick2,
	Enum.KeyCode.Thumbstick1,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.UserInputType.Gamepad1,
	Enum.UserInputType.Gamepad2,
	Enum.UserInputType.Gamepad3,
	Enum.UserInputType.Gamepad4,
	Enum.UserInputType.Gamepad5,
	Enum.UserInputType.Gamepad6,
	Enum.UserInputType.Gamepad7,
	Enum.UserInputType.Gamepad8,
}

local Mobile = 
{
	Enum.UserInputType.Touch,
	Enum.UserInputType.Gyro
}

-- Functions
-- CORE FUNCTIONS
local DeviceNameToInputSet = 
{
	["Console"] = Console,
	["Mobile"] = Mobile
}	

-- DIRECT
function InputsInfoModule.GetInputInfo(NilParam, DeviceName)
	return DeviceNameToInputSet[DeviceName]
end

function InputsInfoModule.GetAllInputInfo()
	return DeviceNameToInputSet
end

return InputsInfoModule