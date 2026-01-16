local GrenadeModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local ConnectionsCache = {}

-- Functions
-- MECHANICS
local function Initialise(GrenadeModel, CharacterToIgnore)
	-- Functions
	-- INIT
	local _Connections = {}
	
	for i, Part in pairs(GrenadeModel:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		local Connection1 = Part.Touched:Connect(function(Hit)
			local TouchCFrame = GrenadeModel.PrimaryPart.CFrame
			
			if Hit:IsDescendantOf(GrenadeModel) or (CharacterToIgnore and Hit:IsDescendantOf(CharacterToIgnore)) then
				return nil
			end
			
			local Humanoid = UtilitiesModule:GetHumanoidFromHit(Hit)
			
			if not Humanoid then
				return nil
			end
			
			DebugModule:Print("Plasma | Sticking onto: ".. tostring(Hit))
			
			UtilitiesModule:DisconnectConnections(_Connections)
			
			GrenadeModel.PrimaryPart.Anchored = true
			GrenadeModel:SetPrimaryPartCFrame(TouchCFrame)
			UtilitiesModule:WeldParts(GrenadeModel.PrimaryPart, Hit)
			GrenadeModel.PrimaryPart.Anchored = false
			
			if game.Players:FindFirstChild(Humanoid.Parent.Name) then
				GrenadeModel:SetAttribute("Stuck", true)
			end
			
			for i, Part in pairs(GrenadeModel:GetChildren()) do
				if not Part:IsA("BasePart") then
					continue
				end
				
				Part.CanCollide = false
			end
		end)
		
		-- Connections
		table.insert(_Connections, Connection1)
	end
	
	if ConnectionsCache[GrenadeModel] then
		UtilitiesModule:DisconnectConnections(ConnectionsCache[GrenadeModel])
	end
	
	ConnectionsCache[GrenadeModel] = _Connections
end

local function End(GrenadeModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(ConnectionsCache[GrenadeModel])
	ConnectionsCache[GrenadeModel] = nil
end

-- DIRECT
function GrenadeModule.Initialise(NilParam, GrenadeModel, CharacterToIgnore)
	return Initialise(GrenadeModel, CharacterToIgnore)
end

function GrenadeModule.End(NilParam, GrenadeModel)
	return End(GrenadeModel)
end

return GrenadeModule