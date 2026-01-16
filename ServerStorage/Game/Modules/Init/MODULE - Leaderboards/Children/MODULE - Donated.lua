local BoardModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local GameGlobalLeaderboardFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["GlobalLeaderboard"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- FOLDERS
local LeaderboardFolder = UtilitiesModule:WaitForChildTimed(GameGlobalLeaderboardFolder, script.Name)

-- Functions
-- MECHANICS
local function DeleteAllFields()
	-- Functions
	-- INIT
	LeaderboardFolder:ClearAllChildren()
end

local function BuildNewFields(DataFields)
	-- Functions
	-- INIT
	for i, Field in pairs(DataFields or {}) do
		local IndexFolder = Instance.new("Folder")
		IndexFolder.Name = tostring(i)
		IndexFolder.Parent = LeaderboardFolder
		
		local ValueInstance = Instance.new("NumberValue")
		ValueInstance.Name = Field["key"]
		ValueInstance.Value = Field["value"]
		ValueInstance.Parent = IndexFolder
		
		--[[for x, j in pairs(Field) do
			DebugModule:Print("Field | Index: ".. tostring(x).. " | Value: ".. tostring(j))
		end]]
	end
end

local function Update(DataFields)
	-- Functions
	-- INIT
	DeleteAllFields()
	BuildNewFields(DataFields)
end

-- DIRECT
function BoardModule.Update(NilParam, DataFields)
	return Update(DataFields)
end

return BoardModule