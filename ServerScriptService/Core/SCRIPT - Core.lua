-- Dirs
local GameModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function RunInitModule(ModuleInstance)
	-- Functions
	-- INIT
	coroutine.wrap(function()
		local Success, Error = pcall(function()
			DebugModule:Print("Init | Requiring: ".. tostring(ModuleInstance))
			local RequiredModule = require(ModuleInstance)
			
			if RequiredModule.Initialise ~= nil then
				RequiredModule:Initialise()
			end
			
			DebugModule:Print("Init | Required: ".. tostring(ModuleInstance))
		end)

		if not Success then
			DebugModule:Print(script.Name.. " | RunInitModule | Error: ".. tostring(Error))
			--print("Error: ".. tostring(Error))
		end
	end)()
end

-- INIT
for i, Module in pairs(GameModulesInitFolder:GetChildren()) do
	RunInitModule(Module)
end