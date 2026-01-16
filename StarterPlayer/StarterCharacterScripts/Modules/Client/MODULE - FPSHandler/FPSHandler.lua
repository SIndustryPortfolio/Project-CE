local FPSHandlerModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent
local CharacterClientServerSignalsFolder = Character:WaitForChild("Remotes")["ClientServer"]["Signals"]
local CharacterClientServerRemotesFolder = Character:WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]
local CharacterCoreFolder = Character:WaitForChild("Core")

-- EXT
local PartsViewModelsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedFPSAPIsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["APIs"]["FPS"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- InfoModules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])
local AdsInfoModule = require(SharedInfoModulesFolder["Ads"])
local FpsInfoModule = require(SharedInfoModulesFolder["Fps"])
local CharacterInfoModule = require(SharedInfoModulesFolder["Character"])
local VehiclesInfoModule = require(SharedInfoModulesFolder["Vehicles"])
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
--local CharacterAnimationsInfoModule = require(CharacterCoreFolder["Animations"])
local SoundsInfoModule = require(SharedInfoModulesFolder["Sounds"])
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local PlayerModule = require(Player.PlayerScripts:WaitForChild("PlayerModule"))
--
local MapsModule = require(SharedModulesFolder["Maps"])
--local ClientMapsModule = require(SharedModulesFolder["Maps"])
local SettingsModule = require(SharedModulesFolder["Settings"])
local InterfacesModule = require(SharedModulesFolder["Interfaces"])
local CameraModule = require(SharedModulesFolder["Camera"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local FPSEffectsModule = require(SharedModulesFolder["EffectsHandler"]["FPSEffects"]) --require(UtilitiesModule:WaitForChildTimed(script, "FPSEffects"))
local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local CharacterModule = require(SharedModulesFolder["Character"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local FPSServerModule = require(UtilitiesModule:WaitForChildTimed(script, "FPSServer"))
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
--

-- APIs
local _SpringModuleInstance = SharedFPSAPIsFolder["Spring"]:Clone()
local SpringModule = require(_SpringModuleInstance)

-- Elements
-- REMOTES
local ProcessCommunicationsEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "ProcessCommunications")
local MouseCameraEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "MouseCamera")
local CharacterProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterProcess")
local CharacterPhysicsProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterPhysicsProcess")
local InterfaceRemote = UtilitiesModule:WaitForChildTimed(ClientRemotesFolder, "Interface")

-- SIGNALS
local CharacterRequestSignal = UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, "CharacterRequest")
local GunRequestSignal = UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, "GunRequest")
local GameRequestSignal = UtilitiesModule:WaitForChildTimed(ClientServerSignalsFolder, "GameRequest")

-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- PARTS
local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
local UpperTorso = UtilitiesModule:WaitForChildTimed(Character, "UpperTorso")
local Head = UtilitiesModule:WaitForChildTimed(Character, "Head")

-- Attachments
local Neck = Character:WaitForChild("Head"):FindFirstChild("Neck") or UtilitiesModule:WaitForChildTimed(Character:WaitForChild("UpperTorso"), "Neck")
local Waist = Character:WaitForChild("UpperTorso"):FindFirstChild("Waist") or UtilitiesModule:WaitForChildTimed(Character:WaitForChild("LowerTorso"), "Waist")

-- FOLDERS
local CharacterCoreFolder = UtilitiesModule:WaitForChildTimed(Character, "Core")
local CharacterDrinksFolder = UtilitiesModule:WaitForChildTimed(Character, "Drinks")

local CharacterViewModelsFolder = UtilitiesModule:WaitForChildTimed(Character, "ViewModels")
local CharacterViewModelsCacheFolder = UtilitiesModule:WaitForChildTimed(CharacterViewModelsFolder, "Cache")

local PartsViewModelArmsFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Arms")
--local PartsViewModelBottlesFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Bottles")
--local PartsViewModelGrenadesFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Grenades")
local PartsViewModelGunsFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Guns")

-- VALUES
local FancyCameraValue = SettingsModule:GetSettingValueInstance("Game", "FancyCamera")
local CharacterVehicleValue = CharacterCoreFolder["Vehicle"]

-- CORE
local LastSwitchTime = tick()
local LastReloadTime = tick()

local ProjectilesToCheck = {}

local ShotCharged = nil
local Charging, LastChargingTick = nil, nil
local LastChargeShakeTick = nil

local LastMouseTick = tick()

local LastEnergyTick = tick()

local ThirdPerson = SettingsModule:GetSettingValue("Game", "ThirdPerson", true)

local BopZeroMark = nil

local Dying = false
local IsUnequipping = false
local IsLoaded = false
local ReturningToMenu = false
local ADSing = false

local Connections = {}
local CustomConnections = {}

local ActionToSound = {}

local FireCustomConnection = nil

local InstanceCache = {}

local RequiredClientModules = UtilitiesModule:RunSubModules(UtilitiesModule:WaitForChildTimed(script, "Client"), true)

--
local WeaponConnections = {}
--
local ElementsCache = {}
local CharacterVisibleParts = 
	{
	--[["LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"	]]
	}



local AnimationToLoad = 
	{

	}

-- MOTORS
local LastNeckC0 = nil
local LastWaistC0 = nil
local NeckOriginC0 = nil
local WaistOriginC0 = nil

pcall(function()
	LastNeckC0 = Neck.C0
	LastWaistC0 = Waist.C0
	NeckOriginC0 = Neck.C0
	WaistOriginC0 = Waist.C0
end)

local TweenDict = {}

local SwaySpring = SpringModule.create()
local ControlsModule = PlayerModule:GetControls()

-- FPS GUN
local SwitchingWeapon = false
local IsShooting = false
local LastShotTime = tick()
local LastShotWeaponName = nil
local IsThrowing = false

local EquippedWeaponModel = nil
local FakeCameraPart = nil
local GunHumanoidRootPart = nil
local GunClientModule = nil

-- SERVER GUN
local EquippedServerWeaponModel = nil
local ServerGunClientModule = nil
local CachedGunClientModule = nil

-- CAMERA
local Camera = nil
local BlurEffect = CameraModule:CreateBlurEffect()
local GlobalYCameraAngle = 0
local GlobalXCameraAngle = 0
local BopCFrame = CFrame.new(0, 0, 0)
local Sway = {x = 0, y = 0}
--local Sensitivity = 0.2

--
local LastPosition = Vector3.new()

-- Services
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function CancelActionSound(ActionName)
	-- Functions
	-- INIT
	if ActionToSound[ActionName] ~= nil then
		pcall(function()
			ActionToSound[ActionName]:Stop()
		end)

		pcall(function()
			DebrisModule:AddItem(ActionToSound[ActionName])
		end)
	end
end

local function CancelReload()
	-- Functions
	-- INIT
	CancelActionSound("Reload")

	local HudInterfaceModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	if HudInterfaceModule then
		HudInterfaceModule:HudProcess("Cursor", "CancelReload")
	end

	local Success, Error = pcall(function()
		if GunClientModule then
			return GunClientModule:CancelReload()
		end
	end)

	if not Success then
		DebugModule:Print(script.Name.. " | Fire | Reload | GunClientModule: ".. tostring(GunClientModule).. " | Error: ".. tostring(Error))
	end

	local Success, Error = pcall(function()
		if ServerGunClientModule then
			return ServerGunClientModule:CancelReload()
		end
	end)

	if not Success then
		DebugModule:Print(script.Name.. " | Fire | Reload | ServerGunClientModule: ".. tostring(ServerGunClientModule).. " | Error: ".. tostring(Error))
	end

	Humanoid:SetAttribute("Reload", false)
end


local function IsPerformingPhysicalAction()
	-- Functions
	-- INIT
	if --[[Humanoid:GetAttributes()["Reload"] or]] Humanoid:GetAttributes()["Melee"] or Humanoid:GetAttributes()["Grenade"] or Humanoid:GetAttributes()["Drink"] or CharacterVehicleValue.Value or IsThrowing then
		return true
	end
end

local function IsFPSLocked()
	-- Functions
	-- INIT
	local IsLocked = false

	if InterfacesModule and (InterfacesModule:IsPageOpen("Custom", "Settings") or InterfacesModule:IsPageOpen("Custom", "ChangeTeam")) then
		IsLocked = true
	end

	return IsLocked
end

local function ResetCharacterVelocity()
	-- Functions
	-- INIT
	Character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
	Character.PrimaryPart.RotVelocity = Vector3.new(0, 0, 0)
end

local function ForceEmptyViewModelsFolder()
	-- Functions
	-- INIT
	for i, Model in pairs(CharacterViewModelsFolder:GetChildren()) do
		if not Model:IsA("Model") then
			continue
		end

		Model:Destroy()
	end
end

local function CanReload()
	if not EquippedServerWeaponModel then
		return nil
	end

	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)

	-- Functions
	-- INIT

	if (--[[WeaponInfo["RoundType"] ~= "Plasma"]] table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) and EquippedServerWeaponModel:GetAttribute("RoundsInMag") ~= EquippedServerWeaponModel:GetAttribute("MaxRoundsInMag") and EquippedServerWeaponModel:GetAttribute("Rounds") > 0) or (WeaponInfo["RoundType"] == "Plasma" and EquippedServerWeaponModel:GetAttribute("Energy") > 0 and EquippedServerWeaponModel:GetAttribute("CurrentEnergyUsage") == EquippedServerWeaponModel:GetAttribute("MaxCharge")) then
		return true
	end

	return false
end

