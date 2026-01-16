local MeleeModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]

-- Elements
-- REMOTES
local PhysicsRemote = ClientServerRemotesFolder["PhysicsRemote"]
local PhysicsSignal = ClientServerSignalsFolder["PhysicsRequest"]

-- Info Modules
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])
local ServerCharacterActionsInfoModule = require(ServerInfoModulesFolder["CharacterActions"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local MapsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Maps"))
local ServerDamageModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Damage"))

-- CORE
local PlayerToSessionId = {}
local SessionIdLength = 10

-- Functions
-- MECHANICS
local function AddToCache(Player, SessionId)
	-- Functions
	-- INIT
	if PlayerToSessionId[Player] ~= nil then
		return nil
	end
	
	PlayerToSessionId[Player] = SessionId
end

local function RemoveFromCache(Player)
	-- Functions
	-- INIT
	PlayerToSessionId[Player] = nil
end

local function IsPartCharacter(PartToShift)
	-- Functions
	-- INIT
	local FoundHumanoid = UtilitiesModule:GetHumanoidFromHit(PartToShift)
	
	local RootModel = nil 
	
	if FoundHumanoid then
		RootModel = FoundHumanoid.Parent
	end
	
	--[[PartToShift:FindFirstAncestorOfClass("Model")
	
	if RootModel and not RootModel:FindFirstChildOfClass("Humanoid") then
		RootModel = PartToShift:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Model")
			
		if RootModel and not RootModel:FindFirstChildOfClass("Humanoid") then
			RootModel = PartToShift:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Model"):FindFirstChildOfClass("Model")
		end
	end]]
	
	if RootModel and game.Players:GetPlayerFromCharacter(RootModel) then
		local Humanoid = RootModel:FindFirstChildOfClass("Humanoid")
		
		if Humanoid and Humanoid.Health > 0 then
			return true
		end
	end
	
	return false
end

local function HandlePhysics(Character, PartToShift, raycastResult, ExtraForce)
	-- CORE
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart
	--local TargetHumanoid = UtilitiesModule:GetHumanoidFromHit(PartToShift)
	
	-- Functions
	-- INIT
	if not PartToShift then
		return nil
	end
	
	if IsPartCharacter(PartToShift) then
		return nil
	end
	
	
	--[[if TargetHumanoid then
		local Success, Error = pcall(function()
			TargetHumanoid.Jump = true
		end)
	end]]
	
	
	--AddToCache(Player, UtilitiesModule:GenerateRandomString(SessionIdLength))
	
	--print("Session Id: ".. PlayerToSessionId[Player])
	
	--PhysicsRemote:FireClient(Player, "Melee", PartToShift)
	--local Response = PhysicsSignal:InvokeClient(Player, "Melee", PlayerToSessionId[Player], PartToShift, raycastResult)
	
	--PartToShift:ApplyImpulse(Character.PrimaryPart.CFrame.LookVector * (PartToShift.AssemblyMass + ServerCharacterActionsInfoModule:GetCharacterActionInfo("Melee")["PushbackForce"] * (ExtraForce or 1)))
	
	PartToShift.Velocity = (Character.PrimaryPart.CFrame.LookVector) * ServerCharacterActionsInfoModule:GetCharacterActionInfo("Melee")["PushbackForce"] * (ExtraForce or 1)
	
	
	--[[local Success, Error = pcall(function()
		return PartToShift:SetNetworkOwner(Player)
	end)
	
	coroutine.wrap(function()
		task.wait(3)
		if PartToShift then
			local Success, Error = pcall(function()
				return PartToShift:SetNetworkOwner(nil)
			end)
		end 
	end)()]]
	
	--[[if TargetHumanoid then
		coroutine.wrap(function()
			task.wait(2)
			
			pcall(function()
				TargetHumanoid.PlatformStand = false
			end)
		end)
	end]]
end

local function Initialise(Character, raycastResult, ExtraForce)
	if not raycastResult or not raycastResult.Instance then
		return nil
	end
	
	local RootModel = UtilitiesModule:GetRootModel(raycastResult.Instance)
	
	local PartToShift = nil
	
	if RootModel then
		PartToShift = UtilitiesModule:GetPartToShift(RootModel)	
	else
		PartToShift = raycastResult.Instance
	end
	
	if PartToShift.Anchored and not UtilitiesModule:GetHumanoidFromHit(PartToShift) then
		return nil
	end
	
	-- CORE
	local CurrentMap = MapsModule:GetCurrentMap()

	-- Functions
	-- INIT
	return HandlePhysics(Character, PartToShift, raycastResult, ExtraForce)
end

-- DIRECT
function MeleeModule.Initialise(NilParam, ObjectsModule, Character, raycastResult, ExtraForce)
	return Initialise(Character, raycastResult, ExtraForce)
end

return MeleeModule