local HealthDamageModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Info Modules
local FpsInfoModule = require(SharedInfoModulesFolder["Fps"])

-- Modules
local MapsModule = require(SharedModulesFolder["Maps"])
local ObjectEffectsModule = require(SharedModulesFolder["ObjectEffects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SettingsModule = require(SharedModulesFolder["Settings"])
--local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function ShootRay(Character)
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart
	
	-- Functions
	-- INIT
	if not HumanoidRootPart then
		return nil
	end
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	local FilterDescendants = {Character, DumpFolder, workspace["Temporary"], unpack(UtilitiesModule:CombineTables(UtilitiesModule:GetCharacters(), MapsModule:GetMapRaycastBlacklistFolders()))}
	
	raycastParams.FilterDescendantsInstances = FilterDescendants --{Character, unpack(UtilitiesModule:GetCharacters()), DumpFolder --[[unpack(workspace:WaitForChild("Dump"):GetChildren())]]}
	
	local Direction = ((HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)).p - HumanoidRootPart.CFrame.p).Unit * FpsInfoModule:GetFpsInfo("RayLength") --600
	
	return workspace:Raycast(HumanoidRootPart.CFrame.p, Direction, raycastParams)
end

local function HandleDamage(EffectsHandlerModule, Character, LeakRayCastResult)
	-- CORE
	local DamageGroans = {"HealthDamage", "HealthDamage2", "HealthDamage3"}
	--local LeakPosition = nil
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- Functions
	-- INIT
	--[[if LeakRayCastResult and LeakRayCastResult.Position then
		LeakPosition = LeakRayCastResult.Position + LeakRayCastResult.Normal
	else
		LeakPosition = HumanoidRootPart.Position
	end]]
	
	----DebugModule:Print"Firing")
	
	--[[--DebugModule:Print"Effects Handler Module")
	--DebugModule:PrintEffectsHandlerModule)
	--DebugModule:Print"Ray Cast Result")
	--DebugModule:PrintRaycastResult)]]
	
	local RaycastResult = ShootRay(Character)
	
	if not RaycastResult then
		return nil
	end
	
	if not RaycastResult.Instance then
		return nil
	elseif RaycastResult.Instance.Name == "BloodSplat" then
		return nil
	end
	
	----DebugModule:Print"Firing")
		
	if SettingsModule:GetSettingValue("Video", "Blood", true) then
		local BloodPart = ObjectsModule:GetObject("Misc", "BloodSplat")
		BloodPart.CFrame = CFrame.new(RaycastResult.Position, RaycastResult.Position + RaycastResult.Normal) --RaycastResult.Instance.CFrame
		--BulletHolePart.Position = RaycastResult.Position
		UtilitiesModule:WeldParts(BloodPart, RaycastResult.Instance)
		BloodPart.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc") --UtilitiesModule:WaitForChildTimed(workspace, "Dump")
		--[[if SettingsModule:GetSettingValue("Video", "RenderQuality") == "ULTRA HIGH" then
			ObjectEffectsModule:ExpandObject(BloodPart)
		end]]
		
		SoundsModule:PlaySoundEffectByName("CharacterActions", "BloodSplat", nil, BloodPart, nil)
		DebrisModule:AddItem(BloodPart, 5)
	end
	
	--[[local SparkObject = EffectsHandlerModule:LoadParticleEmitter(BulletHolePart, "Sparks")
	
	coroutine.wrap(function()
		EffectsHandlerModule:ToggleParticleEmitters(SparkObject, true, nil)
		task.wait(0.15)
		EffectsHandlerModule:ToggleParticleEmitters(SparkObject, false, nil)
		
		--DebrisService:AddItem(SparkObject, 3)
	end)()]]
	
	
	--UtilitiesModule:WeldParts(SparkObject, BulletHolePart)
	
	
	SoundsModule:PlaySoundEffectByName("CharacterActions", DamageGroans[math.random(1, #DamageGroans)], nil, HumanoidRootPart)
	
	--DebrisService:AddItem(BloodPart, 5)
end

-- DIRECT
function HealthDamageModule.Initialise(NilParam, EffectsHandlerModule, Character)
	return HandleDamage(EffectsHandlerModule, Character)
end

return HealthDamageModule