function GetViewModelArms()
	-- CORE
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))

	-- Functions
	-- INIT	
	local Arms = UtilitiesModule:WaitForChildTimed(PartsViewModelArmsFolder, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Variant").Value):Clone()

	if not GameModeInfo["Teams"] or (GameModeInfo["Teams"] and not Character:GetAttributes()["ColourOverwrite"]) then
		CharacterModule:SetCharacterAppearance(Arms, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour").Value, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour").Value)
	else
		CharacterModule:SetCharacterAppearance(Arms, Character:GetAttributes()["ColourOverwrite"].Name --[[Player.Team.Name]], ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour").Value)
	end

	return Arms
end

function GetViewModelGun(GunName)
	-- Functions
	-- INIT
	if GunName == "" then
		return nil
	end

	return UtilitiesModule:WaitForChildTimed(PartsViewModelGunsFolder, GunName):Clone()
end

local function FireCastRay(_GunModel, _BarrelPart, WeaponName, Thickness)
	-- Elements
	-- MODELS
	local GunModelInViewport = _GunModel or EquippedWeaponModel:FindFirstChild("Gun")

	if not GunModelInViewport and not _GunModel then
		----DebugModule:Print"Client return nil") --print("Client return nil")
		return nil
	end

	-- PARTS
	local BarrelPart = _BarrelPart or GunModelInViewport:FindFirstChild("Barrel") --GunModelInViewport.PrimaryPart

	if not BarrelPart then
		return nil
	end

	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or EquippedServerWeaponModel.Name)

	local RandomXOffset = 0 
	local RandomYOffset = 0 

	local Spread = WeaponInfo["Spread"]

	if CharacterDrinksFolder:FindFirstChild("Deadshot Daiquiri") and Spread then
		Spread *= 0.65
	end

	if WeaponInfo["Spread"] ~= nil and WeaponInfo["Spread"] ~= 0 then
		RandomXOffset = math.random(-(Spread * 100), Spread * 100) / 100
		RandomYOffset = math.random(-(Spread * 100), Spread * 100) / 100
	end

	local raycastParams = RaycastParams.new()
	local FilterDescendants = {Character, UtilitiesModule:WaitForChildTimed(workspace, "Dump"), unpack(UtilitiesModule:CombineTables(ShortcutsModule:GetAllDeadAi(), MapsModule:GetMapRaycastBlacklistFolders(), ShortcutsModule:GetAllDeadCharacters()))}
	
	for i, ToFilter in pairs(UtilitiesModule:CombineTables({_GunModel, _BarrelPart}, CharacterModule:CharacterProcess("GetAllShieldEffects"), CollectionService:GetTagged("Water"))) do
		if not ToFilter then
			continue
		end
		
		table.insert(FilterDescendants, ToFilter)
	end
	
	--[[if _GunModel then
		table.insert(FilterDescendants, _GunModel)
	end

	if _BarrelPart then
		table.insert(FilterDescendants, _BarrelPart)
	end

	for i, ShieldEffect in pairs(CharacterModule:CharacterProcess("GetAllShieldEffects")) do
		table.insert(FilterDescendants, ShieldEffect)
	end

	for i, Water in pairs(CollectionService:GetTagged("Water")) do
		table.insert(FilterDescendants, Water)
	end]]

	raycastParams.FilterDescendantsInstances = FilterDescendants --{Character, UtilitiesModule:WaitForChildTimed(workspace, "Dump"), unpack(CharacterModule:CharacterProcess("GetAllShieldEffects")), unpack(CollectionService:GetTagged("Water"))}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude --Enum.RaycastFilterType.Blacklist

	--local OriginPosition = BarrelPart.CFrame.p
	local OriginCFrame = Camera.CFrame
	--local RayDirection = ((Mouse.Hit * CFrame.new(RandomXOffset, RandomYOffset, 0)).p - OriginPosition).Unit * 600
	local CameraRayDirection = (Camera.CFrame --[[* CFrame.new(RandomXOffset, RandomYOffset, 0)]]).LookVector * FpsInfoModule:GetFpsInfo("RayLength") --600

	local CameraRayResult = workspace:Raycast(OriginCFrame.Position, CameraRayDirection, raycastParams)

	local RayDirection = nil

	if CameraRayResult == nil or CameraRayResult.Instance == nil then
		CameraRayResult = {Position = OriginCFrame.Position + CameraRayDirection}
	end

	--if CameraRayResult then
	local Distance = (CameraRayResult["Position"] - BarrelPart.CFrame.p).Magnitude

	if Humanoid:GetAttribute("Ads") then
		RandomXOffset *= FpsInfoModule:GetFpsInfo("AdsSpreadMultiplier")
		RandomYOffset *= FpsInfoModule:GetFpsInfo("AdsSpreadMultiplier")
	end

	local DropOffs = Distance / 30
	RandomXOffset *= DropOffs
	RandomYOffset *= DropOffs

	local EndPosition = nil 

	if CameraRayResult["Normal"] then
		EndPosition = (CFrame.new(CameraRayResult["Position"], CameraRayResult["Position"] + CameraRayResult["Normal"]) * CFrame.new(RandomXOffset, RandomYOffset, 0)).Position
	else
		EndPosition = (CFrame.new(CameraRayResult["Position"]) * CFrame.new(RandomXOffset, RandomYOffset, 0)).Position
	end

	RayDirection = (EndPosition - --[[Camera.CFrame.Position]] OriginCFrame.Position).Unit * FpsInfoModule:GetFpsInfo("RayLength")

	--RayDirection = ((CFrame.new(CameraRayResult.Position, CameraRayResult.Position + CameraRayResult.Normal) * CFrame.new(RandomXOffset, RandomYOffset, 0)).p - Camera.CFrame.p).Unit * 600
	--else
	--	RayDirection = (Camera.CFrame --[[* CFrame.new(RandomXOffset, RandomYOffset, 0)]]).LookVector * FpsInfoModule:GetFpsInfo("RayLength") --600
	--end

	--if not RayDirection or not Mouse.Hit then -- CONTINUE
	--	RayDirection = Mouse.unitRay * FpsInfoModule:GetFpsInfo("RayLength") --600
	--end

	--print("Origin: ".. tostring(OriginPosition))
	--print("Direction: ".. tostring(RayDirection))

	-- Functions
	-- INIT
	local Result = workspace:Raycast(OriginCFrame.Position, RayDirection, raycastParams)
	local ResultPosition = nil

	Thickness = Thickness or WeaponInfo["RoundWidth"] or FpsInfoModule:GetFpsInfo("RayWidth")

	if Result then
		ResultPosition = Result.Position
	else
		ResultPosition = OriginCFrame.Position + RayDirection
	end

	if Thickness then
		local ToGoThrough = {-(Thickness / 2), (Thickness / 2)}
		local _Axis = {"X", "Y"}

		local Closest = nil

		if Result then
			Closest = (OriginCFrame.Position - --[[Result.Position]] ResultPosition).Magnitude
		else
			Closest = math.huge
		end

		for i, Axis in pairs(_Axis) do
			for _, Offset in pairs(ToGoThrough) do
				local VectorTable = {[Axis] = Offset}

				for j,c in pairs({"X", "Y", "Z"}) do
					if VectorTable[c] == nil then
						VectorTable[c] = 0
					end
				end

				local VectorToUnpack = Vector3.new(VectorTable.X, VectorTable.Y, VectorTable.Z)

				local _OriginalCFrame = (Camera.CFrame * CFrame.new(VectorToUnpack))
				local _CameraRayDirection = (_OriginalCFrame).LookVector * FpsInfoModule:GetFpsInfo("RayLength") --600

				local _CameraRayResult = workspace:Raycast(_OriginalCFrame.Position, _CameraRayDirection, raycastParams)

				if _CameraRayResult then
					local Distance = (_OriginalCFrame.Position - _CameraRayResult.Position).Magnitude

					if Distance < Closest then
						Closest = Distance
						Result = _CameraRayResult
					end
				end
			end
		end
	end

	if not Result then
		Result = {["Position"] = --[[CameraRayResult["Position"] --[[mouse.hit.p]] ResultPosition, ["Origin"] = OriginCFrame.Position}
	else
		Result = {["Position"] = ResultPosition, ["Instance"] = Result.Instance, ["Normal"] = Result.Normal, ["Material"] = Result.Material}
		--local OffsetCFrame = CFrame.new(RandomXOffset, RandomYOffset, 0)
		--[[local HitCFrame = CFrame.new(Result["Position"], Result["Position"] + Result["Normal"])
		local Distance = (Result["Position"] - BarrelPart.CFrame.p ).Magnitude

		local DropOffs = Distance / 30
		RandomXOffset *= DropOffs
		RandomYOffset *= DropOffs
		
		HitCFrame = HitCFrame * CFrame.new(RandomXOffset, RandomYOffset, 0)
		
		Result = 
		{
			["Instance"] = Result["Instance"],
			["Position"] = HitCFrame.p,
			["Normal"] = Result["Normal"]
		}]]

		--Result["Position"] = HitCFrame.p
	end	

	--print("RESULT")
	--print(Result)

	--[[DebugModule:Print("Result V")
	DebugModule:Print(Result)	]]

	return Result
end

local function FireRaycastProcedure(...)
	-- Functions
	-- INIT
	local raycastResult = FireCastRay(...)

	--print("Client Raycast result")
	--print(raycastResult)

	local PackagedResult = nil

	if raycastResult then
		PackagedResult = {Instance = raycastResult.Instance, Position = raycastResult.Position, Material = raycastResult.Material, Normal = raycastResult.Normal, Origin = raycastResult.Origin}
	else
		PackagedResult = {}
	end

	return PackagedResult
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

local function FireProcedure(ScatterShot, Charge)
	if not EquippedServerWeaponModel or not EquippedWeaponModel then
		return nil
	end

	-- Core
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)

	local TypeToFireProcedure = 
	{
		["Raycast"] = FireRaycastProcedure,
		["Projectile"] = FireRaycastProcedure
	}

	-- Functions
	-- INIT
	--DebugModule:Print(script.Name.. " | FireProcedure | WeaponName: ".. tostring(EquippedServerWeaponModel.Name))
	--DebugModule:Print(script.Name.. " | FireProcedure | RoundType: ".. tostring( WeaponInfo["RoundType"]))
	--DebugModule:Print(script.Name.. " | FireProcedure | RoundsInMag: ".. tostring(EquippedServerWeaponModel:GetAttribute("RoundsInMag")))

	if table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) ~= nil and EquippedServerWeaponModel:GetAttribute("Energy") <= 0 then
		return "Reload", Enum.UserInputState.Begin
	end

	if (table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) ~= nil and EquippedServerWeaponModel:GetAttribute("RoundsInMag") <= 0) or (table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) ~= nil and ( (EquippedServerWeaponModel:GetAttribute("CurrentEnergyUsage") >= EquippedServerWeaponModel:GetAttribute("MaxCharge") and not Charge) or EquippedServerWeaponModel:GetAttribute("Energy") <= 0)) then
		return "Reload", Enum.UserInputState.Begin
	end

	local PackagedResult = {}

	if not ScatterShot then
		PackagedResult = {TypeToFireProcedure[WeaponInfo["ProjectileType"]]()}
	else
		for i = 1, WeaponInfo["Scatter"] do
			--print("Looping scatter: ".. tostring(i))
			local Result = TypeToFireProcedure[WeaponInfo["ProjectileType"]]() 
			table.insert(PackagedResult, Result)
		end
	end

	coroutine.wrap(function()
		local Projectiles = nil

		if not ThirdPerson then
			Projectiles = FPSEffectsModule:ClientFireEffect(EffectsHandlerModule, EquippedWeaponModel, PackagedResult, nil, Charge)	
		else
			Projectiles = FPSEffectsModule:ClientFireEffect(EffectsHandlerModule, EquippedServerWeaponModel, PackagedResult, nil, Charge)
		end

		if WeaponInfo["ProjectileType"] == "Projectile" then
			for i, Projectile in pairs(Projectiles) do
				ProjectilesToCheck[Projectile] = {WeaponName = EquippedServerWeaponModel.Name, Connections = {}}
				table.insert(ProjectilesToCheck[Projectile]["Connections"], Projectile.Touched:Connect(function() end))
			end
		end
		--table.insert(ProjectilesToCheck, Projectile)
	end)()


	if --[[WeaponInfo["RoundType"] == "Plasma"]] table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) then
		EquippedServerWeaponModel:SetAttribute("CurrentEnergyUsage", math.clamp(EquippedServerWeaponModel:GetAttribute("CurrentEnergyUsage") + (WeaponInfo["MinimumEnergyConsumption"]), 0, EquippedServerWeaponModel:GetAttribute("MaxCharge")))
	end

	--CharacterProcessRemote:FireServer("Fire", EquippedServerWeaponModel, PackagedResult, nil, nil, Charge)
	
	coroutine.wrap(function()
		local Response = CharacterRequestSignal:InvokeServer("Fire", EquippedServerWeaponModel, PackagedResult, nil, nil, Charge)

		HandleFireResponse(Response)
	end)()
	
	coroutine.wrap(function()
		local Intensity = WeaponInfo["ShakeIntensity"]

		if Humanoid:GetAttribute("Ads") then
			Intensity /= 2			
		end

		CameraModule:CameraProcess("FOVOffset", true, Intensity / 2)
		CameraModule:CameraProcess("YAngleOffset", true, Intensity --[[* 2]]) -- RECOIL
		--CameraModule:CameraProcess("Shake", true, WeaponInfo["ShakeIntensity"], WeaponInfo["ShakeDuration"], "Fire", "Y", true)
	end)()	
end

