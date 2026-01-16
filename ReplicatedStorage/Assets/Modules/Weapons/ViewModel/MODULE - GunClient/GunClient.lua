local GunClientModule = {}

-- Dirs
local ModelRoot = script.Parent.Parent.Parent
local GunModel = ModelRoot:WaitForChild("Gun")

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- INFO MODULES
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])
local GunAnimations = require(script.Parent["Animations"])
local CoreGunAnimations = require(script.Parent["CoreAnimations"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SettingsModule = require(ModulesFolder["Settings"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(ModelRoot.Name)
local AnimationToLoad = {}
local Connections = {}

local AnimationInstances = {}

local ElementsCache = {}

local Character = UtilitiesModule:GetCharacter(Player)
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local GunSpecificModule = nil

local Visible = true
local Equipped = false

local Charging = false

local Character = nil
local ServerGun = nil

-- Elements
-- MODELS
local GunModel = UtilitiesModule:WaitForChildTimed(ModelRoot, "Gun")

-- FOLDERS
local SurfacesFolder = GunModel:FindFirstChild("Surfaces") --UtilitiesModule:WaitForChildTimed(GunModel, "Surfaces")

-- PARTS
local AmmoCounterPart = nil
local EnergyVisualPart = nil

if SurfacesFolder then
	AmmoCounterPart = SurfacesFolder:FindFirstChild("AmmoCounter") --UtilitiesModule:WaitForChildTimed(SurfacesFolder, "AmmoCounter")]
	EnergyVisualPart = SurfacesFolder:FindFirstChild("EnergyVisual")	
end

local BarrelPart = GunModel:FindFirstChild("Barrel") --GunModel.PrimaryPart

if not BarrelPart then
	return nil
end

-- ATTACHMENTS
local EffectsAttachment = BarrelPart:FindFirstChildOfClass("Attachment") --UtilitiesModule:WaitForChildOfClass(BarrelPart, "Attachment")

-- PARTICLE EMITTERS
local MuzzleFlashParticleEmitter = EffectsAttachment:FindFirstChild("MuzzleFlash")

-- Surfaces
local AmmoCounterUi = nil --UtilitiesModule:WaitForChildOfClass(AmmoCounterPart, "SurfaceGui")
local EnergyVisualUi = nil

if EnergyVisualPart then
	EnergyVisualUi = EnergyVisualPart:FindFirstChild("SurfaceGui")
end

if AmmoCounterPart then
	AmmoCounterUi = AmmoCounterPart:FindFirstChild("SurfaceGui")
end

-- IMAGES
local EnergyVisualImage = nil

if EnergyVisualUi then
	EnergyVisualImage = EnergyVisualUi:FindFirstChild("Energy")
end

-- Texts
local AmmoText = nil --UtilitiesModule:WaitForChildTimed(AmmoCounterUi, "Ammo")

if AmmoCounterUi then
	AmmoText = AmmoCounterUi:FindFirstChild("Ammo")
end

-- Animations
local AnimationController = UtilitiesModule:WaitForChildOfClass(ModelRoot, "AnimationController")
local Animator = UtilitiesModule:WaitForChildOfClass(AnimationController, "Animator")

-- Functions
-- MECHANICS
local function GetServerGun()
	-- Functions
	-- INIT
	local FoundWeapon = UtilitiesModule:GetCharacter(Player, true):FindFirstChild(ModelRoot.Name)
	
	if not FoundWeapon then
		FoundWeapon = Player:WaitForChild("Backpack"):FindFirstChild(ModelRoot.Name)
	end
	
	return FoundWeapon
end

local function ToggleMuzzleFlash(ToggleValue)	
	-- Functions
	-- INIT
	for i, Effect in pairs(EffectsAttachment:GetChildren()) do
		Effect.Enabled = ToggleValue
	end
end

local function UpdateEnergySurfaceUi()
	-- Functions
	-- INIT
	UtilitiesModule:CreateElementCache(EnergyVisualImage, {"ImageColor3"}, ElementsCache)
	
	local CurrentUsage = ServerGun:GetAttribute("CurrentEnergyUsage")
	local MaxCharge = ServerGun:GetAttribute("MaxCharge")
	
	local OriginalColour = UtilitiesModule:Color3ToVector3(ElementsCache[EnergyVisualImage]["ImageColor3"])
	local DestinationColour = UtilitiesModule:Color3ToVector3(Color3.fromRGB(255, 0, 0))
	
	local Percentage = math.clamp(CurrentUsage / MaxCharge, 0, 1)
	local DifferenceBetweenValues = DestinationColour - OriginalColour
	
	local VectorToAdd = OriginalColour + (DifferenceBetweenValues * (Percentage))
	
	EnergyVisualImage.ImageColor3 = Color3.fromRGB(VectorToAdd.X, VectorToAdd.Y, VectorToAdd.Z)
end

local function UpdateAmmoSurfaceUi()
	-- Functions
	-- INIT
	if not AmmoText then
		return nil
	end
	
	repeat
		task.wait()
	until not ServerGun or ServerGun:GetAttributes()["RoundsInMag"] ~= nil
	
	local _AmmoText = ServerGun:GetAttribute("RoundsInMag") or 0
	
	if string.len(_AmmoText) < 2 then
		_AmmoText = "0".. tostring(_AmmoText)
	end
	
	AmmoText.Text = _AmmoText
end

local function Show(Force)
	-- Functions
	-- INIT
	--[[if not GunModel.Parent or GunModel.Parent.Name ~= "ViewModels" then
		return nil
	end]]
	
	if Visible and not Force then
		return nil
	end	
	
	local AllowedClassNames = {"Decal", "Texture"}

	--DebugModule:Print"Showing view model gun: ".. tostring(GunModel.Name))
	
	Visible = true

	for i, Part in pairs(ModelRoot:GetDescendants()) do
		if Part:IsA("BasePart") or table.find(AllowedClassNames, Part.ClassName) then
			UtilitiesModule:CreateElementCache(Part, {"Transparency"}, ElementsCache)
			Part.Transparency = ElementsCache[Part]["Transparency"]
		elseif Part:IsA("SurfaceGui") then
			Part.Enabled = true
		end
	end
	
	if Charging then
		GunClientModule:Charge()
	end
end

local function Hide(_GunModel, Force)
	-- Functions
	-- INIT
	if not Visible and not Force then
		--DebugModule:Print("GunClient | Attempted to hide already hidden ViewModel")
		return nil
	end
	
	local AllowedClassNames = {"Decal", "Texture"}
	
	local ModelRoot = ModelRoot
	
	if _GunModel then
		ModelRoot = GunModel
	end
	
	--DebugModule:Print"Hiding view model gun: ".. tostring(GunModel.Name))
	Visible = false
	
	for i, Part in pairs(ModelRoot:GetDescendants()) do
		--DebugModule:Print("GunClient | Hiding: ".. tostring(Part.Name).. " | Type: ".. tostring(Part.ClassName))
		
		if Part:IsA("BasePart") or table.find(AllowedClassNames, Part.ClassName) --[[(Part:IsA("Decal") and Part.Name == "ArmourColour")]] then
			UtilitiesModule:CreateElementCache(Part, {"Transparency"}, ElementsCache)
			Part.Transparency = 1
		elseif Part:IsA("SurfaceGui") then
			Part.Enabled = false	
		end
	end
	
	ToggleMuzzleFlash(false)
end

local function StopAnimation(AnimationName)
	-- Functions
	-- INIT
	if GunAnimations[AnimationName] and not AnimationToLoad[AnimationName] then
		repeat
			task.wait()
		until AnimationToLoad[AnimationName]
	end
	
	if AnimationToLoad[AnimationName] then
		AnimationToLoad[AnimationName]:Stop()
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
	
	UtilitiesModule:LoadAnimations(GunAnimations, AnimationInstances, AnimationToLoad, Animator, true)
	UtilitiesModule:LoadAnimations(CoreGunAnimations, AnimationInstances, AnimationToLoad, Animator, true)
	
	if WeaponInfo and WeaponInfo["AnimationSpeeds"] then
		for AnimationName, AnimationSpeed in pairs(WeaponInfo["AnimationSpeeds"]) do
			AnimationToLoad[AnimationName]:AdjustSpeed(AnimationSpeed)
		end
	end
	
	--coroutine.wrap(function()
		--[[for InstanceName, AnimationInfo in pairs(GunAnimations) do
			-- Instancing		
			coroutine.wrap(function()
				local Success, Error = false, nil

				local Animation = Instance.new("Animation")
				Animation.AnimationId = AnimationInfo.Id

				table.insert(AnimationInstances, Animation)

				repeat
					Success, Error = pcall(function()
						AnimationToLoad[InstanceName] = Animator:LoadAnimation(Animation)
					end)

					task.wait()	
				until Success
			end)()
		end]]
	--end)()
end

local function PlayAnimation(AnimationName, WaitTillFinished, FreezeFrameName, Speed)
	-- Functions
	-- INIT
	if not AnimationToLoad[AnimationName] and GunAnimations[AnimationName] then
		repeat
			InitialiseAnimations()
			task.wait()
		until AnimationToLoad[AnimationName]
	end
	
	if FreezeFrameName then
		--DebugModule:Print"Creating freez frame connection for '".. tostring(AnimationName).. "' called: ".. tostring(FreezeFrameName))
		local Connection1 = nil
		
		Connection1 = AnimationToLoad[AnimationName]:GetMarkerReachedSignal(FreezeFrameName):Connect(function()
			-- Functions
			-- INIT			
			--DebugModule:Print"Freezing animation '".. tostring(AnimationName).. "' at keyframe: ".. tostring(FreezeFrameName))
			AnimationToLoad[AnimationName]:AdjustSpeed(0)
			Connection1:Disconnect()
		end)
		
		-- Connections
		table.insert(Connections, Connection1)
	end
	
	----DebugModule:Print"Playing View Model gun animation: ".. tostring(AnimationName))
	AnimationToLoad[AnimationName]:Play()
	
	if Speed then
		AnimationToLoad[AnimationName]:AdjustSpeed(Speed)
	end
	
	if WaitTillFinished then
		AnimationToLoad[AnimationName].Stopped:Wait()
	end
	
	return AnimationToLoad[AnimationName]
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
		return GunSpecificModule:Initialise(GunClientModule, GunModel, GetServerGun())
	end
