local AIZombieModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local PartsDropsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Drops"]

-- Modules
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local MapsModule = require(ServerModulesFolder["Maps"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local BlacklistedCollections = {"OneWayDoor"}
local MaxDistance = 1500
local MeleeRange = 5
local Damage = 35
local BossDamageMultiplier = 1.75

local ChanceToDrop = 50 -- 1 in 50
local ChanceTable = {}

local ConnectionsCache = {}

-- Services
local CollectionService = game:GetService("CollectionService")
--local PathFindingService = game:GetService("PathfindingService")

-- Functions
-- MECHANICS
local function SetupChanceTable()
	-- Functions
	-- INIT
	for i = 1, ChanceToDrop do
		if i == 1 then
			ChanceTable[i] = true
		else
			ChanceTable[i] = false
		end
	end
end

local function PowerUpDrop(Zombie)
	-- Functions
	-- INIT
	local PowerUpModel = PartsDropsFolder:GetChildren()[math.random(1, #PartsDropsFolder:GetChildren())]:Clone()
	
	local PartToShift = UtilitiesModule:GetPartToShift(PowerUpModel)
	
	PowerUpModel.Parent = workspace["Dump"]["Power Up Drops"]
	
	PartToShift.CFrame = Zombie.PrimaryPart.CFrame
	
	CollectionService:AddTag(PowerUpModel, "Power Up Drop")
	CollectionService:AddTag(PowerUpModel, PowerUpModel.Name.. " Power Up")
end

--[[local function CanSeeCharacter(Zombie, Character)
	-- Elements
	-- PARTS
	local CharacterHumanoidRootPart = Character.PrimaryPart
	local ZombieHumanoidRootPart = Zombie.PrimaryPart
	
	-- Functions
	-- INIT
	local Origin = ZombieHumanoidRootPart.Position
	local Direction = (CharacterHumanoidRootPart.Position - ZombieHumanoidRootPart.Position).Unit * MaxDistance
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {Zombie}
	
	local Result = workspace:Raycast(Origin, Direction, raycastParams)
	
	if Result and Result.Instance and Result.Instance:IsDescendantOf(Character) then
		return true
	else
		return false
	end
end]]

local function CheckIfPathBlockedByDestructable(Zombie)
	-- CORE
	local Origin = Zombie.PrimaryPart.Position
	local Direction = Zombie.PrimaryPart.CFrame.lookVector * MeleeRange
	
	-- Functions
	-- INIT
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
	
	local Whitelisted = {}
	
	for i, CollectionFolder in pairs(MapsModule:GetCurrentMap()["Contents"]["Collections"]:GetChildren()) do
		if table.find(BlacklistedCollections, CollectionFolder.Name) then
			continue
		end
		
		table.insert(Whitelisted, CollectionFolder)
	end
	
	raycastParams.FilterDescendantsInstances = Whitelisted
	
	local result = workspace:Raycast(Origin, Direction, raycastParams)
	
	if result and result.Instance then
		--[[if (Origin - result.Position).Magnitude > MeleeRange then
			return nil
		end]]
		
		local FoundHumanoid = UtilitiesModule:GetHumanoidFromHit(result.Instance)
		
		if FoundHumanoid then
			DebugModule:Print(script.Name.. " | Path blocked by: ".. tostring(FoundHumanoid.Parent))
			return FoundHumanoid.Parent
		end
	end	
end

local function ZombieDied(Zombie, IsBoss, InfectionModule)
	-- Functions
	-- INIT
	InfectionModule:ZombieDied(Zombie, IsBoss)

	CharacterActionsModule:ClientRequest(Zombie, "DropWeapon", "DropWeapon", Zombie)
	ShortcutsModule:Ragdollify(Zombie)
	DebrisModule:AddItem(Zombie, 5)
	
	if ChanceTable[math.random(1, #ChanceTable)] then
		return PowerUpDrop(Zombie)
	end
end

local function RaycastToCharacter(Zombie, Character)
	-- Functions
	-- INIT
	if not Zombie or not Zombie.PrimaryPart or not Character then
		return nil
	end
	
	local OriginalPosition = Zombie.PrimaryPart.Position
	local Direction = (UtilitiesModule:GetPartToShift(Character).Position - OriginalPosition).Unit * MeleeRange
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {Zombie}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	
	return workspace:Raycast(OriginalPosition, Direction, raycastParams)
end

local function Hit(Zombie, Character, IsBoss, IgnoreRaycast)
	-- Functions
	-- INIT
	local raycastResult = RaycastToCharacter(Zombie, Character)
	
	if not raycastResult and not IgnoreRaycast then
		return nil
	end
	
	local ToDamage = Damage
	
	if IsBoss then
		ToDamage *= BossDamageMultiplier
	end
	
	if (raycastResult and raycastResult.Instance:IsDescendantOf(Character)) or IgnoreRaycast then
		DamageModule:TakeDamage(UtilitiesModule:WaitForChildOfClass(Character, "Humanoid"), ToDamage, nil, nil, Zombie.PrimaryPart.Position)
		return true
	end
end

local function Initialise(Zombie, ChosenSpawn, IsBoss, ServerWeaponModule, InfectionModule, CustomConnection)
	-- CORE
	local SpawnNodeValue = ChosenSpawn:FindFirstChild("SpawnNode")
	local Died = false
	local HasReachedSpawnNode = false
	local ZombieHumanoid = Zombie["Humanoid"]
	local ZombieHumanoidRootPart = Zombie.PrimaryPart
	
	-- Functions
	-- MECHANICS
	local function GetClosest()
		-- Functions
		-- INIT
		local ClosestDistance = MaxDistance --math.huge
		local ClosestCharacter = nil
		
		for i, Character in pairs(UtilitiesModule:GetCharacters(true)) do
			local Humanoid = Character:FindFirstChildOfClass("Humanoid")
			
			if Humanoid and Humanoid.Health == 0 then
				continue
			end
			
			local Distance = (Character.PrimaryPart.Position - ZombieHumanoidRootPart.Position).Magnitude
			
			if Distance < ClosestDistance then
				ClosestDistance = Distance
				ClosestCharacter = Character
			end
		end
		
		return ClosestCharacter, ClosestDistance
	end
	
	local function onHealthChanged()
		-- Functions
		-- INIT
		if ZombieHumanoid.Health > 0 or Died then
			return nil
		end
		
		Died = true
		
		ZombieDied(Zombie, IsBoss, InfectionModule)
	end
	
	-- DIRECT
	local Connection1 = ZombieHumanoid:GetPropertyChangedSignal("Health"):Connect(function()
		return onHealthChanged()
	end)
	
	-- INIT
	ConnectionsCache[Zombie] = {Connection1}
	
	coroutine.wrap(function()
		CollectionService:AddTag(Zombie, "AI")

		while Zombie and ZombieHumanoid and ZombieHumanoid.Health > 0 and CustomConnection and CustomConnection.Value and task.wait() do
			local Success, Error = pcall(function()
				-- CORE
				local HasHit = false

				
				local Success, ClosestCharacter =  nil
				
				if HasReachedSpawnNode then
					Success, ClosestCharacter = pcall(function() 
						return GetClosest()
					end)
				else
					Success, ClosestCharacter = pcall(function()
						return SpawnNodeValue.Value
					end)
				end
				
				if not Success or not ClosestCharacter then
					ZombieHumanoid:SetAttribute("Run", false)
					return nil
				end
				
				--[[local CanSee = CanSeeCharacter(Zombie, ClosestCharacter)
				
				
				if not CanSee then
					local Success, Error = pcall(function()
						Path:ComputeAsync(Zombie.PrimaryPart.Position, ClosestCharacter.PrimaryPart.Position)
					end)
				end]]
				
				
				ZombieHumanoid:SetAttribute("Run", true)
				
				ZombieHumanoid:MoveTo(UtilitiesModule:GetPartToShift(ClosestCharacter).Position)
				
				--ZombieHumanoid.MoveToFinished:Wait()
				
				local CollectionBlockingWay = CheckIfPathBlockedByDestructable(Zombie)
				
				if CollectionBlockingWay then
					local HitResult = Hit(Zombie, CollectionBlockingWay, IsBoss, true)

					if HitResult then
						ServerWeaponModule:Melee()
						HasHit = true
					end
				end
				
				if not HasHit and (ZombieHumanoidRootPart.Position - UtilitiesModule:GetPartToShift(ClosestCharacter).Position).Magnitude <= MaxDistance then
					if InfectionModule:GetIsNuking() then
						return nil
					end
					
					local HitResult = Hit(Zombie, ClosestCharacter, IsBoss)
					
					if HitResult then
						ServerWeaponModule:Melee()
						HasHit = true
					end
				end

				
				if not HasReachedSpawnNode then
					if (Zombie.PrimaryPart.Position - SpawnNodeValue.Value.Position).Magnitude <= 5 + ZombieHumanoid.HipHeight then
						HasReachedSpawnNode = true
					end
				end
				
				if HasHit then
					task.wait(1) -- Cooldown
				end
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | AI Cycle Loop | Error: ".. tostring(Error))
			end
		end
		
		UtilitiesModule:DisconnectConnections(ConnectionsCache[Zombie])
	end)()
end

local function End()
	
end

-- DIRECT
function AIZombieModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function AIZombieModule.End(NilParam, ...)
	return End(...)
end

-- INIT
SetupChanceTable()

return AIZombieModule