local ExplosionModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]

local ObjectPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Objects"]
local DumpsFolder = workspace:WaitForChild("Dump")

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]

-- Info Modules
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local MapsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Maps"))
local ServerDamageModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Damage"))
local DebugModule = require(UtilitiesModule:WaitForChildTimed(SharedModulesFolder, "Debug"))
local DebrisModule = require(SharedModulesFolder["Debris"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local GameModule = require(ServerModulesFolder["Game"])

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
	
	if Part.Anchored and not UtilitiesModule:GetRootModel(Part):FindFirstChildOfClass("Humanoid") then
		return nil
	end
	
	Part.Velocity = rayDirection * Force
end

local function HandleExplosionWithArray(Model, Array, PlayerResponsible, ObjectName, IgnorePlayer)
	-- CORE
	local PositionToCompareTo = Model
	local ObjectInfo = nil 
	local PlayerCharacter = nil
	
	if PlayerResponsible then
		PlayerCharacter = UtilitiesModule:GetCharacter(PlayerResponsible, true)
	end
	
	local ModelHumanoid = nil
	
	if typeof(Model) == "Instance" then
		ObjectInfo = ObjectsInfoModule:GetObjectInfo(ObjectName or Model.Name)
	else
		ObjectInfo = ObjectsInfoModule:GetObjectInfo(ObjectName or Model)
	end

	local Success, Error = pcall(function()
		ModelHumanoid = Model:FindFirstChildOfClass("Humanoid")
		
		local ElementToCompareTo = UtilitiesModule:GetPartToShift(Model) --Model.PrimaryPart or Model
		
		if ElementToCompareTo:IsA("Model") then
			ElementToCompareTo = UtilitiesModule:WaitForChildTimed(ElementToCompareTo, "Base")
		end
		
		if ElementToCompareTo and ElementToCompareTo:IsA("BasePart") then
			PositionToCompareTo = ElementToCompareTo.Position
		end
	end)
	
	if not Success and Model ~= nil and not PositionToCompareTo then
		pcall(function()
			if typeof(Model) == "Instance" then
				PositionToCompareTo = Model.Position
			else
				PositionToCompareTo = Model
			end
		end)
	end
	
	if not PositionToCompareTo then
		DebugModule:Print(script.Name.. " | HandleExplosionWithArray | Model: ".. tostring(Model).. " | Returning nil V")
		DebugModule:Print(script.Name.. " | HandleExplosionWithArray | PositionToCompareTo: ".. tostring(PositionToCompareTo))
		DebugModule:Print(script.Name.. " | HandleExplosionWithArray | ObjectName: ".. tostring(ObjectName))
		DebugModule:Print(script.Name.. " | HandleExplosionWithArray | IgnorePlayer: ".. tostring(IgnorePlayer))
		return nil
	end
	
	-- Functions
	-- INIT
	if typeof(PositionToCompareTo) == "Instance" then
		local Success, Error = pcall(function()
			PositionToCompareTo = PositionToCompareTo.Position
		end)
		
		if not Success then
			return
		end
	end
	
	for i, Item in pairs(Array) do
		local Success, Error = pcall(function()
			if (typeof(Model) == "Instance" and (Item == Model or Item:IsDescendantOf(Model))) or not --[[ElementToCompareTo]] PositionToCompareTo then
				return nil --continue
			end
			
			if PlayerResponsible and (Item == PlayerCharacter) and IgnorePlayer then
				return nil
			end
			
			local Part = UtilitiesModule:GetPartToShift(Item)
			
			if Part and Part:IsA("Model") then
				Part = UtilitiesModule:WaitForChildTimed(Part, "Base")
			elseif not Part then
				Part = Item
			end
			
			--[[if Item:IsA("BasePart") then
				Part = Item
			else
				Part = Item.PrimaryPart
			end]]
			
			if not Part then 
				return nil --continue
			end
			
			local Distance = (--[[ElementToCompareTo.Position]] PositionToCompareTo - Part.Position).Magnitude
			
			if Distance > ObjectInfo["ExplosionRadius"] then
				return nil --continue
			end
			
			local Filter = {DumpsFolder}
			
			if typeof(Model) == "Instance" then
				table.insert(Filter, Model)
			end
			
			local rayOrigin = PositionToCompareTo --ElementToCompareTo.Position
			local rayDirection = (Part.Position - rayOrigin).Unit * ObjectInfo["ExplosionRadius"]
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = Filter --{Model, DumpsFolder}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude --Enum.RaycastFilterType.Blacklist
			local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
			
			if raycastResult and raycastResult.Instance then
				if not raycastResult.Instance:IsDescendantOf(Item) then
					return nil --continue
				end
			end
			
			PushbackPart(Part, rayDirection + Vector3.new(0, ObjectInfo["ExplosionUpThrust"], 0), ObjectInfo["ExplosionPushBackForce"], Model)

			-- Elements
			-- HUMANODIS
			local Humanoid = Item:FindFirstChildOfClass("Humanoid") or UtilitiesModule:GetHumanoidFromHit(Part)
			
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
			
			if ModelHumanoid then
				if ModelHumanoid:GetAttributes()["LastHit"] ~= "" and ModelHumanoid:GetAttributes()["LastHit"] ~= nil then
					PlayerResponsibleName = ModelHumanoid:GetAttribute("LastHit")
				elseif ModelHumanoid:GetAttributes()["Owner"] ~= "" and ModelHumanoid:GetAttributes()["Owner"] ~= nil then
					PlayerResponsibleName = ModelHumanoid:GetAttribute("Owner")
				end
				--PlayerResponsibleName = ModelHumanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]
			elseif Model and typeof(Model) == "Instance" then
				if Model:GetAttributes()["Owner"] ~= "" and Model:GetAttributes()["Owner"] ~= nil then
					PlayerResponsibleName = Model:GetAttribute("Owner")
				elseif Model:GetAttributes()["LastHit"] ~= "" and Model:GetAttribute()["LastHit"] ~= nil then
					PlayerResponsibleName = Model:GetAttribute("LastHit")
				end
				--PlayerResponsibleName = Model:GetAttributes()["Owner"] or Model:GetAttributes()["LastHit"]
			end
			
			if not PlayerResponsibleName or PlayerResponsibleName == "" then
				PlayerResponsibleName = Humanoid:GetAttributes()["LastHit"]
			end
			
			--if --[[not ModelHumanoid]] Humanoid then
				--PlayerResponsibleName = Humanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]
			--[[else
				PlayerResponsibleName = ModelHumanoid:GetAttributes()["LastHit"] or Model:GetAttributes()["Owner"]]
			--end
			
			local _PlayerResponsible = PlayerResponsible
			
			if not _PlayerResponsible and PlayerResponsibleName ~= nil then
				_PlayerResponsible = game.Players:FindFirstChild(PlayerResponsibleName)
			end
			
			if _PlayerResponsible and Item == _PlayerResponsible.Character then
				local PlayerResponsibleCharacter = UtilitiesModule:GetCharacter(_PlayerResponsible, true)
				
				if PlayerResponsibleCharacter then
					local DrinksFolder = PlayerResponsibleCharacter:FindFirstChild("Drinks")
					
					if DrinksFolder and DrinksFolder:FindFirstChild("PHD Flopper") then
						return nil
					end
				end
			end 
			
			--Humanoid:TakeDamage(DamageToGive)

			local IsDead, DamagedHealth, DamageTaken = ServerDamageModule:TakeDamage(Humanoid, DamageToGive, _PlayerResponsible, nil, --[[Model.PrimaryPart.Position]] PositionToCompareTo)
			local IsAI = false
			
			if TargetPlayer and typeof(TargetPlayer) == "table" then
				IsAI = true
			end
			
			if DamageTaken and TargetPlayer and _PlayerResponsible then
				MainRemote:Fire("PlayerShotRegistered", _PlayerResponsible)
			end
			
			if IsDead and _PlayerResponsible and TargetPlayer then
				local PlayerResponsibleCharacter = UtilitiesModule:GetCharacter(_PlayerResponsible, true)
				
				if PlayerResponsibleCharacter then
					local Success, Error = pcall(function()
						Distance = (PlayerResponsibleCharacter.PrimaryPart.Position - (raycastResult.Position or Part.Position)).Magnitude
					end)
					
					if not Success then
						local Success, Error = pcall(function()
							Distance = (PositionToCompareTo - (raycastResult.Position or Part.Position)).Magnitude
						end)
						
						if not Success or Distance == nil then
							Distance = -1
						end
					end
				end
				
				if Model and typeof(Model) == "Instance" and Model:GetAttributes()["Stuck"] then
					GameModule:GameProcess("Kill", _PlayerResponsible, "Explosion", TargetPlayer, nil, "Stuck", IsAI, Distance)
				else
					GameModule:GameProcess("Kill", _PlayerResponsible, "Explosion", TargetPlayer, nil, nil, IsAI, Distance)
				end
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Model: ".. tostring(Model).. " | Item:  ".. tostring(Item).. " | Player Responsible: ".. tostring(PlayerResponsible)..  " | Error: ".. tostring(Error))
			--DebugModule:PrintError, "Error")
		end
	end
end

local function Initialise(ObjectsModule, Model, SpawnScrap, Player, ObjectName, IgnorePlayer)
	--DebugModule:Print"Model: ".. tostring(Model).. " | Descendants: ".. tostring(#Model:GetDescendants()))
	
	-- CORE
	local CurrentMap = MapsModule:GetCurrentMap()
	
	local ArraysToHandle = 
	{
		[1] = UtilitiesModule:GetCharacters(), 
		[2] = MapsModule:GetMapCollectables(MapsModule:GetCurrentMap()),
		[3] = workspace["Temporary"]["AI"]:GetChildren()
	}
	
	-- Elements
	
	-- FOLDERS
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(CurrentMap, "Contents")
	local CollectionsFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Collections")
	
	-- Functions
	-- INIT
	if SpawnScrap and typeof(Model) == "Instance" then
		local Array =  ObjectsModule:ObjectProcess("SpawnScrap", Model) --SpawnScrapInstances(Model)
		table.insert(ArraysToHandle, Array)
	end
	
	--[[HandleExplosionWithArray(Model, UtilitiesModule:GetCharacters())
	HandleExplosionWithArray(Model, MapsModule:GetMapCollectables(MapsModule:GetCurrentMap()))]]
	
	for i = 1, #ArraysToHandle do
		local Array = ArraysToHandle[i]
		
		local Success, Error = pcall(function()
			if typeof(Array) == "function" then
				HandleExplosionWithArray(Model, Array(), Player, ObjectName, IgnorePlayer)
			else
				HandleExplosionWithArray(Model, Array, Player, ObjectName, IgnorePlayer)
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Array: ".. tostring(Array).. " | Error: ".. tostring(Error))
		end
	end
end

-- DIRECT
function ExplosionModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return ExplosionModule