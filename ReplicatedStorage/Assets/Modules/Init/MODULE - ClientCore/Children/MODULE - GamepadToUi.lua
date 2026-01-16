local GamepadToUiModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Elements
-- REMOTES
local InterfaceRemote = ClientRemotesFolder["Interface"]

-- Info Modules
local ButtonToActionInfoModule = require(InfoModulesFolder["ButtonToAction"])

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- CORE
local Connections = {}

-- Services
local UserInputService = game:GetService("UserInputService")

-- Functions
-- MECHANICS
local function IsGamepadInput(InputObject)
	-- Functions
	-- INIT
	for i = 1, 8 do
		if InputObject.UserInputType == Enum.UserInputType["Gamepad".. tostring(i)] then
			return true
		end
	end
	
	return false
end

local function IsGameProcessedEventExtra()
	-- Functions
	-- INIT
	if InterfacesModule:IsPageOpen("Custom", "GetUserKeyInput") then
		return true
	end
end

local function HandleGamepadInput(InputObject, GameProcessedEvent)
	-- CORE
	local ButtonInfo = ButtonToActionInfoModule:GetButtonToActionInfo("Ui", "Console")[InputObject.KeyCode]
	
	-- Functions
	-- INIT
	if not ButtonInfo or IsGameProcessedEventExtra() then
		return nil
	end
	
	InterfaceRemote:Fire(ButtonInfo["ActionName"])
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
		if not IsGamepadInput(InputObject) then
			return nil
		end
		
		return HandleGamepadInput(InputObject, GameProcessedEvent)
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
end

-- DIRECT
function GamepadToUiModule.Initialise()
	return Initialise()
end

return GamepadToUiModule