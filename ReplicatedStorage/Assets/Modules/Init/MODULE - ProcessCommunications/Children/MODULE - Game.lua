local GameProcessCommunicationsModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local OfflinePartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Offline"]
local ScreenInterfacesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Interfaces"]["Screen"]
local GameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local CachesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Caches"]

-- Client
local Player = game.Players.LocalPlayer

-- CACHES
local RoundXpCacheModule = require(CachesFolder["RoundXp"])

-- Info Modules
local PowerUpDropsInfoModule = require(InfoModulesFolder["PowerUpDrops"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ControlsModule = require(Player.PlayerScripts.PlayerModule):GetControls()
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- SERVICES
local TeleportService = game:GetService("TeleportService")

-- Functions
-- MECHANICS
-- SPECIFIC
local function ResetGlobals()
	-- Functions
	-- INIT
	DebugModule:Print("ProcessCommunications | ".. script.Name.. " | Resetting Globals")
	_G["KilledBy"] = nil
end

local function ReturnToLobby()
	-- Functions
	-- INIT
	--DebugModule:Print("Returning to lobby: ".. tostring(tick()))
	
	ResetGlobals()
	
	if ShortcutsModule:IsMenuOpen() or InterfacesModule:IsPageOpen("Custom", "Multiplayer") or InterfacesModule:IsPageOpen("Custom", "Crew") then
		--[[local MenuModule = InterfacesModule:GetUiModuleFromType("Main", "Menu")
		
		if MenuModule then
			if MenuModule:GetState() == "Show" then
				return nil
			end
		else
			return nil
		end]]
		
		return nil
	end
	
	if not GameLobbyFolder:FindFirstChild(Player.Name) then
		return nil
	end
	
	ControlsModule:Disable()
	
	--[[local Character = OfflinePartsFolder["Client"]:Clone()
	Character.Parent = workspace:WaitForChild("Dump")["Client"]
	Player.Character = Character]]
	
	InterfacesModule:LoadPage("Custom", "MatchResults", true)
	
	if not Player:GetAttributes()["Crew"] then
		InterfacesModule:LoadPage("Custom", "CrewAdvert", true)
	end
	
	InterfacesModule:LoadPage("Custom", "Multiplayer", true)
end

local function Betrayed()
	-- Functions
	-- INIT
	SoundsModule:PlaySoundEffectByName("Narrator", "Betrayed")
end

local function PowerUpDrop(DropName)
	-- CORE
	local PowerUpDropInfo = PowerUpDropsInfoModule:GetPowerUpDropInfo(DropName)
	
	-- Functions
	-- INIT
	local HudInterfaceModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	LogConsole("Core", nil, DropName.. "!")
	
	if HudInterfaceModule then
		HudInterfaceModule:HudProcess("HudEffects", "FrameFlash", "PowerUpDrop", "PowerUpDropFlash")
	end
	
	if PowerUpDropInfo and PowerUpDropInfo["Sound"] then
		SoundsModule:PlaySoundEffectById(PowerUpDropInfo["Sound"]["Id"], nil, nil, nil, nil, nil, PowerUpDropInfo["Sound"]["FromTime"], PowerUpDropInfo["Sound"]["EndTime"])
	end
end

function LogConsole(MessageType, Sender, Message)
	-- Core
	local ConsoleUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Console")
	
	-- Functions
	-- INIT
	--DebugModule:Print"Logging to console from server! Type: ".. tostring(MessageType).. " | Sender: ".. tostring(Sender).. " | Message: ".. tostring(Message))
	
	if ConsoleUiModule then
		return ConsoleUiModule:Add(MessageType, Sender, Message)
	end
end

local function LogNotification(Type, Text, Icon)
	-- CORE
	local NotificationsUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Notifications")
	
	-- Functions
	-- INIT
	if NotificationsUiModule then
		return NotificationsUiModule:Add(Type, Text, Icon)
	end
end

-- GENERIC
local function LoadPage(PageType, PageName, ...)
	-- Functions
	-- INIT
	return InterfacesModule:LoadPage(PageType, PageName, nil, ...)
end

local function Died(Murderer)
	-- Functions
	-- INIT
	DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Received died request | Killed by: ".. tostring(Murderer).. " | Time: ".. tick())
	--
	--[[if DeathInfo then
		for DeathKey, DeathVal in pairs(DeathInfo) do
			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Key: ".. tostring(DeathKey).. " | Val: ".. tostring(DeathVal))	
		end
	end]]
	--
	
	if Murderer == Player then
		SoundsModule:PlaySoundEffectByName("Narrator", "Suicide")
	end
	
	_G["KilledBy"] = {["Murderer"] = Murderer, Time = tick()} --{Murderer = DeathInfo["Murderer"], Time = tick()}
end

local function SetTeleportUi(UiName)
	-- Functions
	-- INIT
	TeleportService:SetTeleportGui(ScreenInterfacesFolder:FindFirstChild(UiName))
end

local function RoundOver(WinningTeam)
	-- Functions
	-- INIT
	
	if UtilitiesModule:GetCharacter(Player, true) then
		SoundsModule:PlaySoundEffectByName("Narrator", "RoundOver")
	end
	
	local Succcess, Error = pcall(function()
		local ConsoleUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Console")
		
		if ConsoleUiModule and ConsoleUiModule.Add ~= nil then
			ConsoleUiModule:Add("Core", nil, "Round Over!")
		end
	end)
	
	if not Succcess then
		DebugModule:Print(script.Name.. " | RoundOver | Error: ".. tostring(Error))
	end
	
	ResetGlobals()
	
	if UtilitiesModule:GetCharacter(Player, true) and (InterfacesModule:IsPageOpen("Custom", "Hud") or InterfacesModule:IsPageOpen("Custom", "Scoreboard")) then
		local ScoreboardUi = InterfacesModule:LoadPage("Custom", "ScoreBoard", true, WinningTeam)
		local FPSControllerModule =  nil
		
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				FPSControllerModule = UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSController")

				if FPSControllerModule then
					FPSControllerModule = require(FPSControllerModule)
				end

				if FPSControllerModule and FPSControllerModule.RoundEnd ~= nil then
					return FPSControllerModule:RoundEnd()
				else
					DebugModule:Print("Process Communications | Game | Cannot find FPSControllerModule!")
				end
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | RoundOver | FPSControllerModule | Error: ".. tostring(Error))
			end
		end)()
		
		local ScoreboardModule = nil
		
		if ScoreboardUi then
			ScoreboardModule = InterfacesModule:GetUiModule(ScoreboardUi)
		end
		
		task.wait(3)
		if not ScoreboardUi then
			return nil
		end
		--local ScoreboardModule = InterfacesModule:GetUiModule(ScoreboardUi)
		if ScoreboardModule and ScoreboardModule.Fade ~= nil then
			ScoreboardModule:Fade(true)
			
			local Success, Error = pcall(function()
				if FPSControllerModule and FPSControllerModule.UnbindActions ~= nil then
					return FPSControllerModule:UnbindActions()
				end
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | RoundOver | FPSController UnbindActions | Error: ".. tostring(Error))
			end
			
			InterfacesModule:LoadPage("Custom", "Loading", true)
		end
	else
		DebugModule:Print("Process Communications | Game | Can't open scoreboard -> Character doesn't exist")
	end
end

local function Kill()
	-- Functions
	-- INIT
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule then
		HudGuiModule:HudProcess("Cursor", "Kill")
	end
end

local function Spectate()
	-- CORE
	local ToUnload = 
	{
		["Multiplayer"] = "Custom",
		["Loading"]	= "Custom",
		["Hud"] = "Custom",
		["ScoreBoard"] = "Custom"
	}
	
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Spectating!")
	
	for PageName, PageType in pairs(ToUnload) do
		local Success, Error = pcall(function()
			if InterfacesModule:IsPageOpen(PageType, PageName) then
				return InterfacesModule:UnloadPage(PageType, PageName)
			end
		end)
			
		if not Success then
			DebugModule:Print(script.Name.. " | Spectate | Error: ".. tostring(Error))
		end
	end
	
	
	local Ui = InterfacesModule:IsPageOpen("Custom", "Died")
	
	if not Ui then
		Ui = InterfacesModule:LoadPage("Custom", "Died", true, nil)
	end
end

local function RoundStarted()
	-- Functions
	-- INIT
	RoundXpCacheModule:Clear()
	_G["RankUp"] = nil
end

-- CORE FUNCTIONS
local ServerRequests = 
{
	["Spectate"] = Spectate,
	["PowerUpDrop"] = PowerUpDrop,
	["Kill"] = Kill,
	["RoundOver"] = RoundOver,
	["SetTeleportUi"] = SetTeleportUi,
	["ReturnToLobby"] = ReturnToLobby,
	["LoadPage"] = LoadPage,
	["Betrayed"] = Betrayed,
	["LogConsole"] =  LogConsole,
	["Notification"] = LogNotification,
	["Died"] = Died,
	["RoundStarted"] = RoundStarted
}

-- DIRECT
function GameProcessCommunicationsModule.ResetGlobals()
	return ResetGlobals()
end

function GameProcessCommunicationsModule.Initialise(NilParam, FunctionName, ...)
	return ServerRequests[FunctionName](...)
end

return GameProcessCommunicationsModule