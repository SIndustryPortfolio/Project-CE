local AddAmmoModule = {}

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
local function Initialise(AmmoContainer)
	-- Functions
	-- INIT
	----DebugModule:Print"Touched Weapon: ".. tostring(WeaponModel.Name))
	CharacterProcessRemote:FireServer("Collections", "Ammo Container", "AddAmmo", AmmoContainer)
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
function AddAmmoModule.Initialise(NilParam, Child)
	Initialise(Child)
end

function AddAmmoModule.Finsih()
	GarbageCollect()
end

return AddAmmoModule