local GameModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function GameProcess(FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if RequiredModule and RequiredModule.Initialise ~= nil then
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
function GameModule.GameProcess(NilParam, FunctionName, ...)
	return GameProcess(FunctionName, ...)
end

return GameModule