local SpawnCharacterModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedSpartansFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Spartans"]
local SharedGameDeployedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Deployed"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]

-- Modules
--local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Elements
-- SIGNALS
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]
local CharacterActionsSignal = ServerSignalsFolder["CharacterActions"]

-- CORE
local Queued = false

-- Functions
-- MECHANICS

local function Initialise(GameModule, Player, Respawn)
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		local ArmourVariant = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Variant")

		if not ArmourVariant then
			DebugModule:Print("MainLoop | Cannot find players Armour Variant | Player: ".. tostring(Player))
			ArmourVariant = {Value = "Mark1"}
		end

		local FoundCharacterModelFolder = SharedSpartansFolder:FindFirstChild(ArmourVariant.Value --[[Player.Team.Name]])
		local FoundCharacterModel = FoundCharacterModelFolder:FindFirstChild("StarterCharacter") or FoundCharacterModelFolder:FindFirstChildOfClass("Model")

		if FoundCharacterModel then
			FoundCharacterModel = FoundCharacterModel:Clone()
			local RandomX = math.random(-300, 300) / 100
			local RandomZ = math.random(-300, 300) / 100

			FoundCharacterModel:SetPrimaryPartCFrame(game.Workspace.SpawnBox.FirstSpawn.CFrame * CFrame.new(RandomX, 5, RandomZ))
			FoundCharacterModel.Name = Player.Name
			FoundCharacterModel.Parent = workspace

			CharacterActionsSignal:Invoke("InitialiseCharacter", FoundCharacterModel) --CharacterActionsModule:InitialiseCharacter(FoundCharacterModel)

			Player.Character = FoundCharacterModel
			CharacterActionsSignal:Invoke("CharacterSpawned", FoundCharacterModel) --CharacterActionsModule:CharacterSpawned(FoundCharacterModel)
			--PlayerCoreModule:CharacterAdded(Player, FoundCharacterModel)

			--CoreRemote:Fire("CharacterAdded", Player, Player.Character)

			--[[local Response =]] --MapsModule:HandleSpawn(FoundCharacterModel)


			--return Response
		end
		--end
	end)

	if not Success then
		DebugModule:Print("MainLoop | Deploy | Player: ".. tostring(Player).. " Error: ".. tostring(Error))
		return false
	end
	
	pcall(function()
		if not Respawn then
				--table.insert(PlayersDeployed, Player)

			if not SharedGameDeployedFolder:FindFirstChild(Player.Name) then
				local BoolValue = Instance.new("BoolValue")
				BoolValue.Name = Player.Name
				BoolValue.Value = true
				BoolValue.Parent = SharedGameDeployedFolder
			end

			--PlayerToDeployTime[Player] = tick()

			GameModule:SetPlayersDeployed(#SharedGameDeployedFolder:GetChildren() --[[#PlayersDeployed]] --[[GameModule:GetPlayersDeployed() + 1]])
			GameProcessRemote:FireClient(Player, "Game", "LoadPage", "Custom", "SpawnGameMode")
		end
	end)
		
	return true
end

-- DIRECT
function SpawnCharacterModule.GetQueued()
	return Queued
end

function SpawnCharacterModule.Initialise(NilParam, GameModule, ...)
	return Initialise(GameModule, ...)
end

return SpawnCharacterModule