local function ToggleHideCharacterPart(Part, Toggle)
	-- Functions
	-- MECHANICS
	local AllowedClasses = {"SurfaceGui", "Decal", "Texture", "Fire", "ParticleEmitter", "Smoke"}
	local EffectClasses = {"Fire", "ParticleEmitter", "Smoke"}

	if (not Part:IsA("BasePart") and not table.find(AllowedClasses, Part.ClassName)) or Part == Character.PrimaryPart then
		return nil
	end

	if ThirdPerson and Toggle then
		return nil
	end

	if EquippedWeaponModel then
		if Part:IsDescendantOf(EquippedWeaponModel) or Part:IsDescendantOf(CharacterViewModelsFolder) then
			return nil
		end
	end

	if table.find(EffectClasses, Part.ClassName) then
		if Part.Name == "ArmourEffect" then
			Part.Enabled = not Toggle
			return nil
		else
			return nil
		end
	end

	if Part:IsA("Texture") then
		UtilitiesModule:CreateElementCache(Part, {"Transparency"}, ElementsCache)
		if Toggle then
			Part.Transparency = 1
		else
			Part.Transparency = ElementsCache[Part]["Transparency"]
		end
		return nil
	end

	if Part:IsA("SurfaceGui") then
		Part.Enabled = not Toggle
		return nil
	end

	if not table.find(CharacterVisibleParts, Part.Name) then
		local FoundArmourDecal = Part:FindFirstChild("ArmourColour")


		UtilitiesModule:CreateElementCache(Part, {"Transparency"}, ElementsCache)
		if FoundArmourDecal then
			UtilitiesModule:CreateElementCache(FoundArmourDecal, {"Transparency"}, ElementsCache)
		end

		if Toggle then
			Part.Transparency = 1
			if FoundArmourDecal then
				FoundArmourDecal.Transparency = 1
			end
		else
			Part.Transparency = ElementsCache[Part]["Transparency"]
			if FoundArmourDecal then
				FoundArmourDecal.Transparency = ElementsCache[FoundArmourDecal]["Transparency"]
			end
		end
	end
end

function HideCharacter()
	-- Functions
	-- INIT
	for i, Part in pairs(Character:GetDescendants()) do
		local Success, Error = pcall(function()
			return ToggleHideCharacterPart(Part, true)
		end)

		if not Success then
			DebugModule:Print("FPSHandler | Error hiding part: ".. tostring(Part).. " | Error: ".. tostring(Error))
		end
	end
end

local function ShowCharacter()
	-- Functions
	-- INIT
	for i, Part in pairs(Character:GetDescendants()) do
		local Success, Error = pcall(function()
			return ToggleHideCharacterPart(Part, false)
		end)

		if not Success then
			DebugModule:Print("FPSHandler | Error showing part: ".. tostring(Part).. " | Error: ".. tostring(Error))
		end
	end

	for i, Part in pairs(Player:WaitForChild("Backpack"):GetDescendants()) do
		local Success, Error = pcall(function()
			return ToggleHideCharacterPart(Part, false)
		end)

		if not Success then
			DebugModule:Print("FPSHandler | Error showing part: ".. tostring(Part).. " | Error: ".. tostring(Error))
		end
	end
end

local function SetupMotors()
	-- Elements
	-- MODELS
	local GunModel = EquippedWeaponModel:FindFirstChild("Gun") --UtilitiesModule:WaitForChildTimed(EquippedWeaponModel, "Gun")

	if not GunModel then
		return nil
	end

	-- FOLDERS
	local MotorsFolder = GunModel:FindFirstChild("Motors")

	-- Functions
	-- INIT
	if not MotorsFolder then
		return nil
	end

	for i, PartNameFolder in pairs(MotorsFolder:GetChildren()) do
		local Part0 = EquippedWeaponModel:FindFirstChild(PartNameFolder.Name)

		for x, Motor6D in pairs(PartNameFolder:GetChildren()) do
			local MotorClone = Motor6D:Clone()
			MotorClone.Part0 = Part0
			MotorClone.Part1 = Motor6D:WaitForChild("Part1").Value
			MotorClone.Parent = Part0
		end
	end
end

local function ClearCache(LastCachedWeaponName)
	-- Functions
	-- INIT
	for i, ViewModel in pairs(CharacterViewModelsCacheFolder:GetChildren()) do
		if ViewModel.Name ~= LastCachedWeaponName and not table.find({Character:GetAttribute("Primary"), Character:GetAttribute("Secondary")}, ViewModel.Name) then
			--ViewModel:Destroy()
			DebrisModule:AddItem(ViewModel)
		end
	end
end

local function CacheOtherWeapon(NewArmViewModel, OtherWeaponType, WaitTillFinished)
	-- CORE
	local FinishedLoading = false
	local RequiredClient = false
	local RequiredServer = false
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))

	-- Functions
	-- INIT
	if not NewArmViewModel then
		if not GameModeInfo["Teams"] and not Player.Team then
			repeat
				task.wait()
			until Player.Team or not GameModeInfo["Teams"] 
		end

		NewArmViewModel = GetViewModelArms()
	end

	if not OtherWeaponType then
		OtherWeaponType = "Secondary"
	end

	local ArmsClone = NewArmViewModel:Clone()

	local OldGunInClone = ArmsClone:FindFirstChild("Gun")

	if OldGunInClone then
		OldGunInClone:Destroy()
	end

	local _GunInViewModel = GetViewModelGun(Character:GetAttribute(OtherWeaponType))
	--DebugModule:Print"Caching Weapon: ".. tostring(_GunInViewModel.Name))


	coroutine.wrap(function()
		--DebugModule:Print"Loading client gun")

		if _GunInViewModel then
			_GunInViewModel.Name = "Gun"
			_GunInViewModel.Parent = ArmsClone
		end

		ArmsClone.Name = Character:GetAttribute(OtherWeaponType)
		ArmsClone.Parent = CharacterViewModelsCacheFolder

		if not _GunInViewModel then
			RequiredClient = true
			DebugModule:Print(script.Name.. " | CacheOtherWeapon | No _GunInViewModel for Required Client! -> Not requiring module")
			return nil
		end

		local CoreFolder = UtilitiesModule:WaitForChildTimed(_GunInViewModel, "Core")
		local RequiredModule = require(UtilitiesModule:WaitForChildTimed(CoreFolder, "GunClient"))

		if RequiredModule.Initialise ~= nil then
			RequiredModule:Initialise()
		end

		CachedGunClientModule = RequiredModule

		RequiredClient = true

		--DebugModule:Print"Finished loading client gun")
	end)()


	DebugModule:Print(script.Name.. " | Waiting for secondary weapon: ".. tostring(Character:GetAttribute(OtherWeaponType)))
	local _SeverGunInViewModel = Player:WaitForChild("Backpack"):WaitForChild(Character:GetAttribute(OtherWeaponType)) --UtilitiesModule:WaitForChildTimed(Player:WaitForChild("Backpack"), Character:GetAttribute(OtherWeaponType))  --Player:WaitForChild("Backpack"):WaitForChild(Character:GetAttribute(OtherWeaponType))

	if _SeverGunInViewModel then
		coroutine.wrap(function()
			DebugModule:Print(script.Name.. " | Attempting to require server gun client for secondary weapon: ".. tostring(_SeverGunInViewModel))
			--DebugModule:Print"Loading server gun")
			local ServerCoreFolder = UtilitiesModule:WaitForChildTimed(_SeverGunInViewModel, "Core")

			local ServerModule = nil

			if ServerCoreFolder then
				ServerModule = UtilitiesModule:WaitForChildTimed(ServerCoreFolder, "GunClient") --ServerCoreFolder:WaitForChild("GunClient")
			end

			local ServerRequiredModule = nil 

			if ServerModule then
				ServerRequiredModule = require(ServerModule)
			end

			if not ServerRequiredModule then
				RequiredServer = true
				DebugModule:Print("FPSHandler | ServerRequiredModule is nil")
				return nil
			end

			if ServerRequiredModule.Initialise ~= nil then
				ServerRequiredModule:Initialise(Humanoid)
			end

			RequiredServer = true
			--DebugModule:Print"Finished loading server gun")
		end)()
	else
		DebugModule:Print("FPSHandler | CacheOtherWeapon | Cannot find other weapon in backpack!")
		RequiredServer = true
	end

	if WaitTillFinished then
		DebugModule:Print(script.Name.. " | CacheOtherWeapon | Waiting | RequiredClient: ".. tostring(RequiredClient).. " | RequiredServer: ".. tostring(RequiredServer))

		--local Count = 0

		if not RequiredClient or not RequiredServer then
			repeat
				--[[if Count % 100 == 0 then
					local Response = GameRequestSignal:InvokeServer("Main", "Respawn")
				end]]

				DebugModule:Print(script.Name.. " | CacheOtherWeapon | STILL WAITING TO REQUIRE | RequiredClient: ".. tostring(RequiredClient).. " | RequiredServer: ".. tostring(RequiredServer))
				task.wait()
				--Count += 1
			until (RequiredClient ~= nil and RequiredServer ~= nil) or not Character or not Humanoid
		end

		if DebugModule then
			DebugModule:Print(script.Name.. " | CacheOtherWeapon | Waiting | Finished requiring client / server for: ".. tostring(_SeverGunInViewModel))
		end		
	end

	return ArmsClone
end


function UnequipWeapon(_EquippedWeaponModel, _GunClientModule, _ServerGunClientModule)
	-- Functions
	-- INIT
	--_GunClientModule:Unequip()
	--_GunClientModule:End()
	IsUnequipping = true
	local Response = RequestFunctions["Unequip"](_EquippedWeaponModel.Name, _EquippedWeaponModel, _GunClientModule, _ServerGunClientModule)
	_GunClientModule:Hide()
	IsUnequipping = false
	return Response
end

function SwitchGrenade(GrenadeToSwitchTo)
	-- Functions
	-- INIT
	if Humanoid:GetAttribute("Grenade") or IsThrowing then
		return nil
	end

	SoundsModule:PlaySoundEffectByName("CharacterActions", "SwitchGrenade")
	CharacterProcessRemote:FireServer("SwitchGrenade", GrenadeToSwitchTo)
end