end

-- INIT
function GunClientModule.Show()
	return Show(true)
end

function GunClientModule.Hide(NilParam, _GunModel, Force)
	return Hide(_GunModel, Force)
end

function GunClientModule.Initialise()
	Hide()
	
	-- Elements
	-- PARTS
	local Shell = ModelRoot:FindFirstChild("Shell")
	
	-- Functions
	-- INIT
	Equipped = false
	if Shell then
		UtilitiesModule:CreateElementCache(Shell, {"Transparency"}, ElementsCache)
		Shell.Transparency = 1
	end
	
	InitialiseAnimations()
	InitialiseSpecificModule()
	
	--DebugModule:Print(AnimationToLoad)
	
	--AnimationToLoad["Reload"]:AdjustSpeed(WeaponInfo["ReloadSpeed"])
	
	if AnimationToLoad["Reload"] and table.find({1, nil}, WeaponInfo["ReloadSpeed"]) == nil then
		pcall(function()
			AnimationToLoad["Reload"]:AdjustSpeed(WeaponInfo["ReloadSpeed"])
		end)
	else
		DebugModule:Print("ServerGunClient | Cannot find Reload animation in table!")
	end
end

function GunClientModule.Charge()
	-- Functions
	-- INIT
	Charging = true
	PlayAnimation("Charge")
	ToggleMuzzleFlash(true)
