local ThrowGrenadeModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local PartsGrenadesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Grenades"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])
--local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local CharacterActionsInfoModule = require(ServerInfoModulesFolder["CharacterActions"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ServerLobbyModule = require(ServerModulesFolder["Lobby"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local ServerGrenadesModule = require(ServerModulesFolder["Grenades"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local ThrowGrenadeActionCooldownCache = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function SetupGrenadeEffect(GrenadeModel)
	-- CORE
	local BasePart = GrenadeModel.PrimaryPart
	
	-- Functions
	-- INIT
	local Attachment1 = Instance.new("Attachment")
	Attachment1.CFrame = CFrame.new(0, BasePart.Size.Y / 2, 0)
	Attachment1.Parent = BasePart
	
	local Attachment2 = Instance.new("Attachment")
	Attachment2.CFrame = CFrame.new(0, -(BasePart.Size.Y / 2), 0)
	Attachment2.Parent = BasePart
	
	local Trail = Instance.new("Trail")
	Trail.Texture = "rbxassetid://580455093"
	Trail.Color = ColorSequence.new(
	{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50))
	})
	Trail.Lifetime = 1
	Trail.Attachment0 = Attachment1
	Trail.Attachment1 = Attachment2
	Trail.Parent = BasePart
end

local function ForceSwitchGrenadeType(Player)
	-- CORE
	local AllGrenadeTypes = GrenadesInfoModule:GetGrenadeSetting("GrenadeOrder")
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end
	
	for i, GrenadeName in pairs(AllGrenadeTypes) do
		if Character:GetAttributes()[GrenadeName.. "Grenades"] > 0 then
			Character:SetAttribute("EquippedGrenade", GrenadeName)
			break
		end
	end
end

local function ThrowGrenade(CharacterActionsModule, Player, GrenadeType, RayResult)
	-- Elements
	local PlayerCharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- CORE	
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	local HumanoidRootPart = Character.PrimaryPart
	local GrenadeInfo = CharacterActionsInfoModule:GetCharacterActionInfo("Grenade")
	
	local EquippedGrenade = Character:GetAttribute("EquippedGrenade")
	local AmountOfEquippedGrenade = Character:GetAttribute(tostring(EquippedGrenade).. "Grenades")
	
	if table.find(ThrowGrenadeActionCooldownCache, Player) ~= nil then
		return nil
	end
	
	Humanoid:SetAttribute("Grenade", true)
	
	if not RayResult then
		Humanoid:SetAttribute("Grenade", false)
		return nil
	end
	
	if GrenadeType ~= EquippedGrenade then
		Humanoid:SetAttribute("Grenade", false)
		return nil
	end
	
	if AmountOfEquippedGrenade <= 0 then
		Humanoid:SetAttribute("Grenade", false)		
		return nil
	end

	if not EquippedGrenade or not Character or DamageModule:IsPlayerDead(Player) then
		Humanoid:SetAttribute("Grenade", false)
		return nil
	end
	
	table.insert(ThrowGrenadeActionCooldownCache, Player)
	
	-- CORE
	
	-- Functions
	-- INIT	
	local FoundGrenadeModel = PartsGrenadesFolder:FindFirstChild(EquippedGrenade):Clone()
	
	local HandWeld = FoundGrenadeModel:FindFirstChild("HandWeld")
	HandWeld.Part1 = Character["RightHand"]
	FoundGrenadeModel.Parent = workspace:WaitForChild("Dump")["Misc"]
	
	ObjectsModule:ObjectProcess("SetCollisionGroup", FoundGrenadeModel, tostring(Player:GetAttributes()["CollisionGroup"]).. "Grenades")
	PhysicsService:CollisionGroupSetCollidable(tostring(Player:GetAttributes()["CollisionGroup"]).. "Characters", tostring(Player:GetAttributes()["CollisionGroup"]).. "Grenades", false)
	CharacterActionsModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "ThrowGrenade")

	SetupGrenadeEffect(FoundGrenadeModel)
	
	HandWeld.Part1 = nil
	HandWeld.Part0 = nil
	HandWeld:Destroy()
	
	FoundGrenadeModel:SetPrimaryPartCFrame(HumanoidRootPart.CFrame * CFrame.new(0, 2, -(HumanoidRootPart.Size.Z * 1.5)))
	
	Character:SetAttribute(EquippedGrenade.. "Grenades", AmountOfEquippedGrenade - 1)
	
	if Character:GetAttributes()[EquippedGrenade.. "Grenades"] <= 0 then
		ForceSwitchGrenadeType(Player)
	end
	
	--[[local EndPosition = RayResult.Position
	local StartPosition = Character.PrimaryPart.Position
	
	local Direction = (EndPosition - StartPosition).Unit]]
	
	FoundGrenadeModel.PrimaryPart:SetNetworkOwner(Player)	
	
	local Direction = RayResult.Direction + Vector3.new(0, GrenadesInfoModule:GetGrenadeSetting("DirectionalUpThrust"), 0)
	
	FoundGrenadeModel.PrimaryPart.Velocity = Direction * GrenadesInfoModule:GetGrenadeSetting("DirectionalPower") * (math.clamp(RayResult["Distance"] / 20, 1, 1.75))
	
	CollectionService:AddTag(FoundGrenadeModel, "ThrowGrenade")
	
	local Success, Error = pcall(function()
		ServerGrenadesModule:Initialise(FoundGrenadeModel, Character)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Grenade: ".. tostring(FoundGrenadeModel) .." | Error: ".. tostring(Error))
	end
	
	local Connection1 = nil
	
	Connection1 = FoundGrenadeModel.PrimaryPart.Touched:Connect(function()
		for i, Part in pairs(FoundGrenadeModel:GetChildren()) do
			Part.Velocity = Vector3.new()
		end
		
		Connection1:Disconnect()
	end)
	
	--[[coroutine.wrap(function()
		task.wait(math.random(1 * 100, 3 * 100) / 100)
		FoundGrenadeModel.PrimaryPart:SetNetworkOwner(nil)
	end)()]]
	
	Humanoid:SetAttribute("Grenade", false)
	
	coroutine.wrap(function()
		task.wait(2)
		
		if not FoundGrenadeModel or not FoundGrenadeModel.PrimaryPart then
			return nil
		end
		
		if Player then
			FoundGrenadeModel:SetAttribute("Owner", Player.Name)
		end
		
		FoundGrenadeModel.PrimaryPart.Anchored = true
		ServerObjectsModule:ObjectProcess("Explosion", FoundGrenadeModel)
		EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "GrenadeExplosion", FoundGrenadeModel)
		ServerGrenadesModule:End(FoundGrenadeModel)
		DebrisModule:AddItem(FoundGrenadeModel, 1)
		task.wait(1)
		UtilitiesModule:DisconnectConnections({Connection1})
	end)()
	
	local FoundIndex = table.find(ThrowGrenadeActionCooldownCache, Player)
	
	if FoundIndex then
		table.remove(ThrowGrenadeActionCooldownCache, FoundIndex)
	end
end

-- DIRECT
function ThrowGrenadeModule.Initialise(NilParam, ...)
	return ThrowGrenade(...)
end


return ThrowGrenadeModule