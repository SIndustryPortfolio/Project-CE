local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local Cache = {}

-- Functions
-- MECHANICS
local function UpdateInstance(_Instance, PropertyName)
	-- Functions
	-- INIT
	local PartToShift = _Instance --UtilitiesModule:GetPartToShift(_Instance)
	
	if _Instance:IsA("Model") then
		PartToShift = UtilitiesModule:GetPartToShift(_Instance)
	end
	
	local PlayerToIgnore = _Instance:GetAttributes()["CFramePlayerToIgnore"]
	
	if PlayerToIgnore and PlayerToIgnore == Player.Name then
		return nil
	end
	
	PartToShift[PropertyName] = _Instance:GetAttribute(PropertyName)
end

local function Initialise(_Instance)
	-- CORE
	local PropertyName = _Instance:GetAttributes()["CFramePropertyName"] or "CFrame"
	
	-- Functions
	-- INIT
	if Cache[_Instance] ~= nil then
		TagModule:End(_Instance)
	end
	
	-- DIRECT
	local Connection1 = nil
	
	local Connection2 = nil
	
	
	if UtilitiesModule:HasProperty(_Instance, "C0") then
		Connection1 = _Instance:GetAttributeChangedSignal("C0"):Connect(function()
			return UpdateInstance(_Instance, "C0")
		end)
		
		Connection2 = _Instance:GetAttributeChangedSignal("C1"):Connect(function()
			return UpdateInstance(_Instance, "C1")
		end)
	else
		Connection1 = _Instance:GetAttributeChangedSignal(PropertyName):Connect(function()
			return UpdateInstance(_Instance, PropertyName)
		end)
	end
	
	-- Connections
	Cache[_Instance] = {Connection1, Connection2}
end

local function End(_Instance)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Cache[_Instance])
	Cache[_Instance] = nil
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule