local CameraSequencesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local CameraSequencesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["CameraSequences"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local TweenDict = {}
local CustomConnections = {}
local RunningSequence = ""

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
--[[local function CreateCustomConnection()
	-- Instancing
	local CustomConnection = Instance.new("BoolValue")
	CustomConnection.Value = true
	
	table.insert(CustomConnections, CustomConnection)
	
	return CustomConnection
end]]

local function SetupCamera(Camera)
	-- Properties
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject =  nil
end

local function GetCamera()
	return workspace.CurrentCamera
end

local function GetSequence(SequenceName)
	return UtilitiesModule:WaitForChildTimed(CameraSequencesFolder, SequenceName)
end

local function ExecuteSequence(SequenceName)
	if SequenceName == RunningSequence then
		return nil
	end
	
	-- Elements
	-- FOLDERS
	local SequenceFolder = GetSequence(SequenceName)
	local PathFolder = SequenceFolder["Path"]

	-- CORE
	local Camera = GetCamera()
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections) --CreateCustomConnection()	
	local SectionFolders = PathFolder:GetChildren()
	
	local Looped = PathFolder:GetAttribute("Looped")
	local tweenInfo = TweenInfo.new(PathFolder:GetAttribute("Duration"), Enum.EasingStyle[PathFolder:GetAttribute("EasingStyle")], Enum.EasingDirection[PathFolder:GetAttribute("EasingDirection")])
	
	-- Functions
	-- INIT
	SetupCamera(Camera)
	
	local Pass = true
	
	RunningSequence = SequenceName
	
	coroutine.wrap(function()
		while Pass and CustomConnection and CustomConnection.Value do
			for i = 1, #SectionFolders do
				-- Elements
				-- FOLDERS
				local NodeFolder = UtilitiesModule:WaitForChildTimed(PathFolder, tostring(i))
				
				-- INIT
				local LoopToo = #NodeFolder:GetChildren()
				local StartNode = NodeFolder:FindFirstChild("Start")
				
				if StartNode then
					Camera.CFrame = StartNode.CFrame
					LoopToo -= 1
				end
				
				
				for x = 1, LoopToo do
					local SelectedNode = NodeFolder[x]
					
					local tweeningInfo = {}
					tweeningInfo.CFrame = SelectedNode.CFrame
					
					UtilitiesModule:CancelTween(Camera, TweenDict)
					TweenDict[Camera] = TweenService:Create(Camera, tweenInfo, tweeningInfo)
					TweenDict[Camera]:Play()
					UtilitiesModule:CompleteTween(Camera, TweenDict)
					
					UtilitiesModule:BetterCountdown(PathFolder:GetAttribute("Duration"), CustomConnection)
					
					if not CustomConnection or not CustomConnection.Value then
						return nil
					end			
				end
				
				if not CustomConnection or not CustomConnection.Value then
					return nil
				end
			end
			
			if not CustomConnection or not CustomConnection.Value then
				return nil
			end	
			
			if not Looped then
				Pass = false
			end
		end
	end)()
end

local function StopAllSequences()
	-- Functions
	-- INIT
	RunningSequence = ""
	UtilitiesModule:DisconnectCustomConnections(CustomConnections)
	UtilitiesModule:CancelTween(GetCamera(), TweenDict)
end

-- INIT
function CameraSequencesModule.GetSequence()
	return RunningSequence
end

function CameraSequencesModule.ExecuteSequence(NilParam, SequenceName)
	return ExecuteSequence(SequenceName)
end

function CameraSequencesModule.StopAllSequences()
	return StopAllSequences()
end

return CameraSequencesModule