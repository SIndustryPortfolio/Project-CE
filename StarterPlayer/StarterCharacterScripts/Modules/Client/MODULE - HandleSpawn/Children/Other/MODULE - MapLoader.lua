local MapLoaderModule = {}

-- Dirs
local ServerMapsFolder = workspace:WaitForChild("Map")["Server"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local MapsModule = require(ModulesFolder["Maps"])
local SettingsModule = require(ModulesFolder["Settings"])

-- CORE
local Connections = {}

-- Services
local Lighting = game:GetService("Lighting")

-- Functions
-- MECHANICS
local function SetupMapLighting(MapFolder)
	if not MapFolder then
		return nil
	end
	
	-- Core
	local ContentsFolder = MapFolder:WaitForChild("Contents")
	local SettingsFolder = ContentsFolder:FindFirstChild("Settings") --UtilitiesModule:WaitForChildTimed(ContentsFolder, "Settings")
	
	if not SettingsFolder then
		return nil
	end
	
	local LightingFolder = SettingsFolder:FindFirstChild("Lighting") --UtilitiesModule:WaitForChildTimed(SettingsFolder, "Lighting")
	
	-- Functions
	-- INIT
	if not LightingFolder or not SettingsModule:GetSettingValue("Video", "MapLighting", true) then
		return nil
	end
	
	for i, Sky in pairs(LightingFolder:GetChildren()) do
		local SkyClone = Sky:Clone()
		SkyClone.Name = MapFolder.Name
		SkyClone.Parent = Lighting
	end
end

local function RemoveMapLighting(MapFolder)
	-- Functions
	-- INIT
	if MapFolder == nil then
		return nil
	end
	
	for i, Sky in pairs(Lighting:GetChildren()) do
		if Sky.Name == MapFolder.Name then
			Sky:Destroy()
		end
	end
end

local function SetupMap(MapFolder)
	if not MapFolder then
		return nil
	end
	
	-- Functions
	-- INIT
	RemoveMapLighting(MapFolder)
	SetupMapLighting(MapFolder)
end


local function RemoveMap(MapFolder)
	-- Functions
	-- INIT
	RemoveMapLighting(MapFolder)
end

local function Initialise()
	UtilitiesModule:DisconnectConnections(Connections)
	
	-- CORE
	local MapLightingValue = SettingsModule:GetSettingValueInstance("Video", "MapLighting")
	
	-- Functions
	-- DIRECT
	local Connection1 = ServerMapsFolder.ChildAdded:Connect(function(MapFolder)
		return SetupMap(MapFolder)
	end)
	
	local Connection2 = ServerMapsFolder.ChildRemoved:Connect(function(MapFolder)
		return RemoveMap(MapFolder)
	end)
	
	--
	
	local Connection3 = nil
	
	if MapLightingValue then
		Connection3 = MapLightingValue:GetPropertyChangedSignal("Value"):Connect(function()
			if SettingsModule:GetSettingValue("Video", "MapLighting", true) then
				SetupMapLighting(ServerMapsFolder:FindFirstChildOfClass("Folder"))
			else
				RemoveMapLighting(ServerMapsFolder:FindFirstChildOfClass("Folder"))
			end
		end)
	end
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	table.insert(Connections, Connection3)
	
	
	-- INIT
	SetupMap(ServerMapsFolder:FindFirstChildOfClass("Folder"))
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ServerMapsFolder = nil
	ModulesFolder = nil
	--
	Player = nil
	--
	UtilitiesModule = nil
	MapsModule = nil
	SettingsModule = nil
	--
	Connections = nil
	--
	Lighting = nil
	
end

-- DIRECT
function MapLoaderModule.GarbageCollect()
	GarbageCollect()
end

function MapLoaderModule.Initialise()
	return Initialise()
end

function MapLoaderModule.End()
	return End()
end

return MapLoaderModule