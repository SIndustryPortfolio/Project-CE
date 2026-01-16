local WeaponsModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedServerWeaponsModuleFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]["Weapons"]["Server"]
local SharedWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Info Modules
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local ServerWeaponsInfoModule = require(ServerInfoModulesFolder["Weapons"])

-- Modules
local TeamsModule = require(ServerModulesFolder["Teams"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local ServerDamageModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Damage"))
local DebugModule = require(SharedModulesFolder["Debug"])
local ObjectsModule = require(SharedModulesFolder["Objects"])

--local BulletHoleModule = require(UtilitiesModule:WaitForChildTimed(script, "BulletHole"))

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- CORE
local AttributesToStoreOnWeapons = {"Technology", "RoundsInMag", "Rounds", "MaxRoundsInMag", "FireRate", "MaxMags", "MaxEnergy", "Energy", "MaxCharge", "CurrentEnergyUsage"}
local RequiredModules = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function InitialiseWeapon(WeaponModel, Player, IsMapWeapon, Raycastable)
	-- CORE
	local PlayerTeam = nil 
	
	if Player then
		PlayerTeam = Player.Team
	end
	
	local FoundAssociatedWeaponModel = SharedWeaponsFolder:FindFirstChild(WeaponModel.Name)
	
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
	local WeaponCoreFolder = UtilitiesModule:WaitForChildTimed(WeaponModel, "Core")
	local BarrelPart = UtilitiesModule:WaitForChildTimed(WeaponModel, "Barrel")
	
	local FoundBarrelAttachment = BarrelPart:FindFirstChildOfClass("Attachment")
	local MuzzleFlashParticleEmitter = nil 
	local SmokeParticleEmitter = nil
	
	if FoundBarrelAttachment then
		MuzzleFlashParticleEmitter = FoundBarrelAttachment:FindFirstChild("MuzzleFlash")
		SmokeParticleEmitter = FoundBarrelAttachment:FindFirstChild("Smoke")
	end
	
	local PlayerEquippedCamo = nil
	
	if Player then
		PlayerEquippedCamo = ShortcutsModule:GetPlayerInventoryFolder(Player, "Camos"):GetAttribute("Equipped")
	end
	
	local ServerWeaponGunClient = UtilitiesModule:WaitForChildTimed(SharedServerWeaponsModuleFolder, "GunClient")
	
	-- Functions
	-- INIT
	if MuzzleFlashParticleEmitter and WeaponInfo["FireRate"] then
		local OriginalLifetime = (1 / WeaponInfo["FireRate"]) * 2
		
		MuzzleFlashParticleEmitter.Lifetime = NumberRange.new(OriginalLifetime)
		MuzzleFlashParticleEmitter.Rate = WeaponInfo["FireRate"]
		
		if WeaponInfo["Type"] == "Burst" then
			MuzzleFlashParticleEmitter.Lifetime = NumberRange.new(OriginalLifetime / 3)
		end
	end
		
	if FoundAssociatedWeaponModel then
		if WeaponCoreFolder:FindFirstChild("Animations") then
			WeaponCoreFolder["Animations"]:Destroy()
		end
		
		FoundAssociatedWeaponModel["Core"]["Animations"]:Clone().Parent = WeaponCoreFolder
	end
	
	local Success, Error = pcall(function()
		for i, PropertyName in pairs(AttributesToStoreOnWeapons) do
			local Success, Error = pcall(function()
				if WeaponModel:GetAttributes()[PropertyName] == nil and WeaponInfo[PropertyName] ~= nil then
					WeaponModel:SetAttribute(PropertyName, WeaponInfo[PropertyName])
				end
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | InitialiseWeapon | Unable to set property / attribute | Property Name: ".. tostring(PropertyName).. " | Weapon Model: ".. tostring(WeaponModel).. " | Player: ".. tostring(Player))
			end
		end
	end)
	
	if Player and PlayerTeam and not IsMapWeapon then
		local TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam)
		
		if TeamInfo and TeamInfo["InfiniteAmmo"] then
			if table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
				WeaponModel:SetAttribute("Rounds", math.huge)
			elseif table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) then
				WeaponModel:SetAttribute("Energy", math.huge)
			end
		end
	end
	
	if not Success then
		DebugModule:Print(script.Name.. " | InitialiseWeapon | Setting Attributes | Error: ".. tostring(Error))
	end
	
	if FoundAssociatedWeaponModel and FoundAssociatedWeaponModel:FindFirstChild("Core") then
		for i, Module in pairs(WeaponCoreFolder:GetChildren()) do
			if not Module:IsA("ModuleScript") then
				continue
			end

			Module:Destroy()
		end
		
		for i, Attachment in pairs(BarrelPart:GetChildren()) do
			if not Attachment:IsA("Attachment") then
				continue
			end
			
			Attachment:Destroy()
		end
		
		for i, Module in pairs(FoundAssociatedWeaponModel:WaitForChild("Core"):GetChildren()) do
			if WeaponCoreFolder:FindFirstChild(Module.Name) then
				continue
			end
			
			Module:Clone().Parent = WeaponCoreFolder
		end
		
		for i, Attachment in pairs(FoundAssociatedWeaponModel:WaitForChild("Barrel"):GetChildren()) do
			if not Attachment:IsA("Attachment") then
				continue
			end
			
			Attachment:Clone().Parent = BarrelPart
		end
	end
	
	--[[local FoundWeaponGunClientModule = WeaponCoreFolder:FindFirstChild("GunClient")
	
	if FoundWeaponGunClientModule then
		FoundWeaponGunClientModule:Destroy()
	end]]
	
	--ServerWeaponGunClient:Clone().Parent = WeaponCoreFolder
	
	ObjectsModule:ObjectProcess("SetCollisionGroup", WeaponModel, "Weapons")
	
	local Success, Error = pcall(function()
		if not Raycastable then
			ObjectsModule:ObjectProcess("NoneRaycastable", WeaponModel)
		else
			ObjectsModule:ObjectProcess("Raycastable", WeaponModel)
		end	
			
		if not IsMapWeapon and not WeaponModel:GetAttributes()["Map"] then
			if PlayerEquippedCamo and PlayerEquippedCamo ~= "" then
				ObjectsModule:ObjectProcess("ApplyCamo", WeaponModel, PlayerEquippedCamo)
			end
		else
			WeaponModel:SetAttribute("Map", true)
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Weapon: ".. tostring(WeaponModel).. " | Player: ".. tostring(Player).. " | IsMapWeapon: ".. tostring(IsMapWeapon).. " | Error: ".. tostring(Error))
	end
end

local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function WeaponProcess(FunctionName, ...)
	-- Functions
	-- INIT
	return RequiredModules[FunctionName]:Initialise(...)
end

local function GetPlayerWeaponFromName(Player, WeaponName)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player)
	
	if not Character then
		return nil
	end
	
	return Character:FindFirstChild(WeaponName) or Player:WaitForChild("Backpack"):FindFirstChild(WeaponName)
end

-- DIRECT
function WeaponsModule.GetPlayerWeaponFromName(NilParam, Player, WeaponName)
	return GetPlayerWeaponFromName(Player, WeaponName)
end

function WeaponsModule.WeaponProcess(NilParam, FunctionName, ...)
	return WeaponProcess(FunctionName, ...)
end

function WeaponsModule.ProjectileRegistered(NilParam, ...)
	return RequiredModules["Fire"]:ProjectileRegistered(...)
end

function WeaponsModule.FireWeapon(NilParam, ...)
	return RequiredModules["Fire"]:Fire(...)
end

function WeaponsModule.InitialiseWeapon(NilParam, WeaponModel, Player, IsMapWeapon, Raycastable)
	-- Functions
	-- INIT
	return InitialiseWeapon(WeaponModel, Player, IsMapWeapon, Raycastable)
end

-- INIT
RunSubModules()

return WeaponsModule