local FixesModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function RunModule(ModuleInstance)
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		local RequiredModule = require(ModuleInstance)
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise()
		end
	end)
	
	if Success then
		return Error
	else
		--DebugModule:PrintError, "Error")
	end
end

-- INIT
for i, ModuleInstance in pairs(script:GetChildren()) do
	coroutine.wrap(function()
		RunModule(ModuleInstance)
	end)()
end


return FixesModule