local RemoveCamoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local CamoInfoModule = require(InfoModulesFolder["Camos"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function RemoveTexture(Part)
	-- Functions
	-- INIT
	for i, Texture in pairs(Part:GetChildren()) do
		if Texture:IsA("Texture") then
			Texture:Destroy()
		end
	end
end

local function Initialise(WeaponModel)
	-- Elements
	-- FOLDERS
	local ColourableFolder = WeaponModel:FindFirstChild("Colourable")
	
	-- Functions
	-- INIT
	CollectionService:RemoveTag(WeaponModel, "AnimatedWeaponCamo")
	
	if not ColourableFolder then
		DebugModule:Print(script.Name.. " | No Colourable Folder for: ".. tostring(WeaponModel))
		return nil
	end
	
	for i, Part in pairs(ColourableFolder:GetChildren()) do
		RemoveTexture(Part)
	end
end

-- DIRECT
function RemoveCamoModule.Initialise(NilParam, ObjectsModule, WeaponModel)
	return Initialise(WeaponModel)
end

function RemoveCamoModule.End()
	
end

return RemoveCamoModule