local BulletLingerModule = {}

-- Dirs
local PartsBeamsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Beams"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SettingsModule = require(SharedModulesFolder["Settings"])

-- Functions
-- MECHANICS
local function CreatePointPart(Position)
	-- Functions
	-- INIT
	local PointPart = Instance.new("Part")
	PointPart.Size = Vector3.new(.1, 0, .1, 0)
	PointPart.CanCollide = false
	PointPart.CanTouch = false
	PointPart.CanQuery = false
	PointPart.Transparency = 1
	PointPart.Anchored = true
	PointPart.Position = Position
	PointPart.Name = "BulletLingerNode"
	PointPart.Parent = workspace:WaitForChild("Dump")["Misc"]
	
	local Attachment = Instance.new("Attachment")
	Attachment.Parent = PointPart
	
	return PointPart, Attachment
end

local function Initialise(StartPosition, EndPosition, LingerInfo)
	-- Functions
	-- INIT
	local FoundBeam = PartsBeamsFolder:FindFirstChild(LingerInfo["Beam"])
	
	if FoundBeam then
		FoundBeam = FoundBeam:Clone()
	else
		return nil
	end

	if LingerInfo["BeamProperties"] then
		for PropertyName, PropertyValue in pairs(LingerInfo["BeamProperties"]) do
			FoundBeam[PropertyName] = PropertyValue
		end
	end
	
	local StartNode, StartAttchment = CreatePointPart(StartPosition)
	local EndNode, EndAttachment = CreatePointPart(EndPosition)
	
	--StartNode.Parent = workspace:WaitForChild("Dump")["Misc"]
	--EndNode.Parent = workspace:WaitForChild("Dump")["Misc"]
	
	FoundBeam.Attachment0 = StartAttchment
	FoundBeam.Attachment1 = EndAttachment
	FoundBeam.Parent = StartNode
	
	if SettingsModule:GetSettingValue("Video", "BulletSpecular", true) then
		coroutine.wrap(function()
			local Increment = UtilitiesModule:GetNumberFromSequence(FoundBeam.Transparency, 0)
			
			for i = 1, 100 do
				FoundBeam.Transparency = NumberSequence.new
				{
					NumberSequenceKeypoint.new(0, Increment),
					NumberSequenceKeypoint.new(1, Increment)							
				}
				
				Increment += 0.01
				task.wait()
				
				if not FoundBeam then
					break
				end
			end
		end)()
	end
	
	DebrisModule:AddItem(StartNode, LingerInfo["Duration"])
	DebrisModule:AddItem(EndNode, LingerInfo["Duration"])
end

-- DIRECT
function BulletLingerModule.Initialise(NilParam, EffectsHandlerModule, StartPosition, EndPosition, LingerInfo)
	Initialise(StartPosition, EndPosition, LingerInfo)
end

return BulletLingerModule