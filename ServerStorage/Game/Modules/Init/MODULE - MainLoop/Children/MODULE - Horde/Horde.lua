local InfectionModule = {}

-- Dirs
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local SharedGamePowerUpDropsFolder = SharedGameFolder["PowerUpDrops"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedGameDeployedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Deployed"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]
local SharedPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]

local SharedArmoursFolder = SharedPartsFolder["Armours"]

local SharedWeaponsFolder = SharedPartsFolder["Weapons"]


-- Info Modules
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local PowerUpDropsInfoModule = require(SharedInfoModulesFolder["PowerUpDrops"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local GameModule = require(ServerModulesFolder["Game"])
local MapsModule = require(ServerModulesFolder["Maps"])
local TeamsModule = require(ServerModulesFolder["Teams"])
local CharacterModule = require(SharedModulesFolder["Character"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local WeaponsModule = require(ServerModulesFolder["Weapons"])

local WeaponsModule = require(ServerModulesFolder["Weapons"])

--
local AIZombieModule = require(script["AIZombie"])

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]
local PowerUpsRemote = ServerRemotesFolder["PowerUps"]
local MainRemote = ServerRemotesFolder["Main"]

-- SIGNALS
local CoreSignal = ServerSignalsFolder["Core"]
local CharacterCoreSignal = ServerSignalsFolder["CharacterCore"]
local GameModeSignal = ServerSignalsFolder["GameMode"]

-- CORE
local BossWaveSpawn = 1 -- Every 5 waves
local BossHealthMultiplier = 125 -- Of normal Zombie

local StartRunningWave = 3

local Connections = {}
local RoundConnections = {}

local Zombies = {}

local GameModeFolder = nil
local ZombieMultiplier = 1.25
local ShieldMultiplier = 1.125
local ScorePerKill = 50
local ScorePerAssist = 25
local StartZombies = 15
local GrenadesPerRound = 2

local MaxSpawnAtOnce = 50

local IsNuking = false
local IsSlowdown  = false
local IsInstaKill = false
local IsDoublePoints = false

local WaveTo = 10

local LastPowerUpDropTimes = {}

local ElementCache = {}

local DiedZombies = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function ReviveAllDead()
	-- Functions
	-- INIT
	for i, PlayerDeployedValue in pairs(SharedGameDeployedFolder:GetChildren()) do
		coroutine.wrap(function()
			local FoundPlayer = game.Players:FindFirstChild(PlayerDeployedValue.Name)
			local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(PlayerDeployedValue.Name)
			
			if not FoundPlayer then
				return nil
			end
			
			if FoundPlayer and FoundPlayer.Character == nil then
				FoundPlayerLobbyValue:SetAttribute("Lives", 1)
				return MainRemote:Fire("PlayerRespawn", FoundPlayer)
			end
		end)()
	end
end

local function RemovePowerUpDropInstance(PowerUpDropName)
	-- Functions
	-- INIT
	for i, BoolValue in pairs(SharedGamePowerUpDropsFolder:GetChildren()) do
		if BoolValue.Name ~= PowerUpDropName then
			continue
		end
		
		DebrisModule:AddItem(BoolValue)
	end
end

local function CreatePowerUpDropInstance(PowerUpDropName)
	-- Instancing
	local BoolValue = Instance.new("BoolValue")
	
	-- Functions
	-- INIT
	BoolValue.Name = PowerUpDropName
	BoolValue.Value = true
	BoolValue.Parent = SharedGamePowerUpDropsFolder
	
	return BoolValue
end

local function RewardAllPoints(NumberOfPoints)
	-- Functions
	-- INIT
	for i, PlayerValue in pairs(SharedGameDeployedFolder:GetChildren()) do
		local FoundLobbyValue = SharedGameLobbyFolder:FindFirstChild(PlayerValue.Name)
		
		if not FoundLobbyValue then
			continue
		end
		
		if IsDoublePoints then
			NumberOfPoints *= 2
		end
		
		FoundLobbyValue:SetAttribute("Score", (FoundLobbyValue:GetAttributes()["Score"] or 0) + NumberOfPoints)
	end
end

local function CreateRandomRig(IsBoss)
	-- Functions
	-- INIT
	local TeamInfo = nil
	
	if IsBoss then
		TeamInfo = TeamsModule:GetTeamInfo("Boss")
	else
		TeamInfo = TeamsModule:GetTeamInfo("Infected")
	end
	
	local RigBase = SharedPartsFolder["Spartans"]["Mark1"]["StarterCharacter"]:Clone()
	
	if not IsBoss then
		RigBase.Name = "Zombie"
	else
		RigBase.Name = "Boss"
	end
	
	local Helmets = {"", unpack(UtilitiesModule:GetChildrenNames(SharedArmoursFolder["Helmets"]))}
	
	CharacterModule:CharacterProcess("ApplyHelmet", RigBase, Helmets[math.random(1, #Helmets)])
	CharacterModule:SetCharacterAppearance(RigBase, TeamInfo["Colour"], BrickColor.new("Black"), BrickColor.new("Bright yellow"))
	
	if IsBoss then
		CharacterModule:CharacterProcess("ApplyArmourEffect", RigBase, "Blue Fire")
	end
	
	if not IsBoss then
		RigBase:SetAttribute("Team", "Infected")
	else
		RigBase:SetAttribute("Team", "Boss")
	end
	
	CharacterCoreSignal:Invoke("HandleCharacterProperties", nil, RigBase)
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(RigBase, "Humanoid")
	
	local Multiplier = ShieldMultiplier
	
	for i = 1, GameModeFolder:GetAttribute("Wave") do
		Multiplier *= ShieldMultiplier
	end
	
	Humanoid:SetAttribute("MaxShield", Humanoid:GetAttribute("MaxShield") * Multiplier)
	Humanoid:SetAttribute("Shield", Humanoid:GetAttribute("MaxShield"))
	
	if IsBoss then
		Humanoid:SetAttribute("MaxShield", Humanoid:GetAttribute("MaxShield") * BossHealthMultiplier)
		Humanoid:SetAttribute("Shield", Humanoid:GetAttribute("MaxShield"))
	end
	
	--CharacterCoreModule:HandleCharacterProperties(RigBase)
	
	table.insert(Zombies, RigBase)
	
	return RigBase
end

local function SpawnHordeZombie(CustomConnection, IsBoss)
	-- Functions
	-- INIT
	local Zombie = CreateRandomRig(IsBoss)

	Zombie.Parent = workspace["Temporary"]["AI"]
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Zombie, "Humanoid")
	
	local TeamInfo = nil
	
	if not IsBoss then
		TeamInfo = TeamsModule:GetTeamInfo("Infected")
	else
		TeamInfo = TeamsModule:GetTeamInfo("Boss")
	end
	
	local WeaponModel = SharedWeaponsFolder[TeamInfo["Weapons"]["Primary"]]:Clone()
	WeaponsModule:InitialiseWeapon(WeaponModel)
	WeaponModel.Parent = Zombie
	
	local ServerWeaponModule = require(UtilitiesModule:WaitForChildTimed(WeaponModel["Core"], "GunClient"))
	
	WeaponModel["HandWeld"].Part0 = UtilitiesModule:WaitForChildTimed(WeaponModel["HandWeld"], "Part0").Value
	WeaponModel["HandWeld"].Part1 = Zombie["RightHand"]
	
	Zombie:SetAttribute("EquippedWeapon", "Primary")
	Zombie:SetAttribute("Primary", TeamInfo["Weapons"]["Primary"])
	
	ServerWeaponModule:Initialise()
	ServerWeaponModule:Equip()
	
	ObjectsModule:ObjectProcess("SetCollisionGroup", Zombie, "AIs")
	
	local ChosenSpawn = MapsModule:HandleSpawn(Zombie, TeamInfo["SpawnWith"] or 2)
	
	AIZombieModule:Initialise(Zombie, ChosenSpawn, IsBoss, ServerWeaponModule, InfectionModule, CustomConnection)
	
	Humanoid:SetAttribute("BaseSpeed", Humanoid.WalkSpeed)
	Humanoid:SetAttribute("AnimationBaseSpeed", Humanoid.WalkSpeed)
	
	if GameModeFolder:GetAttribute("Wave") <= StartRunningWave and not IsBoss then
		Humanoid:SetAttribute("BaseSpeed", Humanoid.WalkSpeed / 2)
		Humanoid.WalkSpeed = Humanoid:GetAttribute("BaseSpeed")
	end
	
	if IsNuking then
		CollectionService:AddTag(Zombie, "Incineration")
	end
	
	if IsSlowdown then
		Humanoid.WalkSpeed = 5
	end
	
	if IsInstaKill and not IsBoss then
		UtilitiesModule:CreateElementCache(Humanoid, {"Health", "Shield", "MaxShield"}, ElementCache)

		Humanoid.Health = 1
		Humanoid:SetAttribute("Shield" , 0)
		Humanoid:SetAttribute("MaxShield", 0)
	end
end

local function RewardGrenadesToAll(Number)
	-- Functions
	-- INIT
	for i, PlayerDeployedValue in pairs(SharedGameDeployedFolder:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerDeployedValue.Name)
		
		if not Player then
			continue
		end
		
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if not Character then
			continue
		end
		
		local Success, Error = pcall(function()
			for GrenadeName, GrenadeInfo in pairs(GrenadesInfoModule:GetAllGrenadeInfo()) do
				WeaponsModule:WeaponProcess("AddGrenades", Character, GrenadeName, Number)
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | RewardGrenadesToAll | Error: ".. tostring(Error))
		end
	end
end

local function StartRound(CustomConnection)
	-- CORE
	local ChangingRound = nil
	
	-- Functions
	-- MECHANICS
	local function NextWave()
		-- Functions
		-- INIT
		if GameModeFolder:GetAttribute("Wave") >= WaveTo then
			return MainRemote:Fire("DisconnectRoundLoop")
		end
		
		if not CoreSignal:Invoke("GetRoundRunning") then
			return nil
		end
		
		GameModeFolder:SetAttribute("Wave", GameModeFolder:GetAttribute("Wave") + 1)
		ReviveAllDead()
		
		local Multiplier = ZombieMultiplier
		
		for i = 1, GameModeFolder:GetAttribute("Wave") do
			Multiplier *= ZombieMultiplier
		end
		
		local ZombiesLeft = math.floor(StartZombies * Multiplier)
		GameModeFolder:SetAttribute("ZombiesLeft", ZombiesLeft)
		
		RewardGrenadesToAll(GrenadesPerRound)
		
		pcall(function()
			if GameModeFolder:GetAttribute("Wave") % BossWaveSpawn == 0 then
				if not CoreSignal:Invoke("GetRoundRunning") then
					return nil
				end
				
				SpawnHordeZombie(CustomConnection, true)
			end
			
			for i = 1, ZombiesLeft do
				if not CoreSignal:Invoke("GetRoundRunning") then
					return nil
				end
				
				if #workspace["Temporary"]["AI"]:GetChildren() >= MaxSpawnAtOnce then
					repeat
						task.wait()
					until #workspace["Temporary"]["AI"]:GetChildren() < MaxSpawnAtOnce
				end
				
				SpawnHordeZombie(CustomConnection)
				task.wait(1)
			end
		end)
	end
	
	local function ZombiesLeftChanged()
		-- Functions
		-- INIT
		if GameModeFolder:GetAttributes()["ZombiesLeft"] > 0 or ChangingRound then
			return nil
		end
		
		DebugModule:Print(script.Name.. "| NEXT WAVE")
		
		ChangingRound = true
		task.wait(5)
		
		coroutine.wrap(function()
			NextWave()
		end)()
		
		ChangingRound = false
	end
	
	-- INIT
	GameModeFolder:SetAttribute("Wave", 0)
	GameModeFolder:SetAttribute("ZombiesLeft", 30)
	
	-- DIRECT
	local Connection1 = GameModeFolder:GetAttributeChangedSignal("ZombiesLeft"):Connect(function()
		return ZombiesLeftChanged()
	end)
	
	-- Connections
	table.insert(RoundConnections, Connection1)
	
	NextWave()
end

local function AddToCache(Player, _Connections)
	-- Functions
	-- INIT
	if Connections[Player] == nil then
		Connections[Player] = {}
	end
	
	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Player], Connection)
	end
end

local function RemoveFromCache(Player)
	-- Functions
	-- INIT
	if Connections[Player] ~= nil then
		UtilitiesModule:DisconnectConnections(Connections[Player])
		Connections[Player] = nil
	end
end


local function CheckIfRoundEnd()
	-- Functions
	-- INIT
	local RoundEnd = true
	
	for i, PlayerDeployedValue in pairs(SharedGameDeployedFolder:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerDeployedValue.Name)
		
		if not Player then
			continue
		end
		
		local PlayerTeam = Player.Team
		
		if PlayerTeam and PlayerTeam.Name ~= "Infected" then
			RoundEnd = false
		end
	end
	
	return RoundEnd
end

local function OnPlayerKilled(Player)
	-- Functions
	-- INIT
	local Result = CheckIfRoundEnd()
	
	if Result then
		MainRemote:Fire("DisconnectRoundLoop")
	end
end

local function SetupPlayerConnections(Player)
	if not Player then
		return nil
	end
	
	-- CORE
	local PlayerLobbyValue = UtilitiesModule:WaitForChildTimed(SharedGameLobbyFolder, Player.Name)
	local PreviousKills = 0
	local PreviousAssists = 0	
	
	--local PlayerTeam = Player.Team
	
	-- Functions
	-- DIRECT
	local Connection1 = PlayerLobbyValue:GetAttributeChangedSignal("Kills"):Connect(function()
		local Difference = PlayerLobbyValue:GetAttribute("Kills") - PreviousKills
		
		local ToAdd = (Difference * ScorePerKill)
		
		if IsDoublePoints then
			ToAdd *= 2
		end
		
		PlayerLobbyValue:SetAttribute("Score", PlayerLobbyValue:GetAttribute("Score") + ToAdd)
		
		PreviousKills = PlayerLobbyValue:GetAttribute("Kills")
		
		---PlayerLobbyValue:SetAttribute("Score", PlayerLobbyValue:GetAttribute("Kills"))
		--GameModule:UpdateTotalScore(PlayerTeam)
	end)
	
	local Connection2 = PlayerLobbyValue:GetAttributeChangedSignal("Assists"):Connect(function()
		local Difference = PlayerLobbyValue:GetAttribute("Assists") - PreviousAssists
		
		local ToAdd = (Difference * ScorePerAssist)
		
		if IsDoublePoints then
			ToAdd *= 2
		end
		
		PlayerLobbyValue:SetAttribute("Score", PlayerLobbyValue:GetAttribute("Score") + ToAdd)

		PreviousAssists = PlayerLobbyValue:GetAttribute("Assists")
	end)
	
	--[[local Connection2 = PlayerLobbyValue:GetAttributeChangedSignal("Deaths"):Connect(function()
		OnPlayerDied(Player)
	end)]]
	
	-- INIT
	AddToCache(Player, {Connection1, Connection2})
end


local function GetKillType(Murdered, Murderer, CurrentKillType)
	-- Functions
	-- INIT
	local BlacklistedKillTypes = {" suicide ", " betrayed "}
	
	if table.find(BlacklistedKillTypes, CurrentKillType) then
		return nil
	end
	
	if Murdered and Murdered.Team and Murdered.Team.Name == "Survivor" and Murderer and Murderer.Team and Murderer.Team.Name == "Infected" then
		return " infected "
	end
end

local function GetWeaponModelFromCharacter(Character)
	-- Functions
	-- INIT
	for i, Model in pairs(Character:GetChildren()) do
		if Model:GetAttributes()["Weapon"] and Model.Name ~= "UnequipWeapon" then
			return Model
		end
	end
end

local function MaxAmmo()
	-- Functions
	-- INIT
	for i, Character in pairs(UtilitiesModule:GetCharacters(true)) do
		-- CORE
		local Player = game.Players:GetPlayerFromCharacter(Character)
		
		-- Functions
		-- INIT
		if not Player then
			continue
		end
		
		local CharacterWeaponModel = GetWeaponModelFromCharacter(Character)
		local BackpackWeaponModel = Player:WaitForChild("Backpack"):FindFirstChildOfClass("Model")

		local Weapons = {CharacterWeaponModel, BackpackWeaponModel}

		for i, WeaponModel in pairs(Weapons) do

			if not WeaponModel then
				continue
			end

			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Weapon Name: ".. tostring(WeaponModel))

			local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)

			if not table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
				continue	
			end
			
			local TotalMaxAmmo = WeaponModel:GetAttribute("MaxMags") * WeaponModel:GetAttribute("MaxRoundsInMag")
			WeaponsModule:WeaponProcess("AddAmmo", WeaponModel, TotalMaxAmmo)
		end
		
		--[[for AttributeName, AttributeValue in pairs(Character:GetAttributes()) do
			if string.find(AttributeName, "Grenades") then
				Character:SetAttribute(AttributeName, 4)
			end
		end]]
		
		for GrenadeName, GrenadeInfo in pairs(GrenadesInfoModule:GetAllGrenadeInfo()) do
			WeaponsModule:WeaponProcess("AddGrenades", Character, GrenadeName, GrenadesInfoModule:GetGrenadeSetting("MaxGrenades"))
		end
		
	end
end

local function StopKillingAllZombies()
	-- Functions
	-- INIT
	for i, Zombie in pairs(Zombies) do
		if not Zombie then
			continue
		end

		local Humanoid = Zombie:FindFirstChildOfClass("Humanoid")

		if not Humanoid then
			continue
		end
		
		if table.find(CollectionService:GetTags(Zombie), "Incineration") then
			CollectionService:RemoveTag(Zombie, "Incineration")
		end
	end
end

local function KillAllZombies()
	-- Functions	
	-- INIT
	for i, Zombie in pairs(Zombies) do
		if not Zombie then
			continue
		end
		
		local Humanoid = Zombie:FindFirstChildOfClass("Humanoid")
		
		if not Humanoid then
			continue
		end
		
		CollectionService:AddTag(Zombie, "Incineration")
		
		--Humanoid.Health = 0
		task.wait(math.random(0 * 10, 4 * 10) / 100)
	end
end

local function RevertZombieHumanoid()
	-- Functions
	-- INIT
	for i, Zombie in pairs(Zombies) do
		if not Zombie then
			continue
		end

		local Humanoid = Zombie:FindFirstChildOfClass("Humanoid")
		
		if Humanoid and ElementCache[Humanoid] ~= nil then
			for PropertyName, PropertyValue in pairs(ElementCache[Humanoid] or {}) do
				if UtilitiesModule:HasProperty(Humanoid, PropertyName) then
					Humanoid[PropertyName] = PropertyValue
				else
					Humanoid:SetAttribute(PropertyName, PropertyValue)
				end
			end
		end
	end
end

local function SetZombieHumanoid(Properties, StoreOld, IgnoreBoss)
	-- Functions
	-- INIT
	for i, Zombie in pairs(Zombies) do
		if not Zombie then
			continue
		end
		
		if IgnoreBoss and Zombie.Name == "Boss" then
			continue
		end
		
		local Humanoid = Zombie:FindFirstChildOfClass("Humanoid") --UtilitiesModule:WaitForChildOfClass(Zombie, "Humanoid")
		
		if Humanoid then
			for PropertyName, PropertyValue in pairs(Properties) do
				pcall(function()
					if StoreOld then
						UtilitiesModule:CreateElementCache(Humanoid, {PropertyName}, ElementCache)
					end
					
					if UtilitiesModule:HasProperty(Humanoid, PropertyName) then
						Humanoid[PropertyName] = PropertyValue
					else
						Humanoid:SetAttribute(PropertyName, PropertyValue)
					end
				end)
			end
		end
	end
end

local function Slowdown(StartTime)
	-- CORE
	local TeamInfo = TeamsModule:GetTeamInfo("Infected")
	
	-- Functions
	-- INIT	
	IsSlowdown = true
	SetZombieHumanoid({["WalkSpeed"] = 5})
	task.wait(PowerUpDropsInfoModule:GetPowerUpDropInfo("Slowdown")["Duration"])
	
	if StartTime == LastPowerUpDropTimes["Slowdown"] then
		SetZombieHumanoid({["WalkSpeed"] = TeamInfo["Character"]["Humanoid"]["WalkSpeed"]})
		IsSlowdown = false
		RemovePowerUpDropInstance("Slowdown")
	end
end

local function InstaKill(StartTime)
	-- Functions
	-- INIT	
	IsInstaKill = true
	SetZombieHumanoid({["Health"] = 1, ["Shield"] = 0, ["MaxShield"] = 0}, true, true)
	task.wait(PowerUpDropsInfoModule:GetPowerUpDropInfo("InstaKill")["Duration"])
	
	if StartTime == LastPowerUpDropTimes["InstaKill"] then
		RevertZombieHumanoid()
		IsInstaKill = false
		RemovePowerUpDropInstance("InstaKill")
	end
end



local function DoublePoints(StartTime)
	-- Functions
	-- INIT
	--[[if IsNuking then
		RewardAllPoints(400)
		return nil
	end]]

	IsDoublePoints = true

	
	task.wait(PowerUpDropsInfoModule:GetPowerUpDropInfo("DoublePoints")["Duration"])

	if StartTime == LastPowerUpDropTimes["Nuke"] then
		IsDoublePoints = false
		RemovePowerUpDropInstance("DoublePoints")
	end
end

local function Nuke(StartTime)
	-- Functions
	-- INIT
	--[[if IsNuking then
		RewardAllPoints(400)
		return nil
	end]]
	
	IsNuking = true
	
	KillAllZombies()
	task.wait(PowerUpDropsInfoModule:GetPowerUpDropInfo("Nuke")["Duration"])
	StopKillingAllZombies()
	
	if StartTime == LastPowerUpDropTimes["Nuke"] then
		IsNuking = false
		RemovePowerUpDropInstance("Nuke")
	end
	
	RewardAllPoints(400)	
end


local Requests = 
{
	["GetKillType"] = GetKillType
}

local PowerUpDropResponses = 
{
	["Nuke"] = Nuke,
	["Slowdown"] = Slowdown,
	["InstaKill"] = InstaKill,
	["MaxAmmo"] = MaxAmmo,
	["DoublePoints"] = DoublePoints
}

local function ActivatePowerUpDrop(PowerUpDropName)
	-- Functions
	-- INIT
	if not SharedGamePowerUpDropsFolder:FindFirstChild(PowerUpDropName) then
		CreatePowerUpDropInstance(PowerUpDropName)
	end
	
	local StartTime = tick()
	
	LastPowerUpDropTimes[PowerUpDropName] = StartTime
	
	PowerUpDropResponses[PowerUpDropName](StartTime)
	
	if LastPowerUpDropTimes[PowerUpDropName] == StartTime then
		RemovePowerUpDropInstance(PowerUpDropName)
	end
end

local function OnGameModeSignalInvoke(FunctionName, ...)
	-- Functions
	-- INIT
	return Requests[FunctionName](...)
end

local function Initialise(CustomConnection)
	-- Functions
	-- DIRECT
	GameModeSignal.OnInvoke = OnGameModeSignalInvoke
	
	local Connection1 = PowerUpsRemote.Event:Connect(function(GlobalFunctionName, FunctionName, ...)
		if GlobalFunctionName == "Activate" then
			return ActivatePowerUpDrop(FunctionName) --PowerUpDropResponses[FunctionName](...)
		end
	end)
	
	-- DIRECT
	table.insert(Connections, Connection1)
	
	-- INIT
	for i, Player in pairs(SharedGameLobbyFolder:GetChildren()) do
		SetupPlayerConnections(game.Players:FindFirstChild(Player.Name))
	end
	
	CheckIfRoundEnd()
	
	GameModeFolder = Instance.new("Folder")
	GameModeFolder.Name = "GameMode"
	GameModeFolder.Parent = SharedGameFolder
	
	coroutine.wrap(function()
		repeat
			task.wait()
		until not CustomConnection or not CustomConnection.Value or #SharedGameDeployedFolder:GetChildren() > 0
		
		if CustomConnection and CustomConnection.Value then
			StartRound(CustomConnection)
		end
	end)()
end

local function DisconnectAllConnections()
	-- Functions
	-- INIT
	for Player, PlayerConnections in pairs(Connections) do
		if PlayerConnections and typeof(PlayerConnections) == "table" then
			UtilitiesModule:DisconnectConnections(PlayerConnections)
			
			Connections[Player] = nil
		end
	end
	
	UtilitiesModule:DisconnectConnections(RoundConnections)
	
	Connections = {}
	RoundConnections = {}
end

local function End()
	-- Functions
	-- INIT
	ElementCache = {}
	DiedZombies = {}
	Zombies = {}
	DisconnectAllConnections()
end

local function ZombieDied(Model, IsBoss)
	-- Functions
	-- INIT
	if DiedZombies[Model] then
		return nil
	end
	
	DiedZombies[Model] = true
	
	if not IsBoss then
		GameModeFolder:SetAttribute("ZombiesLeft", math.clamp(GameModeFolder:GetAttribute("ZombiesLeft") - 1, 0, math.huge))
	end
	
	coroutine.wrap(function()
		task.wait(1)
		DiedZombies[Model] = nil
	end)()
end

local function OnPlayerShotRegistered(Player)
	-- Functions
	-- INIT
	if not Player then
		return nil
	end
	
	local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
	
	if not FoundPlayerLobbyValue then
		return nil
	end
	
	local BasePoints = 10
	
	if IsDoublePoints then
		BasePoints *= 2
	end
	
	FoundPlayerLobbyValue:SetAttribute("Score", FoundPlayerLobbyValue:GetAttribute("Score") + BasePoints)
end

-- DIRECT
function InfectionModule.GetIsNuking()
	return IsNuking
end

function InfectionModule.ZombieDied(NilParam, ...)
	return ZombieDied(...)
end

function InfectionModule.PlayerDied(NilParam, Player)
	return OnPlayerKilled(Player)
end

function InfectionModule.PlayerShotRegistered(NilParam, Player)
	return OnPlayerShotRegistered(Player)
end

function InfectionModule.PlayerKilled(NilParam, Murdered, Murderer)
	return OnPlayerKilled(Murdered, Murderer)
end

function InfectionModule.PlayerAdded(NilParam, Player)
	return SetupPlayerConnections(Player)
end

function InfectionModule.PlayerLeft(NilParam, Player)
	return RemoveFromCache(Player)
end

function InfectionModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function InfectionModule.End()
	return End()
end

return InfectionModule