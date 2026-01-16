local ExplosionModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])
local FpsInfoModule = require(InfoModulesFolder["Fps"])

-- Modules
local CameraModule = require(ModulesFolder["Camera"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local MaxIntensity = 1
local ExplosionDuration = 0.75

-- Functions
-- MECHANICS
local function ShootRay(Object)
	-- CORE
	local Filter = {DumpFolder, unpack(UtilitiesModule:GetCharacters())}
	
	-- Elements
	-- PARTS
	local MainPart = nil
	
	if typeof(Object) == "Instance" then
		MainPart = UtilitiesModule:GetPartToShift(Object)
		
		table.insert(Filter, Object)
	end
	
	local PositionToRayFrom = nil
	
	if MainPart and typeof(MainPart) == "Instance" then
		PositionToRayFrom = MainPart.Position
	else
		PositionToRayFrom = Object
	end

	-- Functions
	-- INIT
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	--local FilterDescendants = Filter
	
	raycastParams.FilterDescendantsInstances = Filter --{Object, unpack(UtilitiesModule:GetCharacters()), DumpFolder --[[unpack(workspace:WaitForChild("Dump"):GetChildren())]]}

	local Direction = nil 
	
	if MainPart and typeof(MainPart) == "Instance" then
		Direction = ((MainPart.CFrame * CFrame.new(0, -5, 0)).p - MainPart.CFrame.p).Unit * FpsInfoModule:GetFpsInfo("RayLength") --600
	elseif PositionToRayFrom then
		Direction = ((PositionToRayFrom - Vector3.new(0, -5, 0)) - PositionToRayFrom).Unit * FpsInfoModule:GetFpsInfo("RayLength") --600
	end
	
	return workspace:Raycast(MainPart.CFrame.p, Direction, raycastParams)
end

local function Initialise(ObjectsModule, Object)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(Object.Name)
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	local ObjectPart = nil
	
	pcall(function()
		ObjectPart = UtilitiesModule:GetPartToShift(Object) --Object.PrimaryPart or Object
	end)
	
	local ObjectPartPosition = nil
	
	if ObjectPart then
		ObjectPartPosition = ObjectPart.Position
	else
		ObjectPartPosition = Object.Position
	end
	
	-- Functions
	-- INIT

	local RaycastResult = ShootRay(Object)

	----DebugModule:Print"Firing")
	
	if RaycastResult.Instance and RaycastResult.Instance.Name ~= "ExplosionMark" then
		local ExplosionMarkPart = ObjectsModule:GetObject("Misc", "ExplosionMark")
		ExplosionMarkPart.CFrame = CFrame.new(RaycastResult.Position, RaycastResult.Position + RaycastResult.Normal) --RaycastResult.Instance.CFrame
		--BulletHolePart.Position = RaycastResult.Position
		UtilitiesModule:WeldParts(ExplosionMarkPart, RaycastResult.Instance)

		ExplosionMarkPart.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc")
		
		DebrisModule:AddItem(ExplosionMarkPart, 10)
	end
	
	local Distance = (HumanoidRootPart.Position - --[[ObjectPart.Position]] ObjectPartPosition).Magnitude
	
	if Distance > (ObjectInfo["ExplosionRadius"] * 1.5) then
		return nil
	end
	
	local IntensityPercentage = (ObjectInfo["ExplosionRadius"] / Distance) * MaxIntensity
	
	CameraModule:CameraProcess("Shake", true, IntensityPercentage, ExplosionDuration, "Explosion")
end

-- DIRECT
function ExplosionModule.Initialise(NilParam, ObjectsModule, Object)
	return Initialise(ObjectsModule, Object)
end

return ExplosionModule