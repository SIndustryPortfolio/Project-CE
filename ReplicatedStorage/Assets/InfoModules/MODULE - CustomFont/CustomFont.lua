local CustomFontInfoModule = {}

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
function CustomFontInfoModule.GetCustomFontInfo(NilParam, FontName)
	return RequiredModules[FontName] --require(UtilitiesModule:WaitForChildTimed(script, FontName))
end

-- INIT
RunSubModules()

return CustomFontInfoModule