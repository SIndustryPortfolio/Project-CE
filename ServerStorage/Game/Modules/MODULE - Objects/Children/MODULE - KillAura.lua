local KillAuraModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

local ObjectPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Objects"]
local DumpsFolder = workspace:WaitForChild("Dump")

-- Info Modules
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local MapsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Maps"))
local ServerDamageModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Damage"))
local DebugModule = require(UtilitiesModule:WaitForChildTimed(SharedModulesFolder, "Debug"))
local DebrisModule = require(SharedModulesFolder["Debris"])
local GameModule = require(ServerModulesFolder["Game"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- CORE
local Info = 
{
	["ExplosionRadius"] = 15,
	["ExplosionDamage"] = 100000,
	["ExplosionDropOffIncrement"] = 15,
	["ExplosionDropOffMultiplier"] = 1,
	["ExplosionPushBackForce"] = 0,
	["ExplosionUpThrust"] = 0,
	["ExplosionSound"] = "rbxassetid://2674547670"
}

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function PushbackPart(Part, rayDirection, Force, Model)
	-- Functions
	-- INIT
	--DebugModule:Print"Pushing back ".. tostring(Part))
	
	--[[if Model and not game.Players:FindFirstChild(Model.Name) then
		local PlayerName = Model:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]
		
		if PlayerName then
			local Player = game.Players:FindFirstChild(PlayerName)
			
			if Player then
				--Part:SetNetworkOwner(Player)
			end
		end
	end]]
	
	Part.Velocity = rayDirection * Force
end

local function HandleExplosionWithArray(Model, Array)
	-- CORE
	local ElementToCompareTo = Model.PrimaryPart or Model
	
	if ElementToCompareTo:IsA("Model") then
		ElementToCompareTo = UtilitiesModule:WaitForChildTimed(ElementToCompareTo, "Base")
	end
	
	local ObjectInfo = Info --ObjectsInfoModule:GetObjectInfo(Model.Name)
	
	local ModelHumanoid = Model:FindFirstChildOfClass("Humanoid")
	
	local ToReturn = {}
	
	-- Functions
	-- INIT
	for i, Item in pairs(Array) do
		local Success, Error = pcall(function()
			if Item == Model or Item:IsDescendantOf(Model) or not ElementToCompareTo then
				return nil --continue
			end
			
			local Part = nil
			
			if Item:IsA("BasePart") then
				Part = Item
			else
				Part = Item.PrimaryPart
			end
			
			if not Part then 
				return nil --continue
			end
			
			local Distance = (ElementToCompareTo.Position - Part.Position).Magnitude
			
			if Distance > ObjectInfo["ExplosionRadius"] then
				return nil --continue
			end
			
			local rayOrigin = ElementToCompareTo.Position
			local rayDirection = (Part.Position - rayOrigin).Unit * ObjectInfo["ExplosionRadius"]
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {Model, DumpsFolder}
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			
			if raycastResult and raycastResult.Instance then
				if not raycastResult.Instance:IsDescendantOf(Item) then
					return nil --continue
				end
			end
			
			PushbackPart(Part, rayDirection + Vector3.new(0, ObjectInfo["ExplosionUpThrust"], 0), ObjectInfo["ExplosionPushBackForce"], Model)

			-- Elements
			-- HUMANODIS
			local Humanoid = Item:FindFirstChildOfClass("Humanoid")
			
			if not Humanoid or Humanoid.Health <= 0 then
				DebugModule:Print("Explosion | Object already dead: ".. tostring(Item))
				return nil --continue
			end
			
			local DamageToGive = ObjectInfo["ExplosionDamage"]
			local AmountOfDropOffs = (Distance - (Distance % ObjectInfo["ExplosionDropOffIncrement"])) / ObjectInfo["ExplosionDropOffIncrement"]
			
			for i = 1, AmountOfDropOffs do
				DamageToGive = DamageToGive * ObjectInfo["ExplosionDropOffMultiplier"]
			end
			
			local TargetCharacter = Humanoid.Parent
			--[[local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetCharacter)
			
			if not TargetPlayer and TargetCharacter.Parent == workspace["Temporary"]["AI"] then
				TargetPlayer = {["Character"] = TargetCharacter, Name = TargetCharacter.Name, Team = {Name = TargetCharacter:GetAttributes()["Team"]}, ["AI"] = true}
			end]]
			
			local TargetPlayer = ShortcutsModule:GetPlayerFromCharacter(TargetCharacter)
			
			local PlayerResponsibleName = nil
			
			local PlayerAssociated = game.Players:GetPlayerFromCharacter(Model)
			
			if not PlayerAssociated then
				if ModelHumanoid then
					if ModelHumanoid:GetAttributes()["LastHit"] ~= "" and ModelHumanoid:GetAttributes()["LastHit"] ~= nil then
						PlayerResponsibleName = ModelHumanoid:GetAttribute("LastHit")
					elseif ModelHumanoid:GetAttributes()["Owner"] ~= "" and ModelHumanoid:GetAttributes()["Owner"] ~= nil then
						PlayerResponsibleName = ModelHumanoid:GetAttribute("Owner")
					end
					--PlayerResponsibleName = ModelHumanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]
				elseif Model then
					if Model:GetAttributes()["Owner"] ~= "" and Model:GetAttributes()["Owner"] ~= nil then
						PlayerResponsibleName = Model:GetAttribute("Owner")
					elseif Model:GetAttributes()["LastHit"] ~= "" and Model:GetAttribute()["LastHit"] ~= nil then
						PlayerResponsibleName = Model:GetAttribute("LastHit")
					end
					--PlayerResponsibleName = Model:GetAttributes()["Owner"] or Model:GetAttributes()["LastHit"]
				end
			else
				PlayerResponsibleName = PlayerAssociated.Name
			end
			
			if not PlayerResponsibleName or PlayerResponsibleName == "" then
				PlayerResponsibleName = Humanoid:GetAttributes()["LastHit"]
			end
			
			--if --[[not ModelHumanoid]] Humanoid then
				--PlayerResponsibleName = Humanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]
			--[[else
				PlayerResponsibleName = ModelHumanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]]
			--end
			
			local PlayerResponsible = nil
			
			if PlayerResponsibleName ~= nil then
				PlayerResponsible = game.Players:FindFirstChild(PlayerResponsibleName)
			end
			
			--Humanoid:TakeDamage(DamageToGive)
			local IsDead = ServerDamageModule:TakeDamage(Humanoid, DamageToGive, PlayerResponsible, nil, Model.PrimaryPart.Position)
			local IsAI = false

			if TargetPlayer and typeof(TargetPlayer) == "table" then
				IsAI = true
			end			
			
			if IsDead and PlayerResponsible and TargetPlayer then
				if Model:GetAttributes()["Stuck"] then
					GameModule:GameProcess("Kill", PlayerResponsible, nil, TargetPlayer, nil, "Stuck", IsAI, Distance)
				else
					GameModule:GameProcess("Kill", PlayerResponsible, nil, TargetPlayer, nil, nil, IsAI, Distance)
				end
			end
			
			
			table.insert(ToReturn, TargetCharacter)
		end)
		
		if not Success then
			--DebugModule:PrintError, "Error")
		end
	end
	
	return ToReturn
