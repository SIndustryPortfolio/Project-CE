local SoundEffectModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])

-- Functions
-- MECHANICS
local function Initialise(SoundType, SoundName)
	-- Functions
	-- INIT
	SoundsModule:PlaySoundEffectByName(SoundType, SoundName)
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	SoundsModule = nil
	
end

-- DIRECT
function SoundEffectModule.Initialise(NilParam, SoundType, SoundName)
	Initialise(SoundType, SoundName)
end

function SoundEffectModule.GarbageCollect()
	GarbageCollect()
end

return SoundEffectModule