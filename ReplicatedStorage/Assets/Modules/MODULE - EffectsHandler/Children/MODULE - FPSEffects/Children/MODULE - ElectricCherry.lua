local ElectricCherryModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebrisModule = require(ModulesFolder["Debris"])

-- Functions
-- MECHANICS
local function Initialise(EffectsHandlerModule, _Character)
	-- Functions
	-- INIT
	if typeof(_Character) ~= "table" then
		_Character = {_Character}
	end
	
	for i, Character in pairs(_Character) do
		local Particle = EffectsHandlerModule:LoadParticleEmitter(Character.PrimaryPart, "ElectricCherry", nil, true)
		EffectsHandlerModule:ToggleParticleEmitters(Particle, true)
		
		local Sound = nil
		
		pcall(function()
			Sound = SoundsModule:PlaySoundEffectById("rbxassetid://2674547670", nil, Character.PrimaryPart)
		end)
		
		DebrisModule:AddItem(Particle, 1)

		if Sound then
			DebrisModule:AddItem(Sound, 1)
		end
	end
end

-- Direct
function ElectricCherryModule.Initialise(NilParm, ...)
	return Initialise(...)
end

return ElectricCherryModule