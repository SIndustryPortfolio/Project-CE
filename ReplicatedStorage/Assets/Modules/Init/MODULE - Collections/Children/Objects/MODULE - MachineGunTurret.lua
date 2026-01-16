local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local CustomConnections = {}

-- Functions
-- MECHANICS
local function Initialise(Model)
	-- CORE
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	
	-- Elements
	-- MODELS
	local GunModel = UtilitiesModule:WaitForChildTimed(Model, "Gun")
	
	-- PARTS
	local BarrelPart = GunModel["Barrel"]
	
	-- WELDS
	local Weld = UtilitiesModule:WaitForChildOfClass(BarrelPart, "ManualWeld")
	
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Rotating turret")
	
	coroutine.wrap(function()
		local TurretSound = SoundsModule:PlaySoundEffectByName("Guns", "TurretSpinning", nil, BarrelPart, true, {["Volume"] = .1})
		while task.wait() and CustomConnection and CustomConnection.Value do
			Weld.C0 *= CFrame.Angles(math.rad(15), 0, 0)
		end
		TurretSound:Stop()
		TurretSound:Destroy()
	end)()
end

local function End(Model)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections(CustomConnections)
end

-- DIRECT
function TagModule.Initialise(NilParam, Model)
	return Initialise(Model) 
end

function TagModule.End(NilParam, Model)
	return End(Model)
end

return TagModule