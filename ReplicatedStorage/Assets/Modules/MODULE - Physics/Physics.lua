local PhysicsModule = {}

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


local function HandleServerRequest(ModuleName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[ModuleName] --require(UtilitiesModule:WaitForChildTimed(script, ModuleName))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(unpack(Args))
		end
	end)
	
	if not Success then
		--DebugModule:PrintError, "Error")
	else
		return Error
	end
end

-- DIRECT
function PhysicsModule.ServerRequest(NilParam, ...)
	return HandleServerRequest(...)
end

-- INIT
RunSubModules()

return PhysicsModule