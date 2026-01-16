local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local ObjectInfo = ObjectsInfoModule:GetObjectInfo(script.Name)
local Connections = {}

-- Functions
-- MECHANICS
local function AddToCache(Model, _Connections)
	-- Functions
	-- INIT
	if Connections[Model] == nil then
		Connections[Model] = {}
	end

	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not Connections[Model] then
		return nil
	end

	UtilitiesModule:DisconnectConnections(Connections[Model])
	Connections[Model] = nil
end

local function Initialise(WoodenPallet)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(WoodenPallet, "Humanoid")
	
	if not Humanoid then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | WoodenPallet: ".. tostring(WoodenPallet).. " | Humanoid: ".. tostring(Humanoid).. " | Error: WoodenPallet has no humanoid")
		return nil
	end
	
	-- Functions
	-- DIRECT
	local Connection1 = nil
	
	Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			Connection1:Disconnect()
			SoundsModule:PlaySoundEffectById(ObjectInfo["BreakSound"], nil, UtilitiesModule:GetPartToShift(WoodenPallet), nil, nil, "Wooden Pallet Break", nil, nil, true)
			End(WoodenPallet)		
		end
	end)
	
	-- INIT
	AddToCache(WoodenPallet, {Connection1})
end

function End(WoodenPallet)
	-- Functions
	-- INIT
	RemoveFromCache(WoodenPallet)
end

-- DIRECT
function TagModule.Initialise(NilParam, WoodenPallet)
	return Initialise(WoodenPallet)
end

function TagModule.End(NilParam, WoodenPallet)
	return End(WoodenPallet)
end

return TagModule