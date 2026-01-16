local FPSEffectsModule = {}

-- Dirs
local BeamsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Beams"]
local ParticlesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Particles"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- InfoModules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local EffectsInfoModule = require(InfoModulesFolder["Effects"])
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])
local FpsInfoModule = require(InfoModulesFolder["Fps"])

-- Modules
local ParticlesModule = require(ModulesFolder["Particles"])
local ObjectsModule = require(ModulesFolder["Objects"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local BulletHoleModule = require(UtilitiesModule:WaitForChildTimed(script, "BulletHole"))
local MeleeSmokeModule = require(UtilitiesModule:WaitForChildTimed(script, "MeleeSmoke"))
local SoundsModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Sounds"))
local SettingsModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Settings"))
local DebugModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Debug"))
local DebrisModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Debris"))

-- CORE
local TweenDict = {}
local GlobalSounds = {}
local RequiredModules = {}

-- Services
local TweenService = game:GetService("TweenService")
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function CreatePointPart(Position, Particle, Name)
	-- CORE
	local ActivateModule = nil
	
	-- Instancing
	if Particle then
		Particle = Particle:Clone()
		
		if Particle:FindFirstChild("Core") then
			ActivateModule = require(Particle["Core"]["Activate"])
		end
	end
	
	local Part = Particle or Instance.new("Part")
	if not Particle then
		Part.Size = Vector3.new(.1, .1, .1)
	end
	Part.Transparency = 1
	Part.CanCollide = false
	Part.CanTouch = false
	Part.CanQuery = false
	Part.Anchored = true
	Part.Parent = workspace["Dump"]["Misc"]
	
	if Position then
		Part.Position = Position
	end
	
	if Name then
		Part.Name = Name
	end
	
	return Part, ActivateModule
end

local function HandleBeam()
	-- Functions
	-- INIT
	
end

local function ClientFireEffect(EffectsHandlerModule, ViewmodelWeapon, raycastParams, WeaponName, Charge, ResultEffectInfo)
	----DebugModule:Print"Client Fire Effect | Weapon: ".. tostring(ViewmodelWeapon).. " | Params: ".. tostring(raycastParams))
	
	-- CORE
	local Nodes = {}
	local ToDisable = {}
	
	
	--DebugModule:Print(script.Name.. " | ResultEffectInfo: ")
	--DebugModule:Print(script.Name.. " | Charge:  ")
	
	--local FPSHandlerModule = UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSHandler")
		
	if raycastParams and typeof(raycastParams) == "table" and raycastParams[1] ~= nil then
		local Index = 0
		local Cancelled = false
		
		for i, raycastResult in pairs(raycastParams) do
			coroutine.wrap(function()
				local _Result = ClientFireEffect(EffectsHandlerModule, ViewmodelWeapon, raycastResult, WeaponName, Charge)
				
				if _Result then
					table.insert(Nodes, unpack(_Result))
					Index += 1
				else
					Cancelled = true
				end
			end)()
		end
		
		repeat
			task.wait()
		until Index >= #raycastParams or not ViewmodelWeapon or Cancelled
		
		return Nodes
	end
	
	if not ViewmodelWeapon or not raycastParams then
		DebugModule:Print(script.Name.. " | No ViewmodelWeapon or not raycastParams VV")
		DebugModule:Print(script.Name.. " | ViewmodelWeapon: ".. tostring(ViewmodelWeapon))
		DebugModule:Print(script.Name.. " | RaycastParams: ".. tostring(raycastParams))
		return nil
	end
	
	-- CORE
	local Distance = nil
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or ViewmodelWeapon.Name)
	local RoundTypeInfo = RoundTypesInfoModule:GetRoundTypeInfo(WeaponInfo["RoundType"])
	
	if not WeaponInfo then
		DebugModule:Print(script.Name.. " | No WeaponInfo")
		return nil
	end
	
	local Success, Returned = pcall(function()
		if not ViewmodelWeapon:IsDescendantOf(UtilitiesModule:GetCharacter(game.Players.LocalPlayer), true) then
			if table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) and not WeaponInfo["BulletLinger"] and not WeaponInfo["ShootEffectOverwrite"] and tostring(ViewmodelWeapon:GetAttributes()["Occupant"]) ~= game.Players.LocalPlayer.Name then
				local TruthTable = {true, false}
				
				return TruthTable[math.random(1, #TruthTable)]
			end	
		end
	end)
	
	if Success and Returned == false then
		return nil --> Prevent Render
	end
	
	----DebugModule:Print"1")
	
	local EffectInfo = EffectsInfoModule:GetEffectInfo(WeaponInfo["Technology"].. WeaponInfo["ProjectileType"])
	
	local tweenInfo = nil
	local Duration = EffectInfo["Duration"]
	
	-- Elements
	-- MODELS
	local GunModel = ViewmodelWeapon:FindFirstChild("Gun") or ViewmodelWeapon
	
	if not GunModel then
		DebugModule:Print(script.Name.. " | No GunModel")
		return nil
	end
	
	----DebugModule:Print"2")
	
	-- PARTS
	local BarrelPart = ViewmodelWeapon:FindFirstChild("Barrel") or GunModel:FindFirstChild("Barrel") --GunModel.PrimaryPart
	
	if not BarrelPart then
		DebugModule:Print(script.Name.. " | No BarrelPart")
		return nil
	end
	
	-- BEAMS
	local Beam = nil --BeamsFolder:FindFirstChild(WeaponInfo["Technology"].. WeaponInfo["ProjectileType"])
	local Particle = nil 
	
	local PreString = ""
	
	if Charge then
		PreString = "Charge"
	end
	
	if WeaponInfo["ShootEffectOverwrite"] then		
		Beam = BeamsFolder:FindFirstChild(PreString.. WeaponInfo["ShootEffectOverwrite"])
		Particle = ParticlesFolder:FindFirstChild(PreString.. WeaponInfo["ShootEffectOverwrite"])
	else
		Beam = BeamsFolder:FindFirstChild(PreString.. WeaponInfo["Technology"].. WeaponInfo["ProjectileType"])
		Particle = ParticlesFolder:FindFirstChild(PreString.. WeaponInfo["Technology"].. WeaponInfo["ProjectileType"])
	end	
	
	-- CORE
	
	
	-- Functions
	-- INIT
	if not GunModel or not BarrelPart then
		return nil
	end
	
	-----DebugModule:Print"3")
	
	local Point1 = CreatePointPart(BarrelPart.CFrame.p, nil, "Point1")
	local Point2 = CreatePointPart(raycastParams.Position, nil, "Point2")
	local Point3, ActivateModule = CreatePointPart(BarrelPart.CFrame.p, Particle, "Point3")
	
	if Charge then
		Point3:SetAttribute("Charge", true)
	end
	
	local PointLight = nil
	local PointLight1 = nil
	
	local BindableEvent = Instance.new("BindableEvent")
	BindableEvent.Parent = Point3
	
	local Attachment0 = Instance.new("Attachment")
	Attachment0.Parent = Point1
	
	local Attachment1 = Instance.new("Attachment")
	Attachment1.Parent = Point3
	
	local tweeningInfo = {}
	tweeningInfo.CFrame = Point2.CFrame
	
	local tweeningInfo1 = nil
	
	if Beam --[[and not Particle]] then
		Beam = Beam:Clone()
		Beam.Parent = Point3
		Beam.Attachment0 = Attachment0
		Beam.Attachment1 = Attachment1
		
		table.insert(ToDisable, Beam)
		
	end
	
	if SettingsModule:GetSettingValue("Video", "LightingSpecular", true) then
		PointLight = Instance.new("PointLight")
		PointLight1 = Instance.new("PointLight")			
			
		table.insert(ToDisable, PointLight)
		table.insert(ToDisable, PointLight1)
		
		if Beam then
			PointLight1.Color = UtilitiesModule:GetColourFromSequence(Beam.Color, 0)
			PointLight.Color = UtilitiesModule:GetColourFromSequence(Beam.Color, 0) --Color3.fromRGB(255, 255, 255)
		end
		
		if Particle then
			PointLight1.Color = RoundTypesInfoModule:GetRoundTypeInfo(WeaponInfo["RoundType"])["MarkColour"]
			PointLight.Color = RoundTypesInfoModule:GetRoundTypeInfo(WeaponInfo["RoundType"])["MarkColour"]
		end
		
		
		PointLight.Parent = Point3
		PointLight1.Parent = BarrelPart
			
		tweeningInfo1 = {}
		if Beam then
			tweeningInfo1.Color = UtilitiesModule:GetColourFromSequence(Beam.Color, 1)
		end
	end
	
	if raycastParams and raycastParams.Position and BarrelPart then
		Distance = (raycastParams.Position - BarrelPart.CFrame.p).Magnitude
	else
		Distance = FpsInfoModule:GetFpsInfo("RayLength")
	end
	
	--DebugModule:Print(script.Name.. " | ClientFireEffect | Distance: ".. tostring(Distance))
	
	if Distance and WeaponInfo then
		Duration = (math.clamp(Distance / (WeaponInfo["ProjectileSpeed"] or 300), 0, 2)) * EffectInfo["Duration"] -- CLIENT	
	end
	
	--DebugModule:Print(script.Name.. " | ClientFireEffect | Duration: ".. tostring(Duration))
	
	if Particle then
		for i, _Particle in pairs(Point3:GetDescendants()) do
			local ClassNames = {"ParticleEmitter", "Trail"}
						
			if table.find(ClassNames, _Particle.ClassName) then
				table.insert(ToDisable, _Particle)
			end
		end
		
		--table.insert(ToDisable, Particle)
		--[[if Beam then
			Beam.Enabled = true
		end
		
		for i, Trail in pairs(Point3:GetChildren()) do
			if not Trail:IsA("Trail") then
				continue
			end

			Trail.MaxLength = Distance * 2
		end]]
	end
	
	local tweenInfo = TweenInfo.new(Duration, EffectInfo["Style"], EffectInfo["Direction"])
	local Finished = false
	local TimeNow = tick()
	local BulletFlySound = nil
	
	if not RoundTypeInfo["SkipRender"] or WeaponInfo["ProjectileType"] == "Projectile" then
		UtilitiesModule:CancelTween(Point3, TweenDict)
		TweenDict[Point3] = TweenService:Create(Point3, tweenInfo, tweeningInfo)
		
		if ActivateModule then
			local Success, Error = pcall(function()
				return ActivateModule:Initialise()
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | ActivateModule |  Error: ".. tostring(Error))
			end
		end	
		
		BulletFlySound = SoundsModule:PlaySoundEffectByName("Guns", "BulletFly", nil, Point3, true)
		
		TweenDict[Point3]:Play()
		
		if WeaponInfo["BulletLinger"] then
			EffectsHandlerModule:FPSEffectProcess("BulletLinger", BarrelPart.CFrame.Position, raycastParams.Position, WeaponInfo["BulletLinger"])
		end
		
		if PointLight and tweeningInfo1 then
			UtilitiesModule:CancelTween(PointLight, TweenDict)
			TweenDict[PointLight] = TweenService:Create(PointLight, tweenInfo, tweeningInfo1)
			TweenDict[PointLight]:Play()
			UtilitiesModule:CompleteTween(PointLight, TweenDict)
			
		end
		
		UtilitiesModule:CompleteTween(Point3, TweenDict)
	--else
		--[[coroutine.wrap(function()
			task.wait(EffectInfo["Duration"])
			Finished = true
		end)()]]
	end
	
	if GunModel.Name == "Gun" and GunModel:IsDescendantOf(UtilitiesModule:GetCharacter(Player, true)) then
		SoundsModule:PlaySoundEffectById(WeaponInfo["FireSound"], nil, nil, nil, {["RollOffMaxDistance"] = 500, ["Volume"] = 0.25})
	else
		SoundsModule:PlaySoundEffectById(WeaponInfo["FireSound"], nil, BarrelPart, nil, {["RollOffMaxDistance"] = 500, ["Volume"] = 0.25})
	end
	
	coroutine.wrap(function()		
		coroutine.wrap(function()
			BindableEvent.Event:Wait()
			Finished = true
		end)()
		
		if TweenDict[Point3] ~= nil then
			coroutine.wrap(function()
				TweenDict[Point3].Completed:Wait()
				Finished = true
			end)()
		end
		
		local Difference = 0
		
		repeat
			Difference = tick() - TimeNow
			task.wait()
		until Finished or Difference >= Duration
		
		local Success, Error = pcall(function()
			if BindableEvent then
				return BindableEvent:Fire() -- End the previous thread
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | ClientFireEffect | Coroutine | Error: ".. tostring(Error))
		end
		
		--print(ResultEffectInfo)
		
		if ResultEffectInfo then			
			coroutine.wrap(function()
				for i, _ResultEffectInfo in pairs(ResultEffectInfo) do
					coroutine.wrap(function()
						if not _ResultEffectInfo["Explosions"] then
							return nil
						end
						
						local ObjectInfo = ObjectsInfoModule:GetObjectInfo(WeaponInfo["ExplosiveRounds"]["Type"])

						for i, ExplosionLocation in pairs(_ResultEffectInfo["Explosions"]) do
							ParticlesModule:ParticleEffect("Explosion", ExplosionLocation, ObjectInfo["ExplosionTrailColour"])
							ObjectsModule:ObjectProcess("Explosion", {Name = WeaponInfo["ExplosiveRounds"]["Type"], Position = ExplosionLocation})
							SoundsModule:PlaySoundEffectById(ObjectInfo["ExplosionSound"], nil, ExplosionLocation)
						end
					end)()
					
					coroutine.wrap(function()		
						if not _ResultEffectInfo["Damage"] or not _ResultEffectInfo["Damage"]["Effect"] then
							return nil
						end
						
						return FPSEffectsModule:EffectProcess(EffectsHandlerModule, _ResultEffectInfo["Damage"]["Effect"]["Name"], _ResultEffectInfo["Damage"]["Effect"]["Character"], _ResultEffectInfo["Damage"]["Effect"]["Result"])
					end)()				
				end
			end)()
		end
		
		for i, _Instance in pairs(ToDisable) do
			_Instance.Enabled = false
		end
		
		if BulletFlySound then
			BulletFlySound:Stop()
			BulletFlySound:Destroy()
		end
		
		if PointLight1 then
			DebrisModule:AddItem(PointLight1)
		end	
		
		BulletHoleModule:Initialise(EffectsHandlerModule, raycastParams, WeaponName or ViewmodelWeapon.Name)
		
		DebrisModule:AddItem(Point1, 2)
		DebrisModule:AddItem(Point2, 2)
		DebrisModule:AddItem(Point3, 2)
		--[[Point1:Destroy()
		Point2:Destroy()
		Point3:Destroy()]]
	end)()
	
	return {Point3}
end

local function ClientMeleeEffect(EffectsHandlerModule, raycastResult)
	-- Functions
	-- INIT
	--[[local Attachment = EffectsHandlerModule:LoadParticle(raycastResult.Position)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, true, nil)
	task.wait(0.3)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, false, nil)
	--DebrisService:AddItem(Attachment, 1)]]
	
	MeleeSmokeModule:Initialise(EffectsHandlerModule, raycastResult)
