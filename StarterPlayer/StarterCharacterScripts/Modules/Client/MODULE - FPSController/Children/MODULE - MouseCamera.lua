local MouseDeltaModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Info Modules
local FpsInfoModule = require(SharedInfoModulesFolder["Fps"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local SettingsModule = require(SharedModulesFolder["Settings"])

-- Elements
-- MODELS
local Character = UtilitiesModule:GetCharacter(Player, true)

-- REMOTES
local MouseCameraEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "MouseCamera")

-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- CORE
local Connections = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function OnMouseMoved(ForceDelta, MobileOverwrite)
	-- CORE
	--local NewMouseTick = tick()
	local SensitivityMultiplier = nil

	if ForceDelta then
		SensitivityMultiplier = 1 
	else
		SensitivityMultiplier = FpsInfoModule:GetFpsInfo("SensitivityMultiplier")
	end

	-- Functions
	-- INIT
	local MouseDelta = nil

	if ForceDelta then
		MouseDelta = ForceDelta
	else
		MouseDelta = UserInputService:GetMouseDelta()
	end

	if Humanoid:GetAttribute("Ads") then
		SensitivityMultiplier = FpsInfoModule:GetFpsInfo("AdsSensitivityMultiplier")	
	end

	MouseDelta = 
		{
			X = MouseDelta.X * SensitivityMultiplier,
			Y = MouseDelta.Y * SensitivityMultiplier	
		}
	
	if not ForceDelta and table.find({"Computer", "Mobile", "Console"}, Player:GetAttributes()["Device"]) ~= nil then
		MouseDelta.X *= FpsInfoModule:GetFpsInfo("MouseSensitivity")
		MouseDelta.Y *= FpsInfoModule:GetFpsInfo("MouseSensitivity")
	end
	
	--DebugModule:Print(script.Name.. " | Delta | X: ".. tostring(MouseDelta.X).. " | Y: ".. tostring(MouseDelta.Y))
	
	if Player:GetAttribute("Device") == "Mobile" then
		--[[if Mouse.X < InterfacesModule:IsPageOpen("Custom", "Hud").AbsoluteSize.X / 2 then
			return nil
		end]]
		if not MobileOverwrite then
			return nil			
		end
	end

	--GlobalXCameraAngle -= (MouseDelta.X * Sensitivity)
	--GlobalYCameraAngle = math.clamp((GlobalYCameraAngle - MouseDelta.Y * Sensitivity), -60, 60)
	MouseCameraEvent:Fire(Vector2.new(MouseDelta.X, MouseDelta.Y))
end


--local Dragging = nil
local function onTouchMoved(input, gameProcessedEvent)
	if gameProcessedEvent then
		return nil
	end
	
	--[[if Humanoid.MoveDirection ~= Vector3.new() then
		local OldDragPosition = (input.Position - input.Delta)

		if input.Position ~= OldDragPosition then
			--DebugModule:Print("FPSHandler | Cancelling Touch Moved")
			Dragging = true
		else
			Dragging = false
		end
	end]]
	
	local Dampening = ((SettingsModule:GetSettingValue("Game", "GamepadXSensitivity") + SettingsModule:GetSettingValue("Game", "GamepadYSensitivity")) / 4) / 5
	
	--DebugModule:Print("FPSHandler | Mouse Moved")
	OnMouseMoved(input.Delta * Dampening, true)
end


local function OnJoystickMoved(input, gameProcessedEvent)
	-- CORE
	if input.UserInputType ~= Enum.UserInputType.Gamepad1 or input.KeyCode ~= Enum.KeyCode.Thumbstick2 then
		return nil
	end

	local Changed = false

	-- Functions
	-- DIRECT
	local Connection1 = nil
	local Connection2 = nil

	Connection1 = UserInputService.InputChanged:Connect(function(_Input, _GPE)
		if _Input.UserInputType == Enum.UserInputType.Gamepad1 and _Input.KeyCode == Enum.KeyCode.Thumbstick2 then
			Changed = true
			UtilitiesModule:DisconnectConnections({Connection1, Connection2})

			--[[Connection1:Disconnect()
			Connection2:Disconnect()]]
		end
	end)

	-- INIT

	local Delta = input.Delta
	local JoyStickDelta = {X = 0, Y = 0}


	local DeadZone = 0.2

	local MaxXSensitivity = SettingsModule:GetSettingValue("Game", "GamepadXSensitivity") --5
	local MaxYSensitivity = SettingsModule:GetSettingValue("Game", "GamepadYSensitivity") --5

	if input.Position.X ~= 0 and (input.Position.X > DeadZone or input.Position.X < -DeadZone) then
		JoyStickDelta.X = MaxXSensitivity * input.Position.X
	end

	if input.Position.Y ~= 0 and (input.Position.Y > DeadZone or input.Position.Y < -DeadZone) then 
		JoyStickDelta.Y = (MaxYSensitivity * input.Position.Y) * -1
	end

	--repeat
	--OnMouseMoved(JoyStickDelta)
	--task.wait()
	--until Changed or not Character or not Humanoid or Humanoid.Health <= 0

	Connection2 = RunService.RenderStepped:Connect(function()
		OnMouseMoved(JoyStickDelta)
	end)

	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = Mouse.Move:Connect(function()
		if Player:GetAttributes()["Device"] == "Computer" then
			return OnMouseMoved()
		end
	end)
	
	local Connection2 = UserInputService.InputChanged:Connect(function(...)
		if Player:GetAttributes()["Device"] == "Console" then
			return OnJoystickMoved(...)
		end
	end)
	
	local Connection3 = UserInputService.TouchMoved:Connect(function(...)
		if Player:GetAttributes()["Device"] == "Mobile" then
			return onTouchMoved(...)
		end
	end)
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	table.insert(Connections, Connection3)
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function MouseDeltaModule.Initialise()
	return Initialise()
end

function MouseDeltaModule.End()
	return End()
end

return MouseDeltaModule