local VehicleControllerModule = {}

-- FPS Controller Translator

-- Dirs
local ModelRoot = script.Parent.Parent

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local VehicleClientModule = require(script.Parent["Client"])
--
--local FPSControllerModule = UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSController")

-- Functions
-- MECHANICS
local function InputBegin(ActionName, InputObject)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Input Begin | ActionName: ".. tostring(ActionName).. " | InputObject: ".. tostring(InputObject))
	return VehicleClientModule:InputBegin(ActionName, InputObject)
end

local function InputEnd(ActionName, InputObject)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Input End | ActionName: ".. tostring(ActionName).. " | InputObject: ".. tostring(InputObject))
	return VehicleClientModule:InputEnd(ActionName, InputObject)
end

-- DIRECT
function VehicleControllerModule.GetInputs()
	return VehicleClientModule:GetInputs()
end

function VehicleControllerModule.InputBegin(NilParam, ...)
	return InputBegin(...)
end

function VehicleControllerModule.InputEnd(NilParam, ...)
	return InputEnd(...)
end

return VehicleControllerModule