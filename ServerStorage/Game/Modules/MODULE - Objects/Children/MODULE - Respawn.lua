local RespawnModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(UtilitiesModule:WaitForChildTimed(SharedModulesFolder, "Debug"))

-- CORE
local Respawning = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECAHNICS
local function AddTagsToInstance(_Instance, Tags)
	-- Functions
	-- INIT
	for i, TagName in pairs(Tags) do
		if not table.find(CollectionService:GetTags(_Instance), TagName) then
			CollectionService:AddTag(_Instance, TagName)
		end
	end
end

local function ReHealth(Model)
	-- Elements
	-- HUMANOIDS
	local Humanoid = Model:FindFirstChildOfClass("Humanoid")
	
	-- Functions
	-- INIT
	if Humanoid then
		if Humanoid.Health ~= Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end
end

local function StopVelocity(Model)
	-- Functions
	-- INIT
	for i, Part in pairs(Model:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.Velocity = Vector3.new()
		end
	end
end

local function RePosition(Model)
	-- Elements
	-- PARTS
	local PartToShift = UtilitiesModule:GetPartToShift(Model)
	
	if not PartToShift then
		return nil
	end
	
	-- CORE
	local OriginalPosition = PartToShift:GetAttribute("OriginalPosition") --or PartToShift["Origin Position"] --[[+ Vector3.new(0, 1, 0)]]
	local OriginalOrientation = PartToShift:GetAttribute("OriginalOrientation") --or PartToShift["Origin Orientation"]
	local OriginalCFrame = PartToShift:GetAttribute("OriginalCFrame")
	
	-- Funcitons
	-- INIT
	if not OriginalCFrame then
		if OriginalPosition and OriginalOrientation then
			PartToShift.CFrame = CFrame.new(OriginalPosition) * CFrame.Angles(OriginalOrientation.x, OriginalOrientation.y, OriginalOrientation.z) 
		end
	else
		PartToShift.CFrame = OriginalCFrame
	end
	
	PartToShift.Velocity = Vector3.new()
end


local function Initialise(Model, ObjectName)
	if not Model or table.find(Respawning, Model) ~= nil or typeof(Model) ~= "Instance" then
		return nil
	end
	
	----DebugModule:Print"Model: ".. tostring(Model).. "| ObjectName: ".. tostring(ObjectName))
	
	table.insert(Respawning, Model)
	-- CORE
	local Tags = {}

	pcall(function()
		Tags = CollectionService:GetTags(Model)
	end)
	
	local Clone = Model:Clone()
	local OldParent = Model.Parent
	local ObjectInfo = nil
	
	if ObjectName then
		ObjectInfo = ObjectsInfoModule:GetObjectInfo(ObjectName)
	else
		ObjectInfo = ObjectsInfoModule:GetObjectInfo(Model.Name)
	end	
	-- Functions
	-- INIT
	--DebugModule:Print"Respawning: ".. tostring(Model))
	
	coroutine.wrap(function()
		task.wait(ObjectInfo["RespawnTime"])
		
		if OldParent then
			ReHealth(Clone)
			RePosition(Clone)
			StopVelocity(Clone)
			Clone.Parent = OldParent
			AddTagsToInstance(Clone, Tags)
		end
		
		local FoundIndex = table.find(Respawning, Model)
		
		if FoundIndex then
			table.remove(Respawning, FoundIndex)
		end
	end)()
end

-- DIRECT
function RespawnModule.Initialise(NilParam, ObjectsModule, Model, ObjectName)
	return Initialise(Model, ObjectName)
end

return RespawnModule