local HealthPackModule = {}

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
local function Initialise(HealthPack)
	-- Functions
	-- INIT
	----DebugModule:Print"Touched Weapon: ".. tostring(WeaponModel.Name))
	CharacterProcessRemote:FireServer("Collections", "Health Pack", "Heal", HealthPack)
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
function HealthPackModule.Initialise(NilParam, Child)
	Initialise(Child)
end

function HealthPackModule.Finsih()
	GarbageCollect()
end

return HealthPackModule