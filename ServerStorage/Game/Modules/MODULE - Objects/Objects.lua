local ObjectsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function ObjectProcess(Name, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[Name] --require(UtilitiesModule:WaitForChildTimed(script, Name))
		
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(ObjectsModule, unpack(Args))
		end
	end)
	
	if not Success then
		--DebugModule:PrintError, "Error")
	else
		return Error
	end
end

local function InitialiseObject(Object)
	-- Elements
	-- PARTS
	local MainPart = UtilitiesModule:GetPartToShift(Object)
	
	if not MainPart or not MainPart:IsA("BasePart") then
		MainPart = UtilitiesModule:WaitForChildTimed(Object, "Base")
	end
	
	----DebugModule:Print"Object: ".. tostring(Object).. " | Parent: ".. tostring(Object.Parent))
	
	--print(Object.ClassName)
	
	if not MainPart or typeof(MainPart) ~= "Instance" then
		return nil
	end
	
	-- CORE
	local PropertiesDict = 
	{
		["OriginalCFrame"] = MainPart.CFrame,
		["OriginalPosition"] = MainPart.Position,
		["OriginalOrientation"] = MainPart.Orientation
	}
	
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(PropertiesDict) do
		if MainPart:GetAttributes()[PropertyName] ~= nil then
			continue
		end
		
		MainPart:SetAttribute(PropertyName, PropertyValue)
	end
end

-- DIRECT
function ObjectsModule.InitialiseObject(NilParam, Object)
	return InitialiseObject(Object)
end

function ObjectsModule.ObjectProcess(NilParam, Name, ...)
	return ObjectProcess(Name, ...)
end

-- INIT
RunSubModules()

return ObjectsModule