function SwitchWeapon(VariantToSwitchTo)
	LastSwitchTime = tick()
	local _LastSwitchTime = LastSwitchTime

	--DebugModule:Print("FPSHandler | Switching weapon!")

	if CharacterVehicleValue.Value then
		DebugModule:Print(script.Name.. " | Attempted to switch weapon in vehicle")
		return nil
	end

	if Character:GetAttributes()[VariantToSwitchTo] == "" then
		DebugModule:Print("FPSHandler | ".. tostring(VariantToSwitchTo).. " variant is just a blank string")
		return nil
	end

	if SwitchingWeapon then
		--DebugModule:Print("Already switching weapon!")
		--DebugModule:Print"Switching weapon. Droppped request")
		DebugModule:Print("FPSHandler | Already switching weapon")
		return nil
	end

	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))

	SwitchingWeapon = true
	Humanoid:SetAttribute("Melee", false)
	Humanoid:SetAttribute("Ads", false)
	--Humanoid:SetAttribute("Reload", false)
	CancelReload()

	-- FUNCTIONS
	-- INIT
	UtilitiesModule:DisconnectConnections(WeaponConnections)

	if GunClientModule then
		GunClientModule:StopFiring()
	end

	if ServerGunClientModule then
		ServerGunClientModule:StopFiring()
	end

	IsShooting = false
	Charging = false
	LastChargingTick = nil
	ShotCharged = false

	CharacterProcessRemote:FireServer("SwitchWeapon", VariantToSwitchTo)

	--DebugModule:Print"SWITCHING WEAPON TO: ".. tostring(VariantToSwitchTo))

	-- CORE	
	local EquippedWeaponType = VariantToSwitchTo or Character:GetAttribute("EquippedWeapon")

	if EquippedWeaponType ~= Character:GetAttribute("EquippedWeapon") then
		UnequipWeapon(EquippedWeaponModel, GunClientModule, ServerGunClientModule)
	end

	Character:SetAttribute("EquippedWeapon", EquippedWeaponType)

	--[[if Character:GetAttribute("EquippedWeapon") == VariantToSwitchTo then
		return nil
	end]]


	local OtherWeaponType = nil

	if EquippedWeaponType == nil then
		SwitchingWeapon = false
		return nil
	else
		if EquippedWeaponType == "Primary" then
			OtherWeaponType = "Secondary"
		else
			OtherWeaponType = "Primary"
		end
	end

	local TeamName = nil

	if GameModeInfo["Teams"] then
		TeamName = Player.Team.Name
	else
		TeamName = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour").Value.Name
	end

	local WeaponName = Character:GetAttribute(EquippedWeaponType)

	--DebugModule:Print"Weapon Name: ".. tostring(WeaponName)) --print("Weapon Name: ".. tostring(WeaponName))

	local NewArmViewModel = CharacterViewModelsCacheFolder:FindFirstChild(WeaponName)
	local GunInViewModel = nil

	if NewArmViewModel ~= nil then
		GunInViewModel = NewArmViewModel:FindFirstChild("Gun")
	end

	if not NewArmViewModel or not GunInViewModel then
		NewArmViewModel = GetViewModelArms()

		if WeaponName then
			GunInViewModel = GetViewModelGun(WeaponName)

			if GunInViewModel then
				GunInViewModel.Name = "Gun"
				GunInViewModel.Parent = NewArmViewModel
			end
		end

		NewArmViewModel.Name = WeaponName or "Arms"
	end

	--[[local NewWeaponViewModel = nil
	
	if WeaponName then
		NewWeaponViewModel = GetViewModel(WeaponName)
	end]]

	-- Functions
	-- INIT
	--[[if EquippedWeaponModel and GunClientModule then
		GunClientModule:Unequip()
		GunClientModule:End()
	end
	
	if EquippedWeaponModel then
		EquippedWeaponModel:Destroy()
	end]]

	if WeaponName ~= "Arms" then
		--DebugModule:Print"Firing Server Equip Weapon: ".. WeaponName)
		CharacterProcessRemote:FireServer("EquipWeapon", WeaponName)
	end

	coroutine.wrap(function()
		if WeaponName then
			local _EquippedServerWeaponModel = Character:WaitForChild(WeaponName) --UtilitiesModule:WaitForChildTimed(Character, WeaponName)

			if LastSwitchTime == _LastSwitchTime then
				EquippedServerWeaponModel = _EquippedServerWeaponModel
			end
		end
	end)()

	--print("New Weapon View Model: ".. tostring(--[[NewWeaponViewModel]] NewArmViewModel))
	--DebugModule:Print"New Weapon View Model: ".. tostring(--[[NewWeaponViewModel]] NewArmViewModel))

	if --[[NewWeaponViewModel]] NewArmViewModel ~= nil then

		if EquippedWeaponModel and EquippedWeaponModel.Name ~= "Arms" then
			--EquippedWeaponModel:Destroy()
			-- CACHE
			local Success, Error = pcall(function()
				EquippedWeaponModel.Parent = CharacterViewModelsCacheFolder
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | Switch Weapon | Error: ".. tostring(Error))
			end
		elseif not CharacterViewModelsCacheFolder:FindFirstChildOfClass("Model") then
			--DebugModule:Print"Caching other weapon: ".. tostring(Character:GetAttribute(OtherWeaponType)))
			if OtherWeaponType and Character:GetAttribute(OtherWeaponType) ~= "" then
				CacheOtherWeapon(NewArmViewModel, OtherWeaponType, true)
			end
			--ClearCache(Character:GetAttribute(OtherWeaponType))
		end

		ForceEmptyViewModelsFolder()
		ClearCache("")

		--[[NewWeaponViewModel]] NewArmViewModel.Parent = CharacterViewModelsFolder
		EquippedWeaponModel = NewArmViewModel
		--NewWeaponViewModel		
	else
		EquippedWeaponModel = nil
	end

	--DebugModule:Print("Setting Up Motors")
	SetupMotors()

	--DebugModule:Print("Updating Globals")
	if GunClientModule then
		GunClientModule:Hide()
	end

	UpdateGlobals()

	--DebugModule:Print("Hiding character")
	if not ThirdPerson then
		HideCharacter()
	end

	-- DIRECT
	if not EquippedServerWeaponModel then
		DebugModule:Print("FPSHandler | NO SERVER WEAPON MODEL")
		return nil
	end

	FPSServerModule:SwitchedWeapon()

	if EquippedWeaponModel and  EquippedServerWeaponModel:GetAttributes()["Camo"] and EquippedServerWeaponModel:GetAttributes()["Camo"] ~= "" then
		ObjectsModule:ObjectProcess("ApplyCamo", EquippedWeaponModel["Gun"], EquippedServerWeaponModel:GetAttribute("Camo"))
	end

	local Connection1 = EquippedServerWeaponModel:GetAttributeChangedSignal("Camo"):Connect(function()
		ObjectsModule:ObjectProcess("ApplyCamo" , EquippedWeaponModel["Gun"], EquippedServerWeaponModel:GetAttribute("Camo"))

		if ThirdPerson then
			if GunClientModule then
				GunClientModule:Hide(nil, true)
			end
		end
	end)

	table.insert(WeaponConnections, Connection1)
	table.insert(Connections, Connection1)

	IsShooting = false

	coroutine.wrap(function()
		if GunClientModule and GunClientModule.Equip ~= nil then
			--DebugModule:Print"Equipping gun client!")
			if ThirdPerson then
				GunClientModule:Hide(nil, true)
			end

			GunClientModule:Equip(ThirdPerson)

			if not ThirdPerson then
				GunClientModule:Show()
			else
				GunClientModule:Hide(nil, true)
			end
		end
	end)()

	if ServerGunClientModule and ServerGunClientModule.Equip ~= nil then
		--DebugModule:Print"Equipped gun server!")
		ServerGunClientModule:Equip()
	end

	task.wait(.1)

	if not EquippedServerWeaponModel then
		repeat
			DebugModule:Print(script.Name.. " | Switch Weapon | Waiting for server weapon model: ".. tostring(WeaponName))
			task.wait()
		until EquippedServerWeaponModel ~= nil or Humanoid.Health <= 0
	end
	
	
	if EquippedServerWeaponModel ~= nil then
		local FoundHighlight = EquippedServerWeaponModel:FindFirstChildOfClass("Highlight") --UtilitiesModule:WaitForChildOfClass(EquippedServerWeaponModel, "Highlight")

		if FoundHighlight then				
			local Success, Error = pcall(function()
				FoundHighlight.Enabled = false
				FoundHighlight.Adornee = nil
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | SwitchWeapon | Highlight | Error: ".. tostring(Error))
			end

			DebrisModule:AddItem(FoundHighlight)
		end
	end
	
	SwitchingWeapon = false

end


local function Fire(Scatter, FireType, _ChargedShot)
	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)

	-- Functions
	-- INIT
	if IsPerformingPhysicalAction() --[[or Humanoid:GetAttribute("Reload")]] --[[Humanoid:GetAttribute("Reload") or Humanoid:GetAttribute("Melee") or Humanoid:GetAttribute("Grenade")]] then
		return nil
	end

	if Humanoid:GetAttribute("Reload") then
		if not SettingsModule:GetSettingValue("Game", "ShootCancelsReload", true) or RoundTypesInfoModule:GetRoundTypeInfo(WeaponInfo["RoundType"])["CantReloadCancel"] then
			return nil
		else
			if table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
				if EquippedServerWeaponModel:GetAttribute("RoundsInMag") == 0 then
					return nil					
				end
			end

			local TimeNow = tick()
			local TimeSpan = TimeNow - LastReloadTime

			if TimeSpan < .3 then
				return nil
			end

			CancelReload()
		end
	end

	if SwitchingWeapon then
		return nil
	end

	if GunClientModule then	
		local Response, ResponseState = FireProcedure(Scatter, _ChargedShot)

		if Response == "Reload" then
			return Response, ResponseState
		end

		if GunClientModule then
			GunClientModule:Fire(Humanoid:GetAttribute("Ads"), FireType, ThirdPerson)
		end
	end
end

local function PerformClientAction(ActionName, ...)
	-- Functions
	-- INIT
	return RequiredClientModules[ActionName]:Initialise(FPSHandlerModule, ...)
end

function UpdateGlobals()
	-- CORE
	local AssociatedWeaponName = EquippedWeaponModel.Name

	-- Functions

	-- INIT
	----DebugModule:Print"Update Global Check 1")	
	if EquippedWeaponModel then
		local Success, Error = nil, nil

		if EquippedWeaponModel.Name ~= "Arms" then
			Success, Error = pcall(function()
				local GunModel = UtilitiesModule:WaitForChildTimed(EquippedWeaponModel, "Gun")
				--DebugModule:Print("Client Gun Model: ".. tostring(GunModel))				
				local CoreFolder = UtilitiesModule:WaitForChildTimed(GunModel, "Core")
				--DebugModule:Print("Client Gun Core Folder: ".. tostring(CoreFolder))
				local _GunClientModule = UtilitiesModule:WaitForChildTimed(CoreFolder, "GunClient")
				--DebugModule:Print("Gun Client Module: ".. tostring(_GunClientModule))

				--GunClientModule = require(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(EquippedWeaponModel, "Gun"), "Core"), "GunClient"))
				GunClientModule = require(_GunClientModule)				
			end)
		end

		FakeCameraPart = UtilitiesModule:WaitForChildTimed(EquippedWeaponModel, "FakeCamera")
		GunHumanoidRootPart = UtilitiesModule:WaitForChildTimed(EquippedWeaponModel, "HumanoidRootPart")

		if GunClientModule and Success then
			GunClientModule:Initialise()
		else
			GunClientModule = nil
			ServerGunClientModule = nil		
			--DebugModule:Print("Global Error: ".. tostring(Error))

			--DebugModule:PrintError, "Error")
		end
	end

	if AssociatedWeaponName ~= "Arms" then
		--coroutine.wrap(function()
		----DebugModule:Print"Update Global Check 2")
		if not EquippedServerWeaponModel or EquippedServerWeaponModel.Name ~= AssociatedWeaponName then
			EquippedServerWeaponModel = UtilitiesModule:WaitForChildTimed(Character, AssociatedWeaponName)

			if EquippedServerWeaponModel and EquippedServerWeaponModel.Name ~= AssociatedWeaponName then
				return nil
			end
		end
		----DebugModule:Print"Update Global Check 3")
		if EquippedServerWeaponModel and EquippedServerWeaponModel.Parent and EquippedServerWeaponModel.Name == AssociatedWeaponName then
			local ServerGunCoreFolder = UtilitiesModule:WaitForChildTimed(EquippedServerWeaponModel, "Core")
			--DebugModule:Print("Server Gun Core Folder: ".. tostring(ServerGunCoreFolder))			
			local ServerGunClientModuleInstance = ServerGunCoreFolder:WaitForChild("GunClient") --UtilitiesModule:WaitForChildTimed(ServerGunCoreFolder, "GunClient")
			--DebugModule:Print("Server Gun Client Module: ".. tostring(ServerGunClientModuleInstance).. " | Name: ".. tostring(ServerGunClientModuleInstance:GetFullName()).. " | Parent: ".. tostring(ServerGunClientModuleInstance.Parent))

			ServerGunClientModule = require(ServerGunClientModuleInstance)

			--local Success, Error = pcall(function()	#
			--ServerGunClientModule = require(ServerGunClientModuleInstance)
			--end)

				--[[if not Success then
					DebugModule:Print("Error: ".. tostring(Error))
				end]]		
			--ServerGunClientModule = require(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(EquippedServerWeaponModel, "Core"), "GunClient"))

			coroutine.wrap(function()
				if ServerGunClientModule then
					ServerGunClientModule:Initialise()
				end
			end)()
		else
			pcall(function()
				DebugModule:Print("FPSHandler | Cannot update Server Global v")
				DebugModule:Print("FPSHandler | EquippedServerWeaponModel: ".. tostring(EquippedServerWeaponModel))		
				DebugModule:Print("FPSHandler | EquippedServerWeaponModel Parent: ".. tostring(EquippedServerWeaponModel.Parent))
				DebugModule:Print("FPSHandler | AssociatedWeaponName: ".. tostring(AssociatedWeaponName))
				DebugModule:Print("FPSHandler | EquippedServerWeaponModel Name: ".. tostring(EquippedServerWeaponModel.Name))
			end)
		end
		--end)()
	else
		DebugModule:Print("FPSHandler | Server Associated Weapon Name is: Arms")
	end
	--DebugModule:Print("3")
