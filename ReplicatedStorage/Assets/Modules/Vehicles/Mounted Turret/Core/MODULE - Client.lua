local VehicleModule = {}

-- Dirs
local ModelRoot = script.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local VehiclesInfoModule = require(InfoModulesFolder["Vehicles"])
local FpsInfoModule = require(InfoModulesFolder["Fps"])

-- Modules
local CameraModule = require(ModulesFolder["Camera"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local CoreAnimationsModule = require(script.Parent["CoreAnimations"])
local DebugModule = require(ModulesFolder["Debug"])
local CharacterFPSHandlerModule = require(UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSHandler"))
local InterfacesModule = require(ModulesFolder["Interfaces"])
local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local FpsEffectsModule = require(ModulesFolder["EffectsHandler"]["FPSEffects"])

-- Elements
-- FOLDERS
local RemotesFolder = UtilitiesModule:WaitForChildTimed(ModelRoot, "Remotes")
local ClientServerRemotesFolder = RemotesFolder["ClientServer"]["Remotes"]
local ClientServerSignalsFolder = RemotesFolder["ClientServer"]["Signals"]

-- SIGNALS
local VehicleRequestSignal = ClientServerSignalsFolder["VehicleRequest"]

-- REMOTES
local MouseCameraEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "MouseCamera")
local ProcessCommunicationsEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "ProcessCommunications")
local VehicleProcessRemote = ClientServerRemotesFolder["VehicleProcess"]

-- MODELS
local GunModel = UtilitiesModule:WaitForChildTimed(ModelRoot, "Gun")
local StandModel = UtilitiesModule:WaitForChildTimed(ModelRoot, "Stand")

-- PARTS
local BasePart = GunModel["Base"]
local BarrelPart = ModelRoot["Barrel"]
local CharacterPlaceholderPart = UtilitiesModule:WaitForChildTimed(ModelRoot, "CharacterPlaceholder")

-- WELDS
local RootWeld = BasePart["Root"]

-- CORE
local Initialised = false
local LastTilt = tick()
local LastSpinUpTime = nil
local OriginalC0 = RootWeld.C0
local OriginalC1 = RootWeld.C1
local OriginalCharacterPlaceholderPosition = CharacterPlaceholderPart.Position

local VehicleInfo = VehiclesInfoModule:GetVehicleInfo(ModelRoot.Name)
local AnimationToLoad = {}
local AnimationInstances = {}

local GlobalTurretXAngle = 0
local GlobalTurretYAngle = 0

local Connections = {}
local FireCustomConnections = {}
local Character = nil
local HumanoidRootPart = nil
local Humanoid = nil

-- Services
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function Render()
	-- Functions
	-- INIT
	if LastTilt then
		if (tick() - LastTilt) >= FpsInfoModule:GetFpsInfo("TiltUpdateDelay") or not LastTilt then
			VehicleProcessRemote:FireServer("UpdateTilt", {["C0"] = RootWeld.C0, ["C1"] = RootWeld.C1})
			LastTilt = tick()
		end	
	end
	
	RootWeld.C0 = RootWeld.C0:Lerp(OriginalC0 * CFrame.Angles(0, math.rad(GlobalTurretXAngle), 0) * CFrame.Angles(0, 0, math.rad(GlobalTurretYAngle)), FpsInfoModule:GetFpsInfo("LerpIntensity"))
	--HumanoidRootPart.CFrame = CFrame.new(Vector3.new(CharacterPlaceholderPart.Position.X, HumanoidRootPart.Position.Y, CharacterPlaceholderPart.Position.Z), Vector3.new(CharacterPlaceholderPart.CFrame.lookVector.X, HumanoidRootPart.CFrame.lookVector.Y, CharacterPlaceholderPart.CFrame.lookVector.Z))
	--HumanoidRootPart.CFrame = CharacterPlaceholderPart.CFrame	
	HumanoidRootPart.CFrame = CFrame.new(Vector3.new(CharacterPlaceholderPart.CFrame.X, OriginalCharacterPlaceholderPosition.Y, CharacterPlaceholderPart.CFrame.Z), Vector3.new(BasePart.CFrame.lookVector.X * 10000, HumanoidRootPart.CFrame.lookVector.Y, BasePart.CFrame.lookVector.Z * 10000))
	CharacterFPSHandlerModule:SetGlobalXCameraAngle(GlobalTurretXAngle)
	CharacterFPSHandlerModule:SetGlobalYCameraAngle(GlobalTurretYAngle)
end

local function PlayAnimation(AnimationName, WaitTillFinished)
	-- Functions
	-- INIT
	if not AnimationToLoad[AnimationName] then
		DebugModule:Print(ModelRoot.Name.. " | ".. script.Name.. " | Can't find animation to play: ".. tostring(AnimationName))
		return nil
	end
	
	AnimationToLoad[AnimationName]:Play()
	
	if WaitTillFinished then
		AnimationToLoad[AnimationName].Stopped:Wait()
	end
end

local function StopAllAnimations()
	-- Functions
	-- INIT
	for AnimationName, LoadedInstance in pairs(AnimationToLoad) do
		LoadedInstance:Stop()
	end
end

local function InitialiseAnimations()
	-- Functions
	-- INIT	
	if UtilitiesModule:GetSizeOfDict(AnimationToLoad) > 0 then
		return nil
	end

	UtilitiesModule:LoadAnimations(CoreAnimationsModule, AnimationInstances, AnimationToLoad, Humanoid, true)
end

local function onMouseMoved(Vector2Delta)
	-- Functions
	-- INIT
	local XBounds = VehicleInfo["Bounds"]["X"]
	local YBounds = VehicleInfo["Bounds"]["Y"] 
	
	GlobalTurretXAngle = math.clamp((GlobalTurretXAngle + Vector2Delta.X * FpsInfoModule:GetFpsInfo("AdsSensitivityMultiplier")), XBounds[1],XBounds[2])
	GlobalTurretYAngle = math.clamp((GlobalTurretYAngle + Vector2Delta.Y * FpsInfoModule:GetFpsInfo("AdsSensitivityMultiplier")), YBounds[1], YBounds[2])
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = MouseCameraEvent.Event:Connect(onMouseMoved)
	
	-- Connections
	table.insert(Connections, Connection1)
	
	-- INIT
	DebugModule:Print("Mounted Turret | Starting Initialise: ".. tick())
	
	Character = UtilitiesModule:GetCharacter(Player, true)
	Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	HumanoidRootPart = UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	--CharacterFPSHandlerModule:End()
	InitialiseAnimations()
	
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule then
		HudGuiModule:HudProcess("Cursor", "SetCursor", VehicleInfo["GunInfo"]["CursorIcon"], VehicleInfo["GunInfo"]["CursorSize"], false)
	end
	
	CharacterFPSHandlerModule:SetGlobalXCameraAngle(0)
	CharacterFPSHandlerModule:SetGlobalYCameraAngle(0)
	CharacterFPSHandlerModule:ForceDrawCamera()
	Render()
	HumanoidRootPart.Anchored = true
	PlayAnimation("Equip", true)
	PlayAnimation("Idle")
	HumanoidRootPart.Anchored = false
	
	RunService:BindToRenderStep(ModelRoot.Name.. "Render", Enum.RenderPriority.First.Value, Render)
	Initialised = true
	DebugModule:Print("Mounted Turret | Finished Initialise: ".. tick())
end

local function End()
	-- Functions
	-- INIT
	Initialised = false
	if CharacterFPSHandlerModule then
		CharacterFPSHandlerModule:UnForceDrawCamera()
	end
	
	RunService:UnbindFromRenderStep(ModelRoot.Name.. "Render")
	UtilitiesModule:DisconnectConnections(Connections)
	UtilitiesModule:DisconnectCustomConnections(FireCustomConnections)
	StopAllAnimations()
end

local function HandleFireResponse(Response)
	-- Functions
	-- INIT
	if Response and typeof(Response) == "table" then
		for i, Shot in pairs(Response) do
			local DamageInfo = Shot["Damage"]
			local FeedInfo = Shot["Feed"]

			if DamageInfo then
				local Success, Error = pcall(function()
					return ProcessCommunicationsEvent:Fire("Damage", DamageInfo["Character"], DamageInfo["Damage"], DamageInfo["IsHeadShot"], DamageInfo["DamagedHealth"], DamageInfo["Position"])

					--ProcessCommunicationsModule:ClientFire("Damage", DamageInfo["Character"], DamageInfo["Damage"], DamageInfo["IsHeadShot"], DamageInfo["DamagedHealth"], DamageInfo["Position"])
				end)

				if not Success then
					DebugModule:Print(script.Name.. " | Shot Invoke Registry | Error: ".. tostring(Error))
				end
			end

			if FeedInfo then
				local Success, Error = pcall(function()
					return ProcessCommunicationsEvent:Fire("Feed", FeedInfo["Type"], FeedInfo["XpToGive"], FeedInfo["Args"])
				end)

				if not Success then
					DebugModule:Print(script.Name.. " | Shot Invoke Registry | Feed | Error: ".. tostring(Error))
				end
			end
		end
	end
end

local function FireProcedure()
	-- Functions
	-- INIT
	local WeaponInfo = VehicleInfo["GunInfo"]
	
	local CastResult = CharacterFPSHandlerModule:FireCastRay(GunModel, BarrelPart, "Machine Gun Turret")

	--DebugModule:Print(ModelRoot.Name.. " | ".. script.Name.. " | Cast Result: ".. tostring(CastResult))

	--VehicleProcessRemote:FireServer("Fire", CastResult)
	
	coroutine.wrap(function()
		local Result = VehicleRequestSignal:InvokeServer("Fire", CastResult)
		
		HandleFireResponse(Result)
	end)()
	
	coroutine.wrap(function()
		CameraModule:CameraProcess("FOVOffset", true, WeaponInfo["ShakeIntensity"] / 4)
		CameraModule:CameraProcess("Shake", true, WeaponInfo["ShakeIntensity"], WeaponInfo["ShakeDuration"], "Fire", "Y")
	end)()	
	
	coroutine.wrap(function()
		FpsEffectsModule:ClientFireEffect(EffectsHandlerModule, ModelRoot, CastResult, "Machine Gun Turret")
	end)()
end

local function Fire()
	-- CORE
	local CustomConnection = UtilitiesModule:CreateCustomConnection(FireCustomConnections)
	
	-- Functions
	-- INIT
	--CollectionService:AddTag(ModelRoot, "MachineGunTurret")
	LastSpinUpTime = tick()
	VehicleProcessRemote:FireServer("SpinUp")
	
	repeat
		task.wait()
	until not CustomConnection or not CustomConnection.Value or (tick() - LastSpinUpTime) > VehicleInfo["SpinUpTime"]
	
	if not CustomConnection or not CustomConnection.Value then
		return nil
	end
	
	EffectsHandlerModule:ToggleParticleEmitters(BarrelPart:FindFirstChildOfClass("Attachment"), true)
	
	repeat
		task.wait(1 / VehicleInfo["GunInfo"]["FireRate"])
		
		FireProcedure()
	until not CustomConnection or not CustomConnection.Value
	EffectsHandlerModule:ToggleParticleEmitters(BarrelPart:FindFirstChildOfClass("Attachment"), false)
end

local function StopFire()
	-- Functions
	-- INIT
	--CollectionService:RemoveTag(ModelRoot, "MachineGunTurret")
	UtilitiesModule:DisconnectCustomConnections(FireCustomConnections)
	VehicleProcessRemote:FireServer("StopSpinning")
end

local function Blank()
	-- Functions
	-- INIT
	return nil
end

-- CORE FUNCTIONS
local InputBegin = 
{
	["Fire"] = Fire,
	["Ads"] = Blank
}

local InputEnd = 
{
	["Fire"] = StopFire,
	["Ads"] = Blank
}

-- DIRECT
function VehicleModule.GetInitialised()
	return Initialised
end

function VehicleModule.InputBegin(NilParam, ActionName, ...)
	local Args = {...}
	
	DebugModule:Print(ModelRoot.Name.. " | ".. script.Name.. " | Received Input Begin | ActionName: ".. tostring(ActionName).. " | Args: ".. tostring({...}))
	
	local Success, Error = pcall(function()
		return InputBegin[ActionName](unpack(Args))
	end)
	
	if not Success then
		DebugModule:Print("Mounted Turret | ".. script.Name.. " | InputBegin | Error: ".. tostring(Error))
	end
end

function VehicleModule.InputEnd(NilParam, ActionName, ...)
	local Args = {...}
	
	local Success, Error = pcall(function()
		return InputEnd[ActionName](unpack(Args))
	end)
	
	if not Success then
		DebugModule:Print("Mounted Turret | ".. script.Name.. " | InputEnd | Error: ".. tostring(Error))
	end
end

function VehicleModule.GetGlobals()
	return Vector2.new(-GlobalTurretXAngle, -GlobalTurretYAngle)
end

function VehicleModule.GetInputs()
	return InputBegin
end

function VehicleModule.Initialise()
	return Initialise()
end

function VehicleModule.End()
	return End()
end

return VehicleModule