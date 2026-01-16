local CameraFovOffsetModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local AdsInfoModule = require(InfoModulesFolder["Ads"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- CORE
local TweenDict = {}
local CustomConnections = {}
local ReturningToZero = false
local AdsReturningToZero = false
local MaxFOVOffset = .25

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS

--[[local function ReturnADSToZero(CameraModule)
	-- CORE
	local Camera = CameraModule:GetCamera()
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	local BaseFOV = ShortcutsModule:GetBaseFieldOfView(CameraModule)
	
	-- Functions
	-- INIT
	AdsReturningToZero = true
	
	coroutine.wrap(function()
		repeat
			task.wait()
			BaseFOV = ShortcutsModule:GetBaseFieldOfView(CameraModule)
			Camera:SetAttribute("FOVOffset", math.clamp((Camera:GetAttribute("FOVOffset") or BaseFOV) - 1, BaseFOV, math.huge))
		until not CustomConnection or not CustomConnection.Value or Camera.FieldOfView <= BaseFOV
		AdsReturningToZero = false
		
		--
		UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	end)()
end]]

local function ReturnToZero(CameraModule)
	-- CORE
	local Camera = CameraModule:GetCamera()
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	
	local Decrement = 0.05
	
	-- Functions
	-- MECHANICS
	local function Render()
		-- Functions
		-- INIT
		if not CustomConnection or not CustomConnection.Value or not ReturningToZero then
			return nil
		end

		Camera:SetAttribute("FOVOffset", math.clamp(Camera:GetAttribute("FOVOffset") - Decrement, 0, math.huge))

		if Camera:GetAttribute("FOVOffset") <= 0 then
			pcall(function()
				RunService:UnbindFromRenderStep(script.Name.. "Return")
			end)

			ReturningToZero = false

			UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
	end
	
	-- INIT
	ReturningToZero = true
	
	pcall(function()
		return RunService:UnbindFromRenderStep(script.Name.. "Return")
	end)

	RunService:BindToRenderStep(script.Name.. "Return", Enum.RenderPriority.Last.Value, Render)
	
	--[[coroutine.wrap(function()
		repeat
			task.wait()
			Camera:SetAttribute("FOVOffset", math.clamp(Camera:GetAttribute("FOVOffset") - 0.05, 0, math.huge))
		until not CustomConnection or not CustomConnection.Value or Camera:GetAttribute("FOVOffset") <= 0
		ReturningToZero = false
		
		--
		UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	end)()]]
end

local function Initialise(CameraModule, FovOffset)
	-- CORE
	local Camera = CameraModule:GetCamera()
	
	-- Functions
	-- INIT
	UtilitiesModule:CancelTween(Camera, TweenDict)
	
	Camera:SetAttribute("FOVOffset", math.clamp((Camera:GetAttributes()["FOVOffset"] or 0) + FovOffset, 0, MaxFOVOffset))
	--Camera:SetAttribute("FOVOffset", (Camera:GetAttributes()["FOVOffset"] or 0) + FovOffset)	
	
	--[[if not AdsReturningToZero then
		ReturnADSToZero(CameraModule)
	end]]
	
	if not ReturningToZero then
		return ReturnToZero(CameraModule)
	end
end

local function Reset()
	-- Functions
	-- INIT
	RunService:UnbindFromRenderStep(script.Name.. "Return")
	
	for Type, CustomConnectionsTable in pairs(CustomConnections) do
		UtilitiesModule:DisconnectCustomConnections(CustomConnectionsTable)
	end
	
	CustomConnections = {}
	
	ReturningToZero = false
end


local function End(CameraModule, Type)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections(CustomConnections[Type])
end

-- DIRECT
function CameraFovOffsetModule.Initialise(NilParam, CameraModule, Offset)
	return Initialise(CameraModule, Offset)
end

function CameraFovOffsetModule.End(NilParam, CameraModule, Type)
	return End(CustomConnections[Type])
end

function CameraFovOffsetModule.Reset()
	return Reset()
end

return CameraFovOffsetModule