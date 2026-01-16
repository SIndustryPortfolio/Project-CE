local SetupCharacterShieldModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ParticlesModule = require(ModulesFolder["Particles"])
local SoundsModule = require(ModulesFolder["Sounds"])
--local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local TweenDict = {}

local EffectInfo = 
{
	["Duration"] = 0.3,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut
}

local PostEffectInfo = 
{
	["Duration"] = .5,
	["Style"] = Enum.EasingStyle.Linear,
	["Direction"] = Enum.EasingDirection.InOut		
}

-- Services
local TweenService = game:GetService("TweenService")
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function FilterPart(Part)
	-- Functions
	-- INIT
	for i, _Part in pairs(Part:GetChildren()) do
		if _Part:IsA("SpecialMesh") then
			continue
		end
		
		_Part:Destroy()
	end
end

local function PostLoaded(EffectsHandlerModule, Character)
	-- CORE
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	local tweenInfo = TweenInfo.new(PostEffectInfo["Duration"], PostEffectInfo["Style"], PostEffectInfo["Direction"])
	local tweeningInfo = {}
	tweeningInfo.C0 = CFrame.new(0, -Humanoid.HipHeight, 0)
	
	local tweeningInfo1 = {}
	tweeningInfo1.Transparency = 1
	
	-- Functions
	-- INIT
	coroutine.wrap(function()
		for i = 1, 3 do
			local HollowGlassCircle = EffectsHandlerModule:LoadParticleEmitter(Character.PrimaryPart, "HollowGlassRing", CFrame.new(0, -(Humanoid.HipHeight / 2), 0), Character.PrimaryPart)
			local FoundWeld = HollowGlassCircle:FindFirstChildOfClass("ManualWeld")
			
			if not FoundWeld then
				continue
			end
			
			UtilitiesModule:CancelTween(FoundWeld, TweenDict)
			TweenDict[FoundWeld] = TweenService:Create(FoundWeld, tweenInfo, tweeningInfo)
			TweenDict[FoundWeld]:Play()
			UtilitiesModule:CompleteTween(FoundWeld, TweenDict)
			
			UtilitiesModule:CancelTween(HollowGlassCircle, TweenDict)
			TweenDict[HollowGlassCircle] = TweenService:Create(HollowGlassCircle, tweenInfo, tweeningInfo1)
			TweenDict[HollowGlassCircle]:Play()
			UtilitiesModule:CompleteTween(HollowGlassCircle, TweenDict)
			
			SoundsModule:PlaySoundEffectByName("CharacterActions", "SpawnShield", nil, Character.PrimaryPart)
			
			DebrisModule:AddItem(HollowGlassCircle, PostEffectInfo["Duration"])
			
			task.wait(PostEffectInfo["Duration"] / 2)
		end
	end)()
	
end

local function SetupFilterCharacter(Character)
	-- CORE
	local CharacterClone = Character:Clone()
	
	local PropertiesToRemove = 
	{
		["ClassName"] = {"Humanoid", "LocalScript", "Script", "Motor6D", "Attachment", "ModuleScript", "ParticleEmitter", "Texture", "Decal"},
		["Name"] = {"Core", "Modules", "Remotes", "ViewModels", "HumanoidRootPart", "htp", "Back"}
	}
	
	local AttributesToRemove = 
	{
		["Weapon"] = {true}	
	}
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = CharacterClone:FindFirstChildOfClass("Humanoid")
	
	if Humanoid then
		Humanoid:Destroy()
	end
	
	-- Functions		
	-- Properties
	CharacterClone.Name = "ShieldEffect"
	
	-- INIT
	for PropertyName, Table in pairs(PropertiesToRemove) do
		for x, Part in pairs(CharacterClone:GetDescendants()) do
			pcall(function()
				if table.find(Table, Part[PropertyName]) then
					Part:Destroy()
				end
			end)
		end
	end		
	
	for AttributeName, Table in pairs(AttributesToRemove) do
		for x, Part in pairs(CharacterClone:GetDescendants()) do
			pcall(function()
				if table.find(Table, Part:GetAttributes()[AttributeName]) then
					Part:Destroy()
				end
			end)
		end
	end
	
	if CharacterClone:GetAttribute("EquippedWeapon") ~= nil then
		local FoundServerGunModel = CharacterClone:FindFirstChild(CharacterClone:GetAttribute(Character:GetAttribute("EquippedWeapon")))
		
		if FoundServerGunModel then
			FoundServerGunModel:Destroy()
		end
	end
	
	for i, Part in pairs(CharacterClone:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		local CharacterPart = Character:FindFirstChild(Part.Name)
		local SpecialMesh = Part:FindFirstChildOfClass("SpecialMesh")
		
		Part.Transparency = 1
		Part.Material = Enum.Material.ForceField
		Part.Color = Color3.fromRGB(255, 255, 0)
		--Part.Size *= 1.1
		
		if SpecialMesh then
			SpecialMesh.Scale *= 1.1
		end
		
		Part.CanCollide = false
		Part.CanTouch = false
		Part.CanQuery = false
		
		if Part:IsA("MeshPart") then
			Part.TextureID = "rbxassetid://5101923607"
		end
		
		FilterPart(Part) --Part:ClearAllChildren()
		
		UtilitiesModule:WeldParts(Part, CharacterPart, true)
	end
	
	CharacterClone.Parent = Character
	
	return CharacterClone
end

local function Initialise(EffectsHandlerModule, Character)
	-- Elements
	-- HUMANOIDS
	--local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")
	
	-- Functions
	-- INIT
	if not Character:FindFirstChild("ShieldEffect") --[[and Humanoid:GetAttribute("Shield") > 0 and Humanoid.Health > 0]] then
		SetupFilterCharacter(Character)
		PostLoaded(EffectsHandlerModule, Character)
	end
end

-- DIRECT
function SetupCharacterShieldModule.Initialise(NilParam, EffectsHandlerModule, Character)
	return Initialise(EffectsHandlerModule, Character)
end

return SetupCharacterShieldModule