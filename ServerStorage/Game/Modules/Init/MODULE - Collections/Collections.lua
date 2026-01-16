local CollectionsModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])

-- Modules
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Connections = {}
local RequiredModules = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, CategoryFolder in pairs(script:GetChildren()) do
		local _Required = UtilitiesModule:RunSubModules(CategoryFolder, true)
		
		for ModuleName, Module in pairs(_Required) do
			RequiredModules[ModuleName] = Module
		end
	end
end

local function GetTagModule(TagName)
	-- Functions
	-- INIT
	--[[f not script:FindFirstChild(TagName) then
		return nil
	end
	
	local Success, Error = pcall(function()
		return require(UtilitiesModule:WaitForChildTimed(script, TagName))
	end)

	if Success then
		return Error
	else
		--DebugModule:PrintError, "Error")
	end]]
	
	return RequiredModules[TagName]
end

local function TagToggle(Name, Object, Initialise)
	-- Functions
	-- INIT
	ServerObjectsModule:InitialiseObject(Object)
	
	local TagModule = GetTagModule(Name)
	
	if not TagModule then
		DebugModule:Print("Collections | Tag Module doesn't exist: ".. tostring(Name))
		--DebugModule:Print"Tag Module doesn't exist: ".. tostring(Object))
		return nil
	end

	local Success, Error = pcall(function()
		if Initialise then
			return TagModule:Initialise(Object)
		else
			return TagModule:End(Object)
		end
	end)

	if not Success then
		DebugModule:Print(script.Name.. " | TagToggle | Name: ".. tostring(Name).. " | Object: ".. tostring(Object).. " | Initialise: ".. tostring(Initialise).. " | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	end
end

local function ClientRequest(Player, FunctionName, ...)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Client Request | Player: ".. tostring(Player).. " | FunctionName: ".. tostring(FunctionName))
	
	local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
	
	return RequiredModule:ClientRequest(Player, ...)
end

-- DIRECT
function CollectionsModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequest(Player, FunctionName, ...)
end

function CollectionsModule.TagAdded(NilParam, Name, Object)
	return TagToggle(Name, Object, true)
end

function CollectionsModule.TagRemoved(NilParam, Name, Object)
	return TagToggle(Name, Object, false)
end

-- INIT
RunSubModules()

for CollectionName, Module in pairs(RequiredModules) do --for i, CollectionName in pairs(CollectionsInfoModule:GetCollectionInfo("CollectionsOnStart")) do
	-- DIRECT
	local Connection1 = CollectionService:GetInstanceAddedSignal(CollectionName):Connect(function(Object)
		return TagToggle(CollectionName, Object, true)
	end)

	local Connection2 = CollectionService:GetInstanceRemovedSignal(CollectionName):Connect(function(Object)
		return TagToggle(CollectionName, Object, false)
	end)

	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	for i, _Instance in pairs(CollectionService:GetTagged(CollectionName)) do
		TagToggle(CollectionName, _Instance, true)
	end
end

return CollectionsModule