end

local function Initialise(ObjectsModule, Model)
	--DebugModule:Print"Model: ".. tostring(Model).. " | Descendants: ".. tostring(#Model:GetDescendants()))
	
	-- CORE
	local CurrentMap = MapsModule:GetCurrentMap()
	
	local ArraysToHandle = 
	{
		[1] = UtilitiesModule:GetCharacters(), 
		[2] = workspace["Temporary"]["AI"]:GetChildren()
	}
	
	-- Elements
	
	-- FOLDERS
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(CurrentMap, "Contents")
	local CollectionsFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Collections")
	
	-- Functions
	-- INIT
	
	--[[HandleExplosionWithArray(Model, UtilitiesModule:GetCharacters())
	HandleExplosionWithArray(Model, MapsModule:GetMapCollectables(MapsModule:GetCurrentMap()))]]
	
	local FinalResult = {}
	
	for i = 1, #ArraysToHandle do
		local Array = ArraysToHandle[i]
		
		local AffectedArray = nil
		
		local Success, Error = pcall(function()
			if typeof(Array) == "function" then
				AffectedArray = HandleExplosionWithArray(Model, Array())
			else
				AffectedArray = HandleExplosionWithArray(Model, Array)
			end
		end)
		
		for i, Element in pairs(AffectedArray) do
			table.insert(FinalResult, Element)
		end
	end
	
	return FinalResult
end

-- DIRECT
function KillAuraModule.Initialise(NilParam, ObjectsModule, Model)
	return Initialise(ObjectsModule, Model)
end

return KillAuraModule