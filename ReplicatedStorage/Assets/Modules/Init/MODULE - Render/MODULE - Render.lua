local RenderInitModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local RenderInfoModule = require(InfoModulesFolder["Render"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local SetttingsModule = require(ModulesFolder["Settings"])

local TexturesModule = require(UtilitiesModule:WaitForChildTimed(script, "Textures"))

-- Elements
-- FOLDERS
local MapFolder = UtilitiesModule:WaitForChildTimed(workspace, "Map")["Server"]

-- CORE
local RequiredModulesToLoopThrough = {}
local RenderSubModules = {}
local onLoop = {"ChunkLoader", "Textures", "Shadows"}
local LastRenderTick = tick()

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				local RequiredModule = require(Module)
				
				if RequiredModule.Initialise ~= nil then
					RequiredModule:Initialise()
				end
				
				return RequiredModule
			end)
			
			if not Success then
				--DebugModule:PrintError, "Error")
			else
				RenderSubModules[Module.Name] = Error
			end
		end)()
	end
end

local function onRenderChildAdded(Child)
	-- Functions
	-- INIT
	for ModuleName, RequiredModule in pairs(RenderSubModules) do
		if RequiredModule and RequiredModule.Update ~= nil then
			RequiredModule:Update(Child, SetttingsModule:GetSettingValue("Video", "RenderQuality"))
		end
	end
end

--[[local function onRenderChildRemoved(Child)

end]]

local function Update()
	-- Functions
	-- INIT
	local ServerMapFolder = MapFolder:FindFirstChildOfClass("Folder")
	
	for x, RequiredModule in pairs(RequiredModulesToLoopThrough) do
		if RequiredModule.Loop ~= nil then
			--coroutine.wrap(function()
			RequiredModule:Loop()
			--end)()
		end				
	end

	if ServerMapFolder then
		local DumpFolder = ServerMapFolder:FindFirstChild("Dump")
		
		if not DumpFolder then
			return nil
		end
		
		for i, Child in pairs(DumpFolder:GetDescendants()) do
			--coroutine.wrap(function()
			if Child:IsA("Folder") or not DumpFolder then
				continue
			end

			for x, RequiredModule in pairs(RequiredModulesToLoopThrough) do
				local Success, Error = pcall(function()
					return RequiredModule:Update(Child, SetttingsModule:GetSettingValue("Video", "RenderQuality"))
				end)					
			end
			--end)()
		end
	end
end


local function Render()
	-- Functions
	-- INIT
	local TimeNow = tick()
	
	if TimeNow - LastRenderTick >= RenderInfoModule:GetRenderInfo("LoopDelay") then
		LastRenderTick = TimeNow
		pcall(function()
			Update()
		end)
	end
end


local function MainLoop()
	-- CORE
	local MapFolder = UtilitiesModule:WaitForChildTimed(workspace, "Map")["Server"]
	
	-- Functions
	-- INIT
	for i, Child in pairs(MapFolder:GetDescendants()) do
		onRenderChildAdded(Child)
	end
	
	--coroutine.wrap(function()
		--local RequiredModulesToLoopThrough = {}
		
		for i, ModuleName in pairs(onLoop) do
			if not RenderSubModules[ModuleName] then
				continue
			end

			table.insert(RequiredModulesToLoopThrough, RenderSubModules[ModuleName])
		end
	
		RunService:BindToRenderStep("RenderEngine", Enum.RenderPriority.Last.Value, Render)	
	
		--while task.wait(RenderInfoModule:GetRenderInfo("LoopDelay")) do
			--[[local ServerMapFolder = MapFolder:FindFirstChildOfClass("Folder")
			
			for x, RequiredModule in pairs(RequiredModulesToLoopThrough) do
				if RequiredModule.Loop ~= nil then
					--coroutine.wrap(function()
						RequiredModule:Loop()
					--end)()
				end				
			end
			
			if ServerMapFolder then
				for i, Child in pairs(UtilitiesModule:WaitForChildTimed(ServerMapFolder, "Dump"):GetDescendants()) do
					--coroutine.wrap(function()
						if Child:IsA("Folder") then
							continue
						end
						
					for x, RequiredModule in pairs(RequiredModulesToLoopThrough) do
						local Success, Error = pcall(function()
							return RequiredModule:Update(Child, SetttingsModule:GetSettingValue("Video", "RenderQuality"))
						end)					
					end
					--end)()
				end
			end]]
		--end
	--end)()
end

local function Initialise()
	-- Functions
	-- INIT
	--RunSubModules()
	
	--[[RunSubModules()
	
	MainLoop()]]
end

-- DIRECT
--[[local Connection1 = UtilitiesModule:WaitForChildTimed(workspace, "Map").DescendantAdded:Connect(function(Child)
	return onRenderChildAdded(Child)
end)]]

--[[local Connection2 = UtilitiesModule:WaitForChildTimed(workspace, "Map").DescendantRemoving:Connect(function(Child)
	return onRenderChildRemoved(Child)
end)]]

function RenderInitModule.Initialise()
	return Initialise()
end

return RenderInitModule