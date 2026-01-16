local CameraShakeModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local CustomConnections = {}

-- Functions
-- MECHANICS
local function Initialise(CameraModule, Intensity, Duration, Type, AngleBased)
	-- CORE
	local TimeNow = tick()
	local TimeDifference = 0
	local Camera = CameraModule:GetCamera()
	
	-- Functions
	-- INIT
	--DebugModule:Print"Camera Shaking | Type: ".. tostring(Type))
	
	if CustomConnections[Type] ~= nil then
		UtilitiesModule:DisconnectCustomConnections(CustomConnections[Type])	
	end 
		
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	CustomConnections[Type] = {CustomConnection}
	
	coroutine.wrap(function()
		while TimeDifference < Duration and task.wait() and CustomConnection and CustomConnection.Value and Camera do
			local RandomX = math.random(-(Intensity * 100), Intensity * 100) / 100
			local RandomY = math.random(-(Intensity * 100), Intensity * 100) / 100

			if not AngleBased then
				Camera:SetAttribute("Offset", Vector3.new(RandomX, RandomY, 0))
			else
				Camera:SetAttribute(AngleBased.. "AngleOffset", (Camera:GetAttribute(AngleBased.. "AngleOffset") or 0) + RandomY)
			end
			
			TimeDifference = (tick() -  TimeNow)
		end
		
		if CustomConnection then
			UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
		
		if not AngleBased then
			Camera:SetAttribute("Offset", Vector3.new())
		else
			Camera:SetAttribute(AngleBased.. "AngleOffset", 0)
		end
	end)()
end

local function Reset()
	-- Functions
	-- INIT
	for Type, CustomConnectionsTable in pairs(CustomConnections) do
		UtilitiesModule:DisconnectCustomConnections(CustomConnectionsTable)
	end
	
	CustomConnections = {}
end


local function End(CameraModule, Type)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections(CustomConnections[Type])
end

-- DIRECT
function CameraShakeModule.Initialise(NilParam, CameraModule, Intensity, Duration, Type, AngleBased)
	return Initialise(CameraModule, Intensity, Duration, Type, AngleBased)
end

function CameraShakeModule.End(NilParam, CameraModule, Type)
	return End(CustomConnections[Type])
end

function CameraShakeModule.Reset()
	return Reset()
end

return CameraShakeModule