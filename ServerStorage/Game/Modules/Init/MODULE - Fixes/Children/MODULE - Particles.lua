local FixModule = {}

-- Dirs
local ParticlesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Particles"]

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	for i, Particle in pairs(ParticlesFolder:GetDescendants()) do
		if Particle:IsA("BasePart") then
			Particle.CanCollide = false
		end
	end
end

-- INIT
Initialise()

return FixModule