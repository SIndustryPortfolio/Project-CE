local SetCollisionGroupModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local CamoInfoModule = require(InfoModulesFolder["Camos"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function SetCollisionGroup(Part, GroupName)
	-- Functions
	-- INIT
	local Parts = UtilitiesModule:GetAllPartsIncludingParent(Part)
	
	for i, Part in pairs(Parts) do
		local Success, Error = pcall(function()
			--return PhysicsService:SetPartCollisionGroup(Part, GroupName)
			Part.CollisionGroup = GroupName
		end)
		
		--[[if not Success then
			DebugModule:Print("SetCollissionGroup | Error: ".. tostring(Error).. " | Part: ".. tostring(Part))
		else
			DebugModule:Print("SetCollissionGroup | Setting part group | Part: ".. tostring(Part).. " | GroupName: ".. tostring(GroupName))
		end]]
	end
	
	--[[if Part:IsA("Model") then
		local Success, Error = pcall(function()
			Part.CollisionGroup = GroupName
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | SetCollisionGroup | Error: ".. tostring(Error))
		end
	end]]
end

local function Initialise(ObjectsModule, Part, GroupName)
	-- Functions
	-- INIT
	SetCollisionGroup(Part, GroupName)
end

-- DIRECT
function SetCollisionGroupModule.Initialise(NilParam, ObjectsModule, Part, GroupName)
	return Initialise(ObjectsModule, Part, GroupName)
end

function SetCollisionGroupModule.End()
	
end

return SetCollisionGroupModule