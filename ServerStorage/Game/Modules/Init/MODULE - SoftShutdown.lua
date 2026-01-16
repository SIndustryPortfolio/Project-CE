local SoftshutdownModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local WaitTime = 5
local PlaceId = 10215420141

-- Services
local TeleportService = game:GetService("TeleportService")
local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function SetClientUi(Player, UiName)
	-- Functions
	-- INIT
	GameProcessRemote:FireClient(Player, "Game", "SetTeleportUi", UiName)
	GameProcessRemote:FireClient(Player, "Game", "LoadPage", "Custom", UiName)
end

-- INIT
if game.PrivateServerId ~= "" and game.PrivateServerOwnerId == 0 and not RunService:IsStudio() then
	GameProcessRemote:FireAllClients("Game", "SetTeleportUi", "TempLobby")
	GameProcessRemote:FireAllClients("Game", "LoadPage", "Custom", "TempLobby")
	
	-- DIRECT
	local Connection1 = PlayersService.PlayerAdded:Connect(function(Player)
		SetClientUi(Player, "TempLobby")
		task.wait(WaitTime)
		WaitTime /= 2
		return TeleportService:Teleport(PlaceId, Player)
	end)
	
	-- INIT
	for i, Player in pairs(PlayersService:GetChildren()) do
		local Success, Error = pcall(function()
			SetClientUi(Player, "TempLobby")
			
			return TeleportService:Teleport(PlaceId, Player)
		end)
		
		WaitTime /= 2
	end
	
	return {}
elseif RunService:IsStudio() then
	return {}
end

-- DIRECT
game:BindToClose(function()
	-- Functions
	-- INIT
	--DebugModule:Print("SERVER IS SOFT SHUTTING DOWN!")
	
	GameProcessRemote:FireAllClients("SetTeleportUi", "SoftShutdown")
	GameProcessRemote:FireAllClients("LoadPage", "Custom", "SoftShutdown")
	
	coroutine.wrap(function()
		for i, Player in pairs(PlayersService:GetChildren()) do
			SetClientUi(Player, "SoftShutdown")
			
			local Success, Error = pcall(function()
				return TeleportService:TeleportAsync(PlaceId, {Player})
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | BindToClose | Error: ".. tostring(Error))
			end
			
			coroutine.wrap(function()
				task.wait(6)
				Player.Parent = nil
			end)()
		end
	end)()
	
	local Connection1 = PlayersService.PlayerAdded:Connect(function(Player)
		SetClientUi(Player, "SoftShutdown")
		
		return TeleportService:TeleprotAsync(PlaceId, {Player})
	end)
	
	while (#PlayersService:GetPlayers() > 0) do
		task.wait(1)
	end
end)

return SoftshutdownModule