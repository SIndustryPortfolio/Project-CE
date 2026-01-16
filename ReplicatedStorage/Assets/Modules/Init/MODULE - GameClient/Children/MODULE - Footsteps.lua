local FootstepsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SoundGroupsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["SoundGroups"]
local GameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]

-- Client
local LocalPlayer = game.Players.LocalPlayer

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Elements
-- SOUND GROUPS
local FootstepsSoundGroup = SoundGroupsFolder["Footsteps"]

-- CORE
local CharacterConnections = {}
local PlayerConnections = {}

-- Services
local PlayersService = game:GetService("Players")

-- Functions
-- MECHANICS
local function ChangeSoundVolume(Group, Multiplier)
	-- Functions
	-- INIT
	for i, Sound in pairs(Group:GetChildren()) do
		Sound.Volume *= Multiplier
	end
end

local function CharacterAdded(Character, Player)
	if not Character then
		return nil
	end
	
	-- CORE
	local SoundGroup = nil
	local LastMaterial = nil
	local LastSound = nil
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	if not Humanoid then
		--DebugModule:Print("Footsteps | No humanoid for: ".. tostring(Character))
		return {}
	end
	
	-- Functions
	-- MECHANICS
	local function StopAllSounds()
		-- Functions
		-- INIT
		if not SoundGroup then
			return nil
		end
		
		for i, Sound in pairs(SoundGroup:GetChildren()) do
			Sound:Stop()
		end
	end
	
	local function End()
		-- Functions
		-- INIT
		StopAllSounds()
		RemoveFromCache(Player, CharacterConnections)
	end
	
	local function Update()
		-- Functions
		-- INIT
		if not Character then
			End()
			return nil
		end
		
		if not Humanoid then
			End()
			return nil
		end
		
		if Humanoid.Health <= 0 then
			--StopAllSounds()
			End()
			return nil
		end
		
		if LastSound then
			LastSound.PlaybackSpeed = Humanoid.WalkSpeed * 0.04
			
			if Humanoid.MoveDirection.Magnitude <= 0 then
				LastSound:Stop()
			else
				if not LastSound.Playing then
					LastSound:Play()
				end
			end
		end
		
		
		if not Humanoid.FloorMaterial then
			StopAllSounds()
			LastSound = nil
			LastMaterial = nil
			return nil
		end
		
		if Humanoid.FloorMaterial.Name == LastMaterial then
			return nil
		else
			StopAllSounds()
		end
		
		LastMaterial = Humanoid.FloorMaterial.Name

		local FoundSound = SoundGroup:FindFirstChild(LastMaterial)
		
		if FoundSound then
			LastSound = FoundSound
			LastSound.PlaybackSpeed = Humanoid.WalkSpeed * 0.04
			LastSound:Play()
		else
			LastSound = nil
		end
	end
	
	-- DIRECT
	local Connection1 = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		Update()
	end)
	
	local Connection2 = Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		Update()
	end)
	
	local Connection3 = Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		Update()
	end)
	
	local Connection4 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		Update()
	end)
	
	local Connection5 = Character:GetPropertyChangedSignal("Parent"):Connect(function()
		Update()
	end)
	
	-- INIT
	SoundGroup = FootstepsSoundGroup:Clone() 
	SoundGroup.Parent = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	if Player ~= LocalPlayer then
		ChangeSoundVolume(SoundGroup, .5)
	end
	
	return {Connection1, Connection2, Connection3, Connection4, Connection5}
end

function AddToCache(Player, _Connections, Cache)
	-- Functions
	-- INIT
	if not Cache[Player.Name] then
		Cache[Player.Name] = {}
	end
	
	if _Connections then
		for i, Connection in pairs(_Connections) do
			table.insert(Cache[Player.Name], Connection)
		end
	else
		if #Cache[Player.Name] <= 0 then
			Cache[Player.Name] = nil
		end
	end
end

function RemoveFromCache(Player, Cache)
	-- Functions
	-- INIT
	if not Cache[Player.Name] then
		return nil
	end
	
	UtilitiesModule:DisconnectConnections(Cache[Player.Name])
	Cache[Player.Name] = nil
end

local function PlayerAdded(Player)
	-- Functions
	-- DIRECT
	--DebugModule:Print("Footsteps | Player Added: ".. tostring(Player))
	
	local Connection1 = Player:GetPropertyChangedSignal("Character"):Connect(function(Character)
		RemoveFromCache(Player, CharacterConnections)
		local _Connections = CharacterAdded(Character--[[UtilitiesModule:GetCharacter(Player, true)]], Player)
		AddToCache(Player, _Connections, CharacterConnections)
	end)
	
	-- CONNECTIONS
	AddToCache(Player, {Connection1}, PlayerConnections)
end

local function PlayerLeft(Player)
	-- Functions
	-- INIT
	RemoveFromCache(Player, CharacterConnections)
	RemoveFromCache(Player, PlayerConnections)
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = GameLobbyFolder.ChildAdded:Connect(function(PlayerLobbyValue)
		local AssociatedPlayer = game.Players:FindFirstChild(PlayerLobbyValue.Name)
		
		if AssociatedPlayer then
			PlayerAdded(AssociatedPlayer)
		end
	end)
	
	local Connection2 = GameLobbyFolder.ChildRemoved:Connect(function(PlayerLobbyValue)
		PlayerLeft(PlayerLobbyValue.Name)
	end)
	
	-- INIT
	for i, PlayerLobbyValue in pairs(GameLobbyFolder:GetChildren()) do
		local AssociatedPlayer = game.Players:FindFirstChild(PlayerLobbyValue.Name)
		
		if AssociatedPlayer then
			PlayerAdded(AssociatedPlayer)
		end
	end
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function FootstepsModule.Initialise()
	return Initialise()
end

function FootstepsModule.End()
	return End()
end

return FootstepsModule