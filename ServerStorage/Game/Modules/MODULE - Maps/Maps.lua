local MapsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerMapsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Maps"]
local ServerMapsArchiveFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Archive"]["Maps"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]

local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

local WorkspaceMapFolder = workspace:WaitForChild("Map")

-- InfoModules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])
local MapsInfoModule = require(ServerInfoModulesFolder["Maps"])

-- Modules
local TeamsModule = require(ServerModulesFolder["Teams"])
local GameModule = require(ServerModulesFolder["Game"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local MapLoaderModule = require(UtilitiesModule:WaitForChildTimed(script, "MapLoader"))

-- Functions
-- MECHANICS
local function GetMap(MapName)
	-- Functions
	-- INIT
	local Map = ServerMapsFolder["Any"]:FindFirstChild(MapName) --ServerMapsFolder:FindFirstChild(MapName) or ServerMapsArchiveFolder:FindFirstChild(MapName) --UtilitiesModule:WaitForChildTimed(ServerMapsFolder, MapName)
	
	if not Map then
		for i, GameTypeFolder in pairs(ServerMapsFolder:GetChildren()) do
			if GameTypeFolder.Name == "Any" then
				continue
			end
			
			Map = GameTypeFolder:FindFirstChild(MapName)
			
			if Map then
				break
			end
		end
	end
	
	if not Map then
		Map = ServerMapsArchiveFolder:FindFirstChild(MapName)
	end
	
	if Map then
		return Map:Clone()
	end
end

local function SortMapSpawns(MapClone, GameModeInfo)
	-- CORE
	local TeamsInfo = GameModeInfo.Teams
	
	-- Elements
	-- FOLDERS
	local SpawnsFolder = UtilitiesModule:WaitForChildTimed(MapClone, "Spawns")
	
	-- Functions
	-- INIT
	if not TeamsInfo then
		return nil
	end
	
	for i, _TeamInfo in pairs(TeamsInfo) do
		local LocatedSpawnsSubFolder = nil -- UtilitiesModule:WaitForChildTimed(SpawnsFolder, _TeamInfo["SpawnWith"] or tostring(i))
		
		if _TeamInfo["SpawnWith"] ~= nil then
			--LocatedSpawnsSubFolder = SpawnsFolder:FindFirstChild(tostring(_TeamInfo["SpawnWith"]))
			continue
		else
			LocatedSpawnsSubFolder = SpawnsFolder:FindFirstChild(tostring(i))
			LocatedSpawnsSubFolder.Name = _TeamInfo["Name"]

		end
		
		for x, SpawnLocation in pairs(LocatedSpawnsSubFolder:GetChildren()) do
			if SpawnLocation:IsA("SpawnLocation") then
				SpawnLocation.Neutral = false
				SpawnLocation.TeamColor = _TeamInfo["TeamColour"] or _TeamInfo["Colour"] or BrickColor.new(_TeamInfo["Name"])
			end
		end
		
		LocatedSpawnsSubFolder.Name = _TeamInfo["Name"]
	end
end

local function LoadMap(MapName, GameMode)
	-- CORE
	local GameModeInfo = nil 
	
	if GameMode then
		GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameMode)
	end
	
	-- Functions
	-- INIT
	local Map = GetMap(MapName)
	
	if not Map or not GameModeInfo then
		return nil
	end
	
	SortMapSpawns(Map, GameModeInfo)	
	
	MapLoaderModule:LoadMap(Map, GameModeInfo["MapWeapons"],  GameModeInfo["MapVehicles"], GameModeInfo["MapGrenades"])
	
	Map.Parent = UtilitiesModule:WaitForChildTimed(WorkspaceMapFolder, "Server")
	return Map
end

local function UnloadMap(MapName)
	-- Functions
	-- INIT
	local Map = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(WorkspaceMapFolder, "Server"), MapName)
	
	if Map then
		MapLoaderModule:UnloadMap(Map)
		Map:Destroy()
	end
end

