local FixesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function RunModule(Module)
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		local RequiredModule = require(Module)
		
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise()
		end
	end)
	
	if not Success then
		DebugModule:Print("Error: ".. tostring(Error))
	end
end

-- INIT
for i, Module in pairs(script:GetChildren()) do
	RunModule(Module)
end

return FixesModule