end

local function UpdateZeroMark()
	-- Functions
	-- INIT
	if Humanoid.MoveDirection.Magnitude > 0 and BopZeroMark == nil then
		BopZeroMark = tick()
	else
		if Humanoid.MoveDirection.Magnitude == 0 and BopZeroMark then
			BopZeroMark = nil
		end
	end
end

local function UpdateBop()
	-- Functions
	-- INIT
	local Tick = nil --tick()

	if BopZeroMark ~= nil then
		Tick = tick() - BopZeroMark
	end

	if Humanoid.MoveDirection.Magnitude > 0 and BopZeroMark ~= nil then
		local XBop = math.cos(Tick * 5) * 0.15 --0.25
		local YBop = math.abs(math.sin(Tick * 5)) * 0.15 --0.25

		BopCFrame = BopCFrame:Lerp(CFrame.new(XBop, YBop, 0), FpsInfoModule:GetFpsInfo("BopLerpIntensity"))
	else
		BopZeroMark = Tick
		BopCFrame = BopCFrame:Lerp(CFrame.new(), 0.1)
	end
end

local function UpdateSway(DeltaTime)
	-- Functions
	-- INIT
	local MouseDelta = UserInputService:GetMouseDelta()
	SwaySpring:shove(Vector3.new(MouseDelta.X / 200, MouseDelta.Y / 200, 0))
	Sway = SwaySpring:update(DeltaTime)
end

function Draw()
	-- Functions
	-- INIT	
	local OriginalCFrame = nil --CFrame.new(HumanoidRootPart.CFrame.p + Vector3.new(0, (HumanoidRootPart.Size.Y / 4), 0)) * CFrame.Angles(0, math.rad(GlobalXCameraAngle), 0) * CFrame.Angles(math.rad(GlobalYCameraAngle), 0, 0)


	if CharacterVehicleValue.Value then
		local CharacterPlaceholderPart = CharacterVehicleValue.Value["CharacterPlaceholder"]

		OriginalCFrame = (CharacterPlaceholderPart.CFrame + Vector3.new(0, (HumanoidRootPart.Size.Y / 4), 0)) * CFrame.Angles(0, math.rad(GlobalXCameraAngle), 0) * CFrame.Angles(math.rad(GlobalYCameraAngle), 0, 0)
	else
		OriginalCFrame = CFrame.new(HumanoidRootPart.CFrame.p + Vector3.new(0, (HumanoidRootPart.Size.Y / 4), 0)) * CFrame.Angles(0, math.rad(GlobalXCameraAngle), 0) * CFrame.Angles(math.rad(GlobalYCameraAngle), 0, 0)
	end


	if not ThirdPerson and not CharacterVehicleValue.Value then
		OriginalCFrame *= CFrame.new(FpsInfoModule:GetFpsInfo("FirstPersonOffset"))
	else
		if not CharacterVehicleValue.Value then
			OriginalCFrame *= CFrame.new(FpsInfoModule:GetFpsInfo("ThirdPersonOffset"))
		else
			local GlobalAngles = ShortcutsModule:GetVehicleModule(CharacterVehicleValue.Value, "Client"):GetGlobals()

			if GlobalAngles then
				OriginalCFrame *= CFrame.Angles(0, math.rad(GlobalAngles.X), 0) * CFrame.Angles(math.rad(GlobalAngles.Y), 0, 0)
			end

			OriginalCFrame *= CFrame.new(VehiclesInfoModule:GetVehicleInfo(CharacterVehicleValue.Value.Name)["CameraOffset"])
		end
	end

	local CameraCFrame = OriginalCFrame:ToWorldSpace()	
	local FocusCFrame = OriginalCFrame:ToWorldSpace(CFrame.new(GlobalXCameraAngle, GlobalYCameraAngle, -10000))

	--local FieldOfView = Camera["FieldOfView"] + Camera:GetAttribute("FOVOffset")

	if FancyCameraValue.Value == "ON" and not ADSing and Humanoid.Health > 0 then
		if TweenDict and (Camera:GetAttributes()["FOVOffset"] or 0) >= 0 or Camera.FieldOfView ~= ShortcutsModule:GetBaseFieldOfView() then
			Camera.FieldOfView = (ShortcutsModule:GetBaseFieldOfView() + ((Camera:GetAttributes()["FOVOffset"] or 0) * 5))
		end
	end

	if not CharacterVehicleValue.Value then
		HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.CFrame.p, Vector3.new(FocusCFrame.p.X, HumanoidRootPart.CFrame.p.Y, FocusCFrame.p.Z))
	end

	--Camera.CFrame = CFrame.new(CameraCFrame.p, FocusCFrame.p) * CFrame.new(Camera:GetAttribute("Offset")) * CFrame.Angles(math.rad(Camera:GetAttribute("YAngleOffset") or 0), math.rad(Camera:GetAttribute("ZAngleOffset") or 0), math.rad(Camera:GetAttribute("XAngleOffset") or 0))

	local Distance = (LastPosition - HumanoidRootPart.Position).Magnitude	

	if Distance < 5 and FancyCameraValue.Value == "ON" then 
		Camera.CFrame = --[[Camera.CFrame:Lerp(]]CFrame.new(CameraCFrame.p, FocusCFrame.p) * CFrame.new(Camera:GetAttribute("Offset")) * CFrame.Angles(math.rad(Camera:GetAttribute("YOffset") or 0), math.rad(Camera:GetAttribute("ZOffset") or 0), math.rad(Camera:GetAttribute("XOffset") or 0))--[[, FpsInfoModule:GetFpsInfo("LerpIntensity"))]] * CFrame.new(-BopCFrame.p)
	else
		Camera.CFrame = CFrame.new(CameraCFrame.p, FocusCFrame.p) * CFrame.new(Camera:GetAttribute("Offset")) * CFrame.Angles(math.rad(Camera:GetAttribute("YOffset") or 0), math.rad(Camera:GetAttribute("ZOffset") or 0), math.rad(Camera:GetAttribute("XOffset") or 0)) * CFrame.new(-BopCFrame.p)
	end

	LastPosition = HumanoidRootPart.Position

	if GunHumanoidRootPart then
		GunHumanoidRootPart.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(180), 0) * BopCFrame * CFrame.Angles(0, -Sway.x / 2, Sway.y / 2)

		--if FancyCameraValue.Value == "ON" then
		GunHumanoidRootPart.CFrame *= CFrame.new(Vector3.new(0, 0, -(Camera:GetAttributes()["FOVOffset"] or 0)))
		--end

		--GunHumanoidRootPart.CFrame = GunHumanoidRootPart.CFrame:Lerp(Camera.CFrame * CFrame.Angles(0, math.rad(180), 0) * BopCFrame * CFrame.Angles(0, -Sway.x / 5, Sway.y / 5), 0.2)
	end
end

local function UpdateMotionBlur()
	-- Functions
	-- INIT
	local MouseDelta = UserInputService:GetMouseDelta()

	if SettingsModule:GetSettingValue("Video", "MotionBlur", true) then
		BlurEffect.Size = math.clamp((((MouseDelta.X + MouseDelta.Y) * (MouseDelta.X + MouseDelta.Y)) / 2) / 100, 0, FpsInfoModule:GetFpsInfo("MaxBlur")) + (BlurEffect:GetAttributes()["AdditionalBlur"] or 0)
	else
		BlurEffect.Size = 0
	end
end

-- MECHANICS
local function RemoveProjectile(ProjectilePart)
	-- Functions
	-- INIT
	if not ProjectilesToCheck[ProjectilePart] then
		if ProjectilePart then
			ProjectilePart:Destroy()
		end

		return nil
	end

	UtilitiesModule:DisconnectConnections(ProjectilesToCheck[ProjectilePart]["Connections"])
	ProjectilesToCheck[ProjectilePart] = nil

	if ProjectilePart then
		local BindableEvent = ProjectilePart:FindFirstChildOfClass("BindableEvent")

		if BindableEvent then
			BindableEvent:Fire()
		end
		--ProjectilePart:Destroy()
	end
end

local function UpdateProjectiles()
	-- INIT
	if UtilitiesModule:GetSizeOfDict(ProjectilesToCheck) <= 0 then
		return nil
	end

	-- Functions
	-- INIT
	
	for ProjectilePart, ProjectileInfo in pairs(ProjectilesToCheck) do
		if not ProjectilePart or not ProjectilePart.Parent then
			--ProjectilesToCheck[ProjectilePart] = nil
			RemoveProjectile(ProjectilePart)
			continue
		end		

		--DebugModule:Print(script.Name.. " | ProjectilePart: ".. tostring(ProjectilePart).. " | WeaponName: ".. tostring(ProjectileInfo["WeaponName"]))

		--[[local _OverlapParams = OverlapParams.new()
		_OverlapParams.FilterDescendantsInstances = {ProjectilePart}
		_OverlapParams.FilterType = Enum.RaycastFilterType.Blacklist]]

		--local _Region3 = UtilitiesModule:CreateRegion3FromPart(ProjectilePart)

		local TouchingParts = --[[workspace:FindPartsInRegion3(_Region3, {ProjectilePart}, 30)]] workspace:GetPartsInPart(ProjectilePart)

		local TouchingHumanoid = nil
		local PartToSend = nil
		local Touching = nil

		for x, Part in pairs(TouchingParts) do
			if Part:IsDescendantOf(Character) then
				continue
			end

			--DebugModule:Print(script.Name.. " | Touching part: ".. tostring(Part))
			Touching = true
			PartToSend = Part

			TouchingHumanoid = UtilitiesModule:GetHumanoidFromHit(Part)

			if TouchingHumanoid then
				break
			end
		end

		if Touching then
			--[[ProjectilesToCheck[ProjectilePart] = nil
			ProjectilePart:Destroy()]]
			RemoveProjectile(ProjectilePart)
		end

		if TouchingHumanoid then
			DebugModule:Print(script.Name.. " | Firing Server projectile hit!")
			--CharacterProcessRemote:FireServer("ProjectileHit", PartToSend, EquippedServerWeaponModel, ProjectilePart:GetAttribute("Charge"))
			coroutine.wrap(function()
				--[[DebugModule:Print("Firing Projectile Server V")
				DebugModule:Print("PartToSend: ".. tostring(PartToSend))
				DebugModule:Print("EquippedServerWeaponModel: ".. tostring(EquippedServerWeaponModel))
				DebugModule:Print("Charge: ".. tostring(ProjectilePart:GetAttribute("Charge")))]]
				local Response = CharacterRequestSignal:InvokeServer("ProjectileHit", PartToSend, EquippedServerWeaponModel, ProjectilePart:GetAttribute("Charge"))

				HandleFireResponse(Response)
			end)()
		end
	end
end