end

local function ClientShieldRegenEffect(EffectsHandlerModule, Toggle)
	-- Functions
	-- INIT
	if GlobalSounds["ShieldRegen"] ~= nil then
		GlobalSounds["ShieldRegen"]:Stop()
	end
	
	if Toggle then
		GlobalSounds["ShieldRegen"] = SoundsModule:PlaySoundEffectByName("Hud", "ShieldRegen")
	end
end

local function EffectProcess(EffectsHandlerModule, Name, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	--[[local Success, Error = pcall(function()
		local RequiredModule = require(UtilitiesModule:WaitForChildTimed(script, Name))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(EffectsHandlerModule, unpack(Args))
		end
	end)
	
	if not Success then
		--DebugModule:PrintError, "Error")
	else
		return Error
	end]]

	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[Name]

		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(EffectsHandlerModule, unpack(Args))
		end
	end)
	
	
	if not Success then
		DebugModule:Print("FPSEffects | EffectProcess | Error: ".. tostring(Error))
	else
		return Error
	end
end

local function End()
	-- Functions
	-- INIT
	for ModuleName, RequiredModule in pairs(RequiredModules) do
		if RequiredModule.End ~= nil then
			coroutine.wrap(function()
				local Success, Error = pcall(function()			
					return RequiredModule:End()
				end)
				
				if not Success then
					DebugModule:Print("FPSEffects | End | Error: ".. tostring(Error))
				end
			end)()
		end
	end
	
	--[[for i, Module in pairs(script:GetChildren()) do
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				local RequiredModule = require(Module)
				
				if RequiredModule.End ~= nil then
					return RequiredModule:End()
				end
			end)
			
			if not Success then
				--DebugModule:PrintError, "Error")
			else
				return Error
			end
		end)()
	end]]
end

-- DIRECT
function FPSEffectsModule.End()
	return End()
end

function FPSEffectsModule.EffectProcess(NilParam, EffectsHandlerModule, Name, ...)
	return EffectProcess(EffectsHandlerModule, Name, ...)
end

function FPSEffectsModule.ClientShieldRegenEffect(NilParam, EffectsHandlerModule, Toggle)
	return ClientShieldRegenEffect(EffectsHandlerModule, Toggle)
end

function FPSEffectsModule.ClientMeleeEffect(NilParam, EffectsHandlerModule, raycastResult)
	return ClientMeleeEffect(EffectsHandlerModule, raycastResult)
end

function FPSEffectsModule.ClientFireEffect(NilParam, ...)
	return ClientFireEffect(...)
end

function FPSEffectsModule.ClientRequest(NilParam, ...)
	return FPSEffectsModule:EffectProcess(...)
end

-- INIT
RunSubModules()

return FPSEffectsModule