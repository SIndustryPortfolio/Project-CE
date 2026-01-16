local SpawnScrapModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ObjectPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Objects"]
local DumpsFolder = workspace:WaitForChild("Dump")
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Functions
-- MECHANICS
local function GetScrapArray(ModelName)
	-- CORE
	local Scrap = {}

	-- Functions
	-- INIT
	for i, ScrapPart in pairs(ObjectPartsFolder:WaitForChild(ModelName):WaitForChild("Scrap"):GetChildren()) do
		table.insert(Scrap, ScrapPart:Clone())
	end

	return Scrap
end

local function SpawnScrapInstances(Model, Position)
	-- CORE
	local ScrapArray = GetScrapArray(Model.Name)

	local RandomXOffset = math.random(-(3 * 100), 3 * 100) / 100
	local RandomYOffset = math.random(-(2 * 100), 2 * 100) / 100
	local RandomZOffset = math.random(-(3 * 100), 3 * 100) / 100

	-- Elements
	-- PARTS
	local PartToBaseOff = nil

	if not Position then
		--[[if Model:IsA("Model") then
			PartToBaseOff = Model.PrimaryPart
		else
			PartToBaseOff = Model
		end]]
		
		PartToBaseOff = UtilitiesModule:GetPartToShift(Model)
	end

	-- Functions
	-- INIT
	for i, ScrapPart in pairs(ScrapArray) do
		pcall(function()
			if not Position then
				ScrapPart.Position = PartToBaseOff.Position
			else
				ScrapPart.Position = Position
			end

			ScrapPart.Position += Vector3.new(RandomXOffset, RandomYOffset, RandomZOffset)

			ScrapPart.Parent = UtilitiesModule:WaitForChildTimed(DumpsFolder, "Misc")

			--DebrisService:AddItem(ScrapPart, 20)
			DebrisModule:AddItem(ScrapPart, 20)
		end)
	end

	return ScrapArray
end

-- DIRECT
function SpawnScrapModule.Initialise(NilParam, ObjectsModule, Model, Position)
	return SpawnScrapInstances(Model, Position)
end

function SpawnScrapModule.End()
	
end

return SpawnScrapModule