local function UpdateEnergyConsumption(NewEnergyTick)
	-- Functions
	-- INIT
	if not EquippedServerWeaponModel or EquippedServerWeaponModel:GetAttributes()["CurrentEnergyUsage"] == nil or EquippedServerWeaponModel:GetAttributes()["CurrentEnergyUsage"] == 0 or  EquippedServerWeaponModel:GetAttributes()["CurrentEnergyUsage"] >= EquippedServerWeaponModel:GetAttributes()["MaxCharge"] then
		return nil
	end

	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)


	if (NewEnergyTick - LastEnergyTick) >= 0.1 then
		if ShotCharged then
			EquippedServerWeaponModel:SetAttribute("CurrentEnergyUsage", EquippedServerWeaponModel:GetAttribute("MaxCharge"))
		else
			EquippedServerWeaponModel:SetAttribute("CurrentEnergyUsage", math.clamp(EquippedServerWeaponModel:GetAttributes()["CurrentEnergyUsage"] - (WeaponInfo["MinimumEnergyConsumption"] / 8), 0, EquippedServerWeaponModel:GetAttribute("MaxCharge")))
		end		
		LastEnergyTick = NewEnergyTick		
	end
end

local function UpdateCharge()
	-- Functions
	-- INIT
	if not Charging then
		return nil
	end

	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)

	local TimeNow = tick()

	if LastChargingTick ~= nil and WeaponInfo["ChargeTime"] and (TimeNow - LastChargingTick) >= WeaponInfo["ChargeTime"] and not ShotCharged then
		ShotCharged = true

		if GunClientModule then
			GunClientModule:Charge()
		end
	end

	if ShotCharged and (not LastChargeShakeTick or (TimeNow - LastChargeShakeTick) >= 0.1) then
		CameraModule:CameraProcess("Shake", true, 0.2, 0.1, "Charge", "X")
		LastChargeShakeTick = TimeNow
	end
end

local function Update(DeltaTime)
	-- CORE
	local NewMouseTick = tick()
	--local NewEnergyTick = tick()

	-- Functions
	-- INIT
	if not IsFPSLocked() and Humanoid and Humanoid.Health > 0 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
	else
		DebugModule:Print(script.Name.. " | FPSLocked - Can't centre mouse!")
	end	

	UpdateProjectiles()
	UpdateCharge()
	UpdateEnergyConsumption(--[[NewEnergyTick]] NewMouseTick)
	UpdateSway(DeltaTime)
	UpdateBop()
	UpdateMotionBlur()

	--if (NewMouseTick - LastMouseTick) >= FpsInfoModule:GetFpsInfo("TiltUpdateDelay") then
	UpdateTilt(NewMouseTick)
	--LastMouseTick = NewMouseTick
	--end
end

local function Render(DeltaTime)
	-- Functions
	-- INIT
	Update(DeltaTime)
	Draw(DeltaTime)
end

local function OnMouseMoved(Vector2Delta)
	-- CORE
	local MaxYAngle = FpsInfoModule:GetFpsInfo("MaxYAngle")

	-- Functions
	-- INIT
	GlobalXCameraAngle -= (Vector2Delta.X --[[* FpsInfoModule:GetFpsInfo("MouseSensitivity")]])
	GlobalYCameraAngle = math.clamp((GlobalYCameraAngle - Vector2Delta.Y --[[* FpsInfoModule:GetFpsInfo("MouseSensitivity")]]), -MaxYAngle, MaxYAngle)
end

function UpdateTilt(NewMouseTick)
	-- CORE
	local MousePosition = Mouse.Hit.p
	Neck.MaxVelocity = 1 / 3

	if not Neck or not Waist or not UpperTorso or not Head then
		return nil
	end

	--local UpperTorsoLookVector = (UpperTorso.CFrame * CFrame.Angles(0, math.rad(90), 0)).lookVector

	-- Functions
	-- INIT
	--local DeltaY = Camera.CFrame.LookVector.Y

	--CharacterPhysicsProcessRemote:FireServer("UpdateTilt2", math.floor(DeltaY * 100) / 100)

	local NewNeckC0 = nil
	local NewWaistC0 = nil

	if MousePosition then
		local Distance = (Head.Position - MousePosition).Magnitude
		local Difference = (Head.CFrame.Y - MousePosition.Y)

		NewNeckC0 = NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), 0, 0) 
		NewWaistC0 = WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), 0, 0) 
		--Neck.C0 = Neck.C0:Lerp(NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), 0, 0), 0.25)
		--Waist.C0 = Waist.C0:Lerp(WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), 0 , 0), 0.25)
	else
		NewNeckC0 = NeckOriginC0
		NewWaistC0 = NewWaistC0
		--Neck.C0 = NeckOriginC0
		--Waist.C0 = WaistOriginC0
	end

	--local NeckX, NeckY, NeckZ = NewNeckC0:ToEulerAnglesXYZ()
	--local WaistX, WaistY, WaistZ = NewWaistC0:ToEulerAnglesXYZ()

	if NewNeckC0 ~= LastNeckC0 or NewWaistC0 ~= LastWaistC0 then

		Neck.C0 = NewNeckC0
		Waist.C0 = NewWaistC0

		if (NewMouseTick - LastMouseTick) >= FpsInfoModule:GetFpsInfo("TiltUpdateDelay") then
			CharacterPhysicsProcessRemote:FireServer("UpdateTilt4", NewNeckC0, NewWaistC0)
			LastMouseTick = NewMouseTick
		end
		--CharacterPhysicsProcessRemote:FireServer("UpdateTilt3", Vector3.new(NeckX, NeckY, NeckZ), Vector3.new(WaistX, WaistY, WaistZ))
	end

	LastNeckC0 = NewNeckC0
	LastWaistC0 = NewWaistC0
end

local function ChangeFPSMode()
	-- CORE
	ThirdPerson = SettingsModule:GetSettingValue("Game", "ThirdPerson", true)

	if ThirdPerson then
		GunClientModule:Hide()
		ShowCharacter()
	else
		GunClientModule:Show()
		HideCharacter()
	end
end

local function SetupFPSPostServerLoad()
	-- Functions
	-- INIT
	InterfacesModule:UnloadPage("Custom", "Died")
	InterfacesModule:UnloadPage("Custom", "Loading")

	if not InterfacesModule:IsPageOpen("Custom", "Hud") and not InterfacesModule:IsPageOpen("Custom", "Multiplayer") then
		InterfacesModule:LoadPage("Custom", "Hud", true)
	elseif InterfacesModule:IsPageOpen("Custom", "Hud") then
		local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

		if HudGuiModule then
			HudGuiModule:End()
			HudGuiModule:Initialise()
		end
	end

	local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	-- Functions
	-- INIT
	ControlsModule:Enable()
	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	HudModule:ShowCursor()

	CameraModule:ResetCamera()
	Camera.CameraType = Enum.CameraType.Scriptable
	RunService:BindToRenderStep("FPSHandle", Enum.RenderPriority.Character.Value, Render)
end

local function SetupFPSPreServerLoad()
	-- Functions
	-- INIT
	--task.wait()

	table.insert(InstanceCache, _SpringModuleInstance)

	UnbindFromRenderStepped()

	if not Character then
		return nil
	end

	repeat
		task.wait()
	until --[[Player.Team and Player.Team.Name ~= "Neutral"]]	--[[and Character:GetAttributes()["ServerLoaded"]]--[[and]] Character:GetAttributes()["EquippedWeapon"] ~= nil and Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")] ~= nil and Character:GetAttributes()["Primary"] ~= nil and Character:GetAttributes()["Secondary"] ~= nil
	UnbindFromRenderStepped()
	--CacheOtherWeapon(nil, nil, true)
	--HandleTilt()
	SwitchWeapon(Character:GetAttributes()["EquippedWeapon"] or "Primary")
	--InterfacesModule:UnloadPage("Custom", "Died")
	--InterfacesModule:UnloadPage("Custom", "Loading")
	--[[if not InterfacesModule:IsPageOpen("Custom", "Hud") and not InterfacesModule:IsPageOpen("Custom", "Multiplayer") then
		InterfacesModule:LoadPage("Custom", "Hud", true)
	elseif InterfacesModule:IsPageOpen("Custom", "Hud") then
		local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
		
		if HudGuiModule then
			HudGuiModule:End()
			HudGuiModule:Initialise()
		end
	end]]

	Humanoid.AutoRotate = false

	ThirdPerson = SettingsModule:GetSettingValue("Game", "ThirdPerson", true)

	coroutine.wrap(function()
		local FoundClientCharacter = workspace:WaitForChild("Dump")["Client"]:FindFirstChildOfClass("Model")

		if FoundClientCharacter then
			DebrisModule:AddItem(FoundClientCharacter)
		end
	end)()

	if not ThirdPerson then
		HideCharacter()	
	end

	-- Modules
	--local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	-- Functions
	-- INIT
	--HudModule:ShowCursor()
	GlobalXCameraAngle = 0
	GlobalYCameraAngle = 0

	BopCFrame = CFrame.new(0, 0, 0)
	Sway = {x = 0, y = 0}
end

local function HasReloaded()
	-- CORE
	local _EquippedWeaponModel = EquippedWeaponModel

	-- Functions
	-- INIT
	repeat
		task.wait()
	until FPSServerModule:HasReloaded() or not _EquippedWeaponModel or _EquippedWeaponModel ~= EquippedWeaponModel or Humanoid.Health <= 0
	return true
end

local function HasUnequipped(WeaponName)
	-- Functions
	-- INIT
	if not FPSServerModule:HasUnequipped() then
		repeat
			if WeaponName and EquippedWeaponModel then
				if WeaponName ~= EquippedWeaponModel.Name then
					break
				end
			end

			task.wait()
		until FPSServerModule:HasUnequipped() or Humanoid.Health <= 0
	end
	return true
end

-- CORE FUNCTIONS
local ProcessFunctions = 
	{
		["ResetEnergyUsage"] = function()
			EquippedServerWeaponModel:SetAttribute("CurrentEnergyUsage", 0)	
		end,		
		["UnequipGun"] = function()
			if not IsUnequipping then
				return UnequipWeapon(EquippedWeaponModel, GunClientModule, ServerGunClientModule)	
			end		
		end,
	}

local CharacterRequestFunctions = 
	{
		["HasLoaded"] = function()
			--DebugModule:Print"LOADING CHARACTER CLIENT")
			repeat
			task.wait()
		until IsLoaded
			return true
		end,
		["IsSwitchingWeapon"] = function()
			return SwitchingWeapon	
		end,
	}

RequestFunctions = 
	{
		["HasReloaded"] = function()
			return HasReloaded()
		end,
		["HasUnequipped"] = function(...)
			return HasUnequipped(...)
		end,
		---------------------
		["DrinkPerk"] = function(DrinkName)
			return PerformClientAction("DrinkPerk", DrinkName) --DrinkPerk(DrinkName)
		end,
		["ThrowGrenade"] = function()
			return FPSServerModule:Request("ServerThrowGrenade", FPSHandlerModule)	
		end,
		["Melee"] = function()
			return FPSServerModule:Request("ServerMelee", FPSHandlerModule) --ServerMelee()
		end,
		["Unequip"] = function(WeaponName, _EquippedWeaponModel, _GunClientModule, _ServerGunClientModule)
			return FPSServerModule:Request("ServerUnequip", FPSHandlerModule, WeaponName, _EquippedWeaponModel, _GunClientModule, _ServerGunClientModule)--ServerUnequip()
		end,
		["Reload"] = function()
			return FPSServerModule:Request("ServerReload", FPSHandlerModule)--ServerReload()
		end,
		["Fire"] = function()
			return FPSServerModule:Request("ServerFire", FPSHandlerModule, ThirdPerson) --ServerFire()
		end,
	}

-- MECHANICS
function UnbindFromRenderStepped()
	-- CORE
	local BindsToUnbind = {"FPSHandle", "DeathCamera", "Radar", "FPSCounter", "SpartanRender", "ForceFPSHandle"}

	-- Functions
	-- INIT
	for i, BindName in pairs(BindsToUnbind) do
		RunService:UnbindFromRenderStep(BindName)
	end
end

