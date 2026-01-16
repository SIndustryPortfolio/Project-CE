local PowerUpDropsModule = {}

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
local function Initialise(PowerUpDropModel)
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Initialise | PowerUpDropModel: ".. tostring(PowerUpDropModel))
	CharacterProcessRemote:FireServer("Collections", "Power Up Drop", "PickUp", PowerUpDropModel)
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
function PowerUpDropsModule.Initialise(NilParam, Child)
	Initialise(Child)
end

function PowerUpDropsModule.Finsih()
	GarbageCollect()
end

return PowerUpDropsModule