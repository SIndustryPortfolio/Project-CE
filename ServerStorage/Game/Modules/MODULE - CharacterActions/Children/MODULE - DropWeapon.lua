local DropWeaponModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedWeaponsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Modules
local ObjectsModule = require(SharedModulesFolder["Objects"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SoundsModule = require(SharedModulesFolder["Sounds"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function RefreshWeapon(GunModel)
	-- Functions
	-- INIT
	local HandWeld = GunModel:FindFirstChild("HandWeld") --UtilitiesModule:WaitForChildTimed(GunModel, "HandWeld")
	
	if HandWeld then
		HandWeld.Part0 = nil
		HandWeld.Part1 = nil
	end
	
	PhysicsModule:ServerRequest("CanCollide", GunModel, true)
end

local function DropWeapon(CharacterActionsModule, Player)
	-- Functions
	-- INIT
	--DebugModule:Print"Dropping weapon | Player: ".. tostring(Player.Name))
	
	DebugModule:Print("DropWeapon | Dropping Weapon | Player: ".. tostring(Player))
	
	local Character = nil 
	
	if Player and typeof(Player) == "Instance" and Player:FindFirstChildOfClass("Humanoid") then
		Character = Player
	else
		Character = UtilitiesModule:GetCharacter(Player)
	end
	
	local EquippedWeaponName = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	
	local OldWeaponModelInCurrentState = UtilitiesModule:WaitForChildTimed(Character, EquippedWeaponName)
	
	if not OldWeaponModelInCurrentState then
		DebugModule:Print("DropWeapon | Old weapon in current state not found!")
		--DebugModule:Print"Dropping weapon | Player: ".. tostring(Player.Name).. " | Can't find weapon!")
		return nil
	end
	
	local WeaponModelInCurrentState = OldWeaponModelInCurrentState:Clone()
	RefreshWeapon(WeaponModelInCurrentState)
	
	OldWeaponModelInCurrentState:Destroy()
	
	ObjectsModule:ObjectProcess("Raycastable", WeaponModelInCurrentState)
	WeaponModelInCurrentState.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Weapons")
	
	SoundsModule:PlaySoundEffectByName("CharacterActions", "DropWeapon", nil, WeaponModelInCurrentState.PrimaryPart)
	
	DebrisModule:AddItem(WeaponModelInCurrentState, 30, {Parent = DumpFolder["Weapons"]})
end

-- DIRECT
function DropWeaponModule.Initialise(NilParam, ...)
	return DropWeapon(...)
end

return DropWeaponModule