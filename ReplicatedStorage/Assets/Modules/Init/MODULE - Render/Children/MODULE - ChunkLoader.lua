local ChunkLoaderModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local SettingsModule = require(ModulesFolder["Settings"])

-- CLIENT
local Player = game.Players.LocalPlayer

-- CORE
local ChunkCache = {}

local RenderModeToDistance = 
{
	["ULTRA HIGH"] = 2000,
	["HIGH"] = 1000,
	["MEDIUM"] = 500,
	["LOW"] = 300,
	["ULTRA LOW"] = 150
}

-- Functions
-- MECHANICS
local function ChunkLoad(Child, RenderMode)
	if not SettingsModule:GetSettingValue("Video", "PerformanceMode", true) then
		return nil
	end
	
	pcall(function()
		if not Child:IsA("BasePart") then
			return nil
		end
		
		-- CORE	
		local RenderDistance = RenderModeToDistance[RenderMode]
		local Character = UtilitiesModule:GetCharacter(Player)
		
		if not Character then
			Character = workspace.CurrentCamera
		end
		
		-- Elements
		-- MODELS
		--[[local Model = nil
		
		if Child:IsA("Model") then
			Model = Child
		else
			Model = Child:FindFirstAncestorOfClass("Model")
		end]]
		
		-- PARTS
		local HumanoidRootPart = nil
		local PrimaryPart = UtilitiesModule:GetPartToShift(--[[Model]] Child)
		
		if Character == workspace.CurrentCamera then
			HumanoidRootPart = Character		
		else
			HumanoidRootPart = UtilitiesModule:GetPartToShift(Character)
		end
		
		-- Functions
		-- INIT
		--[[if Model then
			Child = Model
		end]]
		
		----DebugModule:Print"Pre texture toggle")
			
		if (not Child and not ChunkCache[Child]) or not RenderDistance or (not PrimaryPart and not ChunkCache[Child]) or not Character or not HumanoidRootPart then
			return nil
		end
		
		----DebugModule:Print"Toggling textures | Child: ".. tostring(Child).. " | Mode: ".. tostring(RenderMode))
			
		--[[if not TextureCache[Child] then
			TextureCache[Child] = {}
		end]]
		local PartInfo = ChunkCache[Child] or {LastPosition = Child.Position, Parent = Child.Parent}
		local Magnitude = (HumanoidRootPart.CFrame.Position - PartInfo["LastPosition"]).Magnitude
		
		
		if Magnitude > RenderDistance then
			----DebugModule:Print"Hiding: ".. Child.Name)
			if ChunkCache[Child] ~= nil then
				return nil
			end
			
			--print("Hiding: ".. tostring(Child))
			local OldParent = Child.Parent
			ChunkCache[Child] = {Parent = OldParent, LastPosition = PrimaryPart.CFrame.Position}
			Child.Parent = nil
		else		
			--print("Revealing: ".. Child.Name)
			if ChunkCache[Child] == nil then
				return nil
			end
			
			--print("Revealing: ".. tostring(Child))
			
			if PartInfo["Parent"] then
				Child.Parent = PartInfo["Parent"]
				if PartInfo["LastPosition"] ~= nil then
					Child.Position = PartInfo["LastPosition"]
				end
			end
			
			ChunkCache[Child] = nil
		end
	end)
end

local function UnloadAll()
	-- Functions
	-- INIT
	for Part, PartInfo in pairs(ChunkCache) do
		Part.Parent = PartInfo["Parent"]
		if PartInfo["LastPosition"] ~= nil then
			Part.Position = PartInfo["LastPosition"]
		end
		ChunkCache[Part] = nil
	end
	
	ChunkCache = {}
end

local function Loop()
	-- Functions
	-- INIT
	if not SettingsModule:GetSettingValue("Video", "PerformanceMode", true) then
		if UtilitiesModule:GetSizeOfDict(ChunkCache) > 0 then
			UnloadAll()
		end
		
		return nil
	end
	
	for Part, PartInfo in pairs(ChunkCache) do
		--coroutine.wrap(function()
			pcall(function()
				ChunkLoad(Part, SettingsModule:GetSettingValue("Video", "RenderQuality"))
			end)
		--end)()
	end
end

-- DIRECT
function ChunkLoaderModule.Update(NilParam, Child, RenderMode)
	pcall(function()
		return ChunkLoad(Child, RenderMode)
	end)
end

function ChunkLoaderModule.Loop()
	--return nil
	return Loop()
end

return ChunkLoaderModule