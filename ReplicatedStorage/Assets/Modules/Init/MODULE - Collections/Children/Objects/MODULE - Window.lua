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

local function Initialise(Window)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildTimed(Window, "Humanoid")
	
	-- Functions
	-- DIRECT
	local Connection1 = nil
	
	Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			Connection1:Disconnect()
			SoundsModule:PlaySoundEffectById(ObjectInfo["BreakSound"], nil, UtilitiesModule:GetPartToShift(Window), nil, nil, "Window Break", nil, nil, true)
			End(Window)
		end
	end)
	
	-- INIT
	AddToCache(Window, {Connection1})
end

function End(Window)
	-- Functions
	-- INIT
	RemoveFromCache(Window)
end

-- DIRECT
function TagModule.Initialise(NilParam, Window)
	return Initialise(Window)
end

function TagModule.End(NilParam, Window)
	return End(Window)
end

return TagModule