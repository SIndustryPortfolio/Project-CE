local TagModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local CamosInfoModule = require(InfoModulesFolder["Camos"])

-- Modules
local SettingsModule = require(SharedModulesFolder["Settings"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
--local CustomConnectionsCache = {}

--local TweensCache = {}

--local AnimatedEffectInfo = 
--{
--	["Duration"] = 40,
--	["Style"] = Enum.EasingStyle.Linear,
--	["Direction"] = Enum.EasingDirection.Out,
--	["Repeat"] = -1,
--	["Reverse"] = false,
--	["Delay"] = 0.0,
--}

--local RefreshTableTime = 1
--local LastRefreshedTable = tick()

local RenderTickRate = 2
local FrameIndex = 0

local AnimatedWeapons = {}

-- Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
--[[local function RefreshTable()
	-- CORE
	--local Cancelled = false
	
	-- Functions
	-- INIT
	for WeaponModel, WeaponTextures in pairs(AnimatedWeapons) do
		if not WeaponModel or not WeaponModel.Parent then
			AnimatedWeapons[WeaponModel] = nil
			WeaponModel:Destroy()
			--Cancelled = true
			--break
		end
	end
	
	--[[if Cancelled then
		return RefreshTable()
	end]]
--end

--[[local function AddToCache(Model, Tweens)
	-- Functions
	-- INIT
	if not TweensCache[Model] then
		TweensCache[Model] = {}
	end
	
	for i, Tween in pairs(Tweens) do
		table.insert(TweensCache[Model], Tween)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not TweensCache[Model] then
		return nil
	end
	
	for i, Tween in pairs(TweensCache[Model]) do
		Tween:Cancel()
		Tween:Destroy()
	end
	
	TweensCache[Model] = nil
end]]

--[[local function AddToCache(Model, Connections)
	-- FUNCTIONS
	-- INIT
	if not CustomConnectionsCache[Model] then
		CustomConnectionsCache[Model] = {}
	end
	
	for i, Connection in pairs(Connections) do
		table.insert(CustomConnectionsCache[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	--UtilitiesModule:DisconnectConnections(CustomConnectionsCache[Model])
	UtilitiesModule:DisconnectCustomConnections(CustomConnectionsCache[Model])
	CustomConnectionsCache[Model] = nil
end]]

local function GetAllTexturesFromWeaponModel(WeaponModel)
	-- CORE
	local Textures = {}
	
	-- Functions
	-- INIT
	for i, Texture in pairs(UtilitiesModule:WaitForChildTimed(WeaponModel, "Colourable"):GetDescendants()) do
		if not Texture:IsA("Texture") then
			continue
		end
		
		table.insert(Textures, Texture)
	end
	
	return Textures
end

local function Render()
	-- Functions
	-- INIT
	FrameIndex += 1
	
	if FrameIndex > 60 then
		FrameIndex = 0
	end
	
	if (FrameIndex % RenderTickRate == 0) then
		return nil		
	end
		
	if SettingsModule:GetSettingValue("Video", "AnimatedCamos", true) == false then
		return nil
	end
	
	--[[if (tick() - LastRefreshedTable) >= RefreshTableTime then
		RefreshTable()
		LastRefreshedTable = tick()
	end]]
	
	for WeaponModel, WeaponTextures in pairs(AnimatedWeapons) do
		if not WeaponModel then
			AnimatedWeapons[WeaponModel] = nil
			continue
		end
		
		for i, Texture in pairs(WeaponTextures) do
			if not Texture then
				continue
			end
			
			if Texture["OffsetStudsU"] >= Texture["StudsPerTileU"] then
				Texture["OffsetStudsU"] = 0
				Texture["OffsetStudsV"] = 0
				continue
			end
			
			Texture["OffsetStudsU"] += .02083
			Texture["OffsetStudsV"] += .02083
		end
	end	
end

local function Intialise(WeaponModel)
	-- Functions
	-- INIT
	if not WeaponModel then
		DebugModule:Print(script.Name.. " | WeaponModel doesn't exist")
		return nil
	end
	
	AnimatedWeapons[WeaponModel] = GetAllTexturesFromWeaponModel(WeaponModel)
	
	--[[-- CORE
	DebugModule:Print("AnimatedWeaponCamo | Applying animation to weapon: ".. tostring(WeaponModel))
	
	local WeaponTextures = GetAllTexturesFromWeaponModel(WeaponModel)
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	local tweenInfo = TweenInfo.new(AnimatedEffectInfo["Duration"], AnimatedEffectInfo["Style"], AnimatedEffectInfo["Direction"], AnimatedEffectInfo["Repeat"], AnimatedEffectInfo["Reverse"], AnimatedEffectInfo["Delay"])
	local Tweens = {}
	
	-- Functions
	-- INIT
	if SettingsModule:GetSettingValue("Video", "AnimatedCamos", true) == false then
		DebugModule:Print("AnimatedWeaponCamo | Cancelled camo animation -> Setting disabled")
		return nil
	end
	
	for i, Texture in pairs(WeaponTextures) do
		local TextureTween1 = TweenService:Create(Texture, tweenInfo, {["OffsetStudsU"] = 50})
		local TextureTween2 = TweenService:Create(Texture, tweenInfo, {["OffsetStudsV"] = 50})
		
		-- Cache
		table.insert(Tweens, TextureTween1)
		table.insert(Tweens, TextureTween2)
		
		-- INIT
		TextureTween1:Play()
		TextureTween2:Play()
	end
	
	AddToCache(WeaponModel, Tweens)]]
end

local function End(WeaponModel)
	-- Functions
	-- INIT
	--RemoveFromCache(WeaponModel)
	AnimatedWeapons[WeaponModel] = nil
end

-- DIRECT
function TagModule.Initialise(NilParam, WeaponModel)
	return Intialise(WeaponModel)
end

function TagModule.End(NilParam, WeaponModel)
	return End(WeaponModel)
end

-- INIT
RunService:BindToRenderStep("AnimatedCamos", Enum.RenderPriority.Last.Value, Render)

return TagModule