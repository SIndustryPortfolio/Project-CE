local SpecificGunModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])

-- Connections
local Connections = {}

-- Functions
-- MECHANICS
local function UpdateEnergy(GunModel, ServerGunModel)
	-- Functions
	-- INIT
	if ServerGunModel:GetAttributes()["Energy"] > 0 then
		return nil
	end

	if GunModel:FindFirstChild("Colourable") then	
		DebrisModule:AddItem(GunModel["Colourable"]:FindFirstChild("Blade"))
	end
end

local function Initialise(GunClientModule, GunModel, ServerGunModel)
	-- Functions
	-- DIRECT
	local Connection1 = ServerGunModel:GetAttributeChangedSignal("Energy"):Connect(function()
		return UpdateEnergy(GunModel, ServerGunModel)	
	end)

	-- Connections
	table.insert(Connections, Connection1)
end

local function End()
	-- Functions	
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function SpecificGunModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function SpecificGunModule.End()
	return End()
end

return SpecificGunModule