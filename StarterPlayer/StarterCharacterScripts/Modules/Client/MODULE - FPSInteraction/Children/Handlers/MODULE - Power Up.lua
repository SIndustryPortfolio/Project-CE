local PowerUpModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Elements
-- FOLDERS
local CharacterClientServerRemotesFolder = Character["Remotes"]["ClientServer"]["Remotes"]

-- Remotes
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function Initialise(PowerUpModel)
	-- Functions
	-- INIT
	----DebugModule:Print"Touched Weapon: ".. tostring(WeaponModel.Name))
	CharacterProcessRemote:FireServer("PickupPowerUp", PowerUpModel)
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	ModulesFolder = nil
	--
	CharacterClientServerRemotesFolder = nil
	--
	CharacterProcessRemote = nil
	--
	DebugModule = nil
	
end

-- DIRECT
function PowerUpModule.Initialise(NilParam, PowerUpModel)
	Initialise(PowerUpModel)
end

function PowerUpModule.GarbageCollect()
	GarbageCollect()
end

return PowerUpModule