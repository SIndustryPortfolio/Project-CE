-- Dirs
local ModulesInitFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]["Init"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local GameDeployedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Deployed"]

-- Client
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local PriorityInitModuleLoading = {"ClientCore"}
local RequiredModules = {}
local Connections = {}

-- Services
local ReplicatedFirstServicee = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function RunInitModule(ModuleInstance, IsCharacterModule)
	-- Functions
	-- INIT
	coroutine.wrap(function()
		--DebugModule:Print"Requiring Client Module: ".. tostring(ModuleInstance.Name))
		local Success, Error = pcall(function()
			DebugModule:Print("Init | Requiring: ".. tostring(ModuleInstance))
			local RequiredModule = require(ModuleInstance)
			DebugModule:Print("Init | Required: ".. tostring(ModuleInstance))
			
			local Response
			
			if RequiredModule.Initialise ~= nil then
				Response = RequiredModule:Initialise()
			end
			
			if IsCharacterModule then
				RequiredModules[ModuleInstance.Name] = RequiredModule
			end
			
			return Response
		end)
		
		
		if not Success then
			DebugModule:Print("Error | ".. tostring(ModuleInstance).. ": ".. tostring(Error))
			--DebugModule:PrintError, "Error")
			--print("Error: ".. tostring(Error))
		end
	end)()
end

local function GarbageCollectModule(ModuleInstance)
	coroutine.wrap(function()
		local Success, Error = pcall(function()
			local RequiredModule = nil

			if typeof(ModuleInstance) == "Instance" then
				RequiredModule = require(ModuleInstance)
			elseif typeof(ModuleInstance) == "table" then
				RequiredModule = ModuleInstance
			end

			if RequiredModule.GarbageCollect ~= nil then
				return RequiredModule:GarbageCollect()
			end
		end)

		if ModuleInstance and typeof(ModuleInstance) == "Instance" then
			ModuleInstance:Destroy()
		end

		if not Success then
			DebugModule:Print("Init | ERROR - GarbageCollection | Module: ".. tostring(ModuleInstance).. " | ".. tostring(Error))
			--DebugModule:Printtostring(Error).. " | Module Name: ".. tostring(ModuleInstance.Name), "Error")
		end
	end)()
end

local function EndInitModule(ModuleInstance)
	-- Functions
	-- INIT
	coroutine.wrap(function()
		local ShouldDestroy = true
		
		local Success, Error = pcall(function()
			local RequiredModule = nil
			
			if typeof(ModuleInstance) == "Instance" then
				RequiredModule = require(ModuleInstance)
			elseif typeof(ModuleInstance) == "table" then
				RequiredModule = ModuleInstance
			end
			
			if RequiredModule.GarbageCollect ~= nil then
				ShouldDestroy = false
			end
			
			if RequiredModule.End ~= nil then
				return RequiredModule:End()
			end
		end)
		
		if not Success then
			DebugModule:Print("Init | ERROR | Module: ".. tostring(ModuleInstance).. " | ".. tostring(Error))
			--DebugModule:Printtostring(Error).. " | Module Name: ".. tostring(ModuleInstance.Name), "Error")
		end
		
		if ShouldDestroy and ModuleInstance and typeof(ModuleInstance) == "Instance" then
			ModuleInstance:Destroy()
		end
	end)()
end

local function RunInitModules()
	-- CORE
	local InitModules = ModulesInitFolder:GetChildren()
	
	-- Functions	
	-- INIT
	for i, ModuleName in pairs(PriorityInitModuleLoading) do
		local FoundModule = UtilitiesModule:WaitForChildTimed(ModulesInitFolder, ModuleName)
		
		if FoundModule then
			RunInitModule(FoundModule)
			
			local FoundInitModuleIndexInTable = table.find(InitModules, FoundModule)
			
			if FoundInitModuleIndexInTable then
				table.remove(InitModules, FoundInitModuleIndexInTable)
			end
		end
	end
	
	for i, ModuleInstance in pairs(InitModules) do
		RunInitModule(ModuleInstance)
	end
end

