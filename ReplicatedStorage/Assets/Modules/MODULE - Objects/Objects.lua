local ObjectsModule = {}

-- Dirs
local PartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function ChangeProperties(_Instance, Properties)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(Properties) do
		_Instance[PropertyName] = PropertyValue
	end
end

local function InitialiseGenericItem(RootModel)
	-- Functions
	-- INIT
	
end

local function CreateInstancesFromDict(RootModel, Dict)
	-- Functions
	-- INIT
	for InstanceClass, Properties in pairs(Dict) do
		local InstanceToChangePropertiesOf = nil
		
		if InstanceClass == "Root" then
			InstanceToChangePropertiesOf = RootModel
		else
			InstanceToChangePropertiesOf = Instance.new(InstanceClass, RootModel)
		end
		
		ChangeProperties(InstanceToChangePropertiesOf, Properties)
	end
end

local function GetObject(FolderName, ObjectName)
	-- Functions
	-- INIT
	local FoundFolder = UtilitiesModule:WaitForChildTimed(PartsFolder, FolderName)
	
	local ObjectClone = UtilitiesModule:WaitForChildTimed(FoundFolder, ObjectName):Clone()
	local ObjectCoreFolder = ObjectClone:FindFirstChild("Core")
	
	if ObjectCoreFolder then
		return ObjectClone, ObjectCoreFolder:FindFirstChild("Activate")	
	else
		return ObjectClone
	end
	
end

local function ObjectProcess(FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(ObjectsModule, unpack(Args))
		end
	end)
	
	if Success then
		return Error
	else
		--DebugModule:Print)
	end
end

local function LoadObject(Object, ...)
	-- Elements
	-- Folders
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Object, "Core")
	
	-- Modules
	local ObjectModule = require(UtilitiesModule:WaitForChildTimed(CoreFolder, "Object"))
	
	-- Functions
	-- INIT
	return ObjectModule:Initialise(...)
end

local function UnloadObject(Object, ...)
	-- CORE
	local Response
	
	-- Elements
	-- Folders
	local CoreFolder = UtilitiesModule:WaitForChildTimed(Object, "Core")

	-- Modules
	local ObjectModule = require(UtilitiesModule:WaitForChildTimed(CoreFolder, "Object"))

	-- Functions
	-- INIT
	if ObjectModule and ObjectsModule.End ~= nil then
		Response = ObjectModule:End(...)
	end
	
	DebrisModule:AddItem(Object)
	
	return Response
end

-- DIRECT
function ObjectsModule.LoadObject(NilParam, Object, ...)
	return LoadObject(Object, ...)
end

function ObjectsModule.UnloadObject(NilParam, Object, ...)
	return UnloadObject(Object, ...)
end

function ObjectsModule.ObjectProcess(NilParam, FunctionName, ...)
	return ObjectProcess(FunctionName, ...)
end

function ObjectsModule.GetObject(NilParam, FolderName, ObjectName)
	return GetObject(FolderName, ObjectName)
end

function ObjectsModule.CreateInstancesFromDict(NilParam, RootModel, Dict)
	return CreateInstancesFromDict(RootModel, Dict)
end

-- INIT
RunSubModules()

return ObjectsModule