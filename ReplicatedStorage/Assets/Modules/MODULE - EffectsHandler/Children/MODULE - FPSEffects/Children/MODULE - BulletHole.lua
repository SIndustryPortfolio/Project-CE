local BulletHoleModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local SoundsInfoModule = require(SharedInfoModulesFolder["Sounds"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SettingsModule = require(SharedModulesFolder["Settings"])
--local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function IsLivingThing(_Instance)
	-- Functions
	-- INIT
	local ModelRoot = _Instance:FindFirstAncestorOfClass("Model")
	
	if not ModelRoot then
		return nil
	end
	
	local Humanoid = ModelRoot:FindFirstChildOfClass("Humanoid")
	
	pcall(function()
		if not Humanoid then
			ModelRoot = _Instance:FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model")
			
			Humanoid = ModelRoot:FindFirstChildOfClass("Humanoid")
			
			if not Humanoid then
				ModelRoot = _Instance:FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model")
				
				Humanoid = ModelRoot:FindFirstChildOfClass("Humanoid")
			end
		end
	end)
	
	if Humanoid then
		return true
	end
end

local function HandleBulletHole(EffectsHandlerModule, RaycastResult, WeaponName)
	-- Functions
	-- INIT
	----DebugModule:Print"Firing")
	
	--[[--DebugModule:Print"Effects Handler Module")
	--DebugModule:PrintEffectsHandlerModule)
	--DebugModule:Print"Ray Cast Result")
	--DebugModule:PrintRaycastResult)]]
	
	if not RaycastResult.Instance or not RaycastResult.Position then
		return nil
	end
	
	if IsLivingThing(RaycastResult.Instance) then
		return nil
	end
	
	----DebugModule:Print"Firing")
	
	local BulletHolePart, ActivateModule = ObjectsModule:GetObject("Misc", "BulletHole")
	
	if not RaycastResult.Position then
		BulletHolePart:Destroy()
		return nil
	end
	
	BulletHolePart.CFrame = CFrame.new(RaycastResult.Position, RaycastResult.Position + (RaycastResult.Normal or Vector3.new(0, 0, 0))) --RaycastResult.Instance.CFrame
	--BulletHolePart.Position = RaycastResult.Position
	BulletHolePart.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc") --UtilitiesModule:WaitForChildTimed(workspace, "Dump")
	
	if ActivateModule then
		ActivateModule = require(ActivateModule)
	end
	
	local SparkObject, SparkActivateModule = nil, nil
	local SmokeObject = nil
	
	if SettingsModule:GetSettingValue("Video", "BulletSpecular", true) then
		SparkObject, SparkActivateModule = EffectsHandlerModule:LoadParticleEmitter(BulletHolePart, "Sparks")
		SmokeObject = EffectsHandlerModule:LoadParticleEmitter(BulletHolePart, "SmokeDustExplosion")
		
		if SparkActivateModule then
			SparkActivateModule = require(SparkActivateModule)
		end
		
		if WeaponName then
			--DebugModule:Print(script.Name.. " | Starting activate module | MarkColour: ".. tostring(RoundTypesInfoModule:GetRoundTypeInfo(WeaponsInfoModule:GetWeaponInfo(WeaponName)["RoundType"])["MarkColour"]))
			ActivateModule:Initialise(RoundTypesInfoModule:GetRoundTypeInfo(WeaponsInfoModule:GetWeaponInfo(WeaponName)["RoundType"])["MarkColour"])
			SparkActivateModule:Initialise(RoundTypesInfoModule:GetRoundTypeInfo(WeaponsInfoModule:GetWeaponInfo(WeaponName)["RoundType"])["MarkColour"])
		end
		
		EffectsHandlerModule:ToggleParticleEmitters(SparkObject, true, nil)
		coroutine.wrap(function()
			EffectsHandlerModule:ToggleParticleEmitters(SmokeObject, true, nil)
			task.wait(0.4)
			EffectsHandlerModule:ToggleParticleEmitters(SparkObject, false, nil)
			EffectsHandlerModule:ToggleParticleEmitters(SmokeObject, false, nil)

			--DebrisService:AddItem(SparkObject, 3)
			DebrisModule:AddItem(SparkObject, 3)
			DebrisModule:AddItem(SmokeObject, 3)
		end)()
	end
	
	UtilitiesModule:WeldParts(BulletHolePart, RaycastResult.Instance)
	
	if SparkObject then
		UtilitiesModule:WeldParts(SparkObject, BulletHolePart)
	end
	
	local Success, Error = pcall(function()
		local IsMaterialSound = SoundsInfoModule:GetSounds("Effects")["BulletImpacts"][RaycastResult.Instance.Material.Name]
		
		if IsMaterialSound then
			SoundsModule:PlaySoundEffectByName("BulletImpacts", RaycastResult.Instance.Material.Name, nil, BulletHolePart, nil, {["Volume"] = .1})
		else
			--local RandomAppend = {"", "1", "2", "3"}
			
			SoundsModule:PlaySoundEffectByName("BulletImpacts", "Default" --[[.. RandomAppend[math.random(1, #RandomAppend)]], nil, BulletHolePart, nil, {["Volume"] = .1})
		end
	end)
	
	if not Success then
		DebugModule:Print("Error: ".. tostring(Error))
	end
	
	--DebrisService:AddItem(BulletHolePart, 5)
	DebrisModule:AddItem(BulletHolePart, 5)
end

-- DIRECT
function BulletHoleModule.Initialise(NilParam, EffectsHandlerModule, RaycastResult, WeaponName)
	return HandleBulletHole(EffectsHandlerModule, RaycastResult, WeaponName)
end

return BulletHoleModule