end

function GunClientModule.StopCharge()
	-- Functions
	-- INIT
	Charging = false
	StopAnimation("Charge")
	ToggleMuzzleFlash(false)
end

function GunClientModule.StopFiring()
	-- Functions
	-- INIT
	ToggleMuzzleFlash(false)
end

function GunClientModule.Fire(NilParam, Ads, Type, ThirdPerson)
	-- Functions
	-- INIT
	if not Ads then
		if not ThirdPerson then
			Show()
		end
		
		if SettingsModule:GetSettingValue("Video", "BulletSpecular", true) and not ThirdPerson then
			ToggleMuzzleFlash(true)
			
			coroutine.wrap(function()
				if Type ~= "Automatic" then
					--task.wait(--[[.1]] 1 / WeaponInfo["FireRate"])
					task.wait(MuzzleFlashParticleEmitter.Lifetime.Min)
					ToggleMuzzleFlash(false)
				end
			end)()
		end
	end
	PlayAnimation("Fire", false)
end

function GunClientModule.CancelReload(NilParam)
	-- Functions
	-- INIT
	StopAnimation("Reload")
	
	local FoundShell = ModelRoot:FindFirstChild("Shell")
	
	if FoundShell then
		FoundShell.Transparency = 1
	end
end

function GunClientModule.Reload(NilParam, Speed)
	-- Functions
	-- INIT
	local FoundShell = ModelRoot:FindFirstChild("Shell")

	if FoundShell then
		FoundShell.Transparency = ElementsCache[FoundShell]["Transparency"]	
	end

	PlayAnimation("Reload", true, nil, Speed)

	if FoundShell then
		FoundShell.Transparency = 1
	end
