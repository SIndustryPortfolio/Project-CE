local GunClientModule = {}

-- Dirs
local ModelRoot = script.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- CLIENT
local Player = game.Players.LocalPlayer

-- INFO MODULES
local GunAnimations = require(script.Parent["Animations"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])

-- Modules
local SettingsModule = require(ModulesFolder["Settings"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(ModelRoot.Name)
local AnimationToLoad = {}
local ElementCache = {}
local Connections = {}
local AnimationInstances = {}

local GunSpecificModule = nil

local Equipped = false

local Character = nil

-- Elements
-- Animations
--local AnimationController = UtilitiesModule:WaitForChildOfClass(ModelRoot, "AnimationController")
--local Animator = UtilitiesModule:WaitForChildOfClass(AnimationController, "Animator")
local Humanoid = nil

-- Folders
local SurfacesFolder = ModelRoot:FindFirstChild("Surfaces") --UtilitiesModule:WaitForChildTimed(ModelRoot, "Surfaces")

-- Parts
local AmmoCounterPart = nil 

if SurfacesFolder then
	AmmoCounterPart = SurfacesFolder:FindFirstChild("AmmoCounter") --UtilitiesModule:WaitForChildTimed(SurfacesFolder, "AmmoCounter")
end

local BarrelPart = ModelRoot:FindFirstChild("Barrel") --ModelRoot.PrimaryPart

if not BarrelPart then
	return nil
end


-- ATTACHMENTS
local EffectsAttachment = BarrelPart:FindFirstChildOfClass("Attachment") --UtilitiesModule:WaitForChildOfClass(BarrelPart, "Attachment")

-- PARTICLE EMITTERS
local MuzzleFlashParticleEmitter = nil

if EffectsAttachment then
	MuzzleFlashParticleEmitter = EffectsAttachment:FindFirstChild("MuzzleFlash")
end

-- Attachments
local Attachment = UtilitiesModule:WaitForChildOfClass(BarrelPart, "Attachment")

-- Surfaces
local AmmoCounterUi = nil --UtilitiesModule:WaitForChildOfClass(AmmoCounterPart, "SurfaceGui")

if AmmoCounterPart then
	AmmoCounterUi = AmmoCounterPart:FindFirstChildOfClass("SurfaceGui")
end

-- TEXTS
local AmmoText = nil --UtilitiesModule:WaitForChildTimed(AmmoCounterUi, "Ammo")

if AmmoCounterUi then
	AmmoText = AmmoCounterUi:FindFirstChild("Ammo")
end

-- Functions
-- MECHANICS
local function ToggleMuzzleFlash(ToggleValue)	
	-- Functions
	-- INIT
	if not EffectsAttachment then
		EffectsAttachment = BarrelPart:FindFirstChildOfClass("Attachment")
		
		if not EffectsAttachment then
			return nil
		end
	end
	
	for i, Effect in pairs(EffectsAttachment:GetChildren()) do
		Effect.Enabled = ToggleValue
	end
end

local function UpdateSurfaceUi()
	-- Functions
	-- INIT
	if not AmmoText then
		return nil
	end
	
	local _AmmoText = ModelRoot:GetAttribute("RoundsInMag") or 0

	if string.len(_AmmoText) < 2 then
		_AmmoText = "0".. tostring(_AmmoText)
	end
	
	AmmoText.Text = _AmmoText
end

local function Setup()
	-- Functions
	-- INIT
	Character = ModelRoot.Parent
	Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
end

local function InitialiseAnimations(ForceAnimator)
	-- Functions
	-- INIT
	if not Humanoid and not ForceAnimator then
		return nil
	end
	
	if UtilitiesModule:GetSizeOfDict(AnimationToLoad) > 0 then
		return nil
	end
	
	--DebugModule:Print("Server Gun Client |  ".. tostring(ModelRoot).. "Force Animator: ".. tostring(ForceAnimator))
	--DebugModule:Print("Server Gun Client | GunAnimations V ")
	--print(GunAnimations)
	--DebugModule:Print("Server Gun Client | AnimationInstances V ")
	--print(AnimationInstances)
	--DebugModule:Print("Server Gun Client | Humanoid: ".. tostring(Humanoid))
	
	local ResetPlayer = Humanoid or ForceAnimator
	
	
	if not ForceAnimator then
		UtilitiesModule:LoadAnimations(GunAnimations, AnimationInstances, AnimationToLoad, Humanoid, true, {["WeaponName"] = ModelRoot.Name, ["Server"] = true})
	else
		UtilitiesModule:LoadAnimations(GunAnimations, AnimationInstances, AnimationToLoad, ForceAnimator, true, {["WeaponName"] = ModelRoot.Name, ["Server"] = true})
	end
	
	pcall(function()
		if WeaponInfo and WeaponInfo["AnimationSpeeds"] then
			for AnimationName, AnimationSpeed in pairs(WeaponInfo["AnimationSpeeds"]) do
				AnimationToLoad[AnimationName]:AdjustSpeed(AnimationSpeed)
			end
		end
	end)
	
	--[[for InstanceName, AnimationInfo in pairs(GunAnimations) do
		-- Instancing		
		coroutine.wrap(function()
			local Success, Error = false, nil

			local Animation = Instance.new("Animation")
			Animation.AnimationId = AnimationInfo.Id
			
			table.insert(AnimationInstances, Animation)
			
			repeat
				Success, Error = pcall(function()
					AnimationToLoad[InstanceName] = Humanoid:LoadAnimation(Animation)
				end)

				task.wait()	
			until Success
		end)()
	end]]
end

local function StopAnimation(AnimationName)
	-- Functions
	-- INIT
	if GunAnimations[AnimationName] and not AnimationToLoad[AnimationName] then
		repeat
			task.wait()
		until AnimationToLoad[AnimationName]
	end
	
	if not GunAnimations[AnimationName] then
		return nil
	end
	
	AnimationToLoad[AnimationName]:Stop()
end

local function PlayAnimation(AnimationName, WaitTillFinished, FreezeFrameName, Speed)
	-- Functions
	-- INIT
	if GunAnimations[AnimationName] and not AnimationToLoad[AnimationName] then
		repeat
			task.wait()
		until AnimationToLoad[AnimationName]
	end
	
	if not GunAnimations[AnimationName] then
		return nil
	end
	
	if FreezeFrameName then
		--[[local Marker = nil
		
		for i, _Marker in pairs(AnimationToLoad[AnimationName]:GetMarkers()) do
			if _Marker.Name == FreezeFrameName then
				Marker = _Marker
			end
		end]]
		
		--[[if not Success then
			print("Animation Name: ".. tostring(AnimationName).. "\nKeyframe Name: ".. tostring(FreezeFrameName))
			
			print("Error: ".. tostring(Error))
		end]]
			
		local Connection1 = nil
		
		Connection1 = AnimationToLoad[AnimationName]:GetMarkerReachedSignal(FreezeFrameName):Connect(function()
			-- Functions
			-- INIT
			AnimationToLoad[AnimationName]:AdjustSpeed(0)
			
			if not AnimationToLoad[AnimationName].IsPlaying then
				AnimationToLoad[AnimationName]:Play()
			end
			
			--AnimationToLoad[AnimationName].TimePosition = (AnimationToLoad[AnimationName].Length * Marker.Value)
			Connection1:Disconnect()
		end)
		
		-- Connections
		table.insert(Connections, Connection1)
	end	
	
	AnimationToLoad[AnimationName]:Play()
	
	if Speed then
		AnimationToLoad[AnimationName]:AdjustSpeed(Speed)
	end
	
	if WaitTillFinished then
		AnimationToLoad[AnimationName].Stopped:Wait()
	end
end

local function StopAllAnimations()
	-- Functions
	-- INIT
	for AnimationName, LoadedInstance in pairs(AnimationToLoad) do
		if LoadedInstance.IsPlaying then
			LoadedInstance:Stop()
		end
	end
end

local function DestroyAllAnimations()
	-- Functions
	-- INIT
	for i, AnimationInstance in pairs(AnimationInstances) do
		AnimationInstance:Destroy()
	end
	
	AnimationInstances = {}
end

local function EndSpecificModule()
	-- Functions
	-- INIT
	if not GunSpecificModule then
		return nil
	end
	
	return GunSpecificModule:End()
end

local function InitialiseSpecificModule()
	-- Functions
	-- INIT
	local FoundSpecificModule = script:FindFirstChild(ModelRoot.Name)
	
	if not FoundSpecificModule then
		return nil
	end
	
	GunSpecificModule = require(FoundSpecificModule)
	
	if GunSpecificModule and GunSpecificModule.Initialise ~= nil then
		return GunSpecificModule:Initialise(GunClientModule, ModelRoot)
	end
end

-- INIT
function GunClientModule.Initialise(NilParam, ForceAnimator)
	-- Functions
	-- INIT
	if not ForceAnimator then
		Setup()
	end
	
	InitialiseAnimations(ForceAnimator)
	InitialiseSpecificModule()
	--
	--[[if AnimationToLoad["Reload"] and table.find({1, nil}, WeaponInfo["ReloadSpeed"]) == nil then
		local Success, Erorr = pcall(function()
			AnimationToLoad["Reload"]:AdjustSpeed(WeaponInfo["ReloadSpeed"])
		end)
		
		if not Success then
		
		DebugModule:Print("Server".. script.Name.. " | Init")
		end
	else
		DebugModule:Print("ServerGunClient | Cannot find Reload animation in table!")
	end]]
end

function GunClientModule.StopFiring()
	-- Functions
	-- INIT
	ToggleMuzzleFlash(false)
end

function GunClientModule.Fire(NilParam, ThirdPerson)
	-- Functions
	-- INIT
	if SettingsModule:GetSettingValue("Video", "BulletSpecular", true) and ThirdPerson then
		ToggleMuzzleFlash(true)

		coroutine.wrap(function()
			if WeaponInfo["Type"] ~= "Automatic" then
				--task.wait(--[[.1]] 1 / WeaponInfo["FireRate"])
				task.wait(MuzzleFlashParticleEmitter.Lifetime.Min)
				ToggleMuzzleFlash(false)
			end
		end)()
	end
	
	PlayAnimation("Fire", false)
end

function GunClientModule.CancelReload(NilParam)
	-- Functions
	-- INIT
	StopAnimation("Reload")
end

function GunClientModule.Reload(NilParam, Speed)
	-- Functions
	-- INIT
	PlayAnimation("Reload", true, nil, Speed)
end

function GunClientModule.Melee(NilParam, Speed)
	-- Functions
	-- INIT
	StopAnimation("Reload")
	PlayAnimation("Melee", true, nil, Speed)
end

function GunClientModule.Unequip()
	-- Functions
	-- INIT
	Equipped = false
	--PlayAnimation("Unequip", true)
	
	coroutine.wrap(function()
		PlayAnimation("Unequip", true)
		
		if not Equipped then
			StopAllAnimations()
		end
	end)()
end

function GunClientModule.GetAnimationToLoad()
	return AnimationToLoad
end

function GunClientModule.Equip(NilParam, WaitTillFinished)
	Equipped = true
	
	-- CORE
	local Finished = false
	
	-- Functions
	-- DIRECT
	local Connection1 = nil 
	
	if WeaponInfo["RoundType"] and table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
		Connection1 = ModelRoot:GetAttributeChangedSignal("RoundsInMag"):Connect(function()
			return UpdateSurfaceUi()
		end)
	end
	
	-- Connections
	table.insert(Connections, Connection1)
	
	-- INIT	
 	UpdateSurfaceUi()
	
	for i, AnimationTrack in pairs(Humanoid:GetPlayingAnimationTracks()) do
		DebugModule:Print("Server Gun Client | Animation in Humanoid: ".. tostring(AnimationTrack.Name))

		if AnimationTrack and AnimationTrack:GetAttributes()["WeaponName"] then
			if AnimationTrack:GetAttributes()["WeaponName"] ~= ModelRoot.Name then
				AnimationTrack:Stop()
			end
		end

		--[[if GunAnimations[AnimationTrack.Name] ~= nil then
			AnimationTrack:Stop()
			AnimationTrack:Destroy()
		end]]
	end
	
	coroutine.wrap(function()
		PlayAnimation("Equip", true --[[, "Equipped"]])
		
		if Equipped then
			PlayAnimation("Idle")
		end
		
		Finished = true
	end)()
	
	if WaitTillFinished then
		repeat
			task.wait(0.05)
		until Finished
	end
end

function GunClientModule.End()
	-- Functions
	-- INIT
	Equipped = false
	StopAllAnimations()
	DestroyAllAnimations()
	EndSpecificModule()
	--AnimationToLoad = nil
	--UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireServer("RemoveCache")
	UtilitiesModule:DisconnectConnections(Connections)
	--Connections = nil
end

return GunClientModule