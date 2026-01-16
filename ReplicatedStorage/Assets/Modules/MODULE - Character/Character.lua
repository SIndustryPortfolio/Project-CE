local CharacterModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SpartansPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Spartans"]
local ArmourPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Armours"]

-- InfoModules
--local ArmourInfoModule = require(InfoModulesFolder["Armour"])

-- Modules
local ShortcutsModule = require(ModulesFolder["Shortcuts"])
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


--[[local function SetPropertiesFromTable(Part, Properties)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(Properties) do
		pcall(function()
			Part[PropertyName] = PropertyValue
		end)
	end
end]]

local function IsExcessArmourPart(Part)
	-- Functions
	-- INIT
	for i, Folder in pairs(ArmourPartsFolder:GetChildren()) do
		if Folder:FindFirstChild(Part.Name) then
			return true
		end
	end
end

local function RecursiveColourChange(Model, Colour3, VisorBrickColour)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Changing colour of: ".. tostring(Model))
	
	for i, Part in pairs(Model:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		if Part.Name == "Visor" then
			if VisorBrickColour then
				Part.BrickColor = VisorBrickColour
				continue
			end
		end
		
		local ArmourColourDecal = Part:FindFirstChild("ArmourColour")

		if ArmourColourDecal then
			ArmourColourDecal.Color3 = Colour3
		end

		Part.Color = Colour3
	end
end

local function ChangeCharacterColor(Character, Colour3, SecondaryColour3, VisorBrickColour)
	-- Functions
	-- INIT
	for i, Part in pairs(Character:GetChildren()) do
		if not Part:IsA("BasePart") then
			if IsExcessArmourPart(Part) then
				RecursiveColourChange(Part, Colour3, VisorBrickColour)
			end
			continue
		end
		
		if Part.Material == Enum.Material.Neon then
			Part.Color = SecondaryColour3
			continue
		end
		
		if Part.Name == "Visor" then
			if VisorBrickColour then
				Part.BrickColor = VisorBrickColour
				continue
			end
		end
		
		local ArmourColourDecal = Part:FindFirstChild("ArmourColour")
		
		if ArmourColourDecal then
			ArmourColourDecal.Color3 = Colour3
		end
		
		Part.Color = Colour3
	end
end

local function SetCharacterAppearance(Character, TeamName, SecondaryColour, VisorBrickColour)
	if not TeamName then
		return nil
	end
		
	-- CORE
	--local TeamToTextureInfo = ArmourInfoModule:GetTeamToTextureInfo(TeamName)
	local TeamColour3 = UtilitiesModule:TypeToColor3(TeamName) --TypeToColor3[typeof(TeamName)](TeamName)
	local SecondaryColour3 = UtilitiesModule:TypeToColor3(SecondaryColour) --TypeToColor3[typeof(SecondaryColour)](SecondaryColour)	
	
	DebugModule:Print(script.Name.. " | Setting Character Appearance | TeamColor3: ".. tostring(TeamColour3).. " | SecondaryColour3: ".. tostring(SecondaryColour3))
	
	--[[if typeof(TeamName) == "string" then
		TeamColour3 = BrickColor.new(TeamName).Color
	elseif typeof(TeamName) == "BrickColor" then
		TeamColour3 = TeamName.Color
	elseif typeof(TeamName) == "Color3" then
		TeamColour3 = TeamName
	end]]
	
	-- Functions
	-- INIT
	ChangeCharacterColor(Character, TeamColour3, SecondaryColour3, VisorBrickColour)
	
	--[[for PartName, AppearanceInfo in pairs(TeamToTextureInfo) do
		-- Elements
		-- PARTS
		local Part = UtilitiesModule:WaitForChildTimed(Character, PartName)
		
		-- Properties
		SetPropertiesFromTable(Part, AppearanceInfo)
	end]]
end

local function CharacterProcess(ProcessName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[ProcessName] --require(UtilitiesModule:WaitForChildTimed(script, ProcessName))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(CharacterModule, unpack(Args))
		end
	end)
	
	if not Success then
		--DebugModule:PrintError, "Error")
	else
		return Error
	end
end

-- DIRECT
function CharacterModule.CharacterProcess(NilParam, ProcessName, ...)
	return CharacterProcess(ProcessName, ...)
end

function CharacterModule.SetCharacterAppearance(NilParam, ...)
	return SetCharacterAppearance(...)
end

-- INIT
RunSubModules()

return CharacterModule