local function CharacterDied(Character)
	-- Elements
	-- FOLDERS
	local CharacterModulesFolder = UtilitiesModule:WaitForChildTimed(Character, "Modules")
	local ClientCharacterModulesFolder = UtilitiesModule:WaitForChildTimed(CharacterModulesFolder, "Client")
	
	-- Modules
	local FPSControllerModule = require(UtilitiesModule:WaitForChildTimed(ClientCharacterModulesFolder, "FPSController"))
	
	-- Functions
	-- DIRECT
	local Connection1 = nil
	
	Connection1 = Character:GetPropertyChangedSignal("Parent"):Connect(function()
		if Character.Parent ~= nil then
			return nil
		end
		
		Connection1:Disconnect()
		RunService:UnbindFromRenderStep("DeathCamera")
	end)
	
	-- Connections
	--UtilitiesModule:DisconnectConnections(Connections)
	table.insert(Connections, Connection1)
	
	-- INIT
	RequiredModules = {}
	
	--task.wait(.1)
	for i, ModuleInstance in pairs(ClientCharacterModulesFolder:GetChildren()) do
		EndInitModule(ModuleInstance)
	end

	for ModuleName, RequiredModule in pairs(RequiredModules) do
		EndInitModule(RequiredModule)
	end
	
	local _ToGarbageCollect = {}

	for ModuleName, Module in pairs(RequiredModules) do
		_ToGarbageCollect[ModuleName] = Module
	end
	
	FPSControllerModule:Dead()
	
	coroutine.wrap(function()
		task.wait(10) -- Time Out time
		
		for i, ModuleInstance in pairs(ClientCharacterModulesFolder:GetChildren()) do
			GarbageCollectModule(ModuleInstance)
		end

		for ModuleName, RequiredModule in pairs(_ToGarbageCollect) do
			GarbageCollectModule(RequiredModule)
		end
	end)()
end

local function CharacterSpawn(Character)
	--[[if not GameDeployedFolder:FindFirstChild(Player.Name) then
		return nil
	end]]
	
	-- Elements
	-- FOLDERS
	local CharacterModulesFolder = Character:WaitForChild("Modules"):WaitForChild("Client") --UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), "Client")
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then
		return nil
	end
	
	-- Functions
	-- DIRECT
	local Connection
	local Connection1
	local Connection2
	local Connection3 
	local Connection4
	
	Connection1 = Character:GetPropertyChangedSignal("Parent"):Connect(function()
		if Character.Parent == nil then
			UtilitiesModule:DisconnectConnections({Connection, Connection1, Connection2, Connection3, Connection4})
			CharacterDied(Character)
		end
	end)
	
	Connection = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			UtilitiesModule:DisconnectConnections({Connection, Connection1, Connection2, Connection3, Connection4})
			CharacterDied(Character)
		end
	end)
	
	Connection4 = Humanoid.Died:Connect(function()
		UtilitiesModule:DisconnectConnections({Connection, Connection1, Connection2, Connection3, Connection4})
		CharacterDied(Character)
	end)
	
	Connection2 = CharacterModulesFolder.ChildAdded:Connect(function(Child)
		return RunInitModule(Child)
	end)
	
	Connection3 = CharacterModulesFolder.ChildRemoved:Connect(function(Child)
		EndInitModule(Child)
	end)
	
	-- Connections
	UtilitiesModule:DisconnectConnections(Connections)

	table.insert(Connections, Connection)
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	table.insert(Connections, Connection3)
	table.insert(Connections, Connection4)
	
	-- INIT
	InterfacesModule:LoadPage("Custom", "Loading", true)
	
	local PriorityLoad = {"FPSHandler"}
	
	for i, ModuleName in pairs(PriorityLoad) do
		RunInitModule(UtilitiesModule:WaitForChildTimed(CharacterModulesFolder, ModuleName))
	end
	
	for i, ModuleInstance in pairs(CharacterModulesFolder:GetChildren()) do
		if table.find(PriorityLoad, ModuleInstance.Name) ~= nil then
			continue
		end
		
		RunInitModule(ModuleInstance, true)
	end
end

-- DIRECT
Player.CharacterAdded:Connect(CharacterSpawn)

--[[Player:GetPropertyChangedSignal("Character"):Connect(function()
	return CharacterSpawn(UtilitiesModule:GetCharacter(Player))
end)]]

-- INIT
Mouse.Icon = "rbxassetid://10588304006"
pcall(function()
	Player.DevEnableMouseLock = false
end)

--Mouse.Icon = "rbxassetid://8632225050"--rbxassetid://7050626026"
ReplicatedFirstServicee:RemoveDefaultLoadingScreen()

RunInitModules()