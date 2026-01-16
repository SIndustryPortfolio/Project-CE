local DropGrenadeModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGrenadesPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Grenades"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Info Modules
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])

-- Modules
local PhysicsModule = require(SharedModulesFolder["Physics"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SoundsModule = require(SharedModulesFolder["Sounds"])

-- CORE
local MaxStudsOffset = 3

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
--[[[local function RefreshWeapon(GunModel)
	-- Functions
	-- INIT
	local HandWeld = GunModel:FindFirstChild("HandWeld") --UtilitiesModule:WaitForChildTimed(GunModel, "HandWeld")
	
	if HandWeld then
		HandWeld.Part0 = nil
		HandWeld.Part1 = nil
	end
	
	PhysicsModule:ServerRequest("CanCollide", GunModel, true)
end]]

local function DropGrenade(Character, GrenadeName)
	-- Functions
	-- INIT
	local FoundGrenadeModel = SharedGrenadesPartsFolder:FindFirstChild(GrenadeName)
	
	if FoundGrenadeModel then
		local RandomX = math.random(-(MaxStudsOffset * 100), MaxStudsOffset * 100) / 100
		local RandomZ = math.random(-(MaxStudsOffset * 100), MaxStudsOffset * 100) / 100
		
		local GrenadeClone = FoundGrenadeModel:Clone()
		GrenadeClone:SetAttribute("NoneRespawnable", true)
		GrenadeClone.Parent = DumpFolder["Grenades"]
		FoundGrenadeModel:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.new(RandomX, Character.PrimaryPart.CFrame, RandomZ))
		SoundsModule:PlaySoundEffectByName("CharacterActions", "DropGrenade", nil, FoundGrenadeModel.PrimaryPart)
		DebrisModule:AddItem(GrenadeClone, 30, {Parent = DumpFolder["Grenades"]})

	end	
	Character:SetAttribute(GrenadeName.. "Grenades", Character:GetAttribute(GrenadeName.. "Grenades") - 1)
end

local function DropGrenades(CharacterActionsModule, Player)
	-- Functions
	-- INIT
	--DebugModule:Print"Dropping weapon | Player: ".. tostring(Player.Name))
	
	local Character = UtilitiesModule:GetCharacter(Player)
	--local EquippedWeaponName = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	
	for GrenadeName, GrenadeInfo in pairs(GrenadesInfoModule:GetAllGrenadeInfo()) do
		local AmountOfGrenadesPlayerHas = Character:GetAttribute(GrenadeName.. "Grenades")
		
		if AmountOfGrenadesPlayerHas >= 1 then
			for i = 1, AmountOfGrenadesPlayerHas do
				DropGrenade(Character, GrenadeName)
			end
		end
	end
	
	--[[local OldWeaponModelInCurrentState = UtilitiesModule:WaitForChildTimed(Character, EquippedWeaponName)
	
	if not OldWeaponModelInCurrentState then
		--DebugModule:Print"Dropping weapon | Player: ".. tostring(Player.Name).. " | Can't find weapon!")
		return nil
	end
	
	local WeaponModelInCurrentState = OldWeaponModelInCurrentState:Clone()
	RefreshWeapon(WeaponModelInCurrentState)
	
	OldWeaponModelInCurrentState:Destroy()
	
	WeaponModelInCurrentState.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Weapons")]]
end

-- DIRECT
function DropGrenadeModule.Initialise(NilParam, ...)
	return DropGrenades(...)
end

return DropGrenadeModule