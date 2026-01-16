local ApplyVisorColourModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local VisorColoursInfoModule = require(SharedInfoModulesFolder["VisorColours"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
--local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function GetSecondVisorPart(Character)
	-- Functions
	-- INIT
	for i, Model in pairs(Character:GetChildren()) do
		if Model:GetAttributes()["Helmet"] then
			return Model:FindFirstChild("Visor")
		end
	end
end

local function ApplyVisorColour(Character, VisorColourName)
	-- CORE
	local VisorColourInfo = VisorColoursInfoModule:GetInfo(VisorColourName) --VisorColoursInfoModule:GetVisorColourInfo(VisorColourName)
	
	-- Functions
	-- INIT
	if not VisorColourInfo then
		DebugModule:Print("ApplyVisorColour | No visor colour info for: ".. tostring(VisorColourName))
		return nil
	end
	
	local FoundVisorPart = Character:FindFirstChild("Visor")
	local FoundSecondVisorPart = GetSecondVisorPart(Character)
	
	if not FoundVisorPart then
		DebugModule:Print("ApplyVisorColour | No Found Visor Part in Character: ".. tostring(Character))
		return nil
	end
	
	FoundVisorPart.BrickColor = VisorColourInfo["Colour"]
	
	if FoundSecondVisorPart then
		FoundSecondVisorPart.BrickColor = VisorColourInfo["Colour"]
	end
end

-- DIRECT
function ApplyVisorColourModule.Initialise(NilParam, CharacterModule, Character, VisorColourName)
	return ApplyVisorColour(Character, VisorColourName)
end

return ApplyVisorColourModule