local function OnCharacterRequestSignalInvoked(FunctionName, ...)
	-- Functions
	-- INIT
	return CharacterRequestFunctions[FunctionName](...)
end

local function OnGunRequestSignalInvoked(FunctionName, ...)
	-- Functions
	-- INIT
	return RequestFunctions[FunctionName](...)
end

--[[local function LoadAnimations()
	-- Functions
	-- INIT
	for AnimationName, AnimationInfo in pairs(CharacterAnimationsInfoModule) do
		local AnimationInstance = Instance.new("Animation")
		AnimationInstance.Name = AnimationName
		AnimationInstance.AnimationId = AnimationInfo.Id
		
		AnimationToLoad[AnimationName] = Humanoid:LoadAnimation(AnimationInstance)
	end
end]]

-- DIRECT
function FPSHandlerModule.SwitchGrenade(NilParam, VariantToSwitchTo)
	return SwitchGrenade(VariantToSwitchTo)
end

function FPSHandlerModule.SwitchWeapon(NilParam, VariantToSwitchTo)
	local Success, Error  = pcall(function()
		return SwitchWeapon(VariantToSwitchTo)
	end)

	if Success then
		return Error
	else
		if DebugModule then
			DebugModule:Print("Error | Switch Weapon: ".. tostring(Error))
		end
	end
end

function FPSHandlerModule.Dead()
	---- Functions
	---- INIT
	PerformClientAction("Dead")

	--if Dying then
	--	return nil
	--end

	--Dying = true

	--Humanoid:SetAttribute("Ads", false)
	--UnbindFromRenderStepped()
	--UtilitiesModule:CancelTween(Camera, TweenDict)

	--local RequiredModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	--if RequiredModule and SharedGameFolder:GetAttribute("GameMode") ~= "" and SharedGameFolder:GetAttribute("Map") ~= "" and SharedGameFolder:GetAttribute("GameTime") > 0 then
	--	if not InterfacesModule:IsPageOpen("Custom", "Multiplayer") and not ReturningToMenu then
	--		RequiredModule:Death(GameRequestSignal:InvokeServer("Main", "Respawn"))
	--		--DebugModule:Print("Death Camera")
	--		EffectsHandlerModule:FPSEffectProcess("Death", Character)
	--	else
	--		InterfacesModule:LoadPage("Custom", "Loading", true)
	--		GameRequestSignal:InvokeServer("Main", "Undeploy")
	--	end
	--end

	----FPSEffectsModule:EffectProcess("Death", EffectsHandlerModule)

	--if Humanoid then
	--	return UtilitiesModule:UnloadAnimations(Humanoid:GetPlayingAnimationTracks())
	--end
end

function FPSHandlerModule.FireCastRay(NilParam, ...)
	return FireRaycastProcedure(...)
end

function FPSHandlerModule.Charge()
	-- Functions
	-- INIT
	LastChargingTick = tick()
	Charging = true
end

function FPSHandlerModule.Fire()
	-- CORE
	local Firing = true
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeaponModel.Name)

	FireCustomConnection = CustomConnection

	local _ShotCharged = ShotCharged
	local _LastChargingTick = LastChargingTick
	local _Charging = Charging

	ShotCharged = nil
	LastChargingTick = nil
	Charging = nil

	if GunClientModule then
		GunClientModule:StopCharge()
	end

	-- Functions
	-- DIRECT
	FPSHandlerModule.StopFiring = nil -- Delete previous

	function FPSHandlerModule.StopFiring()
		-- Functions
		-- INIT
		Firing = false
	end

	-- INIT
	if not EquippedServerWeaponModel then
		return nil
	end

	if IsShooting then
		return nil
	end

	local TimeNow = tick()

	local Response, ResponseState = nil, nil
	local FireRate = 1 / (EquippedServerWeaponModel:GetAttribute("FireRate") or 1)

	if CharacterDrinksFolder:FindFirstChild("Double Tap") then
		FireRate /= 2
	end

	if WeaponInfo and WeaponInfo["Type"] and LastShotWeaponName == Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")] then
		--if table.find({"Automatic", "Semi Automatic", "ScatterShot"}, WeaponInfo["Type"]) then
		if TimeNow - LastShotTime < FireRate then
			return nil
		end
		--else

		--end
	end

	IsShooting = true

	LastShotWeaponName = Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")]
	LastShotTime = tick()

	local GunFiring = EquippedWeaponModel

	if WeaponInfo and WeaponInfo["Type"] == "Automatic" then
		repeat
			Response, ResponseState = Fire(nil, WeaponInfo["Type"], _ShotCharged)

			if Response == "Reload" then
				UtilitiesModule:DisconnectCustomConnections({CustomConnection})
			end			
			if Response and ResponseState then
				break
			end

			task.wait(FireRate)
		until not Firing or not CustomConnection or not CustomConnection.Value or EquippedWeaponModel ~= GunFiring
	elseif WeaponInfo["Type"] == "Burst" then
		for i = 1, 3 do
			Response, ResponseState = Fire(nil, WeaponInfo["Type"], _ShotCharged)

			if Response and ResponseState then
				break
			end

			task.wait(FireRate / 5)
		end
		task.wait(FireRate)
	elseif WeaponInfo["Type"] == "Semi Automatic" then
		Response, ResponseState = Fire(nil, WeaponInfo["Type"], _ShotCharged)
		task.wait(FireRate)
	elseif WeaponInfo["Type"] == "ScatterShot" then
		Response, ResponseState = Fire(true, WeaponInfo["Type"], _ShotCharged)
		task.wait(FireRate)
	elseif WeaponInfo["Type"] == "Melee" then
		Response, ResponseState = PerformClientAction("Melee") --Melee()
	end

	if Response == "Reload" then
		UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	end

	if GunClientModule then
		GunClientModule:StopFiring()
	end

	if ServerGunClientModule then
		ServerGunClientModule:StopFiring()
	end

	IsShooting = false

	if Response and ResponseState then
		return Response, ResponseState
	end
end

