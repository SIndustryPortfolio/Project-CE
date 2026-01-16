local MapModule = {}

-- Dirs
local ClientMapsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Maps"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

local WorkspaceMapFolder = workspace:WaitForChild("Map")

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Services
local Lighting = game:GetService("Lighting")

-- Functions
-- MECHANICS
local function GetCurrentServerMap()
	-- Functions
	-- INIT
	return WorkspaceMapFolder["Server"]:FindFirstChildOfClass("Folder")
end

local function ResetLighting()
	-- Functions
	-- INIT
	Lighting.ClockTime = 0
	
	for i, Sky in pairs(Lighting:GetChildren()) do
		Sky:Destroy()
	end
end

local function ChangeLighting(LightingInfo)
	-- Functions
	-- INIT
	ResetLighting()
	
	for PropertyName, PropertyValue in pairs(LightingInfo["Properties"]) do
		Lighting[PropertyName] = PropertyValue
	end
	
	for InstanceName, Properties in pairs(LightingInfo["Instances"] or {}) do
		local _Instance = Instance.new(InstanceName)
		
		for PropertyName, PropertyValue in pairs(Properties) do
			_Instance[PropertyName] = PropertyValue
		end
		
		_Instance.Parent = Lighting
	end
end

local function IsMapLoaded(MapName)
	return WorkspaceMapFolder["Client"]:FindFirstChild(MapName)
end

local function GetSourceMap(MapName)
	return UtilitiesModule:WaitForChildTimed(ClientMapsFolder, MapName)
end

local function LoadMap(MapName, ...)
	-- CORE
	local SourceMap = GetSourceMap(MapName)
	
	-- Functions
	-- INIT
	if not SourceMap then
		--DebugModule:Print("Cannot find source client map: ".. tostring(MapName))
		return nil
	end
	
	--DebugModule:Print("Loading Client Map: ".. tostring(MapName))
	
	local CloneMap = SourceMap:Clone()
	
	--SourceMap = SourceMap:Clone()
	--[[SourceMap]] CloneMap.Parent = UtilitiesModule:WaitForChildTimed(WorkspaceMapFolder, "Client")
	
	-- Elements
	-- FOLDERS
	local CoreFolder = UtilitiesModule:WaitForChildTimed(CloneMap, "Core")
	
	-- Modules
	local MapModule = require(UtilitiesModule:WaitForChildTimed(CoreFolder, "Map"))
	
	-- Functions
	-- INIT
	local Response = nil
	
	if MapModule and MapModule.Initialise ~= nil then
		Response = MapModule:Initialise(...)
	end
	
	return CloneMap, Response
end

local function CloseMap(MapFolder, ...)
	-- Functions 
	-- INIT
	if not MapFolder then
		return nil
	end
	
	-- Elements
	-- FOLDERS
	local CoreFolder = UtilitiesModule:WaitForChildTimed(MapFolder, "Core")

	-- Modules
	local MapModule = require(UtilitiesModule:WaitForChildTimed(CoreFolder, "Map"))

	-- Functions
	-- INIT
	--DebugModule:Print("Destroying Client Map: ".. tostring(MapFolder.Name))

	
	if MapModule and MapModule.End ~= nil then
		MapModule:End(...)
	end
	
	MapFolder:Destroy()
end

local function UnloadMap(MapName, ...)
	-- Functions
	-- INIT
	local FoundMapFolder = IsMapLoaded(MapName)
	
	if not FoundMapFolder then
		return nil
	end
	
	return CloseMap(FoundMapFolder, ...)
end

local function UnloadAllMaps(Wait)
	-- CORE
	local NumberOfMapsToEnd = #WorkspaceMapFolder["Client"]:GetChildren()	
	local Finished = 0
	
	-- Functions
	-- INIT
	for i, MapFolder in pairs(WorkspaceMapFolder["Client"]:GetChildren()) do
		coroutine.wrap(function()
			CloseMap(MapFolder)
			Finished += 1
		end)()
	end
	
	if Wait then
		repeat
			task.wait()
		until Finished >= NumberOfMapsToEnd
	end
end


-- DIRECT
local function GetMapRaycastBlacklistFolders()
	-- Functions
	-- INIT
	local CurrentMap = GetCurrentServerMap()

	if not CurrentMap then
		return {}
	end

	return {CurrentMap["Spawns"], CurrentMap["Contents"]["Collections"]:FindFirstChild("Death Zone"), CurrentMap["Contents"]["Collections"]:FindFirstChild("SafeDeathZone")}
end

-- DIRECT
function MapModule.GetCurrentServerMap()
	return GetCurrentServerMap()
end

function MapModule.GetMapRaycastBlacklistFolders()
	return GetMapRaycastBlacklistFolders()
end

function MapModule.ChangeLighting(NilParam, LightingInfo)
	return ChangeLighting(LightingInfo)
end

function MapModule.ResetLighting()
	return ResetLighting()
end

function MapModule.UnloadMap(NilParam, MapName, ...)
	return UnloadMap(MapName, ...)
end

function MapModule.UnloadAllClientMaps()
	return UnloadAllMaps()
end

function MapModule.LoadMap(NilParam, MapName, ...)
	return LoadMap(MapName, ...)
end

function MapModule.IsMapLoaded(NilParam, MapName)
	return IsMapLoaded(MapName)
end


return MapModule