local AnchoredModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(_Instance, Toggle)
	-- Functions
	-- INIT
	--DebugModule:Print"Anchored | Instance: ".. tostring(_Instance).. " | Toggle: ".. tostring(Toggle))
	
	local PartsToHandle = {}
	
	if _Instance:IsA("BasePart") then
		table.insert(PartsToHandle, _Instance)
	end
	
	PartsToHandle = UtilitiesModule:CombineTables(PartsToHandle, _Instance:GetDescendants()) --{unpack(PartsToHandle), unpack(_Instance:GetDescendants())}
	
	for i, Part in pairs(PartsToHandle) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		Part.Anchored = Toggle
	end
end

-- DIRECT
function AnchoredModule.Initialise(NilParam, _Instance, Toggle)
	return Initialise(_Instance, Toggle)
end

return AnchoredModule