local RotateAroundViewportPartModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function SetupViewportCamera()
	-- Functions
	-- INIT
	local Camera = Instance.new("Camera")
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = nil
	
	return Camera
end

local function Initialise(CameraModule, Viewport, CustomConnection, Increment, ZOffset, StartAngle, UpdateTable)
	if not CameraModule or not Viewport or not CustomConnection then
		DebugModule:Print("RotateAroundViewportPart | Cancelled rotate around viewport")
		--DebugModule:Print"CANCELLED ROTATE AROUND VIEWPORT | Camera Module: ".. tostring(CameraModule).. " | Viewport: ".. tostring(Viewport).. " | Custom Connection: ".. tostring(CustomConnection))
		return nil
	end
	
	-- CORE
	if not UpdateTable then
		UpdateTable = {}
	end
	
	local PartToRotateAround = Viewport:FindFirstChildWhichIsA("BasePart") or Viewport:FindFirstChildOfClass("Model") or UpdateTable[1]
	local PartToShift = UtilitiesModule:GetPartToShift(PartToRotateAround)
	local Angle = 0
	local Offset = 5 -- Studs
	
	if ZOffset then
		Offset += ZOffset
	end
	
	-- Functions
	-- INIT
	if not Viewport.CurrentCamera then
		local Camera = SetupViewportCamera()
		Camera.CameraSubject = PartToShift
		Camera.Parent = Viewport
		Viewport.CurrentCamera = Camera
	end
	
	if StartAngle then
		Angle += StartAngle
	end
	
	local ViewportCamera = Viewport.CurrentCamera
	
	local Connection1 = nil
	
	Connection1 = RunService.Stepped:Connect(function()
		local Success, Error = pcall(function()
			if not CustomConnection or not CustomConnection.Value or not Viewport or not ViewportCamera then
				DebugModule:Print("RotateAroundViewport | Loop successfully broke")
				return UtilitiesModule:DisconnectConnections({Connection1})
			end
			
			local Subject = UtilitiesModule:GetPartToShift(UpdateTable[1] or ViewportCamera.CameraSubject)

			if Subject then 
				ViewportCamera.CFrame = (Subject.CFrame * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(0, 0, (Subject.Size.Z / 2) + Offset)
			end

			Angle += Increment or 1
		end)
		
		if not Success then
			DebugModule:Print("RotateAroundViewportPart | Error: ".. tostring(Error))
		end
	end)
	
	
	--[[coroutine.wrap(function()
		local Success, Error = pcall(function()
			DebugModule:Print("RotateAroundViewportPart | Started Rotation")
			local ViewportCamera = Viewport.CurrentCamera
			
			while CustomConnection and CustomConnection.Value and Viewport and ViewportCamera --[[and (Viewport.CurrentCamera.CameraSubject or UpdateTable[1])]] --[[and PartToShift]] --and task.wait() do
				--[[local Subject = UtilitiesModule:GetPartToShift(UpdateTable[1] or ViewportCamera.CameraSubject)
				
				if Subject then 
					ViewportCamera.CFrame = (Subject.CFrame * CFrame.Angles(0, math.rad(Angle), 0)) * CFrame.new(0, 0, (Subject.Size.Z / 2) + Offset)
				end
				
				Angle += Increment or 1
			end
			
			if CustomConnection then
				UtilitiesModule:DisconnectCustomConnections({CustomConnection})
			end
			
			DebugModule:Print("RotateAroundViewport | Loop successfully broke")
		end)
		
		if not Success then
			DebugModule:Print("RotateAroundViewportPart | Error: ".. tostring(Error))
		end
	end)()]]
		
	return {Connection1}
end

local function End(CameraModule, Type)
	
end

-- DIRECT
function RotateAroundViewportPartModule.Initialise(NilParam, CameraModule, Viewport, CustomConnection, Increment, ZOffset, StartAngle, UpdateTable)
	return Initialise(CameraModule, Viewport, CustomConnection, Increment, ZOffset, StartAngle, UpdateTable)
end

function RotateAroundViewportPartModule.End(NilParam, CameraModule, Type)
	return End(CameraModule, Type)
end

return RotateAroundViewportPartModule