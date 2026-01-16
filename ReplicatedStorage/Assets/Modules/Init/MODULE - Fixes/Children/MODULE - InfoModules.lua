local InfoModulesModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- CORE
local ToInitialise = {"DeveloperProducts", "Gamepasses"}

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	for i, ModuleName in pairs(ToInitialise) do
		require(InfoModulesFolder:WaitForChild(ModuleName))
	end
end

-- DIRECT
function InfoModulesModule.Initialise()
	--[[for i, Module in pairs(InfoModulesFolder:GetChildren()) do
		require(Module)
	end	]]
	Initialise()
end

return InfoModulesModule