function FPSHandlerModule.ThrowGrenade()
	local Success, Error = pcall(function()
		return PerformClientAction("ThrowGrenade") --ThrowGrenade()
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | ThrowGrenade: ".. tostring(Error))
	end
end

function FPSHandlerModule.Melee()
	local Success, Error = pcall(function()
		return PerformClientAction("Melee") --Melee()
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | Melee: ".. tostring(Error))
	end
end

function FPSHandlerModule.CancelReload()
	return CancelReload()
end

function FPSHandlerModule.Reload()
	local Success, Error = pcall(function()
		return PerformClientAction("Reload") --Reload()
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | Reload: ".. tostring(Error))
	end
end

function FPSHandlerModule.Crouch()
	local Success, Error = pcall(function()
		return PerformClientAction("Crouch")
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | Crouch: ".. tostring(Error))
	end
end

function FPSHandlerModule.StopCrouch()
	local Success, Error = pcall(function()
		return PerformClientAction("StopCrouch")
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | Stop Crouch: ".. tostring(Error))
	end
end

function FPSHandlerModule.CancelActionSound(NilParam, ...)
	return CancelActionSound(...)
end

function FPSHandlerModule.UnbindFromRenderStepped()
	return UnbindFromRenderStepped()
end

function FPSHandlerModule.CanReload()
	return CanReload()
end

function FPSHandlerModule.ResetCharacterVelocity()
	return ResetCharacterVelocity()
end

function FPSHandlerModule.SetADSing(NilParam, Value)
	ADSing = Value
end

function FPSHandlerModule.SetLastSwitchTime(NilParam, Value)
	LastSwitchTime = Value
end

function FPSHandlerModule.SetLastMouseTick(NilParam, Value)
	LastMouseTick = Value
end

function FPSHandlerModule.SetLastChargingTick(NilParam, Value)
	LastChargingTick = Value
end

function FPSHandlerModule.SetShotCharged(NilParam, Value)
	ShotCharged = Value
end

function FPSHandlerModule.SetDrinking(NilParam, Value)
	--Drinking = Value // DEPRECATED
end

function FPSHandlerModule.SetDying(NilParam, Value)
	Dying = Value
end

function FPSHandlerModule.SetLastReloadTime(NilParam, Value)
	LastReloadTime = Value
end

function FPSHandlerModule.SetEquippedWeaponModel(NilParam, Value)
	EquippedWeaponModel = Value
end

function FPSHandlerModule.SetFiringCustomConnection(NilParam, Value)
	FireCustomConnection = Value
end

function FPSHandlerModule.SetIsThrowing(NilParam, Value)
	IsThrowing = Value
end

function FPSHandlerModule.SetIsShooting(NilParam, Value)
	IsShooting = Value
end

function FPSHandlerModule.SetGlobalYCameraAngle(NilParam, Value)
	GlobalYCameraAngle = Value
end

function FPSHandlerModule.SetGlobalXCameraAngle(NilParam, Value)
	GlobalXCameraAngle = Value
end

function FPSHandlerModule.SetReturningToMenu(NilParam, Value)
	if Value then
		if ControlsModule then
			ControlsModule:Disable()
		end
	end

	ReturningToMenu = Value
end

function FPSHandlerModule.IsPerformingPhysicalAction(NilParam, ...)
	return IsPerformingPhysicalAction(...)
end

function FPSHandlerModule.FireRaycastProcedure(NilParam, ...)
	return FireRaycastProcedure(...)
end

-- ACCESSORS
function FPSHandlerModule.GetFPSServerModule()
	return FPSServerModule
end

function FPSHandlerModule.GetThirdPerson()
	return ThirdPerson
end

function FPSHandlerModule.GetCamera()
	return ShortcutsModule:GetCamera()
end

function FPSHandlerModule.IsFPSLocked()
	return IsFPSLocked()
end

function FPSHandlerModule.IsSwitchingWeapon()
	return SwitchingWeapon
end

function FPSHandlerModule.GetTweenDict()
	return TweenDict
end

function FPSHandlerModule.GetRequestFunctions()
	return RequestFunctions
end

function FPSHandlerModule.GetConnections()
	return Connections
end

function FPSHandlerModule.GetFireCustomConnection()
	return FireCustomConnection
end

function FPSHandlerModule.GetIsUnequipping()
	return IsUnequipping
end

function FPSHandlerModule.GetEquippedServerWeaponModel()
	return EquippedServerWeaponModel
end

function FPSHandlerModule.GetEquippedWeaponModel()
	return EquippedWeaponModel
end

function FPSHandlerModule.GetGunClientModule()
	return GunClientModule
end

function FPSHandlerModule.GetServerGunClientModule()
	return ServerGunClientModule
end

--
function FPSHandlerModule.GetIsThrowing()
	return IsThrowing
end

function FPSHandlerModule.GetIsShooting()
	return IsShooting
end

function FPSHandlerModule.GetSwitchingWeapon()
	return SwitchingWeapon
end

function FPSHandlerModule.GetActionToSound()
	return ActionToSound
end

function FPSHandlerModule.GetADSing()
	return ADSing
end

function FPSHandlerModule.GetDying()
	return Dying
end

function FPSHandlerModule.GetReturningToMenu()
	return ReturningToMenu
end

function FPSHandlerModule.GetIsLoaded()
	return IsLoaded
end

function FPSHandlerModule.IsLoaded()
	return IsLoaded
end

function FPSHandlerModule.Initialise(NilParam, Force)
	-- Functions
	-- INIT
	DebugModule:Print("Initialising FPS Handler | time: ".. tostring(tick()))
	--DebugModule:Print"FPS HANDLE INIT PHASE 1")

	if InterfacesModule:IsPageOpen("Custom", "Hud") and not Force then
		return FPSHandlerModule:End(true)
	end

	GunRequestSignal.OnClientInvoke = OnGunRequestSignalInvoked
	CharacterRequestSignal.OnClientInvoke = OnCharacterRequestSignalInvoked

	local LastHealth = Humanoid.Health
	local LastShield = Humanoid:GetAttribute("Shield")

	--Instance.new("Animator", Humanoid)
	--DebugModule:Print"FPS HANDLE INIT PHASE 2")

	if not InterfacesModule:IsPageOpen("Custom", "Notifications") then
		InterfacesModule:LoadPage("Custom", "Notifications", true)
	end

	if not InterfacesModule:IsPageOpen("Custom", "Console") then
		InterfacesModule:LoadPage("Custom", "Console", true)
	end

	local ConsoleModule = InterfacesModule:GetUiModuleFromType("Custom", "Console")

	if ConsoleModule then
		ConsoleModule:ChangeMode("Main")
	end
	--ClientMapsModule:UnloadAllClientMaps()

	Camera = ShortcutsModule:GetCamera()

	--DebugModule:Print"FPS HANDLE INIT PHASE 3")

	--SetupFPS()
	SetupFPSPreServerLoad()

	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	if HudGuiModule then
		HudGuiModule:HudProcess("GunInfo", "UpdateCursor")
	end

	--DebugModule:Print"FPS HANDLE INIT PHASE 4")


	-- DIRECT
	local Connection0 = MouseCameraEvent.Event:Connect(OnMouseMoved)

	--local Connection0 = Mouse.Move:Connect(OnMouseMoved)
	--local Connection1 = UserInputService.InputChanged:Connect(onJoystickMoved)
	--local Connection2 = UserInputService.TouchMoved:Connect(onTouchMoved)
	--local Connection3 = UserInputService.TouchPan:Connect(onMobilePanned)
	--[[local Connection2 = Humanoid:GetAttributeChangedSignal("Melee"):Connect(function()
		--return Melee()
	end)]]

	--[[local Connection3 = Character:GetAttributeChangedSignal("EquippedWeapon"):Connect(function()
		--return SwitchWeapon()
	end)]]

	local Connection4 = Character.DescendantAdded:Connect(function(Descendant)
		if EquippedWeaponModel then
			return ToggleHideCharacterPart(Descendant, true) --HideCharacterPart(Descendant)
		end
	end)

	--[[local Connection5 = Character.ChildAdded:Connect(function(Child)
		if EquippedWeaponModel then
			return ToggleHideCharacterPart(Child, true) --HideCharacterPart(Child)
		end
	end)]]

	--[[local Connection6 = Humanoid:GetAttributeChangedSignal("Reload"):Connect(function()
		--return Reload()
	end)]]

	local Connection7 = Humanoid:GetAttributeChangedSignal("ShieldRegen"):Connect(function()
		if Humanoid:GetAttribute("ShieldRegen") then
			--[[if not HudGuiModule then
				HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
			end
			
			if HudGuiModule then
				DebugModule:Print(script.Name.. " | Doing heal effect")
				HudGuiModule:HudProcess("HealthBar", "Heal")
			end]]

			return FPSEffectsModule:ClientShieldRegenEffect(EffectsHandlerModule, true)
		else
			return FPSEffectsModule:ClientShieldRegenEffect(EffectsHandlerModule, false)
		end
	end)

	local Connection8 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if not LastHealth then
			LastHealth = Humanoid.Health

			if not LastHealth then
				return nil
			end
		end

		if LastHealth > Humanoid.Health then
			coroutine.wrap(function()
				CameraModule:CameraProcess("Shake", true, 0.75, 0.1, "Hurt", "X")
			end)()
			FPSServerModule:Request("ServerFlinch")
		end

		LastHealth = Humanoid.Health
	end)

	local Connection9 = Humanoid:GetAttributeChangedSignal("Shield"):Connect(function()
		if not LastShield then
			LastShield = Humanoid:GetAttribute("Shield")

			if not LastShield then
				return nil
			end
		end

		if LastShield > Humanoid:GetAttribute("Shield") then
			coroutine.wrap(function()
				CameraModule:CameraProcess("Shake", true, 0.75, 0.1, "Hurt", "X")
			end)()
			FPSServerModule:Request("ServerFlinch")
		end

		LastShield = Humanoid:GetAttribute("Shield")
	end)

	local Connection10 = Humanoid:GetAttributeChangedSignal("Ads"):Connect(function()
		--DebugModule:Print("FPSHandler | ADS CHANGED -> Firing ToggleAds function | Ads: ".. tostring(Humanoid:GetAttribute("Ads")))
		--ToggleAds(Humanoid:GetAttribute("Ads"))
		PerformClientAction("ToggleADS", Humanoid:GetAttribute("Ads"))
	end)

	local Connection11 = Character:GetAttributeChangedSignal("Primary"):Connect(function()
		if Character:GetAttribute("EquippedWeapon") == "Primary" then
			return SwitchWeapon("Primary")
		end
	end)

	local Connection12 = Character:GetAttributeChangedSignal("Secondary"):Connect(function()
		if Character:GetAttribute("EquippedWeapon") == "Secondary" then
			return SwitchWeapon("Secondary")
		end
	end)

	local Connection13 = SettingsModule:GetSettingValueInstance("Game", "ThirdPerson"):GetPropertyChangedSignal("Value"):Connect(function()
		return ChangeFPSMode()
	end)

	local Connection14 = InterfaceRemote.Event:Connect(function(ActionName, ...)
		if ActionName == "GrenadeSwitch" then
			SwitchGrenade(...)
		end
	end)

	local Connection15 = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		return UpdateZeroMark()
	end)

	--[[local Connection15 = Character:GetAttributeChangedSignal("WaistAngle"):Connect(function()
		return UpdateClientTilt()
	end)]]

	--[[local Connection15 = CharacterVehicleValue:GetPropertyChangedSignal("Value"):Connect(function()
		return SwitchVehicle(CharacterVehicleValue.Value)
	end)]]

	-- Connections
	table.insert(Connections, Connection0)
	--table.insert(Connections, Connection1)
	--table.insert(Connections, Connection2)
	--table.insert(Connections, Connection3)
	table.insert(Connections, Connection4)	
	--table.insert(Connections, Connection5)
	--table.insert(Connections, Connection6)
	table.insert(Connections, Connection7)
	table.insert(Connections, Connection8)
	table.insert(Connections, Connection9)
	table.insert(Connections, Connection10)
	table.insert(Connections, Connection11)
	table.insert(Connections, Connection12)
	table.insert(Connections, Connection13)
	table.insert(Connections, Connection14)
	--table.insert(Connections, Connection15)
	table.insert(Connections, Connection15)

	-- INIT
	--LoadAnimations()

	IsLoaded = true
	--DebugModule:Print("FPS Handler Initialised!")

	script:SetAttribute("Enabled", true)

	repeat
		task.wait()
	until Character:GetAttributes()["ServerLoaded"] or not Character
	SetupFPSPostServerLoad()
	--RunService:BindToRenderStep("FPSHandle", Enum.RenderPriority.Character.Value, Render)
end

function FPSHandlerModule.ServerProcess(NilParam, FunctionName, ...)
	return ProcessFunctions[FunctionName](...)
end

function FPSHandlerModule.ForceDrawCamera()
	-- Functions
	-- INIT
	RunService:BindToRenderStep("ForceFPSHandle", Enum.RenderPriority.Character.Value, Render)
end

function FPSHandlerModule.UnForceDrawCamera()
	-- Functions
	-- INIT
	RunService:UnbindFromRenderStep("ForceFPSHandle")
end

function FPSHandlerModule.GarbageCollect()
	-- Functions
	-- INIT
	EquippedWeaponModel = nil
	EquippedServerWeaponModel = nil

	IsShooting = nil
	SwitchingWeapon = nil
	InstanceCache = nil
	AnimationToLoad = nil
	CharacterVisibleParts = nil
	SwaySpring = nil
	ControlsModule = nil
	TweenDict = nil
	Connections = nil
	WeaponConnections = nil
	CustomConnections = nil
	ElementsCache = nil
	-----
	Character = nil
	CharacterClientServerSignalsFolder = nil
	CharacterClientServerRemotesFolder = nil
	ClientServerSignalsFolder = nil
	CharacterCoreFolder = nil
	--
	PartsViewModelsFolder = nil
	SharedModulesFolder = nil
	SharedFPSAPIsFolder = nil
	SharedInfoModulesFolder = nil
	SharedGameFolder = nil
	--
	Player = nil
	Mouse = nil
	--
	WeaponsInfoModule = nil
	GrenadesInfoModule = nil
	AdsInfoModule = nil
	FpsInfoModule = nil
	CharacterInfoModule = nil
	SoundsInfoModule = nil
	GameModesInfoModule = nil
	--
	PlayerModule = nil
	--
	SettingsModule = nil
	InterfacesModule = nil
	CameraModule = nil
	UtilitiesModule = nil
	FPSEffectsModule = nil
	EffectsHandlerModule = nil
	DebugModule = nil
	DebrisModule = nil
	CharacterModule = nil
	SoundsModule = nil
	FPSServerModule = nil
	ShortcutsModule = nil
	ObjectsModule = nil
	--
	_SpringModuleInstance = nil
	SpringModule = nil
	--
	CharacterProcessRemote = nil
	CharacterPhysicsProcessRemote = nil
	CharacterRequestSignal = nil
	GunRequestSignal = nil
	GameRequestSignal = nil
	--
	Humanoid = nil
	--
	HumanoidRootPart = nil
	--
	Neck = nil
	Waist = nil
	--
	CharacterViewModelsFolder = nil
	CharacterViewModelsCacheFolder = nil
	--
	PartsViewModelsFolder = nil
	--PartsViewModelGrenadesFolder = nil
	PartsViewModelGunsFolder = nil
	--
	Dying = nil
	IsLoaded = nil
	ReturningToMenu = nil
	ADSing = nil
	--
	Camera = nil
	BlurEffect = nil
	GlobalXCameraAngle = nil
	GlobalYCameraAngle = nil
	BopCFrame = nil
	Sway = nil
	--Sensitivity = nil
	--
	LastPosition = nil
	--
	UserInputService = nil
	RunService = nil
	TweenService = nil
	CollectionService = nil

end

function FPSHandlerModule.End(NilParam, Cancel)
	-- Functions
	-- INIT
	if not Cancel then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		RunService:UnbindFromRenderStep("FPSHandle")
	end

	UtilitiesModule:DisconnectCustomConnections(CustomConnections)
	UtilitiesModule:DisconnectConnections(WeaponConnections)
	UtilitiesModule:DisconnectConnections(Connections)
	
	if ProjectilesToCheck then
		for Projectile, ProjectileInfo in pairs(ProjectilesToCheck) do
			if not ProjectileInfo["Connections"] then
				continue
			end
			
			UtilitiesModule:DisconnectConnections(ProjectileInfo["Connections"])
		end
	end
	

	if not Cancel then
		if GunClientModule then
			GunClientModule:End()
		end

		if ServerGunClientModule then
			ServerGunClientModule:End()
		end

		if CachedGunClientModule then
			CachedGunClientModule:End()
		end
		FPSEffectsModule:End()
		FPSServerModule:End()
	end

	for i, _Instance in pairs(InstanceCache) do
		_Instance:Destroy()
	end

	for Part, Tween in pairs(TweenDict) do
		UtilitiesModule:CancelTween(Part, TweenDict)
	end

	--

	if not Cancel then
		InterfacesModule:UnloadPage("Custom", "Loading")

		if EquippedWeaponModel then
			EquippedWeaponModel:Destroy()
		end

		if CharacterViewModelsCacheFolder then
			CharacterViewModelsCacheFolder:Destroy()
		end

		GunRequestSignal.OnClientInvoke = nil
		CharacterRequestSignal.OnClientInvoke = nil
		ShowCharacter()
		--ToggleAds(false)
		PerformClientAction("ToggleADS", false)
	end

	IsLoaded = false
	script:SetAttribute("Enabled", false)
end

return FPSHandlerModule