end

function GunClientModule.DrinkPerk(NilParam, ThirdPerson)
	-- Functions
	-- INIT
	GunClientModule:Hide(true)
	--StopAnimation("Reload")
	StopAllAnimations()
	PlayAnimation("DrinkPerk", true)

	if Equipped and not ThirdPerson then
		GunClientModule:Show()
	end
end

function GunClientModule.ThrowGrenade(NilParam, ThirdPerson, Speed)
	-- Functions
	-- INIT
	GunClientModule:Hide(true)
	--StopAnimation("Reload")
	StopAllAnimations()
	PlayAnimation("ThrowGrenade", true, nil, Speed)
	
	if Equipped and not ThirdPerson then
		GunClientModule:Show()
	end
end

function GunClientModule.Melee(NilParam, Speed)
	-- Functions
	-- INIT
	StopAnimation("Reload")
	PlayAnimation("Melee", true, nil, Speed)
end

function GunClientModule.Unequip(NilParam, HideJustHand)
	-- Functions
	-- INIT
	Equipped = false
	Charging = false
	
	coroutine.wrap(function()
		PlayAnimation("Unequip", true)
		
		if not Equipped then
			if not HideJustHand then
				Hide()
			else
				Hide(GunModel)
			end
		end
		
		StopAllAnimations()
	end)()
end

function GunClientModule.GetAnimationToLoad()
	return AnimationToLoad
end

function GunClientModule.Equip(NilParam, ThirdPerson, _Wait)
	-- Functions
	-- INIT
	Equipped = true
	
	StopAllAnimations()
	AnimationToLoad["Equip"]:AdjustSpeed(1)
	PlayAnimation("Equip", _Wait, "Equipped")
	--[[coroutine.wrap(function()
		task.wait(1)
		if Equipped and not Humanoid:GetAttributes()["Ads"] then
			DebugModule:Print("GunClient | SHOWING GUN VIEWMODEL")
			Show(true)
		end
	end)()]]
	
	if not ThirdPerson then
		Show(true)
	else
		Hide()
	end
	
	Character = ModelRoot:FindFirstAncestorOfClass("Model")
	
	repeat
		Character = ModelRoot:FindFirstAncestorOfClass("Model")
		task.wait()
	until Character
	
	ServerGun = UtilitiesModule:WaitForChildTimed(Character, ModelRoot.Name)
	
	if not ServerGun then
		return nil
	end
	
	--[[
	repeat
		task.wait()
	until ServerGun:GetAttributes()["RoundsInMag"] ~= nil or not ServerGun]]
	local RoundTypeToCheck = 
	{
		["Shell"] = "RoundsInMag",
		["Medium"] = "RoundsInMag",
		["Light"] = "RoundsInMag",
		["Heavy"] = "RoundsInMag",
		["Plasma"] = "CurrentEnergyUsage"	
	}
	
	-- MECHANICS
	local function Update()
		-- Functions
		-- INIT
		local Success, Error = pcall(function()
			if table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) --[[WeaponInfo["RoundType"] == "Plasma"]] then
				return UpdateEnergySurfaceUi()
			else
				return UpdateAmmoSurfaceUi()
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | ViewModel |  Error: ".. tostring(Error))
		end
	end
	
	
	--UpdateSurfaceUi()
	
	-- DIRECT
	local Connection1 = nil 
	
	if WeaponInfo and WeaponInfo["RoundType"] then
		Connection1 = ServerGun:GetAttributeChangedSignal(--[["RoundsInMag"]] RoundTypeToCheck[WeaponInfo["RoundType"]]):Connect(function()
			return Update() --UpdateSurfaceUi()
		end)
	end
	
	-- Connections
	table.insert(Connections, Connection1)
	
	-- INIT
	Update()
end

function GunClientModule.End()
	-- Functions
	-- INIT
	Equipped = false
	StopAllAnimations()
	DestroyAllAnimations()
	--AnimationToLoad = nil
	--ElementsCache = nil
	EndSpecificModule()
	UtilitiesModule:DisconnectConnections(Connections)
	--Connections = nil
end

return GunClientModule