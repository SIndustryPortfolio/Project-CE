local FPSServerModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Elements
-- HUMANOIDS
local Humanoid = Character:WaitForChild("Humanoid")

-- FOLDERS
local CoreFolder = Character:WaitForChild("Core")
local DrinksFolder = Character:WaitForChild("Drinks")

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local AnimationsInfoModule = require(CoreFolder["Animations"])
local CharacterInfoModule = require(InfoModulesFolder["Character"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Core
local Connections = {}
local LoadedAnimations = {}
local AnimationInstances = {}

local AnimationToConnections = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function LoadAnimations()
	-- Functions
	-- INIT
	UtilitiesModule:LoadAnimations(AnimationsInfoModule, AnimationInstances, LoadedAnimations, Humanoid)
	
	--[[for AnimationName, AnimationInfo in pairs(AnimationsInfoModule) do
		local AnimationInstance = Instance.new("Animation")
		AnimationInstance.Name = AnimationName
		AnimationInstance.AnimationId = AnimationInfo.Id
		
		LoadedAnimations[AnimationName] = Humanoid:LoadAnimation(AnimationInstance)
	end]]
end

local function ServerUnequip(FPSHandlerModule, WeaponName, _EquippedWeaponModel, _GunClientModule, _ServerGunClientModule, ...)
	-- Functions
	-- INIT
	
	local Args = {...}
	
	Overwrites["HasUnequipped"] = nil
	
	--if not _EquippedWeaponModel then
		--_EquippedWeaponModel = FPSHandlerModule:GetEquippedWeaponModel()
	--end
	
	--if not _GunClientModule then
		--_GunClientModule = FPSHandlerModule:GetGunClientModule()
	--end
	
	--if _ServerGunClientModule == nil then
		--_ServerGunClientModule = FPSHandlerModule:GetServerGunClientModule()
	--end
	
	--DebugModule:Print"Unequipped Weapon: ".. tostring(_EquippedWeaponModel.Name))
	--DebugModule:Print"Gun Server Client Module: ".. tostring(_ServerGunClientModule))
	
	
	if WeaponName ~= _EquippedWeaponModel.Name then
		DebugModule:Print(script.Name.. " | Server Unequip | Weapon name mis match")
		return nil
	end	
	
	local Success, Error = pcall(function()
		coroutine.wrap(function()
			if _EquippedWeaponModel and _GunClientModule then
				_GunClientModule:Unequip(unpack(Args))
				--_GunClientModule:Hide()
				--_GunClientModule:End()
			end
		end)()

		if _ServerGunClientModule ~= nil then
			--DebugModule:Print"Unequipping Server gun")
			_ServerGunClientModule:Unequip(unpack(Args))
			_ServerGunClientModule:End()
		end
		
		if _EquippedWeaponModel then
			if not _EquippedWeaponModel:IsDescendantOf(Character) then
				--_EquippedWeaponModel:Destroy()
				DebrisModule:AddItem(_EquippedWeaponModel)
			end
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | ServerUnequip | Error: ".. tostring(Error))
	end
	
	Overwrites["HasUnequipped"] = true
	
	return true
end

local function ServerDrinkPerk(FPSHandlerModule)
	-- Functions
	-- INIT
	if FPSHandlerModule:GetServerGunClientModule() then
		FPSHandlerModule:GetServerGunClientModule():Unequip()
		LoadedAnimations["DrinkPerk"]:Play()

		--task.wait(LoadedAnimations["DrinkPerk"].Length / 2)

		--coroutine.wrap(function()
			LoadedAnimations["DrinkPerk"].Stopped:Wait()
			task.wait(.3)
			FPSHandlerModule:GetServerGunClientModule():Equip()
		
		--end)()

		--LoadedAnimations["ThrowGrenade"].Stopped:Wait()
	end
end

local function ServerThrowGrenade(FPSHandlerModule, Speed)
	-- Functiosn
	-- INIT
	if FPSHandlerModule:GetServerGunClientModule() then
		FPSHandlerModule:GetServerGunClientModule():Unequip()
		LoadedAnimations["ThrowGrenade"]:Play()
		
		if Speed then
			LoadedAnimations["ThrowGrenade"]:AdjustSpeed(Speed)
			task.wait((LoadedAnimations["ThrowGrenade"].Length * (1 / Speed)) / 2)
		else
			task.wait(LoadedAnimations["ThrowGrenade"].Length / 2)
		end
		
		
		coroutine.wrap(function()
			LoadedAnimations["ThrowGrenade"].Stopped:Wait()
			FPSHandlerModule:GetServerGunClientModule():Equip()
		end)()
		
		--LoadedAnimations["ThrowGrenade"].Stopped:Wait()
	end
