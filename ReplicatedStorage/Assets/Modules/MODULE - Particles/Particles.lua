local ParticlesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANCIS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end


local function ParticleEffect(ParticleName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[ParticleName] --require(UtilitiesModule:WaitForChildTimed(script, ParticleName))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(unpack(Args))
		end
	end)
	
	if Success then
		return Error
	else
		DebugModule:Print(script.Name.. " | ParticleEffect | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	end
end

-- DIRECT
function ParticlesModule.ParticleEffect(NilParam, ParticleName, ...)
	return ParticleEffect(ParticleName, ...)
end

-- INIT
RunSubModules()

return ParticlesModule