local ApplyCamoModule = {}

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
local function ApplyTexture(Part, CamoName)
	-- CORE
	local CamoInfo = CamoInfoModule:GetInfo(CamoName) --CamoInfoModule:GetCamoInfo(CamoName)
	--local Textures = {}
	
	-- Functions
	-- INIT
	local _Faces = {"Front", "Top", "Back", "Left", "Right", "Bottom"}
	
	for i, Face in pairs(_Faces) do
		local Texture = Instance.new("Texture")
		Texture.Name = Face
		Texture.Face = Face
		Texture.Texture = CamoInfo["Wrap"]["Id"]
		Texture.Parent = Part
		
		--table.insert(Textures, Texture)
	end
	
	--return Textures
end

local function Initialise(ObjectsModule, WeaponModel, CamoName, IsViewport)
	-- Elements
	-- FOLDERS
	local ColourableFolder = WeaponModel:FindFirstChild("Colourable")
	
	-- CORE
	--local AllTextures = {}
	local CamoInfo = CamoInfoModule:GetInfo(CamoName) --CamoInfoModule:GetCamoInfo(CamoName)
	
	-- Functions
	-- INIT
	if not CamoInfo then
		DebugModule:Print(script.Name.. " | No camo info for: ".. tostring(CamoName))
		return nil
	end
	
	ObjectsModule:ObjectProcess("RemoveCamo", WeaponModel)
	
	if not ColourableFolder then
		DebugModule:Print(script.Name.. " | No Colourable Folder for: ".. tostring(WeaponModel))
		return nil
	end
	
	WeaponModel:SetAttribute("Camo", CamoName)
	
	for i, Part in pairs(ColourableFolder:GetChildren()) do
		--[[local _Textures =]] ApplyTexture(Part, CamoName)
		
		--[[for x, Texture in pairs(_Textures) do
			table.insert(AllTextures, Texture)
		end]]
	end
	
	if CamoInfo["Animated"] --[[and not IsViewport]] then
		DebugModule:Print("Apply Camo | Applying animated tag to: ".. tostring(WeaponModel))
		CollectionService:AddTag(WeaponModel, "AnimatedWeaponCamo")
	end
end

-- DIRECT
function ApplyCamoModule.Initialise(NilParam, ObjectsModule, WeaponModel, CamoName, IsViewport)
	return Initialise(ObjectsModule, WeaponModel, CamoName, IsViewport)
end

function ApplyCamoModule.End()
	
end

return ApplyCamoModule