end

local function ServerMelee(FPSHandlerModule)
	-- Functions
	-- INIT
	local HasSpeedCola = DrinksFolder:FindFirstChild("Speed Cola")
	
	if FPSHandlerModule:GetServerGunClientModule() then
		if not HasSpeedCola then
			return FPSHandlerModule:GetServerGunClientModule():Melee()
		else
			return FPSHandlerModule:GetServerGunClientModule():Melee(2)
		end
	end
end

local function ServerReload(FPSHandlerModule)
	-- Functions
	-- INIT
	Overwrites["HasReloaded"] = nil
	local FinishedReloading = false
	local WeaponName = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(Character:GetAttribute(Character:GetAttribute("EquippedWeapon")))
	local Connection1 = nil
	if FPSHandlerModule:GetServerGunClientModule() then
		if WeaponInfo["ReloadType"] == "Static" then
			if FPSHandlerModule:GetServerGunClientModule():GetAnimationToLoad()["Reload"] then
				Connection1 = FPSHandlerModule:GetServerGunClientModule():GetAnimationToLoad()["Reload"]:GetMarkerReachedSignal("Reloaded"):Connect(function()
					Connection1:Disconnect()
					FinishedReloading = true
				end)
				--
				table.insert(Connections, Connection1)
			end
		end
		
		
		local ReloadSpeed = WeaponInfo["ReloadSpeed"] or 1
		
		local HasSpeedCola = DrinksFolder:FindFirstChild("Speed Cola")
		
		coroutine.wrap(function()
			if HasSpeedCola then
				FPSHandlerModule:GetServerGunClientModule():Reload(ReloadSpeed * 2.0)
			else
				FPSHandlerModule:GetServerGunClientModule():Reload(ReloadSpeed)
			end
			if WeaponInfo["ReloadType"] ~= "Static" then
				FinishedReloading = true
			end
		end)()		
	else
		FinishedReloading = true
	end
	
	DebugModule:Print(script.Name.. " | Starting wait for HasReloaded")
	repeat
		task.wait()
	until FinishedReloading or WeaponName ~= Character:GetAttribute(Character:GetAttribute("EquippedWeapon")) or not Humanoid:GetAttribute("Reload") or not Character or Humanoid.Health <= 0
	
	UtilitiesModule:DisconnectConnections({Connection1})
	
	DebugModule:Print(script.Name.. " | Setting HasReloaded to true")
	Overwrites["HasReloaded"] = true
	
	return FinishedReloading
end

local function ServerFire(FPSHandlerModule, ThirdPerson)
	-- Functions
	-- INIT
	if FPSHandlerModule:GetServerGunClientModule() then
		return FPSHandlerModule:GetServerGunClientModule():Fire(ThirdPerson)
	end
end

local function StopLoadedAnimations(Ignore, SpecificNames)
	-- Functions
	-- INIT
	if not Ignore then
		Ignore = {}
	end
	
	-- MECHANICS
	local function Stop(AnimationName)
		-- Functions
		-- INIT
		LoadedAnimations[AnimationName]:AdjustSpeed(1)
		LoadedAnimations[AnimationName]:Stop()

		if AnimationToConnections[AnimationName] ~= nil then
			UtilitiesModule:DisconnectConnections(AnimationToConnections[AnimationName])
			AnimationToConnections[AnimationName] = nil
		end
	end
	
	-- INIT
	if not SpecificNames then
		for AnimationName, AnimationInfo in pairs(LoadedAnimations) do
			if table.find(Ignore, AnimationName) then
				continue
			end
			
			Stop(AnimationName)
		end
	else
		for i, SpecificAnimationName in pairs(SpecificNames) do
			Stop(SpecificAnimationName)
		end
	end
end

local function DestroyAllAnimationInstances()
	-- Functions
	-- INIT
	for Animation, _Connections in pairs(AnimationToConnections) do
		if _Connections then
			UtilitiesModule:DisconnectConnections(_Connections)
		end
		AnimationToConnections[Animation] = nil
	end
	
	for i, AnimationInstance in pairs(AnimationInstances) do
		AnimationInstance:Destroy()
	end
