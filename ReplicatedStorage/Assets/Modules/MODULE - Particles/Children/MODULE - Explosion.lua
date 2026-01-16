local ParticleModule = {}

-- Dirs
local DumpFolder = workspace:WaitForChild("Dump")
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])
local SettingsModule = require(ModulesFolder["Settings"])
local DebugModule = require(ModulesFolder["Debug"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function CreateTrailInstance(TrailColour)
	-- Functions
	-- INSTANCING
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(1, 1, 1)
	Part.Transparency = 1
	Part.Name = "TrailPart"
	Part.CanCollide = false
	Part.Anchored = false
	
	local Attachment0 = Instance.new("Attachment")
	Attachment0.CFrame = CFrame.new(0, Part.Size.Y / 2, 0)
	Attachment0.Parent = Part
	
	local Attachment1 = Instance.new("Attachment")
	Attachment1.CFrame = CFrame.new(0, -Part.Size.Y / 2, 0)
	Attachment1.Parent = Part
	
	local Trail = Instance.new("Trail")
	Trail.Attachment0 = Attachment0
	Trail.Attachment1 = Attachment1
	Trail.Color = TrailColour
	Trail.Lifetime = 0.5
	Trail.Texture = "rbxassetid://580455093"
	Trail.Parent = Part
	
	return Part
end

local function ExplosionPhase(ReferencePart, TrailReferencePart, DampenMultiplier, IgnoreLight)
	-- CORE
	local TrailClone = TrailReferencePart:Clone()
	local ExplosionConnections = {}
	
	local YForce = math.random(35 * 100, 50 * 100) / 100
	local XForce = math.random(-(15 * 100), 15 * 100) / 100
	local ZForce = math.random(-(15 * 100), 15 * 100) / 100
	
	-- Elements
	-- TRAILS
	local Trail = TrailClone:FindFirstChildOfClass("Trail")
	local PointLight = nil
	-- Functions
	-- INIT
	
	if SettingsModule:GetSettingValue("Video", "LightingSpecular", true) and not IgnoreLight then
		PointLight = Instance.new("PointLight")
		PointLight.Color = UtilitiesModule:GetColourFromSequence(Trail.Color, 0)
		PointLight.Parent = TrailClone
	end
	
	if DampenMultiplier then
		YForce *= DampenMultiplier
		XForce *= DampenMultiplier
		ZForce *= DampenMultiplier
	end
	
	if not ReferencePart then
		DebugModule:Print(script.Name.. " | ExplosionPhase | ReferencePart: ".. tostring(ReferencePart)..  " | TrailReferencePart: ".. tostring(TrailReferencePart).. " | DampenMultiplier: ".. tostring(DampenMultiplier).. " | IgnoreLight: ".. tostring(IgnoreLight).. " | Error: No reference part")
		return nil
	end
	
	TrailClone.CFrame = ReferencePart.CFrame
	TrailClone.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc") --UtilitiesModule:WaitForChildTimed(workspace, "Dump")
	TrailClone.Velocity = Vector3.new(XForce, YForce, ZForce)
	
	if PointLight then
		local StartTime = tick() 
		
		local Connection1 = TrailClone:GetPropertyChangedSignal("Position"):Connect(function()
			local TimePosition = math.clamp(tick() - StartTime, 0, 1)
			PointLight.Color = UtilitiesModule:GetColourFromSequence(Trail.Color, TimePosition)
		end)
		
		-- Connections
		table.insert(ExplosionConnections, Connection1)
		
		--[[coroutine.wrap(function()
			local TimePosition = 0
			
			while task.wait(.05) and TrailClone and PointLight do
				TimePosition = math.clamp(TimePosition + 0.05, 0, 1)
				PointLight.Color = UtilitiesModule:GetColourFromSequence(Trail.Color, TimePosition)
			end
		end)()]]
	end
	
	--DebrisService:AddItem(TrailClone, 5)
	DebrisModule:AddItem(TrailClone, 5, nil, ExplosionConnections)
end

local function Initialise(ReferencePart, TrailColour, DampenMultiplier, IgnoreLight)
	-- CORE
	local TrailReferencePart = CreateTrailInstance(TrailColour)
	local ExplosionTrails = math.random(2, 5)
	
	-- Functions
	-- INIT
	if typeof(ReferencePart) == "Vector3" then
		local Position = ReferencePart
		
		ReferencePart = Instance.new("Part")
		ReferencePart.Position = Position
		ReferencePart.Size = Vector3.new(1, 1, 1)
		ReferencePart.CanCollide = false
		ReferencePart.Anchored = true
		ReferencePart.Transparency = 1
		ReferencePart.Name = "Reference"
		ReferencePart.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc")
	end
	
	if SettingsModule:GetSettingValue("Video", "ExplosionSpecular", true) then
		for i = 1, ExplosionTrails do
			ExplosionPhase(ReferencePart, TrailReferencePart, DampenMultiplier, IgnoreLight)
		end
	end
	
	TrailReferencePart:Destroy()
end

-- DIRECT
function ParticleModule.Initialise(NilParam, ReferencePart, TrailColour, DampenMultiplier, IgnoreLight)
	return Initialise(ReferencePart, TrailColour, DampenMultiplier, IgnoreLight)
end

return ParticleModule