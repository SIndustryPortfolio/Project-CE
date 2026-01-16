local CameraYOffsetModule = {}

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
local LastOffsetTime = tick()

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
			Camera:SetAttribute("YOffset", math.clamp((Camera:GetAttribute("YOffset") or BaseFOV) - 1, BaseFOV, math.huge))
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
	local Decrement = Camera:GetAttribute("YOffset") / 20

	-- Functions
	-- MECHANICS
	local function Render()
		-- Functions
		-- INIT
		if not CustomConnection or not CustomConnection.Value or not ReturningToZero then
			return nil
		end
		
		Camera:SetAttribute("YOffset", math.clamp(Camera:GetAttribute("YOffset") - Decrement, 0, math.huge))
		
		if Camera:GetAttribute("YOffset") <= 0 then
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
		local Decrement = Camera:GetAttribute("YOffset") / 20
		
		repeat
			Camera:SetAttribute("YOffset", math.clamp(Camera:GetAttribute("YOffset") - Decrement, 0, math.huge))
			task.wait()
		until not CustomConnection or not CustomConnection.Value or Camera:GetAttribute("YOffset") <= 0
		ReturningToZero = false

		--
		UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	end)()]]
end

local function Initialise(CameraModule, YOffset)
	-- CORE
	local Camera = CameraModule:GetCamera()
	LastOffsetTime = tick()

	-- Functions
	-- INIT
	Reset()
	
	--UtilitiesModule:CancelTween(Camera, TweenDict)
	
	local EstimatedResult = math.clamp((Camera:GetAttributes()["YOffset"] or 0) + YOffset, 0, 10)
	
	Camera:SetAttribute("YOffset", EstimatedResult)
	
	task.wait(.125)
	
	if not ReturningToZero and Camera:GetAttribute("YOffset") == EstimatedResult and (tick() - LastOffsetTime) >= .1 then
		return ReturnToZero(CameraModule)
	end
end

function Reset()
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
function CameraYOffsetModule.Initialise(NilParam, CameraModule, Offset)
	return Initialise(CameraModule, Offset)
end

function CameraYOffsetModule.End(NilParam, CameraModule, Type)
	return End(CustomConnections[Type])
end

function CameraYOffsetModule.Reset()
	return Reset()
end

return CameraYOffsetModule