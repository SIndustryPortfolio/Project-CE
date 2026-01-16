local OnTouchModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent

-- EXT
local DumpFolder = workspace:WaitForChild("Dump")
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local MapsModule = require(ModulesFolder["Maps"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local Connections = {}

-- Functions
-- MECHANICS


local function IsHitValid(Hit)
	-- Functions
	-- INIT
	if not Hit then
		return false
	end
	
	local ServerMap = MapsModule:GetCurrentServerMap()
	
	if ServerMap then
		if Hit:IsDescendantOf(ServerMap["Dump"]) or Hit:IsDescendantOf(workspace["Temporary"]) then
			return false
		end
	end
	
	return true
end

local function Initialise(FPSInteraction)
	-- Functions
	-- DIRECT
	for i, Part in pairs(Character:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end

		local Connection1 = Part.Touched:Connect(function(Hit)
			if not IsHitValid(Hit) then
				return false
			end
			
			local FoundModel = UtilitiesModule:GetRootModel(Hit) --Hit:FindFirstAncestorOfClass("Model")
			
			if FoundModel then
				return FPSInteraction:OnTouch(FoundModel, true)		
			else
				return FPSInteraction:OnTouch(Hit, true)		
			end
		end)

		-- Connections
		table.insert(Connections, Connection1)
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	DumpFolder = nil
	ModulesFolder = nil
	--
	UtilitiesModule = nil
	--
	Connections = nil
	
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function OnTouchModule.Initialise(NilParam, FPSInteractionModule)
	Initialise(FPSInteractionModule)
end

function OnTouchModule.GarbageCollect()
	GarbageCollect()
end

function OnTouchModule.End()
	End()
end

return OnTouchModule