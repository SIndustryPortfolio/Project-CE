local ObjectsInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function ObjectsInfoModule.GetObjectInfo(NilParam, ObjectName)
	return RequiredModules[ObjectName]
	
	--[[plocal Success, RequiredModule = pcall(function()
		return require(UtilitiesModule:WaitForChildTimed(script, ObjectName))
	end)

	if Success then
		return RequiredModule
	else
		--print("Error: ".. tostring(RequiredModule))
		--DebugModule:PrintRequiredModule, "Error")
	end]]
end


-- INIT
RunSubModules()

return ObjectsInfoModule