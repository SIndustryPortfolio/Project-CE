local RaycastableModule = {}

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
	-- Functions
	-- INIT
	for i, Part in pairs(WeaponModel:GetDescendants()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		Part.CanTouch = false
		Part.CanQuery = true
	end
end

-- DIRECT
function RaycastableModule.Initialise(NilParam, ObjectsModule, WeaponModel)
	return Initialise(WeaponModel)
end

function RaycastableModule.End()
	
end

return RaycastableModule