local function GetAllMapNames(GameMode)
	-- CORE
	local MapNames = {}
	
	local LoopableFolders = {}
	local GameModeInfo = nil
	
	if GameMode then
		GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameMode)
	end
	
	-- Functions
	-- INIT
	if GameMode then
		if ServerMapsFolder:FindFirstChild(GameMode) then
			table.insert(LoopableFolders, ServerMapsFolder:FindFirstChild(GameMode))
		end
		
		if not GameModeInfo["RestrictedMaps"] then
			table.insert(LoopableFolders, ServerMapsFolder["Any"])
		end
	else
		table.insert(LoopableFolders, ServerMapsFolder["Any"])
	end
	
	for i, MapParentFolder in pairs(--[[ServerMapsFolder["Any"]] --[[LoopableFolder:GetChildren()]] LoopableFolders) do
		for x, Map in pairs(MapParentFolder:GetChildren()) do
			table.insert(MapNames, Map.Name)
		end
	end
	
	return MapNames
end

local function HandleSpawn(FoundCharacterModel, TeamNumber)
	-- Core
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	local LinkedPlayer = game.Players:GetPlayerFromCharacter(FoundCharacterModel)
	
	if not LinkedPlayer and not TeamNumber then
		return nil
	end
	
	local Team = nil
	local TeamInfo = nil
	
	if GameModeInfo["Teams"] then
		if not TeamNumber then
			Team = LinkedPlayer.Team
			TeamInfo = TeamsModule:GetTeamInfo(Team)
		else
			Team = TeamNumber
			TeamInfo = GameModeInfo["Teams"][TeamNumber]
		end
	end
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(FoundCharacterModel, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = FoundCharacterModel.PrimaryPart
	
	-- FOLDERS
	local Map = UtilitiesModule:WaitForChildTimed(WorkspaceMapFolder["Server"], SharedGameFolder:GetAttribute("Map"))
	
	if not Map then
		return nil
	end
	
	local SpawnsFolder = UtilitiesModule:WaitForChildTimed(Map, "Spawns")
	
	-- Functions
	-- INIT
	local ChosenSpawnsFolder = nil
	
	if GameModeInfo["Teams"] then
		if TeamInfo["SpawnWith"] then
			ChosenSpawnsFolder = UtilitiesModule:WaitForChildTimed(SpawnsFolder, GameModeInfo["Teams"][TeamInfo["SpawnWith"]]["Name"])
		else
			ChosenSpawnsFolder = UtilitiesModule:WaitForChildTimed(SpawnsFolder, --[[Team.Name]] TeamInfo["Name"])
		end
	else
		local SpawnsFolderChildren = SpawnsFolder:GetChildren()
		ChosenSpawnsFolder = SpawnsFolderChildren[math.random(1, #SpawnsFolderChildren)]
	end
	
	local SpawnsSet = ChosenSpawnsFolder:GetChildren()
	local SpawnSetClone = ChosenSpawnsFolder:GetChildren()
	
	local ChosenSpawn = nil 
	
	for i = 1, #SpawnSetClone do
		local RandomIndex = math.random(1, #SpawnSetClone)
		local _ChosenSpawn = SpawnSetClone[RandomIndex]
	--for i, _ChosenSpawn in pairs(SpawnsSet) do
		local PlayerInSpawn = false
		--local _ChosenSpawn = SpawnsSet[SpawnCount]
		
		local Connection = _ChosenSpawn.Touched:Connect(function() end)
		
		for i, Part in pairs(_ChosenSpawn:GetTouchingParts()) do
			local Success, Error = pcall(function()
				local Humanoid = UtilitiesModule:GetHumanoidFromHit(Part)
				
				local AssociatedPlayer = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
				
				if AssociatedPlayer then
					PlayerInSpawn = true
				end
			end)
		end
		
		if not PlayerInSpawn then
			ChosenSpawn = _ChosenSpawn
			break
		else
			table.remove(SpawnSetClone, RandomIndex)
		end
		
		UtilitiesModule:DisconnectConnections({Connection})		
		
		--SpawnCount += 1
	--until SpawnCount >= #SpawnsSet or ChosenSpawn
	--end
	end
	
	if not ChosenSpawn then
		ChosenSpawn = SpawnsSet[math.random(1, #SpawnsSet)]
	end
	
	local RandomXOffset = math.random(-(MapsInfoModule:GetMapInfo("SpawnOffset") * 100), MapsInfoModule:GetMapInfo("SpawnOffset") * 100) / 100
	local RandomZOffset = math.random(-(MapsInfoModule:GetMapInfo("SpawnOffset") * 100), MapsInfoModule:GetMapInfo("SpawnOffset") * 100) / 100

	HumanoidRootPart.CFrame = (ChosenSpawn.CFrame * CFrame.new(0, Humanoid.HipHeight + (HumanoidRootPart.Size.Y / 2), 0)) + Vector3.new(RandomXOffset, 0, RandomZOffset)
	Humanoid:ChangeState(Enum.HumanoidStateType.None)
	--HumanoidRootPart.Anchored = false
	----DebugModule:Print"Located Character: ".. tostring(FoundCharacterModel.Name))
	
	return ChosenSpawn
end

local function GetCurrentMap()
	-- Functions
	-- INIT
	return WorkspaceMapFolder["Server"]:FindFirstChildOfClass("Folder")
end

local function GetMapCollectables(Map)
	-- CORE
	local Collectables = {}
	
	-- Elements
	-- FOLDERS
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(Map, "Contents")
	local CollectionsFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Collections")
	
	-- Functions
	-- INIT
	
	if CollectionsFolder then
		for i, Folder in pairs(CollectionsFolder:GetChildren()) do
			for x, Model in pairs(Folder:GetChildren()) do
				table.insert(Collectables, Model)
			end
		end
	end 
	
	return Collectables
end


-- DIRECT
function MapsModule.GetMapCollectables(NilParam, Map)
	return GetMapCollectables(Map)
end

function MapsModule.GetCurrentMap()
	return GetCurrentMap()
end

function MapsModule.HandleSpawn(NilParam, ...)
	return HandleSpawn(...)
end

function MapsModule.GetAllMapNames(NilParam, GameModeName)
	return GetAllMapNames(GameModeName)
end

function MapsModule.UnloadMap(NilParam, MapName)
	return UnloadMap(MapName)
end

function MapsModule.LoadMap(NilParam, MapName, GameMode)
	return LoadMap(MapName, GameMode)
end

return MapsModule