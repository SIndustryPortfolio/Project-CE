local HandleSpawnModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Client
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Character = script.Parent.Parent.Parent

-- Info Modules
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])
local MapsInfoModule = require(InfoModulesFolder["Maps"])

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local CameraModule = require(ModulesFolder["Camera"])
local SoundsModule = require(ModulesFolder["Sounds"])
local MapsModule = require(ModulesFolder["Maps"])
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])
--
local FPSHandlerModule = require(UtilitiesModule:WaitForChildTimed(script.Parent, "FPSHandler"))
local MapLoaderModule = require(UtilitiesModule:WaitForChildTimed(script["Other"], "MapLoader"))

-- Elements
-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- FOLDERS
local GameDeployedFolder = GameFolder["Deployed"]
local GameLobbyFolder = GameFolder["Lobby"]

-- VALUES
local PlayerLobbyValue = GameLobbyFolder:FindFirstChild(Player.Name)

-- CORE
local VehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")
local PreviousVehicle = nil
local Connections = {}

-- Services
local RunService = game:GetService("RunService")
--local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function SwitchVehicle(VehicleModel, Dead)
	-- Functions
	-- INIT
	if VehicleModel then
		local VehicleCoreFolder = UtilitiesModule:WaitForChildTimed(VehicleModel, "Core")
		
		if not VehicleCoreFolder then
			DebugModule:Print(script.Name.. " | Switch Vehicle | No Vehicle Core Folder")
			return nil
		end
		
		local VehicleClientModule = require(VehicleCoreFolder["Client"])

		if VehicleClientModule.Initialise ~= nil then
			if VehicleClientModule:GetInitialised() then
				repeat
					task.wait()
				until not VehicleClientModule:GetInitialised()
			end
			
			coroutine.wrap(function()
				local Success, Error = pcall(function()
					return FPSHandlerModule:End()
				end)
				
				if not Success then
					DebugModule:Print(script.Name.. " | SwitchVehicle | Error: ".. tostring(Error))
				end
			end)()
			
			if Character and Humanoid and Humanoid.Health > 0 then
				VehicleClientModule:Initialise()
			end
		end
	else
		local VehicleCoreFolder = UtilitiesModule:WaitForChildTimed(PreviousVehicle, "Core")
		
		if not VehicleCoreFolder then
			DebugModule:Print(script.Name.. " | Switch Vehicle | No Vehicle Core Folder")
			return nil
		end
		
		local VehicleClientModule = require(VehicleCoreFolder["Client"])

		if VehicleClientModule.End ~= nil then
			if not VehicleClientModule:GetInitialised() then
				repeat
					task.wait()
				until VehicleClientModule:GetInitialised()
			end
			
			local Success, Error = pcall(function()
				VehicleClientModule:End()
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | SwitchVehicle | Error: ".. tostring(Error))
			end
			
			if Dead then
				FPSHandlerModule:UnForceDrawCamera()
				return nil
				--FPSHandlerModule:Dead()
			end
			
			if Character and Humanoid and Humanoid.Health > 0 then
				FPSHandlerModule:Initialise(true)			
			end
		end
	end
	
	PreviousVehicle = VehicleModel
end

local function GetMapCameraPart()
	-- Elements
	-- FOLDERS
	local MapFolder = UtilitiesModule:WaitForChildTimed(workspace:WaitForChild("Map")["Server"], GameFolder:GetAttribute("Map"))
	
	if not MapFolder then
		return nil
	end
	
	local StartUpCameraFolder = MapFolder:WaitForChild("Contents")["Settings"]["StartUpCamera"]
	
	--UtilitiesModule:WaitForChildOfClass(StartUpCameraFolder, "Part")
	
	if StartUpCameraFolder then
		return StartUpCameraFolder:GetChildren()[math.random(1, #StartUpCameraFolder:GetChildren())]
	end
end

local function SetupMapCamera()
	-- CORE
	local Camera = CameraModule:GetCamera()
	local MapCameraPart = GetMapCameraPart()
	
	if not MapCameraPart then
		return nil
	end
	
	-- Properties
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = MapCameraPart
	Camera.CFrame = Camera.CameraSubject.CFrame
end

local function Killed()
	-- Functions
	-- INIT
	if not Player then
		Player = game.Players.LocalPlayer
	end
	
	local PlayerTeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if PlayerTeamInfo and PlayerTeamInfo["KillSound"] then
		SoundsModule:PlaySoundEffectById(PlayerTeamInfo["KillSound"]["Id"])
	end
end

local function SetupUiFolders()
	-- CORE
	local Folders = {"Main", "Pages", "Custom"}
	
	-- Functions
	-- INIT
	for i, FolderName in pairs(Folders) do
		if PlayerGui:FindFirstChild(FolderName) then
			continue
		end
		
		local Folder = Instance.new("Folder")
		Folder.Name = FolderName
		Folder.Parent = PlayerGui
	end
end

-- DIRECT
function HandleSpawnModule.GarbageCollect()
	-- Functions
	-- INIT
	InfoModulesFolder = nil
	ModulesFolder = nil
	GameFolder = nil
	--
	Player = nil
	PlayerGui = nil
	--
	SoundsInfoModule = nil
	MapsInfoModule = nil
	--
	InterfacesModule = nil
	CameraModule = nil
	--SoundsModule = nil
	MapsModule = nil
	DebugModule = nil
	UtilitiesModule = nil
	--
	FPSHandlerModule = nil
	MapLoaderModule = nil
	--
	RunService = nil
	
end

function HandleSpawnModule.End()
	-- Functions
	-- INIT
	SwitchVehicle(nil, true)
	UtilitiesModule:DisconnectConnections(Connections)
	MapLoaderModule:End()
end

function HandleSpawnModule.Initialise()
	-- Functions
	-- INIT
	if not Humanoid or Humanoid.Health <= 0 then
		return nil
	end
	
	-- DIRECT
	local Connection1 = VehicleValue:GetPropertyChangedSignal("Value"):Connect(function()
		return SwitchVehicle(VehicleValue.Value)
	end)
	
	local Connection2 = PlayerLobbyValue:GetAttributeChangedSignal("Kills"):Connect(function()
		return Killed()
	end)
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	--SetupUiFolders()
	
	--DebugModule:Print("Handling spawn client!")
	
	if SoundsModule:GetMusic().SoundId ~= SoundsInfoModule:GetSounds("Music")[GameFolder:GetAttribute("Map")].Id then
		SoundsModule:PlayMusicByName(GameFolder:GetAttribute("Map"))
	end
	
	--DebugModule:Print("Handle Spawn | 1")
	
	local SelectedMap = GameFolder:GetAttribute("Map")
	local Success, Error = pcall(function()
		MapsModule:ChangeLighting(MapsInfoModule:GetMapInfo(SelectedMap)["Lighting"])
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
	
	--DebugModule:Print("Handle Spawn | 2")
	local Success, Error = pcall(function()
		MapLoaderModule:Initialise()
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
	
	--DebugModule:Print("Handle Spawn | 3")
	
	CameraModule:ResetCamera()
	--DebugModule:Print("Handle Spawn | 4")
	--
	local LoadedCharacters = #UtilitiesModule:GetCharacters(true) 
	
	DebugModule:Print(script.Name.. " | LoadedCharacters: ".. tostring(LoadedCharacters))
	
	if LoadedCharacters > 0 then--if ((_G["KilledBy"] ~= nil and _G["KilledBy"]["Murderer"] ~= nil) and (_G["KilledBy"]["Murderer"] ~= Player) ) and (tick() - _G["KilledBy"]["Time"]) <= 10 then
		RunService:UnbindFromRenderStep("DeathCamera")
		if _G["KilledBy"] ~= nil and _G["KilledBy"]["Murderer"] ~= nil and (tick() - _G["KilledBy"]["Time"]) < 10 then
			InterfacesModule:LoadPage("Custom", "Died", true, _G["KilledBy"]["Murderer"])
		else
			InterfacesModule:LoadPage("Custom", "Died", true, nil)
		end
	else
		pcall(function()
			DebugModule:Print(script.Name.. " | Not loading Died Ui V")
			DebugModule:Print(script.Name.. " | _G['KilledBy']: ".. tostring(_G["KilledBy"]))
			DebugModule:Print(script.Name.. " | KilledBy: ".. tostring(_G["KilledBy"]))
			DebugModule:Print(script.Name.. " | Murderer: ".. tostring(_G["KilledBy"]["Murderer"]))
		end)
		
		SetupMapCamera()
	end
	--
	MapsModule:UnloadAllClientMaps()
	
	
	coroutine.wrap(function()
		local FoundDeployedValue = UtilitiesModule:WaitForChildTimed(GameDeployedFolder, Player.Name)
		
		if FoundDeployedValue and Character and Humanoid and Humanoid.Health > 0 then
			InterfacesModule:UnloadPage("Custom", "Multiplayer")
		end
	end)()
	--
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["SpawnSound"] then
		if (PlayerLobbyValue:GetAttributes()["Deploy"] or 0) <= 1 or not Player:GetAttributes()["LastTeam"] or Player:GetAttributes()["LastTeam"] ~= TeamInfo["Name"] then
			SoundsModule:PlaySoundEffectById(TeamInfo["SpawnSound"]["Id"])
			Player:SetAttribute("LastTeam", TeamInfo["Name"])
		end
	end
	
	repeat
		task.wait()
	until not FPSHandlerModule or FPSHandlerModule:IsLoaded()
	
	if not InterfacesModule then
		return nil
	end
	
	local MenuModule = InterfacesModule:GetUiModuleFromType("Main", "Menu")
	
	if MenuModule then
		MenuModule:HideCurrency()
	end
	
	if InterfacesModule:IsPageOpen("Custom", "Settings") then
		InterfacesModule:UnloadPage("Custom", "Settings")
	end
	
	--[[if InterfacesModule:IsPageOpen("Custom", "Died") then
		InterfacesModule:UnloadPage("Custom", "Died")
	end]]
	
	if InterfacesModule:IsPageOpen("Custom", "Notifications") then	
		InterfacesModule:UnloadPage("Custom", "Notifications")
		InterfacesModule:UnloadPage("Custom", "MenuHud")
	end
end

return HandleSpawnModule