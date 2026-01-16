local ClientCoreModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local PlayerGui = Player:WaitForChild("PlayerGui")
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- InfoModules
local ClientCoreInfoModule = require(InfoModulesFolder["ClientCore"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local CameraModule = require(ModulesFolder["Camera"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local PagesToLoadOnLaunch = {{Type = "Custom", Name = "Console"}}
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script)
end

local function RemoveCoreScripts()
	-- Elements
	-- FOLDERS
	local PlayerScriptsFolder = UtilitiesModule:WaitForChildTimed(Player, "PlayerScripts")
	
	-- Functions
	-- INIT
	local SoundScript = UtilitiesModule:WaitForChildTimed(PlayerScriptsFolder, "RbxCharacterSounds")
	SoundScript:Destroy()
end

local function SetupUiFolders()
	-- Functions
	-- INIT
	task.wait(1)
	for i, FolderName in pairs(ClientCoreInfoModule:GetClientCoreInfo("UiTypes")) do
		if PlayerGui:FindFirstChild(FolderName) then
			continue
		end
		
		local Folder = Instance.new("Folder")
		Folder.Name = FolderName
		Folder.Parent = PlayerGui
	end
end

local function LoadUis()
	-- Functions
	-- INIT
	for i, PageInfo in pairs(PagesToLoadOnLaunch) do
		InterfacesModule:LoadPage(PageInfo.Type, PageInfo.Name, true)
	end
end

-- DIRECT
function ClientCoreModule.Initialise()
	-- Functions
	-- INIT
	CameraModule:SetupCamera()
	SetupUiFolders()
	LoadUis()
	RemoveCoreScripts()
	RunSubModules()
end

return ClientCoreModule