end

local function ServerFlinch(FPSHandlerModule)
	-- CORE
	local FlinchAnimations = {"FlinchLeft", "FlinchRight"}
	
	-- Functions
	-- INIT
	StopLoadedAnimations({"Crouch", "CrouchMove"})
	LoadedAnimations[FlinchAnimations[math.random(1, #FlinchAnimations)]]:Play()
end

local function ServerCrouch(FPSHandlerModule)
	-- CORE
	local ConnectionsWithAnimation = {}
	
	StopLoadedAnimations(nil, {"Crouch", "CrouchMove"})
	Humanoid.HipHeight = CharacterInfoModule:GetCharacterInfo("CrouchHipHeight")
	LoadedAnimations["Crouch"]:Play()
	
	
	local Connection1 = LoadedAnimations["Crouch"]:GetMarkerReachedSignal("Freeze"):Connect(function()
		LoadedAnimations["Crouch"]:AdjustSpeed(0)
	end)
	
	local Connection2 = Humanoid.Running:Connect(function(Speed)
		if Speed > 0 then
			LoadedAnimations["CrouchMove"]:Play()
		else
			LoadedAnimations["CrouchMove"]:Stop()
		end
	end)
	
	local Connection3 = CollectionService:GetInstanceAddedSignal("Custom Power Up"):Connect(function(Model)
		if Model ~= Character then
			return nil
		end
		
		return LoadedAnimations["CrouchMove"]:AdjustSpeed(2)
	end)
	
	local Connection4 = CollectionService:GetInstanceRemovedSignal("Custom Power Up"):Connect(function(Model)
		if Model ~= Character then
			return nil
		end
		
		return LoadedAnimations["CrouchMove"]:AdjustSpeed(1)
	end)
	
	-- Connections
	table.insert(ConnectionsWithAnimation, Connection1)
	table.insert(ConnectionsWithAnimation, Connection2)
	table.insert(ConnectionsWithAnimation, Connection3)
	table.insert(ConnectionsWithAnimation, Connection4)
	
	-- INIT
	AnimationToConnections["Crouch"] = ConnectionsWithAnimation
end

local function StopServerCrouch(FPSHandlerModule)
	-- Functions
	-- INIT
	Humanoid.HipHeight = CharacterInfoModule:GetCharacterInfo("HipHeight")
	StopLoadedAnimations(nil, {"Crouch", "CrouchMove"})
end

-- CORE FUNCTIONS
local Requests = 
{
	["ServerFire"] = ServerFire,
	["ServerReload"] = ServerReload,
	["ServerUnequip"] = ServerUnequip,
	["ServerMelee"] = ServerMelee,
	["ServerThrowGrenade"] = ServerThrowGrenade,
	["ServerDrinkPerk"] = ServerDrinkPerk,
	["ServerFlinch"] = ServerFlinch,
	["ServerCrouch"] = ServerCrouch,
	["ServerStopCrouch"] = StopServerCrouch
}

Overwrites = 
{
	["HasReloaded"] = nil,
	["HasUnequipped"] = nil
}

-- DIRECT
function FPSServerModule.SwitchedWeapon()
	Overwrites["HasReloaded"] = nil
end

function FPSServerModule.HasReloaded()
	return Overwrites["HasReloaded"]
end

function FPSServerModule.HasUnequipped()
	return Overwrites["HasUnequipped"]
end

function FPSServerModule.Request(NilParam, FunctionName, FPSHandlerModule, ...)
	return Requests[FunctionName](FPSHandlerModule, ...)
end

function FPSServerModule.GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	ModulesFolder = nil
	InfoModulesFolder = nil
	--
	Humanoid = nil
	--
	CoreFolder = nil
	--
	AnimationsInfoModule = nil
	CharacterInfoModule = nil
	--
	UtilitiesModule = nil
	DebugModule = nil
	--
	LoadedAnimations = nil
	AnimationInstances = nil
	AnimationToConnections = nil
	--
	CollectionService = nil
	
end

function FPSServerModule.End()
	UtilitiesModule:DisconnectConnections(Connections)
	StopLoadedAnimations()
	DestroyAllAnimationInstances()
end

-- INIT
LoadAnimations()

return FPSServerModule