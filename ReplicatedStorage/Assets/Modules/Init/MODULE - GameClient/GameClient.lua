local GameClientModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, ModuleInstance in pairs(script:GetChildren()) do
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				local RequiredModule = require(ModuleInstance)
				
				if RequiredModule.Initialise ~= nil then
					RequiredModule:Initialise()
				end
				
				return RequiredModule
			end)
			
			if not Success then
				DebugModule:Print("GameClient | Module: "..tostring(ModuleInstance.Name).. " | Error: ".. tostring(Error))	
				--DebugModule:PrintError, "Error")
			else
				RequiredModules[ModuleInstance.Name] = Error
				return Error
			end
		end)()
	end
end

local function GameClientProcess(ModuleName, FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[ModuleName]
		
		if RequiredModule then
			return RequiredModule[FunctionName](nil, unpack(Args))
		else
			DebugModule:Print(script.Name.. " | Required module doesn't exist | Module: ".. tostring(ModuleName))
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | GameClientProcess | Error: ".. tostring(Error))
	else
		return Error
	end
end

-- DIRECT
function GameClientModule.GameClientProcess(NilParam, ...)
	return GameClientProcess(...)
end

function GameClientModule.Initialise()
	-- Functions
	-- INIT
	RunSubModules()
	InterfacesModule:LoadFirstPage("Main", "SplashScreen")
end

return GameClientModule