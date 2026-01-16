local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CACHE
local Cache = {}

-- Functions
-- MECHANICS
local function Initialise(DropModel)
	-- CORE
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	-- Functions
	-- INIT
	Cache[DropModel] = {CustomConnection}
	
	local PartToShift = nil
	
	repeat
		PartToShift = UtilitiesModule:GetPartToShift(DropModel)
		task.wait()
	until not DropModel or (PartToShift and PartToShift:IsA("BasePart"))
	
	if not DropModel then
		return nil
	end
	
	local Success, Error = pcall(function()
		local Attachment = EffectsHandlerModule:LoadParticleEmitter(PartToShift, "SunRays", nil, true)
		EffectsHandlerModule:ToggleParticleEmitters(Attachment, true, nil)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
	
	coroutine.wrap(function()
		while DropModel and CustomConnection and CustomConnection.Value and task.wait() do
			if not PartToShift then
				PartToShift = UtilitiesModule:GetPartToShift(DropModel)
			end
			
			if PartToShift then
				PartToShift.CFrame *= CFrame.Angles(0, math.rad(2), 0)
			else
				continue
			end
		end
	end)()
end
local function End(DropModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections(Cache[DropModel])
	
	Cache[DropModel] = nil
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule