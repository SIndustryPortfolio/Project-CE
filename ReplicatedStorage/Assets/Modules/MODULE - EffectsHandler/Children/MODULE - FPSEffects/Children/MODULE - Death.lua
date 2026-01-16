local DeathModule = {}

-- Dirs
--local Character = nil --script.Parent.Parent.Parent.Parent.Parent

-- Client
local Player = game.Players.LocalPlayer

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local CameraModule = require(ModulesFolder["Camera"])
local CharacterModule = require(ModulesFolder["Character"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- Elements
-- FOLDERS
local GameDeployedFolder = SharedGameFolder["Deployed"]

-- CORE
local Connections = {}
local AnimationToLoad = {}
local AnimationInstances = {}
local TweenDict = {}

local CameraOffset = Vector3.new(0, 10, 0)

local EffectInfo = 
{
	["Duration"] = 3,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut	
}

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function SetupCamera()
	-- Functions
	-- INIT
	local Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = nil
end

function StopAllAnimations(Humanoid, Ignore)
	-- Functions
	-- INIT
	if not Ignore then
		Ignore = {}
	end

	for i, AnimationLoad in pairs(Humanoid:GetPlayingAnimationTracks()) do
		if not table.find(Ignore, AnimationLoad.Name) then
			AnimationLoad:Stop()
		end
	end
end

local function LoadAnimations(Humanoid, Animations) 
	-- Functions
	-- INIT
	UtilitiesModule:LoadAnimations(Animations, AnimationInstances, AnimationToLoad, Humanoid)
	
	--[[for AnimationName, AnimationInfo in pairs(Animations) do
		local AnimationInstance = Instance.new("Animation")
		AnimationInstance.AnimationId = AnimationInfo.Id
		AnimationInstance.Name = AnimationName
		
		AnimationToLoad[AnimationName] = Humanoid:LoadAnimation(AnimationInstance)
	end]]
end

local function CameraEffect(Character)
	-- CORE
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local Camera = workspace.CurrentCamera
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	--[[local tweeningInfo = {}
	tweeningInfo.CFrame = CFrame.new(HumanoidRootPart.CFrame.p + CameraOffset, HumanoidRootPart.CFrame.p)]]
	
	-- Functions
	-- MECHANICS
	local function RenderCamera()
		-- Functions
		-- INIT
		if not HumanoidRootPart or not Camera or not Humanoid or Humanoid.Health > 0 then
			RunService:UnbindFromRenderStep("DeathCamera")
			return nil
		end
		
		--Camera.CFrame = CFrame.new(HumanoidRootPart.CFrame.p + CameraOffset, HumanoidRootPart.CFrame.p)
		Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(HumanoidRootPart.CFrame.p + CameraOffset, HumanoidRootPart.CFrame.p), 0.05)
		--[[local tweeningInfo = {}
		tweeningInfo.CFrame = CFrame.new(HumanoidRootPart.CFrame.p + CameraOffset, HumanoidRootPart.CFrame.p)
		
		UtilitiesModule:CancelTween(Camera, TweenDict)
		TweenDict[Camera] = TweenService:Create(Camera, tweenInfo, tweeningInfo)
		TweenDict[Camera]:Play()
		UtilitiesModule:CompleteTween(Camera, TweenDict)]]
	end
	
	-- INIT
	CameraModule:ResetCamera()
	
	--[[UtilitiesModule:CancelTween(CameraEffect, TweenDict)
	TweenDict[Camera] = TweenService:Create(Camera, tweenInfo, tweeningInfo)
	TweenDict[Camera]:Play()
	UtilitiesModule:CompleteTween(Camera, TweenDict)]]
	RunService:BindToRenderStep("DeathCamera", Enum.RenderPriority.First.Value, RenderCamera)
end

local function Initialise(EffectsHandlerModule, Character)
	-- CORE
	local Character = Character or UtilitiesModule:GetCharacter(Player, true)
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart") or Character.PrimaryPart

	-- Folders
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Character, "Core")
	
	-- Modules
	local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	-- Funcitons
	-- INIT
	if InterfacesModule:IsPageOpen("Custom", "Multiplayer") or (SharedGameFolder:GetAttribute("GameTime") or 0) <= 0 then
		return nil
	end
	
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	
	LoadAnimations(Humanoid, require(UtilitiesModule:WaitForChildTimed(CoreFolder, "DeathAnimations")))
	
	if HudModule then
		HudModule:HideCursor()
	end
	
	StopAllAnimations(Humanoid, {"DeathFalling"})

	CharacterModule:CharacterProcess("Death", Character)
	
	CameraEffect(Character)
	
	if AnimationToLoad["DeathFalling"] ~= nil then
		AnimationToLoad["DeathFalling"]:Play()
	else
		return nil
	end
	
	if not HumanoidRootPart then
		return nil
	end
	
	HumanoidRootPart.Velocity = HumanoidRootPart.Velocity + Vector3.new(0, 5, 0)
	InterfacesModule:LoadPage("Custom", "ScoreBoard", true)
	
	local HudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	task.wait(1)
	
	local Connection1Triggers = {}
	
	if HudUiModule then
		HudUiModule:End()
	end
	
	coroutine.wrap(function()
		local Connection2 = nil
		
		--ShortcutsModule:Ragdollify(Character)
		
		for i, Part in pairs(Character:GetDescendants()) do
			if not Part:IsA("BasePart") then
				continue
			end

			-- DIRECT
			local Connection1 = Part.Touched:Connect(function(Hit)
				if not Hit:IsDescendantOf(UtilitiesModule:WaitForChildTimed(workspace, "Map")) then
					return nil
				end

				UtilitiesModule:DisconnectConnections(Connection1Triggers)
				StopAllAnimations(Humanoid, {"DeathFinalPose"})
				
				if AnimationToLoad["DeathFinalPose"] ~= nil then
					AnimationToLoad["DeathFinalPose"]:Play()
				end
			end)

			-- Connections
			table.insert(Connection1Triggers, Connection1)
		end
		
		if AnimationToLoad["DeathFinalPose"] ~= nil then
			Connection2 = AnimationToLoad["DeathFinalPose"]:GetMarkerReachedSignal("Freeze"):Connect(function()
				UtilitiesModule:DisconnectConnections(Connection1Triggers)
				
				if AnimationToLoad["DeathFinalPose"] ~= nil then
					AnimationToLoad["DeathFinalPose"]:AdjustSpeed(0)
					--ShortcutsModule:Ragdollify(Character)
				end
				
				Connection2:Disconnect()
			end)
		end

		-- Connections
		table.insert(Connections, Connection2)
	end)()
	
	task.wait(1)
	
	if --[[game.Players:GetPlayerFromCharacter(Character)]] Character.Name == Player.Name then
		if #GameDeployedFolder:GetChildren() > 1 then --if _G["KilledBy"] ~= nil and _G["KilledBy"]["Murderer"] ~= nil and (tick() - _G["KilledBy"]["Time"]) < 10 then
			RunService:UnbindFromRenderStep("DeathCamera")
			
			if _G["KilledBy"] ~= nil and _G["KilledBy"]["Murderer"] ~= nil and (tick() - _G["KilledBy"]["Time"]) < 10 then
				return InterfacesModule:LoadPage("Custom", "Died", true, _G["KilledBy"]["Murderer"])
			else
				return InterfacesModule:LoadPage("Custom", "Died", true, nil)
			end
		else
			DebugModule:Print(script.Name.. " | No death cam | _G['KilledBy']: ".. tostring(_G["KilledBy"]))
		end
	end
end

local function DestroyAllAnimationInstances()
	-- Functions
	-- INIT
	for i, AnimationInstance in pairs(AnimationInstances) do
		AnimationInstance:Destroy()
	end
end

-- DIRECT
function DeathModule.Initialise(NilParam, EffectsHandlerModule, Character)
	return Initialise(EffectsHandlerModule, Character)
end

function DeathModule.End()
	-- Functions
	-- INIT
	DestroyAllAnimationInstances()
	UtilitiesModule:DisconnectConnections(Connections)
end

return DeathModule