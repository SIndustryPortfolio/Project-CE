local LeaderboardsInitModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local WebhookModule = require(ServerModulesFolder["Webhook"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local OrderedDataStoreModule = require(ServerModulesFolder["OrderedDataStore"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function Update()
	-- Functions
	-- INIT
	WebhookModule:LogAll()
	
	for ModuleName, RequiredModule in pairs(RequiredModules) do
		RequiredModule:Update(OrderedDataStoreModule:GetDataFields(ModuleName, false))
	end
end

local function Initialise()
	-- Functions
	-- INIT
	RunSubModules()
	
	coroutine.wrap(function()
		while task.wait() do
			Update()
			task.wait(UtilitiesModule:MinutesToSeconds(1))
		end
	end)()
end

-- DIRECT
function LeaderboardsInitModule.Initialise()
	return Initialise()
end

return LeaderboardsInitModule